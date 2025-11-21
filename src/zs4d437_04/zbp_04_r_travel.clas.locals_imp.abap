CLASS lsc_z04_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z04_r_travel IMPLEMENTATION.

  METHOD save_modified.
    DATA(model) = new /lrn/cl_s4d437_tritem( i_table_name = 'Z04_TRITEM' ).
    LOOP AT delete-item ASSIGNING FIELD-SYMBOL(<item_d>).

        model->delete_item( <item_d>-itemUuid ).

    ENDLOOP.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<item_c>).
*        model->create_item( exporting i_item = corresponding #( <item_c> MAPPING FROM ENTITY ) ).
    ENDLOOP.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item_u>).
*        model->update_item( EXPORTING i_item = CORRESPONDING #( <item_u> MAPPING FROM ENTITY ) i_itemx = CORRESPONDING #( <item_u> MAPPING FROM ENTITY
*                                                   USING CONTROL ) ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS flightDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~flightDate.
    METHODS determineTravelDates FOR DETERMINE ON SAVE
      IMPORTING keys FOR Item~determineTravelDates.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD flightDate.
    READ ENTITIES OF z04_r_travel IN LOCAL MODE ENTITY Item FIELDS ( FlightDate AgencyId TravelId )
        WITH CORRESPONDING #( keys )
            RESULT DATA(items).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<ls_item>).
        APPEND VALUE #( %tky = <ls_item>-%tky %state_area = 'FLIGHTDATE' ) TO reported-item.
        IF <ls_item>-flightdate is INITIAL.
            APPEND VALUE #( %tky = <ls_item>-%tky
                            %msg = new /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                            %element-FlightDate = if_abap_behv=>mk-on
                            %state_area = 'FLIGHTDATE'
                            %path-travel = VALUE #( AgencyId = <ls_item>-AgencyId
                                          TravelId = <ls_item>-TravelId %is_draft = <ls_item>-%is_draft )

                           ) TO reported-item.
        ELSEIF <ls_item>-FlightDate < cl_abap_context_info=>get_system_date( ).
            APPEND VALUE #( %tky = <ls_item>-%tky ) to failed-item.

        ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD determineTravelDates.
    READ ENTITIES OF Z04_R_Travel IN LOCAL MODE ENTITY Item
        FIELDS ( FlightDate ) WITH CORRESPONDING #( keys ) RESULT DATA(items)
        by \_Travel FIELDS ( BeginDate EndDate )
           WITH CORRESPONDING #( keys ) RESULT DATA(travels) LINK DATA(link).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
        ASSIGN travels[ %tky = link[ source-%tky = <item>-%tky ]-target-%tky ] TO FIELD-SYMBOL(<travel>).
        IF <item>-FlightDate > cl_abap_context_info=>get_system_date( )
            AND <item>-FlightDate < <travel>-BeginDate.
            <travel>-BeginDate = <item>-FlightDate.
        ENDIF.
        MODIFY ENTITIES OF Z04_R_Travel IN LOCAL MODE ENTITY Travel
            UPDATE FIELDS ( BeginDate EndDate ) WITH CORRESPONDING #( travels ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancel_travel.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDescription.
    METHODS validateBegda FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBegda.
    METHODS validateEndda FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateEndda.
    METHODS determineStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~determineStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS determineduration FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~determineduration.
    METHODS validatedatesequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedatesequence.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.



ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = CORRESPONDING #( keys ).
    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
        data(rc) = /lrn/cl_s4d437_model=>authority_check( i_agencyid = <line>-AgencyId i_actvt = '02' ).
        if rc <> 0.
          <line>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
          <line>-%update = if_abap_behv=>auth-unauthorized.
        else.
          <line>-%action-cancel_travel = if_abap_behv=>auth-allowed.
          <line>-%update = if_abap_behv=>auth-allowed.
        endif.

    ENDLOOP.
  ENDMETHOD.


  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.
    DATA oMessage TYPE REF TO zcm_04_messages.
    READ ENTITIES OF z04_r_travel IN LOCAL MODE
        ENTITY Travel FIELDS ( BeginDate EndDate Status )
            WITH CORRESPONDING #( keys )
                RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
        IF <line>-Status = 'C'.
            APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.
            oMessage = new #( textid = zcm_04_messages=>trip_canceld
                        severity = if_abap_behv_message=>severity-error ).
            APPEND VALUE #( %tky = <line>-%tky %msg = omessage ) TO reported-travel.

        ELSEIF <line>-BeginDate < cl_abap_context_info=>get_system_date(  ).
            APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.
            oMessage = NEW #( textid = zcm_04_messages=>trip_started
                              severity = if_abap_behv_message=>severity-error
                            ).
            APPEND VALUE #( %tky = <line>-%tky %msg = omessage ) TO reported-travel.
        ELSE.
            <line>-status = 'C'.
        ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z04_r_travel IN LOCAL MODE
        ENTITY Travel
            UPDATE FIELDS ( status )
                WITH CORRESPONDING #( result ).
  ENDMETHOD.


  METHOD validateCustomer.
    DATA oMessage TYPE REF TO zcm_04_messages.
    omessage = new #( textid = zcm_04_messages=>trip_canceld severity = if_abap_behv_message=>severity-error ).
    READ ENTITIES OF z04_r_travel IN LOCAL MODE
        ENTITY Travel
            FIELDS ( CustomerId )
                WITH CORRESPONDING #( keys )
                    RESULT DATA(result).
    LOOP AT result ASSIGNING FIELD-SYMBOL(<ls_result>).
        SELECT SINGLE FROM /DMO/I_Customer
            FIELDS 'X'
                WHERE CustomerID = @<ls_result>-CustomerId
                    INTO @DATA(check_id).
        if check_id = abap_false.
          APPEND VALUE #( %tky = <ls_result>-%tky ) to failed-travel.

          APPEND VALUE #( %tky = <ls_result>-%tky %element-customerId = if_abap_behv=>mk-on
                          %msg = new zcm_04_messages( textid = zcm_04_messages=>customer_not_exist severity = if_abap_behv_message=>severity-error i_customer_id = <ls_result>-CustomerId )  ) TO reported-travel.
        endif.
        clear check_id.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDescription.
