#define LIGHTFLOOR_ON 1
#define LIGHTFLOOR_WHITE 2
#define LIGHTFLOOR_RED 3
#define LIGHTFLOOR_GREEN 4
#define LIGHTFLOOR_YELLOW 5
#define LIGHTFLOOR_BLUE 6
#define LIGHTFLOOR_PURPLE 7

#define LIGHTFLOOR_GENERICCYCLE 8
#define LIGHTFLOOR_CYCLEA 9
#define LIGHTFLOOR_CYCLEB 10

/turf/simulated/floor/light
	name = "Light floor"
	light_range = 5
	icon_state = "light_on"
	floor_tile = /obj/item/stack/tile/light
	broken_states = list("light_broken")
	var/on = 1
	var/state = LIGHTFLOOR_ON
	var/can_modify_colour = TRUE

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
			if(LIGHTFLOOR_GENERICCYCLE)
				icon_state = "light_on-cycle_all"
				set_light(5,null,LIGHT_COLOR_WHITE)
			if(LIGHTFLOOR_CYCLEA)
				icon_state = "light_on-dancefloor_A"
				set_light(5,null,LIGHT_COLOR_RED)
			if(LIGHTFLOOR_CYCLEB)
				icon_state = "light_on-dancefloor_B"
				set_light(5,null,LIGHT_COLOR_DARKBLUE)
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
	if(!can_modify_colour)
		return
	on = !on
	update_icon()

/turf/simulated/floor/light/attackby(obj/item/C, mob/user, params)
	if(istype(C,/obj/item/light/bulb)) //only for light tiles
		if(istype(builtin_tile, /obj/item/stack/tile/light))
			if(!state)
				qdel(C)
				state = LIGHTFLOOR_ON
				update_icon()
				to_chat(user, "<span class='notice'>You replace the light bulb.</span>")
			else
				to_chat(user, "<span class='notice'>The light bulb seems fine, no need to replace it.</span>")
	else
		return ..()

/turf/simulated/floor/light/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!can_modify_colour)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(state != 0)
		if(state < LIGHTFLOOR_PURPLE)
			state++
		else
			state = LIGHTFLOOR_ON
		to_chat(user, "<span class='notice'>You change [src]'s light bulb color.</span>")
		update_icon()
	else
		to_chat(user, "<span class='warning'>[src]'s light bulb appears to have burned out.</span>")

//Cycles through all of the colours
/turf/simulated/floor/light/colour_cycle
	state = LIGHTFLOOR_GENERICCYCLE
	can_modify_colour = FALSE

//Two different "dancefloor" types so that you can have a checkered pattern
// (also has a longer delay than colour_cycle between cycling colours)
/turf/simulated/floor/light/colour_cycle/dancefloor_a
	name = "dancefloor"
	desc = "Funky floor."
	state = LIGHTFLOOR_CYCLEA

/turf/simulated/floor/light/colour_cycle/dancefloor_b
	name = "dancefloor"
	desc = "Funky floor."
	state = LIGHTFLOOR_CYCLEB
