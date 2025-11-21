CLASS lsc_Z00_R_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z00_R_TRAVEL IMPLEMENTATION.

  METHOD save_modified.

    LOOP AT update-item ASSIGNING FIELD-SYMBOL(<update>) WHERE %control-zzClassZ00 = if_abap_behv=>mk-on.
      UPDATE z00_tritem SET zzclassz00 = @<update>-zzClassZ00
      WHERE item_uuid = @<update>-itemuuid.
    ENDLOOP.

    LOOP AT create-item ASSIGNING FIELD-SYMBOL(<create>) WHERE %control-zzClassZ00 = if_abap_behv=>mk-on.
      UPDATE z00_tritem SET zzclassz00 = @<create>-zzClassZ00
      WHERE item_uuid = @<create>-itemuuid.
    ENDLOOP.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
