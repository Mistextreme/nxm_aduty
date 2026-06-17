Locales = Locales or {}

Locales.en = {
    -- ===== Generic =====
    ['title']                       = 'Aduty',
    ['no_permission']               = 'You do not have permission',
    ['no_permission_for_cmd']       = 'No permission for /%s',
    ['no_permission_for_ui']        = 'No permission to open the management UI',
    ['cooldown_wait']               = 'Cooldown: %ds remaining',

    -- ===== Aduty Toggle =====
    ['aduty_entered']               = 'You are now in Aduty',
    ['aduty_left']                  = 'You left the Aduty',
    ['aduty_no_outfit_for_sex']     = 'No outfit configured for your gender.',
    ['aduty_force_off']             = 'You were forced out of Aduty by %s',
    ['aduty_job_restored']          = 'Your job %s (grade %s) was restored',

    -- ===== Commands: /adlist =====
    ['list_none_active']            = 'Nobody is currently in Aduty.',
    ['list_header']                 = '%d player(s) in Aduty:',
    ['list_row']                    = '[%d] %s — %s',

    -- ===== Commands: /adoff =====
    ['off_usage']                   = 'Usage: /%s <playerId>',
    ['off_not_in_aduty']            = 'Player %d is not in Aduty.',
    ['off_player_offline']          = 'Player ID %d is not online',
    ['off_success']                 = '%s was removed from Aduty.',

    -- ===== Commands: /adlog =====
    ['log_none_for_player']         = 'No logs found for %s',
    ['log_none']                    = 'No log entries available.',
    ['log_header_filtered']         = 'Logs (%d) - %s',
    ['log_header']                  = 'Last %d logs:',

    -- ===== Discord Embed Titles =====
    ['discord_entered']             = '🟢 Aduty Entered',
    ['discord_left']                = '🔴 Aduty Left',
    ['discord_restore']             = 'Aduty Rejoin Restore',
    ['discord_field_player']        = 'Player',
    ['discord_field_id']            = 'ID',
    ['discord_field_oldjob']        = 'Previous Job',
    ['discord_field_oldgrade']      = 'Previous Grade',
    ['discord_field_newjob']        = 'New Job',
    ['discord_field_rank']          = 'Rank',
    ['discord_field_grade']         = 'Grade',
    ['discord_field_job']           = 'Job',
    ['discord_field_restored_job']  = 'Restored Job',
    ['discord_footer']              = 'Aduty Logs',

    -- ===== UI Strings (sent via NUI on open) =====
    ['ui_nav_ranks']                = 'Ranks',
    ['ui_nav_list']                 = 'Active',
    ['ui_nav_logs']                 = 'Logs',
    ['ui_search_rank']              = 'Search rank…',
    ['ui_search_player']            = 'Search player…',
    ['ui_search_log']               = 'Name / ID / Action…',
    ['ui_btn_new_rank']             = '＋ New Rank',
    ['ui_btn_close']                = 'Close (ESC)',
    ['ui_btn_refresh']              = '↻ Refresh',

    ['ui_empty_title']              = 'No rank selected',
    ['ui_empty_text']               = 'Pick a rank on the left or create a new one.',

    ['ui_field_rank_key']           = 'Rank-Key',
    ['ui_field_rank_key_hint']      = '(ACE: staff.aduty.<key>)',
    ['ui_field_label']              = 'Display Name',
    ['ui_field_priority']           = 'Priority',
    ['ui_field_rank_key_ph']        = 'e.g. moderator',
    ['ui_field_label_ph']           = 'e.g. Moderator',

    ['ui_setting_god']              = 'God-Mode',
    ['ui_setting_heal']             = 'Auto-Heal',
    ['ui_setting_armor']            = 'Auto-Armor',
    ['ui_setting_blip_color']       = 'Blip Color',
    ['ui_setting_blip_sprite']      = 'Blip Icon',

    ['ui_tab_male']                 = '♂ Male',
    ['ui_tab_female']               = '♀ Female',

    ['ui_btn_import']               = '📥 Import Current',
    ['ui_btn_import_tip']           = 'Import your currently worn outfit',
    ['ui_btn_copy']                 = '↔ Mirror',
    ['ui_btn_copy_tip']             = 'Copy values from the other gender',
    ['ui_btn_preview']              = '👁 Live',
    ['ui_btn_preview_tip']          = 'Live preview on character',
    ['ui_btn_preview_reset']        = '↺',
    ['ui_btn_preview_reset_tip']    = 'Reset live preview',
    ['ui_btn_3d']                   = '🎬 3D Preview',
    ['ui_btn_3d_tip']               = '3D preview with camera',

    ['ui_btn_delete']               = '🗑 Delete',
    ['ui_btn_save']                 = '💾 Save',

    ['ui_list_title']               = '👥 Active Aduty Players',
    ['ui_list_count']               = '%d active',
    ['ui_list_count_empty']         = 'Nobody is currently in Aduty.',
    ['ui_list_count_no_match']      = 'No matches for your filter.',
    ['ui_list_btn_force_off']       = '⏏ Force-Off',
    ['ui_list_btn_logs']            = '📜 Logs',

    ['ui_logs_title']               = '📜 Activity Logs',
    ['ui_logs_count']               = '%d entr%s',
    ['ui_logs_count_singular']      = 'y',
    ['ui_logs_count_plural']        = 'ies',
    ['ui_logs_empty']               = 'No entries found.',

    ['ui_3d_title']                 = '3D Preview',
    ['ui_3d_hint_drag']             = '🖱 LMB drag: rotate',
    ['ui_3d_hint_zoom']             = '🖲 Wheel: zoom',
    ['ui_3d_hint_esc']              = 'ESC: close',
    ['ui_3d_btn_close']             = '✕ Close',

    ['ui_confirm_title']            = 'Confirm',
    ['ui_confirm_text']             = 'Are you sure?',
    ['ui_confirm_ok']               = 'Confirm',
    ['ui_confirm_cancel']           = 'Cancel',

    ['ui_confirm_delete_title']     = 'Delete rank?',
    ['ui_confirm_delete_text']      = '"%s" will be permanently deleted.',
    ['ui_confirm_forceoff_title']   = 'Remove from Aduty?',
    ['ui_confirm_forceoff_text']    = '%s (ID %d) will be forced out of Aduty immediately.',

    ['ui_toast_saved']              = 'Saved',
    ['ui_toast_deleted']            = 'Deleted',
    ['ui_toast_nothing_delete']     = 'Nothing to delete',
    ['ui_toast_key_missing']        = 'Rank-Key missing',
    ['ui_toast_imported_male']      = 'Imported (male)',
    ['ui_toast_imported_female']    = 'Imported (female)',
    ['ui_toast_copied_to_male']     = 'Values copied to male',
    ['ui_toast_copied_to_female']   = 'Values copied to female',
    ['ui_toast_preview_active']     = 'Live preview active',
    ['ui_toast_preview_reset']      = 'Preview reset',
    ['ui_toast_forceoff_sent']      = 'Force-Off sent',
    ['ui_toast_list_refreshed']     = 'List refreshed',
    ['ui_toast_outfit_load_failed'] = 'Could not load outfit',

    ['ui_empty_no_ranks']           = 'No ranks created yet.',
    ['ui_empty_no_matches']         = 'No matches.',

    -- ===== Chat suggestions =====
    ['suggest_list']                = 'Shows all players currently in Aduty',
    ['suggest_log']                 = 'Shows the latest Aduty logs',
    ['suggest_forceoff']            = 'Forces a player out of Aduty',
    ['suggest_arg_playerid']        = 'Server ID of the player',
    ['suggest_arg_playerid_opt']    = 'Optional: server ID of the player',

    -- ===== Blip =====
    ['blip_name']                   = '[Aduty] %s (%s)',  -- name, rank_label
}
