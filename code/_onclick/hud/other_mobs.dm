
/datum/hud/proc/unplayer_hud()
	return

/datum/hud/proc/ghost_hud()
	return

/datum/hud/proc/brain_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')
	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.layer = 0


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

	mymob.client.screen = null

	mymob.client.screen += list(blobpwrdisplay, blobhealthdisplay)


/mob/proc/update_power_buttons() // These spell buttons will be used for all sorts of abilities from ghost abilities to simple_mob abilities. It shouldn't be human only
	var/num = 1
	if(!hud_used) return
	if(!client) return

	if(!hud_used.hud_shown)	//Hud toggled to minimal
		return

	client.screen -= hud_used.power_action_list

	hud_used.power_action_list = list()
	for(var/obj/effect/proc_holder/spell/wizard/S in spell_list)
		if(S.icon_power_button)
			var/obj/screen/power_action/P = new(hud_used)
			P.icon = 'icons/mob/screen1_action.dmi'
			P.icon_state = S.icon_power_button
			if(S.charge_counter != S.charge_max)
				P.icon = 'icons/mob/screen1_action.dmi'
				P.icon_state = S.icon_power_button
				var/icon/newicon = new(P.icon, P.icon_state)
				newicon.GrayScale()
				P.icon = newicon
			else
				P.icon = 'icons/mob/screen1_action.dmi'
				P.icon_state = S.icon_power_button


			if(S.power_button_name)
				P.name = S.power_button_name
			else
				P.name = "Use [S.name]"
			P.owner = S

			hud_used.power_action_list += P

			switch(num)
				if(1)
					P.screen_loc = ui_power_slot1
				if(2)
					P.screen_loc = ui_power_slot2
				if(3)
					P.screen_loc = ui_power_slot3
				if(4)
					P.screen_loc = ui_power_slot4
				if(5)
					P.screen_loc = ui_power_slot5
				if(6)
					P.screen_loc = ui_power_slot6
				if(7)
					P.screen_loc = ui_power_slot7
				if(8)
					P.screen_loc = ui_power_slot8
				if(9)
					P.screen_loc = ui_power_slot9
				if(10)
					P.screen_loc = ui_power_slot10
					break //5 slots available, so no more can be added.
			num++
	src.client.screen += src.hud_used.power_action_list