*    CONSTANTS c_area TYPE string VALUE `DESC`.
*    READ ENTITIES OF z04_r_travel IN LOCAL MODE
*        ENTITY Travel
*            FIELDS ( Description )
*                WITH CORRESPONDING #( keys )
*                    RESULT DATA(result).
*    LOOP AT result ASSIGNING FIELD-SYMBOL(<travel>).
*        IF <travel>-Description IS INITIAL.
*            APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
*                %element-CustomerId = if_abap_behv=>mk-on %state_area = c_area ) TO reported-travel.
*        ELSE.
*            APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>customer_not_exist
*                customerid = <travel>-CustomerId ) %element-CustomerId = if_abap_behv=>mk-on %state_area = c_area )
*                    TO reported-travel.
*        ENDIF.
*    ENDLOOP.

  ENDMETHOD.

  METHOD validateBegda.
    DATA oMessage TYPE REF TO zcm_04_messages.
    FINAL(today) = cl_abap_context_info=>get_system_date( ).
    omessage = new #( textid = zcm_04_messages=>trip_canceld severity = if_abap_behv_message=>severity-error ).
    READ ENTITIES OF z04_r_travel IN LOCAL MODE
        ENTITY Travel
            FIELDS ( BeginDate )
                WITH CORRESPONDING #( keys )
                    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<ls_result>).

        if <ls_result>-BeginDate is INITIAL.
          APPEND VALUE #( %tky = <ls_result>-%tky ) to failed-travel.

          APPEND VALUE #( %tky = <ls_result>-%tky %element-BeginDate = if_abap_behv=>mk-on
                          %msg = new zcm_04_messages( textid = zcm_04_messages=>start_initial severity = if_abap_behv_message=>severity-error  )  )
                          TO reported-travel.
        ELSEIF <ls_result>-BeginDate < today.
          APPEND VALUE #( %tky = <ls_result>-%tky ) to failed-travel.

          APPEND VALUE #( %tky = <ls_result>-%tky %element-BeginDate = if_abap_behv=>mk-on
                          %msg = new zcm_04_messages( textid = zcm_04_messages=>start_past severity = if_abap_behv_message=>severity-error  )  )
                          TO reported-travel.
        endif.
