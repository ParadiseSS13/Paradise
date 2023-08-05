/turf/simulated/floor/vault
	icon = 'icons/turf/floors.dmi'
	icon_state = "rockvault"
	smoothing_flags = NONE

/turf/simulated/wall/vault
	icon = 'icons/turf/walls.dmi'
	icon_state = "rockvault"
	smoothing_flags = NONE

/turf/simulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/simulated/floor/bluegrid/telecomms
	nitrogen = 100
	oxygen = 0
	temperature = 80

/turf/simulated/floor/bluegrid/telecomms/server
	name = "server base"

/turf/simulated/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"

/turf/simulated/floor/greengrid/airless
	icon_state = "gcircuit"
	name = "airless floor"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/greengrid/airless/Initialize(mapload)
	. = ..()
	name = "floor"

/turf/simulated/floor/redgrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "rcircuit"

/turf/simulated/floor/beach
	name = "beach"
	icon = 'icons/misc/beach.dmi'
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/beach/pry_tile(obj/item/C, mob/user, silent = FALSE)
	return

/turf/simulated/floor/beach/sand
	name = "sand"
	icon_state = "sand"
	baseturf = /turf/simulated/floor/beach/sand

/turf/simulated/floor/beach/coastline
	name = "coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"
	baseturf = /turf/simulated/floor/beach/coastline
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/simulated/floor/beach/coastline_t
	name = "coastline"
	desc = "Tide's high tonight. Charge your batons."
	icon_state = "sandwater_t"
	baseturf = /turf/simulated/floor/beach/coastline_t
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/simulated/floor/beach/coastline_b
	name = "coastline"
	icon_state = "sandwater_b"
	baseturf = /turf/simulated/floor/beach/coastline_b
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/simulated/floor/beach/water // TODO - Refactor water so they share the same parent type - Or alternatively component something like that
	name = "water"
	icon_state = "water"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/obj/machinery/poolcontroller/linkedcontroller = null
	baseturf = /turf/simulated/floor/beach/water
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/simulated/floor/beach/water/Initialize(mapload)
	. = ..()
	var/image/overlay_image = image('icons/misc/beach.dmi', icon_state = "water5", layer = ABOVE_MOB_LAYER)
	overlay_image.plane = GAME_PLANE
	overlays += overlay_image
	RegisterSignal(src, COMSIG_ATOM_INITIALIZED_ON, PROC_REF(InitializedOn))

/turf/simulated/floor/beach/water/Entered(atom/movable/AM, atom/OldLoc)
	. = ..()
	if(!linkedcontroller)
		return
	if(ismob(AM))
		linkedcontroller.mobinpool += AM

/turf/simulated/floor/beach/water/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(!linkedcontroller)
		return
	if(ismob(AM))
		linkedcontroller.mobinpool -= AM

/turf/simulated/floor/beach/water/proc/InitializedOn(atom/A)
	if(!linkedcontroller)
		return
	if(istype(A, /obj/effect/decal/cleanable)) // Better a typecheck than looping through thousands of turfs everyday
		linkedcontroller.decalinpool += A

/turf/simulated/floor/noslip
	name = "high-traction floor"
	icon_state = "noslip"
	floor_tile = /obj/item/stack/tile/noslip
	broken_states = list("noslip-damaged1","noslip-damaged2","noslip-damaged3")
	burnt_states = list("noslip-scorched1","noslip-scorched2")
	slowdown = -0.3

/turf/simulated/floor/noslip/MakeSlippery()
	return

/turf/simulated/floor/noslip/lavaland
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE

/turf/simulated/floor/lubed
	name = "slippery floor"
	icon_state = "floor"

/turf/simulated/floor/lubed/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_LUBE, INFINITY)

/turf/simulated/floor/lubed/pry_tile(obj/item/C, mob/user, silent = FALSE) //I want to get off Mr Honk's Wild Ride
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		to_chat(H, "<span class='warning'>You lose your footing trying to pry off the tile!</span>")
		H.slip("the floor", 10 SECONDS, tilesSlipped = 4, walkSafely = 0, slipAny = 1)
	return

