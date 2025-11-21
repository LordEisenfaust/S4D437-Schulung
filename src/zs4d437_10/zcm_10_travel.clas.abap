CLASS zcm_10_travel DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

    constants:
      begin of already_canceled,
        msgid type symsgid value 'Z10_TRAVEL',
        msgno type symsgno value '001',
        attr1 type scx_attrname value 'attr1',
        attr2 type scx_attrname value 'attr2',
        attr3 type scx_attrname value 'attr3',
        attr4 type scx_attrname value 'attr4',
      end of already_canceled.

          constants:
      begin of description_missing,
        msgid type symsgid value 'Z10_TRAVEL',
        msgno type symsgno value '003',
        attr1 type scx_attrname value 'attr1',
        attr2 type scx_attrname value 'attr2',
        attr3 type scx_attrname value 'attr3',
        attr4 type scx_attrname value 'attr4',
      end of description_missing.


    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key
        !previous LIKE previous OPTIONAL
        severity like if_abap_behv_message~m_severity optional.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_10_travel IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).
    if_t100_message~t100key = textid.
    if_abap_behv_message~m_severity = severity.

  ENDMETHOD.
ENDCLASS.
