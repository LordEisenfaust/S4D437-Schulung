CLASS zcl_07_simple_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070007'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '0004164'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_07_SIMPLE_EML IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


  read ENTITIES OF z07_r_travel
  entity travel
  all fields with value #( ( AgencyId = c_agency_id
                            TravelId = c_travel_id ) )
  result data(travels)
  failed data(failed).

  if failed is not initial.
    out->write( 'Error retrieving the travel' ).
  else.
    modify ENTITIES OF z07_r_travel
    entity travel
    update fields ( description )
    with value #( ( AgencyId = c_agency_id
                  TravelId = c_travel_id
                  description = 'Travel in the future modified' ) )
  failed failed.
  endif.

  if failed is initial.
    commit entities.
    out->write( 'Description successfully updated' ).
  else.
    rollback entities.
    out->write( 'Error updating the description' ).
  endif.

  ENDMETHOD.
ENDCLASS.
