CLASS lhc_Zjm_R_Connection DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Zjm_R_Connection RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Zjm_R_Connection RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Zjm_R_Connection.

    METHODS read FOR READ
      IMPORTING keys FOR READ Zjm_R_Connection RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Zjm_R_Connection.
*    METHODS determineFromCity FOR DETERMINE ON SAVE
*      IMPORTING keys FOR Zjm_R_Connection~determineFromCity.
*
*    METHODS determineToCity FOR DETERMINE ON SAVE
*      IMPORTING keys FOR Zjm_R_Connection~determineToCity.

ENDCLASS.

CLASS lhc_Zjm_R_Connection IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<line>).
      zjm_unmanaged_model=>create_flight(
        EXPORTING
          is_record     = CORRESPONDING #( <line>  MAPPING FROM ENTITY )
        EXCEPTIONS
          create_failed = 1 ).


    ENDLOOP.
  ENDMETHOD.

  METHOD read.

    DATA read_keys TYPE zjm_unmanaged_Model=>rt_carriers.

    read_keys = VALUE #( FOR line IN keys ( low = line-CarrierId sign = 'I' option = 'EQ' ) ).

    zjm_unmanaged_model=>read_flights(
      EXPORTING
        carriers = read_keys
      IMPORTING
        flights  = DATA(model_result)
    ).

    result = CORRESPONDING #( model_result MAPPING TO ENTITY ).

    ENDMETHOD.

    METHOD lock.
    ENDMETHOD.

*  METHOD determineFromCity.
*  read entities of zjm_r_connection in local mode
*  entity Zjm_R_Connection
*  all fields
*  with corresponding #( keys )
*  result data(result).
*  loop at result assigning field-symbol(<line>).
*  select from /dmo/airport
*  fields city
*  where airport_id = @<line>-Airpfrom
*  into @<line>-Airpfrom.
*
**  modify entities of zjm_r_connection in local mode
**  entity zjm_r_connection
**  update  fields ( airpfrom )
**  with corresponding #( result ).
*
*
*
*  ENDMETHOD.

*  METHOD determineToCity.
*  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZJM_R_CONNECTION DEFINITION INHERITING FROM cl_abap_behavior_saver.
PROTECTED SECTION.

  METHODS finalize REDEFINITION.

  METHODS check_before_save REDEFINITION.

  METHODS save REDEFINITION.

  METHODS cleanup REDEFINITION.

  METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZJM_R_CONNECTION IMPLEMENTATION.

METHOD finalize.
ENDMETHOD.

METHOD check_before_save.
ENDMETHOD.

METHOD save.

zjm_unmanaged_model=>save( ).


ENDMETHOD.

METHOD cleanup.
ENDMETHOD.

METHOD cleanup_finalize.
ENDMETHOD.

ENDCLASS.
