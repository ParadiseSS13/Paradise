/obj/item/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/used = FALSE

/obj/item/antag_spawner/proc/spawn_antag(client/C, turf/T, type = "")
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
	var/checking = FALSE
	var/rolename = "Syndicate Operative"
	var/image/poll_icon

/obj/item/antag_spawner/nuke_ops/Initialize(mapload)
	. = ..()
	poll_icon = image(icon = 'icons/mob/simple_human.dmi', icon_state = "syndicate_space_sword")

/obj/item/antag_spawner/nuke_ops/proc/before_candidate_search(user)
	return TRUE

/obj/item/antag_spawner/nuke_ops/proc/check_usability(mob/user)
	if(used)
		to_chat(user, "<span class='warning'>[src] is out of power!</span>")
		return FALSE
	if(!(user.mind in SSticker.mode.syndicates))
		to_chat(user, "<span class='danger'>AUTHENTICATION FAILURE. ACCESS DENIED.</span>")
		return FALSE
	if(checking)
		to_chat(user, "<span class='danger'>The device is already connecting to Syndicate command. Please wait.</span>")
		return FALSE
	return TRUE

/obj/item/antag_spawner/nuke_ops/attack_self__legacy__attackchain(mob/user)
	if(!(check_usability(user)))
		return

	var/continue_proc = before_candidate_search(user)
	if(!continue_proc)
		return

	checking = TRUE

	to_chat(user, "<span class='notice'>You activate [src] and wait for confirmation.</span>")
	var/list/nuke_candidates = SSghost_spawns.poll_candidates("Do you want to play as a [rolename]?", ROLE_OPERATIVE, TRUE, 15 SECONDS, source = poll_icon)
	if(length(nuke_candidates))
		checking = FALSE
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE
		var/mob/dead/observer/G = pick(nuke_candidates)
		spawn_antag(G.client, get_turf(src), user.mind)
		dust_if_respawnable(G)
		do_sparks(4, TRUE, src)
		qdel(src)
	else
		checking = FALSE
		to_chat(user, "<span class='warning'>Unable to connect to Syndicate command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>")

/obj/item/antag_spawner/nuke_ops/spawn_antag(client/C, turf/T, kind, datum/mind/user)
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

/obj/item/antag_spawner/nuke_ops/borg_tele/before_candidate_search(mob/user)
	var/switch_roles_choice = tgui_input_list(user, "Would you like to continue playing as an operative or take over as the cyborg? If you play as the cyborg, another player will control your old self.", "Play As", list("Nuclear Operative", "Syndicate Cyborg", "Don't activate this Cyborg Teleporter"))
	if(!switch_roles_choice || !(check_usability(user)) || switch_roles_choice == "Don't activate this Cyborg Teleporter")
		return FALSE

	if(switch_roles_choice == "Syndicate Cyborg")
		switch_roles = TRUE
		rolename = "Syndicate Operative"
	else
		switch_roles = FALSE

	return TRUE

/obj/item/antag_spawner/nuke_ops/borg_tele/spawn_antag(client/C, turf/T, datum/mind/user)
	if(!(user in SSticker.mode.syndicates))
		used = FALSE
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
		var/mob/living/L = user.current
		set_syndicate_values(user.current.client, R)

		L.key = C.key
		SSticker.mode.greet_syndicate(L.mind)

///////////SLAUGHTER DEMON

/// Warning edgiest item in the game
/obj/item/antag_spawner/slaughter_demon
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	var/shatter_msg = "<span class='notice'>You shatter the bottle, no \
		turning back now!</span>"
	var/veil_msg = "<span class='warning'>You sense a dark presence lurking \
		just beyond the veil...</span>"
	var/objective_verb = "Kill"
	var/mob/living/demon_type = /mob/living/simple_animal/demon/slaughter

/obj/item/antag_spawner/slaughter_demon/attack_self__legacy__attackchain(mob/user)
	if(level_blocks_magic(user.z)) //this is to make sure the wizard does NOT summon a demon from the Den..
		to_chat(user, "<span class='notice'>You should probably wait until you reach the station.</span>")
		return

	if(used)
		to_chat(user, "<span class='notice'>This bottle already has a broken seal.</span>")
		return
	used = TRUE
	to_chat(user, "<span class='notice'>You break the seal on the bottle, calling upon the dire spirits of the underworld...</span>")

	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a [demon_type::name] summoned by [user.real_name]?", ROLE_DEMON, TRUE, 10 SECONDS, source = demon_type)

	if(length(candidates) > 0)
		var/mob/C = pick(candidates)
		spawn_antag(C, get_turf(src.loc), initial(demon_type.name), user)
		dust_if_respawnable(C)
		to_chat(user, "[shatter_msg]")
		to_chat(user, "[veil_msg]")
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
		qdel(src)
	else
		used = FALSE
		to_chat(user, "<span class='notice'>The demons do not respond to your summon. Perhaps you should try again later.</span>")

