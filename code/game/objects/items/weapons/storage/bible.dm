/obj/item/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	var/mob/affecting = null
	var/deity_name = "Christ"
	/// Is the sprite of this bible customisable
	var/customisable = FALSE

	// ALL OF THESE MUST BE THE SAME LENGTH
	/// List of bible variant names, used for the radial menu
	var/static/list/bible_names = list("Bible", "Koran", "Scrapbook", "Creeper", "White Bible", "Holy Light", "PlainRed", "Tome", "The King in Yellow", "Ithaqua", "Scientology", "the bible melts", "Necronomicon", "Greentext")
	/// List of bible variant icon states, used for the radial menu
	var/static/list/bible_states = list("bible", "koran", "scrapbook", "creeper", "white", "holylight", "athiest", "tome", "kingyellow", "ithaqua", "scientology", "melted", "necronomicon", "greentext")
	/// List of bible variant inhand states, used for the radial menu
	var/static/list/bible_inhand = list("bible", "koran", "scrapbook", "syringe_kit", "syringe_kit", "syringe_kit", "syringe_kit", "syringe_kit", "kingyellow", "ithaqua", "scientology", "melted", "necronomicon", "greentext")

/obj/item/storage/bible/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='boldwarning'>[user] stares into [name] and attempts to transcend understanding of the universe!</span>")
	user.dust()
	return OBLITERATION

/obj/item/storage/bible/fart_act(mob/living/M)
	if(QDELETED(M) || M.stat == DEAD)
		return
	M.visible_message("<span class='danger'>[M] farts on \the [name]!</span>")
	M.visible_message("<span class='userdanger'>A mysterious force smites [M]!</span>")
	M.suiciding = TRUE
	do_sparks(3, 1, M)
	M.gib()
	return TRUE // Don't run the fart emote

/obj/item/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/storage/bible/booze/New()
	..()
	new /obj/item/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/stack/spacecash(src)
	new /obj/item/stack/spacecash(src)
	new /obj/item/stack/spacecash(src)
//BS12 EDIT
 // All cult functionality moved to Null Rod
/obj/item/storage/bible/proc/bless(mob/living/carbon/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/heal_amt = 10
		for(var/obj/item/organ/external/affecting in H.bodyparts)
			if(affecting.heal_damage(heal_amt, heal_amt))
				H.UpdateDamageIcon()
	return

/obj/item/storage/bible/attack(mob/living/M, mob/living/user)
	add_attack_logs(user, M, "Hit with [src]")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	if(!(ishuman(user) || SSticker) && SSticker.mode.name != "monkey")
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(!user.mind?.isholy)
		to_chat(user, "<span class='warning'>The book sizzles in your hands.</span>")
		user.take_organ_damage(0, 10)
		return

	if((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

	if(M.stat != DEAD && ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(60))
			bless(H)
			H.visible_message("<span class='danger>[user] heals [H == user ? "[user.p_them()]self" : "[H]"] with the power of [deity_name]!</span>",
				"<span class='danger'>May the power of [deity_name] compel you to be healed!</span>")
			playsound(loc, "punch", 25, 1, -1)
		else
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				M.adjustBrainLoss(10)
				to_chat(M, "<span class='warning'>You feel dumber.</span>")
			H.visible_message("<span class='danger'>[user] beats [H == user ? "[user.p_them()]self" : "[H]"] over the head with [src]!</span>")
			playsound(src.loc, "punch", 25, 1, -1)
	else
		M.visible_message("<span class='danger'>[user] smacks [M]'s lifeless corpse with [src].</span>")
		playsound(src.loc, "punch", 25, 1, -1)


/obj/item/storage/bible/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(isfloorturf(target))
		to_chat(user, "<span class='notice'>You hit the floor with the bible.</span>")
		if(user.mind?.isholy)
			for(var/obj/O in target)
				O.cult_reveal()
	if(istype(target, /obj/machinery/door/airlock))
		to_chat(user, "<span class='notice'>You hit the airlock with the bible.</span>")
		if(user.mind?.isholy)
			var/obj/airlock = target
			airlock.cult_reveal()

	if(user.mind?.isholy && target.reagents)
		if(target.reagents.has_reagent("water")) //blesses all the water in the holder
			to_chat(user, "<span class='notice'>You bless [target].</span>")
			var/water2holy = target.reagents.get_reagent_amount("water")
			target.reagents.del_reagent("water")
			target.reagents.add_reagent("holywater", water2holy)

		if(target.reagents.has_reagent("unholywater")) //yeah yeah, copy pasted code - sue me
			to_chat(user, "<span class='notice'>You purify [target].</span>")
			var/unholy2clean = target.reagents.get_reagent_amount("unholywater")
			target.reagents.del_reagent("unholywater")
			target.reagents.add_reagent("holywater", unholy2clean)

/obj/item/storage/bible/attack_self(mob/user)
	. = ..()
	if(!customisable || !user.mind?.isholy)
		return

	var/list/skins = list()
	for(var/I in 1 to length(bible_states))
		var/image/bible_image = image('icons/obj/storage.dmi', icon_state = bible_states[I])
		skins += list(bible_names[I] = bible_image)

	var/choice = show_radial_menu(user, src, skins, null, 42, CALLBACK(src, .proc/radial_check, user), TRUE)
	if(!choice || !radial_check(user))
		return
	var/index = bible_names.Find(choice)
	if(!index)
		return
	icon_state = bible_states[index]
	item_state = bible_inhand[index]
	customisable = FALSE

	// Carpet symbol icons are currently broken, so commented out until it's fixed
	/*var/carpet_dir
	switch(choice)
		if("Bible")
			carpet_dir = 2
		if("Koran")
			carpet_dir = 4
		if("Scientology")
			carpet_dir = 8
	if(carpet_dir)
		for(var/area/chapel/main/A in world)
			for(var/turf/T in A.contents)
				if(T.icon_state == "carpetsymbol")
					T.dir = carpet_dir*/

	feedback_set_details("religion_book", "[choice]")

	if(SSticker)
		SSticker.Bible_name = name
		SSticker.Bible_icon_state = icon_state
		SSticker.Bible_item_state = item_state

/obj/item/storage/bible/proc/radial_check(mob/user)
	if(!user?.mind.isholy || !ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!src || !H.is_in_hands(src) || H.incapacitated())
		return FALSE
	return TRUE
