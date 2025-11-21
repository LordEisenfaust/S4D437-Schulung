CLASS zcl_00_simple_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_00_simple_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA input_keys TYPE TABLE FOR READ IMPORT z00_r_travel.
    DATA result_tab TYPE TABLE FOR READ RESULT z00_r_travel.

    input_keys = VALUE #( ( agencyId = '70000' TravelId = '00004145' ) ).

    READ ENTITIES OF z00_R_travel "Business Object
    ENTITY Travel "entity name - alias allowed
*  all fields " FIELDS-clause
  FIELDS ( description status )
  WITH input_keys "WHERE-clause
  RESULT result_tab.

    out->write( result_tab ).

    LOOP AT result_tab ASSIGNING FIELD-SYMBOL(<line>).
      <line>-description = <line>-description && | modified|.
      <line>-status = 'U'.
    ENDLOOP.

    " Add bad data to table
    APPEND VALUE #(    agencyid = '1111' Travelid = '333'  ) TO result_tab.

    MODIFY ENTITIES OF z00_r_travel
    ENTITY Travel
    UPDATE FIELDS ( description status )
    WITH CORRESPONDING #( result_tab )
    FAILED DATA(failed_Modify).

    COMMIT ENTITIES RESPONSES FAILED DATA(failed_update).

    out->write(  'done' ).




  ENDMETHOD.
ENDCLASS.
