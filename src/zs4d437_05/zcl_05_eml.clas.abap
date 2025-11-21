CLASS zcl_05_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070005'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004150'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_05_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    READ ENTITIES OF Z05_R_Travel
    ENTITY Travel
    ALL FIELDS
    WITH VALUE #( ( AgencyId = c_agency_id
                    TravelId = c_travel_id ) )
    RESULT DATA(travels)
    FAILED DATA(failed).

    IF failed IS NOT INITIAL.
      LOOP AT failed-travel ASSIGNING FIELD-SYMBOL(<failed>).
        out->write( |Fehlgeschlagen: Travel-ID { <failed>-TravelId } Agency-ID { <failed>-AgencyId }| ).
      ENDLOOP.
    ELSE.
      MODIFY ENTITIES OF Z05_R_Travel
      ENTITY Travel
      UPDATE FIELDS ( Description )
      WITH VALUE #( ( AgencyId = c_agency_id
                      TravelId = c_travel_id
                      Description = |GNU Terry Pratchett| ) )
      FAILED failed.
      IF failed IS INITIAL.
        COMMIT ENTITIES.
      ELSE.
        LOOP AT failed-travel ASSIGNING <failed>.
          out->write( |Fehlgeschlagen: Travel-ID { <failed>-TravelId } Agency-ID { <failed>-AgencyId }| ).
        ENDLOOP.
      ENDIF.
    ENDIF.




  ENDMETHOD.
ENDCLASS.
