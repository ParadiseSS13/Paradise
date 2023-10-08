/obj/item/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	discrete = 1
	var/cleanspeed = 50 //slower than mop
	var/times_eaten = 0 //How many times a Drask has chewed on this bar of soap
	var/max_bites = 30 //The maximum amount of bites before the soap is depleted

/obj/item/soap/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, src, 8 SECONDS, 100, 0, FALSE)

/obj/item/soap/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(user.zone_selected == "mouth" && ishuman(target)) // cleaning out someone's mouth is a different act
		return
	if(target == user && user.a_intent == INTENT_GRAB && ishuman(target))
		var/mob/living/carbon/human/muncher = user
		if(muncher && isdrask(muncher))
			eat_soap(muncher)
			return
	target.cleaning_act(user, src, cleanspeed)

/obj/item/soap/proc/eat_soap(mob/living/carbon/human/drask/user)
	times_eaten++
	playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)
	user.adjust_nutrition(5)
	user.reagents.add_reagent("soapreagent", 3)
	if(times_eaten < max_bites)
		to_chat(user, "<span class='notice'>You take a bite of [src]. Delicious!</span>")
	else
		to_chat(user, "<span class='notice'>You finish eating [src].</span>")
		qdel(src)

/obj/item/soap/examine(mob/user)
	. = ..()
	if(!user.Adjacent(src) || !times_eaten)
		return
	if(times_eaten < (max_bites * 0.3))
		. += "<span class='notice'>[src] has bite marks on it!</span>"
	else if(times_eaten < (max_bites * 0.6))
		. += "<span class='notice'>Big chunks of [src] have been chewed off!</span>"
	else if(times_eaten < (max_bites * 0.9))
		. += "<span class='notice'>Most of [src] has been gnawed away!</span>"
	else
		. += "<span class='notice'>[src] has been eaten down to a sliver!</span>"

/obj/item/soap/attack(mob/target as mob, mob/user as mob)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_selected == "mouth")
		user.visible_message("<span class='warning'>[user] starts washing [target]'s mouth out with [name]!</span>")
		if(do_after(user, cleanspeed, target = target))
			user.visible_message("<span class='warning'>[user] washes [target]'s mouth out with [name]!</span>")
			target.reagents.add_reagent("soapreagent", 6)
		return
	..()

/obj/item/soap/can_clean()
	return TRUE

/obj/item/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"

/obj/item/soap/homemade
	desc = "A homemade bar of soap. Smells of... well...."
	icon_state = "soapgibs"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/ducttape
	desc = "A homemade bar of soap. It seems to be gibs and tape..Will this clean anything?"
	icon_state = "soapgibs"

/obj/item/soap/ducttape/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return

	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before 'cleaning' it.</span>")
	else
		user.visible_message("<span class='warning'>[user] begins to smear [src] on \the [target.name].</span>")
		if(do_after(user, cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You 'clean' \the [target.name].</span>")
			if(issimulatedturf(target))
				new /obj/effect/decal/cleanable/blood/gibs/cleangibs(target)
			else if(iscarbon(target))
				for(var/obj/item/carried_item in target.contents)
					if(!istype(carried_item, /obj/item/implant))//If it's not an implant.
						carried_item.add_mob_blood(target)//Oh yes, there will be blood...
				var/mob/living/carbon/human/H = target
				H.bloody_hands(target,0)
				H.bloody_body(target)

	return

/obj/item/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of comdoms."
	icon_state = "soapdeluxe"
	cleanspeed = 40 //slightly better because deluxe -- captain gets one of these

/obj/item/soap/syndie
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	icon_state = "soapsyndie"
	cleanspeed = 10 //much faster than mop so it is useful for traitors who want to clean crime scenes
