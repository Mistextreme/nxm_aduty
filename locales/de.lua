Locales = Locales or {}

Locales.de = {
    -- ===== Generic =====
    ['title']                       = 'Aduty',
    ['no_permission']               = 'Du hast keine Berechtigung',
    ['no_permission_for_cmd']       = 'Keine Berechtigung für /%s',
    ['no_permission_for_ui']        = 'Keine Berechtigung für das Verwaltungs-UI',
    ['cooldown_wait']               = 'Cooldown: noch %ds',

    -- ===== Aduty Toggle =====
    ['aduty_entered']               = 'Du bist nun im Aduty',
    ['aduty_left']                  = 'Du hast den Aduty verlassen',
    ['aduty_no_outfit_for_sex']     = 'Für dein Geschlecht ist kein Outfit hinterlegt.',
    ['aduty_force_off']             = 'Du wurdest von %s aus dem Aduty entfernt',
    ['aduty_job_restored']          = 'Dein Job %s (Rang %s) wurde wiederhergestellt',

    -- ===== Commands: /adlist =====
    ['list_none_active']            = 'Aktuell ist niemand im Aduty.',
    ['list_header']                 = '%d Spieler im Aduty:',
    ['list_row']                    = '[%d] %s — %s',

    -- ===== Commands: /adoff =====
    ['off_usage']                   = 'Verwendung: /%s <playerId>',
    ['off_not_in_aduty']            = 'Spieler %d ist nicht im Aduty.',
    ['off_player_offline']          = 'Spieler-ID %d ist nicht online',
    ['off_success']                 = '%s wurde aus dem Aduty entfernt.',

    -- ===== Commands: /adlog =====
    ['log_none_for_player']         = 'Keine Logs für %s gefunden',
    ['log_none']                    = 'Keine Log-Einträge vorhanden.',
    ['log_header_filtered']         = 'Logs (%d) - %s',
    ['log_header']                  = 'Letzte %d Logs:',

    -- ===== Discord Embed Titles =====
    ['discord_entered']             = '🟢 Aduty Betreten',
    ['discord_left']                = '🔴 Aduty Verlassen',
    ['discord_restore']             = 'Aduty Rejoin Wiederherstellung',
    ['discord_field_player']        = 'Spieler',
    ['discord_field_id']            = 'ID',
    ['discord_field_oldjob']        = 'Alter Job',
    ['discord_field_oldgrade']      = 'Alter Rang',
    ['discord_field_newjob']        = 'Neuer Job',
    ['discord_field_rank']          = 'Rang',
    ['discord_field_grade']         = 'Grade',
    ['discord_field_job']           = 'Job',
    ['discord_field_restored_job']  = 'Wiederhergestellter Job',
    ['discord_footer']              = 'Aduty Logs',

    -- ===== UI Strings =====
    ['ui_nav_ranks']                = 'Ränge',
    ['ui_nav_list']                 = 'Aktive',
    ['ui_nav_logs']                 = 'Logs',
    ['ui_search_rank']              = 'Rang suchen…',
    ['ui_search_player']            = 'Spieler suchen…',
    ['ui_search_log']               = 'Name / ID / Aktion…',
    ['ui_btn_new_rank']             = '＋ Neuer Rang',
    ['ui_btn_close']                = 'Schließen (ESC)',
    ['ui_btn_refresh']              = '↻ Aktualisieren',

    ['ui_empty_title']              = 'Kein Rang ausgewählt',
    ['ui_empty_text']               = 'Wähle links einen Rang aus oder erstelle einen neuen.',

    ['ui_field_rank_key']           = 'Rang-Key',
    ['ui_field_rank_key_hint']      = '(ACE: staff.aduty.<key>)',
    ['ui_field_label']              = 'Anzeige-Name',
    ['ui_field_priority']           = 'Priorität',
    ['ui_field_rank_key_ph']        = 'z.B. moderator',
    ['ui_field_label_ph']           = 'z.B. Moderator',

    ['ui_setting_god']              = 'God-Mode',
    ['ui_setting_heal']             = 'Auto-Heal',
    ['ui_setting_armor']            = 'Auto-Armor',
    ['ui_setting_blip_color']       = 'Blip-Farbe',
    ['ui_setting_blip_sprite']      = 'Blip-Icon',

    ['ui_tab_male']                 = '♂ Männlich',
    ['ui_tab_female']               = '♀ Weiblich',

    ['ui_btn_import']               = '📥 Übernehmen',
    ['ui_btn_import_tip']           = 'Übernimm dein aktuelles Outfit',
    ['ui_btn_copy']                 = '↔ Spiegeln',
    ['ui_btn_copy_tip']             = 'Werte vom anderen Geschlecht kopieren',
    ['ui_btn_preview']              = '👁 Live',
    ['ui_btn_preview_tip']          = 'Live-Vorschau am Charakter',
    ['ui_btn_preview_reset']        = '↺',
    ['ui_btn_preview_reset_tip']    = 'Live-Vorschau zurücksetzen',
    ['ui_btn_3d']                   = '🎬 3D-Vorschau',
    ['ui_btn_3d_tip']               = '3D-Vorschau mit Kamera',

    ['ui_btn_delete']               = '🗑 Löschen',
    ['ui_btn_save']                 = '💾 Speichern',

    ['ui_list_title']               = '👥 Aktive Aduty Spieler',
    ['ui_list_count']               = '%d aktiv',
    ['ui_list_count_empty']         = 'Aktuell ist niemand im Aduty.',
    ['ui_list_count_no_match']      = 'Keine Treffer für deinen Filter.',
    ['ui_list_btn_force_off']       = '⏏ Force-Off',
    ['ui_list_btn_logs']            = '📜 Logs',

    ['ui_logs_title']               = '📜 Aktivitäts-Logs',
    ['ui_logs_count']               = '%d Eintr%s',
    ['ui_logs_count_singular']      = 'ag',
    ['ui_logs_count_plural']        = 'äge',
    ['ui_logs_empty']               = 'Keine Einträge gefunden.',

    ['ui_3d_title']                 = '3D-Vorschau',
    ['ui_3d_hint_drag']             = '🖱 LMB ziehen: drehen',
    ['ui_3d_hint_zoom']             = '🖲 Rad: zoomen',
    ['ui_3d_hint_esc']              = 'ESC: schließen',
    ['ui_3d_btn_close']             = '✕ Beenden',

    ['ui_confirm_title']            = 'Bestätigen',
    ['ui_confirm_text']             = 'Bist du sicher?',
    ['ui_confirm_ok']               = 'Bestätigen',
    ['ui_confirm_cancel']           = 'Abbrechen',

    ['ui_confirm_delete_title']     = 'Rang löschen?',
    ['ui_confirm_delete_text']      = '"%s" wird unwiderruflich gelöscht.',
    ['ui_confirm_forceoff_title']   = 'Aus dem Aduty entfernen?',
    ['ui_confirm_forceoff_text']    = '%s (ID %d) wird sofort aus dem Aduty geworfen.',

    ['ui_toast_saved']              = 'Gespeichert',
    ['ui_toast_deleted']            = 'Gelöscht',
    ['ui_toast_nothing_delete']     = 'Nichts zu löschen',
    ['ui_toast_key_missing']        = 'Rang-Key fehlt',
    ['ui_toast_imported_male']      = 'Übernommen (männlich)',
    ['ui_toast_imported_female']    = 'Übernommen (weiblich)',
    ['ui_toast_copied_to_male']     = 'Werte nach männlich kopiert',
    ['ui_toast_copied_to_female']   = 'Werte nach weiblich kopiert',
    ['ui_toast_preview_active']     = 'Live-Vorschau aktiv',
    ['ui_toast_preview_reset']      = 'Vorschau zurückgesetzt',
    ['ui_toast_forceoff_sent']      = 'Force-Off gesendet',
    ['ui_toast_list_refreshed']     = 'Liste aktualisiert',
    ['ui_toast_outfit_load_failed'] = 'Outfit konnte nicht geladen werden',

    ['ui_empty_no_ranks']           = 'Noch keine Ränge angelegt.',
    ['ui_empty_no_matches']         = 'Keine Treffer.',

    -- ===== Chat suggestions =====
    ['suggest_list']                = 'Zeigt alle Spieler die gerade im Aduty sind',
    ['suggest_log']                 = 'Zeigt die letzten Aduty-Logs',
    ['suggest_forceoff']            = 'Zwingt einen Spieler aus dem Aduty',
    ['suggest_arg_playerid']        = 'Server-ID des Spielers',
    ['suggest_arg_playerid_opt']    = 'Optional: Server-ID des Spielers',

    -- ===== Blip =====
    ['blip_name']                   = '[Aduty] %s (%s)',
}
