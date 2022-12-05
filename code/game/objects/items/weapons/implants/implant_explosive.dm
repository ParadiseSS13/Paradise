/obj/item/implant/explosive
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

/obj/item/implant/explosive/death_trigger(mob/source, gibbed)
	activate("death")

/obj/item/implant/explosive/activate(cause)
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

// Micro/macro-bomb users (typically nukies) should have all of their
// (destructible) equipment destroyed on activation.
/obj/item/implant/explosive/proc/self_destruct()
	if(!imp_in)
		return

	explosion(src, heavy,medium,weak,weak, flame_range = weak)

	// Iterate over the implantee's contents and take out indestructible
	// things to avoid having to worry about containers and recursion
	var/preserved_items = list()
	var/destructed_items = list()
	// In case something happens to the implantee between now and the
	// self-destruct
	var/current_location = get_turf(imp_in)

	for(var/obj/item/I in imp_in.get_contents())
		if(I)
			if(I == src) // Don't delete ourselves prematurely
				continue
			if(I.resistance_flags & INDESTRUCTIBLE)
				preserved_items += I
			else
				destructed_items += I

	for(var/obj/item/I in preserved_items)
		I.forceMove(current_location)

	for(var/obj/item/I in destructed_items)
		qdel(I)

	imp_in.gib()

	qdel(src)

/obj/item/implant/explosive/implant(mob/source)
	var/obj/item/implant/explosive/imp_e = locate(type) in source
	if(imp_e && imp_e != src)
		imp_e.heavy += heavy
		imp_e.medium += medium
		imp_e.weak += weak
		imp_e.delay += delay
		qdel(src)
		return TRUE

	return ..()

/obj/item/implant/explosive/proc/timed_explosion()
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

/obj/item/implant/explosive/macro
	name = "macrobomb bio-chip"
	desc = "And boom goes the weasel. And everything else nearby."
	icon_state = "explosive"
	origin_tech = "materials=3;combat=5;biotech=4;syndicate=5"
	weak = 16
	medium = 8
	heavy = 4
	delay = 70
	implant_data = new /datum/implant_fluff/explosive_macro

/obj/item/implant/explosive/macro/activate(cause)
	if(!cause || !imp_in)
		return FALSE
	if(cause == "action_button" && alert(imp_in, "Are you sure you want to activate your macrobomb bio-chip? This will cause you to explode and gib!", "Macrobomb Bio-chip Confirmation", "Yes", "No") != "Yes")
		return FALSE
	to_chat(imp_in, "<span class='notice'>You activate your macrobomb bio-chip.</span>")
	timed_explosion()

/obj/item/implant/explosive/macro/implant(mob/source)
	var/obj/item/implant/explosive/imp_e = locate(type) in source
	if(imp_e && imp_e != src)
		return FALSE
	imp_e = locate(/obj/item/implant/explosive) in source
	if(imp_e && imp_e != src)
		heavy += imp_e.heavy
		medium += imp_e.medium
		weak += imp_e.weak
		delay += imp_e.delay
		qdel(imp_e)

	return ..()


/obj/item/implanter/explosive
	name = "bio-chip implanter (explosive)"
	implant_type = /obj/item/implant/explosive

/obj/item/implantcase/explosive
	name = "bio-chip case - 'Micro Explosive'"
	desc = "A glass case containing a micro explosive bio-chip."
	implant_type = /obj/item/implant/explosive

/obj/item/implanter/explosive_macro
	name = "bio-chip implanter (macro-explosive)"
	implant_type = /obj/item/implant/explosive/macro

/obj/item/implantcase/explosive_macro
	name = "bio-chip case - 'Macro Explosive'"
	desc = "A glass case containing a macro explosive bio-chip."
	implant_type = /obj/item/implant/explosive/macro
