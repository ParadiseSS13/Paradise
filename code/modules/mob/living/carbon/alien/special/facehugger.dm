//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//TODO: Make these simple_animals

var/const/MIN_IMPREGNATION_TIME = 100 //time it takes to impregnate someone
var/const/MAX_IMPREGNATION_TIME = 150

var/const/MIN_ACTIVE_TIME = 200 //time between being dropped and going idle
var/const/MAX_ACTIVE_TIME = 400

/obj/item/weapon/holder/facehugger
	name = "facehugger"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	origin_tech = "magnets=3;biotech=5"
	w_class = 1
	flags = FPRINT | TABLEPASS | MASKCOVERSMOUTH | MASKCOVERSEYES | MASKINTERNALS
	body_parts_covered = HEAD
	slot_flags = SLOT_MASK

/*
/obj/item/weapon/holder/facehugger/throw_at(atom/target, range, speed)
	..()
	icon_state = "[initial(icon_state)]_thrown"
	spawn(15)
		if(icon_state == "[initial(icon_state)]_thrown")
			icon_state = "[initial(icon_state)]"


/obj/item/weapon/holder/facehugger/throw_impact(atom/hit_atom)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]"
		Attach(hit_atom)
*/


/mob/living/carbon/alien/facehugger
	name = "alien facehugger"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	flags = FPRINT | TABLEPASS
	throw_range = 5

	maxHealth = 5
	health = 5
	var/strength=5
	var/sterile = 0
	var/attached = 0
	var/icon_dead = "facehugger_dead"

/mob/living/carbon/alien/facehugger/New()
	if(aliens_allowed)
//		if(name == "alien facehugger")
//			name = "alien facehugger ([rand(1, 1000)])"
		real_name = name
		regenerate_icons()
		..()
	else
		del(src)

/mob/living/carbon/alien/facehugger/attack_hand(mob/living/carbon/M as mob)

	//Let people pick the little buggers up.
	if(istype(M,/mob/living/carbon/alien/humanoid))
		var/mob/living/carbon/alien/humanoid/H = M
		if(H.a_intent == "help")
			var/obj/item/weapon/holder/facehugger/F = new(loc)
			src.loc = F
			F.name = loc.name
			F.attack_hand(H)
			H << "You scoop up [src]."
			src << "[H] scoops you up."
			return
	else if(istype(M,/mob/living/carbon/human))
		if(stat == CONSCIOUS && !sterile)
			Attach(M)
			return
		else
			..()
			return
	..()

/mob/living/carbon/alien/facehugger/UnarmedAttack(var/atom/A)
	return

/mob/living/carbon/alien/facehugger/examine()
	..()
	switch(stat)
		if(DEAD,UNCONSCIOUS)
			usr << "\red \b [src] is not moving."
		if(CONSCIOUS)
			usr << "\red \b [src] seems to be active."
	if (sterile)
		usr << "\red \b It looks like the proboscis has been removed."
	return

/mob/living/carbon/alien/facehugger/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"

	if(stat != CONSCIOUS)
		return

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\green You are now hiding.")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("<B>[] scurries to the ground!</B>", src)
	else
		layer = MOB_LAYER
		src << text("\green You have stopped hiding.")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("[] slowly peaks up from the ground...", src)


