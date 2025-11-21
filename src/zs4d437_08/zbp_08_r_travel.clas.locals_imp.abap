
CLASS lsc_z08_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z08_r_travel IMPLEMENTATION.

  METHOD save_modified.
    DATA(model) = NEW /lrn/cl_s4d437_tritem( i_table_name = 'Z08_TRITEM' ).

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

    METHODS validFlightDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validFlightDate.
    METHODS determineTravelDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Item~determineTravelDate.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD validFlightDate.
    READ ENTITIES OF z08_r_travel IN LOCAL MODE
    ENTITY item
    FIELDS ( AgencyId TravelId FlightDate )
    WITH CORRESPONDING #(  keys )
    RESULT DATA(items).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<s_items>).
      reported-item = VALUE #( ( %tky = <s_items>-%tky
                                 %state_area = 'FLDATE' ) ).
      IF <s_items>-FlightDate IS INITIAL.
        failed-item = VALUE #( (   %tky = <s_items>-%tky ) ).
        reported-item = VALUE #( ( %tky = <s_items>-%tky
                                 %state_area = 'FLDATE'
                                 %msg = NEW /lrn/cm_s4d437(
                                  /lrn/cm_s4d437=>field_empty  )
                                  %element-flightdate = if_abap_behv=>mk-on
                                  %path-travel = CORRESPONDING #( <s_items> )                                 ) ).
      ELSEIF <s_items>-FlightDate < cl_abap_context_info=>get_system_date( ).
        failed-item = VALUE #( (   %tky = <s_items>-%tky ) ).
        reported-item = VALUE #( ( %tky = <s_items>-%tky
                                 %state_area = 'FLDATE'
                                 %msg = NEW /lrn/cm_s4d437(
                                  /lrn/cm_s4d437=>flight_date_past  )
                                  %element-flightdate = if_abap_behv=>mk-on
                                  %path-travel = CORRESPONDING #( <s_items> )
                                  ) ).

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD determineTravelDate.
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
    METHODS validateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDescription.
    METHODS setStatusNew FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setStatusNew.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS validatedataseq FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedataseq.
    METHODS determineduration FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~determineduration.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = CORRESPONDING #( keys ).
    LOOP AT result ASSIGNING FIELD-SYMBOL(<ls_result>).
      DATA(rc) = /lrn/cl_s4d437_model=>authority_check(
                   i_agencyid = <ls_result>-agencyid
                   i_actvt    = '02'
                 ).
      IF rc <> 0.
        <ls_result>-%action-cancelTravel = if_abap_behv=>auth-unauthorized.
        <ls_result>-%update = if_abap_behv=>auth-unauthorized.
      ELSE.
        <ls_result>-%action-cancelTravel = if_abap_behv=>auth-allowed.
        <ls_result>-%update = if_abap_behv=>auth-allowed.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.


  ENDMETHOD.

  METHOD cancelTravel.
* Read
    READ ENTITIES OF z08_r_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS (  BeginDate EndDate Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

* Modify
    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>).
** Check
      IF <ls_result>-Status = 'C'.
        failed-travel = VALUE #( BASE failed-travel
                                    ( AgencyId = <ls_result>-AgencyId
                                       TravelId = <ls_result>-TravelId )  ).
        reported-travel = VALUE #(  BASE reported-travel
                                    ( %tky = <ls_result>-%tky
                                     %msg = NEW zcm_08_message( textid = zcm_08_message=>is_canceled
                                                severety = if_abap_behv_message=>severity-error ) ) ) .

      ELSEIF <ls_result>-BeginDate < cl_abap_context_info=>get_system_date( ).
        failed-travel = VALUE #( BASE failed-travel
                                    ( AgencyId = <ls_result>-AgencyId
                                       TravelId = <ls_result>-TravelId )  ).
        reported-travel = VALUE #(  BASE reported-travel
                                    ( %tky = <ls_result>-%tky
                                     %msg = NEW zcm_08_message( textid = zcm_08_message=>is_running
                                              severety = if_abap_behv_message=>severity-error ) ) ) .
      ELSE.
        <ls_result>-Status = 'C'.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z08_r_travel IN LOCAL MODE
    ENTITY Travel
    UPDATE
    FIELDS ( Status )
    WITH CORRESPONDING #( lt_result ).

  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITIES OF z08_r_travel IN LOCAL MODE
