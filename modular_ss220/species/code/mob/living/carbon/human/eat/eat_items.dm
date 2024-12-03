/obj/item
	var/material_type = MATERIAL_CLASS_NONE
	var/bites_limit = 1 			//The maximum amount of bites before item is depleted
	var/current_bites = 0	//How many bites did
	var/integrity_bite = 10		// Integrity used
	var/nutritional_value = 20 	// How much nutrition add
	var/is_only_grab_intent = FALSE	//Grab if help_intent was used
	var/is_examine_bites = TRUE

	// Healing Special Effect
	var/overall_heal_amount = 0
	var/fracture_repair_probability = 5

/obj/item/examine(mob/user)
	var/material_string = item_string_material(user)
	. = ..(user, "", material_string)

/obj/item/attack__legacy__attackchain(mob/living/target, mob/living/user, def_zone)
	if(check_item_eat(target, user))
		try_item_eat(target, user)
		return TRUE
	. = ..()

/obj/item/proc/check_item_eat(mob/target, mob/user)
	switch(material_type)
		if(MATERIAL_CLASS_NONE)
			return FALSE
		if(MATERIAL_CLASS_CLOTH)
			return ismoth(target)
		if(MATERIAL_CLASS_TECH)
			return isvox(target)
		if(MATERIAL_CLASS_SOAP)
			return isdrask(target)
		if(MATERIAL_CLASS_PLASMA)
			return isplasmaman(target)
		if(MATERIAL_CLASS_RAD)
			return isnucleation(target)
	if(is_only_grab_intent && user.a_intent != INTENT_GRAB)
		return FALSE
	return TRUE

/obj/item/proc/item_string_material(mob/user)
	var/material_string
	var/material_promt = "Вкуснятина! [is_only_grab_intent ? "\nНужно аккуратно есть." : ""]"
	switch(material_type)
		if(MATERIAL_CLASS_CLOTH)
			material_string = "\nТканевый предмет. [ismoth(user) ? material_promt : ""]"
		if(MATERIAL_CLASS_TECH)
			material_string = "\nТехнологичный предмет. [isvox(user) ? material_promt : ""]"
		if(MATERIAL_CLASS_SOAP)
			material_string = "\nМыльный предмет. [isdrask(user) ? material_promt : ""]"
		if(MATERIAL_CLASS_PLASMA)
			material_string = "\nПлазменный предмет. [isdrask(user) ? material_promt : ""]"
		if(MATERIAL_CLASS_RAD)
			material_string = "\nРадиоактивный предмет. [isdrask(user) ? material_promt : ""]"

	if(is_examine_bites)
		var/bites_split = bites_limit > 3 ? round(bites_limit / 4) : 1
		var/bites_damage_string = ""
		if(current_bites >= 1 && current_bites <= bites_split)
			bites_damage_string = "Выглядит покусанным..."
		else if(current_bites >= bites_split && current_bites <= (bites_split * 2))
			bites_damage_string = "Видны оторванные части..."
		else if((current_bites >= bites_split * 2) && current_bites <= (bites_split * 3))
			bites_damage_string = "Видна внутренняя часть..."
		else if(current_bites >= bites_split * 3)
			bites_damage_string = "Осталась одна труха..."
		material_string += "\n[bites_damage_string]"

	return material_string


/obj/item/proc/try_item_eat(mob/living/carbon/target, mob/user)
	if(ishuman(target) && item_eat(target, user))
		return TRUE
	return FALSE

//Eat all thing in my hand
/obj/item/proc/item_eat(mob/living/carbon/target, mob/user)
	if(!check_item_eat(target, user))
		return FALSE

	var/chat_message_to_user = "Вы кормите [target] [src.name]."
	var/chat_message_to_target = "[user] покормил вас [src.name]."
	switch(user.a_intent)
		if(INTENT_HELP, INTENT_GRAB)
			if(target.nutrition >= NUTRITION_LEVEL_FULL)
				chat_message_to_user = "В [target == user ? "вас" : target] больше не лезет [src.name]. [target == user ? "Вы" : target] наел[target == user ? "ись" : "ся"]!"
				return FALSE
			else if(target == user)
				chat_message_to_user = "Вы откусили от [src.name]. Вкуснятина!"
		if(INTENT_HARM)
			chat_message_to_user = "В [target == user ? "вас" : target] больше не лезет. Но [target == user ? "вы" : user] насильно запихива[target == user ? "ете" : "ет"] [src.name] в рот!"
			if(target != user)
				chat_message_to_target = "В ваш рот насильно запихивают [src.name]!"
			if(target.nutrition >= NUTRITION_LEVEL_FULL)
				target.vomit(nutritional_value + 20)
				target.adjustStaminaLoss(15)

	if(target != user)
		if(!forceFed(target, user, FALSE))
			return FALSE
		to_chat(target, "<span class='notice'>[chat_message_to_target]</span>")
		add_attack_logs(user, src, "Force Fed [target], item [src]")

	to_chat(user, "<span class='notice'>[chat_message_to_user]</span>")

	playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)
	target.adjust_nutrition(nutritional_value)
	item_bite(target, user)
	if(overall_heal_amount > 0)
		item_heal(target)

	SSticker.score.score_food_eaten++
	return TRUE

/obj/item/proc/item_bite(mob/living/carbon/target, mob/user)
	current_bites++
	colour_change()
	obj_integrity = max(obj_integrity - integrity_bite, 0)
	if(current_bites >= bites_limit)
		to_chat(user, "<span class='notice'>[target == user ? "Вы доели" : "[target] доел"] [src.name].</span>")
		qdel(src)

/obj/item/proc/forceFed(mob/living/carbon/target, mob/user, instant_application = FALSE)
	if(!instant_application)
		visible_message("<span class='warning'>[user] пытается накормить [target], запихивая в рот [src.name].</span>")

	if(!instant_application)
		if(!do_mob(user, target, 2 SECONDS))
			return 0
	return 1

/obj/item/proc/colour_change()
	var/bites_split = bites_limit > 3 ? round(bites_limit / 4) : 1
	var/colour
	if(current_bites >= 1 && current_bites <= bites_split)
		colour = "#d9e0e7ff"
	else if(current_bites >= bites_split && current_bites <= (bites_split * 2))
		colour = "#b7c3ccff"
	else if((current_bites >= bites_split * 2) && current_bites <= (bites_split * 3))
		colour = "#929eabff"
	else if(current_bites >= bites_split * 3)
		colour = "#697581ff"

	if(colour)
		add_atom_colour(colour, FIXED_COLOUR_PRIORITY)

/obj/item/proc/item_heal(mob/living/carbon/human/H)
	H.heal_overall_damage(overall_heal_amount, overall_heal_amount)
	if(prob(fracture_repair_probability)) // 5% chance per proc to find a random limb, and mend it
		var/list/our_organs = H.bodyparts.Copy()
		shuffle(our_organs)
		for(var/obj/item/organ/external/L in our_organs)
			if(L.mend_fracture())
				break // We're only checking one limb here, bucko
