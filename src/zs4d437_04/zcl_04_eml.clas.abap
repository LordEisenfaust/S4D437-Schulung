CLASS zcl_04_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070000'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00000001'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_04_EML IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    data input_keys TYPE TABLE FOR READ IMPORT z04_r_travel.
    DATA result_tab TYPE TABLE FOR READ RESULT z04_r_travel.
    input_keys = VALUE #( (  AgencyId = c_agency_id TravelId = c_travel_id ) ).
        READ ENTITIES OF z04_r_travel
            ENTITY Travel
            FIELDS ( Description Status )
                WITH input_keys
                    RESULT result_tab .
    out->write( result_tab ).

    LOOP AT result_tab ASSIGNING FIELD-SYMBOL(<ls_result>).
        <ls_result> = VALUE #( Description = <ls_result>-Description && |Modified| Status = 'U'  ).
    ENDLOOP.

    MODIFY ENTITIES OF z04_r_travel
        ENTITY Travel
            UPDATE FIELDS ( Description Status )
                WITH CORRESPONDING #( result_tab )
                    FAILED DATA(lt_failed).

    if lt_failed IS NOT INITIAL.
        out->write( 'Irgendetwas ist schiefgeangen!' ).
    ELSE.
        MODIFY ENTITIES OF z04_r_travel ENTITY Travel
        UPDATE FIELDS ( Description )
        WITH VALUE #( ( agencyid = c_agency_id travelid = c_travel_id description = `My new Description` ) )
            FAILED lt_failed.

        IF lt_failed IS INITIAL.
            COMMIT ENTITIES. out->write( `Description successfully updated` ).
        ELSE.
            ROLLBACK ENTITIES. out->write( `Error updating the description` ).
        ENDIF.
    endif.



  ENDMETHOD.
ENDCLASS.
