#define LIGHTFLOOR_ON 1
#define LIGHTFLOOR_WHITE 2
#define LIGHTFLOOR_RED 3
#define LIGHTFLOOR_GREEN 4
#define LIGHTFLOOR_YELLOW 5
#define LIGHTFLOOR_BLUE 6
#define LIGHTFLOOR_PURPLE 7

/turf/simulated/floor/light
	name = "Light floor"
	light_range = 5
	icon_state = "light_on"
	floor_tile = /obj/item/stack/tile/light
	broken_states = list("light_broken")
	var/on = 1
	var/state = LIGHTFLOOR_ON

/turf/simulated/floor/light/New()
	..()
	update_icon()

/turf/simulated/floor/light/update_icon()
	..()
	if(on)
		switch(state)
			if(LIGHTFLOOR_ON)
				icon_state = "light_on"
				set_light(5,null,LIGHT_COLOR_LIGHTBLUE)
			if(LIGHTFLOOR_WHITE)
				icon_state = "light_on-w"
				set_light(5,null,LIGHT_COLOR_WHITE)
			if(LIGHTFLOOR_RED)
				icon_state = "light_on-r"
				set_light(5,null,LIGHT_COLOR_RED)
			if(LIGHTFLOOR_GREEN)
				icon_state = "light_on-g"
				set_light(5,null,LIGHT_COLOR_PURE_GREEN)
			if(LIGHTFLOOR_YELLOW)
				icon_state = "light_on-y"
				set_light(5,null,"#FFFF00")
			if(LIGHTFLOOR_BLUE)
				icon_state = "light_on-b"
				set_light(5,null,LIGHT_COLOR_DARKBLUE)
			if(LIGHTFLOOR_PURPLE)
				icon_state = "light_on-p"
				set_light(5,null,LIGHT_COLOR_PURPLE)
			else
				icon_state = "light_off"
				set_light(0)
	else
		set_light(0)
		icon_state = "light_off"

/turf/simulated/floor/light/BeforeChange()
	set_light(0)
	..()

/turf/simulated/floor/light/attack_hand(mob/user)
	on = !on
	update_icon()

/turf/simulated/floor/light/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C,/obj/item/weapon/light/bulb)) //only for light tiles
		if(istype(builtin_tile, /obj/item/stack/tile/light))
			if(!state)
				qdel(C)
				state = LIGHTFLOOR_ON
				update_icon()
				to_chat(user, "<span class='notice'>You replace the light bulb.</span>")
			else
				to_chat(user, "<span class='notice'>The light bulb seems fine, no need to replace it.</span>")
	if(istype(C,/obj/item/device/multitool))
		if(state != 0)
			if(state < LIGHTFLOOR_PURPLE)
				state++
			else
				state = LIGHTFLOOR_ON
			to_chat(user, "<span class='notice'>You change \the [src]'s light bulb color.</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>\The [src]'s light bulb appears to have burned out.</span>")
