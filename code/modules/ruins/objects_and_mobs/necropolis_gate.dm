//The necropolis gate is used to call forth Legion from the Necropolis.
/obj/structure/necropolis_gate
	name = "necropolis gate"
	desc = "A massive stone gateway."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "gate_full"
	flags = ON_BORDER
	appearance_flags = 0
	layer = TABLE_LAYER
	anchored = TRUE
	density = TRUE
	pixel_x = -32
	pixel_y = -32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 8
	light_color = LIGHT_COLOR_LAVA
	var/open = FALSE
	var/changing_openness = FALSE
	var/locked = FALSE
	var/static/mutable_appearance/top_overlay
	var/static/mutable_appearance/door_overlay
	var/static/mutable_appearance/dais_overlay
	var/obj/structure/opacity_blocker/sight_blocker
	var/sight_blocker_distance = 1

/obj/structure/necropolis_gate/Initialize(mapload)
	. = ..()
	var/turf/sight_blocker_turf = get_turf(src)
	if(sight_blocker_distance)
		for(var/i in 1 to sight_blocker_distance)
			if(!sight_blocker_turf)
				break
			sight_blocker_turf = get_step(sight_blocker_turf, NORTH)
	if(sight_blocker_turf)
		sight_blocker = new (sight_blocker_turf) //we need to block sight in a different spot than most things do
		sight_blocker.pixel_y = initial(sight_blocker.pixel_y) - (32 * sight_blocker_distance)
	icon_state = "gate_bottom"

	top_overlay = mutable_appearance('icons/effects/96x96.dmi', "gate_top")
	top_overlay.layer = EDGED_TURF_LAYER
	add_overlay(top_overlay)

	door_overlay = mutable_appearance('icons/effects/96x96.dmi', "door")
	door_overlay.layer = EDGED_TURF_LAYER
	add_overlay(door_overlay)

	dais_overlay = mutable_appearance('icons/effects/96x96.dmi', "gate_dais")
	dais_overlay.layer = CLOSED_TURF_LAYER
	add_overlay(dais_overlay)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_atom_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/necropolis_gate/Destroy()
	qdel(sight_blocker, TRUE)
	return ..()

/obj/structure/necropolis_gate/singularity_pull()
	return

/obj/structure/necropolis_gate/CanPass(atom/movable/mover, border_dir)
	if(border_dir == dir)
		return !density
	return TRUE

/obj/structure/necropolis_gate/proc/on_atom_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER // COMSIG_ATOM_EXIT

	if(direction == dir && density)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/opacity_blocker
	icon = 'icons/effects/96x96.dmi'
	icon_state = "gate_blocker"
	layer = EDGED_TURF_LAYER
	pixel_x = -32
	pixel_y = -32
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	opacity = TRUE
	anchored = TRUE

/obj/structure/opacity_blocker/singularity_pull()
	return

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/necropolis_gate/attack_hand(mob/user)
	. = ..()
	if(locked)
		to_chat(user, "<span class='boldannounceic'>It's [open ? "stuck open" : "locked"].</span>")
		return

	if(GLOB.necropolis_gate == src) //funny override for knock knock gate
		addtimer(CALLBACK(src, PROC_REF(toggle_the_gate), user), 5 SECONDS, TIMER_UNIQUE)
		return

	toggle_the_gate(user)

/obj/structure/necropolis_gate/proc/toggle_the_gate(mob/user)
	if(changing_openness)
		return

	changing_openness = TRUE
	var/turf/T = get_turf(src)

	if(open)
		new /obj/effect/temp_visual/necropolis(T)
		visible_message("<span class='boldwarning'>The door slams closed!</span>")
		playsound(T, 'sound/effects/stonedoor_openclose.ogg', 300, TRUE, frequency = 80000)
		density = TRUE
		var/turf/sight_blocker_turf = get_turf(src)
		if(sight_blocker_distance)
			for(var/i in 1 to sight_blocker_distance)
				if(!sight_blocker_turf)
					break
				sight_blocker_turf = get_step(sight_blocker_turf, NORTH)
		if(sight_blocker_turf)
			sight_blocker.pixel_y = initial(sight_blocker.pixel_y) - (32 * sight_blocker_distance)
			sight_blocker.forceMove(sight_blocker_turf)
		addtimer(CALLBACK(src, PROC_REF(toggle_open_delayed_step), T), 0.5 SECONDS, TIMER_UNIQUE)
		return TRUE

	cut_overlay(door_overlay)
	new /obj/effect/temp_visual/necropolis/open(T)
	visible_message("<span class='warning'>The door starts to grind open...</span>")
	playsound(T, 'sound/effects/stonedoor_openclose.ogg', 300, TRUE, frequency = 20000)
	addtimer(CALLBACK(src, PROC_REF(toggle_closed_delayed_step)), 2.2 SECONDS, TIMER_UNIQUE)
	return TRUE

