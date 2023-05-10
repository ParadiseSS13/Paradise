/obj/screen/wind_up_timer
	name = "Windup"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "windup_display-1"
	screen_loc = ui_cogscarab_timer

/obj/screen/wind_up_timer/examine(mob/user, infix, suffix)
	. = ..()
	var/mob/living/silicon/robot/cogscarab/cog = user
	. += "<span class='notice'>Windup time: [cog.wind_up_timer].</span><BR>"
