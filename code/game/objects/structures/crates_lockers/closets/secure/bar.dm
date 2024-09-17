/obj/structure/closet/secure_closet/bar
	name = "Booze cabinet"
	req_access = list(ACCESS_BAR)
	icon_state = "cabinet"
	door_anim_time = 0
	resistance_flags = FLAMMABLE
	max_integrity = 70
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50

/obj/structure/closet/secure_closet/bar/populate_contents()
	new /obj/item/reagent_containers/drinks/cans/beer(src)
	new /obj/item/reagent_containers/drinks/cans/beer(src)
	new /obj/item/reagent_containers/drinks/cans/beer(src)
	new /obj/item/reagent_containers/drinks/cans/beer(src)
	new /obj/item/reagent_containers/drinks/cans/beer(src)
	new /obj/item/reagent_containers/drinks/cans/beer(src)
	new /obj/item/reagent_containers/drinks/cans/beer(src)
	new /obj/item/reagent_containers/drinks/cans/beer(src)
	new /obj/item/reagent_containers/drinks/cans/beer(src)
	new /obj/item/reagent_containers/drinks/cans/beer(src)
