/mob/living/simple_animal/hostile/clockwork
	icon = 'icons/mob/clockwork_mobs.dmi'

/mob/living/simple_animal/hostile/clockwork/marauder
	name = "clockwork marauder"
	desc = "The stalwart apparition of a soldier, blazing with crimson flames. It's armed with a gladius and shield."
	icon_state = "marauder"
	health = 200
	maxHealth = 200
	force_threshold = 8
	melee_damage_lower = 18
	melee_damage_upper = 18
	obj_damage = 40
	speed = 0
	friendly = "pokes"
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	tts_seed = "Earth"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	pressure_resistance = 100
	a_intent = INTENT_HARM
	stop_automated_movement = TRUE
	see_in_dark = 8
	flying = TRUE
	pass_flags = PASSTABLE
	AIStatus = AI_OFF // Usually someone WILL play for him but i don't know about this on chief.
	universal_speak = TRUE
	loot = list(/obj/item/clockwork/fallen_armor)
	del_on_death = TRUE
	deathmessage = "shatters as the flames goes out."
	light_range = 2
	light_power = 1.1
	var/deflect_chance = 30

/mob/living/simple_animal/hostile/clockwork/marauder/hostile
	AIStatus = AI_ON

/mob/living/simple_animal/hostile/clockwork/marauder/Initialize(mapload)
	. = ..()
	real_name = text("clockwork marauder ([rand(1, 1000)])")
	name = real_name

/mob/living/simple_animal/hostile/clockwork/marauder/death(gibbed)
	. = ..()
	SSticker.mode.remove_clocker(mind, FALSE)

/mob/living/simple_animal/hostile/clockwork/marauder/AttackingTarget()
	if(a_intent == INTENT_HELP && isliving(target) && !isclocker(target)) // yes i know, it's not a disarm
		var/mob/living/L = target
		playsound(loc, 'sound/weapons/clash.ogg', 50, TRUE)
		L.adjustStaminaLoss(20)
		src.do_attack_animation(target)
		target.visible_message("<span class='danger'>[src] hits [target] with flat of the sword!</span>", \
						"<span class='userdanger'>[src] hits you with flat of the sword!</span>")
		add_attack_logs(src, target, "Knocks")
	else
		..()

/mob/living/simple_animal/hostile/clockwork/marauder/FindTarget(list/possible_targets, HasTargetsList)
	. = list()
	if(!HasTargetsList)
		possible_targets = ListTargets()
	for(var/pos_targ in possible_targets)
		var/atom/A = pos_targ
		if(Found(A))
			. = list(A)
			break
		if(CanAttack(A) && !isclocker(A))//Can we attack it? And no biting our friends!!
			. += A
			continue
	var/Target = PickTarget(.)
	GiveTarget(Target)
	return Target

/mob/living/simple_animal/hostile/clockwork/marauder/bullet_act(obj/item/projectile/P)
	if(deflect_projectile(P))
		return
	return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/ratvar_act()
	return

/mob/living/simple_animal/hostile/clockwork/marauder/proc/deflect_projectile(obj/item/projectile/P)
	var/final_deflection_chance = deflect_chance
	var/energy_projectile = istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam)
	if(GetOppositeDir(dir) != P.dir) //if projectile hits into his eyes, nor behind or side.
		return FALSE
	if(P.nodamage || P.damage_type == STAMINA)
		final_deflection_chance = 100
	else if(!energy_projectile) //Flat 30% chance against energy projectiles; ballistic projectiles are 30% - (damage of projectile)%, min. 10%
		final_deflection_chance = max(10, deflect_chance - P.damage)
	if(prob(final_deflection_chance))
		visible_message("<span class='danger'>[src] deflects [P] with their shield!</span>", \
		"<span class='danger'>You block [P] with your shield!</span>")
		if(energy_projectile)
			playsound(src, 'sound/weapons/effects/searwall.ogg', 50, TRUE)
		else
			playsound(src, "ricochet", 50, TRUE)
		return TRUE
	return FALSE

/*MOUSE*/
/mob/living/simple_animal/mouse/clockwork
	name = "moaus"
	real_name = "moaus"
	desc = "A fancy clocked mouse. And it still squeeks!"
	icon = 'icons/mob/clockwork_mobs.dmi'
	mouse_color = "clock" // Check mouse/New()
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	pressure_resistance = 100
	universal_speak = 1
	gold_core_spawnable = NO_SPAWN
	tts_seed = "Earth"

/mob/living/simple_animal/mouse/clockwork/handle_automated_action()
	if(!isturf(loc))
		return
	var/turf/simulated/floor/F = get_turf(src)
	if(!istype(F) || F?.intact)
		return
	var/obj/structure/cable/C = locate() in F
	if(C && prob(30))
		if(C.avail())
			visible_message("<span class='warning'>[src] chews through [C]. [src] sparks for a moment!</span>")
			playsound(src, 'sound/effects/sparks2.ogg', 100, 1)
		else
			visible_message("<span class='warning'>[src] chews through [C].</span>")
		investigate_log("was chewed through by a clock mouse in [get_area(F)]([F.x], [F.y], [F.z] - [ADMIN_JMP(F)])","wires")
		C.deconstruct()

/mob/living/simple_animal/mouse/clockwork/splat(var/obj/item/item = null, var/mob/living/user = null)
	return

/mob/living/simple_animal/mouse/clockwork/toast()
	return

/mob/living/simple_animal/mouse/clockwork/get_scooped(mob/living/carbon/grabber)
	to_chat(grabber, "<span class='warning'>You try to pick up [src], but they slip out of your grasp!</span>")
	to_chat(src, "<span class='warning'>[src] tries to pick you up, but you wriggle free of their grasp!</span>")

/mob/living/simple_animal/mouse/clockwork/decompile_act(obj/item/matter_decompiler/C, mob/user)
	return

/mob/living/simple_animal/mouse/clockwork/ratvar_act()
	adjustBruteLoss(-maxHealth)
