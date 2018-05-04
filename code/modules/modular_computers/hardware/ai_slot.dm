/obj/item/computer_hardware/ai_slot
	name = "intelliCard interface slot"
	desc = "A module allowing this computer to interface with most common intelliCard modules. Necessary for some programs to run properly."
	power_usage = 100 //W
	icon_state = "card_mini"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "programming=2"
	device_type = MC_AI

	var/obj/item/aicard/stored_card = null
	var/locked = FALSE

/obj/item/computer_hardware/ai_slot/Destroy()
	QDEL_NULL(stored_card)
	return ..()


/obj/item/computer_hardware/ai_slot/examine(mob/user)
	..()
	if(stored_card)
		to_chat(user, "There appears to be an intelliCard loaded. There appears to be a pinhole protecting a manual eject button. A screwdriver could probably press it")

/obj/item/computer_hardware/ai_slot/on_install(obj/item/modular_computer/M, mob/living/user = null)
	M.add_verb(device_type)

/obj/item/computer_hardware/ai_slot/on_remove(obj/item/modular_computer/M, mob/living/user = null)
	M.remove_verb(device_type)
	try_eject(0, forced = 1)

/obj/item/computer_hardware/ai_slot/try_insert(obj/item/I, mob/living/user = null)
	if(!holder)
		return FALSE

	if(!istype(I, /obj/item/aicard))
		return FALSE

	if(stored_card)
		if(user)
			to_chat(user, "<span class='warning'>You try to insert \the [I] into \the [src], but the slot is occupied.</span>")
		return FALSE
	if(user && !user.unEquip(I))
		return FALSE

	I.forceMove(src)
	stored_card = I
	if(user)
		to_chat(user, "<span class='notice'>You insert \the [I] into \the [src].</span>")

	return TRUE


/obj/item/computer_hardware/ai_slot/try_eject(slot=0, mob/living/user = null, forced = 0)
	if(!stored_card)
		if(user)
			to_chat(user, "<span class='warning'>There is no card in \the [src].</span>")
		return FALSE

	if(locked && !forced)
		if(user)
			to_chat(user, "<span class='warning'>Safeties prevent you from removing the card until reconstruction is complete...</span>")
		return FALSE

	if(stored_card)
		stored_card.forceMove(get_turf(src))
		locked = FALSE
		stored_card.verb_pickup()
		stored_card = null

		if(user)
			to_chat(user, "<span class='notice'>You remove the card from \the [src].</span>")
		return TRUE
	return FALSE

/obj/item/computer_hardware/ai_slot/attackby(obj/item/I, mob/living/user)
	if(..())
		return
	if(istype(I, /obj/item/screwdriver))
		to_chat(user, "<span class='notice'>You press down on the manual eject button with \the [I].</span>")
		try_eject(0, user, 1)
		return