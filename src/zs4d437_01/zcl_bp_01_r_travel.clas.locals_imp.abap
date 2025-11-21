CLASS lsc_z01_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z01_r_travel IMPLEMENTATION.

  METHOD save_modified.

    DATA(lo_Model) = NEW /lrn/cl_s4d437_tritem( i_table_name = 'Z01_TRITEM' ).

    LOOP AT delete-item ASSIGNING FIELD-SYMBOL(<ls_del>).
      DATA(lv_msg) = lo_model->delete_item( i_uuid = <ls_del>-ItemUuid ).
    ENDLOOP.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<ls_Cre>).
      lv_msg = lo_model->create_item( i_item = CORRESPONDING #( <ls_cre> MAPPING FROM ENTITY ) ).
    ENDLOOP.

    IF create-travel IS NOT INITIAL.
      RAISE ENTITY EVENT z01_r_Travel~TravelCreated
        FROM VALUE #( FOR line IN create-travel ( %key = line-%key origin = 'Z01_R_TRAVEL' ) ).
    ENDIF.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<ls_upd>).
      lv_msg = lo_model->update_item( i_item  = CORRESPONDING #( <ls_upd> MAPPING FROM ENTITY )
                                      i_itemx = CORRESPONDING #( <ls_upd> MAPPING FROM ENTITY USING CONTROL )  ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS TravelDates FOR DETERMINE ON SAVE
      IMPORTING keys FOR Item~TravelDates.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Item RESULT result.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD TravelDates.

    READ ENTITIES OF z01_r_travel IN LOCAL MODE
    ENTITY item
        FIELDS ( flightdate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_items)
        BY \_Travel
        FIELDS (  BeginDate Enddate )
            WITH CORRESPONDING #( keys )
            RESULT DATA(lt_travel)
            LINK DATA(lt_link).

    SORT lt_items BY FlightDate.

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_items>).

      DATA(lv_report) = abap_False.

      READ TABLE lt_link ASSIGNING FIELD-SYMBOL(<ls_link>) WITH KEY id COMPONENTS source-%tky = <ls_items>-%tky.
      CHECK sy-subrc = 0.

      READ TABLE lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>) WITH KEY id COMPONENTS %tky = <ls_link>-target-%tky.
      CHECK sy-subrc = 0.

      IF <ls_travel>-begindate > <ls_items>-flightdate.
        <ls_travel>-begindate = <ls_items>-flightdate.
        lv_Report = abap_true.
      ENDIF.

      IF <ls_travel>-enddate < <ls_items>-flightdate.
        <ls_travel>-enddate = <ls_items>-flightdate.
        lv_Report = abap_true.
      ENDIF.

      APPEND VALUE #( %tky = <ls_items>-%tky %state_area = 'TRDATES' ) TO reported-item.

      IF lv_Report IS NOT INITIAL.
        APPEND VALUE #(  %tky = <ls_items>-%tky
                         %state_area = 'TRDATES'
                         %path-travel = CORRESPONDING #( <ls_travel>-%tky )
                         %msg = NEW zcx_01_travel( Textid = zcx_01_travel=>travel_date_chg severity = if_abap_behv_message=>severity-information ) )
               TO reported-item.
      ENDIF.

    ENDLOOP.

    MODIFY ENTITIES OF z01_r_travel IN LOCAL MODE
          ENTITY Travel
              UPDATE FIELDS ( begindate enddate )
                  WITH CORRESPONDING #( lt_travel )
                    REPORTED DATA(ls_reported).

    IF ls_Reported IS NOT INITIAL.
      reported = CORRESPONDING #( DEEP ls_reported ).
    ENDIF.


  ENDMETHOD.

  METHOD get_instance_authorizations.
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
    METHODS validateCustomerIdOnSave FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomerIdOnSave.

    METHODS validateDescriptionOnSave FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDescriptionOnSave.
    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.
    METHODS Init FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~Init.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS update FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~update.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

    result = CORRESPONDING #( keys ).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<ls_Result>).

      DATA(lv_rc) = /lrn/cl_s4d437_model=>authority_check( i_agencyid = <ls_result>-agencyid i_actvt = '02' ).

      IF lv_Rc <> 0.
        <ls_result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
        <ls_result>-%update = if_abap_behv=>auth-unauthorized.
      ELSE.
        <ls_result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
        <ls_result>-%update = if_abap_behv=>auth-allowed.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.

    READ ENTITIES OF z01_r_travel IN LOCAL MODE
        ENTITY Travel
            ALL FIELDS
             WITH CORRESPONDING #( keys )
                RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travels>).

      IF <ls_travels>-status = 'C'.

        APPEND VALUE #( %tky = <ls_travels>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <ls_travels>-%tky %msg = NEW zcx_01_travel( Textid = zcx_01_travel=>already_canceled ) ) TO reported-travel.

      ELSEIF <ls_Travels>-BeginDate < cl_abap_context_info=>get_system_date(  ).

        APPEND VALUE #( %tky = <ls_travels>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <ls_travels>-%tky %msg = NEW zcx_01_travel( Textid = zcx_01_travel=>already_started ) ) TO reported-travel.

      ELSE.

        MODIFY ENTITIES OF z01_r_travel IN LOCAL MODE
            ENTITY Travel
                UPDATE
                FIELDS ( status )
                WITH VALUE #( ( %tky = <ls_travels>-%tky status = 'C' ) ).

        APPEND VALUE #( %tky = <ls_travels>-%tky %msg = NEW zcx_01_travel( Textid = zcx_01_travel=>canceled severity = if_abap_behv_message=>severity-success ) ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomerIdOnSave.

    READ ENTITIES OF z01_r_travel IN LOCAL MODE
             ENTITY Travel
                FIELDS ( CustomerId )
                  WITH CORRESPONDING #( keys )
                     RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travels>).

      APPEND VALUE #( %tky = <ls_travels>-%tky %state_area = 'CUSTOMER' ) TO reported-travel.

      IF <ls_travels>-CustomerId IS NOT INITIAL.

        SELECT SINGLE FROM z01_i_customer_vh FIELDS @abap_true
          WHERE CustomerID = @<ls_Travels>-CustomerId INTO @DATA(lv_xvalid).
        IF lv_xvalid IS INITIAL.
          APPEND VALUE #( %tky = <ls_travels>-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = <ls_travels>-%tky
                          %msg = NEW zcx_01_travel( Textid = zcx_01_travel=>customer_invalid iv_msgv1 = <ls_Travels>-CustomerId )
                          %element-CustomerId = if_abap_behv=>mk-on
                          %state_area = 'CUSTOMER' ) TO reported-travel.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDescriptionOnSave.

    READ ENTITIES OF z01_r_travel IN LOCAL MODE
             ENTITY Travel
                FIELDS ( Description )
                  WITH CORRESPONDING #( keys )
                     RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travels>).

      APPEND VALUE #( %tky = <ls_travels>-%tky %state_area = 'DESCR' ) TO reported-travel.

      IF <ls_travels>-Description IS INITIAL.
        APPEND VALUE #( %tky = <ls_travels>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <ls_travels>-%tky
                        %msg = NEW zcx_01_travel( Textid = zcx_01_travel=>descr_missing )
                        %element-Description = if_abap_behv=>mk-on
                        %state_area = 'DESCR' ) TO reported-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITIES OF z01_r_travel IN LOCAL MODE
              ENTITY Travel
                 FIELDS ( BeginDate Enddate )
                   WITH CORRESPONDING #( keys )
                      RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travels>).

      APPEND VALUE #( %tky = <ls_travels>-%tky %state_area = 'BEGIN' ) TO reported-travel.
      APPEND VALUE #( %tky = <ls_travels>-%tky %state_area = 'END' )   TO reported-travel.

      IF <ls_Travels>-begindate IS INITIAL.
        APPEND VALUE #( %tky = <ls_travels>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <ls_travels>-%tky
                        %msg = NEW zcx_01_travel( Textid = zcx_01_travel=>begin_initial )
                        %element-Begindate = if_abap_behv=>mk-on
                        %state_area = 'BEGIN' ) TO reported-travel.
      ELSE.

