/obj/machinery/wish_granter
	name = "Wish Granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	use_power = 0
	anchored = 1
	density = 1

	var/charges = 1
	var/insisting = 0

/obj/machinery/wish_granter/attack_hand(var/mob/user as mob)
	usr.set_machine(src)

	if(charges <= 0)
		user << "The Wish Granter lies silent."
		return

	else if(!istype(user, /mob/living/carbon/human))
		user << "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's."
		return

	else if(is_special_character(user))
		user << "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away."

	else if (!insisting)
		user << "Your first touch makes the Wish Granter stir, listening to you.  Are you really sure you want to do this?"
		insisting++

	else
		user << "The power of the Wish Granter have turned you into the superhero the station deserves. You are a masked vigilante, and answer to no man. Will you use your newfound strength to protect the innocent, or will you hunt the guilty?"

		ticker.mode.traitors += user.mind
		user.mind.special_role = "The Hero The Station Deserves"


		var/mob/living/carbon/human/M = user

		var/wish = input("You want to...","Wish") as anything in list("Protect the innocent","Hunt the guilty")
		switch(wish)
			if("Protect the innocent")
				M.fully_replace_character_name(M.real_name, "Owlman")

				var/datum/objective/protect/protect = new
				protect.owner = user.mind
				user.mind.objectives += protect

				for(var/obj/item/W in M)
					M.unEquip(W)

				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/owl(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/owlwings(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/owl_mask(M), slot_wear_mask)

				var/obj/item/weapon/card/id/syndicate/W = new(M)
				W.name = "[M.real_name]'s ID Card (Superhero)"
				W.access = get_all_accesses()
				W.assignment = "Superhero"
				W.registered_name = M.real_name
				M.equip_to_slot_or_del(W, slot_wear_id)

				M.regenerate_icons()

			if("Hunt the guilty")
				M.fully_replace_character_name(M.real_name, "The Griffin")

				var/datum/objective/assassinate/assasinate = new
				assasinate.owner = user.mind
				user.mind.objectives += assasinate

				for(var/obj/item/W in M)
					M.unEquip(W)

				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/griffin(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/griffin(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/owlwings/griffinwings(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/griffin(M), slot_head)

				var/obj/item/weapon/card/id/syndicate/W = new(M)
				W.name = "[M.real_name]'s ID Card (Supervillain)"
				W.access = get_all_accesses()
				W.assignment = "Supervillain"
				W.registered_name = M.real_name
				M.equip_to_slot_or_del(W, slot_wear_id)

				M.regenerate_icons()

		var/obj_count = 1
		for(var/datum/objective/OBJ in user.mind.objectives)
			user << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
			obj_count++

		charges--
		insisting = 0

		if (!(HULK in user.mutations))
			user.dna.SetSEState(HULKBLOCK,1)

		if (!(LASER in user.mutations))
			user.mutations.Add(LASER)

		if (!(XRAY in user.mutations))
			user.mutations.Add(XRAY)
			user.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
			user.see_in_dark = 8
			user.see_invisible = SEE_INVISIBLE_LEVEL_TWO

		if (!(RESIST_COLD in user.mutations))
			user.mutations.Add(RESIST_COLD)

		if (!(RESIST_HEAT in user.mutations))
			user.mutations.Add(RESIST_HEAT)

		if (!(TK in user.mutations))
			user.mutations.Add(TK)

		if(!(REGEN in user.mutations))
			user.mutations.Add(REGEN)

		user.update_mutations()

	return