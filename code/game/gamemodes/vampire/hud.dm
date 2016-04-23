/datum/hud/proc/vampire_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')

	vampire_blood_display = new /obj/screen()
	vampire_blood_display.name = "Usable Blood"
	vampire_blood_display.icon_state = "power_display"
	vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
	vampire_blood_display.layer = 20

	mymob.client.screen += list(vampire_blood_display)

/datum/hud/proc/remove_vampire_hud()
	if(!vampire_blood_display)
		return

	mymob.client.screen -= list(vampire_blood_display)
	qdel(vampire_blood_display)
	vampire_blood_display = null