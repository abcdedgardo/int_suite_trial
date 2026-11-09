FUNCTION z_kurs_insert.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_KURS) TYPE  ZKURS_TT
*"  EXPORTING
*"     VALUE(EV_COUNT) TYPE  I
*"     VALUE(EV_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------
DATA: lt_data_to_process TYPE ZKURS_TT,
      lv_total_rows      TYPE i.

  IF IT_KURS IS INITIAL.
    ev_count   = 0.
    ev_message = 'No data received. Internal table is empty.'.
    RETURN.
  ENDIF.

  lt_data_to_process = IT_KURS.
  lv_total_rows      = lines( lt_data_to_process ).

  LOOP AT lt_data_to_process ASSIGNING FIELD-SYMBOL(<fs_data>).
    IF <fs_data>-mandt IS INITIAL.
      <fs_data>-mandt = sy-mandt.
    ENDIF.

    IF <fs_data>-ZID_KURS IS INITIAL.
      ev_count   = 0.
      ev_message = |Error: Terdapat baris dengan ID kosong.|.
      RETURN.
    ENDIF.
  ENDLOOP.

  MODIFY ZKURS_ASING FROM TABLE @lt_data_to_process.

  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.

    ev_count   = lv_total_rows.
    ev_message = |Success: { lv_total_rows } baris data berhasil disimpan.|.
  ELSE.
    ROLLBACK WORK.

    ev_count   = 0.
    ev_message = 'Error: Gagal menyimpan data ke database (Database Error).'.
  ENDIF.
ENDFUNCTION.
