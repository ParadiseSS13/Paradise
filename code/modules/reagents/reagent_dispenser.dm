#define AUTOIGNITION_WELDERFUEL 561.15

/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	pressure_resistance = 2*ONE_ATMOSPHERE

	var/amount_per_transfer_from_this = 10
	var/possible_transfer_amounts = list(10,25,50,100)

/obj/structure/reagent_dispensers/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	return

/obj/structure/reagent_dispensers/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	if (!possible_transfer_amounts)
		src.verbs -= /obj/structure/reagent_dispensers/verb/set_APTFT
	..()

/obj/structure/reagent_dispensers/examine()
	set src in view()
	..()
	if (!(usr in view(2)) && usr!=src.loc) return
	usr << "\blue It contains:"
	if(reagents && reagents.reagent_list.len)
		for(var/datum/reagent/R in reagents.reagent_list)
			usr << "\blue [R.volume] units of [R.name]"
	else
		usr << "\blue Nothing."

/obj/structure/reagent_dispensers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in view(1)
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/structure/reagent_dispensers/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		else
	return

/obj/structure/reagent_dispensers/blob_act()
	if(prob(50))
		new /obj/effect/effect/water(src.loc)
		qdel(src)







//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/watertank/New()
	..()
	reagents.add_reagent("water",1000)


/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 10
	var/obj/item/device/assembly_holder/rig = null

/obj/structure/reagent_dispensers/fueltank/New()
	..()
	reagents.add_reagent("fuel",1000)

/obj/structure/reagent_dispensers/fueltank/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			message_admins("[key_name_admin(Proj.firer)] triggered a fueltank explosion.")
			log_game("[key_name(Proj.firer)] triggered a fueltank explosion.")
			explode()

/obj/structure/reagent_dispensers/fueltank/blob_act()
	explosion(src.loc,0,1,5,7,10, flame_range = 5)

/obj/structure/reagent_dispensers/fueltank/ex_act()
	explode()

/obj/structure/reagent_dispensers/fueltank/examine()
	set src in view()
	..()
	if (!(usr in view(2)) && usr!=src.loc) return
	if(rig)
		usr << "<span class='notice'>There is some kind of device rigged to the tank."

/obj/structure/reagent_dispensers/fueltank/attack_hand()
	if (rig)
		usr.visible_message("[usr] begins to detach [rig] from \the [src].", "You begin to detach [rig] from \the [src]")
		if(do_after(usr, 20, target = src))
			usr.visible_message("\blue [usr] detaches [rig] from \the [src].", "\blue  You detach [rig] from \the [src]")
			rig.loc = get_turf(usr)
			rig = null
			overlays = new/list()

/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (istype(W,/obj/item/device/assembly_holder))
		if (rig)
			user << "\red There is another device in the way."
			return ..()
		user.visible_message("[user] begins rigging [W] to \the [src].", "You begin rigging [W] to \the [src]")
		if(do_after(user, 20, target = src))
			user.visible_message("\blue [user] rigs [W] to \the [src].", "\blue  You rig [W] to \the [src]")

			var/obj/item/device/assembly_holder/H = W
			if (istype(H.a_left,/obj/item/device/assembly/igniter) || istype(H.a_right,/obj/item/device/assembly/igniter))
				msg_admin_attack("[key_name_admin(user)] rigged a fueltank for explosion (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
				log_game("[key_name(user)] rigged fueltank a fueltank for explosion at [loc.x], [loc.y], [loc.z]")

				rig = W
				user.drop_item()
				W.loc = src

				var/icon/test = getFlatIcon(W)
				test.Shift(NORTH,1)
				test.Shift(EAST,6)
				overlays += test

		return ..()

/obj/structure/reagent_dispensers/fueltank/proc/explode()
	explosion(src.loc,-1,0,2, flame_range = 2)
	if(src)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank/fire_act(datum/gas_mixture/air, temperature, volume)
	blob_act() //saving a few lines of copypasta


/obj/structure/reagent_dispensers/fueltank/Move()
	..()
	if(rig)
		rig.process_movement()

/obj/structure/reagent_dispensers/fueltank/HasProximity(atom/movable/AM)
	if(rig)
		rig.HasProximity(AM)

/obj/structure/reagent_dispensers/fueltank/Crossed(atom/movable/AM)
	if(rig)
		rig.Crossed(AM)

/obj/structure/reagent_dispensers/fueltank/hear_talk(mob/living/M, msg)
	if(rig)
		rig.hear_talk(M, msg)

/obj/structure/reagent_dispensers/fueltank/Bump()
	..()
	if(rig)
		rig.process_movement()


/obj/structure/reagent_dispensers/peppertank
	name = "Pepper Spray Refiller"
	desc = "Refill pepper spray canisters."
	icon = 'icons/obj/objects.dmi'
	icon_state = "peppertank"
	anchored = 1
	density = 0
	amount_per_transfer_from_this = 45

/obj/structure/reagent_dispensers/peppertank/New()
	..()
	reagents.add_reagent("condensedcapsaicin",1000)


/obj/structure/reagent_dispensers/water_cooler
	name = "Water-Cooler"
	desc = "A machine that dispenses water to drink"
	amount_per_transfer_from_this = 5
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	possible_transfer_amounts = null
	anchored = 1

/obj/structure/reagent_dispensers/water_cooler/New()
	..()
	reagents.add_reagent("water",500)


/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg"
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/beerkeg/New()
	..()
	reagents.add_reagent("beer",1000)

/obj/structure/reagent_dispensers/beerkeg/blob_act()
	explosion(src.loc,0,3,5,7,10)
	qdel(src)

/obj/structure/reagent_dispensers/virusfood
	name = "Virus Food Dispenser"
	desc = "A dispenser of virus food."
	icon = 'icons/obj/objects.dmi'
	icon_state = "virusfoodtank"
	amount_per_transfer_from_this = 10
	anchored = 1
	density = 0

/obj/structure/reagent_dispensers/virusfood/New()
	..()
	reagents.add_reagent("virusfood", 1000)

/obj/structure/reagent_dispensers/spacecleanertank
	name = "space cleaner refiller"
	desc = "Refills space cleaner bottles."
	icon = 'icons/obj/objects.dmi'
	icon_state = "spacecleanertank"
	anchored = 1
	density = 0
	amount_per_transfer_from_this = 250

/obj/structure/reagent_dispensers/spacecleanertank/New()
	..()
	reagents.add_reagent("cleaner",5000)
