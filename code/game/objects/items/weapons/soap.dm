/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = 1
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	discrete = 1
	var/cleanspeed = 50 //slower than mop

/obj/item/weapon/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"

/obj/item/weapon/soap/homemade
	desc = "A homemade bar of soap. Smells of... well...."
	icon_state = "soapgibs"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/weapon/soap/ducttape
	desc = "A homemade bar of soap. It seems to be gibs and tape..Will this clean anything?"
	icon_state = "soapgibs"

/obj/item/weapon/soap/ducttape/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return

	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before 'cleaning' it.</span>")
	else
		user.visible_message("<span class='warning'>[user] begins to smear [src] on \the [target.name].</span>")
		if(do_after(user, src.cleanspeed, target = target))
			to_chat(user, "<span class='notice'>You 'clean' \the [target.name].</span>")
			if(istype(target, /turf/simulated))
				new /obj/effect/decal/cleanable/blood/gibs/cleangibs(target)
			else if(istype(target,/mob/living/carbon))
				for(var/obj/item/carried_item in target.contents)
					if(!istype(carried_item, /obj/item/weapon/implant))//If it's not an implant.
						carried_item.add_blood(target)//Oh yes, there will be blood...
				var/mob/living/carbon/human/H = target
				H.bloody_hands(target,0)
				H.bloody_body(target)

	return

/obj/item/weapon/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of comdoms."
	icon_state = "soapdeluxe"
	cleanspeed = 40 //slightly better because deluxe -- captain gets one of these

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	icon_state = "soapsyndie"
	cleanspeed = 10 //much faster than mop so it is useful for traitors who want to clean crime scenes