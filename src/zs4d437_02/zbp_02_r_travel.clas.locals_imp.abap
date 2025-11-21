CLASS lsc_z02_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z02_r_travel IMPLEMENTATION.

  METHOD save_modified.

    "Eventhandling
    DATA event_parameter TYPE TABLE FOR EVENT z02_r_travel~travelCreated.
    IF create-travel IS NOT INITIAL.
      "Origin wird durch den zusätzlichen Typ von der abstract Data Definition Z02_A_EVENT
      event_parameter = VALUE #( FOR line IN create-travel ( %key = line-%key origin = 'Z02_R_TRAVEL'  ) ).
      RAISE ENTITY EVENT z02_r_travel~travelCreated
      FROM event_parameter.
    ENDIF.

    "SAVE Methoden
    DATA(model) = NEW /lrn/cl_s4d437_tritem( i_table_name = 'Z02_TRITEM' ).

    LOOP AT delete-item ASSIGNING FIELD-SYMBOL(<item_d>).
      model->delete_item( <item_d>-ItemUuid ).
    ENDLOOP.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<item_c>).
      model->create_item( EXPORTING  i_item = CORRESPONDING #( <item_c> MAPPING FROM ENTITY ) ).
    ENDLOOP.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<item_u>).
      model->update_item( EXPORTING  i_item  = CORRESPONDING #( <item_u> MAPPING FROM ENTITY )
                                     i_itemx = CORRESPONDING #( <item_u> MAPPING FROM ENTITY USING CONTROL ) ).
    ENDLOOP.

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

    DATA oMessage TYPE REF TO zcm_02_messges. "Definition Message Objekt

    READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Item
    FIELDS ( FlightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(items)
    BY \_Travel
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels)

    LINK DATA(link). "Link schützt uns vor Anderungen am Schlüssel

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).

      APPEND VALUE #( %tky = <item>-%tky %state_area = 'FLIGHTDATE' ) TO reported-item.
      READ TABLE link INTO DATA(s_data) WITH KEY source-ItemUuid = <item>-ItemUuid ##PRIMKEY[ENTITY].

      READ TABLE travels ASSIGNING FIELD-SYMBOL(<travel>) WITH KEY AgencyId = s_data-target-AgencyId
                                                                   TravelId = s_data-target-TravelId ##PRIMKEY[ENTITY].


      IF <item>-FlightDate < <travel>-BeginDate AND <item>-FlightDate IS NOT INITIAL.
        omessage = NEW #( textid   = zcm_02_messges=>flight_outside_trip
                             severity = if_abap_behv_message=>severity-error ).
        APPEND VALUE #( %state_area = 'FLIGHTDATE'
                        %path-travel = CORRESPONDING #( <travel>-%tky )
                        %tky = <item>-%tky
                        %msg = oMessage
                        %element-FlightDate = if_abap_behv=>mk-on ) TO reported-item.
      ENDIF.

      IF <item>-FlightDate > <travel>-EndDate AND <item>-FlightDate IS NOT INITIAL.
        omessage = NEW #( textid   = zcm_02_messges=>flight_outside_trip
                             severity = if_abap_behv_message=>severity-error ).
        APPEND VALUE #( %state_area = 'FLIGHTDATE'
                        %path-travel = CORRESPONDING #( <travel>-%tky )
                        %tky = <item>-%tky
                        %msg = oMessage
                        %element-FlightDate = if_abap_behv=>mk-on ) TO reported-item.
      ENDIF.

    ENDLOOP.



  ENDMETHOD.

  METHOD determineTravelDates.

    DATA oMessage TYPE REF TO zcm_02_messges. "Definition Message Objekt

    READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Item
    FIELDS ( FlightDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(items)
    BY \_Travel
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels)

    LINK DATA(link). "Link schützt uns vor Anderungen am Schlüssel

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
      READ TABLE link INTO DATA(s_data) WITH KEY source-ItemUuid = <item>-ItemUuid ##PRIMKEY[ENTITY].

      READ TABLE travels ASSIGNING FIELD-SYMBOL(<travel>) WITH KEY AgencyId = s_data-target-AgencyId
                                                                   TravelId = s_data-target-TravelId ##PRIMKEY[ENTITY].

      IF <item>-FlightDate < <travel>-BeginDate AND <item>-FlightDate IS NOT INITIAL.
        <travel>-begindate = <item>-flightdate.
      ENDIF.

      IF <item>-FlightDate > <travel>-EndDate AND <item>-FlightDate IS NOT INITIAL.
        <travel>-enddate = <item>-flightdate.
      ENDIF.

    ENDLOOP.

    MODIFY ENTITIES OF z02_r_travel IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( begindate enddate )
    WITH CORRESPONDING #( travels ).
