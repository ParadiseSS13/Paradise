/obj/item/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/checking = FALSE
	var/rolename = ""
	var/role_define
	var/image/poll_icon
	var/poll_time = 10 SECONDS
	var/candidate_search_start_message = ""
	var/candidate_search_fail_message = ""
	new_attack_chain = TRUE

/obj/item/antag_spawner/proc/check_usability(mob/user)
	if(QDELETED(src))
		return FALSE

	return TRUE

/obj/item/antag_spawner/activate_self(mob/user)
	if(!(check_usability(user)))
		return ..()

	checking = TRUE

	to_chat(user, SPAN_NOTICE(candidate_search_start_message))
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a [rolename]?", role_define, TRUE, poll_time, source = poll_icon)
	checking = FALSE
	if(!length(candidates))
		to_chat(user, SPAN_WARNING(candidate_search_fail_message))
		return ITEM_INTERACT_COMPLETE

	if(QDELETED(src) || !check_usability(user))
		return ITEM_INTERACT_COMPLETE
	var/mob/dead/observer/candidate = pick(candidates)
	spawn_antag(candidate.client, get_turf(src), user)
	dust_if_respawnable(candidate)
	after_spawn_antag(candidate, user)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/antag_spawner/proc/spawn_antag(client/C, turf/T, mob/user)
	return

/obj/item/antag_spawner/proc/after_spawn_antag(client/C, mob/user)
	return

/obj/item/antag_spawner/proc/equip_antag(mob/target)
	return

///////////BORGS AND OPERATIVES
/obj/item/antag_spawner/nuke_ops
	name = "syndicate operative teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field."
	icon = 'icons/obj/bio_chips.dmi'
	icon_state = "locator"
	var/borg_to_spawn
	poll_time = 15 SECONDS
	rolename = "Syndicate Operative"
	role_define = ROLE_OPERATIVE

/obj/item/antag_spawner/nuke_ops/Initialize(mapload)
	. = ..()
	poll_icon = image(icon = 'icons/mob/simple_human.dmi', icon_state = "syndicate_space_sword")
	candidate_search_start_message = "You activate [src] and wait for confirmation."
	candidate_search_fail_message = "Unable to connect to Syndicate command. Please wait and try again later or use the teleporter on your uplink to get your points refunded."

/obj/item/antag_spawner/nuke_ops/check_usability(mob/user)
	if(!..())
		return FALSE
	if(!(user.mind in SSticker.mode.syndicates))
		to_chat(user, SPAN_DANGER("AUTHENTICATION FAILURE. ACCESS DENIED."))
		return FALSE
	if(checking)
		to_chat(user, SPAN_DANGER("The device is already connecting to Syndicate command. Please wait."))
		return FALSE
	return TRUE

/obj/item/antag_spawner/nuke_ops/after_spawn_antag(client/C, mob/user)
	do_sparks(4, TRUE, src)

/obj/item/antag_spawner/nuke_ops/spawn_antag(client/C, turf/T, mob/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)

	var/agent_number = LAZYLEN(SSticker.mode.syndicates) - 1
	M.real_name = "[syndicate_name()] Operative #[agent_number]"

	set_syndicate_values(C, M)
	SSticker.mode.create_syndicate(M.mind)
	SSticker.mode.equip_syndicate(M, 0)
	SSticker.mode.update_syndicate_id(M.mind, FALSE)

/obj/item/antag_spawner/nuke_ops/proc/set_syndicate_values(client/C, mob/living/M)
	M.key = C.key

	SSticker.mode.syndicates += M.mind
	SSticker.mode.update_synd_icons_added(M.mind)

	M.mind.assigned_role = SPECIAL_ROLE_NUKEOPS
	M.mind.special_role = SPECIAL_ROLE_NUKEOPS
	M.mind.offstation_role = TRUE

	M.faction = list("syndicate")
	SSticker.mode.forge_syndicate_objectives(M.mind)
	SSticker.mode.greet_syndicate(M.mind)

//////SYNDICATE BORG
/obj/item/antag_spawner/nuke_ops/borg_tele
	name = "syndicate cyborg teleporter"
	var/switch_roles = FALSE

/obj/item/antag_spawner/nuke_ops/borg_tele/assault
	name = "syndicate assault cyborg teleporter"
	borg_to_spawn = "Assault"
	rolename = "Syndicate Assault Cyborg"

/obj/item/antag_spawner/nuke_ops/borg_tele/assault/Initialize(mapload)
	. = ..()
	poll_icon = image(icon = 'icons/mob/robots.dmi', icon_state = "spidersyndi-preview")

/obj/item/antag_spawner/nuke_ops/borg_tele/medical
	name = "syndicate medical teleporter"
	borg_to_spawn = "Medical"
	rolename = "Syndicate Medical Cyborg"

/obj/item/antag_spawner/nuke_ops/borg_tele/medical/Initialize(mapload)
	. = ..()
	poll_icon = image(icon = 'icons/mob/robots.dmi', icon_state = "syndi-medi")

/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	name = "syndicate saboteur teleporter"
	borg_to_spawn = "Saboteur"
	rolename = "Syndicate Saboteur Cyborg"

