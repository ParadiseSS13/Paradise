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

		var/wish = input("You want to...","Wish") as null|anything in list("Protect the innocent","Hunt the guilty")
		switch(wish)
			if("Protect the innocent")
				var/datum/objective/protect/protect = new
				protect.owner = user.mind
				user.mind.objectives += protect

			if("Hunt the guilty")
				var/datum/objective/assassinate/assasinate = new
				assasinate.owner = user.mind
				user.mind.objectives += assasinate

		var/obj_count = 1
		for(var/datum/objective/OBJ in user.mind.objectives)
			user << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
			obj_count++

		user << "As a superhero, you are allowed to pick an appropriate pseudonym for your new role. A costume is also strongly encouraged."
		user.rename_self()

		charges--
		insisting = 0

		if (!(M_HULK in user.mutations))
			user.dna.SetSEState(HULKBLOCK,1)

		if (!(M_LASER in user.mutations))
			user.mutations.Add(M_LASER)

		if (!(M_XRAY in user.mutations))
			user.mutations.Add(M_XRAY)
			user.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
			user.see_in_dark = 8
			user.see_invisible = SEE_INVISIBLE_LEVEL_TWO

		if (!(M_RESIST_COLD in user.mutations))
			user.mutations.Add(M_RESIST_COLD)

		if (!(M_RESIST_HEAT in user.mutations))
			user.mutations.Add(M_RESIST_HEAT)

		if (!(M_TK in user.mutations))
			user.mutations.Add(M_TK)

		if(!(M_REGEN in user.mutations))
			user.mutations.Add(M_REGEN)

		user.update_mutations()

	return