*
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Z02_R_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION travel~cancel_travel.
    METHODS validatedescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedescription.
    METHODS validatecustomerid FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomerid.
    METHODS validatebegindate FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatebegindate.
    METHODS validateenddate FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateenddate.
    METHODS validateBeginEnd FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateBeginEnd.
    METHODS setStatusNew FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setStatusNew.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS determineduration FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~determineduration.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Z02_R_TRAVEL IMPLEMENTATION.

  METHOD get_instance_authorizations.

    result = CORRESPONDING #( keys ).
    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).

      "Simulation
      DATA(rc) = /lrn/cl_s4d437_model=>authority_check( i_agencyid = <line>-AgencyId
                                                        i_actvt    = '02' ).
      "Normale Prüfung
*      AUTHORITY-CHECK OBJECT '/LRN/AGCY'
*      ID '/LRN/AGCY' FIELD <line>-AgencyId
*      ID 'ACTVT' FIELD '02'. "CHANGE

*      IF sy-subrc = 0.
      IF rc = 0.
        <line>-%update = if_abap_behv=>auth-allowed.
        <line>-%action-cancel_travel = if_abap_behv=>auth-allowed.
      ELSE.
        <line>-%update = if_abap_behv=>auth-unauthorized.
        <line>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.

    DATA oMessage TYPE REF TO zcm_02_messges. "Definition Message Objekt

    READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel

    "Auslesen aller Felder
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    "Prüfung auf Status und Begin Date
    LOOP AT travels INTO DATA(travel).
      IF travel-status = 'C'.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        omessage = NEW #( textid   = zcm_02_messges=>trip_cancelled
                          severity = if_abap_behv_message=>severity-error ). "muss mit Constante angegeben , wegen "ENUM"
        APPEND VALUE #( %tky = travel-%tky
                        %msg = oMessage ) TO reported-travel.

      ELSEIF travel-BeginDate < cl_abap_context_info=>get_system_date(  ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        omessage = NEW #( textid   = zcm_02_messges=>trip_started
                          severity = if_abap_behv_message=>severity-error ). "muss mit Constante angegeben , wegen "ENUM"
        APPEND VALUE #( %tky = travel-%tky
                        %msg = oMessage ) TO reported-travel.

      ELSE.
        MODIFY ENTITIES OF Z02_R_travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( status )
        WITH VALUE #(  ( %tky = travel-%tky status = 'C' ) ).

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDescription.
    DATA oMessage TYPE REF TO zcm_02_messges. "Definition Message Objekt

    READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel
    "nur das Feld Description auslesen, anhand den Keys
    FIELDS ( Description ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      APPEND VALUE #( %state_area = 'DESCRIPTION' %tky = travel-%tky ) TO reported-travel.
      IF travel-Description IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        omessage = NEW #( textid   = zcm_02_messges=>empty_field
                             severity = if_abap_behv_message=>severity-error ).
        APPEND VALUE #( %state_area = 'DESCRIPTION'
                        %tky = travel-%tky
                        %msg = oMessage
                        %element-Description = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomerId.
    DATA oMessage TYPE REF TO zcm_02_messges. "Definition Message Objekt

    READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel
    "nur das Feld Description auslesen, anhand den Keys
    FIELDS ( CustomerId ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      DATA: i_check TYPE abap_bool.
      APPEND VALUE #( %state_area = 'CUSTOMER' %tky = travel-%tky ) TO reported-travel.
      i_check = abap_false.

      SELECT SINGLE FROM /dmo/i_customer
      FIELDS CustomerID
      WHERE CustomerID = @travel-CustomerId
      INTO @i_check.

      IF i_check = abap_false.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        omessage = NEW #( textid   = zcm_02_messges=>wrong_CustomerId
                          severity = if_abap_behv_message=>severity-error
                          i_customer_id = travel-CustomerId ).
        APPEND VALUE #( %state_area = 'CUSTOMER'
                        %tky = travel-%tky
                        %msg = oMessage
                        %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateBeginDate.

    "mit final, kann die Variable nicht mehr geändert werden.
    FINAL(today_date) = cl_abap_context_info=>get_system_date( ).

    DATA oMessage TYPE REF TO zcm_02_messges. "Definition Message Objekt

    READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel
    "nur das Feld Description auslesen, anhand den Keys
    FIELDS ( BeginDate ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      APPEND VALUE #( %state_area = 'BEGINDATE' %tky = travel-%tky ) TO reported-travel.
      IF travel-BeginDate < today_date.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        omessage = NEW #( textid   = zcm_02_messges=>start_past_start
                             severity = if_abap_behv_message=>severity-error ).
        APPEND VALUE #( %state_area = 'BEGINDATE'
                        %tky = travel-%tky
                        %msg = oMessage
                        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
  METHOD validateEndDate.

    "mit final, kann die Variable nicht mehr geändert werden.
    FINAL(today_date) = cl_abap_context_info=>get_system_date( ).

    DATA oMessage TYPE REF TO zcm_02_messges. "Definition Message Objekt

    READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel
    "nur das Feld Description auslesen, anhand den Keys
    FIELDS ( EndDate ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      APPEND VALUE #( %state_area = 'ENDDATE' %tky = travel-%tky ) TO reported-travel.
      IF travel-EndDate < today_date.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        omessage = NEW #( textid   = zcm_02_messges=>start_past_end
                             severity = if_abap_behv_message=>severity-error ).
        APPEND VALUE #( %state_area = 'ENDDATE'
                        %tky = travel-%tky
                        %msg = oMessage
                        %element-EndDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
  METHOD validateBeginEnd.

    "mit final, kann die Variable nicht mehr geändert werden.
    FINAL(today_date) = cl_abap_context_info=>get_system_date( ).

    DATA oMessage TYPE REF TO zcm_02_messges. "Definition Message Objekt

    READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel
    "nur das Feld Description auslesen, anhand den Keys
    FIELDS ( BeginDate EndDate ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      APPEND VALUE #( %state_area = 'BEGINENDDATE' %tky = travel-%tky ) TO reported-travel.
      IF travel-EndDate <= travel-BeginDate.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        omessage = NEW #( textid   = zcm_02_messges=>start_end
                             severity = if_abap_behv_message=>severity-error ).
        APPEND VALUE #( %state_area = 'BEGINENDDATE'
                        %tky = travel-%tky
                        %msg = oMessage
                        %element-BeginDate = if_abap_behv=>mk-on
                        %element-EndDate   = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
  METHOD earlynumbering_create.

    "Methode für die Agency zu bekokmmen als Beispiel
    DATA(agency) = /lrn/cl_s4d437_model=>get_agency_by_user( ).

    mapped-travel = CORRESPONDING #( entities ). "Ermitteln der eingegebenen Daten

    "Key Vergabe
    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<key>).
      <key>-AgencyId = agency.
      <key>-TravelId =  /lrn/cl_s4d437_model=>get_next_travelid( ). "Nummernvergabe next
    ENDLOOP.

  ENDMETHOD.

  METHOD setStatusNew.

    DATA oMessage TYPE REF TO zcm_02_messges. "Definition Message Objekt

    READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel
    FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      <travel>-Status = 'N'.
    ENDLOOP.

    MODIFY ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel
    UPDATE FIELDS ( status )
    WITH CORRESPONDING #( travels )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

    omessage = NEW #( textid   = zcm_02_messges=>start_past_end
                                 severity = if_abap_behv_message=>severity-information ).