/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur/Initialize(mapload)
	. = ..()
	poll_icon = image(icon = 'icons/mob/robots.dmi', icon_state = "syndi-engi-preview")

/obj/item/antag_spawner/nuke_ops/borg_tele/check_usability(mob/user)
	if(!..())
		return FALSE

	var/switch_roles_choice = tgui_input_list(user, "Would you like to continue playing as an operative or take over as the cyborg? If you play as the cyborg, another player will control your old self.", "Play As", list("Nuclear Operative", "Syndicate Cyborg", "Don't activate this Cyborg Teleporter"))
	if(!switch_roles_choice || !..() || switch_roles_choice == "Don't activate this Cyborg Teleporter")
		return FALSE

	if(switch_roles_choice == "Syndicate Cyborg")
		switch_roles = TRUE
		rolename = "Syndicate Operative"
	else
		switch_roles = FALSE

	return TRUE

/obj/item/antag_spawner/nuke_ops/borg_tele/spawn_antag(client/C, turf/T, mob/user)
	if(!(user.mind in SSticker.mode.syndicates))
		return

	var/mob/living/silicon/robot/R
	switch(borg_to_spawn)
		if("Medical")
			R = new /mob/living/silicon/robot/syndicate/medical(T)
		if("Saboteur")
			R = new /mob/living/silicon/robot/syndicate/saboteur(T)
		else
			R = new /mob/living/silicon/robot/syndicate(T) //Assault borg by default

	var/brainfirstname = pick(GLOB.first_names_male)
	if(prob(50))
		brainfirstname = pick(GLOB.first_names_female)
	var/brainopslastname = pick(GLOB.last_names)
	if(syndicate_name())  //the brain inside the syndiborg has the same last name as the other ops.
		brainopslastname = syndicate_name()
	var/brainopsname = "[brainfirstname] [brainopslastname]"

	R.mmi.name = "[initial(R.mmi.name)]: [brainopsname]"
	R.mmi.brainmob.real_name = brainopsname
	R.mmi.brainmob.name = brainopsname

	if(!switch_roles)
		set_syndicate_values(C, R)
	else
		var/mob/living/L = user
		set_syndicate_values(user.client, R)

		L.key = C.key
		SSticker.mode.greet_syndicate(L.mind)

///////////DEMONS ETC

/obj/item/antag_spawner/monster
	desc = ABSTRACT_TYPE_DESC
	role_define = ROLE_DEMON
	var/shatter_msg = "You shatter the bottle, no turning back now!"
	var/veil_msg = "You sense nothing emerging from the bottle."
	var/objective_verb = "Annoy"
	var/mob/living/monster_type

/obj/item/antag_spawner/monster/check_usability(mob/user)
	if(!..())
		return FALSE

	if(level_blocks_magic(user.z)) // This is to make sure the wizard does NOT summon a demon from the Den..
		to_chat(user, SPAN_NOTICE("You should probably wait until you reach the station."))
		return FALSE

	return TRUE

/obj/item/antag_spawner/monster/activate_self(mob/user)
	if(monster_type)
		rolename = "[monster_type::name] awakened by [user.real_name]"
		return ..()

/obj/item/antag_spawner/monster/spawn_antag(client/C, turf/T, mob/user)
	if(!monster_type)
		return

/obj/item/antag_spawner/monster/proc/assign_objectives(mob/living/monster, mob/user)
	var/list/messages = list()
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.owner = monster.mind
	KillDaWiz.target = user.mind
	KillDaWiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to awake you."
	messages.Add(KillDaWiz.explanation_text)
	monster.mind.add_mind_objective(KillDaWiz)

	var/datum/objective/KillDaCrew = new /datum/objective
	KillDaCrew.owner = monster.mind
	KillDaCrew.explanation_text = "[objective_verb] everyone and everything else while you're at it."
	messages.Add(KillDaCrew.explanation_text)
	KillDaCrew.completed = TRUE
	monster.mind.add_mind_objective(KillDaCrew)

	to_chat(monster, chat_box_red(messages.Join("<br>")))

/obj/item/antag_spawner/monster/after_spawn_antag(client/C, mob/user)
	to_chat(user, SPAN_NOTICE(shatter_msg))
	to_chat(user, SPAN_WARNING(veil_msg))
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)

///////////SLAUGHTER DEMON

/// Warning edgiest item in the game
/obj/item/antag_spawner/monster/slaughter_demon
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	veil_msg = "You sense a dark presence lurking just beyond the veil..."
	candidate_search_start_message = "You break the seal on the bottle, calling upon the dire spirits of the underworld..."
	candidate_search_fail_message = "The demons do not respond to your summon. Perhaps you should try again later."
	objective_verb = "Kill"
	monster_type = /mob/living/basic/demon/slaughter

/obj/item/antag_spawner/monster/slaughter_demon/spawn_antag(client/C, turf/T, type = "", mob/user)
	var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(T)
	var/mob/living/basic/demon/D = new monster_type(holder)
	if(istype(D, /mob/living/basic/demon/slaughter))
		var/mob/living/basic/demon/slaughter/S = D
		S.vialspawned = TRUE

	D.key = C.key
	D.mind.assigned_role = D.name
	D.mind.special_role = D.name
	SSticker.mode.traitors += D.mind

	assign_objectives(D, user)

