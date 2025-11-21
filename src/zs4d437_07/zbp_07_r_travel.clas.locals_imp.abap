CLASS lsc_z07_r_travel DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_z07_r_travel IMPLEMENTATION.

  METHOD save_modified.

  data(model) = new /lrn/cl_s4d437_tritem( i_table_name = 'z07_tritem' ).

  loop at delete-item assigning FIELD-SYMBOL(<item_d>).
    model->delete_item( i_uuid = <item_d>-ItemUuid ).
  endloop.

  loop at create-item ASSIGNING FIELD-SYMBOL(<item_c>).
    model->create_item(
            i_item = corresponding #( <item_c> mapping from entity ) ).
  endloop.

  loop at update-item assigning FIELD-SYMBOL(<item_u>).
    model->update_item(
        i_item  =   corresponding #( <item_u> mapping from entity )
        i_itemx =   corresponding #( <item_u> mapping from entity using control ) ).
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

  READ ENTITIES OF z07_r_travel in local mode
  entity item
  fields ( AgencyId TravelId FlightDate )
  with corresponding #( keys )
  result data(items).

  loop at items assigning FIELD-SYMBOL(<item>).
    CONSTANTS c_area type string value 'FLIGHTDATE'.

    append value #( %tky        = <item>-%tky
                    %state_area = c_area ) to reported-item.
    if <item>-FlightDate is initial.

        append value #( %tky    = <item>-%tky ) to failed-item.
        append value #( %tky = <item>-%tky
                    %msg = NEW /lrn/cm_s4d437(
                            /lrn/cm_s4d437=>field_empty )
                            %element-flightdate = if_abap_behv=>mk-on
                            %state_area          = c_area
                            %path-travel        = corresponding #( <item> ) ) to reported-item.
    elseif <item>-FlightDate < cl_abap_context_info=>get_system_date( ).

        append value #( %tky    = <item>-%tky ) to failed-item.
        append value #( %tky = <item>-%tky
                    %msg = NEW /lrn/cm_s4d437(
                            /lrn/cm_s4d437=>flight_date_past )
                            %element-flightdate = if_abap_behv=>mk-on
                            %state_area          = c_area
                            %path-travel        = corresponding #( <item> ) ) to reported-item.
    endif.


  endloop.

  ENDMETHOD.

  METHOD determineTravelDates.

  read ENTITIES OF z07_r_travel in local mode
  entity item
  fields ( FlightDate )
  with corresponding #( keys )
  result data(items)

  by \_Travel
  fields ( BeginDate EndDate )
  with corresponding #( keys )
  result data(travels)
  link data(link).

  loop at items assigning FIELD-SYMBOL(<item>).

    assign travels[ KEY id %tky =
    link[ KEY id source-%tky = <item>-%tky ]-target-%tky ]
        to FIELD-SYMBOL(<travel>).

    if <item>-FlightDate > cl_abap_context_info=>get_system_date(  )
        and <travel>-EndDate < <item>-FlightDate.
       <travel>-EndDate = <item>-FlightDate.
    endif.

  endloop.

  modify entities of z07_r_travel in local mode
  entity travel
  update fields ( BeginDate EndDate )
  with corresponding #( travels ).

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
    METHODS ValidateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~ValidateDescription.
    METHODS ValidateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~ValidateCustomer.
    METHODS ValidateBeginDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~ValidateBeginDate.

    METHODS ValidateDateSequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~ValidateDateSequence.

    METHODS ValidateEndDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~ValidateEndDate.
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

  result = corresponding #( keys ).
  loop at result assigning FIELD-SYMBOL(<result>).
    data(rc) = /lrn/cl_s4d437_model=>authority_check(
                                           i_agencyid   = <result>-agencyid
                                           i_actvt      = '02' ).
   if rc <> 0.
    <result>-%action-cancel_travel  = if_abap_behv=>auth-unauthorized.
    <result>-%update                = if_abap_behv=>auth-unauthorized.

    else.
    <result>-%action-cancel_travel  = if_abap_behv=>auth-allowed.
    <result>-%update                = if_abap_behv=>auth-allowed.
  endif.

  endloop.

  ENDMETHOD.

  METHOD get_global_authorizations.



  ENDMETHOD.

  METHOD cancel_travel.

  read ENTITIES OF z07_r_travel in local mode
  entity travel
  all fields
  with corresponding #( keys )
  result data(travels).

  loop at travels into data(travel).

  if travel-Status <> 'C'.
  modify entities of z07_r_travel in local mode
  entity travel
    update
    fields ( status )
    with value #( (  %tky = travel-%tky
                     status = 'C' ) ).

  else.
    append value #( %tky = travel-%tky ) to failed-travel.

  append value #(
    %tky = travel-%tky
