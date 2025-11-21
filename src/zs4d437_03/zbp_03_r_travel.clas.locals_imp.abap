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
    METHODS determineStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~determineStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.

  result = CORRESPONDING #(  keys ).

  Loop AT result ASSIGNING FIELD-SYMBOL(<line>).
*    authority-check object '/LRN/AGCY'
*    id '/LRN/AGCY' field <line>-AgencyId
*    id 'ACTVT' field '02'. "Change authorization

    data(rc) = /lrn/cl_s4d437_model=>authority_check(
    i_agencyid = <line>-AgencyId
    i_actvt = '02'
    ).
    if rc = 0.
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
    read ENTITIES OF z03_r_travel in local mode
    entity travel
    ALL FIELDS
    with CORRESPONDING #( keys )
    result data(travels).

    loop at travels INTO Data(travel).
     IF travel-status <> 'C'.
      MODIFY ENTITIES OF Z03_R_Travel IN LOCAL MODE
        ENTITY Travel
            Update
            FIELDS ( status )
            With Value #( (  %tky = travel-%tky
                       status = 'C' ) ).
     ELSE.
        APPEND VALUE #( %tky = travel-%tky )
        TO failed-travel.

        APPEND VALUE #(
        %tky = travel-%tky
*        %msg = NEW /LRN/CM_S4D437(
*                textid = /LRN/CM_S4D437=>already_canceled )
        %msg = NEW ZCM_03_TRAVEL( textid = zcm_03_travel=>already_canceled ) )
                TO reported-travel.

     ENDIF.
    endloop.

  ENDMETHOD.

  METHOD validateDescription.

  CONSTANTS c_area TYPE string VALUE 'DESC'.

  READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
   ENTITY Travel
   Fields ( Description )
   WITH CORRESPONDING #( keys )
   RESULT DATA(travels).

   LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

   APPEND VALUE #(  %tky        = <travel>-%tky
                    %state_area = c_area )
     TO reported-travel.

   IF <travel>-Description IS INITIAL.
    APPEND VALUE #(  %tky = <travel>-%tky )
    TO failed-travel.

    APPEND VALUE #(  %tky = <travel>-%tky
                     %msg = NEW /lrn/cm_s4d437(
                     /lrn/cm_s4d437=>field_empty )
                     %element-Description = if_abap_behv=>mk-on  )
     TO reported-travel.
   ENDIF.

   ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.

  CONSTANTS c_area TYPE string VALUE 'CUST'.

  DATA check_id TYPE abap_bool.

  read entities of z03_r_travel in local mode
  entity travel
  fields ( CustomerId )
  with corresponding #( keys )
  result data(travels).

  Loop at travels assigning field-symbol(<travel>).

   Append VALUE #(  %tky    = <travel>-%tky
                    %state_area = c_area )
      TO reported-travel.

   IF <travel>-CustomerId IS INITIAL.

    Append VALUE #( %tky = <travel>-%tky )
     TO failed-travel.

    Append Value #( %tky                = <travel>-%tky
                    %msg                = NEW /lrn/cm_s4d437(
                                   /lrn/cm_s4d437=>field_empty )
                    %element-CustomerId = if_abap_behv=>mk-on
                    %state_area = c_area )
        TO reported-travel.
    ELSE.
     Select SINGLE FROM /dmo/i_customer
     FIELDS CustomerID
     WHERE CustomerID = @<travel>-CustomerId
     INTO @DATA(dummy).

     IF sy-subrc <> 0.
      APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.

      APPEND VALUE #( %tky      = <travel>-%tky
                      %msg      = NEW /lrn/cm_s4d437(
                       /lrn/cm_s4d437=>field_empty
                        )
                      %element-description = if_abap_behv=>mk-on
                      %state_area          = c_area )
            TO reported-travel.
     ENDIF.
    ENDIF.
  ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_create.

mapped-travel = corresponding #( entities ).
  data(agency) = /lrn/cl_s4d437_model=>get_agency_by_user( ).

  Loop At mapped-travel ASSIGNING FIELD-SYMBOL(<key>).

   <key>-AgencyId = agency.
   <key>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid(  ).

  ENDLOOP.

  ENDMETHOD.

  METHOD determineStatus.
  READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
  ENTITY Travel
   Fields ( Status )
   WITH CORRESPONDING #( keys )
   RESULT DATA(travels).

   DELETE travels WHERE Status IS NOT INITIAL.
   CHECK travels IS NOT INITIAL.

   Modify ENTITIES OF Z03_R_Travel in local mode
    ENTITY Travel
    Update FIELDS ( Status )
    WITH VALUE #( FOR key IN travels ( %tky  = key-%tky
                                       Status = 'N' ) )
    REPORTED DATA(update_reported).

  reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD get_instance_features.

final(today) = cl_abap_context_info=>get_system_date(  ).

  read entities of z03_r_travel in local mode
  entity Travel
  FIELDS (  Status BeginDate EndDate )
  With CORRESPONDING #( keys )
  RESULT DATA(travels).

  loop at travels ASSIGNING FIELD-SYMBOL(<travel>).

    append CORRESPONDING #( <travel> ) to result
    ASSIGNING FIELD-SYMBOL(<result>).

    IF <travel>-Status = 'C' OR
    (  <travel>-EndDate IS NOT INITIAL AND
       <travel>-EndDate < cl_abap_context_info=>get_system_date( ) ).

    <result>-%update                   = if_abap_behv=>fc-o-disabled.
    <result>-%action-cancel_travel     = if_abap_behv=>fc-o-disabled.

    ELSE.

    <result>-%update                   = if_abap_behv=>fc-o-enabled.
    <result>-%action-cancel_travel     = if_abap_behv=>FC-O-enabled.

    ENDIF.

    IF <travel>-BeginDate IS NOT INITIAL AND
       <travel>-BeginDate < cl_abap_context_info=>get_system_date( ).

       <result>-%field-CustomerId = if_abap_behv=>fc-f-read_only.
       <result>-%field-BeginDate  = if_abap_behv=>fc-f-read_only.

    ELSE.
       <result>-%field-CustomerId = if_abap_behv=>fc-f-mandatory.
       <result>-%field-BeginDate  = if_abap_behv=>fc-f-mandatory.


    ENDIF.


  ENDLOOP.

  ENDMETHOD.

ENDCLASS.
