
/proc/human_roll_mods(var/mob/living/carbon/human/H)
	var/BaseMath = 0
	if(H.handcuffed)
		BaseMath -= rand(0,2)
	if(H.legcuffed)
		BaseMath -= rand(0,2)
	if(H.intent == INTENT_HARM)
		BaseMath += rand(1,3)
	if(H.IsStunned())
		BaseMath -= rand(4,2)
	switch(H.nutrition)
		if(400 to 550)
			BaseMath += pick(0,1)
		if(220 to 275)
			BaseMath += pick(-1,0)
		if(150 to 220)
			BaseMath += pick(-1,0)
		if(100 to 150)
			BaseMath += pick(-2,-0)
		if(1 to 100)
			BaseMath += pick(-3,-2)
		if(-INFINITY to 1)
			BaseMath += pick(-4, -3)
	return BaseMath

/proc/roll_dice(sides, successcheck = FALSE, crit_successcheck = FALSE, amount = 1, mod = 0)
	var/result = 0
	var/highest = 0
	var/slice = highest % 2
	highest = amount * sides
	result = rand(amount, highest)
	var/dice_result = 0
	dice_result = result
	result += mod
	if(successcheck)
		if(result > slice)
			return TRUE
		else
			return FALSE
	if(crit_successcheck)
		return check_crittable(sides, amount, result, mod)
	else
		return result

/proc/check_crittable(sides, amount, result, mod)
	if(sides == 20 && amount == 1)
		switch(mod)
			if(1 to 15)
				if(result >= 20)
					return TRUE
			if(16 to INFINITY)
				if(result >= 19)
					return TRUE
		switch(mod)
			if(1 to 3)
				if(result <= 4)
					return FALSE
			if(4)
				if(result <= 3)
					return FALSE
			if(5)
				if(result <= 2)
					return FALSE
			if(6 to INFINITY)
				if(result <= 1)
					return FALSE
	if(sides == 6 && amount == 3)
		switch(mod)
			if(3 to 14)
				if(result <= 4)
					return TRUE
			if(15)
				if(result <= 5)
					return TRUE
			if(16 to INFINITY)
				if(result <= 6)
					return TRUE
		switch(mod)
			if(3)
				if(result >= 13)
					return FALSE
			if(4)
				if(result >= 14)
					return FALSE
			if(5)
				if(result >= 15)
					return FALSE
			if(6)
				if(result >= 16)
					return FALSE
			if(7 to 15)
				if(result >= 17)
					return FALSE
			if(16 to INFINITY)
				if(result >= 18)
					return FALSE

/proc/skillcheck(var/mob/living/carbon/human/H, skilltocheck)


/proc/prob2()
	var/value1 = 0
	var/result = 0
	value1 = rand(0,100)
	result = prob(value1)
	return result

/proc/adjustskill(var/mob/living/carbon/human/H, skill, amount)
	var/datum/skills/skilldat = H.skills
	var/datum/hud/human/hud =H.hud_used
	switch(skill)
		if("strength")
			skilldat.strength += amount
		if("intelligence")
			skilldat.intelligence += amount
		if("wisdom")
			skilldat.wisdom += amount
		if("dexterity")
			skilldat.dexterity += amount
		if("perception")
			skilldat.perception += amount
			var/obj/screen/fullscreen/noise/N = H.screens["noise"]
			N.icon_state = addtext(num2text(9 - skilldat.perception), "j")
	hud.refreshskills()

/proc/setskill(var/mob/living/carbon/human/H, skill, amount)
	var/datum/skills/skilldat = H.skills
	var/datum/hud/human/hud = H.hud_used
	switch(skill)
		if("strength")
			skilldat.strength = amount
		if("intelligence")
			skilldat.intelligence = amount
		if("wisdom")
			skilldat.wisdom = amount
		if("dexterity")
			skilldat.dexterity = amount
		if("perception")
			skilldat.perception = amount
			var/obj/screen/fullscreen/noise/N = H.screens["noise"]
			N.icon_state = addtext(num2text(9 - skilldat.perception), "j")
	hud.refreshskills()

/datum/skills
	var/wisdom = 0
	var/strength = 0
	var/intelligence = 0
	var/dexterity = 10
	var/perception = 5

/mob/living/Carbon/human/verb/teach(/mob/living/Carbon/human/H)
	set category = null
	set name = "Teach"
	set desc = "Teach someone your skills."
	set src in view(1)

// objects //

/obj/item/paper/verb/teachpaper()
	set name = "Project knowledge"
	set category = "Object"
	set src in usr
	add_fingerprint(usr)
	var/mob/living/carbon/human/H = usr
	var/obj/item/P = H.get_active_hand()
	if(is_pen(P))
		visible_message("[usr] begins to scrawl onto the [src]")
		if(do_after_once(H, H.skills.intelligence * H.skills.wisdom SECONDS, 1, src, 1, "you decide not to write anything down"))
			visible_message("[usr] finishes scrawling onto the [src]")
			qdel(src)
			var/obj/item/research/R = new /obj/item/research/
			R.wisdom = H.skills.wisdom
			R.intelligence = H.skills.intelligence
			if(H.hand)
				H.equip_to_slot_or_del(R, slot_r_hand)
			else
				H.equip_to_slot_or_del(R, slot_l_hand)
			R.add_fingerprint(user)
			to_chat(H, "you write down all of your knowledge onto this [src]")
	else
		to_chat(H, "you need to use a pen for this")