*    %msg = NEW /lrn/cm_s4d437(
*                    textid =
*                            /lrn/cm_s4d437=>already_canceled ) )
    %msg = NEW zcm_07_messages(
                    textid =
                            zcm_07_messages=>already_canceled ) ) to reported-travel.
  endif.
  endloop.

  ENDMETHOD.

  METHOD ValidateDescription.

  CONSTANTS c_area type string value 'DESC'.

  read entities of z07_r_travel in local mode
  entity travel
  fields ( Description )
  WITH corresponding #( keys )
  result data(travels).

  loop at travels assigning FIELD-SYMBOL(<travel>).

    append VALUE #( %tky        = <travel>-%tky
                    %state_area = c_area ) to reported-travel.

  If <travel>-description is INITIAL.
    append value #( %tky = <travel>-%tky ) to failed-travel.
    append value #( %tky = <travel>-%tky
                    %msg = NEW /lrn/cm_s4d437(
                            /lrn/cm_s4d437=>field_empty )
                            %element-description = if_abap_behv=>mk-on
                            %state_area          = c_area ) to reported-travel.
  endif.
  endloop.




  ENDMETHOD.

  METHOD ValidateCustomer.

  constants c_area type string value 'CUST'.

  read entities of z07_r_travel in local mode
  entity travel
  fields ( CustomerID )
  with CORRESPONDING #( keys )
  result data(travels).

  loop at travels assigning FIELD-SYMBOL(<travel>).

    append VALUE #( %tky        = <travel>-%tky
                    %state_area = c_area )  to reported-travel.

  if <travel>-CustomerId is initial.
    append value #( %tky = <travel>-%tky ) to failed-travel.
    append value #( %tky = <travel>-%tky
                    %msg = NEW /lrn/cm_s4d437(
                            /lrn/cm_s4d437=>field_empty )
                            %element-CustomerId = if_abap_behv=>mk-on
                            %state_area         = c_area ) to reported-travel.
  else.
    select single from /dmo/i_Customer
    fields CustomerID
    where CustomerID = @<travel>-CustomerId
    into @data(dummy).

    if sy-subrc <> 0.
    append value #( %tky = <travel>-%tky ) to failed-travel.
    append value #( %tky = <travel>-%tky
                    %msg = NEW /lrn/cm_s4d437(
                           textid  = /lrn/cm_s4d437=>customer_not_exist
                           customerid   = <travel>-CustomerId )
                            %element-CustomerId = if_abap_behv=>mk-on
                            %state_area         = c_area ) to reported-travel.
    endif.
  endif.

  endloop.

  ENDMETHOD.

  METHOD ValidateBeginDate.

  constants c_area type string value 'BEGINDATE'.

  read entities of z07_r_travel in local mode
  entity travel
  fields ( BeginDate )
  with CORRESPONDING #( keys )
  result data(travels).

  loop at travels assigning FIELD-SYMBOL(<travel>).

    append value #( %tky        = <travel>-%tky
                    %state_area = c_area ) to reported-travel.

  if <travel>-BeginDate is initial.
    append value #( %tky = <travel>-%tky ) to failed-travel.
    append value #( %tky = <travel>-%tky
                    %msg = NEW /lrn/cm_s4d437(
                            /lrn/cm_s4d437=>field_empty )
                            %element-BeginDate = if_abap_behv=>mk-on
                            %state_area        = c_area ) to reported-travel.
  elseif <travel>-begindate <
            cl_abap_context_info=>get_system_date(  ).
        append value #( %tky = <travel>-%tky ) to failed-travel.
        append value #( %tky = <travel>-%tky
                    %msg = NEW /lrn/cm_s4d437(
                            /lrn/cm_s4d437=>begin_date_past )
                            %element-BeginDate = if_abap_behv=>mk-on
                            %state_area        = c_area ) to reported-travel.
  endif.
  ENDLOOP.




  ENDMETHOD.

  METHOD ValidateDateSequence.

  constants c_area type string value 'SEQUENCE'.

  read entities of z07_r_travel in local mode
  entity travel
  fields ( BeginDate EndDate )
  with CORRESPONDING #( keys )
  result data(travels).

  loop at travels assigning FIELD-SYMBOL(<travel>).

    append value #( %tky        = <travel>-%tky
                    %state_area = c_area ) to reported-travel.

  if <travel>-EndDate < <travel>-BeginDate.
    append value #( %tky = <travel>-%tky ) to failed-travel.
    append value #( %tky = <travel>-%tky
                    %msg = NEW /lrn/cm_s4d437(
                            /lrn/cm_s4d437=>dates_wrong_sequence )
                            %element = Value #(
                                BeginDate = if_abap_behv=>mk-on
                                EndDate = if_abap_behv=>mk-on )
                            %state_area = c_area ) to reported-travel.
  endif.
  endloop.

  ENDMETHOD.

  METHOD ValidateEndDate.

  constants c_area type string value 'ENDDATE'.

  read entities of z07_r_travel in local mode
  entity travel
  fields ( EndDate )
  with CORRESPONDING #( keys )
  result data(travels).

  loop at travels assigning FIELD-SYMBOL(<travel>).

    append value #( %tky        = <travel>-%tky
                    %state_area = c_area ) to reported-travel.

  if <travel>-EndDate is initial.
    append value #( %tky = <travel>-%tky ) to failed-travel.
    append value #( %tky = <travel>-%tky
                    %msg = NEW /lrn/cm_s4d437(
                            /lrn/cm_s4d437=>field_empty )
                            %element-EndDate = if_abap_behv=>mk-on
                            %state_area = c_area ) to reported-travel.
  elseif <travel>-enddate <
            cl_abap_context_info=>get_system_date(  ).
        append value #( %tky = <travel>-%tky ) to failed-travel.
        append value #( %tky = <travel>-%tky
                    %msg = NEW /lrn/cm_s4d437(
                            /lrn/cm_s4d437=>end_date_past )
                            %element-EndDate = if_abap_behv=>mk-on
                            %state_area = c_area ) to reported-travel.
  endif.
  ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_create.

  data(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user(  ).

  mapped-travel = CORRESPONDING #( entities ).
  loop at mapped-travel assigning FIELD-SYMBOL(<mapping>).
  <mapping>-AgencyId = agencyid.
  <mapping>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid(  ).


  endloop.

  ENDMETHOD.

  METHOD determineStatus.

  read ENTITIES OF z07_r_travel in local mode
  entity travel
  fields ( Status )
  with corresponding #( keys )
  result data(travels).

  DELETE travels where status is not initial.
  CHECK travels is not initial.

  modify entities of z07_r_travel in local mode
  entity travel
  update fields ( Status )
  with value #( for key in travels ( %tky       = key-%tky
                                     Status     = 'N' ) )

     reported data(update_reported).
  reported = corresponding #( DEEP update_reported ).

  ENDMETHOD.

  METHOD get_instance_features.

  READ ENTITIES OF z07_r_travel in local mode
  entity travel
  fields ( Status BeginDate EndDate )
  with corresponding #( keys )
  result data(travels).
  loop at travels assigning FIELD-SYMBOL(<travel>).

    append CORRESPONDING #( <travel> ) to result
        assigning FIELD-SYMBOL(<result>).

    if <travel>-%is_draft = if_abap_behv=>mk-on.

        read entities of z07_r_travel in local mode
        entity travel
        fields ( BeginDate EndDate )
        with Value #( ( %key = <travel>-%key ) )
        result data(travels_active).

        if travels_active is not INITIAL.
            <travel>-BeginDate  = travels_active[ 1 ]-BeginDate.
            <travel>-EndDate    = travels_active[ 1 ]-EndDate.
        else.
            clear <travel>-BeginDate.
            clear <travel>-EndDate.
        endif.

    endif.

    if  <travel>-Status = 'C' or
      ( <travel>-BeginDate is not initial and
        <travel>-EndDate < cl_abap_context_info=>get_system_date( ) ).
    <result>-%update                        = if_abap_behv=>fc-o-disabled.
    <result>-%action-cancel_travel          = if_abap_behv=>fc-o-disabled.
    else.
    <result>-%update                        = if_abap_behv=>fc-o-enabled.
    <result>-%action-cancel_travel          = if_abap_behv=>fc-o-enabled.

    endif.

    if  <travel>-BeginDate is not initial and
        <travel>-BeginDate < cl_abap_context_info=>get_system_date(  ).

        <result>-%field-CustomerId         = if_abap_behv=>fc-f-read_only.
        <result>-%field-BeginDate          = if_abap_behv=>fc-f-read_only.
    else.
        <result>-%field-CustomerId         = if_abap_behv=>fc-f-mandatory.
        <result>-%field-BeginDate          = if_abap_behv=>fc-f-mandatory.
    endif.
  endloop.

  ENDMETHOD.

  METHOD determineDuration.

  read entities of z07_r_travel in local mode
  entity travel
  fields ( BeginDate EndDate )
  with corresponding #( keys )
  result data(travels).

  loop at travels assigning FIELD-SYMBOL(<travel>).
  <TRAVEL>-Duration = <travel>-EndDate - <travel>-BeginDate.
  endloop.

  modify ENTITIES OF z07_r_travel in local mode
  entity travel
  update fields ( duration )
  with corresponding #( travels ).

  ENDMETHOD.

ENDCLASS.
