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
	..()
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