/obj/item/research
	name = "Research Paper"
	desc = "A fragment of knowledge"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_words"
	item_state = "paper_words"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	resistance_flags = FLAMMABLE
	max_integrity = 50
	blocks_emissive = null
	attack_verb = list("bapped")
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	var/wisdom
	var/intelligence

/obj/item/research/attacked_by(obj/item/I, mob/living/user)
	add_fingerprint(user)
	var/mob/living/carbon/human/H = user
	if(istype(I, /obj/item/research))
		var/obj/item/research/P = I
		if(wisdom == P.wisdom & intelligence == P.intelligence)
			visible_message("[user] begins to study both of the [src] together")
			if(do_after_once(H, H.skills.intelligence * H.skills.wisdom SECONDS, 1, src, 1, "you decide not to study"))
				visible_message("[user] combines the [src]")
				qdel(src)
				qdel(P)
				var/obj/item/paper_bundle/B = new(src.loc, default_papers = FALSE)
				if(wisdom < 20)
					R.wisdom = wisdom + 1
				if(intelligence < 20)
					R.intelligence = intelligence + 1
				if(H.hand)
					H.equip_to_slot_or_del(R, slot_r_hand)
				else
					H.equip_to_slot_or_del(R, slot_l_hand)
				R.add_fingerprint(user)
				to_chat(H, "you put the [src] together into a combined report")
			else
				to_chat(H, "none of it seems to make sense together...")
		else
			to_chat(H, "none of it seems to make sense together...")
	else
		to_chat(H, "none of it seems to make sense together...")

/obj/item/research/attack_self(mob/living/carbon/human/user)
	. = ..()
	to_chat(user, "you start studying the [src]")
	if(wisdom > user.skills.wisdom)
		if(do_after_once(user, intelligence SECONDS, 1, src, 1, "you decide not to study"))
			setskill(user,"wisdom", wisdom)
			to_chat(user, "you become wiser")
	else
		to_chat(user, "you cannot find anything distinctly wiser")
	if(intelligence > user.skills.intelligence)
		if(do_after_once(user, intelligence SECONDS, 1, src, 1, "you decide not to study"))
			setskill(user,"intelligence", intelligence)
			to_chat(user, "you become smarter")
	else
		to_chat(user, "you cannot find anything distinctly smarter")

/obj/item/doubleresearch
	name = "Research Guide"
	desc = "An estimate of knowledge"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_stack_words"
	item_state = "paper_stack_words"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	resistance_flags = FLAMMABLE
	max_integrity = 50
	blocks_emissive = null
	attack_verb = list("bapped")
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	var/wisdom
	var/intelligence

/obj/item/doubleresearch/attack_self(mob/living/carbon/human/user)
	. = ..()
	to_chat(user, "you start studying the [src]")
	if(wisdom > user.skills.wisdom)
		if(do_after_once(user, intelligence SECONDS, 1, src, 1, "you decide not to study"))
			setskill(user,"wisdom", wisdom)
			to_chat(user, "you become wiser")
	else
		to_chat(user, "you cannot find anything distinctly wiser")
	if(intelligence > user.skills.intelligence)
		if(do_after_once(user, intelligence SECONDS, 1, src, 1, "you decide not to study"))
			setskill(user,"intelligence", intelligence)
			to_chat(user, "you become smarter")
	else
		to_chat(user, "you cannot find anything distinctly smarter")

/obj/item/research/lootable
	wisdom = 5
	intelligence = 5

/obj/item/research/lootable/Initialize(mapload)
	. = ..()
	wisdom = roll_dice(10,FALSE, FALSE, 2)
	intelligence = roll_dice(10,FALSE, FALSE, 2)

/obj/item/dumbell
	name = "Dumbell"
	desc = "A dumbell for working out"
	force = 12
	gender = PLURAL
	icon = 'icons/obj/stat_obj.dmi'
	icon_state = "stat_dumbell"
	item_state = "stat_dumbell"
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	throw_range = 3
	throw_speed = 2
	pressure_resistance = 1
	max_integrity = 50
	blocks_emissive = null
	attack_verb = list("smashed")
	drop_sound = 'sound/items/handling/wrench_drop.ogg'
	pickup_sound =  'sound/items/handling/wrench_pickup.ogg'
	var/cooldown = 0
	var/strength = 1
	var/dexterityloss = 1
	var/timetable = list()

/obj/item/dumbell/attack_self(mob/living/carbon/human/user)
	. = ..()
	visible_message("[user] starts pumping iron")
	if(do_after_once(user, 20 SECONDS - user.skills.dexterity SECONDS, 1, src, 1, "you need to hold the [src]"))
		if(timetable["[user]"] < world.time)
			visible_message("[user] stops and looks exhausted")
			if(user.skills.strength < 20)
				adjustskill(user,"strength", strength)
				timetable += usertotime(user, 3 MINUTES + world.time)
		else
			visible_message("[user] drops the [src] in a sweaty shaken panic")
			user.drop_item()
			if(user.skills.dexterity > 1)
				adjustskill(user,"dexterity", -dexterityloss)
				timetable += usertotime(user, 3 MINUTES + world.time)


/obj/proc/usertotime(user, time)
	. = list("name" = "time")
	.["[user]"] = time

