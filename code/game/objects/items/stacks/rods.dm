/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	item_state = "rods"
	flags = CONDUCT
	w_class = 3
	force = 9.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=1000)
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")
	hitsound = 'sound/weapons/grenadelaunch.ogg'

/obj/item/stack/rods/cyborg
	materials = list()

/obj/item/stack/rods/New(var/loc, var/amount=null)
	..()

	update_icon()

/obj/item/stack/rods/update_icon()
	var/amount = get_amount()
	if((amount <= 5) && (amount > 0))
		icon_state = "rods-[amount]"
	else
		icon_state = "rods"

/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two rods to do this.</span>")
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/new_item = new(user.loc)
			new_item.add_to_stacks(user)
			if(new_item.get_amount() <= 0)
				// stack was moved into another one on the pile
				new_item = locate() in user.loc

			user.visible_message("<span class='warning'>[user.name] shaped [src] into metal with the weldingtool.</span>", \
						 "<span class='notice'>You shaped [src] into metal with the weldingtool.</span>", \
						 "<span class='warning'>You hear welding.</span>")

			var/replace = user.get_inactive_hand() == src
			use(2)
			if(get_amount() <= 0 && replace)
				user.unEquip(src, 1)
				if(new_item)
					user.put_in_hands(new_item)
		return
	..()


/obj/item/stack/rods/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if(locate(/obj/structure/grille, usr.loc))
		for(var/obj/structure/grille/G in usr.loc)
			if(G.destroyed)
				G.health = 10
				G.density = 1
				G.destroyed = 0
				G.icon_state = "grille"
				use(1)
			else
				return 1
	else
		if(amount < 2)
			to_chat(user, "\blue You need at least two rods to do this.")
			return
		to_chat(usr, "\blue Assembling grille...")

		if(!do_after(usr, 10, target = user))
			return

		var /obj/structure/grille/F = new /obj/structure/grille/ ( usr.loc )
		to_chat(usr, "\blue You assemble a grille")
		F.add_fingerprint(usr)
		use(2)
	return
