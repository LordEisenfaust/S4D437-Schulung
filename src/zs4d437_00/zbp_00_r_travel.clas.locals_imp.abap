CLASS lsc_z00_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z00_r_travel IMPLEMENTATION.

  METHOD save_modified.

    DATA event_parameter TYPE TABLE FOR EVENT z00_r_travel~travelCreated.

    IF create-travel IS NOT INITIAL.
      event_parameter = VALUE #( FOR line IN create-travel ( %key = line-%key origin = 'Z00_R_TRAVEL'  ) ).

      RAISE ENTITY EVENT z00_r_travel~travelCreated
      FROM event_parameter.

    ENDIF.


    DATA(model) = NEW /lrn/cl_s4d437_tritem( i_table_name = 'Z00_TRITEM' ).

    LOOP AT delete-item ASSIGNING FIELD-SYMBOL(<item_d>).
      model->delete_item( <item_d>-ItemUuid ).
    ENDLOOP.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<item_c>).
      model->create_item(
        EXPORTING
          i_item    = CORRESPONDING #( <item_c> MAPPING FROM ENTITY ) ).

    ENDLOOP.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item_u>).
      model->update_item(
        EXPORTING
         i_item    = CORRESPONDING #( <item_u> MAPPING FROM ENTITY )
          i_itemx   = CORRESPONDING #( <item_u> MAPPING FROM ENTITY USING CONTROL )
     ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validateDate.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD validateDate.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY Item
    FIELDS ( flightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(items)
    BY \_Travel
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travel)
    LINK DATA(link).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
      APPEND VALUE #(  %tky = <item>-%tky %state_area = 'ITEMDATE' ) TO reported-item.
      READ TABLE link INTO DATA(s_link) WITH KEY source-ItemUUid = <item>-ItemUuid ##PRIMKEY[ENTITY].

      READ TABLE travel INTO DATA(s_travel) WITH KEY agencyId = s_link-target-AgencyId
      travelId = s_link-target-travelId ##PRIMKEY[ENTITY].

      IF <item>-FlightDate < s_travel-begindate OR <item>-flightdate > s_travel-EndDate.
        APPEND VALUE #( %tky = <item>-%tky ) TO failed-item.

        APPEND VALUE #( %state_area = 'ITEMDATE'
                        %element-FlightDate = if_abap_Behv=>mk-on
                        %path-travel = CORRESPONDING #( s_travel-%tky )
                        %tky = <item>-%tky
                        %msg = NEW zcm_00_messages( textid = zcm_00_messages=>flight_outside_trip
                        severity = if_abap_Behv_message=>severity-error )
       ) TO reported-item.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.



    METHODS cancelTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancelTravel.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.
    METHODS validateBeginDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBeginDate.
    METHODS validateDateSequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDateSequence.

    METHODS validateEndDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateEndDate.
    METHODS validateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDescription.
    METHODS setStatusNew FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setStatusNew.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS determineduration FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~determineduration.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

    result = CORRESPONDING #(  keys ).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).

