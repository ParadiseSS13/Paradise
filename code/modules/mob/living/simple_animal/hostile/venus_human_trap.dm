

/obj/structure/alien/resin/flower_bud_enemy //inheriting basic attack/damage stuff from alien structures
	name = "flower bud"
	desc = "A large pulsating plant..."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "flower_bud"
	layer = MOB_LAYER + 0.9
	opacity = FALSE
	canSmoothWith = null
	smoothing_flags = NONE
	var/growth_time = 120 SECONDS
	is_alien = FALSE

/obj/structure/alien/resin/flower_bud_enemy/Initialize(mapload)
	. = ..()
	var/list/anchors = list()
	anchors += locate(x - 2, y + 2, z)
	anchors += locate(x + 2, y + 2, z)
	anchors += locate(x - 2, y - 2, z)
	anchors += locate(x + 2, y - 2, z)

	for(var/turf/T in anchors)
		var/datum/beam/B = Beam(T, "vine", time=INFINITY, maxdistance=5, beam_type=/obj/effect/ebeam/vine)
		B.sleep_time = 10 //these shouldn't move, so let's slow down updates to 1 second (any slower and the deletion of the vines would be too slow)
	addtimer(CALLBACK(src, PROC_REF(bear_fruit)), growth_time)

/obj/structure/alien/resin/flower_bud_enemy/proc/bear_fruit()
	visible_message("<span class='danger'>the plant has borne fruit!</span>")
	new /mob/living/simple_animal/hostile/venus_human_trap(get_turf(src))
	qdel(src)


/obj/effect/ebeam/vine
	name = "thick vine"
	mouse_opacity = MOUSE_OPACITY_ICON
	desc = "A thick vine, painful to the touch."


/obj/effect/ebeam/vine/Crossed(atom/movable/AM, oldloc)
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(!("vines" in L.faction))
		L.adjustBruteLoss(5)
		to_chat(L, "<span class='alert'>You cut yourself on the thorny vines.</span>")

/mob/living/simple_animal/hostile/venus_human_trap
	name = "venus human trap"
	desc = "Now you know how the fly feels."
	icon_state = "venus_human_trap"
	icon_living = "venus_human_trap"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	layer = MOB_LAYER + 0.9
	health = 50
	maxHealth = 50
	ranged = TRUE
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 25
	melee_damage_upper = 25
	a_intent = INTENT_HARM
	attack_sound = 'sound/weapons/bladeslice.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	faction = list("hostile", "vines", "plants", "jungle")
	var/list/grasping = list()
	var/max_grasps = 4
	var/grasp_chance = 20
	var/grasp_pull_chance = 85
	var/grasp_range = 4
	del_on_death = TRUE

/mob/living/simple_animal/hostile/venus_human_trap/handle_automated_action()
	if(..())
		for(var/mob/living/L in grasping)
			if(L.stat == DEAD)
				var/datum/beam/B = grasping[L]
				if(B)
					B.End()
				grasping -= L

			//Can attack+pull multiple times per cycle
			if(L.Adjacent(src))
				L.attack_animal(src)
			else
				if(prob(grasp_pull_chance))
					dir = get_dir(src,L) //staaaare
					step(L,get_dir(L,src)) //reel them in
					L.Weaken(6 SECONDS) //you can't get away now~

		if(grasping.len < max_grasps)
			grasping:
				for(var/mob/living/L in view(grasp_range, src))
					if(L == src || faction_check_mob(L) || (L in grasping) || L == target)
						continue
					for(var/t in get_line(src,L))
						for(var/a in t)
							var/atom/A = a
							if(A.density && A != L)
								continue grasping
					if(prob(grasp_chance))
						to_chat(L, "<span class='userdanger'>\The [src] has you entangled!</span>")
						grasping[L] = Beam(L, "vine", time=INFINITY, maxdistance=5, beam_type=/obj/effect/ebeam/vine)

						break //only take 1 new victim per cycle


/mob/living/simple_animal/hostile/venus_human_trap/OpenFire(atom/the_target)
	for(var/turf/T in get_line(src, target))
		if(T.density)
			return
		for(var/obj/O in T)
			if(O.density)
				return
	var/dist = get_dist(src,the_target)
	changeNext_move(CLICK_CD_MELEE)
	Beam(the_target, "vine", time=dist*2, maxdistance=dist+2, beam_type=/obj/effect/ebeam/vine)
	the_target.attack_animal(src)


/mob/living/simple_animal/hostile/venus_human_trap/CanAttack(atom/the_target)
	. = ..()
	if(.)
		if(the_target in grasping)
			return 0
