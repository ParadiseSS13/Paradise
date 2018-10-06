/obj/structure/chair/wheelchair
	name = "wheelchair"
	icon_state = "wheelchair"
	item_chair = null
	anchored = FALSE
	movable = TRUE

	var/move_delay = null

/obj/structure/chair/wheelchair/handle_rotation()
	overlays = null
	var/image/O = image(icon = icon, icon_state = "[icon_state]_overlay", layer = FLY_LAYER, dir = src.dir)
	overlays += O
	if(buckled_mob)
		buckled_mob.dir = dir

/obj/structure/chair/wheelchair/relaymove(mob/user, direction)
	if(propelled)
		return 0

	if(!Process_Spacemove(direction) || !has_gravity(src.loc) || !isturf(loc))
		return 0

	if(world.time < move_delay)
		return

	var/calculated_move_delay
	calculated_move_delay += 2 //wheelchairs are not infact sport bikes

	if(buckled_mob)
		if(buckled_mob.incapacitated())
			return 0

		var/mob/living/thedriver = user
		var/mob_delay = thedriver.movement_delay()
		if(mob_delay > 0)
			calculated_move_delay += mob_delay

		if(ishuman(buckled_mob))
			var/mob/living/carbon/human/driver = user
			if(!driver.has_left_hand() && !driver.has_right_hand())
				return 0 // No hands to drive your chair? Tough luck!

			for(var/organ_name in list("l_hand","r_hand","l_arm","r_arm"))
				var/obj/item/organ/external/E = driver.get_organ(organ_name)
				if(!E)
					calculated_move_delay += 4
				else if(E.status & ORGAN_SPLINTED)
					calculated_move_delay += 0.5
				else if(E.status & ORGAN_BROKEN)
					calculated_move_delay += 1.5

		if(calculated_move_delay < 4)
			calculated_move_delay = 4 //no racecarts

		move_delay = world.time
		move_delay += calculated_move_delay

		if(!buckled_mob.Move(get_step(buckled_mob, direction), direction))
			loc = buckled_mob.loc //we gotta go back
			last_move = buckled_mob.last_move
			inertia_dir = last_move
			buckled_mob.inertia_dir = last_move
			. = 0

		else
			. = 1

/obj/structure/chair/wheelchair/Bump(atom/A)
	..()

	if(!buckled_mob)
		return

	if(istype(A, /obj/machinery/door))
		A.Bumped(buckled_mob)

	if(propelled)
		var/mob/living/occupant = buckled_mob
		unbuckle_mob()

		occupant.throw_at(A, 3, propelled)

		occupant.apply_effect(6, STUN, 0)
		occupant.apply_effect(6, WEAKEN, 0)
		occupant.apply_effect(6, STUTTER, 0)
		playsound(src.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
		if(istype(A, /mob/living))
			var/mob/living/victim = A
			victim.apply_effect(6, STUN, 0)
			victim.apply_effect(6, WEAKEN, 0)
			victim.apply_effect(6, STUTTER, 0)
			victim.take_organ_damage(10)

		occupant.visible_message("<span class='danger'>[occupant] crashed into \the [A]!</span>")

/obj/structure/chair/wheelchair/bike
	name = "bicycle"
	desc = "Two wheels of FURY!"
	//placeholder until i get a bike sprite
	icon = 'icons/vehicles/motorcycle.dmi'
	icon_state = "motorcycle_4dir"

/obj/structure/chair/wheelchair/bike/relaymove(mob/user, direction)
	if(propelled)
		return 0

	if(!Process_Spacemove(direction) || !has_gravity(src.loc) || !isturf(loc))	//bikes in space.
		return 0

	if(world.time < move_delay)
		return

	var/calculated_move_delay
	calculated_move_delay = 0 //bikes are infact sport bikes

	if(buckled_mob)
		if(buckled_mob.incapacitated())
			unbuckle_mob()	//if the rider is incapacitated, unbuckle them (they can't balance so they fall off)
			return 0

		var/mob/living/thedriver = user
		var/mob_delay = thedriver.movement_delay()
		if(mob_delay > 0)
			calculated_move_delay += mob_delay

		if(ishuman(buckled_mob))
			var/mob/living/carbon/human/driver = user
			var/obj/item/organ/external/l_hand = driver.get_organ("l_hand")
			var/obj/item/organ/external/r_hand = driver.get_organ("r_hand")
			if(!l_hand && !r_hand)
				calculated_move_delay += 0.5	//I can ride my bike with no handlebars... (but it's slower)

			for(var/organ_name in list("l_leg","r_leg","l_foot","r_foot"))
				var/obj/item/organ/external/E = driver.get_organ(organ_name)
				if(!E)
					return 0	//Bikes need both feet/legs to work. missing even one makes it so you can't ride the bike
				else if(E.status & ORGAN_SPLINTED)
					calculated_move_delay += 0.5
				else if(E.status & ORGAN_BROKEN)
					calculated_move_delay += 1.5

		move_delay = world.time
		move_delay += calculated_move_delay

		if(!buckled_mob.Move(get_step(buckled_mob, direction), direction))
			loc = buckled_mob.loc //we gotta go back
			last_move = buckled_mob.last_move
			inertia_dir = last_move
			buckled_mob.inertia_dir = last_move
			. = 0

		else
			. = 1
