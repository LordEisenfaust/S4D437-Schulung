CLASS zcl_10_elm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070010'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004159'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_10_ELM IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    READ ENTITIES OF z10_r_travel
         ENTITY Travel
         ALL FIELDS
         WITH VALUE #( (  AgencyId = c_agency_id  TravelId = c_travel_id ) )
         RESULT DATA(travels)
         FAILED DATA(failed).

    IF failed IS NOT INITIAL.
      out->write( 'Failed.' ).
      RETURN.
    ENDIF.

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      <travel>-Description = |{ <travel>-Description } modified|.
    ENDLOOP.

    MODIFY ENTITIES OF z10_r_travel
           ENTITY Travel
           UPDATE
           FIELDS ( Description )
           WITH CORRESPONDING #( travels )
           FAILED failed.

    IF failed IS NOT INITIAL.
      out->write( 'Update failed' ).
      ROLLBACK ENTITIES.
      RETURN.
    ENDIF.

    COMMIT ENTITIES.
    out->write( 'Edit correct' ).
  ENDMETHOD.
ENDCLASS.
