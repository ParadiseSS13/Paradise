/datum/config_entry/flag/log_admin // log admin actions
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_adminchat	// log admin chat messages
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_game // log game events

/datum/config_entry/flag/log_mecha // log mech data

/datum/config_entry/flag/log_virus // log virology data

/datum/config_entry/flag/log_cloning // log cloning actions.

/datum/config_entry/flag/log_access // log login/logout

/datum/config_entry/flag/log_law // log lawchanges

/datum/config_entry/flag/log_attack // log attack messages

/datum/config_entry/flag/log_econ // log economy actions

/datum/config_entry/flag/log_manifest // log crew manifest to seperate file

/datum/config_entry/flag/log_say // log client say

/datum/config_entry/flag/log_ooc	// log OOC channel

/datum/config_entry/flag/log_whisper // log client whisper

/datum/config_entry/flag/log_emote // log emotes

/datum/config_entry/flag/log_prayer // log prayers

/datum/config_entry/flag/log_pda	// log pda messages

/datum/config_entry/flag/log_uplink // log uplink/spellbook/codex ciatrix purchases and refunds

/datum/config_entry/flag/log_telecomms // log telecomms messages

/datum/config_entry/flag/log_vote // log voting

/datum/config_entry/flag/log_shuttle // log shuttle related actions, ie shuttle computers, shuttle manipulator, emergency console

/datum/config_entry/flag/log_job_debug // log roundstart divide occupations debug information to a file

/datum/config_entry/flag/developer_express_start

/datum/config_entry/number/mc_tick_rate/high_pop_mc_mode_amount
	config_entry_value = 65

/datum/config_entry/number/mc_tick_rate/base_mc_tick_rate
	integer = FALSE
	config_entry_value = 1

/datum/config_entry/number/mc_tick_rate/disable_high_pop_mc_mode_amount
	config_entry_value = 60

/datum/config_entry/number/mc_tick_rate/high_pop_mc_tick_rate
	integer = FALSE
	config_entry_value = 1.1

/datum/config_entry/number/tick_limit_mc_init //SSinitialization throttling
	config_entry_value = TICK_LIMIT_MC_INIT_DEFAULT
	min_val = 0 //oranges warned us
	integer = FALSE

/datum/config_entry/number/warn_afk_minimum
	config_entry_value = 15

/datum/config_entry/number/auto_cryo_afk
	config_entry_value = 20

/datum/config_entry/number/auto_despawn_afk
	config_entry_value = 21

/datum/config_entry/string/githuburl
	config_entry_value = "https://www.github.com/tgstation/tgstation"

/datum/config_entry/string/wikiurl

/datum/config_entry/string/forumurl

/datum/config_entry/string/forum_link_url

/datum/config_entry/string/rulesurl

/datum/config_entry/string/discordurl

/datum/config_entry/string/discordforumurl

/datum/config_entry/string/donationsurl

/datum/config_entry/flag/ban_legacy_system

/datum/config_entry/string/banappeals

/datum/config_entry/number/ipintel_rating_bad

/datum/config_entry/flag/ipintel_whitelist

/datum/config_entry/string/ipintel_email

/datum/config_entry/number/ipintel_save_good

/datum/config_entry/number/ipintel_save_bad

/datum/config_entry/string/ipintel_domain

/datum/config_entry/flag/admin_legacy_system

/datum/config_entry/flag/use_exp_restrictions

/datum/config_entry/flag/use_exp_restrictions_admin_bypass

/datum/config_entry/flag/use_exp_tracking

/datum/config_entry/flag/allow_ai

/datum/config_entry/flag/load_jobs_from_txt

/datum/config_entry/string/medal_hub_address

/datum/config_entry/string/medal_hub_password

/datum/config_entry/flag/discord_webhooks_enabled

/datum/config_entry/str_list/discord_admin_webhook_urls

/datum/config_entry/str_list/discord_main_webhook_urls

/datum/config_entry/str_list/discord_mentor_webhook_urls

/datum/config_entry/number/discord_admin_role_id

/datum/config_entry/flag/discord_forward_all_ahelps

/datum/config_entry/flag/allow_holidays

/datum/config_entry/flag/disable_away_missions

/datum/config_entry/flag/disable_space_ruins

/datum/config_entry/number/extra_space_ruin_levels_min

/datum/config_entry/number/extra_space_ruin_levels_max

/datum/config_entry/number/lavaland_budget

/datum/config_entry/string/server_name

/datum/config_entry/flag/starlight

/datum/config_entry/flag/enable_night_shifts

/datum/config_entry/flag/randomize_shift_time

/datum/config_entry/flag/auto_profile

/datum/config_entry/number/shuttle_refuel_delay

/datum/config_entry/number/pregame_timestart