/mob/living/carbon/alien/facehugger/verb/Attach()
	set name = "Facehug"
	set desc = "Allows you to molest someone's mouth-hole in the hope of impregnating them with an embryo."
	set category = "Alien"

	var/list/choices = list()
	for(var/mob/living/L in view(1,src))
		if(L.stat != 2 && !istype(L,/mob/living/carbon/alien) && src.Adjacent(L))
			choices += L

	var/mob/living/M = pick(choices)

	if(!M || !src) return

	if(!(src.Adjacent(M))) return

	if( (!iscorgi(M) && !iscarbon(M)) || isalien(M))
		return
	if(attached)
		return

	attached++
	spawn(MAX_IMPREGNATION_TIME)
		attached = 0

	if(loc == M) return
	if(stat != CONSCIOUS)	return
	if(!sterile) M.take_organ_damage(strength,0) //done here so that even borgs and humans in helmets take damage

	M.visible_message("\red \b [src] leaps at [M]'s face!")

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.head && H.head.flags & HEADCOVERSMOUTH)
			H.visible_message("\red \b [src] smashes against [H]'s [H.head]!")
			death()
			return

	if(iscarbon(M))
		var/mob/living/carbon/target = M

		if(target.wear_mask)
			if(prob(20))	return
			var/obj/item/clothing/W = target.wear_mask
			if(!W.canremove)	return
			target.drop_from_inventory(W)

			target.visible_message("\red \b [src] tears [W] off of [target]'s face!")

		var/obj/item/weapon/holder/facehugger/FH = new(loc)
		src.loc = FH
		FH.name = loc.name
		target.equip_to_slot(FH, slot_wear_mask)
		target.regenerate_icons()

		if(!sterile) M.Paralyse(MAX_IMPREGNATION_TIME/6) //something like 25 ticks = 20 seconds with the default settings

	else if (iscorgi(M))
		var/mob/living/simple_animal/corgi/C = M
		var/obj/item/weapon/holder/facehugger/FH = new(loc)
		src.loc = FH
		FH.name = loc.name
		FH.loc = C
		C.facehugger = FH
		C.wear_mask = FH
		C.regenerate_icons()


	spawn(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
		Impregnate(M)

	return

/mob/living/carbon/alien/facehugger/proc/Impregnate(mob/living/target as mob)
	if(!target || !target.wear_mask || (!src in target.wear_mask.contents)  || target.stat == DEAD || target.status_flags & XENO_HOST) //was taken off or something
		return

	if(!sterile)
		//target.contract_disease(new /datum/disease/alien_embryo(0)) //so infection chance is same as virus infection chance
		var/mob/living/carbon/alien/embryo/A = new /mob/living/carbon/alien/embryo(target)
		target.status_flags |= XENO_HOST

		loc = get_turf(target.loc)
		death()
		icon_state = "[initial(icon_state)]_impregnated"

		target.visible_message("\red \b [src] falls limp after violating [target]'s face!")
		A.key = src.key

		if(iscorgi(target))
			var/mob/living/simple_animal/corgi/C = target
			src.loc = get_turf(C)
			C.facehugger = null
	else
		target.visible_message("\red \b [src] violates [target]'s face!")
	return


/proc/CanHug(var/mob/M)

	if(iscorgi(M))
		return 1

	if(!iscarbon(M) || isalien(M))
		return 0
	var/mob/living/carbon/C = M
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.head && H.head.flags & HEADCOVERSMOUTH)
			return 0
	return 1

/mob/living/carbon/alien/facehugger/Login()
	..()
	sleeping = 0

/mob/living/carbon/alien/facehugger/death(gibbed)
	icon_state = icon_dead
	return ..(gibbed)

/mob/living/carbon/alien/facehugger/Life()
	..()
	//Status updates, death etc.
	handle_regular_status_updates()

/mob/living/carbon/alien/facehugger/proc/handle_regular_status_updates()
	updatehealth()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		if(health <= 0 || brain_op_stage == 4.0)
			death()
			blinded = 1
			silent = 0
			return 1

		//UNCONSCIOUS. NO-ONE IS HOME
		if( (getOxyLoss() > 5) || (0 > health) )
			//if( health <= 20 && prob(1) )
			//	spawn(0)
			//		emote("gasp")
			if(!reagents.has_reagent("inaprovaline"))
				adjustOxyLoss(1)
			Paralyse(3)

		if(paralysis)
			AdjustParalysis(-2)
			blinded = 1
			stat = UNCONSCIOUS
		else if(sleeping)
			sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = UNCONSCIOUS
			if( prob(10) && health )
				spawn(0)
					emote("hiss_")
		//CONSCIOUS
		else
			stat = CONSCIOUS

		/*	What in the living hell is this?*/
		if(move_delay_add > 0)
			move_delay_add = max(0, move_delay_add - rand(1, 2))

		//Eyes
		if(sdisabilities & BLIND)	//disabled-blind, doesn't get better on its own
			blinded = 1
		else if(eye_blind)			//blindness, heals slowly over time
			eye_blind = max(eye_blind-1,0)
			blinded = 1
		else if(eye_blurry)	//blurry eyes heal slowly
			eye_blurry = max(eye_blurry-1, 0)

		//Ears
		if(sdisabilities & DEAF)	//disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(ear_deaf)			//deafness, heals slowly over time
			ear_deaf = max(ear_deaf-1, 0)
		else if(ear_damage < 5)	//ear damage heals slowly under this threshold.
			ear_damage = max(ear_damage-0.05, 0)

		//Other
		if(stunned)
			AdjustStunned(-1)

		if(weakened)
			weakened = max(weakened-1,0)	//before you get mad Rockdtben: I done this so update_canmove isn't called multiple times

		if(stuttering)
			stuttering = max(stuttering-1, 0)

		if(silent)
			silent = max(silent-1, 0)

		if(druggy)
			druggy = max(druggy-1, 0)
	return 1
