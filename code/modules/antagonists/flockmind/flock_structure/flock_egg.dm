/obj/structure/flock/egg
	icon_state = "egg"
	name = "glowing orb"
	desc = "Some sort of small machine. It looks like its getting ready for something."
	flock_desc = "Will soon hatch into a Flockdrone."

	anchored = FALSE
	density = FALSE

	max_integrity = 30

	flock_id = "Second-Stage Assembler"
	build_time = 6 SECONDS
	no_flock_decon = TRUE

/obj/structure/flock/egg/finish_building()
	. = ..()

	AddComponent(/datum/component/flock_protection)
	spawn_mobs()
	qdel(src)

/obj/structure/flock/egg/update_info_tag()
	info_tag.set_text("Hatch Time: [build_time_left()] seconds")

/obj/structure/flock/egg/proc/spawn_mobs()
	new /mob/living/basic/flock/drone(get_turf(src), flock)

/obj/structure/flock/egg/bit
	flock_id = "Secondary Second-Stage Assembler"
	flock_desc = "Will soon hatch into Flockbits."

/obj/structure/flock/egg/bit/spawn_mobs()
	for(var/i in 1 to 3)
		new /mob/living/basic/flock/bit(get_turf(src), flock)
