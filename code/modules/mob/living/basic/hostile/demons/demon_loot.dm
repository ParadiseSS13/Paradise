// Demon heart base type
/obj/item/organ/internal/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon_state = "demon_heart"
	origin_tech = "combat=5;biotech=7"
	organ_datums = list(/datum/organ/heart/always_beating, /datum/organ/battery)

/obj/item/organ/internal/heart/demon/update_icon_state()
	return //always beating visually

/obj/item/organ/internal/heart/demon/prepare_eat()
	return // Just so people don't accidentally waste it

/obj/item/organ/internal/heart/demon/attack_self__legacy__attackchain(mob/living/user)
	user.visible_message("<span class='warning'>[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!</span>", \
						"<span class='danger'>An unnatural hunger consumes you. You raise [src] to your mouth and devour it!</span>")
	playsound(user, 'sound/misc/demon_consume.ogg', 50, 1)

/// SLAUGHTER DEMON HEART

/obj/item/organ/internal/heart/demon/slaughter/attack_self__legacy__attackchain(mob/living/user)
	..()

	// Eating the heart for the first time. Gives basic bloodcrawling. This is the only time we need to insert the heart.
	if(!HAS_TRAIT(user, TRAIT_BLOODCRAWL))
		user.visible_message("<span class='warning'>[user]'s eyes flare a deep crimson!</span>", \
							"<span class='userdanger'>You feel a strange power seep into your body... you have absorbed the demon's blood-travelling powers!</span>")
		ADD_TRAIT(user, TRAIT_BLOODCRAWL, "bloodcrawl")
		user.drop_item()
		insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E.
		return TRUE

	// Eating a 2nd heart. Gives the ability to drag people into blood and eat them.
	if(HAS_TRAIT(user, TRAIT_BLOODCRAWL))
		to_chat(user, "You feel differ-<span class='danger'> CONSUME THEM!</span>")
		ADD_TRAIT(user, TRAIT_BLOODCRAWL_EAT, "bloodcrawl_eat")
		qdel(src) // Replacing their demon heart with another demon heart is pointless, just delete this one and return.
		return TRUE

	// Eating any more than 2 demon hearts does nothing.
	to_chat(user, "<span class='warning'>...and you don't feel any different.</span>")
	qdel(src)

/obj/item/organ/internal/heart/demon/slaughter/insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind)
		M.mind.AddSpell(new /datum/spell/bloodcrawl(null))

/obj/item/organ/internal/heart/demon/slaughter/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind)
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL, "bloodcrawl")
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL_EAT, "bloodcrawl_eat")
		M.mind.RemoveSpell(/datum/spell/bloodcrawl)

/// SHADOW DEMON HEART
/obj/item/organ/internal/heart/demon/shadow
	name = "heart of darkness"
	desc = "It still beats furiously, emitting an aura of fear."
	color = COLOR_BLACK

/obj/item/organ/internal/heart/demon/shadow/attack_self__legacy__attackchain(mob/living/user)
	. = ..()
	user.drop_item()
	insert(user)

/obj/item/organ/internal/heart/demon/shadow/insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind)
		M.mind.AddSpell(new /datum/spell/fireball/shadow_grapple)

/obj/item/organ/internal/heart/demon/shadow/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind)
		M.mind.RemoveSpell(/datum/spell/fireball/shadow_grapple)

/// PULSE DEMON HEART
/obj/item/organ/internal/heart/demon/pulse
	name = "perpetual pacemaker"
	desc = "It still beats furiously, thousands of bright lights shine within it."
	color = COLOR_YELLOW

/obj/item/organ/internal/heart/demon/pulse/Initialize(mapload)
	. = ..()
	set_light(13, 2, "#bbbb00")

/obj/item/organ/internal/heart/demon/pulse/attack_self__legacy__attackchain(mob/living/user)
	. = ..()
	user.drop_item()
	insert(user)

/obj/item/organ/internal/heart/demon/pulse/insert(mob/living/carbon/M, special, dont_remove_slot)
	. = ..()
	M.AddComponent(/datum/component/cross_shock, 30, 500, 2 SECONDS)
	ADD_TRAIT(M, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))
	M.set_light(3, 2, "#bbbb00")

/obj/item/organ/internal/heart/demon/pulse/remove(mob/living/carbon/M, special)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))
	M.remove_light()

/obj/item/organ/internal/heart/demon/pulse/on_life()
	if(!owner)
		return
	for(var/obj/item/stock_parts/cell/cell_to_charge in owner.GetAllContents())
		var/newcharge = min(0.05 * cell_to_charge.maxcharge + cell_to_charge.charge, cell_to_charge.maxcharge)
		if(cell_to_charge.charge < newcharge)
			cell_to_charge.charge = newcharge
			if(isobj(cell_to_charge.loc))
				var/obj/cell_location = cell_to_charge.loc
				cell_location.update_icon() //update power meters and such
			cell_to_charge.update_icon()