ENTITY Travel
FIELDS (  CustomerId )
WITH CORRESPONDING #( keys )
RESULT DATA(lt_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>).

      reported-travel = VALUE #(  BASE reported-travel (   %tky = <ls_result>-%tky %state_area = 'CUST' ) ).
      SELECT SINGLE FROM /DMO/I_Customer
      FIELDS @abap_true
      WHERE CustomerID = @<ls_result>-CustomerId
      INTO @DATA(lv_found).

      IF lv_found = abap_false.
        failed-travel = VALUE #(  BASE failed-travel ( %tky = <ls_result>-%tky ) ).
        reported-travel = VALUE #(  BASE reported-travel (   %tky = <ls_result>-%tky
                                                                          %state_area = 'CUST'
                                      %msg = NEW zcm_08_message( textid = zcm_08_message=>no_customer
                                               severety = if_abap_behv_message=>severity-error
                                               i_customer = <ls_result>-CustomerId ) ) ).
      ENDIF.
      CLEAR lv_found.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateBeginDate.

    READ ENTITIES OF z08_r_travel IN LOCAL MODE
  ENTITY Travel
  FIELDS (  BeginDate )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>)
        WHERE BeginDate < cl_abap_context_info=>get_system_date( ).

      failed-travel = VALUE #( BASE failed-travel  ( %tky = <ls_result>-%tky ) ).
      reported-travel = VALUE #(  BASE reported-travel (   %tky = <ls_result>-%tky
                                    %msg = NEW zcm_08_message( textid = zcm_08_message=>false_date
                                             severety = if_abap_behv_message=>severity-error ) ) ).

    ENDLOOP.
  ENDMETHOD.

  METHOD validateDescription.
    CONSTANTS c_area TYPE string VALUE 'DESC'.

    READ ENTITIES OF z08_r_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS (  Description )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>).
      reported-travel = VALUE #(  (  %tky = <ls_result>-%tky %state_area = c_area ) ).
      IF <ls_result>-Description IS INITIAL.

        failed-travel = VALUE #(   BASE failed-travel ( %tky = <ls_result>-%tky ) ).
        reported-travel = VALUE #(  BASE reported-travel (   %tky = <ls_result>-%tky
                                      %state_area = c_area
                                      %msg = NEW zcm_08_message( textid = zcm_08_message=>is_blank
                                               severety = if_abap_behv_message=>severity-error ) ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(lv_agancy) = /lrn/cl_s4d437_model=>get_agency_by_user( ).
    mapped-travel = CORRESPONDING #(  entities ).
    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<ls_mapped>).
      <ls_mapped>-AgencyId = lv_agancy.
      <ls_mapped>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.
  ENDMETHOD.

  METHOD setStatusNew.
    READ ENTITIES OF z08_r_travel IN LOCAL MODE
     ENTITY Travel
     FIELDS (  Status )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result>-Status = 'N'.
    ENDLOOP.

    MODIFY ENTITIES OF z08_r_travel IN LOCAL MODE
   ENTITY Travel
   UPDATE
   FIELDS ( Status )
   WITH CORRESPONDING #( lt_result ).

  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF z08_r_travel IN LOCAL MODE
       ENTITY Travel
       FIELDS (  Status BeginDate EndDate )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_travel).

    LOOP AT  lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      APPEND CORRESPONDING #(  <ls_travel> ) TO result
         ASSIGNING FIELD-SYMBOL(<result>).
*** Draf check
      IF <ls_travel>-%is_draft = if_abap_behv=>mk-on.
        READ ENTITIES OF z08_r_travel IN LOCAL MODE
        ENTITY Travel
        FIELDS ( BeginDate EndDate )
        WITH VALUE #( (  %key = <ls_travel>-%key %is_draft = if_abap_behv=>mk-off ) )
        RESULT DATA(tr_active).

        IF tr_active IS INITIAL.

          CLEAR: <ls_travel>-BeginDate, <ls_travel>-EndDate.
        ELSE.
          <ls_travel>-BeginDate = tr_active[ 1 ]-BeginDate.
          <ls_travel>-EndDate = tr_active[ 1 ]-EndDate.
        ENDIF.
      ENDIF.

      IF  <ls_travel>-EndDate IS NOT INITIAL AND
            <ls_travel>-EndDate < cl_abap_context_info=>get_system_date( ) .
        <result>-%update = if_abap_behv=>fc-o-disabled.
        <result>-%action-canceltravel = if_abap_behv=>fc-o-disabled.
      ELSE.
        <result>-%update = if_abap_behv=>fc-o-enabled.
        <result>-%action-canceltravel = if_abap_behv=>fc-o-enabled.

      ENDIF.

      IF   <ls_travel>-BeginDate IS NOT INITIAL AND
      <ls_travel>-BeginDate < cl_abap_context_info=>get_system_date( ) .
        <result>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
        <result>-%field-EndDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-unrestricted.
        <result>-%field-EndDate = if_abap_behv=>fc-f-unrestricted.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateDataSeq.
    FINAL(today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF z08_r_travel IN LOCAL MODE
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
                        %msg = NEW zcm_08_message(
                        textid = zcm_08_message=>end_before_start
                        severety = if_abap_Behv_message=>severity-error
                        )
                          ) TO  reported-travel.
      ENDIF.



    ENDLOOP.
  ENDMETHOD.

  METHOD determineDuration.
    READ ENTITIES OF z08_r_travel IN LOCAL MODE
      ENTITY travel
      FIELDS ( BeginDate EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(result).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
      <line>-Duration = <line>-EndDate - <line>-BeginDate + 1.
      IF <line>-Duration < 1.
        <line>-Duration = 0.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF z08_r_travel IN LOCAL MODE
      ENTITY Travel
      UPDATE
      FIELDS (  Duration )
      WITH CORRESPONDING #( result ).


  ENDMETHOD.

ENDCLASS.
