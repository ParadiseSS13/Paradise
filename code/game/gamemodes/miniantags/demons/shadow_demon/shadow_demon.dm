/mob/living/simple_animal/demon/shadow
	name = "shadow demon"
	desc = "A creature that's barely tangible, you can feel its gaze piercing you"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shadow_demon"
	icon_living = "shadow_demon"
	move_resist = MOVE_FORCE_STRONG
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE // so they can tell where the darkness is
	loot = list(/obj/item/organ/internal/heart/demon/shadow)
	death_sound = 'sound/shadowdemon/shadowdeath.ogg'
	var/thrown_alert = FALSE
	var/wrapping = FALSE

/mob/living/simple_animal/demon/shadow/Login()
	..()
	var/list/L = list(
		"<span class='deadsay'><font size=3><b>You are a shadow demon!</b></font></span>",
		"<b>You are a lethal ambush predator who thrives in the darkness, calling upon the shadows to heal your injured form and increase your speed.</b>",
		"<b>Light is however your worst enemy and being exposed for too long will be fatal.</b>",
		"<b>Striking your victims with your shadow grapple extinguishes any light sources around them. Striking items silences any light within them.</b>",
		"<b>You can wrap your dead victims into a shadow cocoon which provides a shroud of darkness which tears away any light near it.</b>",
		"<b><i>You do not remember anything of your past lives, nor will you remember anything about this one after your death.</i></b>",
		"<br><span class='motd'>For more information, check the wiki page: [wiki_link("Shadow_Demon")]</span>"
	)
	to_chat(src, chat_box_red(L.Join("<br>")))

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

/mob/living/simple_animal/demon/shadow/UnarmedAttack(atom/A)
	// Pick a random attack sound for each attack
	attack_sound = pick('sound/shadowdemon/shadowattack2.ogg', 'sound/shadowdemon/shadowattack3.ogg', 'sound/shadowdemon/shadowattack4.ogg')
	if(!ishuman(A))
		if(isitem(A))
			A.extinguish_light()
		return ..()
	var/mob/living/carbon/human/target = A
	if(target.stat != DEAD)
		return ..()

	if(isLivingSSD(target) && client.send_ssd_warning(target)) //Similar to revenants, only wrap SSD targets if you've accepted the SSD warning
		return

	if(wrapping)
		to_chat(src, "<span class='notice'>We are already wrapping something.</span>")
		return

	visible_message("<span class='danger'>[src] begins wrapping [target] in shadowy threads.</span>")
	wrapping = TRUE
	if(!do_after(src, 4 SECONDS, FALSE, target = target))
		wrapping = FALSE
		return

	target.visible_message("<span class='warning'><b>[src] envelops [target] into an ethereal cocoon, and darkness begins to creep from it.</b></span>")
	var/obj/structure/shadowcocoon/C = new(get_turf(target))
	target.extinguish_light() // may as well be safe
	target.forceMove(C)
	wrapping = FALSE

/obj/structure/shadowcocoon
	name = "shadowy cocoon"
	desc = "Something wrapped in what seems to be manifested darkness. Its surface distorts unnaturally, and it emanates deep shadows."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shadowcocoon"
	light_power = -4
	light_range = 6
	max_integrity = 100
	light_color = "#ddd6cf"
	anchored = TRUE
	/// Amount of SSobj ticks (Roughly 2 seconds) since the last hallucination proc'd
	var/time_since_last_hallucination = 0
	/// Will we play hallucination sounds or not
	var/silent = TRUE

/obj/structure/shadowcocoon/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/shadowdemon/shadownode.ogg', 5, TRUE, -1)
	START_PROCESSING(SSobj, src)


/obj/structure/shadowcocoon/examine(mob/user)
	. = ..()
	if(istype(user, /mob/living/simple_animal/demon/shadow))
		. += silent ? "<span class='notice'>The tendrils are idle and will not produce noise.</span>" : "<span class='notice'>The tendrils are agitated <b>and will occasionally produce noise to lure in more prey.</b></span>"
		. += "<span class='notice'>Alt+Click to toggle whether [src] should produce noise to lure in victims.</span>"

