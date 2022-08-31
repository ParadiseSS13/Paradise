/obj/item/implant/weapons_auth
	name = "firearms authentication bio-chip"
	desc = "Lets you shoot your guns"
	icon_state = "auth"
	origin_tech = "magnets=2;programming=7;biotech=5;syndicate=5"
	activated = BIOCHIP_ACTIVATED_PASSIVE

/obj/item/implant/weapons_auth/get_data()
	var/dat = {"<b>Bio-chip Specifications:</b><BR>
				<b>Name:</b> Firearms Authentication Bio-chip<BR>
				<b>Life:</b> 4 hours after death of host<BR>
				<b>Bio-chip Details:</b> <BR>
				<b>Function:</b> Allows operation of bio-chip-locked weaponry, preventing equipment from falling into enemy hands."}
	return dat


/obj/item/implant/adrenalin
	name = "adrenal bio-chip"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=4"
	uses = 3

/obj/item/implant/adrenalin/get_data()
	var/dat = {"<b>Bio-chip Specifications:</b><BR>
				<b>Name:</b> Cybersun Industries Adrenaline Bio-chip<BR>
				<b>Life:</b> Five days.<BR>
				<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
				<HR>
				<b>Bio-chip Details:</b> Subjects injected with bio-chip can activate an injection of medical cocktails.<BR>
				<b>Function:</b> Removes stuns, increases speed, and has a mild healing effect.<BR>
				<b>Integrity:</b> Bio-chip can only be used three times before reserves are depleted."}
	return dat

/obj/item/implant/adrenalin/activate()
	uses--
	to_chat(imp_in, "<span class='notice'>You feel a sudden surge of energy!</span>")
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockDown(0)
	imp_in.SetParalysis(0)
	imp_in.adjustStaminaLoss(-75)
	imp_in.stand_up(TRUE)

	imp_in.reagents.add_reagent("synaptizine", 10)
	imp_in.reagents.add_reagent("omnizine", 10)
	imp_in.reagents.add_reagent("stimulative_agent", 10)
	if(!uses)
		qdel(src)


/obj/item/implant/emp
	name = "emp bio-chip"
	desc = "Triggers an EMP."
	icon_state = "emp"
	origin_tech = "biotech=3;magnets=4;syndicate=1"
	uses = 2

/obj/item/implant/emp/activate()
	uses--
	INVOKE_ASYNC(GLOBAL_PROC, .proc/empulse, get_turf(imp_in), 3, 5, 1)
	if(!uses)
		qdel(src)

/obj/item/implant/cortical
	name = "cortical stack"
	desc = "A fist-sized mass of biocircuits and chips."
	icon_state = "implant_evil"
