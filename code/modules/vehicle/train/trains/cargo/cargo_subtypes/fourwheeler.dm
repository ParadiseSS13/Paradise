/obj/vehicle/train/cargo/engine/fourwheeler //make this hold passengers
	name = "fourwheeler"
	desc = "A fast and highly maneuverable vehicle."
	icon = 'icons/vehicles/4wheeler.dmi'
	icon_state = "fourwheel"
	emagged = 0
	mob_offset_y = 6
	load_offset_x = 0
	health = 200
	charge_use = 0

/obj/vehicle/train/cargo/engine/fourwheeler/proc/update_dir_fourwheel_overlays()
	overlays = null
	if(src.dir == NORTH||SOUTH)
		if(src.dir == NORTH)
			var/image/I = new(icon = 'icons/vehicles/4wheeler.dmi', icon_state = "4wheeler_north", layer = src.layer + 0.2) //over mobs
			overlays += I
		else if(src.dir == SOUTH)
			var/image/I = new(icon = 'icons/vehicles/4wheeler.dmi', icon_state = "4wheeler_south", layer = src.layer + 0.2) //over mobs
			overlays += I

/obj/vehicle/train/cargo/engine/fourwheeler/New()
	..()
	update_dir_fourwheel_overlays()

/obj/vehicle/train/cargo/engine/fourwheeler/Move()
	..()
	update_dir_fourwheel_overlays()

/obj/vehicle/train/cargo/engine/fourwheeler/handle_rotation()
	update_dir_fourwheel_overlays()
	..()