//TODO: Make these simple_animals

#define MIN_IMPREGNATION_TIME 100 //time it takes to impregnate someone
#define MAX_IMPREGNATION_TIME 150

#define MIN_ACTIVE_TIME 200 //time between being dropped and going idle
#define MAX_ACTIVE_TIME 400

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = WEIGHT_CLASS_TINY //note: can be picked up by aliens unlike most other items of w_class below 4
	throw_range = 5
	tint = 3
	flags = AIRTIGHT
	flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES
	layer = MOB_LAYER
	max_integrity = 100

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case

	var/sterile = FALSE
	var/real = TRUE //0 for the toy, 1 for real. Sure I could istype, but fuck that.
	var/strength = 5

	var/attached = 0

/obj/item/clothing/mask/facehugger/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	..()
	if(obj_integrity < 90)
		Die()

/obj/item/clothing/mask/facehugger/attackby(obj/item/O, mob/user, params)
	return O.attack_obj(src, user)

/obj/item/clothing/mask/facehugger/attack_alien(mob/user) //can be picked up by aliens
	return attack_hand(user)

/obj/item/clothing/mask/facehugger/attack_hand(mob/user)
	if((stat == CONSCIOUS && !sterile) && !isalien(user))
		if(Attach(user))
			return
	..()

/obj/item/clothing/mask/facehugger/attack(mob/living/M, mob/user)
	..()
	user.unEquip(src)
	Attach(M)

/obj/item/clothing/mask/facehugger/examine(mob/user)
	. = ..()
	if(real)//So that giant red text about probisci doesn't show up for fake ones
		switch(stat)
			if(DEAD,UNCONSCIOUS)
				. += "<span class='boldannounce'>[src] is not moving.</span>"
			if(CONSCIOUS)
				. += "<span class='boldannounce'>[src] seems to be active!</span>"
		if(sterile)
			. += "<span class='boldannounce'>It looks like the proboscis has been removed.</span>"

/obj/item/clothing/mask/facehugger/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		Die()

/obj/item/clothing/mask/facehugger/equipped(mob/M)
	Attach(M)

/obj/item/clothing/mask/facehugger/Crossed(atom/target, oldloc)
	HasProximity(target)
	return

/obj/item/clothing/mask/facehugger/on_found(mob/finder)
	if(stat == CONSCIOUS)
		return HasProximity(finder)
	return 0

/obj/item/clothing/mask/facehugger/HasProximity(atom/movable/AM as mob|obj)
	if(CanHug(AM) && Adjacent(AM))
		return Attach(AM)
	return 0

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed)
	if(!..())
		return
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]_thrown"
		spawn(15)
			if(icon_state == "[initial(icon_state)]_thrown")
				icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]"
		Attach(hit_atom)

/obj/item/clothing/mask/facehugger/proc/Attach(mob/living/M)
	if(!isliving(M))
		return 0
	if((!iscorgi(M) && !iscarbon(M)) || isalien(M))
		return 0
	if(attached)
		return 0
	else
		attached++
		spawn(MAX_IMPREGNATION_TIME)
			attached = 0
	if(M.get_int_organ(/obj/item/organ/internal/xenos/hivenode))
		return 0
	if(M.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo))
		return 0
	if(loc == M)
		return 0
	if(stat != CONSCIOUS)
		return 0
	if(!sterile) M.take_organ_damage(strength,0) //done here so that even borgs and humans in helmets take damage
	M.visible_message("<span class='danger'>[src] leaps at [M]'s face!</span>", \
						"<span class='userdanger'>[src] leaps at [M]'s face!</span>")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.head && H.head.flags_cover & HEADCOVERSMOUTH)
			H.visible_message("<span class='danger'>[src] smashes against [H]'s [H.head]!</span>", \
								"<span class='userdanger'>[src] smashes against [H]'s [H.head]!</span>")
			Die()
			return 0
	if(iscarbon(M))
		var/mob/living/carbon/target = M
		if(target.wear_mask)
			if(prob(20))
				return 0
			if(istype(target.wear_mask, /obj/item/clothing/mask/muzzle))
				var/obj/item/clothing/mask/muzzle/S = target.wear_mask
				if(S.do_break())
					target.visible_message("<span class='danger'>[src] spits acid onto [S] melting the lock!</span>", \
									"<span class='userdanger'>[src] spits acid onto [S] melting the lock!</span>")
			var/obj/item/clothing/W = target.wear_mask
			if(W.flags & NODROP)
				return 0
			target.unEquip(W)

			target.visible_message("<span class='danger'>[src] tears [W] off of [target]'s face!</span>", \
									"<span class='userdanger'>[src] tears [W] off of [target]'s face!</span>")

		src.loc = target
		target.equip_to_slot(src, slot_wear_mask,,0)
		if(!sterile)
			M.Paralyse(MAX_IMPREGNATION_TIME/6) //something like 25 ticks = 20 seconds with the default settings

	GoIdle() //so it doesn't jump the people that tear it off

	spawn(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
		Impregnate(M)

	return 1

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/target as mob)
	if(!target || target.stat == DEAD || loc != target) //was taken off or something
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.wear_mask != src)
			return

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!H.check_has_mouth())
			return

	if(!sterile)
		//target.contract_disease(new /datum/disease/alien_embryo(0)) //so infection chance is same as virus infection chance
		target.visible_message("<span class='danger'>[src] falls limp after violating [target]'s face!</span>", \
								"<span class='userdanger'>[src] falls limp after violating [target]'s face!</span>")

		Die()
		icon_state = "[initial(icon_state)]_impregnated"

		if(!target.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo))
			new /obj/item/organ/internal/body_egg/alien_embryo(target)
	else
		target.visible_message("<span class='danger'>[src] violates [target]'s face!</span>", \
								"<span class='userdanger'>[src] violates [target]'s face!</span>")

/obj/item/clothing/mask/facehugger/proc/GoActive()
	if(stat == DEAD || stat == CONSCIOUS)
		return

	stat = CONSCIOUS
	icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/proc/GoIdle()
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

	stat = UNCONSCIOUS
	icon_state = "[initial(icon_state)]_inactive"

	spawn(rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))
		GoActive()
	return

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD)
		return

	icon_state = "[initial(icon_state)]_dead"
	item_state = "facehugger_inactive"
	stat = DEAD

	visible_message("<span class='danger'>[src] curls up into a ball!</span>")

/proc/CanHug(mob/living/M)
	if(!istype(M))
		return 0
	if(M.stat == DEAD)
		return 0
	if(M.get_int_organ(/obj/item/organ/internal/xenos/hivenode))
		return 0

	if(iscorgi(M))
		return 1

	var/mob/living/carbon/C = M
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.head && H.head.flags_cover & HEADCOVERSMOUTH)
			return 0
		return 1
	return 0

/obj/item/clothing/mask/facehugger/lamarr
	name = "Lamarr"
	desc = "The worst she might do is attempt to... couple with your head." //hope we don't get sued over a harmless reference, rite?
	sterile = 1
	gender = FEMALE
