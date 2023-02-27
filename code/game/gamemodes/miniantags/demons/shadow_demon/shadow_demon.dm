/mob/living/simple_animal/demon/shadow
	name = "shadow demon"
	desc = "A creature that's barely tangible, you can feel its gaze piercing you"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shadow_demon"
	icon_living = "shadow_demon"
	move_resist = MOVE_FORCE_STRONG
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE // so they can tell where the darkness is
	loot = list(/obj/item/organ/internal/heart/demon/shadow)
	var/thrown_alert = FALSE
	/// How many times the shadow demon can use the darklight spell, increases by gouging dead players
	var/darklight_charges = 0
	/// Stores a list of gouged players so the demon can't do it twice
	var/list/gouged_mobs = list()
	/// Is the shadow demon currently gouging someone?
	var/gouging = FALSE

/mob/living/simple_animal/demon/shadow/Life(seconds, times_fired)
	. = ..()
	var/lum_count = check_darkness()
	var/damage_mod = istype(loc, /obj/effect/dummy/slaughter) ? 0.5 : 1
	if(lum_count > 0.2)
		adjustBruteLoss(40 * damage_mod) // 10 seconds in light
		SEND_SOUND(src, sound('sound/weapons/sear.ogg'))
		to_chat(src, "<span class='biggerdanger'>The light scalds you!</span>")
	else
		adjustBruteLoss(-20)

/mob/living/simple_animal/demon/shadow/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Current darklight essence: [darklight_charges]")

/mob/living/simple_animal/demon/shadow/ClickOn(atom/A)
	if(ishuman(A))
		var/mob/living/carbon/human/target = A
		if(in_range(src, target) && target.stat == DEAD)
			if(isLivingSSD(target) && client.send_ssd_warning(target)) //Similar to revenants, only gouge SSD targets if you've accepted the SSD warning
				return
			if(gouging)
				to_chat(src, "<span class='notice'>We are already gouging something.</span>")
				return
			if(!target.ckey)
				to_chat(src, "<span class='notice'>This being is mindless, not fit for darklight gouging.</span>")
				return
			var/mob_UID = target.UID()
			if(mob_UID in gouged_mobs)
				to_chat(src, "<span class='notice'>This being bears the marks of our gouging already, and are empty of darklight essence.</span>")
				return
			to_chat(src, "<span class='notice'>We begin to gouge [target] for their darklight essence.</span>")
			gouging = TRUE
			if(do_after(src, 2 SECONDS, 0, target = target))
				playsound(target, 'sound/misc/demon_attack1.ogg', 50, TRUE)
				target.apply_damage(50, BRUTE, BODY_ZONE_CHEST)
				target.visible_message("<span class='warning'><b>[src] gouges the chest of [target] with its claws, leaving a deep wound.</b></span>")
				darklight_charges++
				gouged_mobs.Add(mob_UID)
				gouging = FALSE
				to_chat(src, "<span class='notice'>We have harvested [target]'s darklight essence, we now possess [darklight_charges].</span>")
				return
			else
				gouging = FALSE
				return
	..()

/mob/living/simple_animal/demon/shadow/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isliving(AM)) // when a living creature is thrown at it, dont knock it back
		return
	..()


/mob/living/simple_animal/demon/shadow/Initialize(mapload)
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/fireball/shadow_grapple)
	var/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/S = new
	AddSpell(S)
	AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/build/darklight)
	whisper_action.button_icon_state = "shadow_whisper"
	whisper_action.background_icon_state = "shadow_demon_bg"
	if(istype(loc, /obj/effect/dummy/slaughter))
		S.phased = TRUE
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/living/simple_animal/demon/shadow, check_darkness))
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(check_darkness))
	add_overlay(emissive_appearance(icon, "shadow_demon_eye_glow_overlay"))

/mob/living/simple_animal/demon/shadow/proc/check_darkness()
	var/turf/T = get_turf(src)
	var/lum_count = T.get_lumcount()
	if(lum_count > 0.2)
		if(!thrown_alert)
			thrown_alert = TRUE
			throw_alert("light", /obj/screen/alert/lightexposure)
		alpha = 255
	else
		if(thrown_alert)
			thrown_alert = FALSE
			clear_alert("light")
		alpha = 125
	return lum_count


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

/obj/effect/proc_holder/spell/aoe/conjure/build/darklight
	name = "Summon Darklight"
	desc = "This spell conjures a fragile crystal constructed of pure darkness. Acts as a negative light source."
	action_icon_state = "shadow_darklight"
	action_background_icon_state = "shadow_demon_bg"
	school = "conjuration"
	base_cooldown = 15 SECONDS
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	summon_type = list(/obj/structure/darklight)

/obj/effect/proc_holder/spell/aoe/conjure/build/darklight/can_cast(mob/living/simple_animal/demon/shadow/user, charge_check = TRUE, show_message = FALSE)
	if(user.darklight_charges <= 0) // should never go less than 0 but let's just be safe
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/aoe/conjure/build/darklight/cast(list/targets, mob/living/simple_animal/demon/shadow/user)
	. = ..()
	user.darklight_charges--

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
		L.throw_at(get_step(firer, get_dir(firer, target)), 50, 10)
	target.extinguish_light(TRUE)

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
