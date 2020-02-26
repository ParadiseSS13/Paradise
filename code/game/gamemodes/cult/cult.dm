var/global/list/all_cults = list()

/datum/game_mode
	var/list/datum/mind/cult = list()
	var/datum/cult_objectives/cult_objs = new
	var/cultist_count = 0
	var/cult_rise_thresshold = 4
	var/cult_ascend_thresshold = 5
	var/cult_risen = FALSE
	var/cult_ascendent = FALSE

/proc/iscultist(mob/living/M as mob)
	return istype(M) && M.mind && SSticker && SSticker.mode && (M.mind in SSticker.mode.cult)

/proc/is_convertable_to_cult(datum/mind/mind)
	if(!mind)
		return FALSE
	if(!mind.current)
		return FALSE
	if(iscultist(mind.current))
		return TRUE //If they're already in the cult, assume they are convertable
	if(mind.isholy)
		return FALSE
	if(ishuman(mind.current))
		var/mob/living/carbon/human/H = mind.current
		if(ismindshielded(H)) //mindshield protects against conversions unless removed
			return FALSE
//	if(mind.offstation_role) cant convert offstation roles such as ghost spawns
//		return FALSE Commented out until we can figure out why offstation_role is getting set to TRUE on normal crew
	if(issilicon(mind.current))
		return FALSE //can't convert machines, that's ratvar's thing
	if(isguardian(mind.current))
		var/mob/living/simple_animal/hostile/guardian/G = mind.current
		if(!iscultist(G.summoner))
			return FALSE //can't convert it unless the owner is converted
	if(isgolem(mind.current))
		return FALSE
	return TRUE

/proc/is_sacrifice_target(datum/mind/mind)
	if(SSticker.mode && mind == SSticker.mode.cult_objs.obj_sac.target)
		return TRUE
	return FALSE

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Internal Affairs Agent", "Security Officer", "Warden", "Detective", "Security Pod Pilot", "Head of Security", "Captain", "Head of Personnel", "Blueshield", "Nanotrasen Representative", "Magistrate", "Brig Physician", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer")
	protected_jobs = list()
	required_players = 30
	required_enemies = 3
	recommended_enemies = 4

	var/const/min_cultists_to_start = 3
	var/const/max_cultists_to_start = 4

/datum/game_mode/cult/announce()
	to_chat(world, "<B>The current game mode is - Cult!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the offer rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with holy water reverts them to whatever CentComm-allowed faith they had.</B>")

/datum/game_mode/cult/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	..()
	var/list/cultists_possible = get_players_for_role(ROLE_CULTIST)

	for(var/cultists_number = 1 to max_cultists_to_start)
		if(!cultists_possible.len)
			break
		var/datum/mind/cultist = pick(cultists_possible)
		cultists_possible -= cultist
		cult += cultist
		cultist.restricted_roles = restricted_jobs
		cultist.special_role = SPECIAL_ROLE_CULTIST
	..()
	return (cult.len > 0)


/datum/game_mode/cult/post_setup()
	modePlayer += cult

	for(var/datum/mind/cult_mind in cult)
		SEND_SOUND(cult_mind.current, 'sound/ambience/antag/bloodcult.ogg')
		equip_cultist(cult_mind.current)
		cult_mind.current.faction |= "cult"
		if(cult_mind.assigned_role == "Clown")
			to_chat(cult_mind.current, "<span class='cultitalic'>A dark power has allowed you to overcome your clownish nature, letting you wield weapons without harming yourself.</span>")
			cult_mind.current.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(cult_mind.current)
		add_cult_actions(cult_mind)
		update_cult_icons_added(cult_mind)
		to_chat(cult_mind.current, "<span class='cultitalic'>You catch a glimpse of the Realm of [SSticker.cultdat.entity_name], [SSticker.cultdat.entity_title3]. You now see how flimsy the world is, you see that it should be open to the knowledge of [SSticker.cultdat.entity_name].</span>")
	cult_objs.setup()
	..()

