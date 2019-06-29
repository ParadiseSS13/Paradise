/obj/item/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = CONDUCT
	hitsound = "swing_hit"
	force = 8.0
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	burn_state = FLAMMABLE
	burntime = 20

/obj/item/storage/briefcase/sniperbundle
	desc = "Its label reads \"genuine hardened Captain leather\", but suspiciously has no other tags or branding. Smells like L'Air du Temps."
	force = 10

/obj/item/storage/briefcase/sniperbundle/New()
	..()
	new /obj/item/gun/projectile/automatic/sniper_rifle/syndicate(src)
	new /obj/item/clothing/accessory/red(src)
	new /obj/item/clothing/under/syndicate/sniper(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/suppressor/specialoffer(src)

/obj/item/storage/briefcase/false_bottomed
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. This one feels a bit heavier than normal for how much fits in it."
	icon_state = "briefcase"
	force = 8.0
	throw_speed = 1
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 10

	var/busy_hunting = 0
	var/bottom_open = 0 //is the false bottom open?
	var/obj/item/stored_item = null //what's in the false bottom. If it's a gun, we can fire it

/obj/item/storage/briefcase/false_bottomed/Destroy()
	if(stored_item)//since the stored_item isn't in the briefcase' contents we gotta remind the game to delete it here.
		qdel(stored_item)
		stored_item = null
	..()

/obj/item/storage/briefcase/false_bottomed/afterattack(atom/A, mob/user, flag, params)
	..()
	if(stored_item && istype(stored_item, /obj/item/gun) && get_dist(A, user) > 1)
		var/obj/item/gun/stored_gun = stored_item
		stored_gun.afterattack(A, user, flag, params)
	return

/obj/item/storage/briefcase/false_bottomed/attackby(var/obj/item/item, mob/user)
	if(istype(item, /obj/item/screwdriver))
		if(!bottom_open && !busy_hunting)
			to_chat(user, "You begin to hunt around the rim of \the [src]...")
			busy_hunting = 1
			if(do_after(user, 20, target = src))
				if(user)
					to_chat(user, "You pry open the false bottom!")
				bottom_open = 1
			busy_hunting = 0
		else if(bottom_open)
			to_chat(user, "You push the false bottom down and close it with a click[stored_item ? ", with \the [stored_item] snugly inside." : "."]")
			bottom_open = 0
	else if(bottom_open)
		if(stored_item)
			to_chat(user, "<span class='warning'>There's already something in the false bottom!</span>")
			return
		if(item.w_class > WEIGHT_CLASS_NORMAL)
			to_chat(user, "<span class='warning'>\The [item] is too big to fit in the false bottom!</span>")
			return
		if(!user.drop_item(item))
			user << "<span class='warning'>\The [item] is stuck to your hands!</span>"
			return

		stored_item = item
		max_w_class = WEIGHT_CLASS_NORMAL - stored_item.w_class
		item.forceMove(null) //null space here we go - to stop it showing up in the briefcase
		to_chat(user, "You place \the [item] into the false bottom of the briefcase.")
	else
		return ..()

/obj/item/storage/briefcase/false_bottomed/attack_hand(mob/user)
	if(bottom_open && stored_item)
		user.put_in_hands(stored_item)
		to_chat(user, "You pull out \the [stored_item] from \the [src]'s false bottom.")
		stored_item = null
		max_w_class = initial(max_w_class)
	else
		return ..()

/obj/item/storage/briefcase/false_bottomed/sniper

/obj/item/storage/briefcase/false_bottomed/sniper/New()
	..()
	var/obj/item/gun/projectile/automatic/sniper_rifle/compact/SNIPER = new
	stored_item = SNIPER
