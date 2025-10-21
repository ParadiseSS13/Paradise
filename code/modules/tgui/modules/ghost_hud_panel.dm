
/// Stores an instance of [/datum/ui_module/ghost_hud_panel] so that ghosts can use this to open their HUD panel.
GLOBAL_DATUM_INIT(ghost_hud_panel, /datum/ui_module/ghost_hud_panel, new)

/**
 * # Ghost HUD panel
 *
 * Allows ghosts to view a TGUI window which contains toggles for all HUD types available to them.
 */
/datum/ui_module/ghost_hud_panel
	name = "Ghost HUD Panel"
	/// Associative list to get the appropriate hud type based on the string passed from TGUI.
	var/list/hud_type_lookup = list(
		"medical" = DATA_HUD_MEDICAL_ADVANCED,
		"security" = DATA_HUD_SECURITY_ADVANCED,
		"diagnostic" = DATA_HUD_DIAGNOSTIC_ADVANCED,
		"pressure" = DATA_HUD_PRESSURE
	)

/datum/ui_module/ghost_hud_panel/ui_state(mob/user)
	return GLOB.observer_state

/datum/ui_module/ghost_hud_panel/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GhostHudPanel", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/ghost_hud_panel/ui_data(mob/dead/observer/ghost)
	var/list/data = list()
	for(var/hud in hud_type_lookup)
		data[hud] = (hud_type_lookup[hud] in ghost.data_hud_seen)
	data["ahud"] = ghost.antagHUD
	// Split radioactivity out as it isn't a true datahud
	data["radioactivity"] = ghost.ghost_flags & GHOST_SEE_RADS
	return data

/datum/ui_module/ghost_hud_panel/ui_act(action, list/params)
	if(..())
		return

	var/mob/dead/observer/ghost = usr
	. = TRUE

	switch(action)
		if("hud_on")
			var/hud_type = hud_type_lookup[params["hud_type"]]
			ghost.show_me_the_hud(hud_type)

		if("hud_off")
			var/hud_type = hud_type_lookup[params["hud_type"]]
			ghost.remove_the_hud(hud_type)

		if("toggle_rad")
			ghost.toggle_rad_view()

		if("ahud_on")
			if(!GLOB.configuration.general.allow_antag_hud && !ghost.client.holder)
				to_chat(ghost, "<span class='warning'>Admins have disabled this for this round.</span>")
				return FALSE
			if(jobban_isbanned(ghost, "AntagHUD"))
				to_chat(ghost, "<span class='danger'>You have been banned from using this feature.</span>")
				return FALSE
			// Check if this is the first time they're turning on Antag HUD.
			if(!check_rights(R_ADMIN | R_MOD, FALSE) && !ghost.is_roundstart_observer() && GLOB.configuration.general.restrict_antag_hud_rejoin && !ghost.has_ahudded())
				var/response = tgui_alert(ghost, "If you turn this on, you will not be able to take any part in the round.", "Are you sure you want to enable antag HUD?", list("Yes", "No"))
				if(response != "Yes")
					return FALSE

				ghost.ghost_flags &= ~(GHOST_CAN_REENTER | GHOST_RESPAWNABLE)
				REMOVE_TRAIT(ghost, TRAIT_RESPAWNABLE, GHOSTED)
				log_admin("[key_name(ghost)] has enabled antaghud as an observer and forfeited respawnability.")
				message_admins("[key_name(ghost)] has enabled antaghud as an observer and forfeited respawnability.")


			else if(ghost.is_roundstart_observer() && !ghost.has_ahudded())
				log_admin("[key_name(ghost)] has enabled antaghud for the first time as a roundstart observer, keeping respawnability.")

			GLOB.antag_hud_users |= ghost.ckey

			if(!check_rights(R_MOD | R_ADMIN | R_MENTOR, FALSE))
				// admins always get aobserve
				add_verb(ghost, list(/mob/dead/observer/proc/do_observe, /mob/dead/observer/proc/observe))

			ghost.antagHUD = TRUE
			for(var/datum/atom_hud/antag/H in GLOB.huds)
				H.add_hud_to(ghost)
			var/datum/atom_hud/data/human/malf_ai/H = GLOB.huds[DATA_HUD_MALF_AI]
			H.add_hud_to(ghost)

		if("ahud_off")
			ghost.antagHUD = FALSE
			for(var/datum/atom_hud/antag/H in GLOB.huds)
				H.remove_hud_from(ghost)
			var/datum/atom_hud/data/human/malf_ai/H = GLOB.huds[DATA_HUD_MALF_AI]
			H.remove_hud_from(ghost)