/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/H, metal = TRUE)
	if(!istype(H))
		return

	. += cult_give_item(/obj/item/melee/cultblade/dagger, H)
	if(metal)
		. += cult_give_item(/obj/item/stack/sheet/runed_metal/ten, H)
	to_chat(H, "These will help you start the cult on this station. Use them well, and remember - you are not the only one.</span>")

/datum/game_mode/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/mob)
	var/list/slots = list(
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
	)

	var/T = new item_path(mob)
	var/item_name = initial(item_path.name)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(mob, "<span class='userdanger'>Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1).</span>")
		return FALSE
	else
		to_chat(mob, "<span class='danger'>You have a [item_name] in your [where].</span>")
		return TRUE

/datum/game_mode/proc/add_cultist(datum/mind/cult_mind)
	if(!istype(cult_mind))
		return FALSE
	if(!(cult_mind in cult))
		cult += cult_mind
		cult_mind.current.faction |= "cult"
		cult_mind.special_role = SPECIAL_ROLE_CULTIST
		if(cult_mind.assigned_role == "Clown")
			to_chat(cult_mind.current, "<span class='cultitalic'>A dark power has allowed you to overcome your clownish nature, letting you wield weapons without harming yourself.</span>")
			cult_mind.current.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(cult_mind.current)
		//SEND_SOUND(cult_mind.current, 'sound/ambience/antag/bloodcult.ogg')
		cult_mind.current.create_attack_log("<span class='danger'>Has been converted to the cult!</span>")
		if(jobban_isbanned(cult_mind.current, ROLE_CULTIST) || jobban_isbanned(cult_mind.current, ROLE_SYNDICATE))
			replace_jobbanned_player(cult_mind.current, ROLE_CULTIST)
		if(!cult_objs.status)
			cult_objs.setup()
		update_cult_icons_added(cult_mind)
		add_cult_actions(cult_mind)
		/*
		check_cult_size(cultist_count += 1)
		if(cult_risen)
			rise(cult_mind.current)
			if(cult_ascendent)
				ascend(cult_mind.current)
		*/
		return TRUE

/datum/game_mode/proc/check_cult_size()
	//if(cultist_count > cult_rise_thresshold && !cult_risen)//if equal or more than cult_rise_thresshold
	if(cultist_count == 1)
		for(var/datum/mind/B in cult)
			SEND_SOUND(B.current, 'sound/hallucinations/i_see_you2.ogg')
			to_chat(B.current, "<span class='cultlarge'>The veil weakens as your cult grows, your eyes begin to glow...</span>")
			addtimer(CALLBACK(src, .proc/rise, B.current), 200)
			cult_risen = TRUE
//	if(cultist_count > cult_ascend_thresshold && !cult_ascendent)
	if(cultist_count == 2)
		for(var/datum/mind/B in cult)
			if(B.current)
				SEND_SOUND(B.current, 'sound/hallucinations/im_here1.ogg')
				to_chat(B.current, "<span class='cultlarge'>Your cult is ascendent and the red harvest approaches - you cannot hide your true nature for much longer!!")
				addtimer(CALLBACK(src, .proc/ascend, B.current), 200)
		cult_ascendent = TRUE


/datum/game_mode/proc/rise(cultist)
	if(ishuman(cultist))
		var/mob/living/carbon/human/H = cultist
		H.change_eye_color("#FF0000", FALSE)
		H.update_eyes()
		H.update_body()
		to_chat(world, "<span class='warning'>The cult has Risen!</FONT></span>") //replace with CC announcement

/datum/game_mode/proc/ascend(cultist, y_offset)
	if(ishuman(cultist))
		var/mob/living/carbon/human/H = cultist
		new /obj/effect/temp_visual/cult/sparks(get_turf(H), H.dir)
		//var/istate = pick("cult_halo1","cult_halo2")
		var/mutable_appearance/new_halo_overlay = mutable_appearance('icons/effects/effects.dmi', "cult_halo1", -MISC_LAYER)
		H.overlays_standing[ABOVE_HUD_LAYER] = new_halo_overlay
		//H.Shift(NORTH, y_offset + 4)
		H.apply_overlay(ABOVE_HUD_LAYER)
		to_chat(world, "<span class='warning'>The cult has Ascended!</FONT></span>") //replace with CC announcement