*      AUTHORITY-CHECK OBJECT '/LRN/AGCY'
*      ID '/LRN/AGCY' FIELD <line>-AgencyId
*      ID 'ACTVT' FIELD '02'. "Change authorization

      DATA(rc) = /lrn/cl_s4d437_model=>authority_check(
                   i_agencyid = <line>-AgencyId
                    i_actvt    = '02'
                 ).

      IF rc = 0.
        <line>-%update = if_abap_behv=>auth-allowed.
        <line>-%action-cancelTravel = if_abap_behv=>auth-allowed.
      ELSE.
        <line>-%update = if_abap_behv=>auth-unauthorized.
        <line>-%action-cancelTravel = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancelTravel.

    DATA oMessage TYPE REF TO zcm_00_messages.

    READ ENTITIES OF z00_r_Travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( BeginDate EndDate Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).

      IF <line>-status = 'C'. "already cancelled
        APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.
        oMessage = NEW #( textid = zcm_00_messages=>trip_cancelled
        severity = if_abap_behv_message=>severity-error ).

        APPEND VALUE #( %tky = <line>-%tky %msg = oMessage ) TO reported-travel.
      ELSEIF <line>-BeginDate < cl_abap_context_info=>get_system_date( ). "trip already running

        APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.

        oMessage =  NEW #( textid = zcm_00_messages=>trip_started
        severity = if_abap_behv_message=>severity-error ).
        APPEND VALUE #( %tky = <line>-%tky %msg = oMessage ) TO reported-travel.
      ELSE.
        <line>-status = 'C'.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z00_r_travel IN LOCAL MODE
     ENTITY travel
     UPDATE FIELDS ( status )
     WITH CORRESPONDING #( result ).

  ENDMETHOD.

  METHOD validateCustomer.

    DATA check_id TYPE abap_bool.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      APPEND VALUE #(  %tky = <line>-%tky %state_area = 'CUSTOMER' ) TO reported-travel.
      check_id = abap_false.
      SELECT SINGLE FROM /dmo/i_customer
      FIELDS @abap_true
      WHERE CustomerID = @<line>-customerId
      INTO @check_id.

      IF check_id = abap_false.
        APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.
        APPEND VALUE #(
        %state_area = 'CUSTOMER'
        %tky = <line>-%tky
                        %element-customerId = if_abap_behv=>mk-on
                        %msg = NEW zcm_00_messages(
                        textid = zcm_00_messages=>no_customer
                        severity = if_abap_Behv_message=>severity-error
                        i_customer = <line>-customerId
                        )
                          ) TO  reported-travel.
      ENDIF.



    ENDLOOP.


  ENDMETHOD.

  METHOD validateBeginDate.


    FINAL(today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
      ENTITY travel
      FIELDS ( BeginDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      APPEND VALUE #(  %tky = <line>-%tky %state_area = 'BEGIN'  ) TO reported-travel.

      IF <line>-beginDate < today.
        APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.
        APPEND VALUE #(
        %state_area = 'BEGIN'
        %tky = <line>-%tky
                        %element-BeginDate = if_abap_behv=>mk-on
                        %msg = NEW zcm_00_messages(
                        textid = zcm_00_messages=>start_past
                        severity = if_abap_Behv_message=>severity-error
                        )
                          ) TO  reported-travel.
      ENDIF.



    ENDLOOP.

  ENDMETHOD.

  METHOD validateDateSequence.
    FINAL(today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
      ENTITY travel
      FIELDS ( BeginDate EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      APPEND VALUE #(  %tky = <line>-%tky %state_area = 'SEQUENCE'  ) TO reported-travel.

      IF <line>-endDate < <line>-beginDate.
        APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.
        APPEND VALUE #(
        %state_area = 'SEQUENCE'
        %tky = <line>-%tky
                        %element-BeginDate = if_abap_behv=>mk-on
                        %element-EndDate = if_abap_behv=>mk-on
                        %msg = NEW zcm_00_messages(
                        textid = zcm_00_messages=>end_before_Start
                        severity = if_abap_Behv_message=>severity-error
                        )
                          ) TO  reported-travel.
      ENDIF.



    ENDLOOP.

  ENDMETHOD.

  METHOD validateEndDate.
    FINAL(today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
      ENTITY travel
      FIELDS ( EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      APPEND VALUE #(  %tky = <line>-%tky %state_area = 'END'  ) TO reported-travel.

      IF <line>-endDate < today.
        APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.
        APPEND VALUE #(
        %state_area = 'END'
        %tky = <line>-%tky
                        %element-endDate = if_abap_behv=>mk-on
                        %msg = NEW zcm_00_messages(
                        textid = zcm_00_messages=>end_past
                        severity = if_abap_Behv_message=>severity-error
                        )
                          ) TO  reported-travel.
      ENDIF.



    ENDLOOP.
  ENDMETHOD.

  METHOD validateDescription.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

* Do not assign state area!!
      APPEND VALUE #(  %tky = <key>-%tky %msg = NEW zcm_00_messages( textid = zcm_00_messages=>description_changed severity = if_abap_behv_message=>severity-success ) )
      TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.

    mapped-travel = CORRESPONDING #( entities ).

    DATA(agency) = /lrn/CL_S4d437_model=>get_agency_by_user(  ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<key>).
      <key>-AgencyId = agency.
      <key>-travelId = /lrn/cl_s4D437_model=>get_next_travelid(  ).
    ENDLOOP.

  ENDMETHOD.

  METHOD setStatusNew.

    READ ENTITIES OF z00_r_Travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      <line>-status = 'N' .
    ENDLOOP.

    MODIFY ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( status )
    WITH CORRESPONDING #( result ) .

  ENDMETHOD.

  METHOD get_instance_features.

    FINAL(today) = cl_abap_context_Info=>get_system_date( ).

    READ ENTITIES OF z00_r_Travel IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<line>).
      APPEND CORRESPONDING #(  <line> ) TO result
      ASSIGNING FIELD-SYMBOL(<action>).

      IF <line>-%is_draft = if_abap_behv=>mk-on. "Draft instance: Get active data

        READ ENTITIES OF z00_r_Travel IN LOCAL MODE
        ENTITY travel
        ALL FIELDS
        WITH VALUE #( (  %key = <line>-%key %is_draft = if_abap_behv=>mk-off ) ) "%key contains key fields *without* %is_Draft
        RESULT DATA(active) .

* New Draft
        IF lines( active ) = 0. " or IS INITIAL
          <line>-BeginDate = '00000000'.
          <line>-endDate = '00000000'.
* Edit Draft
        ELSE.
          <line>-beginDate = active[ 1 ]-BeginDate.
          <line>-EndDate = active[ 1 ]-EndDate.

        ENDIF.
      ENDIF.


* No Edit for cancelled trip
      IF <line>-status = 'C'.
        <action>-%features-%update = if_abap_behv=>fc-o-disabled.
      ELSE.
        <action>-%features-%update = if_abap_behv=>fc-o-enabled.
      ENDIF.
* Set availablity of action
      IF <line>-BeginDate < today.
* Trip already started. Switch off cancel function
        <action>-%action-cancelTravel = if_abap_behv=>fc-o-disabled.
      ELSE.
        <action>-%action-cancelTravel = if_abap_behv=>fc-o-enabled.
      ENDIF.

* Set read-only fields
      IF <line>-beginDate < today AND <line>-beginDate IS NOT INITIAL.
        <action>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <action>-%field-BeginDate = if_abap_behv=>fc-f-unrestricted.
      ENDIF.

      IF <line>-endDate < today AND <line>-endDate IS NOT INITIAL.
        <action>-%field-EndDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <action>-%field-EndDate = if_abap_behv=>fc-f-unrestricted.
      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD determineDuration.

    READ ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( beginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      <line>-duration = <line>-endDate - <line>-BeginDate + 1.
      IF <line>-duration < 1.
        <line>-duration = 0.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z00_r_travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( duration  )
    WITH CORRESPONDING #(  result ).


  ENDMETHOD.

ENDCLASS.
