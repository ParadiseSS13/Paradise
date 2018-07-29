/obj/item/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	discrete = 1

	trip_stun = 4
	trip_weaken = 2
	trip_chance = 100
	trip_walksafe = FALSE
	trip_verb = TV_SLIP

	var/cleanspeed = 50 //slower than mop

/obj/item/soap/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>")
	else if(target == user && user.a_intent == INTENT_GRAB && ishuman(target))
		var/mob/living/carbon/human/muncher = user
		if(muncher && isdrask(muncher))
			to_chat(user, "You take a bite of the [name]. Delicious!")
			playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)
			user.nutrition += 2
	else if(istype(target,/obj/effect/decal/cleanable))
		user.visible_message("<span class='warning'>[user] begins to scrub \the [target.name] out with [src].</span>")
		if(do_after(user, cleanspeed, target = target) && target)
			to_chat(user, "<span class='notice'>You scrub \the [target.name] out.</span>")
			if(issimulatedturf(target.loc))
				clean_turf(target.loc)
				return
			qdel(target)
	else if(issimulatedturf(target))
		user.visible_message("<span class='warning'>[user] begins to clean \the [target.name] with [src].</span>")
		if(do_after(user, cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
			clean_turf(target)
	else
		user.visible_message("<span class='warning'>[user] begins to clean \the [target.name] with [src].</span>")
		if(do_after(user, cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			target.clean_blood()

/obj/item/soap/proc/clean_turf(turf/simulated/T)
	T.clean_blood()
	T.dirt = 0
	for(var/obj/effect/O in T)
		if(is_cleanable(O))
			qdel(O)

/obj/item/soap/attack(mob/target as mob, mob/user as mob)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == "mouth" )
		user.visible_message("<span class='warning'>\the [user] washes \the [target]'s mouth out with [name]!</span>")
		return
	..()

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
			if(istype(target, /turf/simulated))
				new /obj/effect/decal/cleanable/blood/gibs/cleangibs(target)
			else if(istype(target,/mob/living/carbon))
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
