/obj/item/weapon/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = 1
	var/used = 0

/obj/item/weapon/antag_spawner/proc/spawn_antag(var/client/C, var/turf/T, var/type = "")
	return

/obj/item/weapon/antag_spawner/proc/equip_antag(mob/target as mob)
	return


/obj/item/weapon/antag_spawner/borg_tele
	name = "syndicate cyborg teleporter"
	desc = "A single-use teleporter used to deploy a Syndicate Cyborg on the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/checking = 0
	var/TC_cost = 0
	var/borg_to_spawn
	var/list/possible_types = list("Assault", "Medical")

/obj/item/weapon/antag_spawner/borg_tele/attack_self(mob/user as mob)
	if(used)
		to_chat(user, "<span class='warning'>[src] is out of power!</span>")
		return
	if(!(user.mind in ticker.mode.syndicates))
		to_chat(user, "<span class='danger'>AUTHENTICATION FAILURE. ACCESS DENIED.</span>")
		return 0
	if(checking)
		to_chat(user, "<span class='warning'>[src] is already checking for possible borgs.</span>")
		return
	borg_to_spawn = input("What type of borg would you like to teleport?", "Cyborg Type", type) as null|anything in possible_types
	if(!borg_to_spawn || checking || used)
		return
	checking = 1
	to_chat(user, "<span class='notice'>The device is now checking for possible borgs.</span>")
	var/list/borg_candidates = pollCandidates("Do you want to play as a Syndicate [borg_to_spawn] borg?", ROLE_OPERATIVE, 1)
	if(borg_candidates.len > 0 && !used)
		checking = 0
		used = 1
		var/mob/M = pick(borg_candidates)
		var/client/C = M.client
		spawn_antag(C, get_turf(src.loc), "syndieborg")
	else
		checking = 0
		to_chat(user, "<span class='notice'>Unable to connect to Syndicate command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>")
		return

/obj/item/weapon/antag_spawner/borg_tele/spawn_antag(var/client/C, var/turf/T, var/type = "")
	if(!borg_to_spawn) //If there's no type at all, let it still be used but don't do anything
		used = 0
		return
	var/datum/effect/system/spark_spread/S = new /datum/effect/system/spark_spread
	S.set_up(4, 1, src)
	S.start()
	var/mob/living/silicon/robot/R
	switch(borg_to_spawn)
		if("Medical")
			R = new /mob/living/silicon/robot/syndicate/medical(T)
		else
			R = new /mob/living/silicon/robot/syndicate(T) //Assault borg by default
	R.key = C.key
	ticker.mode.syndicates += R.mind
	ticker.mode.update_synd_icons_added(R.mind)
	R.mind.special_role = SPECIAL_ROLE_NUKEOPS
	R.faction = list("syndicate")

/obj/item/weapon/antag_spawner/slaughter_demon //Warning edgiest item in the game
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

/obj/item/weapon/antag_spawner/slaughter_demon/attack_self(mob/user as mob)
	if(level_blocks_magic(user.z))//this is to make sure the wizard does NOT summon a demon from the Den..
		to_chat(user, "<span class='notice'>You should probably wait until you reach the station.</span>")
		return

	if(used)
		to_chat(user, "<span class='notice'>This bottle already has a broken seal.</span>")
		return
	used = 1
	to_chat(user, "<span class='notice'>You break the seal on the bottle, calling upon the dire spirits of the underworld...</span>")

	var/list/candidates = pollCandidates("Do you want to play as a slaughter demon summoned by [user.real_name]?", ROLE_DEMON, 1, 100)

	if(candidates.len > 0)
		var/mob/C = pick(candidates)
		spawn_antag(C, get_turf(src.loc), initial(demon_type.name), user)
		to_chat(user, "[shatter_msg]")
		to_chat(user, "[veil_msg]")
		playsound(user.loc, 'sound/effects/Glassbr1.ogg', 100, 1)
		qdel(src)
	else
		used = 0
		to_chat(user, "<span class='notice'>The demons do not respond to your summon. Perhaps you should try again later.</span>")

/obj/item/weapon/antag_spawner/slaughter_demon/spawn_antag(var/client/C, var/turf/T, var/type = "", mob/user as mob)
	var /obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(T)
	var/mob/living/simple_animal/slaughter/S = new demon_type(holder)
	S.vialspawned = TRUE
	S.holder = holder
	S.key = C.key
	S.mind.assigned_role = S.name
	S.mind.special_role = S.name
	ticker.mode.traitors += S.mind
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.owner = S.mind
	KillDaWiz.target = user.mind
	KillDaWiz.explanation_text = "[objective_verb] [user.real_name], the one who was foolish enough to summon you."
	S.mind.objectives += KillDaWiz
	var/datum/objective/KillDaCrew = new /datum/objective
	KillDaCrew.owner = S.mind
	KillDaCrew.explanation_text = "[objective_verb] everyone else while you're at it."
	S.mind.objectives += KillDaCrew
	S.mind.objectives += KillDaCrew
	to_chat(S, "<B>Objective #[1]</B>: [KillDaWiz.explanation_text]")
	to_chat(S, "<B>Objective #[2]</B>: [KillDaCrew.explanation_text]")


/obj/item/weapon/antag_spawner/slaughter_demon/laughter
	name = "vial of tickles"
	desc = "A magically infused bottle of clown love, distilled from \
		countless hugging attacks. Used in funny rituals to attract \
		adorable creatures."
	color = "#FF69B4" // HOT PINK
	veil_msg = "<span class='warning'>You sense an adorable presence \
		lurking just beyond the veil...</span>"
	objective_verb = "Hug and Tickle"
	demon_type = /mob/living/simple_animal/slaughter/laughter
