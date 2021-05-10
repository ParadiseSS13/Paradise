/obj/effect/decal/cleanable/blood/gibs/robot
	name = "robot debris"
	desc = "It's a useless heap of junk... <i>or is it?</i>"
	icon = 'icons/mob/robots.dmi'
	icon_state = "gib1"
	basecolor = "#030303"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/blood/gibs/robot/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/robot/update_icon()
	color = "#FFFFFF"

/obj/effect/decal/cleanable/blood/gibs/robot/dry()	//pieces of robots do not dry up like
	return

/obj/effect/decal/cleanable/blood/gibs/robot/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/robot/streak(list/directions)
	spawn(0)
		var/direction = pick(directions)
		for(var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(3)
			if(i > 0)
				if(prob(40))
					var/obj/effect/decal/cleanable/blood/oil/streak = new(src.loc)
					streak.update_icon()
				else if(prob(10))
					do_sparks(3, 1, src)
			if(step_to(src, get_step(src, direction), 0))
				break

/obj/effect/decal/cleanable/blood/gibs/robot/limb
	random_icon_states = list("gibarm", "gibleg")

/obj/effect/decal/cleanable/blood/gibs/robot/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7", "gibup1", "gibup1") //2:7 is close enough to 1:4

/obj/effect/decal/cleanable/blood/gibs/robot/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7", "gibdown1", "gibdown1") //2:7 is close enough to 1:4

/obj/effect/decal/cleanable/blood/oil
	name = "motor oil"
	desc = "It's black and greasy. Looks like Beepsky made another mess."
	basecolor = "#030303"
	bloodiness = MAX_SHOE_BLOODINESS

/obj/effect/decal/cleanable/blood/oil/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/oil/dry()
	return

/obj/effect/decal/cleanable/blood/oil/streak
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2
