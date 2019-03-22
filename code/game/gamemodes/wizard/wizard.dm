/datum/game_mode
	var/list/datum/mind/wizards = list()

/datum/game_mode/wizard
	name = "wizard"
	config_tag = "wizard"
	required_players = 20
	required_enemies = 1
	recommended_enemies = 1
	free_golems_disabled = TRUE

	var/use_huds = FALSE
	var/finished = FALSE
	var/making_mage = FALSE
	var/mages_made = 1
	var/time_checked = 0
	var/players_per_mage = 25
	var/list/summoned_items = list() //list of summoned guns/magic, deleted when a new wizard is spawned

	var/multi_wizard_drifting = FALSE
	var/delay_per_mage = 4200 // Every 7 minutes by default
	var/time_till_chaos = 18000 // Half-hour in

/datum/game_mode/wizard/announce()
	to_chat(world, "<B>The current game mode is - Wizard!</B>")
	to_chat(world, "<B>There is a <font color='red'>SPACE WIZARD</font> on the station. Help defeat them!</B>")


/datum/game_mode/wizard/can_start()//This could be better, will likely have to recode it later
	if(!..())
		return 0
	var/list/datum/mind/possible_wizards = get_players_for_role(ROLE_WIZARD)
	if(possible_wizards.len==0)
		return 0
	var/datum/mind/wizard = pick(possible_wizards)

	wizards += wizard
	modePlayer += wizard
	wizard.assigned_role = SPECIAL_ROLE_WIZARD //So they aren't chosen for other jobs.
	wizard.special_role = SPECIAL_ROLE_WIZARD
	wizard.original = wizard.current
	if(wizardstart.len == 0)
		to_chat(wizard.current, "<span class='danger'>A starting location for you could not be found, please report this bug!</span>")
		return 0
	return 1

/datum/game_mode/wizard/pre_setup()
	for(var/datum/mind/wiz in wizards)
		wiz.current.loc = pick(wizardstart)
	..()
	return 1


/datum/game_mode/wizard/post_setup()
	for(var/datum/mind/wizard in wizards)
		log_game("[key_name(wizard)] has been selected as a Wizard")
		forge_wizard_objectives(wizard)
		//learn_basic_spells(wizard.current)
		equip_wizard(wizard.current)
		name_wizard(wizard.current)
		greet_wizard(wizard)
		if(use_huds)
			update_wiz_icons_added(wizard)

	..()

/datum/game_mode/proc/remove_wizard(datum/mind/wizard_mind)
	if(wizard_mind in wizards)
		ticker.mode.wizards -= wizard_mind
		wizard_mind.special_role = null
		wizard_mind.current.create_attack_log("<span class='danger'>De-wizarded</span>")
		wizard_mind.current.spellremove(wizard_mind.current)
		wizard_mind.current.faction = list("Station")
		if(issilicon(wizard_mind.current))
			to_chat(wizard_mind.current, "<span class='userdanger'>You have been turned into a robot! You can feel your magical powers fading away...</span>")
		else
			to_chat(wizard_mind.current, "<span class='userdanger'>You have been brainwashed! You are no longer a wizard.</span>")
		ticker.mode.update_wiz_icons_removed(wizard_mind)

/datum/game_mode/proc/update_wiz_icons_added(datum/mind/wiz_mind)
	var/datum/atom_hud/antag/wizhud = huds[ANTAG_HUD_WIZ]
	wizhud.join_hud(wiz_mind.current)
	set_antag_hud(wiz_mind.current, ((wiz_mind in wizards) ? "hudwizard" : "apprentice"))


/datum/game_mode/proc/update_wiz_icons_removed(datum/mind/wiz_mind)
	var/datum/atom_hud/antag/wizhud = huds[ANTAG_HUD_WIZ]
	wizhud.leave_hud(wiz_mind.current)
	set_antag_hud(wiz_mind.current, null)

