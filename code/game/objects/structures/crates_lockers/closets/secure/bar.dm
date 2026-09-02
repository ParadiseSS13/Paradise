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

/obj/structure/closet/secure_closet/bar/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/reagent_containers/drinks/bottle/beer(src)
