CLASS zcl_02_complex_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_02_complex_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA travel TYPE TABLE FOR create z02_r_travel.
    DATA items TYPE TABLE FOR create z02_r_travel\_Item.

    travel = value #( ( %cid = 'NEWROOT' CustomerId = '5' BeginDate = '20251201' EndDate = '20251212' Description = 'Test Chris Assosiation' ) ).
    items  = value #( ( %cid_ref = 'NEWROOT' %target =
    value #( ( %cid = 'ITEM1' CarrierId = 'LH' ConnectionId = '0400' FlightDate = '20251201' PassengerFirstName = 'David' PassengerLastName = 'Fischer' )
             ( %cid = 'ITEM2' CarrierId = 'LH' ConnectionId = '0401' FlightDate = '20251212' PassengerFirstName = 'David' PassengerLastName = 'Fischer' )
           )
           ) ).

    MODIFY ENTITIES OF z02_r_travel
    ENTITY travel
    CREATE FIELDS ( customerId beginDate endDate Description  )
    WITH travel
    CREATE BY \_Item
    FIELDS ( carrierid connectionid flightdate passengerfirstname passengerlastname )
    WITH items
    FAILED DATA(failed)
    REPORTED DATA(reported).

    commit ENTITIES responses FAILED data(c_faild) REPORTED data(c_reported).
    out->write( 'finished' ).

  ENDMETHOD.
ENDCLASS.