/datum/game_mode/proc/forge_wizard_objectives(var/datum/mind/wizard)
	var/datum/objective/wizchaos/wiz_objective = new
	wiz_objective.owner = wizard
	wizard.objectives += wiz_objective
	return


/datum/game_mode/proc/name_wizard(mob/living/carbon/human/wizard_mob)
	//Allows the wizard to choose a custom name or go with a random one. Spawn 0 so it does not lag the round starting.
	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	spawn(0)
		var/newname = sanitize(copytext(input(wizard_mob, "You are the Space Wizard. Would you like to change your name to something else?", "Name change", randomname) as null|text,1,MAX_NAME_LEN))

		if(!newname)
			newname = randomname

		wizard_mob.real_name = newname
		wizard_mob.name = newname
		if(wizard_mob.mind)
			wizard_mob.mind.name = newname
	return


/datum/game_mode/proc/greet_wizard(var/datum/mind/wizard, var/you_are=1)
	addtimer(CALLBACK(wizard.current, /mob/.proc/playsound_local, null, 'sound/ambience/antag/ragesmages.ogg', 100, 0), 30)
	if(you_are)
		to_chat(wizard.current, "<span class='danger'>You are the Space Wizard!</span>")
	to_chat(wizard.current, "<B>The Space Wizard Federation has given you the following tasks:</B>")

	var/obj_count = 1
	for(var/datum/objective/objective in wizard.objectives)
		to_chat(wizard.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return


/*/datum/game_mode/proc/learn_basic_spells(mob/living/carbon/human/wizard_mob)
	if(!istype(wizard_mob))
		return
	if(!config.feature_object_spell_system)
		wizard_mob.verbs += /client/proc/jaunt
		wizard_mob.mind.special_verbs += /client/proc/jaunt
	else
		wizard_mob.spell_list += new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(usr)
*/

/datum/game_mode/proc/equip_wizard(mob/living/carbon/human/wizard_mob)
	if(!istype(wizard_mob))
		return

	//So zards properly get their items when they are admin-made.
	qdel(wizard_mob.wear_suit)
	qdel(wizard_mob.head)
	qdel(wizard_mob.shoes)
	qdel(wizard_mob.r_hand)
	qdel(wizard_mob.r_store)
	qdel(wizard_mob.l_store)

	wizard_mob.equip_to_slot_or_del(new /obj/item/radio/headset(wizard_mob), slot_l_ear)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(wizard_mob), slot_w_uniform)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(wizard_mob), slot_shoes)
	if(!isplasmaman(wizard_mob)) //handled in the species file for plasmen on the afterjob equip proc for now
		wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(wizard_mob), slot_wear_suit)
		wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(wizard_mob), slot_head)
	wizard_mob.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(wizard_mob), slot_back)
	wizard_mob.equip_to_slot_or_del(new /obj/item/storage/box/survival(wizard_mob), slot_in_backpack)
	wizard_mob.equip_to_slot_or_del(new /obj/item/teleportation_scroll(wizard_mob), slot_r_store)
	var/obj/item/spellbook/spellbook = new /obj/item/spellbook(wizard_mob)
	spellbook.owner = wizard_mob
	wizard_mob.equip_to_slot_or_del(spellbook, slot_r_hand)

	wizard_mob.faction = list("wizard")

	wizard_mob.dna.species.after_equip_job(null, wizard_mob)

	to_chat(wizard_mob, "You will find a list of available spells in your spell book. Choose your magic arsenal carefully.")
	to_chat(wizard_mob, "The spellbook is bound to you, and others cannot use it.")
	to_chat(wizard_mob, "In your pockets you will find a teleport scroll. Use it as needed.")
	wizard_mob.mind.store_memory("<B>Remember:</B> do not forget to prepare your spells.")
	wizard_mob.update_icons()
	wizard_mob.gene_stability += DEFAULT_GENE_STABILITY //magic
	return 1

