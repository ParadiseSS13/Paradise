/*
CONTAINS:
RSF
*/

/obj/item/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsf"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/mode = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	w_class = WEIGHT_CLASS_NORMAL
	var/list/configured_items = list()

/obj/item/rsf/New()
	desc = "A RSF. It currently holds [matter]/30 fabrication-units."
	// configured_items[ID_NUMBER] = list("Human-readable name", price in energy, /type/path)
	configured_items[++configured_items.len] = list("Dosh", 50, /obj/item/stack/spacecash/c10)
	configured_items[++configured_items.len] = list("Drinking Glass", 50, /obj/item/reagent_containers/food/drinks/drinkingglass)
	configured_items[++configured_items.len] = list("Paper", 50, /obj/item/paper)
	configured_items[++configured_items.len] = list("Pen", 50, /obj/item/pen)
	configured_items[++configured_items.len] = list("Dice Pack", 50, /obj/item/storage/pill_bottle/dice)
	configured_items[++configured_items.len] = list("Cigarette", 50, /obj/item/clothing/mask/cigarette)
	configured_items[++configured_items.len] = list("Snack - Newdles", 4000, /obj/item/reagent_containers/food/snacks/chinese/newdles)
	configured_items[++configured_items.len] = list("Snack - Donut", 4000, /obj/item/reagent_containers/food/snacks/donut)
	configured_items[++configured_items.len] = list("Snack - Chicken Soup", 4000, /obj/item/reagent_containers/food/drinks/chicken_soup)
	configured_items[++configured_items.len] = list("Snack - Turkey Burger", 4000, /obj/item/reagent_containers/food/snacks/tofuburger)
	return

/obj/item/rsf/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/rcd_ammo))
		if((matter + 10) > 30)
			to_chat(user, "The RSF cant hold any more matter.")
			return
		qdel(W)
		matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
		to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
		desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

/obj/item/rsf/attack_self(mob/user as mob)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if(mode == configured_items.len)
		mode = 1
	else
		mode++
	to_chat(user, "Changed dispensing mode to '" + configured_items[mode][1] + "'")


/obj/item/rsf/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if(!(istype(A, /obj/structure/table) || istype(A, /turf/simulated/floor)))
		return
	var spawn_location
	var/turf/T = get_turf(A)
	if(istype(T) && !T.density)
		spawn_location = T
	else
		to_chat(user, "The RSF can only create service items on tables, or floors.")
		return
	if(isrobot(user))
		var/mob/living/silicon/robot/engy = user
		if(!engy.cell.use(configured_items[mode][2]))
			to_chat(user, "<span class='warning'>Insufficient energy.</span>")
			return
	else
		if(!matter)
			to_chat(user, "<span class='warning'>Insufficient matter.</span>")
			return
		matter--
		to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
		desc = "A RSF. It currently holds [matter]/30 fabrication-units."

	to_chat(user, "Dispensing " + configured_items[mode][1] + "...")
	playsound(loc, 'sound/machines/click.ogg', 10, 1)
	var/type_path = configured_items[mode][3]
	new type_path(spawn_location)
/*
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
	*/