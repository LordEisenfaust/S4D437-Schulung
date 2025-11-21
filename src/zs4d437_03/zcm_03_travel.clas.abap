CLASS zcm_03_travel DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    constants:
      begin of already_canceled,
        msgid type symsgid value '/LRN/S4D437',
        msgno type symsgno value '130',
        attr1 type scx_attrname value '',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of already_canceled.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
*        !previous LIKE previous OPTIONAL .
        severity LIKE if_abap_behv_message~m_severity OPTIONAL.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_03_travel IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
*    previous = previous
    ).
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    IF severity IS INITIAL.
    if_abap_behv_message~m_severity = if_abap_behv_message~severity-error.
    ELSE.
    if_abap_behv_message~m_severity = severity.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
