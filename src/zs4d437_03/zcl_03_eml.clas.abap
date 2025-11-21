CLASS zcl_03_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070003'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004195'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_03_EML IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  data input_keys type table for read IMPORT z03_r_travel.
    data result_tab TYPE table for read Result z03_r_travel.

    input_keys = value #(  (  AgencyId = '70003' TravelId = '00004195' ) ).

    read ENTITIES OF z03_r_travel "Business Object
    entity Travel "entity name - alias allowed
    all fields with     " FIELDS-clause
    Value #(  (  AgencyId = c_agency_id
                 TRAVELId = c_travel_id ) )
    RESULT DATA(travels)
    FAILED Data(failed).


    IF failed IS NOT INITIAL.
        out->write( 'Error retrieving the travel' ).
    ELSE.
        MODIFY ENTITIES OF z03_r_travel
        ENTITY Travel
        Update FIELDS (  Description )
        with Value #(  ( AgencyId = c_agency_id
                         TravelId = c_travel_id
                         Description = 'MY new Description' ) )
        FAILED failed.

    ENDIF.

    IF failed IS iNITIAL.
        COMMIT ENTITIES.
        out->write(  'Description successfully updated' ).
    ELSE.
        ROLLBACK ENTITIES.
        out->write(  'Error updating the description' ).
    ENDIF.


  ENDMETHOD.
ENDCLASS.
