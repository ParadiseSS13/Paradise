/mob/living/simple_animal/pet/slugcat
	name = "слизнекот"
	desc = "Удивительное существо, напоминающая кота и слизня в одном обличии. Но это не слизь, а иной вид существа. Гордость ксенобиологии. Крайне ловкое и умное, родом с планеты с опасной средой обитания. Обожает копья, не стоит давать ему его в лапки. На нем отлично смотрятся шляпы."
	icon_state = "slugcat"
	icon_living = "slugcat"
	icon_dead = "slugcat_dead"
	icon_resting = "slugcat_rest"
	speak = list("Furrr.","Uhh.", "Hurrr.")
	gender = MALE
	turns_per_move = 5
	see_in_dark = 8
	health = 100
	maxHealth = 100
	blood_volume = BLOOD_VOLUME_NORMAL
	melee_damage_type = STAMINA
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "бьет"
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE
	ventcrawler = VENTCRAWLER_ALWAYS
	can_collar = 1
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 5)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_SLIME
	tts_seed = "Narrator"
	faction = list("slime","neutral")
	//holder_type = /obj/item/holder/cat2

	//Шляпы для слизнекота!
	var/obj/item/inventory_head
	var/obj/item/inventory_hand

	var/hat_offset_y = -8
	var/hat_offset_y_rest = -19
	var/hat_icon_file = 'icons/mob/head.dmi'
	var/hat_icon_state
	var/hat_alpha
	var/hat_color

	var/is_pacifist = FALSE
	var/is_reduce_damage = TRUE

/mob/living/simple_animal/pet/slugcat/monk
	name = "слизнекот-монах"
	desc = "Удивительное существо, напоминающая кота и слизня в одном обличии. Но это не слизь, а иной вид существа. Гордость ксенобиологии. Крайне ловкое и умное, родом с планеты с опасной средой обитания. Не любит охоту и не умеет пользоваться копьями. На нем отлично смотрятся шляпы."
	icon_state = "slugcat_monk"
	icon_living = "slugcat_monk"
	icon_dead = "slugcat_monk_dead"
	icon_resting = "slugcat_monk_rest"
	is_pacifist = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	health = 80
	maxHealth = 80

/mob/living/simple_animal/pet/slugcat/hunter
	name = "слизнекот-охотник"
	desc = "Удивительное существо, напоминающая кота и слизня в одном обличии. Но это не слизь, а иной вид существа. Гордость ксенобиологии. Крайне ловкое и умное, родом с планеты с опасной средой обитания. Обожает копья и умело управляется ими, не стоит давать ему его в лапки. На нем отлично смотрятся шляпы."
	icon_state = "slugcat_hunter"
	icon_living = "slugcat_hunter"
	icon_dead = "slugcat_hunter_dead"
	icon_resting = "slugcat_hunter_rest"
	is_pacifist = FALSE
	is_reduce_damage = FALSE
	faction = list("slime","neutral","hostile")
	gold_core_spawnable = HOSTILE_SPAWN
	health = 150
	maxHealth = 150

/mob/living/simple_animal/pet/slugcat/gold	//for admins
	name = "золотой слизнекот"
	desc = "Уникальный золотой слизнекот полученный чудотворным путём."
	icon_state = "slugcat_gold"
	icon_living = "slugcat_gold"
	icon_dead = "slugcat_gold_dead"
	icon_resting = "slugcat_gold_rest"
	is_pacifist = FALSE
	is_reduce_damage = FALSE
	gold_core_spawnable = NO_SPAWN
	health = 300
	maxHealth = 300

/mob/living/simple_animal/pet/slugcat/New()
	..()
	regenerate_icons()


/mob/living/simple_animal/pet/slugcat/attackby(obj/item/W, mob/user, params)
	if(stat != DEAD)
		if(istype(W, /obj/item/clothing/head) && user.a_intent == INTENT_HELP)
			place_on_head(user.get_active_hand(), user)
			return
		if(istype(W, /obj/item/twohanded/spear) && user.a_intent != INTENT_HARM)
			place_to_hand(user.get_active_hand(), user)
			return

	. = ..()

/mob/living/simple_animal/pet/slugcat/death(gibbed)
	drop_hat()
	drop_hand()
	. = ..()

