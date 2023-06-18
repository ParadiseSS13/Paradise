/obj/effect/proc_holder/spell/bloodcrawl
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	base_cooldown = 0
	clothes_req = FALSE
	cooldown_min = 0
	should_recharge_after_cast = FALSE
	overlay = null
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	panel = "Demon"
	var/allowed_type = /obj/effect/decal/cleanable
	var/phased = FALSE

/obj/effect/proc_holder/spell/bloodcrawl/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.allowed_type = allowed_type
	T.random_target = TRUE
	T.range = 1
	T.use_turf_of_user = TRUE
	return T

/obj/effect/proc_holder/spell/bloodcrawl/valid_target(obj/effect/decal/cleanable/target, user)
	return target.can_bloodcrawl_in()

/obj/effect/proc_holder/spell/bloodcrawl/can_cast(mob/living/user, charge_check, show_message)
	. = ..()
	if(!.)
		return
	if(!isliving(user))
		return FALSE

/obj/effect/proc_holder/spell/bloodcrawl/cast(list/targets, mob/living/user)
	var/atom/target = targets[1]
	if(phased)
		if(phasein(target, user))
			phased = FALSE
	else
		if(phaseout(target, user))
			phased = TRUE
	cooldown_handler.start_recharge()

//Travel through pools of blood. Slaughter Demon powers for everyone!
#define BLOODCRAWL     1
#define BLOODCRAWL_EAT 2


/obj/item/bloodcrawl
	name = "blood crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/effects/blood.dmi'
	flags = NODROP|ABSTRACT

/obj/effect/dummy/slaughter //Can't use the wizard one, blocked by jaunt/slow
	name = "odd blood"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/dummy/slaughter/relaymove(mob/user, direction)
	forceMove(get_step(src, direction))

/obj/effect/dummy/slaughter/ex_act()
	return

/obj/effect/dummy/slaughter/bullet_act()
	return

/obj/effect/dummy/slaughter/singularity_act()
	return


/obj/effect/proc_holder/spell/bloodcrawl/proc/block_hands(mob/living/carbon/C)
	if(C.l_hand || C.r_hand)
		to_chat(C, "<span class='warning'>You may not hold items while blood crawling!</span>")
		return FALSE
	var/obj/item/bloodcrawl/B1 = new(C)
	var/obj/item/bloodcrawl/B2 = new(C)
	B1.icon_state = "bloodhand_left"
	B2.icon_state = "bloodhand_right"
	C.put_in_hands(B1)
	C.put_in_hands(B2)
	C.regenerate_icons()
	return TRUE

/obj/effect/temp_visual/dir_setting/bloodcrawl
	icon = 'icons/mob/mob.dmi'
	icon_state = "blank" // Flicks are used instead
	duration = 0.6 SECONDS
	layer = MOB_LAYER + 0.1

/obj/effect/temp_visual/dir_setting/bloodcrawl/Initialize(mapload, set_dir, animation_state)
	. = ..()
	flick(animation_state, src) // Setting the icon_state to the animation has timing issues and can cause frame skips

/obj/effect/proc_holder/spell/bloodcrawl/proc/sink_animation(atom/A, mob/living/L)
	var/turf/mob_loc = get_turf(L)
	visible_message("<span class='danger'>[L] sinks into [A].</span>")
	playsound(mob_loc, 'sound/misc/enter_blood.ogg', 100, 1, -1)
	new /obj/effect/temp_visual/dir_setting/bloodcrawl(mob_loc, L.dir, "jaunt")

/obj/effect/proc_holder/spell/bloodcrawl/proc/handle_consumption(mob/living/L, mob/living/victim, atom/A, obj/effect/dummy/slaughter/holder)
	if(!HAS_TRAIT(L, TRAIT_BLOODCRAWL_EAT))
		return

	if(!istype(victim))
		return
	if(victim.stat == CONSCIOUS)
		A.visible_message("<span class='warning'>[victim] kicks free of [A] just before entering it!</span>")
		L.stop_pulling()
		return

	victim.forceMove(holder)
	victim.emote("scream")
	A.visible_message("<span class='warning'><b>[L] drags [victim] into [A]!</b></span>")
	L.stop_pulling()
	to_chat(L, "<b>You begin to feast on [victim]. You can not move while you are doing this.</b>")
	A.visible_message("<span class='warning'><B>Loud eating sounds come from the blood...</b></span>")
	var/sound
	if(isslaughterdemon(L))
		var/mob/living/simple_animal/demon/slaughter/SD = L
		sound = SD.feast_sound
	else
		sound = 'sound/misc/demon_consume.ogg'

	for(var/i in 1 to 3)
		playsound(get_turf(L), sound, 100, 1)
		sleep(3 SECONDS)

	if(!victim)
		to_chat(L, "<span class='danger'>You happily devour... nothing? Your meal vanished at some point!</span>")
		return

	if(ishuman(victim) || isrobot(victim))
		to_chat(L, "<span class='warning'>You devour [victim]. Your health is fully restored.</span>")
		L.adjustBruteLoss(-1000)
		L.adjustFireLoss(-1000)
		L.adjustOxyLoss(-1000)
		L.adjustToxLoss(-1000)
	else
		to_chat(L, "<span class='warning'>You devour [victim], but this measly meal barely sates your appetite!</span>")
		L.adjustBruteLoss(-25)
		L.adjustFireLoss(-25)

	if(isslaughterdemon(L))
		var/mob/living/simple_animal/demon/slaughter/demon = L
		demon.devoured++
		to_chat(victim, "<span class='userdanger'>You feel teeth sink into your flesh, and the--</span>")
		var/obj/item/organ/internal/regenerative_core/legion/core = victim.get_int_organ(/obj/item/organ/internal/regenerative_core/legion)
		if(core)
			core.remove(victim)
			qdel(core)
		victim.adjustBruteLoss(1000)
		victim.forceMove(demon)
		demon.consumed_mobs.Add(victim)
		ADD_TRAIT(victim, TRAIT_UNREVIVABLE, "demon")
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = H.w_uniform
				U.sensor_mode = SENSOR_OFF
	else
		victim.ghostize()
		qdel(victim)