/obj/structure/necropolis_gate/proc/toggle_open_delayed_step(turf/T)
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 30, TRUE, frequency = 15000)
	add_overlay(door_overlay)
	open = FALSE
	changing_openness = FALSE

/obj/structure/necropolis_gate/proc/toggle_closed_delayed_step()
	sight_blocker.forceMove(src)
	density = FALSE
	open = TRUE
	changing_openness = FALSE

/obj/structure/necropolis_gate/locked
	locked = TRUE

GLOBAL_DATUM(necropolis_gate, /obj/structure/necropolis_gate/legion_gate)
/obj/structure/necropolis_gate/legion_gate
	desc = "A tremendous, impossibly large gateway, set into a massive tower of stone."
	sight_blocker_distance = 2

/obj/structure/necropolis_gate/legion_gate/Initialize(mapload)
	. = ..()
	GLOB.necropolis_gate = src

/obj/structure/necropolis_gate/legion_gate/Destroy()
	if(GLOB.necropolis_gate == src)
		GLOB.necropolis_gate = null
	return ..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/necropolis_gate/legion_gate/attack_hand(mob/user)
	if(!open && !changing_openness)
		var/safety = tgui_alert(user, "You think this might be a bad idea...", "Knock on the door?", list("Proceed", "Abort"))
		if(!safety || safety == "Abort" || !in_range(src, user) || !src || open || changing_openness || user.incapacitated())
			return
		user.visible_message("<span class='warning'>[user] knocks on [src]...</span>", "<span class='boldannounceic'>You tentatively knock on [src]...</span>")
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 100, 1)
	return ..()

/obj/structure/necropolis_gate/legion_gate/toggle_the_gate(mob/user)
	if(open)
		return
	if(..())
		locked = TRUE
		var/turf/T = get_turf(src)
		visible_message("<span class='userdanger'>Something horrible emerges from the Necropolis!</span>")
		message_admins("[user ? ADMIN_LOOKUPFLW(user) : "Unknown"] has released Legion!")
		log_game("[user ? key_name(user) : "Unknown"] released Legion.")

		var/sound/legion_sound = sound('sound/creatures/legion_spawn.ogg')
		for(var/mob/M in GLOB.player_list)
			if(M.z == z && M.client)
				to_chat(M, "<span class='userdanger'>Discordant whispers flood your mind in a thousand voices. Each one speaks your name, over and over. Something horrible has been released.</span>")
				M.playsound_local(T, null, 100, FALSE, 0, FALSE, pressure_affected = FALSE, S = legion_sound)
				M.flash_screen_color("#FF0000", 5 SECONDS)
		var/mutable_appearance/release_overlay = mutable_appearance('icons/effects/effects.dmi', "legiondoor")
		notify_ghosts("Legion has been released in the [get_area(src)]!", source = src, alert_overlay = release_overlay, action = NOTIFY_JUMP)

/obj/effect/temp_visual/necropolis
	icon = 'icons/effects/96x96.dmi'
	icon_state = "door_closing"
	appearance_flags = 0
	duration = 6
	layer = EDGED_TURF_LAYER
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/necropolis/open
	icon_state = "door_opening"
	duration = 38

/obj/structure/necropolis_arch
	name = "necropolis arch"
	desc = "A massive arch over the necropolis gate, set into a massive tower of stone."
	icon = 'icons/effects/160x160.dmi'
	icon_state = "arch_full"
	appearance_flags = 0
	layer = TABLE_LAYER
	anchored = TRUE
	pixel_x = -64
	pixel_y = -40
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/open = FALSE
	var/static/mutable_appearance/top_overlay

