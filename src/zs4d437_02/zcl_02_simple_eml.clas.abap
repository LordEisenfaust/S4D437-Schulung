CLASS zcl_02_simple_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_02_simple_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA input_keys TYPE TABLE FOR READ IMPORT z02_r_travel.
    DATA result_tab TYPE TABLE FOR READ RESULT z02_r_travel.

    input_keys = VALUE #( ( agencyID = '070002' TravelID = '00004167' ) ).

    READ ENTITIES OF z02_r_travel "Business Object
    ENTITY Travel "entity name - alias allowed
    "all fields "FIELDS-Clause keine Kommas in der Feldliste, bei all field werden alle geändert
    FIELDS ( description status ) "welche Felder sollen geändert werden
    WITH input_keys "Where-Clause
    RESULT result_tab.

    out->write(  result_tab ).
    LOOP AT result_tab ASSIGNING FIELD-SYMBOL(<line>).
      <line>-Description = <line>-Description && | modified|.
      <line>-status = 'U'.
    ENDLOOP.

    "fehlerhafter Datensatz noch mit ergänzen
    "APPEND VALUE #( agencyID = '1111' TravelID = '333' ) TO result_tab.

    MODIFY ENTITIES OF z02_r_travel
    ENTITY Travel
    UPDATE FIELDS ( description status )
    WITH CORRESPONDING #( result_tab ) "with corresponding, weil noch %-Felder mit dabei sind
    FAILED DATA(failed_modify). "Failed um zu schauen, ob der Datensatz noch nicht in der DB vorhanden ist

    COMMIT ENTITIES." RESPONSES FAILED DATA(failed_update).

    out->write( 'done' ).

  ENDMETHOD.
ENDCLASS.