*        clear check_id.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateEndda.
      DATA oMessage TYPE REF TO zcm_04_messages.
    FINAL(today) = cl_abap_context_info=>get_system_date( ).
    omessage = new #( textid = zcm_04_messages=>trip_canceld severity = if_abap_behv_message=>severity-error ).
    READ ENTITIES OF z04_r_travel IN LOCAL MODE
        ENTITY Travel
            FIELDS ( EndDate BeginDate )
                WITH CORRESPONDING #( keys )
                    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<ls_result>).

        if <ls_result>-EndDate is INITIAL.
          APPEND VALUE #( %tky = <ls_result>-%tky ) to failed-travel.

          APPEND VALUE #( %tky = <ls_result>-%tky %element-EndDate = if_abap_behv=>mk-on
                          %msg = new zcm_04_messages( textid = zcm_04_messages=>enddate_initial severity = if_abap_behv_message=>severity-error  )  )
                          TO reported-travel.
        ELSEIF <ls_result>-EndDate < <ls_result>-BeginDate.
          APPEND VALUE #( %tky = <ls_result>-%tky ) to failed-travel.

          APPEND VALUE #( %tky = <ls_result>-%tky %element-EndDate = if_abap_behv=>mk-on
                          %msg = new zcm_04_messages( textid = zcm_04_messages=>enddate_low severity = if_abap_behv_message=>severity-error  )  )
                          TO reported-travel.
        endif.
*        clear check_id.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.

    mapped-travel = CORRESPONDING #( entities ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
        <ls_travel>-AgencyId = /lrn/cl_s4d437_model=>get_agency_by_user(  ).
        <ls_travel>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid(  ).
    ENDLOOP.

  ENDMETHOD.

  METHOD determineStatus.
    DATA oMessage TYPE REF TO zcm_04_messages.
    FINAL(today) = cl_abap_context_info=>get_system_date( ).
    omessage = new #( textid = zcm_04_messages=>trip_canceld severity = if_abap_behv_message=>severity-error ).
    READ ENTITIES OF z04_r_travel IN LOCAL MODE
        ENTITY Travel
            FIELDS ( Status )
                WITH CORRESPONDING #( keys )
                    RESULT DATA(result).
    LOOP AT result ASSIGNING FIELD-SYMBOL(<ls_result>).
        <ls_result>-Status = 'N'.
    ENDLOOP.

    MODIFY ENTITIES OF z04_r_travel IN LOCAL MODE ENTITY Travel
    UPDATE FIELDS ( Status )
    WITH CORRESPONDING #( result ).


  ENDMETHOD.

  METHOD get_instance_features.
    FINAL(today) = cl_abap_context_Info=>get_system_date( ).

    READ ENTITIES OF z04_r_Travel IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<line>).
      APPEND CORRESPONDING #(  <line> ) TO result
      ASSIGNING FIELD-SYMBOL(<action>).

      IF <line>-%is_draft = if_abap_behv=>mk-on. "Draft instance: Get active data

        READ ENTITIES OF z04_r_Travel IN LOCAL MODE
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
        <action>-%action-cancel_Travel = if_abap_behv=>fc-o-disabled.
      ELSE.
        <action>-%action-cancel_Travel = if_abap_behv=>fc-o-enabled.
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
    READ ENTITIES OF z04_r_travel IN LOCAL MODE
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

    MODIFY ENTITIES OF z04_r_travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( duration  )
    WITH CORRESPONDING #(  result ).
  ENDMETHOD.

  METHOD validateDateSequence.
    FINAL(today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF z04_r_travel IN LOCAL MODE
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
                        %msg = NEW zcm_04_messages(
                        textid = zcm_04_messages=>enddate_low
                        severity = if_abap_Behv_message=>severity-error
                        )
                          ) TO  reported-travel.
      ENDIF.



    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
