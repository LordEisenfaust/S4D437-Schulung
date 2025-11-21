CLASS zcl_00_test_create DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_00_test_create IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA travel TYPE TABLE FOR CREATE z00_r_Travel.
    data action type table for  ACTION IMPORT z00_r_travel~determineCustomerCorrect.

    travel = VALUE #( ( %is_draft = if_abap_behv=>mk-on BeginDate = '20251201' EndDate = '20251205' description = 'Missing' customerId = '999998' ) ).

    MODIFY ENTITIES OF z00_r_Travel
    ENTITY travel
    CREATE AUTO FILL CID FIELDS ( BeginDate EndDate description customerid )
   wITH travel
   MAPPED data(keys).


    MODIFY ENTITIES OF z00_r_travel
    ENTITY travel
    EXECUTE determineCustomerCorrect
    FROM CORRESPONDING #( travel )
    FAILED DATA(failed)
    REPORTED DATA(reported).


    COMMIT ENTITIES.




    MODIFY ENTITIES OF z00_r_Travel
    ENTITY travel
    DELETE FROM CORRESPONDING #( travel ).
    COMMIT ENTITIES.

  ENDMETHOD.
ENDCLASS.
