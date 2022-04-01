/mob/living/simple_animal/hostile/retaliate/poison
	var/poison_per_bite = 0
	var/poison_type = "toxin"

/mob/living/simple_animal/hostile/retaliate/poison/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents && !poison_per_bite == 0)
			L.reagents.add_reagent(poison_type, poison_per_bite)
		return .

/mob/living/simple_animal/hostile/retaliate/poison/snake
	name = "snake"
	desc = "A slithery snake. These legless reptiles are the bane of mice and adventurers alike."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	speak_emote = list("hisses")
	health = 20
	maxHealth = 20
	attacktext = "bites"
	melee_damage_lower = 5
	melee_damage_upper = 6
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "steps on"
	faction = list("hostile")
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE


/mob/living/simple_animal/hostile/retaliate/poison/snake/ListTargets(atom/the_target)
	. = oview(vision_range, targets_from) //get list of things in vision range
	var/list/living_mobs = list()
	var/list/mice = list()
	for(var/HM in .)
		//Yum a tasty mouse
		if(istype(HM, /mob/living/simple_animal/mouse))
			mice += HM
		if(isliving(HM))
			living_mobs += HM

	// if no tasty mice to chase, lets chase any living mob enemies in our vision range
	if(length(mice) == 0)
		//Filter living mobs (in range mobs) by those we consider enemies (retaliate behaviour)
		return  living_mobs & enemies
	return mice

/mob/living/simple_animal/hostile/retaliate/poison/snake/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/mouse))
		visible_message("<span class='notice'>[name] consumes [target] in a single gulp!</span>", "<span class='notice'>You consume [target] in a single gulp!</span>")
		QDEL_NULL(target)
		adjustHealth(-2)
	else
		return ..()

//Уникальный питомец Офицера Телекомов. Спрайты от Элл Гуда
/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge
	name = "Руж"
	desc = "Уникальная трёхголовая змея Офицера Телекоммуникаций синдиката. Выращена в лаборатории. У каждой головы свой характер!"
	icon = 'icons/mob/pets.dmi'
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
	attacktext = "bites"
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

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/emote(act, m_type = 1, message = null, force)
	if(incapacitated())
		return

	act = lowertext(act)
	if(!force && act == "hiss" && handle_emote_CD())
		return

	switch(act)
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

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/StartResting(updating = 1)
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_resting
		rest = TRUE
		if(collar_type)
			collar_type = "[initial(collar_type)]_rest"
			regenerate_icons()
		if(inventory_head)
			regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/StopResting(updating = 1)
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

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/show_inv(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	user.set_machine(src)

	var/dat = 	{"<meta charset="UTF-8"><div align='center'><b>Inventory of [name]</b></div><p>"}
	dat += "<br><B>Head:</B> <A href='?src=[UID()];[inventory_head ? "remove_inv=head'>[inventory_head]" : "add_inv=head'>Nothing"]</A>"
	dat += "<br><B>Collar:</B> <A href='?src=[UID()];[pcollar ? "remove_inv=collar'>[pcollar]" : "add_inv=collar'>Nothing"]</A>"

	var/datum/browser/popup = new(user, "mob[UID()]", "[src]", 440, 250)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/getarmor(def_zone, type)
	var/armorval = inventory_head?.armor.getRating(type)
	if(!def_zone)
		armorval *= 0.5
	else if(def_zone != "head")
		armorval = 0
	return armorval 

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/Topic(href, href_list)
	if(!(iscarbon(usr) || isrobot(usr)) || usr.incapacitated() || !Adjacent(usr))
		usr << browse(null, "window=mob[UID()]")
		usr.unset_machine()
		return

	//Removing from inventory
	if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				if(inventory_head)
					if(inventory_head.flags & NODROP)
						to_chat(usr, "<span class='warning'>\The [inventory_head] is stuck too hard to [src] for you to remove!</span>")
						return
					usr.put_in_hands(inventory_head)
					inventory_head = null
					update_snek_fluff()
					regenerate_icons()
				else
					to_chat(usr, "<span class='danger'>There is nothing to remove from its [remove_from].</span>")
					return
			if("collar")
				if(pcollar)
					var/the_collar = pcollar
					unEquip(pcollar)
					usr.put_in_hands(the_collar)
					pcollar = null
					update_snek_fluff()
					regenerate_icons()

		show_inv(usr)

	//Adding things to inventory
	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]

		switch(add_to)
			if("collar")
				add_collar(usr.get_active_hand(), usr)
				update_snek_fluff()

			if("head")
				place_on_head(usr.get_active_hand(),usr)

		show_inv(usr)
	else
		return ..()


/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/proc/place_on_head(obj/item/item_to_add, mob/user)

	if(istype(item_to_add, /obj/item/grenade/plastic/c4)) // last thing she ever wears, I guess
		item_to_add.afterattack(src,user,1)
		return

	if(inventory_head)
		if(user)
			to_chat(user, "<span class='warning'>You can't put more than one hat on [src]!</span>")
		return
	if(!item_to_add)
		user.visible_message("<span class='notice'>[user] pets [src].</span>", "<span class='notice'>You rest your hand on [src]'s head for a moment.</span>")
		if(flags_2 & HOLOGRAM_2)
			return
		return

	if(user && !user.unEquip(item_to_add))
		to_chat(user, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!</span>")
		return 0

	var/valid = FALSE
	if(ispath(item_to_add.snake_fashion, /datum/snake_fashion/head))
		valid = TRUE

	if(valid)
		if(health <= 0)
			to_chat(user, "<span class='notice'>Безжизненный взгляд в глазах [real_name] никак не меняется, когда вы надеваете [item_to_add] на неё.</span>")
		else if(user)
			user.visible_message("<span class='notice'>[user] надевает [item_to_add] на центральную голову [real_name]. [src] смотрит на [user] и довольно шипит.</span>",
				"<span class='notice'>Вы надеваете [item_to_add] на голову [real_name]. [src] озадачено смотрит на вас, пока другие головы смотрят на центральную с завистью.</span>",
				"<span class='italics'>Вы слышите дружелюбное шипение.</span>")
		item_to_add.forceMove(src)
		inventory_head = item_to_add
		update_snek_fluff()
		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>Вы надеваете [item_to_add] на голову [src], но она скидывает [item_to_add] с себя!</span>")
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
