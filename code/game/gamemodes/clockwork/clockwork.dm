GLOBAL_LIST_EMPTY(all_clockers)

/datum/game_mode
	/// A list of all minds currently in the cult
	var/list/datum/mind/clockwork_cult = list()
	var/datum/clockwork_objectives/clocker_objs = new
	/// Does the clockers have significant power stored
	var/power_reveal = FALSE
	/// Does the cult have halos
	var/crew_reveal = FALSE

	/// How many power need to be in supply to reveal
	var/power_reveal_number
	/// How many crew need to be converted to reveal
	var/crew_reveal_number
	/// Used for CentCom announcement when reached crew limit conversion
	var/reveal_percent

/proc/isclocker(mob/living/M)
	return istype(M) && M.mind && SSticker && SSticker.mode && (M.mind in SSticker.mode.clockwork_cult)

/proc/is_convertable_to_clocker(datum/mind/mind)
	if(!mind)
		return FALSE
	if(!mind.current)
		return FALSE
	if(iscultist(mind.current))
		return FALSE // Damn Narsie and his servants
	if(isclocker(mind.current))
		return TRUE //If they're already in the cult, assume they are convertable
	if(mind.isholy)
		return FALSE
	if(ishuman(mind.current))
		var/mob/living/carbon/human/H = mind.current
		if(ismindshielded(H)) //mindshield protects against conversions unless removed
			return FALSE
	if(mind.offstation_role)
		return FALSE
	if(issilicon(mind.current))
		return FALSE //Can't be converted by platform. Have to use a clock slab as an emag.
	if(isguardian(mind.current))
		var/mob/living/simple_animal/hostile/guardian/G = mind.current
		if(!isclocker(G.summoner))
			return FALSE //can't convert it unless the owner is converted
	return TRUE

/proc/adjust_clockwork_power(amount)
	GLOB.clockwork_power += amount
	SSticker.mode.check_power_reveal()
	SSticker.mode.clocker_objs.power_check()

/datum/game_mode/clockwork
	name = "Clockwork Cult"
	config_tag = "clockwork"
	restricted_jobs = list("Chaplain", "AI", "Cyborg", "Internal Affairs Agent", "Security Officer", "Security Cadet", "Warden", "Detective", "Security Pod Pilot", "Head of Security", "Captain", "Head of Personnel", "Blueshield", "Nanotrasen Representative", "Magistrate", "Brig Physician", "Nanotrasen Navy Officer", "Nanotrasen Navy Field Officer", "Special Operations Officer", "Supreme Commander", "Syndicate Officer")
	protected_jobs = list()
	required_players = 30
	required_enemies = 3
	recommended_enemies = 4

	var/const/max_clockers_to_start = 4

/datum/game_mode/clockwork/announce()
	to_chat(world, "<B>The current game mode is - Clockwork Cult!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a clockwork cult!<BR>\nClockers - complete your objectives. Convert crewmembers to your cause by using the credence structure. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with holy water reverts them to whatever CentComm-allowed faith they had.</B>")

/datum/game_mode/clockwork/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/clockers_possible = get_players_for_role(ROLE_CLOCKER)
	for(var/clockers_number in 1 to max_clockers_to_start)
		if(!length(clockers_possible))
			break
		var/datum/mind/clocker = pick(clockers_possible)
		clockers_possible -= clocker
		clockwork_cult += clocker
		clocker.restricted_roles = restricted_jobs
		clocker.special_role = SPECIAL_ROLE_CLOCKER
	return (length(clockwork_cult) > 0)

/datum/game_mode/clockwork/post_setup()
	modePlayer += clockwork_cult
	clocker_objs.setup()

	for(var/datum/mind/clockwork_mind in clockwork_cult)
		SEND_SOUND(clockwork_mind.current, 'sound/ambience/antag/clockcult.ogg')
		to_chat(clockwork_mind.current, CLOCK_GREETING)
		equip_clocker(clockwork_mind.current)
		clockwork_mind.current.faction |= "clockwork_cult"
		var/datum/objective/serveclock/obj = new
		obj.owner = clockwork_mind
		clockwork_mind.objectives += obj

		if(clockwork_mind.assigned_role == "Clown")
			to_chat(clockwork_mind.current, "<span class='clockitalic'>A dark power has allowed you to overcome your clownish nature, letting you wield weapons without harming yourself.</span>")
			clockwork_mind.current.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(clockwork_mind.current)

		add_clock_actions(clockwork_mind)
		update_clock_icons_added(clockwork_mind)
		clocker_objs.study(clockwork_mind.current)
	clockwork_threshold_check()
	addtimer(CALLBACK(src, .proc/clockwork_threshold_check), 2 MINUTES) // Check again in 2 minutes for latejoiners
	. = ..()

