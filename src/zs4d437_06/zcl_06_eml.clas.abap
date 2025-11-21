CLASS zcl_06_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070006'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004178'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_06_EML IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


  READ ENTITIES OF z06_r_travel
    ENTITY Travel
    all fields with value #(  ( AgencyId = c_agency_id TravelId = c_travel_id ) )
    result data(travels)  "Ergebnis der Selektion
    failed data(failed).  "Tabelle der fehlerhaften Schlüssel

  if failed is not INITIAL.
    out->write( 'Error Felder lesen' ).
  else.
    out->write( 'Lesezugriff erfolgreich'  ).
    modify ENTITIES OF z06_r_travel ENTITY Travel
    update fields (  Description )
    with value #( ( AgencyId = c_agency_id
                    TravelId = c_travel_id
                    Description = 'das war ich5' ) )
    FAILED failed.
    if failed is INITIAL.
      commit ENTITIES.
      out->write( 'Update erfolgreich' ).
    else.
      rollback ENTITIES.
      out->write(  'Update fehlgeschlagen ' ).
    endif.

  endif.


  ENDMETHOD.
ENDCLASS.