/obj/item/antag_spawner/monster/slaughter_demon/laughter
	name = "vial of tickles"
	desc = "A magically infused bottle of clown love, distilled from \
		countless hugging attacks. Used in funny rituals to attract \
		adorable creatures."
	icon_state = "vialtickles"
	veil_msg = "You sense an adorable presence lurking just beyond the veil..."
	objective_verb = "Hug and tickle"
	monster_type = /mob/living/basic/demon/slaughter/laughter

/obj/item/antag_spawner/monster/slaughter_demon/shadow
	name = "vial of shadow"
	desc = "A magically infused bottle of pure darkness, distilled from \
		ground up shadowling bones. Used in dark rituals to attract \
		dark creatures."
	icon_state = "vialshadows"
	veil_msg = "You sense a dark presence lurking in the shadows..."
	monster_type = /mob/living/basic/demon/shadow

///////////MORPH

/obj/item/antag_spawner/monster/morph
	name = "vial of ooze"
	desc = "A magically infused bottle of ooze, distilled by methods rather not be spoken of. Used to awaken an all-consuming monstrosity."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vialooze"
	role_define = ROLE_MORPH
	veil_msg = "The sludge is awake and seeps away..."
	objective_verb = "Eat"
	candidate_search_start_message = "You break the seal on the bottle, calling upon the dire sludge to awaken..."
	candidate_search_fail_message = "The sludge does not respond to your attempt to awake it. Perhaps you should try again later."
	monster_type = /mob/living/simple_animal/hostile/morph

/obj/item/antag_spawner/monster/morph/spawn_antag(client/C, turf/T, mob/user)
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
	if(!length(vents))
		message_admins("Warning: No suitable vents detected for spawning morphs. Force picking from station vents regardless of state!")
		vents = get_valid_vent_spawns(unwelded_only = FALSE, min_network_size = 0)
		if(!length(vents))
			message_admins("Warning: No vents detected for spawning morphs at all!")
			return
	var/obj/vent = pick(vents)
	var/mob/living/simple_animal/hostile/morph/wizard/M = new /mob/living/simple_animal/hostile/morph/wizard(vent)
	M.key = C.key
	M.make_morph_antag(FALSE)
	M.forceMove(vent)
	M.add_ventcrawl(vent)

	assign_objectives(M, user)

///////////Revenant

/obj/item/antag_spawner/monster/revenant
	name = "vial of ectoplasm"
	desc = "A magically infused bottle of ectoplasm, effectively pure salt from the spectral realm."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vialectoplasm"
	role_define = ROLE_REVENANT
	veil_msg = "The ectoplasm is awake and seeps away..."
	candidate_search_start_message = "You break the seal on the bottle, calling upon the salty specter to awaken..."
	candidate_search_fail_message = "The ectoplasm does not respond to your attempt to awake it. Perhaps you should try again later."
	objective_verb = "Harvest"
	monster_type = /mob/living/basic/revenant

/obj/item/antag_spawner/monster/revenant/spawn_antag(client/C, turf/T, mob/user)
	var/mob/living/basic/revenant/M = new /mob/living/basic/revenant(pick(GLOB.xeno_spawn))
	M.key = C.key

	assign_objectives(M, user)

///////////Pulse Demon

/obj/item/antag_spawner/monster/pulse_demon
	name = "living lightbulb"
	desc = "A magically sealed lightbulb confining some manner of electricity based creature. It is *heavily* advised not to summon it in maintenance areas."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lbulb"
	shatter_msg = "You shatter the bulb, no turning back now!"
	veil_msg = "The creature sparks energetically and zips away..."
	candidate_search_start_message = "You break the seal on the bulb, waiting for the creature to spark to life... you might wish to get to safety!"
	candidate_search_fail_message = "The creature does not come to life. Perhaps you should try again later."
	objective_verb = "Electrocute"
	monster_type = /mob/living/basic/demon/pulse_demon/wizard

/obj/item/antag_spawner/monster/pulse_demon/check_usability(mob/user)
	if(!..())
		return FALSE

	var/turf/T = get_turf(src)
	var/obj/structure/cable/wire = locate() in T
	if(!wire || wire.get_available_power() <= 0)
		to_chat(user, SPAN_WARNING("This is not a suitable place, the creature would die here. Find a powered cable to release it onto."))
		return FALSE

	return TRUE

/obj/item/antag_spawner/monster/pulse_demon/spawn_antag(client/C, turf/T, mob/user)
	var/datum/mind/player_mind = new /datum/mind(C.key)
	player_mind.active = TRUE

	var/mob/living/basic/demon/pulse_demon/wizard/demon = new(T)
	player_mind.transfer_to(demon)
	player_mind.assigned_role = SPECIAL_ROLE_DEMON
	player_mind.special_role = SPECIAL_ROLE_DEMON
	demon.give_objectives()

	assign_objectives(demon, user)
