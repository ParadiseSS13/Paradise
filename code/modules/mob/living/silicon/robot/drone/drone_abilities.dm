// DRONE ABILITIES
/mob/living/silicon/robot/drone/verb/set_mail_tag()
	set name = "Set Mail Tag"
	set desc = "Tag yourself for delivery through the disposals system."
	set category = "Drone"

	var/tag = input("Select the desired destination.", "Set Mail Tag", null) as null|anything in TAGGERLOCATIONS

	if(!tag || TAGGERLOCATIONS[tag])
		mail_destination = 0
		return

	src << "\blue You configure your internal beacon, tagging yourself for delivery to '[tag]'."
	mail_destination = TAGGERLOCATIONS.Find(tag)

	//Auto flush if we use this verb inside a disposal chute.
	var/obj/machinery/disposal/D = src.loc
	if(istype(D))
		src << "\blue \The [D] acknowledges your signal."
		D.flush_count = D.flush_every_ticks

	return

/mob/living/silicon/robot/drone/verb/hide()
	set name = "Hide"
	set desc = "Allows you to hide beneath tables or certain items. Toggled on or off."
	set category = "Drone"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\blue You are now hiding.")
	else
		layer = MOB_LAYER
		src << text("\blue You have stopped hiding.")

/mob/living/silicon/robot/drone/verb/light()
	set name = "Light On/Off"
	set desc = "Activate a low power omnidirectional LED. Toggled on or off."
	set category = "Drone"

	if(luminosity)
		SetLuminosity(0)
		return
	SetLuminosity(2)

//Actual picking-up event.
/mob/living/silicon/robot/drone/attack_hand(mob/living/carbon/human/M as mob)

	if(M.a_intent == "help")
		var/obj/item/weapon/holder/drone/D = new(loc)
		src.loc = D
		D.attack_hand(M)
		M << "You scoop up [src]."
		src << "[M] scoops you up."
		M.status_flags |= PASSEMOTES
		return

	..()