/obj/item/antag_spawner/slaughter_demon/spawn_antag(client/C, turf/T, type = "", mob/user)
	var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(T)
	var/mob/living/simple_animal/demon/D = new demon_type(holder)
	if(istype(D, /mob/living/simple_animal/demon/slaughter))
		var/mob/living/simple_animal/demon/slaughter/S = D
		S.vialspawned = TRUE

	D.key = C.key
	D.mind.assigned_role = D.name
	D.mind.special_role = D.name
	SSticker.mode.traitors += D.mind

	var/list/messages = list()
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.target = user.mind
	KillDaWiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to summon you."
	messages.Add(KillDaWiz.explanation_text)
	D.mind.add_mind_objective(KillDaWiz)

	var/datum/objective/KillDaCrew = new /datum/objective
	KillDaCrew.explanation_text = "[objective_verb] everyone else while you're at it."
	messages.Add(KillDaCrew.explanation_text)
	KillDaCrew.completed = TRUE
	D.mind.add_mind_objective(KillDaCrew)
	to_chat(D, chat_box_red(messages.Join("<br>")))

/obj/item/antag_spawner/slaughter_demon/laughter
	name = "vial of tickles"
	desc = "A magically infused bottle of clown love, distilled from \
		countless hugging attacks. Used in funny rituals to attract \
		adorable creatures."
	icon_state = "vialtickles"
	veil_msg = "<span class='warning'>You sense an adorable presence \
		lurking just beyond the veil...</span>"
	objective_verb = "Hug and tickle"
	demon_type = /mob/living/simple_animal/demon/slaughter/laughter

/obj/item/antag_spawner/slaughter_demon/shadow
	name = "vial of shadow"
	desc = "A magically infused bottle of pure darkness, distilled from \
		ground up shadowling bones. Used in dark rituals to attract \
		dark creatures."
	icon_state = "vialshadows"
	veil_msg = "<span class='warning'>You sense a dark presence \
		lurking in the shadows...</span>"
	demon_type = /mob/living/simple_animal/demon/shadow

///////////MORPH

/obj/item/antag_spawner/morph
	name = "vial of ooze"
	desc = "A magically infused bottle of ooze, distilled by methods rather not be spoken of. Used to awaken an all-consuming monstrosity."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vialooze"
	var/shatter_msg = "<span class='notice'>You shatter the bottle, no \
		turning back now!</span>"
	var/veil_msg = "<span class='warning'>The sludge is awake and seeps \
		away...</span>"
	var/objective_verb = "Eat"
	var/mob/living/morph_type = /mob/living/simple_animal/hostile/morph

/obj/item/antag_spawner/morph/attack_self__legacy__attackchain(mob/user)
	if(level_blocks_magic(user.z))//this is to make sure the wizard does NOT summon a morph from the Den..
		to_chat(user, "<span class='notice'>You should probably wait until you reach the station.</span>")
		return

	if(used)
		to_chat(user, "<span class='notice'>This bottle already has a broken seal.</span>")
		return
	used = TRUE
	to_chat(user, "<span class='notice'>You break the seal on the bottle, calling upon the dire sludge to awaken...</span>")

	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a magical morph awakened by [user.real_name]?", ROLE_MORPH, 1, 10 SECONDS, source = morph_type)

	if(length(candidates) > 0)
		var/mob/C = pick(candidates)
		spawn_antag(C, get_turf(src.loc), initial(morph_type.name), user)
		dust_if_respawnable(C)
		to_chat(user, "[shatter_msg]")
		to_chat(user, "[veil_msg]")
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
		qdel(src)
	else
		used = FALSE
		to_chat(user, "<span class='notice'>The sludge does not respond to your attempt to awake it. Perhaps you should try again later.</span>")

/obj/item/antag_spawner/morph/spawn_antag(client/C, turf/T, type = "", mob/user)
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

	var/list/messages = list()
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.owner = M.mind
	KillDaWiz.target = user.mind
	KillDaWiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to awake you."
	messages.Add(KillDaWiz.explanation_text)
	M.mind.add_mind_objective(KillDaWiz)

	var/datum/objective/KillDaCrew = new /datum/objective
	KillDaCrew.explanation_text = "[objective_verb] everyone and everything else while you're at it."
	messages.Add(KillDaCrew.explanation_text)
	KillDaCrew.completed = TRUE
	M.mind.add_mind_objective(KillDaCrew)

	to_chat(M, chat_box_red(messages.Join("<br>")))

///////////Revenant

/obj/item/antag_spawner/revenant
	name = "vial of ectoplasm"
	desc = "A magically infused bottle of ectoplasm, effectively pure salt from the spectral realm."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vialectoplasm"
	var/shatter_msg = "<span class='notice'>You shatter the bottle, no \
		turning back now!</span>"
	var/veil_msg = "<span class='warning'>The ectoplasm is awake and seeps \
		away...</span>"
	var/objective_verb = "Harvest"
	var/mob/living/revenant = /mob/living/simple_animal/revenant

