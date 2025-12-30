/obj/machinery/syndicatebomb/ninja
	name = "spider clan bomb"
	payload = /obj/item/bombcore/ninja

/obj/machinery/syndicatebomb/ninja/emp
	name = "spider clan EMP bomb"
	payload = /obj/item/bombcore/emp/ninja

/obj/machinery/syndicatebomb/ninja/spiders
	name = "spider bomb"
	payload = /obj/item/bombcore/badmin/summon/ninja_spiders

/obj/item/bombcore/ninja
	desc = "A powerful secondary explosive of spider clan design and unknown composition, it should be stable under normal conditions..."
	range_heavy = 3
	range_medium = 8
	range_light = 15
	range_flame = 17

/obj/item/bombcore/emp/ninja
	light_emp = 24
	heavy_emp = 12

/obj/item/bombcore/badmin/summon/ninja_spiders
	summon_path = /mob/living/basic/giant_spider
	amt_summon = 20

/obj/item/wormhole_jaunter/ninja_bomb
	name = "spider clan bomb deployment flare"
	icon = 'icons/obj/lighting.dmi'
	desc = "A single-use flare that will bring a high-yield payload to the location it was lit at."
	icon_state = "flare-contractor"
	inhand_icon_state = "flare"
	/// What area should be blow up?
	var/area/bomb_target
	/// What kind of bomb is it
	var/obj/machinery/syndicatebomb/bomb_type = /obj/machinery/syndicatebomb/ninja

/obj/item/wormhole_jaunter/ninja_bomb/Initialize(mapload)
	. = ..()
	var/list/possible_areas = list(
		// Rooms
		/area/station/hallway/primary/aft,
		/area/station/engineering/atmos,
		/area/station/public/arcade,
		/area/station/maintenance/assembly_line,
		/area/station/public/storage/tools/auxiliary,
		/area/station/command/office/blueshield,
		/area/station/supply/storage,
		/area/station/service/chapel,
		/area/station/service/chapel/office,
		/area/station/service/clown,
		/area/station/legal/courtroom,
		/area/station/public/toilet,
		/area/station/engineering/control,
		/area/station/engineering/controlroom,
		/area/station/hallway/secondary/exit,
		/area/holodeck/alphadeck,
		/area/station/service/hydroponics,
		/area/station/service/library,
		/area/station/service/mime,
		/area/station/supply/miningdock,
		/area/station/medical/morgue,
		/area/station/public/storage/office,
		/area/station/public/pet_store,
		/area/station/public/storage/tools,
		/area/station/public/mrchangs,
		/area/station/science/research,
		/area/station/security/checkpoint,
		/area/station/engineering/tech_storage,
		/area/station/command/teleporter,
		/area/station/science/storage,
		/area/station/science/misc_lab,
		/area/station/science/xenobiology,
		/area/station/turret_protected/aisat/interior,
		/area/station/aisat/atmos,
		/area/station/aisat/hall,
		/area/station/aisat/service,
		/area/station/service/bar,
		/area/station/supply/office,
		/area/station/medical/chemistry,
		/area/station/command/office/ce,
		/area/station/command/office/cmo,
		/area/station/medical/cloning,
		/area/station/medical/cryo,
		/area/station/public/dorms,
		/area/station/engineering/equipmentstorage,
		/area/station/engineering/break_room,
		/area/station/ai_monitored/storage/eva,
		/area/station/supply/expedition,
		/area/station/science/genetics,
		/area/station/engineering/gravitygenerator,
		/area/station/command/office/hop,
		/area/station/command/meeting_room,
		/area/station/service/kitchen,
		/area/station/science/robotics/chargebay,
		/area/station/medical/medbay,
		/area/station/medical/medbay2,
		/area/station/medical/medbay3,
		/area/station/medical/reception,
		/area/station/medical/storage,
		/area/station/medical/sleeper,
		/area/station/command/server,
		/area/station/command/office/ntrep,
		/area/station/medical/paramedic,
		/area/station/hallway/primary/port,
		/area/station/supply/qm,
		/area/station/command/office/rd,
		/area/station/science/rnd,
		/area/station/science/robotics,
		/area/station/medical/surgery/primary,
		/area/station/medical/surgery/secondary,
		/area/station/telecomms/chamber,
		/area/station/engineering/secure_storage
	)
	while(!bomb_target)
		var/area/selected_area = pick_n_take(possible_areas)
		for(var/area/potential in SSmapping.existing_station_areas)
			if(potential.type != selected_area)
				continue
			bomb_target = potential
			break

/obj/item/wormhole_jaunter/ninja_bomb/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += SPAN_WARNING("The target bomb location is: [bomb_target.name]")

/obj/item/wormhole_jaunter/ninja_bomb/activate(mob/user)
	if(!turf_check(user))
		return
	var/obj/effect/temp_visual/ninja_bomb/F = new /obj/effect/temp_visual/ninja_bomb(get_turf(src))
	show_activation_message(user)
	user.drop_item()
	forceMove(F)
	log_and_message_admins("[user] activated a ninja bomb flare.")
	addtimer(CALLBACK(src, PROC_REF(spawn_bomb), user), 5 SECONDS)

/obj/item/wormhole_jaunter/ninja_bomb/spawn_bomb(mob/user)
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	var/obj/machinery/syndicatebomb/new_bomb = new bomb_type(get_turf(src))
	new_bomb.anchored = TRUE
	new_bomb.active = TRUE
	var/objectives = user.mind.get_all_objectives()
	for(var/datum/objective/ninja/bomb_department/bomb_dep in objectives)
		if(!bomb_dep.completed)
			bomb_dep.completed = TRUE
			to_chat(user, SPAN_NOTICE("Contract complete. Good work. A new task is being assigned to you..."))
			bomb_dep.check_completion()
	qdel(src)

/obj/item/wormhole_jaunter/ninja_bomb/turf_check(mob/user)
	var/turf/device_turf = get_turf(user)
	if(!device_turf)
		to_chat(user, "<span class='notice'>You're having difficulties getting the [name] to work.</span>")
		return FALSE
	var/area/our_area = get_area(device_turf)
	if(!istype(our_area, bomb_target))
		to_chat(user, "<span class='notice'>You're having difficulties getting the [name] to work.</span>")
		return FALSE
	return TRUE

/obj/item/wormhole_jaunter/ninja_bomb/emp
	bomb_type = /obj/machinery/syndicatebomb/ninja/emp

/obj/item/wormhole_jaunter/ninja_bomb/spiders
	bomb_type = /obj/machinery/syndicatebomb/ninja/spiders

/obj/effect/temp_visual/ninja_bomb
	name = "spider clan bomb deployment flare"
	layer = BELOW_MOB_LAYER
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flare-contractor-on"
	duration = 5.1 SECONDS
	/// Sound that plays when activated
	var/activation_sound = 'sound/goonstation/misc/matchstick_light.ogg'
	/// Light emitted when activated
	var/emitted_color = "#1faf2b"

/obj/effect/temp_visual/ninja_bomb/Initialize(mapload)
	. = ..()
	playsound(loc, activation_sound, 50, TRUE)
	set_light(8, l_color = emitted_color)
