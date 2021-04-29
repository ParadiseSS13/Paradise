// Initial declaration
/obj/effect/mazegen
	desc = "You should not be seeing this!"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	color = "#00FF00"

// Windows which cant be taken apart. Thes are subtypes of windows so you can have atoms you can walk in at some dirs bit not others
/obj/structure/window/reinforced/mazeglass
	name = "maze glass"
	desc = "You cant take this down. Looks like you have to solve the maze."
	resistance_flags = INDESTRUCTIBLE

// No taking apart
/obj/structure/window/reinforced/mazeglass/tool_act(mob/living/user, obj/item/I, tool_type)
	return FALSE