/mob/living/simple_animal/pet/slugcat/Topic(href, href_list)
	if(..())
		return 1

	if(!(iscarbon(usr) || usr.incapacitated() || !Adjacent(usr)))
		usr << browse(null, "window=mob[UID()]")
		usr.unset_machine()
		return

	if (stat == DEAD)
		return 0

	if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				remove_from_head(usr)
			if("hand")
				remove_from_hand(usr)
		show_inv(usr)

	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]
		switch(add_to)
			if("head")
				place_on_head(usr.get_active_hand(), usr)
			if("hand")
				place_to_hand(usr.get_active_hand(), usr)
		show_inv(usr)

	if(usr != src)
		return 1

/mob/living/simple_animal/pet/slugcat/regenerate_icons()
	overlays.Cut()
	..()

	if(inventory_hand)
		if(istype(inventory_hand, /obj/item/twohanded/spear))
			speared()

	if(inventory_head)
		var/image/head_icon

		if(!hat_icon_state)
			hat_icon_state = inventory_head.icon_state
		if(!hat_alpha)
			hat_alpha = inventory_head.alpha
		if(!hat_color)
			hat_color = inventory_head.color

		head_icon = get_hat_overlay()

		add_overlay(head_icon)

/mob/living/simple_animal/pet/slugcat/StartResting(updating = 1)
	if(inventory_head || inventory_hand)
		hat_offset_y = hat_offset_y_rest
		drop_hand()
		regenerate_icons()
	. = ..()

/mob/living/simple_animal/pet/slugcat/StopResting(updating = 1)
	if(inventory_head)
		hat_offset_y = initial(hat_offset_y)
		regenerate_icons()
	. = ..()

/mob/living/simple_animal/pet/slugcat/proc/speared()
	icon_state = "[initial(icon_state)]_spear"

	var/obj/item/twohanded/spear = inventory_hand

	attacktext = "бьет копьем"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	melee_damage_type = BRUTE
	melee_damage_lower = round(spear.force_unwielded / (is_reduce_damage ? 2 : 1))
	melee_damage_upper = round(spear.force_wielded / (is_reduce_damage ? 2 : 1))
	armour_penetration = spear.armour_penetration
	obj_damage = spear.force

/mob/living/simple_animal/pet/slugcat/proc/unspeared()
	icon_state = initial(icon_state)
	attacktext = initial(attacktext)
	attack_sound = initial(attack_sound)
	melee_damage_type = initial(melee_damage_type)
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	armour_penetration = initial(armour_penetration)
	obj_damage = initial(obj_damage)

/mob/living/simple_animal/pet/slugcat/proc/get_hat_overlay()
	if(hat_icon_file && hat_icon_state)
		var/image/slugI = image(hat_icon_file, hat_icon_state)
		slugI.alpha = hat_alpha
		slugI.color = hat_color
		slugI.pixel_y = hat_offset_y
		//slugI.transform = matrix(1, 0, 1, 0, 1, 0)
		return slugI

