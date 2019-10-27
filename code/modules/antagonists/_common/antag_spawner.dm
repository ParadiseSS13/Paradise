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
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/borg_to_spawn
	var/checking = FALSE
	var/rolename = "Syndicate Operative"

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

/obj/item/antag_spawner/nuke_ops/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	var/continue_proc = before_candidate_search(user)
	if(!continue_proc)
		return

	checking = TRUE

	to_chat(user, "<span class='notice'>You activate [src] and wait for confirmation.</span>")
	var/list/nuke_candidates = pollCandidates("Do you want to play as a [rolename]?", ROLE_OPERATIVE, TRUE, 150)
	if(LAZYLEN(nuke_candidates))
		checking = FALSE
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE
		var/mob/dead/observer/G = pick(nuke_candidates)
		spawn_antag(G.client, get_turf(src), user.mind)
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
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field."
	var/switch_roles = FALSE

/obj/item/antag_spawner/nuke_ops/borg_tele/assault
	name = "syndicate assault cyborg teleporter"
	borg_to_spawn = "Assault"

/obj/item/antag_spawner/nuke_ops/borg_tele/medical
	name = "syndicate medical teleporter"
	borg_to_spawn = "Medical"

/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	name = "syndicate saboteur teleporter"
	borg_to_spawn = "Saboteur"

/obj/item/antag_spawner/nuke_ops/borg_tele/before_candidate_search(mob/user)
	var/switch_roles_choice = input("Would you like to continue playing as an operative or take over as the cyborg? If you play as the cyborg, another player will control your old self.", "Play As") as null|anything in list("Nuclear Operative", "Syndicate Cyborg")
	if(!switch_roles_choice || !(check_usability(user)))
		return FALSE

	if(switch_roles_choice == "Syndicate Cyborg")
		switch_roles = TRUE
		rolename = initial(rolename)
	else
		switch_roles = FALSE
		rolename = "Syndicate [borg_to_spawn] Cyborg"

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

/obj/item/antag_spawner/slaughter_demon //Warning edgiest item in the game
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	var/shatter_msg = "<span class='notice'>You shatter the bottle, no \
		turning back now!</span>"
	var/veil_msg = "<span class='warning'>You sense a dark presence lurking \
		just beyond the veil...</span>"
	var/objective_verb = "Kill"
	var/mob/living/demon_type = /mob/living/simple_animal/slaughter

/obj/item/antag_spawner/slaughter_demon/attack_self(mob/user)
	if(level_blocks_magic(user.z)) //this is to make sure the wizard does NOT summon a demon from the Den..
		to_chat(user, "<span class='notice'>You should probably wait until you reach the station.</span>")
		return

	if(used)
		to_chat(user, "<span class='notice'>This bottle already has a broken seal.</span>")
		return
	used = TRUE
	to_chat(user, "<span class='notice'>You break the seal on the bottle, calling upon the dire spirits of the underworld...</span>")

	var/type = "slaughter"
	if(demon_type == /mob/living/simple_animal/slaughter/laughter)
		type = "laughter"
	var/list/candidates = pollCandidates("Do you want to play as a [type] demon summoned by [user.real_name]?", ROLE_DEMON, 1, 100)

	if(candidates.len > 0)
		var/mob/C = pick(candidates)
		spawn_antag(C, get_turf(src.loc), initial(demon_type.name), user)
		to_chat(user, "[shatter_msg]")
		to_chat(user, "[veil_msg]")
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
		qdel(src)
	else
		used = FALSE
		to_chat(user, "<span class='notice'>The demons do not respond to your summon. Perhaps you should try again later.</span>")

/obj/item/antag_spawner/slaughter_demon/spawn_antag(client/C, turf/T, type = "", mob/user)
	var /obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(T)
	var/mob/living/simple_animal/slaughter/S = new demon_type(holder)
	S.vialspawned = TRUE
	S.holder = holder
	S.key = C.key
	S.mind.assigned_role = S.name
	S.mind.special_role = S.name
	SSticker.mode.traitors += S.mind
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.owner = S.mind
	KillDaWiz.target = user.mind
	KillDaWiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to summon you."
	S.mind.objectives += KillDaWiz
	var/datum/objective/KillDaCrew = new /datum/objective
	KillDaCrew.owner = S.mind
	KillDaCrew.explanation_text = "[objective_verb] everyone else while you're at it."
	KillDaCrew.completed = TRUE
	S.mind.objectives += KillDaCrew
	to_chat(S, "<B>Objective #[1]</B>: [KillDaWiz.explanation_text]")
	to_chat(S, "<B>Objective #[2]</B>: [KillDaCrew.explanation_text]")

/obj/item/antag_spawner/slaughter_demon/laughter
	name = "vial of tickles"
	desc = "A magically infused bottle of clown love, distilled from \
		countless hugging attacks. Used in funny rituals to attract \
		adorable creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vialtickles"
	veil_msg = "<span class='warning'>You sense an adorable presence \
		lurking just beyond the veil...</span>"
	objective_verb = "Hug and tickle"
	demon_type = /mob/living/simple_animal/slaughter/laughter

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

/obj/item/antag_spawner/morph/attack_self(mob/user)
	if(level_blocks_magic(user.z))//this is to make sure the wizard does NOT summon a morph from the Den..
		to_chat(user, "<span class='notice'>You should probably wait until you reach the station.</span>")
		return

	if(used)
		to_chat(user, "<span class='notice'>This bottle already has a broken seal.</span>")
		return
	used = TRUE
	to_chat(user, "<span class='notice'>You break the seal on the bottle, calling upon the dire sludge to awaken...</span>")

	var/list/candidates = pollCandidates("Do you want to play as a magical morph awakened by [user.real_name]?", ROLE_MORPH, 1, 100)

	if(candidates.len > 0)
		var/mob/C = pick(candidates)
		spawn_antag(C, get_turf(src.loc), initial(morph_type.name), user)
		to_chat(user, "[shatter_msg]")
		to_chat(user, "[veil_msg]")
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
		qdel(src)
	else
		used = FALSE
		to_chat(user, "<span class='notice'>The sludge does not respond to your attempt to awake it. Perhaps you should try again later.</span>")

/obj/item/antag_spawner/morph/spawn_antag(client/C, turf/T, type = "", mob/user)
	var/mob/living/simple_animal/hostile/morph/wizard/M = new /mob/living/simple_animal/hostile/morph/wizard(pick(xeno_spawn))
	M.key = C.key
	M.mind.assigned_role = SPECIAL_ROLE_MORPH
	M.mind.special_role = SPECIAL_ROLE_MORPH
	to_chat(M, M.playstyle_string)
	SSticker.mode.traitors += M.mind
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.owner = M.mind
	KillDaWiz.target = user.mind
	KillDaWiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to awake you."
	M.mind.objectives += KillDaWiz
	var/datum/objective/KillDaCrew = new /datum/objective
	KillDaCrew.owner = M.mind
	KillDaCrew.explanation_text = "[objective_verb] everyone and everything else while you're at it."
	KillDaCrew.completed = TRUE
	M.mind.objectives += KillDaCrew
	to_chat(M, "<B>Objective #[1]</B>: [KillDaWiz.explanation_text]")
	to_chat(M, "<B>Objective #[2]</B>: [KillDaCrew.explanation_text]")
	M << 'sound/magic/mutate.ogg'