/datum/game_mode/wizard/check_finished()
	var/wizards_alive = 0
	// Accidental pun!
	var/wizard_cap = num_players_started() / players_per_mage

	for(var/datum/mind/wizard in wizards)
		if(isnull(wizard.current))
			continue
		if(!istype(wizard.current, /mob/living/carbon))
			if(istype(get_area(wizard.current), /area/wizard_station)) // We don't want people camping other wizards
				to_chat(wizard.current, "<span class='warning'>If there aren't any admins on and another wizard is camping you in the wizard lair, report them on the forums</span>")
				message_admins("[wizard.current] was transformed in the wizard lair, another wizard is likely camping")
				end_squabble(get_area(wizard.current))
			continue
		if(istype(wizard.current, /mob/living/carbon/brain))
			if(istype(get_area(wizard.current), /area/wizard_station)) // We don't want people camping other wizards
				to_chat(wizard.current, "<span class='warning'>If there aren't any admins on and another wizard is camping you in the wizard lair, report them on the forums</span>")
				message_admins("[wizard.current] was brainified in the wizard lair, another wizard is likely camping")
				end_squabble(get_area(wizard.current))
			continue
		if(wizard.current.stat == DEAD && !isskeleton(wizard.current)) //Liches arent dead until they are gibbed or dusted
			if(istype(get_area(wizard.current), /area/wizard_station)) // We don't want people camping other wizards
				to_chat(wizard.current, "<span class='warning'>If there aren't any admins on and another wizard is camping you in the wizard lair, report them on the forums</span>")
				message_admins("[wizard.current] died in the wizard lair, another wizard is likely camping")
				end_squabble(get_area(wizard.current))
			continue
		if(wizard.current.stat == UNCONSCIOUS)
			if(wizard.current.health < 0)
				if(istype(get_area(wizard.current), /area/wizard_station))
					to_chat(wizard.current, "<span class='warning'>If there aren't any admins on and another wizard is camping you in the wizard lair, report them on the forums</span>")
					message_admins("[wizard.current] went into crit in the wizard lair, another wizard is likely camping")
					end_squabble(get_area(wizard.current))
		if(wizard.current.client && wizard.current.client.is_afk() > 10 * 60 * 10) // 10 minutes
			to_chat(wizard.current, "<span class='warning'><font size='4'>The Space Wizard Federation is upset with your performance and have terminated your employment.</font></span>")
			wizard.current.gib() // Let's keep the round moving
			continue
		if(!wizard.current.client && !isskeleton(wizard.current))
			continue // Could just be a bad connection, so SSD wiz's shouldn't be gibbed over it, but they're not "alive" either
		wizards_alive++

	if(wizards_alive && multi_wizard_drifting)
		if(!time_checked)
			time_checked = world.time
		if(world.time > time_till_chaos && world.time > time_checked + delay_per_mage && (mages_made < wizard_cap))
			time_checked = world.time
			addtimer(CALLBACK(src, .proc/make_more_mages), rand(200, 600))
	else if(!wizards_alive)
		if(wizards.len >= wizard_cap)
			finished = TRUE
			return TRUE
		else
			addtimer(CALLBACK(src, .proc/make_more_mages), rand(200, 600))
	return ..()

// To silence all struggles within the wizard's lair
/datum/game_mode/wizard/proc/end_squabble(var/area/wizard_station/A)
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

