*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_Handler DEFINITION
INHERITING FROM cl_abap_Behavior_event_handler.

  PRIVATE SECTION.
    METHODS on_travel_created
    FOR ENTITY EVENT IMPORTING new_Trips
    FOR Travel~travelCreated.

ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_travel_created.

    DATA newlog TYPE TABLE FOR CREATE /lrn/437_i_travellog.

    newlog = CORRESPONDING #( new_trips ).

    MODIFY ENTITIES OF /lrn/437_i_travellog
    ENTITY TravelLog
    CREATE AUTO FILL CID
    FIELDS ( agencyId travelId origin )
    WITH newlog.

  ENDMETHOD.

ENDCLASS.