/obj/item/antag_spawner/revenant/attack_self__legacy__attackchain(mob/user)
	if(level_blocks_magic(user.z)) //this is to make sure the wizard does NOT summon a revenant from the Den..
		to_chat(user, "<span class='notice'>You should probably wait until you reach the station.</span>")
		return

	if(used)
		to_chat(user, "<span class='notice'>This bottle already has a broken seal.</span>")
		return
	used = TRUE
	to_chat(user, "<span class='notice'>You break the seal on the bottle, calling upon the salty specter to awaken...</span>")

	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a revenant awakened by [user.real_name]?", ROLE_REVENANT, 1, 10 SECONDS, source = revenant)

	if(!length(candidates))
		used = FALSE
		to_chat(user, "<span class='notice'>The ectoplasm does not respond to your attempt to awake it. Perhaps you should try again later.</span>")
		return

	var/mob/C = pick(candidates)
	spawn_antag(C, get_turf(src), initial(revenant.name), user)
	dust_if_respawnable(C)
	to_chat(user, "[shatter_msg]")
	to_chat(user, "[veil_msg]")
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
	qdel(src)

/obj/item/antag_spawner/revenant/spawn_antag(client/C, turf/T, type = "", mob/user)
	var/mob/living/simple_animal/revenant/M = new /mob/living/simple_animal/revenant(pick(GLOB.xeno_spawn))
	M.key = C.key

	var/list/messages = list()
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.target = user.mind
	KillDaWiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to awake you."
	messages.Add(KillDaWiz.explanation_text)
	M.mind.add_mind_objective(KillDaWiz)

	var/datum/objective/KillDaCrew = new /datum/objective
	KillDaCrew.explanation_text = "[objective_verb] everyone and everything else while you're at it."
	messages.Add(KillDaCrew.explanation_text)
	KillDaCrew.completed = TRUE
	M.mind.add_mind_objective(KillDaCrew)

	to_chat(M, chat_box_red(messages.Join("<br>")))

///////////Pulse Demon

/obj/item/antag_spawner/pulse_demon
	name = "living lightbulb"
	desc = "A magically sealed lightbulb confining some manner of electricity based creature. It is *heavily* advised not to summon it in maintenance areas."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lbulb"
	var/shatter_msg = "<span class='notice'>You shatter the bulb, no turning back now!</span>"
	var/veil_msg = "<span class='warning'>The creature sparks energetically and zips away...</span>"
	var/objective_verb = "Electrocute"
	var/mob/living/demon_type = /mob/living/simple_animal/demon/pulse_demon/wizard

/obj/item/antag_spawner/pulse_demon/attack_self__legacy__attackchain(mob/user)
	if(level_blocks_magic(user.z))
		to_chat(user, "<span class='notice'>You should probably wait until you reach the station.</span>")
		return

	var/turf/T = get_turf(src)
	var/obj/structure/cable/wire = locate() in T
	if(!wire || wire.get_available_power() <= 0)
		to_chat(user, "<span class='warning'>This is not a suitable place, the creature would die here. Find a powered cable to release it onto.</span>")
		return

	if(used)
		to_chat(user, "<span class='notice'>This bulb already has a broken seal.</span>")
		return

	used = TRUE
	to_chat(user, "<span class='danger'>You break the seal on the bulb, waiting for the creature to spark to life... you might wish to get to safety!</span>")

	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a pulse demon summoned by [user.real_name]?", ROLE_DEMON, TRUE, 10 SECONDS, source = demon_type)

	if(!length(candidates))
		used = FALSE
		to_chat(user, "<span class='notice'>The creature does not come to life. Perhaps you should try again later.</span>")
		return

	var/mob/C = pick(candidates)
	spawn_antag(C, T, user)
	dust_if_respawnable(C)
	to_chat(user, shatter_msg)
	to_chat(user, veil_msg)
	playsound(T, 'sound/effects/glassbr1.ogg', 100, TRUE)
	qdel(src)

/obj/item/antag_spawner/pulse_demon/spawn_antag(client/C, turf/T, mob/user)
	var/datum/mind/player_mind = new /datum/mind(C.key)
	player_mind.active = TRUE

	var/mob/living/simple_animal/demon/pulse_demon/wizard/demon = new(T)
	player_mind.transfer_to(demon)
	player_mind.assigned_role = SPECIAL_ROLE_DEMON
	player_mind.special_role = SPECIAL_ROLE_DEMON
	demon.give_objectives()

	var/list/messages = list()
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.target = user.mind
	KillDaWiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to awake you."
	messages.Add(KillDaWiz.explanation_text)
	demon.mind.add_mind_objective(KillDaWiz)

	var/datum/objective/KillDaCrew = new /datum/objective
	KillDaCrew.explanation_text = "[objective_verb] everyone and everything else while you're at it."
	messages.Add(KillDaCrew.explanation_text)
	KillDaCrew.completed = TRUE
	demon.mind.add_mind_objective(KillDaCrew)

	to_chat(demon, chat_box_red(messages.Join("<br>")))
