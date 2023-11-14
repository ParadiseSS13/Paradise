/obj/item/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	lefthand_file = 'icons/mob/inhands/religion_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/religion_righthand.dmi'
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound =  'sound/items/handling/book_pickup.ogg'
	var/mob/affecting = null
	var/deity_name = "Christ"
	/// Is the sprite of this bible customisable
	var/customisable = FALSE

	/// Associative list of accociative lists of bible variants, used for the radial menu
	var/static/list/bible_variants = list(
		"Bible" =			   list("state" = "bible",		  "inhand" = "bible"),
		"Koran" =			   list("state" = "koran",		  "inhand" = "koran"),
		"Scrapbook" =		   list("state" = "scrapbook",	  "inhand" = "scrapbook"),
		"Creeper" =			   list("state" = "creeper",	  "inhand" = "generic_bible"),
		"White Bible" =		   list("state" = "white",		  "inhand" = "generic_bible"),
		"Holy Light" =		   list("state" = "holylight",	  "inhand" = "generic_bible"),
		"PlainRed" =		   list("state" = "athiest",	  "inhand" = "generic_bible"),
		"Tome" =			   list("state" = "tome",		  "inhand" = "generic_bible"),
		"The King in Yellow" = list("state" = "kingyellow",	  "inhand" = "kingyellow"),
		"Ithaqua" =			   list("state" = "ithaqua",	  "inhand" = "ithaqua"),
		"Scientology" =		   list("state" = "scientology",  "inhand" = "scientology"),
		"the bible melts" =	   list("state" = "melted",		  "inhand" = "melted"),
		"Necronomicon" =	   list("state" = "necronomicon", "inhand" = "necronomicon"),
		"Greentext" =		   list("state" = "greentext",	  "inhand" = "greentext"),
		"Honkmother" =		   list("state" = "honk",		  "inhand" = "honk"),
		"Silentfather" =	   list("state" = "mime",		  "inhand" = "mime"),
		"Clockwork" =		   list("state" = "clock_bible",  "inhand" = "clock_bible"),
		"Nanotrasen" =		   list("state" = "nanotrasen",	  "inhand" = "nanotrasen")
	)

/obj/item/storage/bible/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] stares into [name] and attempts to transcend understanding of the universe!</span>")
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

/obj/item/storage/bible/booze/populate_contents()
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
	if(!HAS_MIND_TRAIT(user, TRAIT_HOLY))
		to_chat(user, "<span class='warning'>The book sizzles in your hands.</span>")
		user.take_organ_damage(0, 10)
		return

	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='warning'>[src] slips out of your hand and hits your head.</span>")
		user.take_organ_damage(10)
		user.Paralyse(40 SECONDS)
		return

	if(M.stat != DEAD && ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(60))
			bless(H)
			H.visible_message("<span class='danger>[user] heals [H == user ? "[user.p_themselves()]" : "[H]"] with the power of [deity_name]!</span>",
				"<span class='danger'>May the power of [deity_name] compel you to be healed!</span>")
			playsound(loc, "punch", 25, 1, -1)
		else
			M.adjustBrainLoss(10)
			to_chat(M, "<span class='warning'>You feel dumber.</span>")
			H.visible_message("<span class='danger'>[user] beats [H == user ? "[user.p_themselves()]" : "[H]"] over the head with [src]!</span>")
			playsound(src.loc, "punch", 25, 1, -1)
	else
		M.visible_message("<span class='danger'>[user] smacks [M]'s lifeless corpse with [src].</span>")
		playsound(src.loc, "punch", 25, 1, -1)


/obj/item/storage/bible/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(isfloorturf(target))
		to_chat(user, "<span class='notice'>You hit the floor with the bible.</span>")
		if(HAS_MIND_TRAIT(user, TRAIT_HOLY))
			for(var/obj/O in target)
				O.cult_reveal()
	if(istype(target, /obj/machinery/door/airlock))
		to_chat(user, "<span class='notice'>You hit the airlock with the bible.</span>")
		if(HAS_MIND_TRAIT(user, TRAIT_HOLY))
			var/obj/airlock = target
			airlock.cult_reveal()

	if(HAS_MIND_TRAIT(user, TRAIT_HOLY) && target.reagents)
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
	if(!customisable || !HAS_MIND_TRAIT(user, TRAIT_HOLY))
		return

	var/list/skins = list()
	for(var/I in bible_variants)
		var/icons = bible_variants[I] // Get the accociated list
		var/image/bible_image = image('icons/obj/storage.dmi', icon_state = icons["state"])
		skins[I] = bible_image

	var/choice = show_radial_menu(user, src, skins, null, 40, CALLBACK(src, PROC_REF(radial_check), user), TRUE)
	if(!choice || !radial_check(user))
		return
	var/choice_icons = bible_variants[choice]

	icon_state = choice_icons["state"]
	item_state = choice_icons["inhand"]
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
		for(var/area/station/service/chapel/main/A in world)
			for(var/turf/T in A.contents)
				if(T.icon_state == "carpetsymbol")
					T.dir = carpet_dir*/

	SSblackbox.record_feedback("text", "religion_book", 1, "[choice]", 1)

	if(SSticker)
		SSticker.Bible_name = name
		SSticker.Bible_icon_state = icon_state
		SSticker.Bible_item_state = item_state

/obj/item/storage/bible/proc/radial_check(mob/user)
	if(!HAS_MIND_TRAIT(user, TRAIT_HOLY) || !ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!src || !H.is_in_hands(src) || H.incapacitated())
		return FALSE
	return TRUE

/obj/item/storage/bible/syndi
	name = "suspicious bible"
	desc = "For treading the line between cultist, contraband, and a hostile corporation."
	customisable = FALSE
	icon_state = "syndi"
