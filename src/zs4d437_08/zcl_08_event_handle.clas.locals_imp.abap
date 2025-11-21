*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_handler DEFINITION INHERITING FROM cl_abap_behavior_event_handler.
  PRIVATE SECTION.
METHODS travelCreated

 for ENTITY EVENT
     IMPORTING new_travel for travel~travelcreated.
ENDCLASS.
CLASS lcl_handler IMPLEMENTATION.
  METHOD travelcreated.

  ENDMETHOD.

ENDCLASS.
