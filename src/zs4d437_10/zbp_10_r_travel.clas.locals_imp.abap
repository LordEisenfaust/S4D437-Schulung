CLASS lsc_z10_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z10_r_travel IMPLEMENTATION.

  METHOD save_modified.

  data(model) = new /lrn/cl_s4d437_tritem( i_table_name = 'Z10_TRITEM' ).

  LOOP AT delete-item ASSIGNING FIELD-SYMBOL(<item_d>).
    model->delete_item( i_uuid = <item_d>-ItemUuid ).
  endloop.

  LOOP AT create-item ASSIGNING FIELD-SYMBOL(<item_c>).
    model->create_item( i_item = CORRESPONDING #( <item_c> MAPPING FROM ENTITY ) ).
  endloop.

  LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item_u>).
    model->update_item( i_item = CORRESPONDING #( <item_u> MAPPING FROM ENTITY )
                        i_itemx = CORRESPONDING #( <item_u> MAPPING FROM ENTITY USING CONTROL ) ).
  endloop.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateFlightDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validateFlightDate.
    METHODS determineTravelDates FOR DETERMINE ON SAVE
      IMPORTING keys FOR Item~determineTravelDates.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD validateFlightDate.
    READ ENTITIES OF z10_r_travel IN LOCAL MODE
    ENTITY Item FIELDS ( AgencyId TravelId FlightDate ) WITH CORRESPONDING #( keys ) RESULT data(items).

    LOOP AT items ASSIGNING field-symbol(<item>).
        append value #( %tky = <item>-%tky  %state_area = 'FLIGHTDATE' ) to reported-item.

        if <item>-FlightDate is INITIAL.
            failed-item = value #( base failed-item ( %tky = <item>-%tky  ) ).
            reported-item = value #( base reported-item ( %tky = <item>-%tky
                                                          %state_area = 'FLIGHTDATE'
                                                          %element-flightdate = if_abap_behv=>mk-on
                                                          %path-travel = CORRESPONDING #( <item> )
                                                          %msg = new /LRN/CM_S4D437( textid = /LRN/CM_S4D437=>field_empty
                                                                                     severity = if_abap_behv_message=>severity-error ) ) ).
        elseif <item>-FlightDate < cl_abap_context_info=>get_system_date( ).
            failed-item = value #( base failed-item ( %tky = <item>-%tky  ) ).
            reported-item = value #( base reported-item ( %tky = <item>-%tky
                                                          %state_area = 'FLIGHTDATE'
                                                          %path-travel = CORRESPONDING #( <item> )
                                                          %element-flightdate = if_abap_behv=>mk-on
                                                          %msg = new /LRN/CM_S4D437( textid = /LRN/CM_S4D437=>flight_date_past
                                                                                     severity = if_abap_behv_message=>severity-error ) ) ).
        endif.
    endloop.
  ENDMETHOD.

  METHOD determineTravelDates.

    read ENTITIES OF z10_r_travel in local mode
    ENTITY Item FIELDS ( FlightDate ) WITH CORRESPONDING #( keys ) RESULT data(items)
    by \_Travel FIELDS ( BeginDate EndDate ) WITH CORRESPONDING #( keys ) RESULT data(travels) LINK data(link).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
        assign travels[ %tky = link[ source-%tky = <item>-%tky ]-target-%tky ] to FIELD-SYMBOL(<travel>).

        if <item>-FlightDate > <travel>-EndDate.
            <travel>-EndDate = <item>-FlightDate.
        endif.
        if <item>-FlightDate > cl_abap_context_info=>get_system_date( ) and <item>-FlightDate < <travel>-BeginDate .
            <travel>-BeginDate = <item>-FlightDate.
        endif.

    endloop.

    MODIFY ENTITIES OF z10_r_travel in local mode
    ENTITY Travel UPDATE FIELDS ( BeginDate EndDate ) WITH CORRESPONDING #(  travels ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
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
    METHODS determineStatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~determineStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = CORRESPONDING #( keys ).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      DATA(rc) = /lrn/cl_s4d437_model=>authority_check( i_actvt = '02'
                                                        i_agencyid = <line>-AgencyId ).
      IF rc <> 0.
        <line>-%update               = if_abap_behv=>auth-unauthorized.
        <line>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
      ENDIF."
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.

    READ ENTITIES OF z10_r_travel IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      IF <line>-Status = 'C'.
        failed-travel = VALUE #( BASE failed-travel ( %tky = <line>-%tky ) ).
        reported-travel = VALUE #( BASE reported-travel ( %tky = <line>-%tky
                                                          %msg = NEW zcm_10_travel( textid = zcm_10_travel=>already_canceled
                                                                                    severity = if_abap_behv_message=>severity-error
                                                                                    ) ) ).
      ELSEIF <line>-BeginDate < cl_abap_context_info=>get_system_date(  ).
        failed-travel = VALUE #( BASE failed-travel ( %tky = <line>-%tky ) ).
      ELSE.
        <line>-Status = 'C'.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z10_r_travel IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( status )
    WITH VALUE #( FOR travel IN result (  %tky   = travel-%tky
                                          Status = travel-Status ) ).
  ENDMETHOD.

  METHOD validateCustomer.
  data: exists type abap_bool.

  READ ENTITIES OF z10_r_travel IN LOCAL MODE
  ENTITY Travel
  FIELDS ( CustomerId )
  WITH CORRESPONDING #( keys )
  RESULT data(result).

  LOOP AT result ASSIGNING field-symbol(<line>).
        APPEND VALUE #( %tky = <line>-%tky
                      %state_area = `CUST` ) TO reported-travel.
    clear exists.
    SELECT SINGLE
          FROM /dmo/i_customer
        FIELDS @abap_true
         WHERE customerid = @<line>-customerid
          INTO @exists.

    if exists = ABAP_FALSE.
        append value #( %tky = <line>-%tky ) to failed-travel.
        append value #( %tky = <line>-%tky
                        %element-CustomerId = if_abap_behv=>mk-on
                        %state_area = `CUST`
                        %msg = new zcm_10_travel( textid = zcm_10_travel=>description_missing
                                                  severity = if_abap_behv_message=>severity-error  ) )
          to reported-travel.
    endif.
  endloop.

  ENDMETHOD.

  METHOD validateDescription.

    READ ENTITIES OF z10_r_travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( Description )
        WITH CORRESPONDING #( keys )
        RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      APPEND VALUE #( %tky = <line>-%tky
                      %state_area = `DESC` ) TO reported-travel.

        if <line>-Description is initial.
        APPEND VALUE #( %tky = <line>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <line>-%tky
                        %element-description = if_abap_behv=>mk-on
                        %state_area = `DESC`
                        %msg = NEW zcm_10_travel( textid = zcm_10_travel=>description_missing
                                                  severity = if_abap_behv_message=>severity-error  ) )
          TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_create.
    mapped-travel = CORRESPONDING #( entities ).
    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<line>).
      <line>-AgencyId = /lrn/cl_s4d437_model=>get_agency_by_user( ).
      <line>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.
  ENDMETHOD.

  METHOD determineStatus.