/**
  * Decides at the start of the round how many conversions are needed to reveal or how many power supplied to reveal.
  *
  * The number is decided by (Percentage * (Players - clockers)), so for example at 110 players it would be 16 conversions for rise. (0.15 * (110 - 4))
  * These values change based on population because 20 clockers are MUCH more powerful if there's only 50 players, compared to 120.
  *
  * Below 100 players, [CLOCK_POWER_REVEAL_LOW] and [CLOCK_CREW_REVEAL_LOW] are used.
  * Above 100 players, [CLOCK_POWER_REVEAL_HIGH] and [CLOCK_CREW_REVEAL_HIGH] are used.
  */
/datum/game_mode/proc/clockwork_threshold_check()
	var/players = length(GLOB.player_list)
	var/clockers = get_clockers() // Don't count the starting clockers towards the number of needed conversions
	if(players >= CLOCK_POPULATION_THRESHOLD)
		// Highpop
		reveal_percent = CLOCK_CREW_REVEAL_HIGH
		clocker_objs.power_goal = 1200 + length(GLOB.player_list)*CLOCK_POWER_PER_CREW_HIGH
		power_reveal_number = round(clocker_objs.power_goal * 0.67) // 2/3 of power goal
		crew_reveal_number = round(CLOCK_CREW_REVEAL_HIGH * (players - clockers),1)
	else
		// Lowpop
		reveal_percent = CLOCK_CREW_REVEAL_LOW
		clocker_objs.power_goal = 1200 + length(GLOB.player_list)*CLOCK_POWER_PER_CREW_LOW
		power_reveal_number = round(clocker_objs.power_goal * 0.67) // 2/3 of power goal
		crew_reveal_number = round(CLOCK_CREW_REVEAL_LOW * (players - clockers),1)
	add_game_logs("Clockwork Cult power/crew reveal numbers: [power_reveal_number]/[crew_reveal_number].")

/**
  * Returns the current number of clockers and constructs.
  *
  * Returns the number of clockers and constructs in a list ([1] = Clockers, [2] = Constructs), or as one combined number.
  *
  * * separate - Should the number be returned in two separate values (Humans and Constructs) or as one?
  */
