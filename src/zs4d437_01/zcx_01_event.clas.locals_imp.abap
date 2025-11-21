*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations


CLASS lcl_handler DEFINITION INHERITING FROM cl_abap_behavior_event_handler.

  PRIVATE SECTION.

    METHODS on_Travel_created FOR ENTITY EVENT IMPORTING it_travels FOR Travel~TravelCreated.

ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_travel_created.



  ENDMETHOD.

ENDCLASS.
