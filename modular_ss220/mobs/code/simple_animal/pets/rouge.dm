//Уникальный питомец Офицера Телекомов. Спрайты от Элл Гуда
/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge
	name = "Руж"
	desc = "Уникальная трёхголовая змея Офицера Телекоммуникаций синдиката. Выращена в лаборатории. У каждой головы свой характер!"
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	blood_volume = BLOOD_VOLUME_NORMAL
	can_collar = TRUE
	gender = FEMALE
	icon_state = "rouge"
	icon_living = "rouge"
	icon_dead = "rouge_dead"
	icon_resting = "rouge_rest"
	speak_chance = 5
	speak = list("Шшш", "Тсс!", "Тц тц тц!", "ШШшшШШшшШ!")
	speak_emote = list("hisses")
	emote_hear = list("Зевает", "Шипит", "Дурачится", "Толкается")
	emote_see = list("Высовывает язык", "Кружится", "Трясёт хвостом")
	health = 20
	maxHealth = 20
	attacktext = "кусает"
	melee_damage_lower = 5
	melee_damage_upper = 6
	response_help  = "pets"
	var/rest = FALSE
	response_disarm = "shoos"
	response_harm   = "steps on"
	var/obj/item/inventory_head
	faction = list("neutral", "syndicate")
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	can_hide = 1

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/verb/chasetail()
	set name = "Chase your tail"
	set desc = "d'awwww."
	set category = "Animal"
	visible_message("[src] [pick("dances around", "chases [p_their()] tail")].", "[pick("You dance around", "You chase your tail")].")
	spin(20, 1)

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/emote(emote_key, type_override = 1, message, intentional, force_silence)
	if(incapacitated())
		return

	emote_key = lowertext(emote_key)
	if(!force_silence && emote_key == "hiss" && start_audio_emote_cooldown())
		return

	switch(emote_key)
		if("hiss")
			message = "<B>[src]</B> [pick(src.speak_emote)]!"
	..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if(INTENT_HELP)
			shh(1, M)
		if(INTENT_HARM)
			shh(-1, M)

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/on_lying_down(updating = 1)
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_resting
		rest = TRUE
		if(collar_type)
			collar_type = "[initial(collar_type)]_rest"
			regenerate_icons()
		if(inventory_head)
			regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/on_standing_up(updating = 1)
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_living
		rest = FALSE
		if(collar_type)
			collar_type = "[initial(collar_type)]"
			regenerate_icons()
		if(inventory_head)
			regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/proc/shh(change, mob/M)
	if(!M || stat)
		return
	if(change > 0)
		new /obj/effect/temp_visual/heart(loc)
		custom_emote(1, "hisses happily!")
	else
		custom_emote(1, "hisses angrily!")

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/Initialize(mapload)
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/Destroy()
	QDEL_NULL(inventory_head)
	return ..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/handle_atom_del(atom/A)
	if(A == inventory_head)
		inventory_head = null
		regenerate_icons()
	return ..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/Life(seconds, times_fired)
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/death(gibbed)
	..(gibbed)
	regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/getarmor(def_zone, type)
	var/armorval = inventory_head?.armor.getRating(type)
	if(!def_zone)
		armorval *= 0.5
	else if(def_zone != "head")
		armorval = 0
	return armorval

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/proc/place_on_head(obj/item/item_to_add, mob/user)

	if(istype(item_to_add, /obj/item/grenade/plastic/c4)) // last thing she ever wears, I guess
		item_to_add.afterattack(src,user,1)
		return

	if(inventory_head)
		if(user)
			to_chat(user, span_warning("You can't put more than one hat on [src]!"))
		return
	if(!item_to_add)
		user.visible_message(
			span_notice("[user] pets [src]."),
			span_notice("You rest your hand on [src]'s head for a moment."))
		if(flags_2 & HOLOGRAM_2)
			return
		return

	if(user && !user.unEquip(item_to_add))
		to_chat(user, span_warning("\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!"))
		return 0

	var/valid = FALSE
	if(ispath(item_to_add.snake_fashion, /datum/snake_fashion/head))
		valid = TRUE

	if(valid)
		if(health <= 0)
			to_chat(user, span_notice("Безжизненный взгляд в глазах [real_name] никак не меняется, когда вы надеваете [item_to_add] на неё."))
		else if(user)
			user.visible_message(
				span_notice("[user] надевает [item_to_add] на центральную голову [real_name]. [src] смотрит на [user] и довольно шипит."),
				span_notice("Вы надеваете [item_to_add] на голову [real_name]. [src] озадачено смотрит на вас, пока другие головы смотрят на центральную с завистью."),
				span_italics("Вы слышите дружелюбное шипение."))
		item_to_add.forceMove(src)
		inventory_head = item_to_add
		update_snek_fluff()
		regenerate_icons()
	else
		to_chat(user, span_warning("Вы надеваете [item_to_add] на голову [src], но она скидывает [item_to_add] с себя!"))
		item_to_add.forceMove(drop_location())
		if(prob(25))
			step_rand(item_to_add)
		for(var/i in list(1,2,4,8,4,8,4,dir))
			setDir(i)
			sleep(1)

	return valid

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/proc/update_snek_fluff() //имя, описание, эмоуты
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak = list("Шшш", "Тсс!", "Тц тц тц!", "ШШшшШШшшШ!")
	speak_emote = list("hisses")
	emote_hear = list("Зевает", "Шипит", "Дурачится", "Толкается")
	emote_see = list("Высовывает язык", "Кружится", "Трясёт хвостом")

///Этот код скопирован с кода для корги и обнуляет показатели которые ему даёт риг. Если когда нибудь змейке дадут риг, раскомментируете///
/*
	set_light(0)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	mutations.Remove(BREATHLESS)
	minbodytemp = initial(minbodytemp)
*/
	if(inventory_head?.snake_fashion)
		var/datum/snake_fashion/SF = new inventory_head.snake_fashion(src)
		SF.apply(src)

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/regenerate_icons() // оверлей
	..()
	if(inventory_head)
		var/image/head_icon
		var/datum/snake_fashion/SF = new inventory_head.snake_fashion(src)

		if(!SF.obj_icon_state)
			SF.obj_icon_state = inventory_head.icon_state
			if(src.rest || stat == DEAD)
				SF.obj_icon_state += "_rest"
		if(!SF.obj_alpha)
			SF.obj_alpha = inventory_head.alpha
		if(!SF.obj_color)
			SF.obj_color = inventory_head.color

		if(stat || src.rest) //без сознания или отдыхает
			head_icon = SF.get_overlay()
			if(stat)
				head_icon.pixel_y = -2
				head_icon.pixel_x = -2
		else
			head_icon = SF.get_overlay()

		add_overlay(head_icon)