/obj/structure/necropolis_arch/Initialize(mapload)
	. = ..()
	icon_state = "arch_bottom"
	top_overlay = mutable_appearance('icons/effects/160x160.dmi', "arch_top")
	top_overlay.layer = EDGED_TURF_LAYER
	add_overlay(top_overlay)

/obj/structure/necropolis_arch/singularity_pull()
	return

//stone tiles for boss arenas
/obj/structure/stone_tile
	name = "stone tile"
	icon = 'icons/turf/boss_floors.dmi'
	icon_state = "pristine_tile1"
	layer = ABOVE_OPEN_TURF_LAYER
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/tile_key = "pristine_tile"
	var/tile_random_sprite_max = 24

/obj/structure/stone_tile/Initialize(mapload)
	. = ..()
	icon_state = "[tile_key][rand(1, tile_random_sprite_max)]"

/obj/structure/stone_tile/singularity_pull()
	return

/obj/structure/stone_tile/block
	name = "stone block"
	icon_state = "pristine_block1"
	tile_key = "pristine_block"
	tile_random_sprite_max = 4

/obj/structure/stone_tile/slab
	name = "stone slab"
	icon_state = "pristine_slab1"
	tile_key = "pristine_slab"
	tile_random_sprite_max = 4

/obj/structure/stone_tile/center
	name = "stone center tile"
	icon_state = "pristine_center1"
	tile_key = "pristine_center"
	tile_random_sprite_max = 4

/obj/structure/stone_tile/surrounding
	name = "stone surrounding slab"
	icon_state = "pristine_surrounding1"
	tile_key = "pristine_surrounding"
	tile_random_sprite_max = 2

/obj/structure/stone_tile/surrounding_tile
	name = "stone surrounding tile"
	icon_state = "pristine_surrounding_tile1"
	tile_key = "pristine_surrounding_tile"
	tile_random_sprite_max = 2

//cracked stone tiles
/obj/structure/stone_tile/cracked
	name = "cracked stone tile"
	icon_state = "cracked_tile1"
	tile_key = "cracked_tile"

/obj/structure/stone_tile/block/cracked
	name = "cracked stone block"
	icon_state = "cracked_block1"
	tile_key = "cracked_block"

/obj/structure/stone_tile/slab/cracked
	name = "cracked stone slab"
	icon_state = "cracked_slab1"
	tile_key = "cracked_slab"
	tile_random_sprite_max = 1

/obj/structure/stone_tile/center/cracked
	name = "cracked stone center tile"
	icon_state = "cracked_center1"
	tile_key = "cracked_center"

/obj/structure/stone_tile/surrounding/cracked
	name = "cracked stone surrounding slab"
	icon_state = "cracked_surrounding1"
	tile_key = "cracked_surrounding"
	tile_random_sprite_max = 1

/obj/structure/stone_tile/surrounding_tile/cracked
	name = "cracked stone surrounding tile"
	icon_state = "cracked_surrounding_tile1"
	tile_key = "cracked_surrounding_tile"

//burnt stone tiles
/obj/structure/stone_tile/burnt
	name = "burnt stone tile"
	icon_state = "burnt_tile1"
	tile_key = "burnt_tile"

/obj/structure/stone_tile/block/burnt
	name = "burnt stone block"
	icon_state = "burnt_block1"
	tile_key = "burnt_block"

/obj/structure/stone_tile/slab/burnt
	name = "burnt stone slab"
	icon_state = "burnt_slab1"
	tile_key = "burnt_slab"

/obj/structure/stone_tile/center/burnt
	name = "burnt stone center tile"
	icon_state = "burnt_center1"
	tile_key = "burnt_center"

/obj/structure/stone_tile/surrounding/burnt
	name = "burnt stone surrounding slab"
	icon_state = "burnt_surrounding1"
	tile_key = "burnt_surrounding"

/obj/structure/stone_tile/surrounding_tile/burnt
	name = "burnt stone surrounding tile"
	icon_state = "burnt_surrounding_tile1"
	tile_key = "burnt_surrounding_tile"
