CLASS zcl_07_create_item DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_07_create_item IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

   DATA travel TYPE TABLE FOR CREATE z07_r_travel.
    DATA items TYPE TABLE FOR CREATE z07_r_travel\_TravelItem.

    travel = VALUE #( ( %cid = 'NEWROOT' customerId = '1' begindate = '20251201' enddate = '20251205' Description = 'Create by Association' ) ).
    items = VALUE #( ( %cid_ref = 'NEWROOT' %target =
    VALUE #( ( %cid = 'ITEM1' carrierid = 'LH' connectionId = '0400' flightdate = '20251201' PassengerFirstName = 'Max'
    PassengerLastName = 'Mustermann' )
    ( %cid = 'ITEM2' carrierid = 'LH' connectionId = '0401' flightdate = '20251204' PassengerFirstName = 'Max'
    PassengerLastName = 'Mustermann'  )
     )
    ) ).

    MODIFY ENTITIES OF z07_r_travel
    ENTITY Travel
    CREATE FIELDS ( customerId beginDate endDate Description  )
    WITH travel
    CREATE BY \_TravelItem
    FIELDS ( carrierid connectionid flightdate passengerfirstname passengerlastname )
    WITH items
    FAILED DATA(failed)
    REPORTED DATA(reported).

    COMMIT ENTITIES RESPONSES
    FAILED DATA(c_failed)
    REPORTED DATA(c_reported).

    out->write( 'finished' ).

  ENDMETHOD.
ENDCLASS.