/datum/game_mode/proc/get_clockers(separate = FALSE)
	var/clockers = 0
	var/constructs = 0
	for(var/I in clockwork_cult)
		var/datum/mind/M = I
		if(ishuman(M.current) && !M.current.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
			clockers++
		else if(isconstruct(M.current) && isclocker(M.current))
			constructs++
	if(separate)
		return list(clockers, constructs)
	else
		return clockers + constructs

/datum/game_mode/proc/equip_clocker(mob/living/carbon/human/H, metal = TRUE)
	if(!istype(H))
		return
	. += clock_give_item(/obj/item/clockwork/clockslab, H)
	if(metal)
		. += clock_give_item(/obj/item/stack/sheet/brass/ten, H)
	to_chat(H, "<span class='clock'>These will help you start the cult on this station. Use them well, and remember - you are not the only one.</span>")

/datum/game_mode/proc/clock_give_item(obj/item/item_path, mob/living/carbon/human/H)
	var/list/slots = list(
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store)
	var/T = new item_path(H)
	var/item_name = initial(item_path.name)
	var/where = H.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(H, "<span class='userdanger'>Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1).</span>")
		return FALSE
	else
		to_chat(H, "<span class='danger'>You have a [item_name] in your [where].</span>")
		return TRUE


/datum/game_mode/proc/add_clocker(datum/mind/clock_mind)
	if(!istype(clock_mind))
		return FALSE

	if(!reveal_percent) // If the rise/ascend thresholds haven't been set (non-cult rounds)
		clocker_objs.setup()
		clockwork_threshold_check()

	if(!(clock_mind in clockwork_cult))
		clockwork_cult += clock_mind
		clock_mind.current.faction |= "clockwork_cult"
		clock_mind.special_role = SPECIAL_ROLE_CLOCKER

		if(clock_mind.assigned_role == "Clown")
			to_chat(clock_mind.current, "<span class='clockitalic'>A dark power has allowed you to overcome your clownish nature, letting you wield weapons without harming yourself.</span>")
			clock_mind.current.mutations.Remove(CLUMSY)
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(clock_mind.current)
		SEND_SOUND(clock_mind.current, 'sound/ambience/antag/clockcult.ogg')
		add_conversion_logs(clock_mind.current, "converted to the clockwork cult")

		if(jobban_isbanned(clock_mind.current, ROLE_CLOCKER) || jobban_isbanned(clock_mind.current, ROLE_CULTIST) || jobban_isbanned(clock_mind.current, ROLE_SYNDICATE))
			replace_jobbanned_player(clock_mind.current, ROLE_CLOCKER)
		if(!clocker_objs.clock_status && ishuman(clock_mind.current))
			clocker_objs.setup()
		update_clock_icons_added(clock_mind)
		add_clock_actions(clock_mind)
		var/datum/objective/serveclock/obj = new
		obj.owner = clock_mind
		clock_mind.objectives += obj

		adjust_clockwork_power(CLOCK_POWER_CONVERT)

		if(power_reveal)
			powered(clock_mind.current)
		if(crew_reveal)
			clocked(clock_mind.current)
		check_clock_reveal()
		clocker_objs.study(clock_mind.current)
		return TRUE

/datum/game_mode/proc/check_power_reveal()
	if(power_reveal)
		return
	if((GLOB.clockwork_power >= power_reveal_number) && !power_reveal)
		power_reveal = TRUE
		for(var/datum/mind/M in clockwork_cult)
			if(!M.current || !ishuman(M.current))
				continue
			SEND_SOUND(M.current, 'sound/hallucinations/i_see_you2.ogg')
			to_chat(M.current, "<span class='clocklarge'>The veil begins to stutter in fear as the power of Ratvar grows, your hands begin to glow...</span>")
			addtimer(CALLBACK(src, .proc/powered, M.current), 20 SECONDS)

/datum/game_mode/proc/check_clock_reveal()
	if(crew_reveal)
		return
	var/clocker_players = get_clockers()
	if((clocker_players >= crew_reveal_number) && !crew_reveal)
		crew_reveal = TRUE
		clocker_objs.obj_demand.clockers_get = TRUE
		for(var/datum/mind/M in clockwork_cult)
			if(!M.current)
				continue
			to_chat(M.current, "<span class='clocklarge'>The army of my servants have grown. Now it will be easier...</span>")
			if(!clocker_objs.obj_demand.check_completion())
				to_chat(M.current, "<span class='clock'>But there's still more tasks to do.</span>")
			else
				clocker_objs.ratvar_is_ready()
			SEND_SOUND(M.current, 'sound/hallucinations/im_here1.ogg')
			if(!ishuman(M.current))
				continue
			to_chat(M.current, "<span class='clocklarge'>Your cult gets bigger as the clocked harvest approaches - you cannot hide your true nature for much longer!")
			addtimer(CALLBACK(src, .proc/clocked, M.current), 20 SECONDS)
		GLOB.command_announcement.Announce("На вашей станции обнаружена внепространственная активность, связанная с Заводным культом Ратвара. Данные свидетельствуют о том, что в ряды культа обращено около [reveal_percent * 100]% экипажа станции. Служба безопасности получает право свободно применять летальную силу против культистов. Прочий персонал должен быть готов защищать себя и свои рабочие места от нападений культистов (в том числе используя летальную силу в качестве крайней меры самообороны), но не должен выслеживать культистов и охотиться на них. Погибшие члены экипажа должны быть оживлены и деконвертированы, как только ситуация будет взята под контроль.", "Отдел Центрального Командования по делам высших измерений.", 'sound/AI/commandreport.ogg')

/datum/game_mode/proc/powered(clocker)
	if(ishuman(clocker) && isclocker(clocker))
		var/mob/living/carbon/human/H = clocker
		H.update_inv_gloves()
		ADD_TRAIT(H, CLOCK_HANDS, CLOCK_TRAIT)

/datum/game_mode/proc/clocked(clocker)
	if(ishuman(clocker) && isclocker(clocker))
		var/mob/living/carbon/human/H = clocker
		new /obj/effect/temp_visual/ratvar/sparks(get_turf(H), H.dir)
		H.update_halo_layer()


/datum/game_mode/proc/remove_clocker(datum/mind/clock_mind, show_message = TRUE)
	if(!(clock_mind in clockwork_cult))
		return
	var/mob/clocker = clock_mind.current
	clockwork_cult -= clock_mind
	clocker.faction -= "clockwork_cult"
	clock_mind.special_role = null
	for(var/datum/action/innate/clockwork/C in clocker.actions)
		qdel(C)
	update_clock_icons_removed(clock_mind)

	if(ishuman(clocker))
		var/mob/living/carbon/human/H = clocker
		REMOVE_TRAIT(H, CLOCK_HANDS, null)
		H.change_eye_color(H.original_eye_color, FALSE)
		H.update_eyes()
		H.remove_overlay(HALO_LAYER)
		H.update_body()
	add_conversion_logs(clocker, "deconverted from the clockwork cult.")
	if(show_message)
		clocker.visible_message("<span class='clock'>[clocker] looks like [clocker.p_they()] just reverted to [clocker.p_their()] old faith!</span>",
		"<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of Ratvar and the memories of your time as their servant with it.</span>")

/datum/game_mode/proc/update_clock_icons_added(datum/mind/clock_mind)
	var/datum/atom_hud/antag/clockhud = GLOB.huds[ANTAG_HUD_CLOCK]
	if(clock_mind.current)
		clockhud.join_hud(clock_mind.current)
		set_antag_hud(clock_mind.current, "hudclocker")

/datum/game_mode/proc/update_clock_icons_removed(datum/mind/clock_mind)
	var/datum/atom_hud/antag/clockhud = GLOB.huds[ANTAG_HUD_CLOCK]
	if(clock_mind.current)
		clockhud.leave_hud(clock_mind.current)
		set_antag_hud(clock_mind.current, null)

/datum/game_mode/proc/add_clock_actions(datum/mind/clock_mind)
	if(clock_mind.current)
		var/datum/action/innate/clockwork/comm/C = new
		var/datum/action/innate/clockwork/check_progress/D = new
		C.Grant(clock_mind.current)
		D.Grant(clock_mind.current)
		if(ishuman(clock_mind.current) || issilicon(clock_mind.current) && !isAI(clock_mind.current))
			var/datum/action/innate/clockwork/clock_magic/magic = new
			magic.Grant(clock_mind.current)
		clock_mind.current.update_action_buttons(TRUE)

/datum/game_mode/clockwork/declare_completion()
	if(clocker_objs.clock_status == RATVAR_HAS_RISEN)
		SSticker.mode_result = "clockwork cult win - cult win"
	else if(clocker_objs.clock_status == RATVAR_HAS_FALLEN)
		SSticker.mode_result = "clockwork cult draw - ratvar died, nobody wins"
	else
		SSticker.mode_result = "clockwork cult loss - staff stopped the cult"

	var/endtext
	endtext += "<br><b>The clockers' objectives were:</b>"
	endtext += "<br>[clocker_objs.obj_demand.explanation_text] - "
	if(!clocker_objs.obj_demand.check_completion())
		endtext += "<font color='red'>Fail.</font>"
	else
		endtext += "<font color='green'><B>Success!</B></font>"

	if(clocker_objs.clock_status >= RATVAR_NEEDS_SUMMONING)
		endtext += "<br>[clocker_objs.obj_summon.explanation_text] - "
		if(!clocker_objs.obj_summon.check_completion())
			endtext+= "<font color='red'>Fail.</font>"
		else
			endtext += "<font color='green'><B>Success!</B></font>"

	to_chat(world, endtext)
	. = ..()
