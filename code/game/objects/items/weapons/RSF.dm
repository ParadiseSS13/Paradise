/*
CONTAINS:
RSF

*/
/obj/item/weapon/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsf"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/mode = 1
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/rsf/New()
	desc = "A RSF. It currently holds [matter]/30 fabrication-units."
	return

/obj/item/weapon/rsf/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/weapon/rcd_ammo))
		if((matter + 10) > 30)
			to_chat(user, "The RSF cant hold any more matter.")
			return
		qdel(W)
		matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
		to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
		desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

/obj/item/weapon/rsf/attack_self(mob/user as mob)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if(mode == 1)
		mode = 2
		to_chat(user, "Changed dispensing mode to 'Drinking Glass'")
		return
	if(mode == 2)
		mode = 3
		to_chat(user, "Changed dispensing mode to 'Paper'")
		return
	if(mode == 3)
		mode = 4
		to_chat(user, "Changed dispensing mode to 'Pen'")
		return
	if(mode == 4)
		mode = 5
		to_chat(user, "Changed dispensing mode to 'Dice Pack'")
		return
	if(mode == 5)
		mode = 6
		to_chat(user, "Changed dispensing mode to 'Cigarette'")
		return
	if(mode == 6)
		mode = 1
		to_chat(user, "Changed dispensing mode to 'Dosh'")
		return
	// Change mode

/obj/item/weapon/rsf/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if(!(istype(A, /obj/structure/table) || istype(A, /turf/simulated/floor)))
		return

	if(istype(A, /obj/structure/table) && mode == 1)
		if(istype(A, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Dosh...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/stack/spacecash/c10( A.loc )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 200 //once money becomes useful, I guess changing this to a high ammount, like 500 units a kick, till then, enjoy dosh!
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if(istype(A, /turf/simulated/floor) && mode == 1)
		if(istype(A, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Dosh...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/stack/spacecash/c10( A )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 200 //once money becomes useful, I guess changing this to a high ammount, like 500 units a kick, till then, enjoy dosh!
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if(istype(A, /obj/structure/table) && mode == 2)
		if(istype(A, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Drinking Glass...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass( A.loc )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 50
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if(istype(A, /turf/simulated/floor) && mode == 2)
		if(istype(A, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Drinking Glass...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass( A )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 50
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if(istype(A, /obj/structure/table) && mode == 3)
		if(istype(A, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Paper Sheet...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/weapon/paper( A.loc )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 10
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if(istype(A, /turf/simulated/floor) && mode == 3)
		if(istype(A, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Paper Sheet...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/weapon/paper( A )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 10
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if(istype(A, /obj/structure/table) && mode == 4)
		if(istype(A, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Pen...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/weapon/pen( A.loc )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 50
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if(istype(A, /turf/simulated/floor) && mode == 4)
		if(istype(A, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Pen...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/weapon/pen( A )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 50
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if(istype(A, /obj/structure/table) && mode == 5)
		if(istype(A, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Dice Pack...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/weapon/storage/pill_bottle/dice( A.loc )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 200
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if(istype(A, /turf/simulated/floor) && mode == 5)
		if(istype(A, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Dice Pack...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/weapon/storage/pill_bottle/dice( A )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 200
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if(istype(A, /obj/structure/table) && mode == 6)
		if(istype(A, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Cigarette...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/clothing/mask/cigarette( A.loc )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 10
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if(istype(A, /turf/simulated/floor) && mode == 6)
		if(istype(A, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Cigarette...")
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			new /obj/item/clothing/mask/cigarette( A )
			if(isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 10
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

/obj/item/weapon/cookiesynth
	name = "\improper Cookie Synthesizer"
	desc = "A self-recharging device used to rapidly deploy cookies."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	var/matter = 10
	var/toxin = FALSE
	var/cooldown = 0
	var/cooldowndelay = 10
	var/emagged = FALSE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/cookiesynth/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It currently holds [matter]/10 cookie-units.</span>")

/obj/item/weapon/cookiesynth/attackby()
	return

/obj/item/weapon/cookiesynth/emag_act(mob/user)
	emagged = !emagged
	if(emagged)
		to_chat(user, "<span class='warning'>You short out [src]'s reagent safety checker!</span>")
	else
		to_chat(user, "<span class='warning'>You reset [src]'s reagent safety checker!</span>")
		toxin = FALSE

/obj/item/weapon/cookiesynth/attack_self(mob/user)
	var/mob/living/silicon/robot/P = null
	if(isrobot(user))
		P = user
	if(emagged && !toxin)
		toxin = TRUE
		to_chat(user, "<span class='warning'>Cookie Synthesizer Hacked.</span>")
	else if(P.emagged && !toxin)
		toxin = TRUE
		to_chat(user, "<span class='warning'>Cookie Synthesizer Hacked.</span>")
	else
		toxin = FALSE
		to_chat(user, "<span class='notice'>Cookie Synthesizer Reset.</span>")

/obj/item/weapon/cookiesynth/process()
	if(matter < 10)
		matter++

/obj/item/weapon/cookiesynth/afterattack(atom/A, mob/user, proximity)
	if(cooldown > world.time)
		return
	if(!proximity)
		return
	if(!(istype(A, /obj/structure/table) || isfloorturf(A)))
		return
	if(matter < 1)
		to_chat(user, "<span class='warning'>[src] doesn't have enough matter left. Wait for it to recharge!</span>")
		return
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 400)
			to_chat(user, "<span class='warning'>You do not have enough power to use [src].</span>")
			return
	var/turf/T = get_turf(A)
	playsound(loc, 'sound/machines/click.ogg', 10, 1)
	to_chat(user, "Fabricating Cookie..")
	var/obj/item/weapon/reagent_containers/food/snacks/cookie/S = new /obj/item/weapon/reagent_containers/food/snacks/cookie(T)
	if(toxin)
		S.reagents.add_reagent("pancuronium", 2.4)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= 100
	else
		matter--
	cooldown = world.time + cooldowndelay