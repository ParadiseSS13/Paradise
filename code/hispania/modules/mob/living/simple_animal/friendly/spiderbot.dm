/mob/living/simple_animal/spiderbot/death(gibbed = FALSE)
	..(TRUE)
	if(held_item && !isnull(held_item))
		held_item.forceMove(src.loc)
		held_item = null
	robogibs(src.loc)
	qdel(src)

/mob/living/simple_animal/spiderbot/emp_act(severity)
	if(flags & GODMODE)
		return ..()

	switch(severity)
		if(1)
			if(prob(5))
				explode()
				return
			adjustBruteLoss(rand(16,20))
		if(2)
			adjustBruteLoss(rand(8,12))
	flash_eyes(visual = 1)
	to_chat(src, "<span class='danger'>*BZZZT*</span>")
	to_chat(src, "<span class='warning'>Warning: Electromagnetic pulse detected.</span>")
	..()

/mob/living/simple_animal/spiderbot/proc/explode()
	for(var/mob/M in viewers(src, null))
		if(M.client)
			M.show_message("<span class='warning'>[src] makes an odd warbling noise, fizzles, and explodes.</span>")
	explosion(get_turf(loc), -1, -1, 3, 5)
	if(!emagged)
		eject_brain()
	else
		QDEL_NULL(mmi)
	death()

/mob/living/simple_animal/spiderbot/verb/drop_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."

	if(incapacitated())
		return

	if(!held_item)
		to_chat(usr, "<span class='warning'>You have nothing to drop!</span>")
		return FALSE

	visible_message("<span class='notice'>[src] drops \the [held_item]!</span>", "<span class='notice'>You drop \the [held_item]!</span>", "You hear a skittering noise and a soft thump.")
	held_item.forceMove(src.loc)
	held_item = null
	return TRUE

/mob/living/simple_animal/spiderbot/verb/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."
	if(incapacitated())
		return
	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding \the [held_item]</span>")
		return TRUE
	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if(I.loc != src && I.w_class <= WEIGHT_CLASS_SMALL)
			items.Add(I)

	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				if(selection.anchored)
					to_chat(src, "<span class='warning'>It's fastened down!</span>")
					return FALSE
				held_item = selection
				selection.forceMove(src)
				visible_message("<span class='notice'>[src] scoops up \the [held_item]!</span>", "<span class='notice'>You grab \the [held_item]!</span>", "You hear a skittering noise and a clink.")
				return held_item
		to_chat(src, "<span class='warning'>\The [selection] is too far away.</span>")
		return FALSE

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")

/mob/living/simple_animal/spiderbot/examine(mob/user)
	..()
	if(held_item)
		to_chat(user, "It is carrying \a [held_item] [bicon(held_item)].")
