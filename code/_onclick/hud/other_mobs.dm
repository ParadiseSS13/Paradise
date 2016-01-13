
/datum/hud/proc/unplayer_hud()
	return

/datum/hud/proc/ghost_hud()
	return

/datum/hud/proc/corgi_hud(u)
	mymob.fire = new /obj/screen()
	mymob.fire.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_construct_pull

	mymob.oxygen = new /obj/screen()
	mymob.oxygen.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.toxin = new /obj/screen()
	mymob.toxin.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin

	mymob.client.screen = null

	mymob.client.screen += list(mymob.fire, mymob.healths, mymob.pullin, mymob.oxygen, mymob.toxin)

/datum/hud/proc/brain_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')
	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "CENTER-7,CENTER-7"
	mymob.blind.layer = 0
	mymob.blind.mouse_opacity = 0


/datum/hud/proc/blob_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')

	blobpwrdisplay = new /obj/screen()
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.layer = 20

	blobhealthdisplay = new /obj/screen()
	blobhealthdisplay.name = "blob health"
	blobhealthdisplay.icon_state = "block"
	blobhealthdisplay.screen_loc = ui_internal
	blobhealthdisplay.layer = 20

	mymob.client.screen = list()

	mymob.client.screen += list(blobpwrdisplay, blobhealthdisplay)
	mymob.client.screen += mymob.client.void