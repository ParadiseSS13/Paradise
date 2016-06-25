#define WAND_OPEN "Open Door"
#define WAND_BOLT "Toggle Bolts"
#define WAND_EMERGENCY "Toggle Emergency Access"

/obj/item/weapon/door_remote
	icon_state = "gangtool-white"
	item_state = "electronic"
	icon = 'icons/obj/device.dmi'
	name = "control wand"
	desc = "Remotely controls airlocks."
	w_class = 1
	var/mode = WAND_OPEN
	var/region_access = 1 //See access.dm
	var/obj/item/weapon/card/id/ID

/obj/item/weapon/door_remote/New()
	..()
	ID = new /obj/item/weapon/card/id
	ID.access = get_region_accesses(region_access)

/obj/item/weapon/door_remote/attack_self(mob/user)
	switch(mode)
		if(WAND_OPEN)
			mode = WAND_BOLT
		if(WAND_BOLT)
			mode = WAND_EMERGENCY
		if(WAND_EMERGENCY)
			mode = WAND_OPEN
	to_chat(user, "Now in mode: [mode].")

/obj/item/weapon/door_remote/afterattack(obj/machinery/door/airlock/D, mob/user)
	if(!istype(D))
		return
	if(D.is_special)
		to_chat(user, "<span class='danger'>[src] cannot access this kind of door!</span>")
		return
	if(!(D.arePowerSystemsOn()))
		to_chat(user, "<span class='danger'>[D] has no power!</span>")
		return
	if(!D.requiresID())
		to_chat(user, "<span class='danger'>[D]'s ID scan is disabled!</span>")
		return
	if(D.check_access(src.ID))
		switch(mode)
			if(WAND_OPEN)
				if(D.density)
					D.open()
				else
					D.close()
			if(WAND_BOLT)
				if(D.locked)
					D.unlock()
				else
					D.lock()
			if(WAND_EMERGENCY)
				if(D.emergency)
					D.emergency = 0
				else
					D.emergency = 1
				D.update_icon()
	else
		to_chat(user, "<span class='danger'>[src] does not have access to this door.</span>")

/obj/item/weapon/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	icon_state = "gangtool-yellow"
	region_access = REGION_ALL

/obj/item/weapon/door_remote/captain
	name = "command door remote"
	icon_state = "gangtool-yellow"
	region_access = REGION_COMMAND

/obj/item/weapon/door_remote/chief_engineer
	name = "engineering door remote"
	icon_state = "gangtool-orange"
	region_access = REGION_ENGINEERING

/obj/item/weapon/door_remote/research_director
	name = "research door remote"
	icon_state = "gangtool-purple"
	region_access = REGION_RESEARCH

/obj/item/weapon/door_remote/head_of_security
	name = "security door remote"
	icon_state = "gangtool-red"
	region_access = REGION_SECURITY

/obj/item/weapon/door_remote/quartermaster
	name = "supply door remote"
	icon_state = "gangtool-green"
	region_access = REGION_SUPPLY

/obj/item/weapon/door_remote/chief_medical_officer
	name = "medical door remote"
	icon_state = "gangtool-blue"
	region_access = REGION_MEDBAY

/obj/item/weapon/door_remote/civillian
	name = "civillian door remote"
	icon_state = "gangtool-white"
	region_access = REGION_GENERAL

/obj/item/weapon/door_remote/centcomm
	name = "centcomm door remote"
	desc = "High-ranking NT officials only."
	icon_state = "gangtool-blue"
	region_access = REGION_CENTCOMM

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY


/obj/item/weapon/parolesuit_control
	icon_state = "gangtool-red"
	item_state = "electronic"
	icon = 'icons/obj/device.dmi'
	name = "parole suit control wand"
	desc = "Remotely controls parole jumpsuits."
	w_class = 1
	var/emagged = 0

/obj/item/weapon/parolesuit_control/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		to_chat(user,"<span class='danger'>[src] only works on humanoids.</span>")
		return
	if (!istype(H.w_uniform, /obj/item/clothing/under/color/yellow/parole))
		to_chat(user,"<span class='danger'>[H] is not wearing a parole jumpsuit.</span>")
		return
	var/obj/item/clothing/under/color/yellow/parole/J = H.w_uniform
	var/obj/item/weapon/card/id/I = H.get_item_by_slot(slot_wear_id)
	if (!istype(I))
		to_chat(user,"<span class='danger'>[H] is not wearing an ID.</span>")
		return
	if (J.emagged)
		to_chat(user, "<span class='danger'>[J] emits an error tone.</span>")
	else if (J.emped)
		to_chat(user, "<span class='danger'>The circuits on [J] appear to be fried.</span>")
	else if (J.parole_locked && J.flags & NODROP && I.flags & NODROP)
		J.unlock()
	else if (access_heads in I.access)
		to_chat(user, "<span class='danger'>[J] cannot be locked on someone wearing an ID with head access. They might need to use their ID on a keycard swiper.")
		return
	else if (access_security in I.access)
		to_chat(user, "<span class='danger'>[J] cannot be locked on someone wearing an ID with security access.")
		return
	else if (!J.parole_locked && !(J.flags & NODROP) && !(I.flags & NODROP))
		J.lock(I)
	else
		to_chat(user,"<span class='danger'>[src] emits a loud buzzzing sound! Its display reads: jumpsuit/ID lock desynched.</span>")
