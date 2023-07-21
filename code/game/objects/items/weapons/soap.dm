/obj/item/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	belt_icon = "soap"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	discrete = 1
	var/cleanspeed = 50 //slower than mop

/obj/item/soap/ComponentInitialize()
	AddComponent(/datum/component/slippery, src, 4 SECONDS, 100, 0, FALSE)

/obj/item/soap/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	if(try_item_eat(target, user))
		return FALSE
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>")
	else if(istype(target, /obj/effect/decal/cleanable) || istype(target, /obj/effect/rune))
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
	for(var/obj/effect/O in T)
		if(is_cleanable(O))
			qdel(O)

/obj/item/soap/attack(mob/target as mob, mob/user as mob)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_selected == "mouth" )
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

/obj/item/soap/homemade_apple
	desc = "A homemade bar of soap. Smells of apple"
	icon_state = "soapapple"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_potato
	desc = "A homemade bar of soap. Smells of potato"
	icon_state = "soappotato"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_pumpkin
	desc = "A homemade bar of soap. Smells of pumpkin"
	icon_state = "soappumpkin"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_silver
	desc = "A homemade bar of soap. Smells of silver"
	icon_state = "soapsilver"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_tomato
	desc = "A homemade bar of soap. Smells of tomato"
	icon_state = "soaptomato"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_uran
	desc = "A homemade bar of soap. Smells of uranium"
	icon_state = "soapuran"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_watermelon
	desc = "A homemade bar of soap. Smells of watermelon"
	icon_state = "soapwatermelon"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_whiskey
	desc = "A homemade bar of soap. Smells of whiskey"
	icon_state = "soapwhiskey"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_banana
	desc = "A homemade bar of soap. Smells of banana"
	icon_state = "soapbanana"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_beer
	desc = "A homemade bar of soap. Smells of beer"
	icon_state = "soapbeer"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_berry
	desc = "A homemade bar of soap. Smells of berries"
	icon_state = "soapberry"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_carrot
	desc = "A homemade bar of soap. Smells of carrot"
	icon_state = "soapcarrot"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_chocolate
	desc = "A homemade bar of soap. Smells of chocolate"
	icon_state = "soapchocolate"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_cola
	desc = "A homemade bar of soap. Smells of cola"
	icon_state = "soapcola"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_corn
	desc = "A homemade bar of soap. Smells of corn"
	icon_state = "soapcorn"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_golden
	desc = "A homemade bar of soap. Smells of gold"
	icon_state = "soapgolden"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_grape
	desc = "A homemade bar of soap. Smells of grape"
	icon_state = "soapgrape"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_lemon
	desc = "A homemade bar of soap. Smells of lemon"
	icon_state = "soaplemon"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_lime
	desc = "A homemade bar of soap. Smells of lime"
	icon_state = "soaplime"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_milk
	desc = "A homemade bar of soap. Smells of milk"
	icon_state = "soapmilk"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_orange
	desc = "A homemade bar of soap. Smells of orange"
	icon_state = "soaporange"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/soap/homemade_pineapple
	desc = "A homemade bar of soap. Smells of pineapple"
	icon_state = "soappineapple"
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

/obj/item/soap/ert
	desc = "Мыло высокого качества, с запахом морской волны, специально для очистки полов от въевшейся крови неудачливого экипажа."
	icon_state = "soapert"
	cleanspeed = 10

/obj/item/soap/syndie
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	icon_state = "soapsyndie"
	belt_icon = "soapsyndie"
	cleanspeed = 10 //much faster than mop so it is useful for traitors who want to clean crime scenes