//Clockwork floor: Slowly heals toxin damage on nearby servants.
/turf/simulated/floor/clockwork
	name = "clockwork floor"
	desc = "Tightly-pressed brass tiles. They emit minute vibration."
	icon_state = "plating"
	baseturf = /turf/simulated/floor/clockwork
	var/dropped_brass
	var/uses_overlay = TRUE
	var/obj/effect/clockwork/overlay/floor/realappearence

/turf/simulated/floor/clockwork/Initialize(mapload)
	. = ..()
	if(uses_overlay)
		new /obj/effect/temp_visual/ratvar/floor(src)
		new /obj/effect/temp_visual/ratvar/beam(src)
		realappearence = new /obj/effect/clockwork/overlay/floor(src)
		realappearence.linked = src

/turf/simulated/floor/clockwork/Destroy()
	if(uses_overlay && realappearence)
		QDEL_NULL(realappearence)
	return ..()

/turf/simulated/floor/clockwork/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("<span class='notice'>[user] begins slowly prying up [src]...</span>", "<span class='notice'>You begin painstakingly prying up [src]...</span>")
	if(!I.use_tool(src, user, 70, volume = I.tool_volume))
		return
	user.visible_message("<span class='notice'>[user] pries up [src]!</span>", "<span class='notice'>You pry up [src]!</span>")
	make_plating()

/turf/simulated/floor/clockwork/make_plating()
	if(!dropped_brass)
		new /obj/item/stack/tile/brass(src)
		dropped_brass = TRUE
	if(baseturf == type)
		return
	return ..()

/turf/simulated/floor/clockwork/narsie_act()
	..()
	if(istype(src, /turf/simulated/floor/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)

/turf/simulated/floor/clockwork/reebe
	name = "cogplate"
	desc = "Warm brass plating. You can feel it gently vibrating, as if machinery is on the other side."
	icon_state = "reebe"
	baseturf = /turf/simulated/floor/clockwork/reebe
	uses_overlay = FALSE

/turf/simulated/floor/catwalk
	name = "catwalk"
	desc = "A catwalk for easier inspection of cable and pipe installations."
	icon = 'icons/turf/floors/catwalk_floor.dmi'
	icon_state = "catwalk"
	base_icon_state = "catwalk"
	baseturf = /turf/simulated/floor/plating
	floor_tile = /obj/item/stack/tile/catwalk
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CATWALK, SMOOTH_GROUP_SIMULATED_TURFS)
	canSmoothWith = list(SMOOTH_GROUP_CATWALK)
	footstep = FOOTSTEP_CATWALK
	barefootstep = FOOTSTEP_CATWALK
	clawfootstep = FOOTSTEP_CATWALK
	keep_dir = FALSE
	intact = FALSE
	transparent_floor = TRUE

/turf/simulated/floor/catwalk/Initialize(mapload)
	. = ..()
	var/image/I = image('icons/turf/floors/plating.dmi', src, "plating")
	I.layer = PLATING_LAYER
	underlays += I
	dir = SOUTH //dirs that are not 2/south cause smoothing jank
	icon_state = "" //Prevents default icon appearing behind the catwalk

/turf/simulated/floor/catwalk/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	pry_tile(I, user, TRUE)

/turf/simulated/floor/catwalk/can_lay_cable()
	return FALSE // Pry the catwalk up if you want to apply cables underneath

/turf/simulated/floor/catwalk/ex_act(severity)
	if(is_shielded())
		return
	switch(severity)
		if(1.0)
			ChangeTurf(baseturf)
		if(2.0)
			switch(pick(1,2;75,3))
				if(1)
					spawn(0)
						ReplaceWithLattice()
						if(prob(33)) new /obj/item/stack/rods(src)
				if(2)
					ChangeTurf(baseturf)
				if(3)
					break_tile_to_plating()
					hotspot_expose(1000,CELL_VOLUME)
					if(prob(33)) new /obj/item/stack/rods(src)
		if(3.0)
			if(prob(50))
				break_tile_to_plating()
				hotspot_expose(1000,CELL_VOLUME)
