/mob/living/simple_animal/demon/shadow
	name = "shadow demon"
	desc = "A creature that's barely tangible, you can feel its gaze piercing you"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shadow_demon"
	icon_living = "shadow_demon"
	move_resist = MOVE_FORCE_STRONG
	loot = list(/obj/item/organ/internal/heart/demon/shadow)

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
	if(isliving(AM)) // when a living creature is thrown at it, dont knock it back
		return
	..()


/mob/living/simple_animal/demon/shadow/Initialize(mapload)
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/fireball/shadow_grapple)
	AddSpell(new /obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl)

/obj/effect/proc_holder/spell/fireball/shadow_grapple
	name = "Shadow Grapple"
	desc = "Fire one of your hands, if it hits a person it pulls them in. If you hit a structure you get pulled to the structure."
	base_cooldown = 10 SECONDS
	fireball_type = /obj/item/projectile/magic/shadow_hand

	selection_activated_message = "<span class='notice'>You raise your hand, full of demonic energy! <b>Left-click to cast at a target!</b></span>"
	selection_deactivated_message = "<span class='notice'>You re-absorb the energy...for now.</span>"

	action_background_icon_state = "shadow_demon_bg"
	action_icon_state = "shadow_grapple"
	panel = "Demon"

	sound = null
	invocation_type = "none"
	invocation = null

/obj/effect/proc_holder/spell/fireball/shadow_grapple/update_icon_state()
	return

/obj/item/projectile/magic/shadow_hand
	name = "shadow hand"
	icon_state = "shadow_hand"
	plane = FLOOR_PLANE
	var/hit = FALSE

/obj/item/projectile/magic/shadow_hand/fire(setAngle)
	if(firer)
		firer.Beam(src, icon_state = "grabber_beam", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1, beam_type = /obj/effect/ebeam/floor)
	return ..()

/obj/item/projectile/magic/shadow_hand/on_hit(atom/target, blocked, hit_zone)
	if(hit)
		return
	hit = TRUE // to prevent double hits from the pull
	. = ..()
	if(!isliving(target))
		firer.throw_at(get_step(target, get_dir(target, firer)), 50, 10)
	else
		var/mob/living/L = target
		L.Immobilize(2 SECONDS)
		L.apply_damage(40, BRUTE, BODY_ZONE_CHEST)
		L.extinguish_light(TRUE)
		L.throw_at(get_step(firer, get_dir(firer, target)), 50, 10)

/obj/effect/ebeam/floor
	plane = FLOOR_PLANE

/obj/item/organ/internal/heart/demon/shadow
	name = "heart of darkness"
	desc = "It still beats furiously, emitting an aura of fear."
	color = COLOR_BLACK

/obj/item/organ/internal/heart/demon/shadow/attack_self(mob/living/user)
	. = ..()
	user.drop_item()
	insert(user)

/obj/item/organ/internal/heart/demon/shadow/insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(M.mind)
		M.mind.AddSpell(new /obj/effect/proc_holder/spell/fireball/shadow_grapple)

/obj/item/organ/internal/heart/demon/shadow/remove(mob/living/carbon/M, special = 0)
	..()
	if(M.mind)
		M.mind.RemoveSpell(/obj/effect/proc_holder/spell/fireball/shadow_grapple)