/mob/living/simple_animal/pet/slugcat/show_inv(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	user.set_machine(src)

	var/dat = 	{"<meta charset="UTF-8"><div align='center'><b>Inventory of [name]</b></div><p>"}
	dat += "<br><B>Head:</B> <A href='?src=[UID()];[inventory_head ? "remove_inv=head'>[inventory_head]" : "add_inv=head'>Nothing"]</A>"
	dat += "<br><B>Hand:</B> <A href='?src=[UID()];[inventory_hand ? "remove_inv=hand'>[inventory_hand]" : "add_inv=hand'>Nothing"]</A>"

	var/datum/browser/popup = new(user, "mob[UID()]", "[src]", 440, 250)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/pet/slugcat/proc/place_on_head(obj/item/item_to_add, mob/user)
	if(!item_to_add)
		user.visible_message("<span class='notice'>[user] похлопывает по голове [src.name].</span>", "<span class='notice'>Вы положили руку на голову [src.name].</span>")
		if(flags_2 & HOLOGRAM_2)
			return 0
		return 0

	if(!istype(item_to_add, /obj/item/clothing/head))
		to_chat(user, "<span class='warning'>[item_to_add.name] нельзя надеть на голову [src.name]!</span>")
		return 0

	if(inventory_head)
		if(user)
			to_chat(user, "<span class='warning'>Нельзя надеть больше одного головного убора на голову [src.name]!</span>")
		return 0

	if(user && !user.unEquip(item_to_add))
		to_chat(user, "<span class='warning'>[item_to_add.name] застрял в ваших руках, вы не можете его надеть на голову [src.name]!</span>")
		return 0

	user.visible_message("<span class='notice'>[user] надевает [item_to_add].name на голову [real_name].</span>",
		"<span class='notice'>Вы надеваете [item_to_add.name] на голову [real_name].</span>",
		"<span class='italics'>Вы слышите как что-то нацепили.</span>")
	item_to_add.forceMove(src)
	inventory_head = item_to_add
	regenerate_icons()

	return 1

/mob/living/simple_animal/pet/slugcat/proc/remove_from_head(mob/user)
	if(inventory_head)
		if(inventory_head.flags & NODROP)
			to_chat(user, "<span class='warning'>[inventory_head.name] застрял на голове [src.name]! Его невозможно снять!</span>")
			return TRUE

		to_chat(user, "<span class='warning'>Вы сняли [inventory_head.name] с головы [src.name].</span>")
		user.put_in_hands(inventory_head)

		null_hat()

		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>На голове [src.name] нет головного убора!</span>")
		return FALSE

	return TRUE

/mob/living/simple_animal/pet/slugcat/proc/drop_hat()
	if(inventory_head)
		unEquip(inventory_head)
		null_hat()
		regenerate_icons()

/mob/living/simple_animal/pet/slugcat/proc/null_hat()
	inventory_head = null
	hat_icon_state = null
	hat_alpha = null
	hat_color = null

/mob/living/simple_animal/pet/slugcat/proc/place_to_hand(obj/item/item_to_add, mob/user)
	if(!item_to_add)
		user.visible_message("<span class='notice'>[user] пощупал лапки [src].</span>", "<span class='notice'>Вы пощупали лапки [src].</span>")
		if(flags_2 & HOLOGRAM_2)
			return 0
		return 0

	if(resting)
		to_chat(user, "<span class='warning'>[src.name] спит и не принимает [item_to_add.name]!</span>")
		return 0

	if(!istype(item_to_add, /obj/item/twohanded/spear))
		to_chat(user, "<span class='warning'>[src.name] не принимает [item_to_add.name]!</span>")
		return 0
	if(inventory_hand)
		if(user)
			to_chat(user, "<span class='warning'>Лапки [src.name] заняты [inventory_hand.name]!</span>")
		return 0

	if(user && !user.unEquip(item_to_add))
		to_chat(user, "<span class='warning'>[item_to_add.name] застрял в ваших руках, вы не можете его дать [src.name]!</span>")
		return 0

	if(is_pacifist)
		to_chat(user, "<span class='warning'>[src.name] пацифист и не пользуется [item_to_add.name]!</span>")
		return 0

	user.visible_message("<span class='notice'>[real_name] выхватывает [item_to_add] с рук [user].</span>",
		"<span class='notice'>[real_name] выхватывает [item_to_add] с ваших рук.</span>",
		"<span class='italics'>Вы видите довольные глаза.</span>")
	move_item_to_hand(item_to_add)

	return 1

/mob/living/simple_animal/pet/slugcat/proc/move_item_to_hand(obj/item/item_to_add)
	item_to_add.forceMove(src)
	inventory_hand = item_to_add
	regenerate_icons()

/mob/living/simple_animal/pet/slugcat/proc/remove_from_hand(mob/user)
	if(inventory_hand)
		if(inventory_hand.flags & NODROP)
			to_chat(user, "<span class='warning'>[inventory_hand.name] застрял в лапах [src]! Его невозможно отнять!</span>")
			return TRUE

		to_chat(user, "<span class='warning'>Вы забрали [inventory_hand.name] с лап [src].</span>")
		user.put_in_hands(inventory_hand)

		null_hand()

		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>В лапах [src] нечего отбирать!</span>")
		return FALSE

	return TRUE

/mob/living/simple_animal/pet/slugcat/proc/drop_hand()
	if(inventory_hand)
		unEquip(inventory_hand)
		null_hand()
		regenerate_icons()

/mob/living/simple_animal/pet/slugcat/proc/null_hand()
	unspeared()
	inventory_hand = null
