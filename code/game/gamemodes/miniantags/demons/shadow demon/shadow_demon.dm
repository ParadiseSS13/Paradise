/mob/living/simple_animal/demon/shadow
	name = "shadow demon"
	desc = "A creature thats barely tangable, you can feel its gaze pierce you."
	icon = 'icons/mob/mob.dmi'
	icon_state = "shadow_demon"
	icon_living = "shadow_demon"
	move_resist = MOVE_FORCE_STRONG

/mob/living/simple_animal/demon/shadow/Life(seconds, times_fired)
	. = ..()
	var/turf/T = get_turf(src)
	var/lum_count = T.get_lumcount()
	if(lum_count > 0.2)
		adjustBruteLoss(40) // 10 seconds in light
		throw_alert("light", /obj/screen/alert/lightexposure)
		alpha = 255
	else
		alpha = 125
		adjustBruteLoss(-20)
		clear_alert("light")



/mob/living/simple_animal/demon/shadow/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(!isliving(AM)) // when a living creature is thrown at it, it slam
		return ..()
	var/mob/living/L = AM
	do_attack_animation(L, ATTACK_EFFECT_SMASH)
	L.apply_damage(40, BRUTE, BODY_ZONE_CHEST)


/mob/living/simple_animal/demon/shadow/Initialize(mapload)
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/fireball/shadow_grappel)
	AddSpell(new /obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl)

/obj/effect/proc_holder/spell/fireball/shadow_grappel
	name = "Shadow Grapple"
	desc = "Fire one of your hands, if it hits a person it pulls them in. If you hit a structure you get pulled to the structure."
	base_cooldown = 10 SECONDS
	fireball_type = /obj/item/projectile/magic/shadow_hand

	selection_activated_message		= "<span class='notice'>You raise your hand, full of demonic energy! <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>You re-absorb the energy...for now.</span>"

	action_background_icon_state = "shadow_demon_bg"
	action_icon_state = "shadow_grapple"

	sound = null
	invocation_type = "none"
	invocation = null

/obj/effect/proc_holder/spell/fireball/shadow_grappel/update_icon_state()
	return

/obj/item/projectile/magic/shadow_hand
	name = "shadow hand"
	icon_state = "shadow_hand"
	plane = FLOOR_PLANE

/obj/item/projectile/magic/shadow_hand/fire(setAngle)
	if(firer)
		firer.Beam(src, icon_state = "grabber_beam", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1, beam_type = /obj/effect/ebeam/floor)
	. = ..()


/obj/item/projectile/magic/shadow_hand/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(!isliving(target))
		var/turf/T = get_turf(target)
		firer.throw_at(T, 50, 10)
	else
		var/mob/living/L = target
		L.Immobilize(2 SECONDS)
		L.extinguish_light(TRUE)
		L.throw_at(firer, 50, 10)

/obj/effect/ebeam/floor
	plane = FLOOR_PLANE
