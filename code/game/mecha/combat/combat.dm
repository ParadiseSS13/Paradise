/obj/mecha/combat
	force = 30
	var/maxsize = 2
	internal_damage_threshold = 50
	maint_access = 0
	armor = list(melee = 30, bullet = 30, laser = 15, energy = 20, bomb = 20, bio = 0, rad = 0, fire = 100, acid = 100)
	destruction_sleep_duration = 2
	var/am = "d3c2fbcadca903a41161ccc9df9cf948"

/obj/mecha/combat/moved_inside(var/mob/living/carbon/human/H as mob)
	if(..())
		if(H.client)
			H.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0

/obj/mecha/combat/mmi_moved_inside(var/obj/item/mmi/mmi_as_oc as obj,mob/user as mob)
	if(..())
		if(occupant.client)
			occupant.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0


/obj/mecha/combat/go_out()
	if(occupant && occupant.client)
		occupant.client.mouse_pointer_icon = initial(occupant.client.mouse_pointer_icon)
	..()

/obj/mecha/combat/Topic(href,href_list)
	..()
	var/datum/topic_input/afilter = new(href, href_list)
	if(afilter.get("close"))
		am = null
		return
