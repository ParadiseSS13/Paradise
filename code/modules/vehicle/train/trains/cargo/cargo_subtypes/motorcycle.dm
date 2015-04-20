/obj/vehicle/train/cargo/engine/motorcycle
	name = "motorcycle"
	desc = "A fast and highly maneuverable vehicle."
	icon = 'icons/vehicles/motorcycle.dmi'
	icon_state = "motorcycle_4dir"
	emagged = 0
	mob_offset_y = 6
	load_offset_x = 0
	health = 100
	charge_use = 0

/obj/vehicle/train/cargo/engine/motorcycle/proc/update_dir_motorcycle_overlays()
	overlays = null
	if(src.dir == NORTH||SOUTH)
		if(src.dir == NORTH)
			var/image/I = new(icon = 'icons/vehicles/motorcycle.dmi', icon_state = "motorcycle_overlay_n", layer = src.layer + 0.2) //over mobs
			overlays += I
		else if(src.dir == SOUTH)
			var/image/I = new(icon = 'icons/vehicles/motorcycle.dmi', icon_state = "motorcycle_overlay_s", layer = src.layer + 0.2) //over mobs
			overlays += I
	else
		var/image/I = new(icon = 'icons/vehicles/motorcycle.dmi', icon_state = "motorcycle_overlay_side", layer = src.layer + 0.2) //over mobs
		overlays += I

/obj/vehicle/train/cargo/engine/motorcycle/New()
	..()
	update_dir_motorcycle_overlays()

/obj/vehicle/train/cargo/engine/motorcycle/Move()
	..()
	update_dir_motorcycle_overlays()

/obj/vehicle/train/cargo/engine/motorcycle/handle_rotation()
	update_dir_motorcycle_overlays() //this goes first, because vehicle/handle_rotation() just returns
	..()
