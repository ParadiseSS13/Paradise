var/global/list/datum/stack_recipe/rod_recipes = list ( \
	new/datum/stack_recipe("grille", /obj/structure/grille, 2, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("table frame", /obj/structure/table_frame, 2, time = 10, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	item_state = "rods"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_NORMAL
	force = 9.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=1000)
	max_amount = 50
	attack_verb = list("hit", "bludgeoned", "whacked")
	hitsound = 'sound/weapons/grenadelaunch.ogg'
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/stack/rods/cyborg
	materials = list()

/obj/item/stack/rods/New(loc, amount=null)
	..()
	recipes = rod_recipes
	update_icon()

/obj/item/stack/rods/update_icon()
	var/amount = get_amount()
	if((amount <= 5) && (amount > 0))
		icon_state = "rods-[amount]"
	else
		icon_state = "rods"

/obj/item/stack/rods/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W

		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two rods to do this!</span>")
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/new_item = new(user.loc)
			if(new_item.get_amount() <= 0)
				// stack was moved into another one on the pile
				new_item = locate() in user.loc

			user.visible_message("[user.name] shape [src] into metal with the welding tool.", \
						 "<span class='notice'>You shape [src] into metal with the welding tool.</span>", \
						 "<span class='italics'>You hear welding.</span>")

			var/replace = user.is_in_inactive_hand(src)
			use(2)
			if(get_amount() <= 0 && replace)
				user.unEquip(src, 1)
				if(new_item)
					user.put_in_hands(new_item)
		return
	..()