*        IF <ls_Travels>-begindate < cl_abap_Context_info=>get_system_date(  ).
*          APPEND VALUE #( %tky = <ls_travels>-%tky ) TO failed-travel.
*          APPEND VALUE #( %tky = <ls_travels>-%tky
*                          %msg = NEW zcx_01_travel( Textid = zcx_01_travel=>begin_past )
*                          %element-Begindate = if_abap_behv=>mk-on ) TO reported-travel.
*        ENDIF.

        IF <ls_Travels>-begindate > <ls_Travels>-enddate.
          APPEND VALUE #( %tky = <ls_travels>-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = <ls_travels>-%tky
                          %msg = NEW zcx_01_travel( Textid = zcx_01_travel=>end_lower_begin )
                          %element-enddate = if_abap_behv=>mk-on
                          %state_area = 'END' ) TO reported-travel.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(lv_agency) = /lrn/cl_s4d437_model=>get_agency_by_user(  ).

    mapped-travel = CORRESPONDING #( entities ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<ls_mapped>).
      <ls_mapped>-agencyid = lv_agency.
      <ls_mapped>-travelid = /lrn/cl_s4d437_model=>get_next_travelid(  ).
    ENDLOOP.

  ENDMETHOD.

  METHOD Init.

    READ ENTITIES OF z01_r_travel IN LOCAL MODE
        ENTITY Travel
            FIELDS ( Status )
                WITH CORRESPONDING #( keys )
                    RESULT DATA(lt_travels).

    MODIFY lt_Travels FROM VALUE #( status = 'N' ) TRANSPORTING status WHERE status IS INITIAL.

    MODIFY ENTITIES OF z01_r_travel IN LOCAL MODE
        ENTITY Travel
            UPDATE FIELDS ( status )
                WITH CORRESPONDING #( lt_travels )
                    REPORTED DATA(lt_reported).

    reported = CORRESPONDING #( DEEP lt_Reported ).

    IF reported IS INITIAL.
      APPEND VALUE #( %tky = lt_Travels[ 1 ]-%tky
                      %msg = NEW zcx_01_travel( Textid = zcx_01_travel=>status_ok severity = if_abap_behv_message=>severity-information )
                    ) TO reported-travel.
    ENDIF.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF z01_r_travel IN LOCAL MODE
        ENTITY Travel
            ALL FIELDS
                WITH CORRESPONDING #( keys )
                    RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travels>).
      APPEND CORRESPONDING #( <ls_travels> ) TO result ASSIGNING FIELD-SYMBOL(<ls_result>).

      IF <ls_travels>-%is_draft = if_abap_behv=>mk-on.
        READ ENTITIES OF z01_r_travel IN LOCAL MODE
            ENTITY Travel
                ALL FIELDS
                    WITH VALUE #( ( %key = <ls_travels>-%key %is_draft = if_abap_behv=>mk-off ) )
                        RESULT DATA(lt_active).

        READ TABLE lt_active INTO DATA(ls_active) WITH TABLE KEY entity COMPONENTS %key = <ls_travels>-%key.
      ENDIF.

      IF ls_Active IS INITIAL.
        ls_active = <ls_travels>.
      ENDIF.

      IF <ls_travels>-%is_draft = if_abap_behv=>mk-on OR ls_active-status = 'C' OR ( ls_active-enddate IS NOT INITIAL AND ls_active-enddate < cl_abap_context_info=>get_system_date(  ) ).
        <ls_result>-%action-cancel_travel = if_abap_behv=>fc-o-disabled.
      ELSE.
        <ls_result>-%action-cancel_travel = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF ls_active-status = 'C' OR ( ls_active-enddate IS NOT INITIAL AND ls_active-enddate < cl_abap_context_info=>get_system_date(  ) ).
        <ls_result>-%update = if_abap_behv=>fc-o-disabled.
      ELSE.
        <ls_result>-%update = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF ls_active-begindate IS NOT INITIAL AND ls_active-begindate < cl_abap_context_info=>get_system_date(  ).
        <ls_result>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <ls_result>-%field-BeginDate = if_abap_behv=>fc-f-mandatory.
      ENDIF.

      IF ls_active-enddate IS NOT INITIAL AND ls_active-enddate < cl_abap_context_info=>get_system_date(  ).
        <ls_result>-%field-EndDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <ls_result>-%field-EndDate = if_abap_behv=>fc-f-mandatory.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD Update.

    READ ENTITIES OF z01_r_travel IN LOCAL MODE
          ENTITY Travel
              FIELDS ( Begindate Enddate Duration )
                  WITH CORRESPONDING #( keys )
                      RESULT DATA(lt_travels).

    LOOP AT lt_Travels ASSIGNING FIELD-SYMBOL(<ls_travels>).
      <ls_travels>-duration = <ls_travels>-enddate - <ls_travels>-begindate.
    ENDLOOP.

    MODIFY ENTITIES OF z01_r_travel IN LOCAL MODE
        ENTITY Travel
            UPDATE FIELDS ( Duration )
                WITH CORRESPONDING #( lt_travels )
                    REPORTED DATA(lt_reported).

    reported = CORRESPONDING #( DEEP lt_Reported ).

  ENDMETHOD.

ENDCLASS.
