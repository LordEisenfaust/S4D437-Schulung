CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateflightdate FOR VALIDATE ON SAVE
      IMPORTING keys FOR item~validateflightdate.
    METHODS determinetravledates FOR DETERMINE ON SAVE
      IMPORTING keys FOR item~determinetravledates.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.


  METHOD validateflightdate.
  CONSTANTS c_area type string value 'FLIGHTDATE'.

    read ENTITIES OF z06_r_travel in LOCAL MODE
    ENTITY Item
    fields (  FlightDate )
    with CORRESPONDING #( keys )
    result data(items).

    loop at items ASSIGNING field-SYMBOL(<item>).
      append value #( %tky = <item>-%tky
                      %state_area = c_area ) to reported-item.

      if <item>-FlightDate is INITIAL.
        "Aufnahme des Satzes in die Fehlertabelle
        append value #( %tky = <item>-%tky ) to failed-item.
        "jetzt die Nachtichten erstellen
        append value #( %tky = <item>-%tky
                        %msg = new /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                        %element-FlightDate = if_abap_behv=>mk-on
                        %state_area = c_area
                        %path-travel = CORRESPONDING #( <item> ) )
                        to reported-item.
      elseif <item>-FlightDate < cl_abap_context_info=>get_system_date(  ).
        append value #( %tky = <item>-%tky ) to failed-item.
                "jetzt die Nachtichten erstellen
        append value #( %tky = <item>-%tky
                        %msg = new /lrn/cm_s4d437( /lrn/cm_s4d437=>flight_date_past )
                        %element-FlightDate = if_abap_behv=>mk-on
                        %state_area = c_area
                        %path-travel = CORRESPONDING #( <item> ) )
                        to reported-item.
      endif.
    endloop.
  ENDMETHOD.

  METHOD determineTravleDates.
    read ENTITIES OF z06_r_travel in LOCAL MODE
    entity Item
    fields ( Flightdate )
    with CORRESPONDING #( keys )
    result data(items)
    by \_Travel
    fields (  BeginDate EndDate )
    with CORRESPONDING #( keys )
    result data(travels)
    link data(link).    "Verknüpfungen zwischen Item und Kopf

    loop at items ASSIGNING field-SYMBOL(<item>).
     read table travels ASSIGNING field-symbol(<travel>)
       with key %tky = link[ source-%tky = <item>-%tky ]-target-%tky.
     if <travel>-EndDate < <item>-FlightDate.
       <travel>-EndDate = <item>-FlightDate.
     endif.
     if <item>-FlightDate > cl_Abap_context_info=>get_system_date(  )
       and <item>-FlightDate < <travel>-BeginDate.
       <travel>-BeginDate = <item>-FlightDate.
    endif.
    endloop.

    modify ENTITIES OF z06_r_travel in local mode
    ENTITY Travel
    update
    fields ( BeginDate EndDate )
    with CORRESPONDING #( travels ).



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
    METHODS validateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDescription.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.
    METHODS validateBeginDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBeginDate.
    METHODS validateDataSequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDataSequence.

    METHODS validateEndDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateEndDate.
    METHODS determineStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~determineStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS determineduration FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~determineduration.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.
ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = CORRESPONDING #( keys ).
    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
      "das hier ist ein simulierte Auth- Check, da unser SAP User es normalerweise kann,
      "in diesem Trainigsystem können wir aber für  User keine Rechte ändern
      "Normalerweise würde das mit auhority-check erfolgen
      DATA(rc) = /lrn/cl_s4d437_model=>authority_check(
                                        i_agencyid = <result>-agencyid
                                        i_actvt    = '02' ).
      IF rc NE 0.
        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
        <result>-%update               = if_abap_behv=>auth-unauthorized.
      ELSE.
        <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
        <result>-%update               = if_abap_behv=>auth-allowed.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.
    READ ENTITIES OF z06_r_travel IN LOCAL MODE
    ENTITY Travel ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-Status NE  'C'.
        MODIFY ENTITIES OF z06_r_travel IN LOCAL MODE
         ENTITY travel
         UPDATE FIELDS ( status )
         WITH VALUE #( ( %tky = travel-%tky
                         status = 'C' ) ).
      ELSE.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = travel-%tky
                        %msg = NEW /LRN/CM_s4d437( textid = /lrn/cm_s4d437=>already_canceled ) )
                        TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDescription.
    CONSTANTS: c_area TYPE string VALUE 'DESC'.

    READ ENTITIES OF z06_r_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS (  Description )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND VALUE #( %tky = <travel>-%tky
                      %state_area = c_area ) TO reported-travel.

      IF <travel>-Description IS INITIAL.
        "Fehlerhaften Satz in die Fehlertabelle aufnehmen
        APPEND VALUE #(  %tky = <travel>-%tky )  TO failed-travel.
        "jetzt müssen wir die Fehler noch für den Anwender bekannt machen
        APPEND VALUE #( %tky = <travel>-%tky                 "Key des fehlerhaften Satzes
                        %state_area = c_area
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )  "Message für den Satz
                        %element-Description = if_abap_behv=>mk-on )              "Feld Description als rot kennzeichnen
                        TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.

    CONSTANTS: c_area TYPE string VALUE 'CUST'.

    READ ENTITIES OF z06_r_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS (  CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky
                  %state_area = c_area ) TO reported-travel.

      IF <travel>-CustomerId IS INITIAL.
        APPEND VALUE #(  %tky = <travel>-%tky )  TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky                 "Key des fehlerhaften Satzes
         %state_area = c_area
                       %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )  "Message für den Satz
                       %element-CustomerId = if_abap_behv=>mk-on )              "Feld Description als rot kennzeichnen
                       TO reported-travel.
      ELSE.
        SELECT SINGLE FROM /dmo/i_customer
          FIELDS CustomerID
          WHERE CustomerID = @<travel>-CustomerId
          INTO @DATA(dummy).
        IF sy-subrc NE 0.
          APPEND VALUE #(  %tky = <travel>-%tky )  TO failed-travel.
          APPEND VALUE #( %tky = <travel>-%tky                 "Key des fehlerhaften Satzes
           %state_area = c_area
                          %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>customer_not_exist )  "Message für den Satz
                          %element-CustomerId = if_abap_behv=>mk-on )              "Feld Description als rot kennzeichnen
                          TO reported-travel.
        ENDIF.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateBeginDate.
    CONSTANTS: c_area TYPE string VALUE 'DATE1'.

    READ ENTITIES OF z06_r_travel IN LOCAL MODE
      ENTITY Travel
      FIELDS (  BeginDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky
                  %state_area = c_area ) TO reported-travel.

      IF <travel>-BeginDate IS INITIAL.
        APPEND VALUE #(  %tky = <travel>-%tky )  TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky                 "Key des fehlerhaften Satzes
         %state_area = c_area
                       %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )  "Message für den Satz
                       %element-BeginDate = if_abap_behv=>mk-on )              "Feld Description als rot kennzeichnen
                       TO reported-travel.
      ELSEIF <travel>-BeginDate < cl_abap_context_info=>get_system_date(  ).
        APPEND VALUE #(  %tky = <travel>-%tky )  TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky                 "Key des fehlerhaften Satzes
         %state_area = c_area
                       %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>begin_date_past )  "Message für den Satz
                       %element-BeginDate = if_abap_behv=>mk-on )              "Feld Description als rot kennzeichnen
                       TO reported-travel.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD validateDataSequence.
    CONSTANTS: c_area TYPE string VALUE 'SEQU'.
    READ ENTITIES OF z06_r_travel IN LOCAL MODE
     ENTITY Travel
     FIELDS (  BeginDate EndDate )
     WITH CORRESPONDING #( keys )
     RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky
                  %state_area = c_area ) TO reported-travel.
      IF <travel>-EndDate < <travel>-BeginDate.
        APPEND VALUE #(  %tky = <travel>-%tky )  TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky                 "Key des fehlerhaften Satzes
         %state_area = c_area
                %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>dates_wrong_sequence )  "Message für den Satz
                %element-BeginDate = if_abap_behv=>mk-on
                %element-EndDate = if_abap_behv=>mk-on )              "Feld Description als rot kennzeichnen
                TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateEndDate.
    CONSTANTS: c_area TYPE string VALUE 'END'.
    READ ENTITIES OF z06_r_travel IN LOCAL MODE
     ENTITY Travel
     FIELDS (  EndDate )
     WITH CORRESPONDING #( keys )
     RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky
              %state_area = c_area ) TO reported-travel.   "Damit sich die gleichen Nachrichten nicht vermehren, muss ich die "alten" löschen
      IF <travel>-EndDate IS INITIAL.
        APPEND VALUE #(  %tky = <travel>-%tky )  TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky                 "Key des fehlerhaften Satzes
         %state_area = c_area
                       %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )  "Message für den Satz
                       %element-EndDate = if_abap_behv=>mk-on )              "Feld Description als rot kennzeichnen
                       TO reported-travel.
      ELSEIF <travel>-EndDate < cl_abap_context_info=>get_system_date(  ).
        APPEND VALUE #(  %tky = <travel>-%tky )  TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky                 "Key des fehlerhaften Satzes
         %state_area = c_area   "state Nachrichten bleiben auch wenn ich den Satz verlasse
                       %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>end_date_past )  "Message für den Satz
                       %element-EndDate = if_abap_behv=>mk-on )              "Feld Description als rot kennzeichnen
                       TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user(  ).
    mapped-travel = CORRESPONDING #( entities ).
    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).
      <mapping>-AgencyId = agencyid.
      <mapping>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.
  ENDMETHOD.

  METHOD determineStatus.
    READ ENTITIES OF z06_r_travel IN LOCAL MODE
     ENTITY Travel
     FIELDS ( Status )
     WITH CORRESPONDING #( keys )
     RESULT DATA(travels).

    "jetzt lösche ich aus der int. Tabelle alle Sätze, bei denen der Status schon gefüllt ist.
    DELETE travels WHERE Status IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    "jetzt alle verbleibenden Sätze in der Tabelle travel ändern
    MODIFY ENTITIES OF z06_r_travel IN LOCAL MODE
      ENTITY Travel
      UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN travels (  %tky = key-%tky
                                         Status = 'N' )  )
      REPORTED DATA(update_reported).
    reported = CORRESPONDING #(  DEEP update_reported ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF z06_r_travel IN LOCAL MODE
    ENTITY Travel
    ALL  FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).
    FINAL(today) = cl_abap_context_info=>get_system_date(  ).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND CORRESPONDING #( <travel> ) TO result
      ASSIGNING FIELD-SYMBOL(<result>).

      if <travel>-%is_draft = if_abap_behv=>mk-on.
        read ENTITIES OF z06_r_travel in LOCAL MODE
         ENTITY Travel
         fields ( BeginDate EndDate )
         with value #( (  %key = <travel>-%key %is_draft = if_abap_Behv=>mk-off ) )
         result data(travels_active).

         if travels_active is NOT INITIAL.
           <travel>-BeginDate = travels_active[ 1 ]-BeginDate.
           <travel>-EndDate   = travels_active[ 1 ]-EndDate.
         else.
           clear: <travel>-BeginDate.
           clear:  <travel>-EndDate.
         endif.
      endif.



      IF <travel>-Status = 'C' OR
      (  <travel>-EndDate IS NOT INITIAL AND <travel>-EndDate < today ).
        <result>-%update = if_abap_behv=>fc-o-disabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-disabled.
      ELSE.
        <result>-%update = if_abap_behv=>fc-o-enabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF <travel>-BeginDate IS NOT INITIAL AND <travel>-BeginDate < today.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
        <result>-%field-CustomerId = if_abap_behv=>fc-f-read_only.
      ELSE.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-mandatory.
        <result>-%field-CustomerId = if_abap_behv=>fc-f-mandatory.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD determineDuration.

    read ENTITIES OF z06_r_travel in local mode
    ENTITY Travel
    fields ( BeginDate EndDate )
    with corresponding #( keys )
    result data(travels).

    loop at travels ASSIGNING field-SYMBOL(<travel>).
      <travel>-Duration = <travel>-EndDate - <travel>-BeginDate + 1.
    endloop.

    modify ENTITIES OF z06_r_Travel in LOCAL MODE
    ENTITY Travel
    update
    fields (  Duration )
    with CORRESPONDING #( travels ).
  ENDMETHOD.

ENDCLASS.
