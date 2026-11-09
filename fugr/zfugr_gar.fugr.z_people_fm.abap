FUNCTION z_people_fm.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_PEOPLE) TYPE  ZTT_PEOPLE
*"  EXPORTING
*"     VALUE(EV_COUNT) TYPE  I
*"     VALUE(EV_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------

  DATA: lt_data_to_process TYPE ztt_people,
        lv_total_rows      TYPE i.

  " 1. Validasi awal: Pastikan tabel input tidak kosong
  IF it_people IS INITIAL.
    ev_count   = 0.
    ev_message = 'No data received. Internal table is empty.'.
    RETURN.
  ENDIF.

  lt_data_to_process = it_people.
  lv_total_rows      = lines( lt_data_to_process ).

  " 2. Validasi & Sanitasi Data (Contoh: Pastikan MANDT terisi otomatis)
  LOOP AT lt_data_to_process ASSIGNING FIELD-SYMBOL(<fs_data>).
    IF <fs_data>-mandt IS INITIAL.
      <fs_data>-mandt = sy-mandt.
    ENDIF.

    " Opsional: Cek jika ada username yang kosong
    IF <fs_data>-zusername IS INITIAL.
      ev_count   = 0.
      ev_message = |Error: Terdapat baris dengan Username kosong.|.
      RETURN.
    ENDIF.
  ENDLOOP.

  " 3. Eksekusi Massal (Bulk Operation)
  " Gunakan MODIFY untuk Upsert (Insert baru atau Update jika key sudah ada)
  " Atau gunakan INSERT ... FROM TABLE jika murni ingin menolak data kembar.
  MODIFY zpeople_tbl FROM TABLE @lt_data_to_process.

  IF sy-subrc = 0.
    " Commit agar data tersimpan permanen dan langsung sinkron
    COMMIT WORK AND WAIT.

    ev_count   = lv_total_rows.
    ev_message = |Success: { lv_total_rows } baris data berhasil disimpan.|.
  ELSE.
    " Rollback jika terjadi kegagalan sistem database
    ROLLBACK WORK.

    ev_count   = 0.
    ev_message = 'Error: Gagal menyimpan data ke database (Database Error).'.
  ENDIF.
ENDFUNCTION.
