//Necropolis Tendrils, which spawn lavaland monsters and break into a chasm when killed
/obj/structure/spawner/lavaland
	name = "necropolis tendril"
	desc = "A vile tendril of corruption, originating deep underground. Terrible monsters are pouring out of it."

	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"

	faction = list("mining")
	max_mobs = 3
	max_integrity = 250
	mob_types = list(/mob/living/basic/mining/basilisk/watcher)

	move_resist = INFINITY // just killing it tears a massive hole in the ground, let's not move it
	resistance_flags = FIRE_PROOF | LAVA_PROOF

	var/obj/effect/light_emitter/tendril/emitted_light

/obj/structure/spawner/lavaland/goliath
	mob_types = list(/mob/living/basic/mining/goliath)

/obj/structure/spawner/lavaland/legion
	mob_types = list(/mob/living/basic/mining/hivelord/legion)

GLOBAL_LIST_EMPTY(tendrils)

/obj/structure/spawner/lavaland/Initialize(mapload)
	. = ..()
	emitted_light = new(loc)
	GLOB.tendrils += src
	return INITIALIZE_HINT_LATELOAD

/obj/structure/spawner/lavaland/LateInitialize()
	for(var/F in RANGE_TURFS(1, src))
		if(ismineralturf(F))
			var/turf/simulated/mineral/M = F
			M.ChangeTurf(M.turf_type, FALSE, FALSE, TRUE)
		var/turf/no_lava = F
		no_lava.flags |= NO_LAVA_GEN

/obj/structure/spawner/lavaland/deconstruct(disassembled)
	new /obj/effect/collapse(loc)
	new /obj/structure/closet/crate/necropolis/tendril(loc)
	return ..()

/obj/structure/spawner/lavaland/attacked_by(obj/item/attacker, mob/living/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_SPAWNER_SET_TARGET, user)

/obj/structure/spawner/lavaland/bullet_act(obj/item/projectile/P)
	. = ..()
	if(P.firer)
		SEND_SIGNAL(src, COMSIG_SPAWNER_SET_TARGET, P.firer)

/obj/structure/spawner/lavaland/Destroy()
	GLOB.tendrils -= src
	QDEL_NULL(emitted_light)
	return ..()

/obj/effect/light_emitter/tendril
	set_luminosity = 4
	set_cap = 2.5
	light_color = LIGHT_COLOR_LAVA

/obj/effect/collapse
	name = "collapsing necropolis tendril"
	desc = "Get clear!"
	layer = TABLE_LAYER
	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"
	density = TRUE
	var/obj/effect/light_emitter/tendril/emitted_light

/obj/effect/collapse/Initialize(mapload)
	. = ..()
	emitted_light = new(loc)
	visible_message("<span class='boldannounceic'>The tendril writhes in fury as the earth around it begins to crack and break apart! Get back!</span>")
	visible_message("<span class='warning'>Something falls free of the tendril!</span>")
	playsound(loc, 'sound/effects/tendril_destroyed.ogg', 200, FALSE, 50, TRUE, TRUE)
	addtimer(CALLBACK(src, PROC_REF(collapse)), 50)

/obj/effect/collapse/Destroy()
	QDEL_NULL(emitted_light)
	return ..()

/obj/effect/collapse/proc/collapse()
	for(var/mob/M in range(7, src))
		shake_camera(M, 15, 1)
	playsound(get_turf(src),'sound/effects/explosionfar.ogg', 200, TRUE)
	visible_message("<span class='boldannounceic'>The tendril falls inward, the ground around it widening into a yawning chasm!</span>")
	for(var/turf/T in range(LAVALAND_TENDRIL_COLLAPSE_RANGE, src))
		if(!T.density)
			T.TerraformTurf(/turf/simulated/floor/chasm/straight_down/lava_land_surface)
	qdel(src)
