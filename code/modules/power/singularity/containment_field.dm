/obj/machinery/field/containment
	name = "Containment Field"
	desc = "An energy field."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Contain_F"
	anchored = 1
	density = 0
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_2 = RAD_NO_CONTAMINATE_2
	use_power = NO_POWER_USE
	light_range = 4
	layer = OBJ_LAYER + 0.1
	var/obj/machinery/field/generator/FG1 = null
	var/obj/machinery/field/generator/FG2 = null

/obj/machinery/field/containment/Destroy()
	FG1.fields -= src
	FG2.fields -= src
	return ..()

/obj/machinery/field/containment/attack_hand(mob/user)
	if(get_dist(src, user) > 1)
		return 0
	else
		shock_field(user)
		return 1

/obj/machinery/field/containment/attackby(obj/item/W, mob/user, params)
	shock(user)
	return TRUE

/obj/machinery/field/containment/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)
		if(BRUTE)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)

/obj/machinery/field/containment/blob_act(obj/structure/blob/B)
	return FALSE


/obj/machinery/field/containment/ex_act(severity)
	return 0

/obj/machinery/field/containment/attack_animal(mob/living/simple_animal/M)
	if(!FG1 || !FG2)
		qdel(src)
		return
	if(ismegafauna(M))
		M.visible_message("<span class='warning'>[M] glows fiercely as the containment field flickers out!</span>")
		FG1.calc_power(INFINITY) //rip that 'containment' field
		M.adjustHealth(-M.obj_damage)
	else
		..()

/obj/machinery/field/containment/Crossed(mob/mover, oldloc)
	if(isliving(mover))
		shock_field(mover)

	if(istype(mover, /obj/machinery) || istype(mover, /obj/structure) || istype(mover, /obj/mecha))
		bump_field(mover)

/obj/machinery/field/containment/proc/set_master(master1,master2)
	if(!master1 || !master2)
		return 0
	FG1 = master1
	FG2 = master2
	return 1

/obj/machinery/field/containment/shock_field(mob/living/user)
	if(!FG1 || !FG2)
		qdel(src)
		return 0
	..()

/obj/machinery/field/containment/Move()
	qdel(src)

// Abstract Field Class
// Used for overriding certain procs

/obj/machinery/field
	var/hasShocked = 0 //Used to add a delay between shocks. In some cases this used to crash servers by spawning hundreds of sparks every second.

/obj/machinery/field/CanPass(atom/movable/mover, turf/target, height=0)
	if(hasShocked)
		return 0
	if(isliving(mover)) // Don't let mobs through
		shock_field(mover)
		return 0
	if(istype(mover, /obj/machinery) || istype(mover, /obj/structure) || istype(mover, /obj/mecha))
		bump_field(mover)
		return 0
	return ..()

/obj/machinery/field/proc/shock_field(mob/living/user)
	if(isliving(user))
		var/shock_damage = min(rand(30,40),rand(30,40))

		if(isliving(user) && !issilicon(user))
			var/stun = min(shock_damage, 15)
			user.Stun(stun)
			user.Weaken(10)
			user.electrocute_act(shock_damage, src, 1)

		else if(issilicon(user))
			if(prob(20))
				user.Stun(2)
			user.take_overall_damage(0, shock_damage)
			user.visible_message("<span class='danger'>[user.name] was shocked by the [src.name]!</span>", \
			"<span class='userdanger'>Energy pulse detected, system damaged!</span>", \
			"<span class='italics'>You hear an electrical crack.</span>")

		user.updatehealth()
		bump_field(user)

/obj/machinery/field/proc/bump_field(atom/movable/AM as mob|obj)
	if(hasShocked)
		return 0
	hasShocked = 1
	do_sparks(5, 1, AM.loc)
	var/atom/target = get_edge_target_turf(AM, get_dir(src, get_step_away(AM, src)))
	AM.throw_at(target, 200, 4)
	spawn(5)
		hasShocked = 0