*    APPEND VALUE #( %tky = travels[ 1 ]-%tky
*                    %msg = oMessage ) TO reported-travel.

  ENDMETHOD.

  METHOD get_instance_features.

    "mit final, kann die Variable nicht mehr geändert werden.
    FINAL(today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<line>).
      APPEND CORRESPONDING #(  <line> ) TO result
      ASSIGNING FIELD-SYMBOL(<action>).

      IF <line>-%is_draft = if_abap_behv=>mk-on.
        READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel
        "hier muss mit %key gearbeitet werden, da keys nicht die aktive version ermitteln würde
        ALL FIELDS WITH VALUE #( ( %key      = <line>-%key
                                   %is_draft = if_abap_behv=>mk-off ) )
       RESULT DATA(active).
      ENDIF.

      "bei Draft Version die alten aktiven Werte übergeben
      IF lines( active ) = 0.
        <line>-BeginDate = '00000000'.
        <line>-EndDate = '00000000'.
      ELSE.
        <line>-BeginDate = active[ 1 ]-BeginDate.
        <line>-EndDate = active[ 1 ]-EndDate.
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

    "Exklusiv für Draftberechung
    READ ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel
    FIELDS ( BeginDate EndDate ) WITH CORRESPONDING #( keys )
    RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).

      <line>-Duration = <line>-EndDate - <line>-BeginDate + 1.
      IF <line>-Duration < 1.
        <line>-Duration = 0.
      ENDIF.

    ENDLOOP.

    MODIFY ENTITIES OF z02_r_travel IN LOCAL MODE ENTITY Travel
        UPDATE FIELDS ( duration ) WITH CORRESPONDING #( result ).


  ENDMETHOD.

ENDCLASS.
