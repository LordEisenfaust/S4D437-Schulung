CLASS lsc_z09_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z09_r_travel IMPLEMENTATION.

  METHOD save_modified.

    LOOP AT delete-item ASSIGNING FIELD-SYMBOL(<item_d>).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateFligthDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validateFligthDate.
    METHODS determineTravelDates FOR DETERMINE ON SAVE
      IMPORTING keys FOR Item~determineTravelDates.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD validateFligthDate.

    READ ENTITIES OF Z09_R_Travel IN LOCAL MODE
         ENTITY Item
         FIELDS ( AgencyId TravelId FlightDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(items).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
      IF <item>-FlightDate IS INITIAL.
        APPEND VALUE #( %tky = <item>-%tky %state_area = 'FDATE' ) TO reported-item.
        APPEND VALUE #( %tky = <item>-%tky ) TO failed-item.
        APPEND VALUE #( %tky = <item>-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                        %element-FlightDate = if_abap_behv=>mk-on %state_area = 'FDATE'
                        %path-travel = CORRESPONDING #( <item> ) ) TO reported-item.
      ELSEIF <item>-FlightDate < cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %tky = <item>-%tky ) TO failed-item.
        APPEND VALUE #( %tky = <item>-%tky
                        %msg = NEW zcm_09_messages( textid = zcm_09_messages=>flight_date_past
                                                    severity = if_abap_behv_message=>severity-error )
                        %element-FlightDate = if_abap_behv=>mk-on %state_area = 'FDATE'
                        %path-travel = CORRESPONDING #( <item> ) ) TO reported-item.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD determineTravelDates.

    READ ENTITIES OF Z09_R_Travel IN LOCAL MODE
         ENTITY Item
         FIELDS ( AgencyId TravelId FlightDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(items)
         BY \_Travel
         FIELDS ( BeginDate EndDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels)
         LINK DATA(link).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).

      ASSIGN travels[ %tky = link[ source-%tky = <item>-%tky ]-target-%tky ] TO FIELD-SYMBOL(<travel>).

      IF <travel>-enddate < <item>-FlightDate.
        <travel>-enddate = <item>-FlightDate.
      ENDIF.
      IF <item>-FlightDate > cl_abap_context_info=>get_system_date( ) AND
         <item>-FlightDate < <travel>-BeginDate.
        <travel>-BeginDate = <item>-FlightDate.
      ENDIF.

    ENDLOOP.

    MODIFY ENTITIES OF Z09_R_Travel IN LOCAL MODE
           ENTITY Travel
           UPDATE FIELDS ( BeginDate EndDate )
           WITH CORRESPONDING #( travels ).

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
    METHODS validateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDescription.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.
    METHODS validateBeginDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBeginDate.
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

*      AUTHORITY-CHECK OBJECT '/LRN/AGCY'
*        ID '/LRN/AGCY' FIELD <result>-AgencyId
*        ID 'ACTVT' FIELD '02'.
      DATA(rc) = /lrn/cl_s4d437_model=>authority_check(
                   i_agencyid = <result>-AgencyId
                   i_actvt    = '02' ).
      IF rc = 0.
        <result>-%update              = if_abap_behv=>auth-allowed.
        <result>-%action-cancelTravel = if_abap_behv=>auth-allowed.
      ELSE.
        <result>-%update              = if_abap_behv=>auth-unauthorized.
        <result>-%action-cancelTravel = if_abap_behv=>auth-unauthorized.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancelTravel.

    DATA oMessage TYPE REF TO zcm_09_messages.

    READ ENTITIES OF z09_r_travel IN LOCAL MODE
         ENTITY Travel
         FIELDS (  BeginDate EndDate Status )
         WITH CORRESPONDING #( keys )
         RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
      IF <result>-Status = 'C'.

        APPEND VALUE #( %tky = <result>-%tky ) TO failed-travel.
        oMessage = NEW #( textid = zcm_09_messages=>trip_cancelled
                          severity = if_abap_behv_message=>severity-error ).
        APPEND VALUE #(  %tky = <result>-%tky %msg = oMessage ) TO reported-travel.


      ELSEIF <result>-BeginDate < cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %tky = <result>-%tky ) TO failed-travel.
        oMessage = NEW #( textid = zcm_09_messages=>trip_started
                          severity = if_abap_behv_message=>severity-error ).
        APPEND VALUE #(  %tky = <result>-%tky %msg = oMessage ) TO reported-travel.

      ELSE.
