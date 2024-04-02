/mob/living/simple_animal/pet/dog/security
	name = "Мухтар"
	real_name = "Мухтар"
	desc = "Верный служебный пес. Он гордо несёт бремя хорошего мальчика."
	icon = 'modular_ss220/mobs/icons/mob/pets.dmi'
	icon_state = "german_shep"
	icon_living = "german_shep"
	icon_resting = "german_shep_rest"
	icon_dead = "german_shep_dead"
	health = 35
	maxHealth = 35
	melee_damage_type = STAMINA
	melee_damage_lower = 8
	melee_damage_upper = 10
	attacktext = "кусает"
	var/obj/item/inventory_head
	var/obj/item/inventory_mask
	footstep_type = FOOTSTEP_MOB_CLAW
	butcher_results = list(/obj/item/food/snacks/meat/security = 3)

/mob/living/simple_animal/pet/dog/security/ranger
	name = "Ranger"
	real_name = "Ranger"
	desc = "That's Ranger, your friendly and fierce k9. He has seen the terror of Xenomorphs, so it's best to be nice to him. <b>RANGER LEAD THE WAY</b>!"
	icon_state = "ranger"
	icon_living = "ranger"
	icon_resting = "ranger_rest"
	icon_dead = "ranger_dead"

/mob/living/simple_animal/pet/dog/security/warden
	name = "Джульбарс"
	real_name = "Джульбарс"
	desc = "Мудрый служебный пес, названный в честь единственной собаки удостоившийся боевой награды."
	icon_state = "german_shep2"
	icon_living = "german_shep2"
	icon_resting = "german_shep2_rest"
	icon_dead = "german_shep2_dead"

/mob/living/simple_animal/pet/dog/security/detective
	name = "Гав-Гавыч"
	desc = "Старый служебный пёс. Он давно потерял нюх, однако детектив по-прежнему содержит и заботится о нём."
	icon_state = "blackdog"
	icon_living = "blackdog"
	icon_dead = "blackdog_dead"
	icon_resting = "blackdog_rest"

