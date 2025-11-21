CLASS zcl_08_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '0700##'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '000#####'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_08_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA lt_read TYPE TABLE FOR READ IMPORT  z08_r_travel.
    DATA lt_read_result TYPE TABLE FOR  UPDATE  z08_r_travel.

    lt_read = VALUE #( ( AgencyId = '070008' TravelId = '00004203' ) ).

    READ ENTITIES OF z08_r_travel
    ENTITY Travel
    ALL FIELDS
    WITH lt_read
    RESULT DATA(lt_travel_result)
    FAILED DATA(lt_readfgailed).

    out->write( lt_travel_result ).


    LOOP AT lt_travel_result ASSIGNING FIELD-SYMBOL(<ls_travel>).
      data(ls_read_result) = corresponding z08_r_travel( <ls_travel> ).
      ls_read_result = value #( base ls_read_result
                             Description = 'Modify description'    Status = 'U'   ).
      lt_read_result = VALUE #( base lt_read_result (  CORRESPONDING #( ls_read_result  )  ) ).
    ENDLOOP.

    MODIFY ENTITIES OF z08_r_travel
    ENTITY Travel
    UPDATE
    FIELDS ( Description Status )
    WITH lt_read_result
    FAILED DATA(lt_failed_update).

    IF lt_failed_update IS  INITIAL.
      COMMIT ENTITIES.
    ELSE.
      out->write( lt_failed_update ).
    ENDIF.


  ENDMETHOD.
ENDCLASS.