/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = 1)
	if(cult_mind in cult)
		cult -= cult_mind
		to_chat(cult_mind.current, "<span class='danger'>An unfamiliar white light flashes through your mind, cleansing the taint of the dark one and the memories of your time as his servant with it.</span>")
		cult_mind.current.faction -= "cult"
		cult_mind.special_role = null
		for(var/datum/action/innate/cult/C in cult_mind.current.actions)
			qdel(C)
		update_cult_icons_removed(cult_mind)
		var/mob/living/carbon/human/H = cult_mind.current
		H.update_eyes()
		H.remove_overlay(ABOVE_HUD_LAYER)
		H.update_body()
		check_cult_size(cultist_count -= 1)
		//cultist_removed()
		if(show_message)
			for(var/mob/M in viewers(cult_mind.current))
				to_chat(M, "<FONT size = 3>[cult_mind.current] looks like [cult_mind.current.p_they()] just reverted to [cult_mind.current.p_their()] old faith!</FONT>")


/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = huds[ANTAG_HUD_CULT]
	if(cult_mind.current)
		culthud.join_hud(cult_mind.current)
		set_antag_hud(cult_mind.current, "hudcultist")

/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = huds[ANTAG_HUD_CULT]
	if(cult_mind.current)
		culthud.leave_hud(cult_mind.current)
		set_antag_hud(cult_mind.current, null)

/datum/game_mode/proc/add_cult_actions(datum/mind/cult_mind)
	if(cult_mind.current)
		var/datum/action/innate/cult/comm/C = new
		var/datum/action/innate/cult/check_progress/D = new
		C.Grant(cult_mind.current)
		D.Grant(cult_mind.current)
		if(ishuman(cult_mind.current))
			var/datum/action/innate/cult/blood_magic/magic = new
			magic.Grant(cult_mind.current)
			var/datum/action/innate/cult/use_dagger/dagger = new
			dagger.Grant(cult_mind.current)
		cult_mind.current.update_action_buttons(TRUE)

/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!is_convertable_to_cult(player.mind))
			ucs += player.mind
	return ucs

/atom/proc/cult_log(var/message)
	investigate_log(message, "cult")


/datum/game_mode/cult/declare_completion()
	if(cult_objs.status == NARSIE_HAS_RISEN)
		feedback_set_details("round_end_result","cult win - cult win")
		to_chat(world, "<span class='danger'> <FONT size = 3>The cult wins! It has succeeded in summoning [SSticker.cultdat.entity_name]!</FONT></span>")
	else if(cult_objs.status == NARSIE_HAS_FALLEN)
		feedback_set_details("round_end_result","cult draw - narsie died, nobody wins")
		to_chat(world, "<span class='danger'> <FONT size = 3>Nobody wins! [SSticker.cultdat.entity_name] was summoned, but banished!</FONT></span>")
	else
		feedback_set_details("round_end_result","cult loss - staff stopped the cult")
		to_chat(world, "<span class='warning'> <FONT size = 3>The staff managed to stop the cult!</FONT></span>")

	var/endtext
	endtext += "<br><b>The cultists' objectives were:</b>"
	endtext += "<br>[cult_objs.obj_sac.explanation_text] - "
	if(!cult_objs.obj_sac.check_completion())
		endtext += "<font color='red'>Fail.</font>"
	else
		endtext += "<font color='green'><B>Success!</B></font>"
		endtext += "<br>[cult_objs.obj_summon.explanation_text] - "
		if(!cult_objs.obj_summon.check_completion())
			endtext+= "<font color='red'>Fail.</font>"
		else
			endtext += "<font color='green'><B>Success!</B></font>"

	to_chat(world, endtext)
	..()