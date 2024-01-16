/obj/structure/chair/wheelchair
	name = "wheelchair"
	icon_state = "wheelchair"
	item_chair = null
	anchored = FALSE
	movable = TRUE
	buildstackamount = 15

	var/move_delay = null

/obj/structure/chair/wheelchair/handle_rotation()
	overlays = null
	var/image/O = image(icon = icon, icon_state = "[icon_state]_overlay", layer = FLY_LAYER, dir = src.dir)
	overlays += O
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(dir)

/obj/structure/chair/wheelchair/relaymove(mob/user, direction)
	if(propelled)
		return 0

	if(!Process_Spacemove(direction) || !has_gravity(src.loc) || !isturf(loc))
		return 0

	if(world.time < move_delay)
		return

	var/calculated_move_delay
	calculated_move_delay += 2 //wheelchairs are not infact sport bikes

	if(has_buckled_mobs())
		var/mob/living/buckled_mob = buckled_mobs[1]
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

	if(!has_buckled_mobs())
		return
	var/mob/living/buckled_mob = buckled_mobs[1]
	if(istype(A, /obj/machinery/door))
		A.Bumped(buckled_mob)

	if(propelled)
		var/mob/living/occupant = buckled_mob
		unbuckle_mob(occupant)

		occupant.throw_at(A, 3, propelled)

		occupant.Weaken(12 SECONDS)
		occupant.Stuttering(12 SECONDS)
		playsound(src.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
		if(isliving(A))
			var/mob/living/victim = A
			victim.Weaken(12 SECONDS)
			victim.Stuttering(12 SECONDS)
			victim.take_organ_damage(10)

		occupant.visible_message("<span class='danger'>[occupant] crashed into \the [A]!</span>")

/obj/structure/chair/wheelchair/plasteel
	name = "hardened wheelchair"
	desc = "Made from a mixture of metal-plasma sheets, this wheelchair is 3 times stronger than the classic model, and is very resistant to acid and corrosion. Thanks to this it can be used in hazardous environments without much worry."
	icon_state = "h_wheelchair"
	max_integrity = 750
	resistance_flags = ACID_PROOF
	buildstacktype = /obj/item/stack/sheet/plasteel

/obj/structure/chair/wheelchair/plastitanium
	name = "reinforced wheelchair"
	desc = "Made from a mixture of titanium-plasma sheets, this wheelchair is 6 times stronger than the classic model, and is very resistant to acid, corrosion and fire! Thanks to this it can be used in hazardous environments without much worry... <i>but remember not to try to bathe in lava.</i>"
	icon_state = "r_wheelchair"
	max_integrity = 1500
	resistance_flags = FIRE_PROOF | ACID_PROOF
	buildstacktype = /obj/item/stack/sheet/mineral/plastitanium
