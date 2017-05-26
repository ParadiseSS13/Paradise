/obj/item/weapon/implant/weapons_auth
	name = "firearms authentication implant"
	desc = "Lets you shoot your guns"
	icon_state = "auth"
	origin_tech = "materials=2;magnets=2;programming=2;biotech=5;syndicate=5"
	activated = 0

/obj/item/weapon/implant/weapons_auth/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Firearms Authentication Implant<BR>
				<b>Life:</b> 4 hours after death of host<BR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Allows operation of implant-locked weaponry, preventing equipment from falling into enemy hands."}
	return dat


/obj/item/weapon/implant/adrenalin
	name = "adrenal implant"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=4"
	uses = 3

/obj/item/weapon/implant/adrenalin/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Cybersun Industries Adrenaline Implant<BR>
				<b>Life:</b> Five days.<BR>
				<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
				<HR>
				<b>Implant Details:</b> Subjects injected with implant can activate an injection of medical cocktails.<BR>
				<b>Function:</b> Removes stuns, increases speed, and has a mild healing effect.<BR>
				<b>Integrity:</b> Implant can only be used three times before reserves are depleted."}
	return dat

/obj/item/weapon/implant/adrenalin/activate()
	uses--
	to_chat(imp_in, "<span class='notice'>You feel a sudden surge of energy!</span>")
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetParalysis(0)
	imp_in.adjustStaminaLoss(-75)
	imp_in.lying = 0
	imp_in.update_canmove()

	imp_in.reagents.add_reagent("synaptizine", 10)
	imp_in.reagents.add_reagent("omnizine", 10)
	imp_in.reagents.add_reagent("stimulative_agent", 10)
	if(!uses)
		qdel(src)


/obj/item/weapon/implant/emp
	name = "emp implant"
	desc = "Triggers an EMP."
	icon_state = "emp"
	origin_tech = "materials=2;biotech=3;magnets=4;syndicate=4"
	uses = 2

/obj/item/weapon/implant/emp/activate()
	uses--
	empulse(imp_in, 3, 5)
	if(!uses)
		qdel(src)

/obj/item/weapon/implant/cortical
	name = "cortical stack"
	desc = "A fist-sized mass of biocircuits and chips."
	icon_state = "implant_evil"

/obj/item/weapon/implant/teleport
	name = "teleport implant"
	desc = "Teleport to random location."
	icon_state = "teleport"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=4"
	uses = 3

/obj/item/weapon/implant/teleport/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Cybersun Industries Teleport Implant<BR>
				<b>Life:</b> Five days.<BR>
				<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
				<HR>
				<b>Implant Details:</b> Made from components salvaged from a nuke disk<BR>
				<b>Function:</b> Teleports user to a random location<BR>
				<b>Integrity:</b> Implant can only be used three times before reserves are depleted."}
	return dat

/obj/item/weapon/implant/teleport/activate()
	if(uses < 1)
		return 0
	uses--
	imp_in.visible_message("<span class='warning'>[imp_in] disappears in a flash of light!</span>", "<span class='warning'>You activate [src], teleporting you to a random location</span>")
	imp_in.forceMove(get_turf(pick(blobstart)))

/obj/item/weapon/implant/teleport/emp_act(severity)
	if(uses < 1)
		return
	uses--
	imp_in.visible_message("<span class='warning'>[imp_in] disappears in a flash of light!</span>", "<span class='warning'>[src] malfunctions, teleporting you!</span>")
	imp_in.forceMove(locate(rand(1,255), rand(1,255), 1)) // Teleport user to random location on z-1