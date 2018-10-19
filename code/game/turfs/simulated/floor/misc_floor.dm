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

/turf/simulated/floor/beach
	name = "beach"
	icon = 'icons/misc/beach.dmi'

/turf/simulated/floor/beach/sand
	name = "sand"
	icon_state = "sand"

/turf/simulated/floor/beach/coastline
	name = "coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/simulated/floor/beach/water // TODO - Refactor water so they share the same parent type - Or alternatively component something like that
	name = "water"
	icon_state = "water"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/obj/machinery/poolcontroller/linkedcontroller = null

/turf/simulated/floor/beach/water/pry_tile(obj/item/C, mob/user, silent = FALSE)
	return	//cannot pry off tiles of water


/turf/simulated/floor/beach/water/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1)

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

//Clockwork floor: Slowly heals toxin damage on nearby servants.
/turf/simulated/floor/clockwork
	name = "clockwork floor"
	desc = "Tightly-pressed brass tiles. They emit minute vibration."
	icon_state = "clockwork_floor"

/turf/simulated/floor/clockwork/New()
	..()
	new /obj/effect/temp_visual/ratvar/floor(src)
	new /obj/effect/temp_visual/ratvar/beam(src)

/turf/simulated/floor/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(iscrowbar(I))
		user.visible_message("<span class='notice'>[user] begins slowly prying up [src]...</span>", "<span class='notice'>You begin painstakingly prying up [src]...</span>")
		playsound(src, I.usesound, 20, 1)
		if(!do_after(user, 70*I.toolspeed, target = src))
			return 0
		user.visible_message("<span class='notice'>[user] pries up [src]!</span>", "<span class='notice'>You pry up [src]!</span>")
		playsound(src, I.usesound, 80, 1)
		make_plating()
		return 1
	return ..()

/turf/simulated/floor/clockwork/make_plating()
	new /obj/item/stack/tile/brass(src)
	return ..()

/turf/simulated/floor/clockwork/narsie_act()
	..()
	if(istype(src, /turf/simulated/floor/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
