// DRONE ABILITIES
/mob/living/silicon/robot/drone/verb/set_mail_tag()
	set name = "Set Mail Tag"
	set desc = "Tag yourself for delivery through the disposals system."
	set category = "Drone"

	var/tag = input("Select the desired destination.", "Set Mail Tag", null) as null|anything in GLOB.TAGGERLOCATIONS

	if(!tag || GLOB.TAGGERLOCATIONS[tag])
		mail_destination = 0
		return

	to_chat(src, "<span class='notice'>You configure your internal beacon, tagging yourself for delivery to '[tag]'.</span>")
	mail_destination = GLOB.TAGGERLOCATIONS.Find(tag)

	//Auto flush if we use this verb inside a disposal chute.
	var/obj/machinery/disposal/D = src.loc
	if(istype(D))
		to_chat(src, "<span class='notice'>\The [D] acknowledges your signal.</span>")
		D.flush_count = D.flush_every_ticks

	return

/mob/living/silicon/robot/drone/verb/hide()
	set name = "Hide"
	set desc = "Allows you to hide beneath tables or certain items. Toggled on or off."
	set category = "Drone"

	if(layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

/mob/living/silicon/robot/drone/verb/light()
	set name = "Light On/Off"
	set desc = "Activate a low power omnidirectional LED. Toggled on or off."
	set category = "Drone"

	if(lamp_intensity)
		lamp_intensity = lamp_max // setting this to lamp_max will make control_headlamp shutoff the lamp
	control_headlamp()

//Actual picking-up event.
/mob/living/silicon/robot/drone/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	else
		..()

/mob/living/silicon/robot/drone/verb/customize()
	set name = "Customize Chassis"
	set desc = "Reconfigure your chassis into a customized version."
	set category = "Drone"

	if(!custom_sprite) //Check to see if custom sprite time, checking the appopriate file to change a var
		var/file = file2text("config/custom_sprites.txt")
		var/lines = splittext(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = splittext(line, ":")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2 || Entry[1] != "drone")
				continue

			if (Entry[2] == ckey) //Custom holograms
				custom_sprite = 1  // option is given in hologram menu

	if(!custom_sprite)
		to_chat(src, "<span class='warning'>Error 404: Custom chassis not found. Revoking customization option.</span>")
	else
		icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		icon_state = "[ckey]-drone"
		to_chat(src, "<span class='notice'>You reconfigure your chassis and improve the station through your new aesthetics.</span>")
	verbs -= /mob/living/silicon/robot/drone/verb/customize

/mob/living/silicon/robot/drone/get_scooped(mob/living/carbon/grabber)
	var/obj/item/holder/H = ..()
	if(!istype(H))
		return
	if(resting)
		resting = 0
	if(custom_sprite)
		H.icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		H.icon_override = 'icons/mob/custom_synthetic/custom_head.dmi'
		H.lefthand_file = 'icons/mob/custom_synthetic/custom_lefthand.dmi'
		H.righthand_file = 'icons/mob/custom_synthetic/custom_righthand.dmi'
		H.icon_state = "[icon_state]"
		H.item_state = "[icon_state]_hand"
	else if(emagged)
		H.icon_state = "drone-emagged"
		H.item_state = "drone-emagged"
	else
		H.icon_state = "drone"
		H.item_state = "drone"
	grabber.put_in_active_hand(H)//for some reason unless i call this it dosen't work
	grabber.update_inv_l_hand()
	grabber.update_inv_r_hand()

	return H