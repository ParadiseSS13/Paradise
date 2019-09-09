//Necropolis Tendrils, which spawn lavaland monsters and break into a chasm when killed
/obj/structure/spawner/lavaland
	name = "necropolis tendril"
	desc = "A vile tendril of corruption, originating deep underground. Terrible monsters are pouring out of it."

	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"

	faction = list("mining")
	max_mobs = 3
	max_integrity = 250
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/tendril)

	move_resist = INFINITY // just killing it tears a massive hole in the ground, let's not move it
	anchored = TRUE
	burn_state = LAVA_PROOF

	var/gps = null
	var/obj/effect/light_emitter/tendril/emitted_light

/obj/structure/spawner/lavaland/goliath
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goliath/beast/tendril)

/obj/structure/spawner/lavaland/legion
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril)

GLOBAL_LIST_INIT(tendrils, list())

/obj/structure/spawner/lavaland/Initialize(mapload)
	. = ..()
	emitted_light = new(loc)
	gps = new /obj/item/gps/internal(src)
	GLOB.tendrils += src
	return INITIALIZE_HINT_LATELOAD

/obj/structure/spawner/lavaland/LateInitialize()
	for(var/F in RANGE_TURFS(1, src))
		if(ismineralturf(F))
			var/turf/simulated/mineral/M = F
			M.ChangeTurf(M.turf_type, FALSE, FALSE, TRUE)

/obj/structure/spawner/lavaland/deconstruct(disassembled)
	new /obj/effect/collapse(loc)
	new /obj/structure/closet/crate/necropolis/tendril(loc)
	return ..()


/obj/structure/spawner/lavaland/Destroy()
	var/last_tendril = TRUE
	if(GLOB.tendrils.len>1)
		last_tendril = FALSE

	if(last_tendril && !admin_spawned)
		if(SSmedals.hub_enabled)
			for(var/mob/living/L in view(7,src))
				if(L.stat || !L.client)
					continue
				SSmedals.UnlockMedal("[BOSS_MEDAL_TENDRIL] [ALL_KILL_MEDAL]", L.client)
				SSmedals.SetScore(TENDRIL_CLEAR_SCORE, L.client, 1)
	GLOB.tendrils -= src
	QDEL_NULL(emitted_light)
	QDEL_NULL(gps)
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
	anchored = TRUE
	density = TRUE
	var/obj/effect/light_emitter/tendril/emitted_light

/obj/effect/collapse/Initialize(mapload)
	. = ..()
	emitted_light = new(loc)
	visible_message("<span class='boldannounce'>The tendril writhes in fury as the earth around it begins to crack and break apart! Get back!</span>")
	visible_message("<span class='warning'>Something falls free of the tendril!</span>")
	playsound(loc, 'sound/effects/tendril_destroyed.ogg', 200, FALSE, 50, TRUE, TRUE)
	addtimer(CALLBACK(src, .proc/collapse), 50)

/obj/effect/collapse/Destroy()
	QDEL_NULL(emitted_light)
	return ..()

/obj/effect/collapse/proc/collapse()
	for(var/mob/M in range(7, src))
		shake_camera(M, 15, 1)
	playsound(get_turf(src),'sound/effects/explosionfar.ogg', 200, TRUE)
	visible_message("<span class='boldannounce'>The tendril falls inward, the ground around it widening into a yawning chasm!</span>")
	for(var/turf/T in range(2,src))
		if(!T.density)
			T.TerraformTurf(/turf/simulated/floor/chasm/straight_down/lava_land_surface)
	qdel(src)