/obj/item/weapon/gun/throw/piecannon
	name = "pie cannon"
	desc = "A projectile weapon that fires pies."
	icon_state = "piecannon"
	w_class = 5
	throw_speed = 2
	throw_range = 3
	force = 5

	clumsy_check = 0
	valid_projectile_type = /obj/item/weapon/reagent_containers/food/snacks/pie
	max_capacity = 5
	projectile_speed = 2
	projectile_range = 30


/obj/item/weapon/gun/throw/piecannon/New()
	..()
	for(var/i in 1 to max_capacity)
		var/obj/item/weapon/reagent_containers/food/snacks/pie/P = new /obj/item/weapon/reagent_containers/food/snacks/pie(src)
		loaded_projectiles += P
	process_chamber()

/obj/item/weapon/gun/throw/piecannon/notify_ammo_count(mob/user)
	to_chat(user, "<span class='notice'>[src] has [get_ammocount()] of [max_capacity] pies left.")

/obj/item/weapon/gun/throw/piecannon/update_icon()
	if(to_launch)
		icon_state = "piecannon1"
	else
		icon_state = "piecannon0"
	item_state = icon_state

/obj/item/weapon/gun/throw/piecannon/process_chamber()
	..()
	update_icon()
