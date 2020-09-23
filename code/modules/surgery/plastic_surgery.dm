/datum/surgery/plastic_surgery
	name = "Plastic Surgery"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/reshape_face, /datum/surgery_step/generic/cauterize)
	possible_locs = list("head")

/datum/surgery/plastic_surgery/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/head/head = H.get_organ(user.zone_selected)
		if(!head)
			return FALSE
		if(head.is_robotic())
			return FALSE
		return TRUE


/datum/surgery_step/reshape_face
	name = "reshape face"
	allowed_tools = list(/obj/item/scalpel = 100, /obj/item/kitchen/knife = 50, /obj/item/wirecutters = 35)
	time = 64

/datum/surgery_step/reshape_face/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to alter [target]'s appearance.", "<span class='notice'>You begin to alter [target]'s appearance...</span>")

/datum/surgery_step/reshape_face/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/head/head = target.get_organ(target_zone)
	var/species_names = target.dna.species.name
	if(head.disfigured)
		head.disfigured = FALSE
		user.visible_message("[user] successfully restores [target]'s appearance!", "<span class='notice'>You successfully restore [target]'s appearance.</span>")
	else
		var/list/names = list()
		var/list_size = 10
		var/obj/item/card/id/ID

		//IDs in hand
		if(istype(user, /mob/living/carbon/human)) //Only 'humans' can hold ID cards
			var/mob/living/carbon/human/H = user
			ID = H.get_id_from_hands()
			if(ID)
				names += ID.registered_name
				list_size-- //To stop list bloat

		//IDs on body
		var/list/ID_list = list()
		for(var/obj/item/I in range(0, target)) //Get ID cards
			if(istype(I, /obj/item/card/id))
				ID_list += I
			else if(istype(I, /obj/item/pda))
				var/obj/item/pda/PDA = I
				if(PDA.id)
					ID_list += PDA.id
			else if(istype(I, /obj/item/storage/wallet))
				var/obj/item/storage/wallet/W = I
				if(W.front_id)
					ID_list += W.front_id

		for(var/I in ID_list) //Add card names to 'names'
			var/obj/item/card/id/Card = I
			ID = Card.registered_name
			if(ID != target.real_name)
				names += ID
				list_size--

		if(!isabductor(user))
			for(var/i in 1 to list_size)
				names += random_name(target.gender, species_names)

		else //Abductors get to pick fancy names
			list_size-- //One less cause they get a normal name too
			for(var/i in 1 to list_size)
				names += "Subject [target.gender == MALE ? "I" : "O"]-[pick("A", "B", "C", "D", "E")]-[rand(10000, 99999)]"
			names += random_name(target.gender, species_names) //give one normal name in case they want to do regular plastic surgery
		var/chosen_name = input(user, "Choose a new name to assign.", "Plastic Surgery") as null|anything in names
		if(!chosen_name)
			return
		var/oldname = target.real_name
		target.real_name = chosen_name
		var/newname = target.real_name	//something about how the code handles names required that I use this instead of target.real_name
		user.visible_message("[user] alters [oldname]'s appearance completely, [target.p_they()] [target.p_are()] now [newname]!", "<span class='notice'>You alter [oldname]'s appearance completely, [target.p_they()] [target.p_are()] now [newname].</span>")
	target.sec_hud_set_ID()
	return TRUE


/datum/surgery_step/reshape_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/head/head = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, tearing skin on [target]'s face with [tool]!</span>", \
						 "<span class='warning'> Your hand slips, tearing skin on [target]'s face with [tool]!</span>")
	target.apply_damage(10, BRUTE, head, sharp = TRUE)
	return FALSE
