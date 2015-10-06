/obj/structure/stool/bed/chair/wheelchair
	name = "wheelchair"
	desc = "You sit in this. Either by will or force."
	icon_state = "wheelchair"
	anchored = 0
	movable = 1

	var/move_delay = null

/obj/structure/stool/bed/chair/wheelchair/handle_rotation()
	overlays = null
	var/image/O = image(icon = 'icons/obj/objects.dmi', icon_state = "w_overlay", layer = FLY_LAYER, dir = src.dir)
	overlays += O
	if(buckled_mob)
		buckled_mob.dir = dir

/obj/structure/stool/bed/chair/wheelchair/relaymove(mob/user, direction)
	if(propelled)
		return 0

	if(!Process_Spacemove(direction) || !has_gravity(src.loc) || !isturf(loc))
		return 0

	if(world.time < move_delay)
		return

	move_delay = world.time
	move_delay += 2 //wheelchairs are not infact sport bikes

	if(buckled_mob)
		if(buckled_mob.incapacitated())
			return 0
			
		var/mob/living/thedriver = user
		var/mob_delay = thedriver.movement_delay()
		if(mob_delay > 0)
			move_delay += mob_delay

		if(ishuman(buckled_mob))
			var/mob/living/carbon/human/driver = user
			var/obj/item/organ/external/l_hand = driver.get_organ("l_hand")
			var/obj/item/organ/external/r_hand = driver.get_organ("r_hand")
			if((!l_hand || (l_hand.status & ORGAN_DESTROYED)) && (!r_hand || (r_hand.status & ORGAN_DESTROYED)))
				return 0 // No hands to drive your chair? Tough luck!

			for(var/organ_name in list("l_hand","r_hand","l_arm","r_arm"))
				var/obj/item/organ/external/E = driver.get_organ(organ_name)
				if(!E || (E.status & ORGAN_DESTROYED))
					move_delay += 4
				else if(E.status & ORGAN_SPLINTED)
					move_delay += 0.5
				else if(E.status & ORGAN_BROKEN)
					move_delay += 1.5

		if(!buckled_mob.Move(get_step(buckled_mob, direction), direction))
			loc = buckled_mob.loc //we gotta go back
			last_move = buckled_mob.last_move
			inertia_dir = last_move
			buckled_mob.inertia_dir = last_move
			. = 0

		else
			. = 1

/obj/structure/stool/bed/chair/wheelchair/Bump(atom/A)
	..()
	if(!buckled_mob)	return

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