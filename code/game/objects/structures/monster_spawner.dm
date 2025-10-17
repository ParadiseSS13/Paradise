/obj/structure/spawner
	name = "monster nest"
	icon = 'icons/mob/animal.dmi'
	icon_state = null
	max_integrity = 100

	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = TRUE

	var/max_mobs = 5
	var/spawn_time = 300 //30 seconds default
	var/mob_types = list(/mob/living/basic/carp)
	var/spawn_text = "emerges from"
	var/faction = list("hostile")
	var/spawner_type = /datum/component/spawner

/obj/structure/spawner/Initialize(mapload)
	. = ..()
	AddComponent(spawner_type, mob_types, spawn_time, faction, spawn_text, max_mobs)

/obj/structure/spawner/attack_animal(mob/living/simple_animal/M)
	if(faction_check(faction, M.faction, FALSE) && !M.client)
		return
	..()


/obj/structure/spawner/syndicate
	name = "warp beacon"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	spawn_text = "warps in from"
	mob_types = list(/mob/living/simple_animal/hostile/syndicate/ranged)
	faction = list(ROLE_SYNDICATE)

/obj/structure/spawner/skeleton
	name = "bone pit"
	desc = "A pit full of bones, and some still seem to be moving..."
	icon_state = "hole"
	icon = 'icons/mob/nest.dmi'
	max_integrity = 150
	max_mobs = 15
	spawn_time = 150
	mob_types = list(/mob/living/basic/skeleton)
	spawn_text = "climbs out of"
	faction = list("skeleton")

/obj/structure/spawner/mining
	name = "monster den"
	desc = "A hole dug into the ground, harboring all kinds of monsters found within most caves or mining asteroids."
	icon_state = "hole"
	max_integrity = 200
	max_mobs = 3
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls out of"
	mob_types = list(
		/mob/living/basic/mining/goldgrub,
		/mob/living/basic/mining/goliath,
		/mob/living/basic/mining/hivelord,
		/mob/living/basic/mining/basilisk,
	)
	faction = list("mining")

/obj/structure/spawner/mining/goldgrub
	name = "goldgrub den"
	desc = "A den housing a nest of goldgrubs, annoying but arguably much better than anything else you'll find in a nest."
	mob_types = list(/mob/living/basic/mining/goldgrub)

/obj/structure/spawner/mining/goliath
	name = "goliath den"
	desc = "A den housing a nest of goliaths, oh god why?"
	mob_types = list(/mob/living/basic/mining/goliath)

/obj/structure/spawner/mining/goliath/space
	mob_types = list(/mob/living/basic/mining/goliath/space)

/obj/structure/spawner/mining/hivelord
	name = "hivelord den"
	desc = "A den housing a nest of hivelords."
	mob_types = list(/mob/living/basic/mining/hivelord)

/obj/structure/spawner/mining/hivelord/space
	mob_types = list(/mob/living/basic/mining/hivelord/space)

/obj/structure/spawner/mining/basilisk
	name = "basilisk den"
	desc = "A den housing a nest of basilisks, bring a coat."
	mob_types = list(/mob/living/basic/mining/basilisk)

/obj/structure/spawner/mining/basilisk/space
	mob_types = list(/mob/living/basic/mining/basilisk/space)

/obj/structure/spawner/sentient
	var/role_name = "A sentient mob"
	var/assumed_control_message = "You are a sentient mob from a badly coded spawner"

/obj/structure/spawner/sentient/Initialize(mapload)
	. = ..()
	notify_ghosts("\A [name] has been created in \the [get_area(src)]!", source = src, title = "Sentient Spawner Created", flashwindow = FALSE
	)

/obj/structure/spawner/sentient/on_mob_spawn(mob/created_mob)
	created_mob.AddComponent(\
		/datum/component/ghost_direct_control,\
		role_name = src.role_name,\
		assumed_control_message = src.assumed_control_message,\
		after_assumed_control = CALLBACK(src, PROC_REF(became_player_controlled)),\
	)

/obj/structure/spawner/sentient/proc/became_player_controlled(mob/proteon)
	return

/obj/structure/spawner/sentient/proteon_spawner
	name = "eldritch gateway"
	desc = "A dizzying structure that somehow links into Nar'Sie's own domain. The screams of the damned echo continously."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	light_power = 2
	light_color = LIGHT_COLOR_RED
	max_integrity = 50
	density = FALSE
	max_mobs = 2
	spawn_time = 15 SECONDS
	mob_types = list(/mob/living/simple_animal/hostile/construct/proteon/hostile)
	spawn_text = "arises from"
	faction = list("cult")
	role_name = "A proteon cult construct"
	assumed_control_message = null
	/// The GPS inside the spawner, lets security find them, especially if someone is space basing them.
	var/obj/item/gps/internal/proteon/gps

/obj/structure/spawner/sentient/proteon_spawner/Initialize(mapload)
	. = ..()
	GLOB.proteon_portals += src
	gps = new /obj/item/gps/internal/proteon(src)

/obj/structure/spawner/sentient/proteon_spawner/Destroy()
	GLOB.proteon_portals -= src
	QDEL_NULL(gps)
	return ..()

/obj/structure/spawner/sentient/proteon_spawner/examine_status(mob/user)
	if(IS_CULTIST(user) || !isliving(user))
		return "<span class='cult'>It's at <b>[round(obj_integrity * 100 / max_integrity)]%</b> stability.</span>"
	return ..()

/obj/structure/spawner/sentient/proteon_spawner/examine(mob/user)
	. = ..()
	if(!IS_CULTIST(user) && isliving(user))
		var/mob/living/living_user = user
		living_user.adjustBrainLoss(5)
		. += "<span class='userdanger'>The voices of the damned echo relentlessly in your mind, continously rebounding on the walls of your self the more you focus on [src]. Your head pounds, better keep away...</span>"
	else
		. += "<span class='cult'>The gateway will create one weak proteon construct every [spawn_time * 0.1] seconds, up to a total of [max_mobs], that may be controlled by the spirits of the dead.</span>"

/obj/structure/spawner/sentient/proteon_spawner/became_player_controlled(mob/living/simple_animal/hostile/construct/proteon/hostile/proteon)
	proteon.mind.add_antag_datum(/datum/antagonist/cultist)
	proteon.add_filter("awoken_proteon", 3, list("type" = "outline", "color" = LIGHT_COLOR_RED, "size" = 2))
	visible_message("<span class='cult'>[proteon] awakens, glowing an eerie red as it stirs from its stupor!</span>")
	addtimer(CALLBACK(src, PROC_REF(remove_wake_outline), proteon), 8 SECONDS)

/obj/structure/spawner/sentient/proteon_spawner/proc/remove_wake_outline(mob/proteon)
	proteon.remove_filter("awoken_proteon")
	proteon.add_filter("sentient_proteon", 3, list("type" = "outline", "color" = LIGHT_COLOR_RED, "size" = 2, "alpha" = 40))

/obj/structure/spawner/sentient/proteon_spawner/obj_destruction(damage_flag)
	playsound(src, 'sound/hallucinations/veryfar_noise.ogg', 75)
	visible_message("<span class='cult'><b>[src] completely falls apart, the screams of the damned reaching a feverous pitch before slowly fading away into nothing.</b></span>")
	return ..()

/obj/item/gps/internal/proteon
	local = FALSE // Let security find the cult bases in space with it.
	icon_state = null
	gpstag = "Eldritch Signal"
	desc = "You (can)'t just BSA a hole into hell!"
