/datum/game_mode/wizard/raginmages
	name = "ragin' mages"
	config_tag = "raginmages"
	required_players = 20
	use_huds = 1
	but_wait_theres_more = 1
	var/max_mages = 0
	var/making_mage = FALSE
	var/mages_made = 1
	var/time_checked = 0
	var/players_per_mage = 10 // If the admin wants to tweak things or something
	var/delay_per_mage = 4200 // Every 7 minutes by default
	var/time_till_chaos = 18000 // Half-hour in

/datum/game_mode/wizard/raginmages/announce()
	to_chat(world, "<B>The current game mode is - Ragin' Mages!</B>")
	to_chat(world, "<B>The <font color='red'>Space Wizard Federation</font> is pissed, crew must help defeat all the Space Wizards invading the station!</B>")

/datum/game_mode/wizard/raginmages/greet_wizard(var/datum/mind/wizard, var/you_are=1)
	if(you_are)
		to_chat(wizard.current, "<span class='danger'>You are the Space Wizard!</span>")
	to_chat(wizard.current, "<B>The Space Wizard Federation has given you the following tasks:</B>")

	var/obj_count = 1
	to_chat(wizard.current, "<b>Supreme Objective</b>: Make sure the station pays for its actions against our diplomats. We might send more Wizards to the station if the situation is not developing in our favour.")
	for(var/datum/objective/objective in wizard.objectives)
		to_chat(wizard.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return

/datum/game_mode/wizard/raginmages/check_finished()
	var/wizards_alive = 0
	var/wizard_cap = CEILING((num_players_started() / players_per_mage), 1)
	max_mages = wizard_cap
	for(var/datum/mind/wizard in wizards)
		if(isnull(wizard.current))
			continue
		if(!istype(wizard.current,/mob/living/carbon))
			if(istype(get_area(wizard.current), /area/wizard_station)) // We don't want people camping other wizards
				to_chat(wizard.current, "<span class='warning'>If there aren't any admins on and another wizard is camping you in the wizard lair, report them on the forums</span>")
				message_admins("[wizard.current] was transformed in the wizard lair, another wizard is likely camping")
				end_squabble(get_area(wizard.current))
			continue
		if(istype(wizard.current,/mob/living/carbon/brain))
			if(istype(get_area(wizard.current), /area/wizard_station)) // We don't want people camping other wizards
				to_chat(wizard.current, "<span class='warning'>If there aren't any admins on and another wizard is camping you in the wizard lair, report them on the forums</span>")
				message_admins("[wizard.current] was brainified in the wizard lair, another wizard is likely camping")
				end_squabble(get_area(wizard.current))
			continue
		if(wizard.current.stat==DEAD)
			if(istype(get_area(wizard.current), /area/wizard_station)) // We don't want people camping other wizards
				to_chat(wizard.current, "<span class='warning'>If there aren't any admins on and another wizard is camping you in the wizard lair, report them on the forums</span>")
				message_admins("[wizard.current] died in the wizard lair, another wizard is likely camping")
				end_squabble(get_area(wizard.current))
			continue
		if(wizard.current.stat==UNCONSCIOUS)
			if(wizard.current.health < 0)
				if(istype(get_area(wizard.current), /area/wizard_station))
					to_chat(wizard.current, "<span class='warning'>If there aren't any admins on and another wizard is camping you in the wizard lair, report them on the forums</span>")
					message_admins("[wizard.current] went into crit in the wizard lair, another wizard is likely camping")
					end_squabble(get_area(wizard.current))
				else
					to_chat(wizard.current, "<span class='warning'><font size='4'>The Space Wizard Federation is upset with your performance and have terminated your employment.</font></span>")
					wizard.current.gib() // *REAL* ACTION!! *REAL* DRAMA!! *REAL* BLOODSHED!!
			continue
		if(wizard.current.client && wizard.current.client.is_afk() > 10 * 60 * 10) // 10 minutes
			to_chat(wizard.current, "<span class='warning'><font size='4'>The Space Wizard Federation is upset with your performance and have terminated your employment.</font></span>")
			wizard.current.gib() // Let's keep the round moving
			continue
		if(!wizard.current.client)
			continue // Could just be a bad connection, so SSD wiz's shouldn't be gibbed over it, but they're not "alive" either
		wizards_alive++

	if(wizards_alive)
		if(!time_checked) time_checked = world.time
		if(world.time > time_till_chaos && world.time > time_checked + delay_per_mage && (mages_made < wizard_cap))
			time_checked = world.time
			make_more_mages()
	else
		if(wizards.len >= wizard_cap)
			finished = 1
			return 1
		else
			make_more_mages()
	return ..()

// To silence all struggles within the wizard's lair
/datum/game_mode/wizard/raginmages/proc/end_squabble(var/area/wizard_station/A)
	if(!istype(A)) return // You could probably do mean things with this otherwise
	var/list/marked_for_death = list()
	for(var/mob/living/L in A) // To hit non-wizard griefers
		if(L.mind || L.client)
			marked_for_death |= L
	for(var/datum/mind/M in wizards)
		if(istype(M.current) && istype(get_area(M.current), /area/wizard_station))
			mages_made -= 1
			wizards -= M // No, you don't get to occupy a slot
			marked_for_death |= M.current
	for(var/mob/living/L in marked_for_death)
		if(L.stat == CONSCIOUS) // Probably a troublemaker - I'd like to see YOU fight when unconscious
			to_chat(L, "<span class='userdanger'>STOP FIGHTING.</span>")
		L.ghostize()
		if(istype(L, /mob/living/carbon/brain))
			// diediedie
			var/mob/living/carbon/brain/B = L
			if(istype(B.loc, /obj/item))
				qdel(B.loc)
			if(B && B.container)
				qdel(B.container)
		if(L)
			qdel(L)
	for(var/obj/item/spellbook/B in A)
		// No goodies for you
		qdel(B)

/datum/game_mode/wizard/raginmages/proc/make_more_mages()
	if(making_mage || SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		return FALSE
	making_mage = TRUE

	var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_wizard")
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a raging Space Wizard?", ROLE_WIZARD, TRUE, poll_time = 20 SECONDS, source = source)
	var/mob/dead/observer/harry = null
	message_admins("SWF is still pissed, sending another wizard - [max_mages - mages_made] left.")

	if(!candidates.len)
		message_admins("This is awkward, sleeping until another mage check..")
		making_mage = FALSE
		sleep(300)
		return
	else
		harry = pick(candidates)
		making_mage = FALSE
		if(harry)
			var/mob/living/carbon/human/new_character= makeBody(harry)
			new_character.mind.make_Wizard() // This puts them at the wizard spawn, worry not
			mages_made++
			return TRUE
		else
			log_runtime(EXCEPTION("The candidates list for ragin' mages contained non-observer entries!"), src)
			return FALSE

// ripped from -tg-'s wizcode, because whee lets make a very general proc for a very specific gamemode
// This probably wouldn't do half bad as a proc in __HELPERS
// Lemme know if this causes species to mess up spectacularly or anything
/datum/game_mode/wizard/raginmages/proc/makeBody(var/mob/dead/observer/G)
	if(!G || !G.key)
		return // Let's not steal someone's soul here
	var/mob/living/carbon/human/new_character = new(pick(GLOB.latejoin))
	G.client.prefs.copy_to(new_character)
	new_character.key = G.key
	return new_character

/datum/game_mode/wizard/raginmages/declare_completion()
	if(finished)
		SSticker.mode_result = "raging wizard loss - wizard killed"
		to_chat(world, "<span class='warning'><FONT size = 3><B> The crew has managed to hold off the Wizard attack! The Space Wizard Federation has been taught a lesson they will not soon forget!</B></FONT></span>")
	..(1)
