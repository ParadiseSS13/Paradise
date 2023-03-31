/*
CONTAINS:
RSF
*/

/obj/item/rsf
	name = "\improper Rapid-Service-Fabricator"
	var/name_short = "RSF"
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

/obj/item/rsf/New(use_rsf_list = TRUE)
	..()
	if(use_rsf_list)
		configured_items = list(
			list("Dosh", 50, /obj/item/stack/spacecash/c10),
			list("Drinking Glass", 50, /obj/item/reagent_containers/food/drinks/drinkingglass),
			list("Paper", 50, /obj/item/paper),
			list("Pen", 50, /obj/item/pen),
			list("Dice Pack", 50, /obj/item/storage/pill_bottle/dice),
			list("Cigarette", 50, /obj/item/clothing/mask/cigarette/menthol),
			list("Deck of cards", 50, /obj/item/deck/cards),
			list("Prize ticket", 250, /obj/item/stack/tickets/five)
		)
		update_desc()

/obj/item/rsf/rff
	name = "\improper Rapid-Food-Fabricator"
	name_short = "RFF"
	desc = "A device used to rapidly deploy delucious food!"
	icon_state = "rff"

/obj/item/rsf/rff/New()
	..(use_rsf_list = FALSE)
	configured_items = list(
		list("Chinese noodles", 3000, /obj/item/reagent_containers/food/snacks/chinese/newdles),
		list("Donut", 3000, /obj/item/reagent_containers/food/snacks/donut),
		list("Chiken soup", 3000, /obj/item/reagent_containers/food/drinks/chicken_soup),
		list("Tofu burger", 3000, /obj/item/reagent_containers/food/snacks/tofuburger),
		list("Admiral Yamomoto's carp", 3000, /obj/item/reagent_containers/food/snacks/chinese/tao),
		list("Chimichanga", 3000, /obj/item/reagent_containers/food/snacks/chimichanga),
		list("Ikura sushi", 3000, /obj/item/reagent_containers/food/snacks/sushi_Ikura)
	)
	update_desc()

/obj/item/rsf/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/rcd_ammo))
		if((matter + 10) > 30)
			to_chat(user, "The [name_short] cant hold any more matter.")
			return
		qdel(W)
		matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
		to_chat(user, "The [name_short] now holds [matter]/30 fabrication-units.")
		desc = "A [name_short]. It currently holds [matter]/30 fabrication-units."
		return

/obj/item/rsf/attack_self(mob/user as mob)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if(mode >= configured_items.len)
		mode = 1
	else
		mode++
	to_chat(user, "Changed dispensing mode to '" + configured_items[mode][1] + "'")
	update_desc()

/obj/item/rsf/proc/update_desc()
	desc = initial(desc) + " Currently set to dispense '[configured_items[mode][1]]'."

/obj/item/rsf/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if(!(istype(A, /obj/structure/table) || istype(A, /turf/simulated/floor)))
		return
	var/spawn_location
	var/turf/T = get_turf(A)
	if(istype(T) && !T.density)
		spawn_location = T
	else
		to_chat(user, "The [name_short] can only create service items on tables, or floors.")
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
		to_chat(user, "The [name_short] now holds [matter]/30 fabrication-units.")
		desc = "A [name_short]. It currently holds [matter]/30 fabrication-units."

	to_chat(user, "Dispensing " + configured_items[mode][1] + "...")
	playsound(loc, 'sound/machines/click.ogg', 10, 1)
	var/type_path = configured_items[mode][3]
	new type_path(spawn_location)
