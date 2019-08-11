/turf/simulated/floor/vault
	icon = 'icons/turf/floors.dmi'
	icon_state = "rockvault"
	smooth = SMOOTH_FALSE

/turf/simulated/floor/vault/New(location, vtype)
	..()
	icon_state = "[vtype]vault"

/turf/simulated/wall/vault
	icon = 'icons/turf/walls.dmi'
	icon_state = "rockvault"
	smooth = SMOOTH_FALSE

/turf/simulated/wall/vault/New(location, vtype)
	..()
	icon_state = "[vtype]vault"

/turf/simulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/simulated/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"

/turf/simulated/floor/greengrid/airless
	icon_state = "gcircuit"
	name = "airless floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/greengrid/airless/New()
	..()
	name = "floor"

/turf/simulated/floor/redgrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "rcircuit"

/turf/simulated/floor/beach
	name = "beach"
	icon = 'icons/misc/beach.dmi'

/turf/simulated/floor/beach/pry_tile(obj/item/C, mob/user, silent = FALSE)	
	return

/turf/simulated/floor/beach/sand
	name = "sand"
	icon_state = "sand"

/turf/simulated/floor/beach/coastline
	name = "coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/simulated/floor/beach/coastline_t
	name = "coastline"
	desc = "Tide's high tonight. Charge your batons."
	icon_state = "sandwater_t"

/turf/simulated/floor/beach/coastline_b
	name = "coastline"
	icon_state = "sandwater_b"

/turf/simulated/floor/beach/water // TODO - Refactor water so they share the same parent type - Or alternatively component something like that
	name = "water"
	icon_state = "water"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/obj/machinery/poolcontroller/linkedcontroller = null

/turf/simulated/floor/beach/water/New()
	..()
	var/image/overlay_image = image('icons/misc/beach.dmi', icon_state = "water5", layer = ABOVE_MOB_LAYER)
	overlay_image.plane = GAME_PLANE
	overlays += overlay_image

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

/turf/simulated/floor/beach/water/InitializedOn(atom/A)
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

/turf/simulated/floor/clockwork/ReplaceWithLattice()
	. = ..()
	for(var/obj/structure/lattice/L in src)
		L.ratvar_act()

/turf/simulated/floor/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(iscrowbar(I))
		user.visible_message("<span class='notice'>[user] begins slowly prying up [src]...</span>", "<span class='notice'>You begin painstakingly prying up [src]...</span>")
		playsound(src, I.usesound, 20, 1)
		if(!do_after(user, 70 * I.toolspeed, target = src))
			return 0
		user.visible_message("<span class='notice'>[user] pries up [src]!</span>", "<span class='notice'>You pry up [src]!</span>")
		playsound(src, I.usesound, 80, 1)
		make_plating()
		return 1
	return ..()

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
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/turf/simulated/floor/clockwork/reebe
	name = "cogplate"
	desc = "Warm brass plating. You can feel it gently vibrating, as if machinery is on the other side."
	icon_state = "reebe"
	baseturf = /turf/simulated/floor/clockwork/reebe
	uses_overlay = FALSE
	planetary_atmos = TRUE