/datum/config_entry/number/vote_autotransfer_interval

/datum/config_entry/flag/continuous_rounds

/datum/config_entry/number/vote_period

/datum/config_entry/flag/ooc_allowed

/datum/config_entry/flag/auto_toggle_ooc_during_round

/datum/config_entry/flag/vote_no_default

/datum/config_entry/flag/allow_vote_restart

/datum/config_entry/flag/allow_vote_mode

/datum/config_entry/number/vote_delay

/datum/config_entry/flag/vote_no_dead

/datum/config_entry/number/byond_account_age_threshold

/datum/config_entry/flag/protect_roles_from_antagonist

/datum/config_entry/number/vote_autotransfer_initial

/datum/config_entry/flag/traitor_scaling

/datum/config_entry/flag/enable_gamemode_player_limit

/datum/config_entry/number/shadowling_max_age

/datum/config_entry/flag/assistant_maint

/datum/config_entry/flag/jobs_have_minimal_access

/datum/config_entry/flag/use_age_restriction_for_jobs

/datum/config_entry/flag/usewhitelist

/datum/config_entry/flag/usealienwhitelist

/datum/config_entry/flag/disable_karma

/datum/config_entry/number/revival_cloning

/datum/config_entry/number/round_abandon_penalty_period

/datum/config_entry/flag/reactionary_explosions

/datum/config_entry/number/walk_speed

/datum/config_entry/flag/ghost_interaction

/datum/config_entry/flag/disable_lobby_music

/datum/config_entry/flag/dooc_allowed

/datum/config_entry/flag/allow_admin_ooccolor

/datum/config_entry/flag/disable_ooc_emoji

/datum/config_entry/flag/looc_allowed

/datum/config_entry/string/server_suffix

/datum/config_entry/string/server

/datum/config_entry/flag/shutdown_on_reboot

/datum/config_entry/string/server_tag_line

/datum/config_entry/string/server_extra_features

/datum/config_entry/flag/log_hrefs

/datum/config_entry/flag/allow_drone_spawn

/datum/config_entry/string/centcom_ban_db_url

/datum/config_entry/string/forum_playerinfo_url

/datum/config_entry/flag/dsay_allowed

/datum/config_entry/flag/start_now_confirmation

/datum/config_entry/flag/guest_jobban

/datum/config_entry/flag/ban_legacy_system

/datum/config_entry/string/centcom_ban_db_url

/datum/config_entry/flag/popup_admin_pm

/datum/config_entry/flag/automute_on

/datum/config_entry/flag/antag_hud_allowed

/datum/config_entry/flag/antag_hud_restricted

/datum/config_entry/number/run_speed

/datum/config_entry/number/cubemonkeycap

/datum/config_entry/number/comms_password

/datum/config_entry/number/human_delay

/datum/config_entry/flag/bones_can_break

/datum/config_entry/flag/use_age_restriction_for_antags

/datum/config_entry/number/assistantratio

/datum/config_entry/number/player_overflow_cap

/datum/config_entry/string/overflow_server_url

/datum/config_entry/flag/disable_cid_warn_popup

/datum/config_entry/flag/log_access

/datum/config_entry/number/slime_delay

/datum/config_entry/number/animal_delay

/datum/config_entry/number/robot_delay

/datum/config_entry/number/max_maint_drones

/datum/config_entry/number/drone_build_time

/datum/config_entry/flag/default_laws

/datum/config_entry/flag/allow_Metadata

/datum/config_entry/number/auto_cryo_ssd_mins

/datum/config_entry/number/revival_brain_life

/datum/config_entry/number/alien_delay

/datum/config_entry/flag/revival_pod_plants

/datum/config_entry/str_list/event_delay_lower

/datum/config_entry/str_list/event_delay_upper

/datum/config_entry/str_list/event_first_run

/datum/config_entry/number/expected_round_length

/datum/config_entry/flag/humans_need_surnames

/datum/config_entry/number/max_loadout_points

/datum/config_entry/number/max_client_cid_history

/datum/config_entry/flag/ssd_warning

/datum/config_entry/string/resource_urls

/datum/config_entry/flag/check_randomizer

/datum/config_entry/string/ipintel_detailsurl

/datum/config_entry/number/ipintel_maxplaytime

/datum/config_entry/number/panic_bunker_threshold

/datum/config_entry/flag/disable_localhost_admin

/datum/config_entry/number/minimum_client_build

/datum/config_entry/number/gateway_delay

/datum/config_entry/number/traitor_objectives_amount

/datum/config_entry/number/list_afk_minimum

/datum/config_entry/flag/allow_random_events

/datum/config_entry/flag/forbid_singulo_possession

/datum/config_entry/str_list/overflow_whitelist

/datum/config_entry/flag/assistantlimit
