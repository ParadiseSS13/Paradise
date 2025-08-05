/obj/item/bio_chip/explosive
	name = "microbomb bio-chip"
	desc = "And boom goes the weasel."
	icon_state = "explosive"
	origin_tech = "materials=2;combat=3;biotech=4;syndicate=4"
	actions_types = list(/datum/action/item_action/hands_free/activate/always)
	trigger_causes = BIOCHIP_TRIGGER_DEATH_ONCE // Not surviving that
	implant_data = /datum/implant_fluff/explosive
	implant_state = "implant-syndicate"

	var/detonating = FALSE
	var/weak = 2
	var/medium = 0.8
	var/heavy = 0.4
	var/delay = 7

/obj/item/bio_chip/explosive/death_trigger(mob/source, gibbed)
	activate("death")

/obj/item/bio_chip/explosive/activate(cause)
	if(!cause || !imp_in)
		return FALSE
	if(cause == "action_button" && alert(imp_in, "Are you sure you want to activate your microbomb bio-chip? This will cause you to explode!", "Microbomb Bio-chip Confirmation", "Yes", "No") != "Yes")
		return FALSE
	if(detonating)
		return FALSE
	heavy = round(heavy)
	medium = round(medium)
	weak = round(weak)
	detonating = TRUE
	to_chat(imp_in, "<span class='danger'>You activate your microbomb bio-chip.</span>")
//If the delay is short, just blow up already jeez
	if(delay <= 7)
		self_destruct()
		return
	timed_explosion()

/// Gib the implantee and delete their destructible contents.
/obj/item/bio_chip/explosive/proc/self_destruct()
	if(!imp_in)
		return

	explosion(src, heavy, medium, weak, weak, flame_range = weak, cause = name)

	// In case something happens to the implantee between now and the
	// self-destruct
	var/current_location = get_turf(imp_in)

	var/list/destructed_items = list()

	// Iterate over the implantee's contents and take out indestructible
	// things to avoid having to worry about containers and recursion
	for(var/obj/item/I in imp_in.get_contents())
		if(I == src) // Don't delete ourselves prematurely
			continue
		// Drop indestructible items on the ground first, to avoid them
		// getting deleted when destroying the rest of the items, which we
		// track in a list to qdel afterwards
		if(I.resistance_flags & INDESTRUCTIBLE)
			I.forceMove(current_location)
		else
			destructed_items += I

	QDEL_LIST_CONTENTS(destructed_items)

	imp_in.gib()

	qdel(src)

/obj/item/bio_chip/explosive/implant(mob/source)
	var/obj/item/bio_chip/explosive/imp_e = locate(type) in source
	if(imp_e && imp_e != src)
		imp_e.heavy += heavy
		imp_e.medium += medium
		imp_e.weak += weak
		imp_e.delay += delay
		qdel(src)
		return TRUE

	return ..()

/obj/item/bio_chip/explosive/proc/timed_explosion()
	imp_in.visible_message("<span class = 'warning'>[imp_in] starts beeping ominously!</span>")
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	var/wait_delay = delay / 4
	sleep(wait_delay)
	if(imp_in && imp_in.stat)
		imp_in.visible_message("<span class = 'warning'>[imp_in] doubles over in pain!</span>")
		imp_in.Weaken(14 SECONDS)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(wait_delay)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(wait_delay)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(wait_delay)
	self_destruct()

/obj/item/bio_chip/explosive/macro
	name = "macrobomb bio-chip"
	desc = "And boom goes the weasel. And everything else nearby."
	origin_tech = "materials=3;combat=5;biotech=4;syndicate=5"
	weak = 16
	medium = 8
	heavy = 4
	delay = 3 SECONDS
	implant_data = new /datum/implant_fluff/explosive_macro

/obj/item/bio_chip/explosive/macro/activate(cause)
	if(!cause || !imp_in)
		return FALSE
	if(cause == "action_button" && alert(imp_in, "Are you sure you want to activate your macrobomb bio-chip? This will cause you to explode and gib!", "Macrobomb Bio-chip Confirmation", "Yes", "No") != "Yes")
		return FALSE
	to_chat(imp_in, "<span class='notice'>You activate your macrobomb bio-chip.</span>")
	timed_explosion()

/obj/item/bio_chip/explosive/macro/implant(mob/source)
	var/obj/item/bio_chip/explosive/imp_e = locate(type) in source
	if(imp_e && imp_e != src)
		return FALSE
	imp_e = locate(/obj/item/bio_chip/explosive) in source
	if(imp_e && imp_e != src)
		heavy += imp_e.heavy
		medium += imp_e.medium
		weak += imp_e.weak
		delay += imp_e.delay
		qdel(imp_e)

	return ..()


/obj/item/bio_chip_implanter/explosive
	name = "bio-chip implanter (explosive)"
	implant_type = /obj/item/bio_chip/explosive

/obj/item/bio_chip_case/explosive
	name = "bio-chip case - 'Micro Explosive'"
	desc = "A glass case containing a micro explosive bio-chip."
	implant_type = /obj/item/bio_chip/explosive

/obj/item/bio_chip_implanter/explosive_macro
	name = "bio-chip implanter (macro-explosive)"
	implant_type = /obj/item/bio_chip/explosive/macro

/obj/item/bio_chip_case/explosive_macro
	name = "bio-chip case - 'Macro Explosive'"
	desc = "A glass case containing a macro explosive bio-chip."
	implant_type = /obj/item/bio_chip/explosive/macro