/mob/living/simple_animal/pet/dog/security/detective/show_inv(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	user.set_machine(src)

	var/dat = 	{"<meta charset="UTF-8"><div align='center'><b>Inventory of [name]</b></div><p>"}
	dat += "<br><B>Collar:</B> <A href='?src=[UID()];[pcollar ? "remove_inv=collar'>[pcollar]" : "add_inv=collar'>Nothing"]</A>"

	var/datum/browser/popup = new(user, "mob[UID()]", "[src]", 440, 250)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/pet/dog/security/show_inv(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	user.set_machine(src)

	var/dat = 	{"<meta charset="UTF-8"><div align='center'><b>Inventory of [name]</b></div><p>"}
	dat += "<br><B>Head:</B> <A href='?src=[UID()];[inventory_head ? "remove_inv=head'>[inventory_head]" : "add_inv=head'>Nothing"]</A>"
	dat += "<br><B>Mask:</B> <A href='?src=[UID()];[inventory_mask ? "remove_inv=mask'>[inventory_mask]" : "add_inv=mask'>Nothing"]</A>"
	dat += "<br><B>Collar:</B> <A href='?src=[UID()];[pcollar ? "remove_inv=collar'>[pcollar]" : "add_inv=collar'>Nothing"]</A>"

	var/datum/browser/popup = new(user, "mob[UID()]", "[src]", 440, 250)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/pet/dog/security/ranger/show_inv(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	user.set_machine(src)

	var/dat = 	{"<meta charset="UTF-8"><div align='center'><b>Inventory of [name]</b></div><p>"}
	dat += "<br><B>Mask:</B> <A href='?src=[UID()];[inventory_mask ? "remove_inv=mask'>[inventory_mask]" : "add_inv=mask'>Nothing"]</A>"
	dat += "<br><B>Collar:</B> <A href='?src=[UID()];[pcollar ? "remove_inv=collar'>[pcollar]" : "add_inv=collar'>Nothing"]</A>"

	var/datum/browser/popup = new(user, "mob[UID()]", "[src]", 440, 250)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/pet/dog/security/on_lying_down(new_lying_angle)
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_resting
		regenerate_icons()
		if(collar_type)
			collar_type = "[initial(collar_type)]_rest"
			regenerate_icons()

/mob/living/simple_animal/pet/dog/security/on_standing_up(updating = 1)
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_living
		regenerate_icons()
		if(collar_type)
			collar_type = "[initial(collar_type)]"
			regenerate_icons()


/mob/living/simple_animal/pet/dog/security/Initialize(mapload)
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/pet/dog/security/Destroy()
	QDEL_NULL(inventory_head)
	QDEL_NULL(inventory_mask)
	return ..()

/mob/living/simple_animal/pet/dog/security/handle_atom_del(atom/A)
	if(A == inventory_head)
		inventory_head = null
		regenerate_icons()
	if(A == inventory_mask)
		inventory_mask = null
		regenerate_icons()
	return ..()

/mob/living/simple_animal/pet/dog/security/Life(seconds, times_fired)
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/pet/dog/security/death(gibbed)
	..(gibbed)
	regenerate_icons()

/mob/living/simple_animal/pet/dog/security/Topic(href, href_list)
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
					drop_item(inventory_head)
					usr.put_in_hands(inventory_head)
					inventory_head = null
					update_muhtar_fluff()
					regenerate_icons()
				else
					to_chat(usr, "<span class='danger'>There is nothing to remove from its [remove_from].</span>")
					return
			if("mask")
				if(inventory_mask)
					if(inventory_mask.flags & NODROP)
						to_chat(usr, "<span class='warning'>\The [inventory_head] is stuck too hard to [src] for you to remove!</span>")
						return
					drop_item(inventory_mask)
					usr.put_in_hands(inventory_mask)
					inventory_mask = null
					update_muhtar_fluff()
					regenerate_icons()
				else
					to_chat(usr, "<span class='danger'>There is nothing to remove from its [remove_from].</span>")
					return
			if("collar")
				if(pcollar)
					var/the_collar = pcollar
					drop_item(pcollar)
					usr.put_in_hands(the_collar)
					pcollar = null
					update_muhtar_fluff()
					regenerate_icons()

		show_inv(usr)

	//Adding things to inventory
	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]

		switch(add_to)
			if("collar")
				add_collar(usr.get_active_hand(), usr)
				update_muhtar_fluff()

			if("head")
				place_on_head(usr.get_active_hand(),usr)

			if("mask")
				if(inventory_mask)
					to_chat(usr, "<span class='warning'>It's already wearing something!</span>")
					return
				else
					var/obj/item/item_to_add = usr.get_active_hand()

					if(!item_to_add)
						usr.visible_message("<span class='notice'>[usr] pets [src].</span>", "<span class='notice'>You rest your hand on [src]'s face for a moment.</span>")
						return

					if(!usr.drop_item(item_to_add))
						to_chat(usr, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s face!</span>")
						return

					if(istype(item_to_add, /obj/item/grenade/plastic/c4)) // last thing he ever wears, I guess
						item_to_add.afterattack(src,usr,1)
						return

					//The objects that secdogs can wear on their faces.
					var/allowed = FALSE
					if(ispath(item_to_add.muhtar_fashion, /datum/muhtar_fashion/mask))
						allowed = TRUE

					if(!allowed)
						to_chat(usr, "<span class='warning'>You set [item_to_add] on [src]'s face, but it falls off!</span>")
						item_to_add.forceMove(drop_location())
						if(prob(25))
							step_rand(item_to_add)
						for(var/i in list(1,2,4,8,4,8,4,dir))
							setDir(i)
							sleep(1)
						return

					item_to_add.forceMove(src)
					inventory_mask = item_to_add
					update_muhtar_fluff()
					regenerate_icons()

		show_inv(usr)
	else
		return ..()

/mob/living/simple_animal/pet/dog/security/proc/place_on_head(obj/item/item_to_add, mob/user)

	if(istype(item_to_add, /obj/item/grenade/plastic/c4)) // last thing he ever wears, I guess
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
	if(ispath(item_to_add.muhtar_fashion, /datum/muhtar_fashion/head))
		valid = TRUE

	//Various hats and items (worn on his head) change muhtar's behaviour. His attributes are reset when a hat is removed.

	if(valid)
		if(health <= 0)
			to_chat(user, "<span class='notice'>There is merely a dull, lifeless look in [real_name]'s eyes as you put the [item_to_add] on [p_them()].</span>")
		else if(user)
			user.visible_message("<span class='notice'>[user] puts [item_to_add] on [real_name]'s head. [src] looks at [user] and barks once.</span>",
				"<span class='notice'>You put [item_to_add] on [real_name]'s head. [src] gives you a peculiar look, then wags [p_their()] tail once and barks.</span>",
				"<span class='italics'>You hear a friendly-sounding bark.</span>")
		item_to_add.forceMove(src)
		inventory_head = item_to_add
		update_muhtar_fluff()
		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>You set [item_to_add] on [src]'s head, but it falls off!</span>")
		item_to_add.forceMove(drop_location())
		if(prob(25))
			step_rand(item_to_add)
		for(var/i in list(1,2,4,8,4,8,4,dir))
			setDir(i)
			sleep(1)

	return valid

/mob/living/simple_animal/pet/dog/security/proc/update_muhtar_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	desc = initial(desc)

	if(inventory_head && inventory_head.muhtar_fashion)
		var/datum/muhtar_fashion/DF = new inventory_head.muhtar_fashion(src)
		DF.apply(src)

	if(inventory_mask && inventory_mask.muhtar_fashion)
		var/datum/muhtar_fashion/DF = new inventory_mask.muhtar_fashion(src)
		DF.apply(src)

/mob/living/simple_animal/pet/dog/security/regenerate_icons()
	..()
	if(inventory_head)
		var/image/head_icon
		var/datum/muhtar_fashion/DF = new inventory_head.muhtar_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_head.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_head.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_head.color


		if(icon_state == icon_resting)
			head_icon = DF.get_overlay()
			head_icon.pixel_y = -2
		else
			head_icon = DF.get_overlay()

		if(health <= 0)
			head_icon = DF.get_overlay(dir = EAST)
			head_icon.pixel_y = -8
			head_icon.transform = turn(head_icon.transform, 180)

		add_overlay(head_icon)

	if(inventory_mask)
		var/image/mask_icon
		var/datum/muhtar_fashion/DF = new inventory_mask.muhtar_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_mask.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_mask.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_mask.color

		if(icon_state == icon_resting)
			mask_icon = DF.get_overlay()
			mask_icon.pixel_y = -2
		else
			mask_icon = DF.get_overlay()

		if(health <= 0)
			mask_icon = DF.get_overlay(dir = EAST)
			mask_icon.pixel_y = -11
			mask_icon.transform = turn(mask_icon.transform, 180)

		add_overlay(mask_icon)
