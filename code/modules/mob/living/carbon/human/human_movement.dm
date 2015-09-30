/mob/living/carbon/human/movement_delay()
	var/tally = 0

	if(species.slowdown)
		tally = species.slowdown

	if(!has_gravity(src))
		return -1 // It's hard to be slowed down in space by... anything

	if(flying) return -1

	if(embedded_flag)
		handle_embedded_objects() //Moving with objects stuck in you can cause bad times.


	var/health_deficiency = (100 - health + staminaloss)
	if(health_deficiency >= 40)
		tally += (health_deficiency / 25)

	var/hungry = (500 - nutrition)/5 // So overeat would be 100 and default level would be 80
	if (hungry >= 70)
		tally += hungry/50

	if(wear_suit)
		tally += wear_suit.slowdown

	if(!buckled)
		if(shoes)
			tally += shoes.slowdown

	if(shock_stage >= 10) tally += 3

	if(back)
		tally += back.slowdown


	if(FAT in src.mutations)
		tally += 1.5
	if (bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
		tally += (BODYTEMP_COLD_DAMAGE_LIMIT - bodytemperature) / COLD_SLOWDOWN_FACTOR

	tally += 2*stance_damage //damaged/missing feet or legs is slow

	if(RUN in mutations)
		tally = -1
	if(status_flags & IGNORESLOWDOWN) // make sure this is always at the end so we don't have ignore slowdown getting ignored itself
		tally = -1

	if(status_flags & GOTTAGOFAST)
		tally -= 1
	if(status_flags & GOTTAGOREALLYFAST)
		tally -= 2

	return (tally+config.human_delay)

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0)

	if(..())
		return 1

	//Do we have a working jetpack
	if(istype(back, /obj/item/weapon/tank/jetpack) && isturf(loc)) //Second check is so you can't use a jetpack in a mech
		var/obj/item/weapon/tank/jetpack/J = back
		if((movement_dir || J.stabilization_on) && J.allow_thrust(0.01, src))
			return 1
	return 0

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return shoes && shoes.negates_gravity()