*    read ENTITIES OF z10_r_travel IN LOCAL MODE
*    ENTITY Travel fields ( Status ) WITH CORRESPONDING #( keys ) RESULT data(result).
*
*    LOOP AT result into
  ENDMETHOD.

  METHOD get_instance_features.

    FINAL(today) = cl_abap_context_info=>get_system_date(   ).

    READ ENTITIES OF z10_r_travel IN LOCAL MODE ENTITY Travel ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<line>).
      IF <line>-%is_draft = if_abap_behv=>mk-on.
        READ ENTITIES OF z10_r_travel IN LOCAL MODE ENTITY Travel FIELDS ( BeginDate EndDate ) WITH VALUE #( (  %key = <line>-%key  %is_draft = if_abap_behv=>mk-off ) ) RESULT DATA(active).
        IF active IS INITIAL.
          CLEAR: <line>-BeginDate, <line>-EndDate.
        ELSE.
          <line>-BeginDate = active[ 1 ]-BeginDate.
          <line>-EndDate   = active[ 1 ]-EndDate.
        ENDIF.
      ENDIF.

      APPEND CORRESPONDING #( <line> ) TO result ASSIGNING FIELD-SYMBOL(<resultline>).
      IF <line>-Status = 'C'.
        <resultline>-%features-%update = if_abap_behv=>fc-o-disabled.
      ELSE.
        <resultline>-%features-%update = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF <line>-BeginDate < today AND <line>-BeginDate IS NOT INITIAL.
        <resultline>-%features-%field-BeginDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <resultline>-%features-%field-BeginDate = if_abap_behv=>fc-f-unrestricted.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
