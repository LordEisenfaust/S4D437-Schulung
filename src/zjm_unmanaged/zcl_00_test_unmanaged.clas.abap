CLASS zcl_00_test_unmanaged DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_00_test_unmanaged IMPLEMENTATION.



  METHOD if_oo_adt_classrun~main.
    DATA connection TYPE TABLE FOR CREATE zjm_r_connection.

    connection = VALUE #( (  %cid = 'AAA' carrierId = 'LH' connectionId = '0408'
    Airpfrom = 'FRA' airpto = 'JFK' cityfrom = 'Frankfurt' cityto = 'New York' ) ).

    MODIFY ENTITIES OF zjm_r_connection
    ENTITY Zjm_R_Connection
    CREATE FIELDS ( carrierId connectionId airpfrom airpto cityfrom cityto )
    WITH connection.

    COMMIT ENTITIES.

  ENDMETHOD.

ENDCLASS.
