-- =================================================================
-- NXM_Aduty  v2.1
-- =================================================================

CREATE TABLE IF NOT EXISTS `aduty_outfits` (
    `rank_key`     VARCHAR(64)  NOT NULL,
    `label`        VARCHAR(128) NOT NULL,
    `priority`     INT          NOT NULL DEFAULT 100,
    `male_data`    LONGTEXT     NULL,
    `female_data`  LONGTEXT     NULL,
    `god_mode`     TINYINT(1)   NOT NULL DEFAULT 0,
    `auto_heal`    TINYINT(1)   NOT NULL DEFAULT 1,
    `auto_armor`   TINYINT(1)   NOT NULL DEFAULT 1,
    `blip_color`   INT          NOT NULL DEFAULT 3,
    `blip_sprite`  INT          NOT NULL DEFAULT 1,
    `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`rank_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `aduty_active` (
    `identifier`     VARCHAR(64) NOT NULL,
    `original_job`   VARCHAR(64) NOT NULL,
    `original_grade` INT         NOT NULL DEFAULT 0,
    `started_at`     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Audit-Log (für /adlog)
CREATE TABLE IF NOT EXISTS `aduty_logs` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT,
    `identifier`   VARCHAR(64)  NOT NULL,
    `player_name`  VARCHAR(128) NOT NULL,
    `action`       VARCHAR(32)  NOT NULL,  -- 'enter' | 'leave' | 'force_off' | 'outfit_save' | 'outfit_delete' | 'restore'
    `rank_key`     VARCHAR(64)  NULL,
    `actor`        VARCHAR(128) NULL,      -- bei force_off / outfit_*: wer die Aktion ausgelöst hat
    `meta`         LONGTEXT     NULL,      -- JSON: zusätzliche Details
    `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_identifier` (`identifier`),
    KEY `idx_player`     (`player_name`),
    KEY `idx_created`    (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Schema-Migration (falls Tabelle schon existierte ohne neue Spalten)
ALTER TABLE `aduty_outfits` ADD COLUMN IF NOT EXISTS `god_mode`    TINYINT(1) NOT NULL DEFAULT 0;
ALTER TABLE `aduty_outfits` ADD COLUMN IF NOT EXISTS `auto_heal`   TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE `aduty_outfits` ADD COLUMN IF NOT EXISTS `auto_armor`  TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE `aduty_outfits` ADD COLUMN IF NOT EXISTS `blip_color`  INT        NOT NULL DEFAULT 3;
ALTER TABLE `aduty_outfits` ADD COLUMN IF NOT EXISTS `blip_sprite` INT        NOT NULL DEFAULT 1;

-- Fix für Rows die durch frühe Speicherungen mit blip_sprite = 0 in der DB landeten
UPDATE `aduty_outfits` SET `blip_sprite` = 1 WHERE `blip_sprite` IS NULL OR `blip_sprite` <= 0;
UPDATE `aduty_outfits` SET `blip_color`  = 3 WHERE `blip_color`  IS NULL OR `blip_color`  <= 0;
