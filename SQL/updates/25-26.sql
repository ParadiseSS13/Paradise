# Add TTS voice seed preference
ALTER TABLE `characters` ADD `tts_seed` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT 'Xenia' AFTER `uplink_pref`;