/obj/effect/proc_holder/spell/bloodcrawl/proc/post_phase_in(mob/living/L, obj/effect/dummy/slaughter/holder)
	L.notransform = FALSE

/obj/effect/proc_holder/spell/bloodcrawl/proc/phaseout(obj/effect/decal/cleanable/B, mob/living/L)

	if(iscarbon(L) && !block_hands(L))
		return FALSE

	L.notransform = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_phase), B, L)
	return TRUE

/obj/effect/proc_holder/spell/bloodcrawl/proc/async_phase(obj/effect/decal/cleanable/B, mob/living/L)
	var/turf/mobloc = get_turf(L)
	sink_animation(B, L)
	var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(mobloc)
	L.forceMove(holder)
	L.ExtinguishMob()
	handle_consumption(L, L.pulling, B, holder)
	post_phase_in(L, holder)

/obj/effect/proc_holder/spell/bloodcrawl/proc/rise_animation(turf/tele_loc, mob/living/L, atom/A)
	new /obj/effect/temp_visual/dir_setting/bloodcrawl(tele_loc, L.dir, "jauntup")
	if(prob(25) && isdemon(L))
		var/list/voice = list('sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/i_see_you1.ogg')
		playsound(tele_loc, pick(voice),50, 1, -1)
	A.visible_message("<span class='warning'><b>[L] rises out of [A]!</b>")
	playsound(get_turf(tele_loc), 'sound/misc/exit_blood.ogg', 100, 1, -1)

/obj/effect/proc_holder/spell/bloodcrawl/proc/unblock_hands(mob/living/carbon/C)
	if(!istype(C))
		return
	for(var/obj/item/bloodcrawl/BC in C)
		qdel(BC)

/obj/effect/proc_holder/spell/bloodcrawl/proc/rise_message(atom/A)
	A.visible_message("<span class='warning'>[A] starts to bubble...</span>")

/obj/effect/proc_holder/spell/bloodcrawl/proc/post_phase_out(atom/A, mob/living/L)
	if(isslaughterdemon(L))
		var/mob/living/simple_animal/demon/slaughter/S = L
		S.speed = 0
		S.boost = world.time + 6 SECONDS
	L.color = A.color
	addtimer(VARSET_CALLBACK(L, color, null), 6 SECONDS)


/obj/effect/proc_holder/spell/bloodcrawl/proc/phasein(atom/A, mob/living/L)

	if(L.notransform)
		to_chat(L, "<span class='warning'>Finish eating first!</span>")
		return FALSE
	rise_message(A)
	if(!do_after(L, 2 SECONDS, target = A))
		return FALSE
	if(!A)
		return FALSE
	var/turf/tele_loc = isturf(A) ? A : A.loc
	var/holder = L.loc
	L.forceMove(tele_loc)
	L.client.eye = L

	rise_animation(tele_loc, L, A)

	unblock_hands(L)

	QDEL_NULL(holder)

	post_phase_out(A, L)
	return TRUE

/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl
	name = "Shadow Crawl"
	desc = "Use darkness to phase out of existence."
	allowed_type = /turf
	action_background_icon_state = "shadow_demon_bg"
	action_icon_state = "shadow_crawl"

/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/valid_target(turf/target, user)
	return target.get_lumcount() < 0.2

/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/rise_message(atom/A)
	return

/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/rise_animation(turf/tele_loc, mob/living/L, atom/A)
	new /obj/effect/temp_visual/dir_setting/bloodcrawl(get_turf(L), L.dir, "shadowwalk_appear")

/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/handle_consumption(mob/living/L, mob/living/victim, atom/A, obj/effect/dummy/slaughter/holder)
	return

/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/sink_animation(atom/A, mob/living/L)
	A.visible_message("<span class='danger'>[L] sinks into the shadows...</span>")
	new /obj/effect/temp_visual/dir_setting/bloodcrawl(get_turf(L), L.dir, "shadowwalk_disappear")

/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/post_phase_in(mob/living/L, obj/effect/dummy/slaughter/holder)
	..()
	if(!istype(L, /mob/living/simple_animal/demon/shadow))
		return
	var/mob/living/simple_animal/demon/shadow/S = L
	S.RegisterSignal(holder, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/living/simple_animal/demon/shadow, check_darkness))
