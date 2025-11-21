CLASS zcl_01_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '12345'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '12345'.

    CONSTANTS c_agency_id2 TYPE /dmo/agency_id VALUE '070050'.
    CONSTANTS c_travel_id2 TYPE /dmo/travel_id VALUE '00004187'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_01_eml IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA: lt_Travel TYPE TABLE FOR CREATE z01_r_Travel.
    DATA: lt_Items  TYPE TABLE FOR CREATE z01_r_travel\_TravelItem.

    lt_Travel = VALUE #( ( %cid = 'Dummy' CustomerId = '1' begindate = '20251120' enddate = '20251125' Description = 'By EML' ) ).
    lt_Items = VALUE #( ( %cid_ref = 'Dummy'
                          %target = VALUE #( ( %cid = 'ITEM1' CarrierId = 'LH' ConnectionId = '0400' flightdate = '20251120' PassengerFirstName = 'Karl' PassengerLastName = 'Marx' )
                                             ( %cid = 'ITEM2' CarrierId = 'LH' ConnectionId = '0401' flightdate = '20251121' PassengerFirstName = 'Karl' PassengerLastName = 'Marx' ) )
                         ) ).

    MODIFY ENTITIES OF z01_r_travel
        ENTITY Travel
            CREATE FIELDS (  customerID BeginDate EndDate Description )
                WITH lt_Travel
                    CREATE BY \_TravelItem
                    FIELDS ( CarrierId ConnectionId FlightDate PassengerFirstName PassengerLastName )
                    WITH lt_Items
                       REPORTED DATA(ls_reported)
                       FAILED DATA(ls_failed).

    IF ls_failed IS NOT INITIAL.
      out->write( |Fehler beim Schreiben der Reisen| ).
      RETURN.
    ENDIF.

    COMMIT ENTITIES RESPONSES FAILED DATA(ls_Failed_update).

    IF ls_Failed_update IS NOT INITIAL.
      ROLLBACK ENTITIES.
      out->write( |Fehler beim Schreiben der Reisen| ).
    ENDIF.


*    READ ENTITIES OF z01_r_travel
*        ENTITY Travel
*            FIELDS ( description status changedby changedat ) WITH
*                VALUE #( ( AgencyId = c_agency_id  TravelId = c_travel_id ) ( AgencyId = c_agency_id2 TravelId = c_travel_id2 ) )
*                    RESULT DATA(lt_travels)
*                    FAILED DATA(ls_failed)
*                    REPORTED DATA(ls_reported).
*
*    IF ls_failed IS NOT INITIAL.
*      out->write( |Fehler beim Lesen der Reisen| ).
*      RETURN.
*    ELSE.
*      out->write( lt_travels ).
*
*      LOOP AT lt_Travels ASSIGNING FIELD-SYMBOL(<ls_travels>).
*        <ls_travels>-Description    = |{ <ls_travels>-Description } Mod|.
*        <ls_travels>-Status         = 'U'.
*      ENDLOOP.
*
*      MODIFY ENTITIES OF z01_r_travel
*        ENTITY Travel
*            UPDATE FIELDS ( description )
*                WITH CORRESPONDING #( lt_travels )
*             "   WITH CORRESPONDING #( VALUE #( BASE lt_travels ( AgencyId = '888' TravelId = '666' ) ) )
*                    REPORTED ls_reported
*                    FAILED ls_failed.
*
*      IF ls_failed IS NOT INITIAL.
*        out->write( |Fehler beim Schreiben der Reisen| ).
*        RETURN.
*      ENDIF.
*
*      COMMIT ENTITIES RESPONSES FAILED DATA(ls_Failed_update).
*
*      IF ls_Failed_update IS NOT INITIAL.
*        ROLLBACK ENTITIES.
*        out->write( |Fehler beim Schreiben der Reisen| ).
*      ENDIF.
*
*    ENDIF.

  ENDMETHOD.
ENDCLASS.