/datum/game_mode/wizard/proc/make_more_mages()
	if(making_mage || SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		return FALSE
	making_mage = TRUE
	var/list/candidates = list()
	var/mob/dead/observer/harry = null
	message_admins("SWF is still pissed, sending another wizard.")
	for(var/obj/item/I in summoned_items) //Wipe all summoned items so the new wiz isnt fucked over by a previous one.
		I.visible_message("<span class='warning'>The [I] suddenly disappears!</span>")
		summoned_items -= I
		qdel(I)
	if(multi_wizard_drifting)
		candidates = get_candidate_ghosts(ROLE_WIZARD) //GOTTA GO FAST dont bother asking ghosts just spawn the next ragin mage
	else
		candidates = pollCandidates("Do you want to play as a Space Wizard?", ROLE_WIZARD, 1)
	if(!candidates.len)
		making_mage = FALSE
		return FALSE
	else
		harry = pick(candidates)
		making_mage = 0
		if(harry)
			var/mob/living/carbon/human/new_character = makeBody(harry)
			new_character.mind.make_Wizard() // This puts them at the wizard spawn, worry not
			mages_made++
			return TRUE
		else
			log_runtime(EXCEPTION("The candidates list for wizard contained non-observer entries!"), src)
			return FALSE

// ripped from -tg-'s wizcode, because whee lets make a very general proc for a very specific gamemode
// This probably wouldn't do half bad as a proc in __HELPERS
// Lemme know if this causes species to mess up spectacularly or anything
/datum/game_mode/wizard/proc/makeBody(var/mob/dead/observer/G)
	if(!G || !G.key) return // Let's not steal someone's soul here

	var/mob/living/carbon/human/new_character = new(pick(latejoin))

	G.client.prefs.copy_to(new_character)

	new_character.key = G.key

	return new_character

/datum/game_mode/wizard/declare_completion()
	if(finished)
		feedback_set_details("round_end_result","wizard loss - wizards killed")
		to_chat(world, "<span class='warning'><FONT size = 3><B> The crew has managed to hold off the wizard attack! The Space Wizard Federation has been taught a lesson they will not soon forget!</B></FONT></span>")
		..()
	return 1


/datum/game_mode/proc/auto_declare_completion_wizard()
	if(wizards.len)
		var/text = "<br><font size=3><b>the wizards/witches were:</b></font>"

		for(var/datum/mind/wizard in wizards)

			text += "<br><b>[wizard.key]</b> was <b>[wizard.name]</b> ("
			if(wizard.current)
				if(wizard.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(wizard.current.real_name != wizard.name)
					text += " as <b>[wizard.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"

			var/count = 1
			var/wizardwin = 1
			for(var/datum/objective/objective in wizard.objectives)
				if(objective.check_completion())
					text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
					feedback_add_details("wizard_objective","[objective.type]|SUCCESS")
				else
					text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
					feedback_add_details("wizard_objective","[objective.type]|FAIL")
					wizardwin = 0
				count++

			if(wizard.current && wizard.current.stat != DEAD && wizardwin)
				text += "<br><font color='green'><B>The wizard was successful!</B></font>"
				feedback_add_details("wizard_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The wizard has failed!</B></font>"
				feedback_add_details("wizard_success","FAIL")
			if(wizard.spell_list)
				text += "<br><B>[wizard.name] used the following spells: </B>"
				var/i = 1
				for(var/obj/effect/proc_holder/spell/S in wizard.spell_list)
					text += "[S.name]"
					if(wizard.spell_list.len > i)
						text += ", "
					i++
			text += "<br>"

		to_chat(world, text)
	return TRUE

//OTHER PROCS

//To batch-remove wizard spells. Linked to mind.dm
/mob/proc/spellremove(mob/M)
	if(!mind)
		return
	for(var/obj/effect/proc_holder/spell/spell_to_remove in mind.spell_list)
		qdel(spell_to_remove)
		mind.spell_list -= spell_to_remove

//To batch-remove mob spells.
/mob/proc/mobspellremove(mob/M)
	for(var/obj/effect/proc_holder/spell/spell_to_remove in mob_spell_list)
		qdel(spell_to_remove)
		mob_spell_list -= spell_to_remove

/*Checks if the wizard can cast spells.
Made a proc so this is not repeated 14 (or more) times.*/
/mob/proc/casting()
//Removed the stat check because not all spells require clothing now.
	if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
		to_chat(usr, "I don't feel strong enough without my robe.")
		return 0
	if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
		to_chat(usr, "I don't feel strong enough without my sandals.")
		return 0
	if(!istype(usr:head, /obj/item/clothing/head/wizard))
		to_chat(usr, "I don't feel strong enough without my hat.")
		return 0
	else
		return 1

/proc/iswizard(mob/living/M as mob)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.wizards)