*        <result>-Status = 'C'.
        MODIFY ENTITIES OF z09_r_travel IN LOCAL MODE
               ENTITY Travel
               UPDATE FIELDS ( Status )
               WITH VALUE #( ( %tky = <result>-%tky Status = 'C' ) ).
      ENDIF.
    ENDLOOP.

*    MODIFY ENTITIES OF z09_r_travel IN LOCAL MODE
*     ENTITY Travel
*     UPDATE FIELDS ( status )
*    WITH CORRESPONDING #( result ).

  ENDMETHOD.

  METHOD validateDescription.

    READ ENTITIES OF z09_r_travel IN LOCAL MODE
         ENTITY Travel
         FIELDS (  Description )
         WITH CORRESPONDING #( keys )
         RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>)
      WHERE Description IS INITIAL.
      APPEND VALUE #( %tky = <result>-%tky %state_area = 'DESC'  ) TO reported-travel.

      APPEND VALUE #( %tky = <result>-%tky ) TO failed-travel.
      APPEND VALUE #( %tky                 = <result>-%tky
                      %msg                 = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                      %state_area          = 'DESC'
                      %element-description = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF z09_r_travel IN LOCAL MODE
         ENTITY Travel
         FIELDS ( CustomerId )
         WITH CORRESPONDING #( keys )
         RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).

      APPEND VALUE #( %tky = <result>-%tky %state_area = 'CUSTOMER'  ) TO reported-travel.

      IF <result>-CustomerId IS INITIAL.

        APPEND VALUE #( %tky = <result>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <result>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %element-customerid = if_abap_behv=>mk-on ) TO reported-travel.
      ELSE.

        DATA(exist) = abap_false.
        SELECT SINGLE
          FROM /DMO/I_Customer
        FIELDS @abap_true
         WHERE CustomerID = @<result>-CustomerId
          INTO @exist.

        IF exist = abap_false.
          APPEND VALUE #( %tky = <result>-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = <result>-%tky
                          %msg = NEW zcm_09_messages( textid   = zcm_09_messages=>no_customer
                                                      severity = if_abap_behv_message=>severity-error
                                                      customer = <result>-CustomerId )
                          %state_area = 'CUSTOMER'
                          %element-customerid = if_abap_behv=>mk-on ) TO reported-travel.

        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateBeginDate.

    FINAL(today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF z09_r_travel IN LOCAL MODE
       ENTITY Travel
       FIELDS ( BeginDate )
       WITH CORRESPONDING #( keys )
       RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
      APPEND VALUE #( %tky = <result>-%tky %state_area = 'BEGIN'  ) TO reported-travel.
      IF <result>-BeginDate < today.
        APPEND VALUE #( %tky = <result>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <result>-%tky
                                 %msg = NEW zcm_09_messages( textid   = zcm_09_messages=>start_past
                                                             severity = if_abap_behv_message=>severity-error )
                                 %state_area = 'BEGIN'
                                 %element-beginDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateEndDate.

    FINAL(today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF z09_r_travel IN LOCAL MODE
     ENTITY Travel
     FIELDS ( BeginDate EndDate  )
     WITH CORRESPONDING #( keys )
     RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
      APPEND VALUE #( %tky = <result>-%tky %state_area = 'END'  ) TO reported-travel.

      IF <result>-EndDate IS INITIAL.
        APPEND VALUE #( %tky = <result>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <result>-%tky
                        %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>field_empty )
                        %state_area = 'END'
                        %element-endDate = if_abap_behv=>mk-on ) TO reported-travel.
      ELSEIF <result>-EndDate < today.
        APPEND VALUE #( %tky = <result>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <result>-%tky
                                 %msg = NEW zcm_09_messages( textid   = zcm_09_messages=>end_past
                                                             severity = if_abap_behv_message=>severity-error )
                                 %state_area = 'END'
                                 %element-endDate = if_abap_behv=>mk-on ) TO reported-travel.
      ELSEIF <result>-EndDate < <result>-BeginDate.
        APPEND VALUE #( %tky = <result>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <result>-%tky
                                 %msg = NEW zcm_09_messages( textid   = zcm_09_messages=>wrong_sequence
                                                             severity = if_abap_behv_message=>severity-error )
                                 %state_area = 'END'
                                 %element-endDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.

    ENDLOOP..

  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(agency) = /lrn/cl_s4d437_model=>get_agency_by_user(  ).
    mapped-travel = CORRESPONDING #( entities ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<key>).
      <key>-AgencyId = agency.
      <key>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid(  ).
    ENDLOOP.

  ENDMETHOD.

  METHOD determineStatus.

    READ ENTITIES OF z09_r_travel IN LOCAL MODE
         ENTITY Travel
         FIELDS ( status )
         WITH CORRESPONDING #( keys )
         RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>) WHERE Status IS INITIAL.
      MODIFY ENTITIES OF z09_r_travel IN LOCAL MODE
             ENTITY Travel
             UPDATE FIELDS ( Status )
             WITH VALUE #( ( %tky = <result>-%tky Status = 'N' ) ).
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.
    FINAL(today) = cl_abap_context_info=>get_system_date( ).
    READ ENTITIES OF z09_r_travel IN LOCAL MODE
        ENTITY Travel
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-%is_draft = if_abap_behv=>mk-on.
        READ ENTITIES OF z09_r_travel IN LOCAL MODE
             ENTITY Travel
             ALL FIELDS
             WITH VALUE #( (  %key = <travel>-%key %is_draft = if_abap_behv=>mk-off ) )
             RESULT DATA(active).

        IF lines( active ) = 0.
          CLEAR <travel>-BeginDate.
          CLEAR <travel>-EndDate.
        ELSE..
          <travel>-BeginDate = active[ 1 ]-BeginDate.
          <travel>-EndDate   = active[ 1 ]-EndDate.
        ENDIF.

      ENDIF.

      APPEND CORRESPONDING #( <travel> ) TO result ASSIGNING FIELD-SYMBOL(<action>).

      IF <travel>-Status = 'C'.
        <action>-%update = if_abap_behv=>fc-o-disabled.
      ELSE.
        <action>-%update = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF <travel>-BeginDate < today AND
         <travel>-BeginDate IS NOT INITIAL.
        <action>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <action>-%field-BeginDate = if_abap_behv=>fc-f-unrestricted.
      ENDIF.

      IF <travel>-BeginDate < today.
        <action>-%action-cancelTravel = if_abap_behv=>fc-o-disabled.
      ELSE.
        <action>-%action-cancelTravel = if_abap_behv=>fc-o-enabled.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD determineDuration.

    READ ENTITIES OF z09_r_travel IN LOCAL MODE
         ENTITY Travel
         FIELDS ( BeginDate EndDate  )
         WITH CORRESPONDING #( keys )
         RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
      <result>-Duration = <result>-EndDate - <result>-BeginDate + 1.
      IF <result>-Duration < 1.
        <result>-Duration = 0.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z09_r_travel IN LOCAL MODE
           ENTITY Travel
           UPDATE FIELDS ( Duration )
           WITH CORRESPONDING #( result ).

  ENDMETHOD.

ENDCLASS.