/obj/structure/shadowcocoon/process()
	time_since_last_hallucination++
	for(var/atom/to_darken in range(4, src))
		if(prob(60) || !length(to_darken.light_sources))
			continue
		if(iswelder(to_darken) && length(to_darken.light_sources))
			var/obj/item/weldingtool/welder_to_darken = to_darken
			welder_to_darken.remove_fuel(welder_to_darken.reagents.get_reagent_amount("fuel"))
			welder_to_darken.visible_message("<span class='notice'>The shadows swarm around and overwhelm the flame of [welder_to_darken].</span>")
			return
		if(istype(to_darken, /obj/item/flashlight/flare))
			var/obj/item/flashlight/flare/flare_to_darken = to_darken
			if(!flare_to_darken.on)
				continue
			flare_to_darken.turn_off()
			flare_to_darken.fuel = 0
			flare_to_darken.visible_message("<span class='notice'>[flare_to_darken] suddenly dims.</span>")
		to_darken.extinguish_light()
	if(!silent && time_since_last_hallucination >= rand(8, 12))
		playsound(src, pick('sound/shadowdemon/shadowhalluc1.ogg', 'sound/shadowdemon/shadowhalluc2.ogg', 'sound/machines/airlock_open.ogg',  'sound/machines/airlock_close.ogg', 'sound/machines/boltsup.ogg', 'sound/shadowdemon/shadowhalluc3.ogg', get_sfx("bodyfall"), 'sound/weapons/egloves.ogg'), 50)
		time_since_last_hallucination = 0


// Allows you to turn on cocoons making hallucination sounds or not
/obj/structure/shadowcocoon/AltClick(mob/user)
	if(!isdemon(user))
		return ..()
	if(silent)
		to_chat(user, "<span class='notice'>You twist and change your trapped victim in [src] to lure in more prey.</span>")
		silent = FALSE
		return
	to_chat(user, "<span class='notice'>The tendrils from [src] snap back to their orignal form.</span>")
	silent = TRUE

/obj/structure/shadowcocoon/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type != BURN) //I unashamedly stole this from spider cocoon code
		return
	playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/shadowcocoon/obj_destruction()
	visible_message("<span class='danger'>[src] splits open, and the shadows dancing around it fade.</span>")
	return ..()

/obj/structure/shadowcocoon/Destroy()
	for(var/atom/movable/A in contents)
		A.forceMove(loc)
	return..()

/mob/living/simple_animal/demon/shadow/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isliving(AM)) // when a living creature is thrown at it, dont knock it back
		return
	..()

/mob/living/simple_animal/demon/shadow/Initialize(mapload)
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/fireball/shadow_grapple)
	var/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/S = new
	AddSpell(S)
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
		speed = initial(speed)
	else
		if(thrown_alert)
			thrown_alert = FALSE
			clear_alert("light")
		alpha = 125
		speed = 0.5
	return lum_count


/obj/effect/proc_holder/spell/fireball/shadow_grapple
	name = "Shadow Grapple"
	desc = "Fire one of your hands, if it hits a person it pulls them in. If you hit a structure you get pulled to the structure. Any light source hit with this will be disabled in a two tile radius."
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
	hitsound = 'sound/shadowdemon/shadowattack1.ogg' // Plays when hitting something living or a light
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
	for(var/atom/extinguish_target in range(2, src))
		extinguish_target.extinguish_light(TRUE)
	if(!isliving(target))
		firer.throw_at(get_step(target, get_dir(target, firer)), 50, 10)
	else
		var/mob/living/L = target
		L.Immobilize(2 SECONDS)
		L.apply_damage(40, BRUTE, BODY_ZONE_CHEST)
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
	. = ..()
	if(M.mind)
		M.mind.RemoveSpell(/obj/effect/proc_holder/spell/fireball/shadow_grapple)
