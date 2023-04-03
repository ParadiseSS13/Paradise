//entirely neutral or internal status effects go here

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target

/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target

/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)

/datum/status_effect/syphon_mark/tick()
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)

/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/datum/status_effect/adaptive_learning
	id = "adaptive_learning"
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	var/bonus_damage = 0

/datum/status_effect/high_five
	id = "high_five"
	duration = 10 SECONDS
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	/// Message displayed when wizards perform this together
	var/critical_success = "high-five EPICALLY!"
	/// Message displayed when normal people perform this together
	var/success = "high-five!"
	/// Message displayed when this status effect is applied.
	var/request = "requests a high-five."
	/// Item to be shown in the pop-up balloon.
	var/obj/item/item_path = /obj/item/latexballon
	/// Sound effect played when this emote is completed.
	var/sound_effect = 'sound/weapons/slap.ogg'

/// So we don't leave folks with god-mode
/datum/status_effect/high_five/proc/wiz_cleanup(mob/user, mob/highfived)
	user.status_flags &= ~GODMODE
	highfived.status_flags &= ~GODMODE

/datum/status_effect/high_five/on_apply()
	if(!iscarbon(owner))
		return FALSE
	. = ..()

	var/mob/living/carbon/user = owner
	var/is_wiz = iswizard(user)
	for(var/mob/living/carbon/C in orange(1, user))
		if(!C.has_status_effect(type) || C == user)
			continue
		if(is_wiz && iswizard(C))
			user.visible_message("<span class='biggerdanger'><b>[user.name]</b> and <b>[C.name]</b> [critical_success]</span>")
			user.status_flags |= GODMODE
			C.status_flags |= GODMODE
			explosion(get_turf(user), 5, 2, 1, 3, cause = id)
			// explosions have a spawn so this makes sure that we don't get gibbed
			addtimer(CALLBACK(src, PROC_REF(wiz_cleanup), user, C), 1)
			add_attack_logs(user, C, "caused a wizard [id] explosion")
			user.remove_status_effect(type)
			C.remove_status_effect(type)

		user.do_attack_animation(C, no_effect = TRUE)
		C.do_attack_animation(user, no_effect = TRUE)
		user.visible_message("<span class='notice'><b>[user.name]</b> and <b>[C.name]</b> [success]</span>")
		playsound(user, sound_effect, 80)
		user.remove_status_effect(type)
		C.remove_status_effect(type)
		return FALSE

	owner.custom_emote(EMOTE_VISIBLE, request)
	owner.create_point_bubble_from_path(item_path, FALSE)

/datum/status_effect/high_five/on_timeout()
	owner.visible_message("[owner] [get_missed_message()]")

/datum/status_effect/high_five/proc/get_missed_message()
	var/list/missed_highfive_messages = list(
		"lowers [owner.p_their()] hand, it looks like [owner.p_they()] [owner.p_were()] left hanging...",
		"seems to awkwardly wave at nobody in particular.",
		"moves [owner.p_their()] hand directly to [owner.p_their()] forehead in shame.",
		"fully commits and high-fives empty space.",
		"high-fives [owner.p_their()] other hand shamefully before wiping away a tear.",
		"goes for a handshake, then a fistbump, before pulling [owner.p_their()] hand back...? <i>What [owner.p_are()] [owner.p_they()] doing?</i>"
	)

	return pick(missed_highfive_messages)

/datum/status_effect/high_five/dap
	id = "dap"
	critical_success = "dap each other up EPICALLY!"
	success = "dap each other up!"
	request = "requests someone to dap them up!"
	sound_effect = 'sound/effects/snap.ogg'
	item_path = /obj/item/melee/touch_attack/fake_disintegrate  // EI-NATH!

/datum/status_effect/high_five/dap/get_missed_message()
	return "sadly can't find anybody to give daps to, and daps [owner.p_themselves()]. Shameful."

/datum/status_effect/high_five/handshake
	id = "handshake"
	critical_success = "give each other an EPIC handshake!"
	success = "give each other a handshake!"
	request = "requests a handshake!"
	sound_effect = "sound/weapons/thudswoosh.ogg"

/datum/status_effect/high_five/handshake/get_missed_message()
	var/list/missed_messages = list(
		"drops [owner.p_their()] hand, shamefully.",
		"grabs [owner.p_their()] outstretched hand with [owner.p_their()] other hand and gives [owner.p_themselves()] a handshake.",
		"balls [owner.p_their()] hand into a fist, slowly bringing it back in."
	)

	return pick(missed_messages)

/datum/status_effect/charging
	id = "charging"
	alert_type = null

/datum/status_effect/revolver_spinning
	id = "revolver_spin"
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null

	var/obj/effect/spinning_gun_effect_l
	var/obj/effect/spinning_gun_effect_r
	/// Used to show that we stopped spinning, usually when cancelling.
	var/show_stopped_spinning_message = FALSE

	// necessary because shotguns are revolvers too lol
	var/static/list/valid_revolver_types = list(
		/obj/item/gun/projectile/revolver,
		/obj/item/gun/projectile/revolver/mateba,
		/obj/item/gun/projectile/revolver/capgun,
		/obj/item/gun/projectile/revolver/golden,
		/obj/item/gun/projectile/revolver/russian,
		/obj/item/gun/projectile/revolver/russian/soul,
		/obj/item/gun/projectile/revolver/nagant,
		/obj/item/toy/russian_revolver,
		/obj/item/toy/russian_revolver/trick_revolver,
		/obj/item/gun/energy/arc_revolver
	)

	/// Revolvers that won't actually kill a target (but might kill you)
	var/static/list/nonlethal_revolvers = list(
		/obj/item/gun/projectile/revolver/capgun,
		/obj/item/gun/projectile/revolver/russian,
		/obj/item/gun/projectile/revolver/russian/soul,
		/obj/item/toy/russian_revolver,
		/obj/item/toy/russian_revolver/trick_revolver,
		/obj/item/gun/energy/arc_revolver  // don't gib people with this one
	)

	/// guns that will kill you
	var/static/list/suicide_revolvers = list(
		// exclude the trick revolver since you shouldn't know either way
		/obj/item/toy/russian_revolver,
		/obj/item/gun/projectile/revolver/russian,
		/obj/item/gun/projectile/revolver/russian/soul

	)

	var/list/sound_effects = list(
		"sound/weapons/bulletflyby.ogg",
		"sound/weapons/bulletflyby2.ogg",
		"sound/weapons/bulletflyby3.ogg",
	)

/datum/status_effect/revolver_spinning/proc/create_spinning_gun(obj/item/gun/projectile/gun)
	var/obj/effect/spinning_gun_effect = new
	var/mutable_appearance/spinning_gun_ma = mutable_appearance(
		isnull(gun) ? 'icons/obj/guns/projectile.dmi' : gun.icon,
		isnull(gun) ? "revolver" : gun.icon_state,
		layer = ABOVE_MOB_LAYER,
	)

	spinning_gun_effect.appearance = spinning_gun_ma
	spinning_gun_effect.transform *= 0.75
	owner.vis_contents += spinning_gun_effect
	return spinning_gun_effect

/datum/status_effect/revolver_spinning/proc/on_user_move()
	SIGNAL_HANDLER  // COMSIG_MOVABLE_MOVED
	qdel(src)

/datum/status_effect/revolver_spinning/proc/can_spin()
	var/mob/living/carbon/human/H = owner
	return (H.l_hand && (H.l_hand.type in valid_revolver_types) && H.r_hand && (H.r_hand.type in valid_revolver_types) && !H.incapacitated())

/datum/status_effect/revolver_spinning/on_apply()
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(owner))
		return FALSE

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_user_move))

	if(!can_spin())
		return FALSE

	spinning_gun_effect_l = create_spinning_gun(owner.l_hand)
	spinning_gun_effect_r = create_spinning_gun(owner.r_hand)

	spinning_gun_effect_l.pixel_x -= 8
	spinning_gun_effect_r.pixel_x += 8

	for(var/obj/effect/spinning_gun in list(spinning_gun_effect_l, spinning_gun_effect_r))
		// set random direction and speed
		playsound(owner.loc, pick(sound_effects), 45, TRUE)
		spinning_gun.SpinAnimation(rand(3, 15), -1, rand(0, 1), parallel = FALSE)

	H.visible_message(
		"<span class='danger'>[owner] begins spinning the revolvers in [owner.p_their()] hands around!</span>",
	)

	show_stopped_spinning_message = TRUE

/datum/status_effect/revolver_spinning/proc/get_fluff_message(mob/user)
	var/list/messages = list(
		"<span class='warning'>[user] tosses one revolver over the other!</span>",
		"<span class='danger'>[user] flips one revolver around behind [user.p_their()] back and catches it, wow!</span>",
		"<span class='warning'>[user] spins both revolvers around their fingers skillfully.</span>",
		"<span class='notice'>[user] spins one revolver neatly into their pocket, dancing the other around before drawing it out again.</span>",
		"<span class='danger'>You're scared shitless by the display in front of you!</span>"
	)

	return pick(messages)

/datum/status_effect/revolver_spinning/on_remove()
	. = ..()
	owner.vis_contents -= spinning_gun_effect_l
	owner.vis_contents -= spinning_gun_effect_r
	qdel(spinning_gun_effect_l)
	qdel(spinning_gun_effect_r)

	if(show_stopped_spinning_message)
		owner.visible_message("<span class='warning'>[owner] stops spinning [owner.p_their()] revolvers around.</span>")

/datum/status_effect/revolver_spinning/tick()
	. = ..()
	if(!can_spin())
		qdel(src)

	for(var/obj/effect/spinning_gun in list(spinning_gun_effect_l, spinning_gun_effect_r))
		if(prob(70))
			// set random direction and speed
			playsound(owner.loc, pick(sound_effects), 45, TRUE)
			spinning_gun.SpinAnimation(rand(1, 5), -1, rand(0, 1), parallel = FALSE)

	if(prob(5))
		for(var/mob/living/carbon/human/fan in oviewers(owner))
			if(prob(50))
				to_chat(fan, "<span class='notice'>You're so moved by [owner]'s display in front of you, you can't help but clap!</span>")
				fan.emote("clap")

	for(var/mob/living/simple_animal/hostile/poison/bees/bee in orange(3, owner))
		if(prob(50))
			owner.visible_message("<span class='danger'>[owner] deftly splats [bee] out of the air with [owner.p_their()] gun!</span>")
			bee.death()  // pretty good...
			playsound(owner, "sound/effects/splat.ogg", 50)

	if(prob(10))
		owner.visible_message(get_fluff_message(owner), "", "<span class='notice'>You hear something whooshing.</span>")

/// Return TRUE if it actually fires a bullet lethally
/datum/status_effect/revolver_spinning/proc/fire(extra_multiplier, atom/target, obj/item/firing_thing)
	if(istype(firing_thing, /obj/item/gun/projectile/revolver/russian))
		var/obj/item/gun/projectile/revolver/russian/shooting_revolver = firing_thing
		// these are a travesty of guncode and deserve to die tbh
		shooting_revolver.Spin()
		var/initial_zone_selected = owner.zone_selected
		owner.zone_selected = BODY_ZONE_HEAD
		shooting_revolver.afterattack(owner, owner)
		owner.zone_selected = initial_zone_selected
		return FALSE

	else if(istype(firing_thing, /obj/item/gun))
		var/obj/item/gun/shooting_revolver = firing_thing
		var/shot = shooting_revolver.can_shoot()
		shooting_revolver.chambered?.BB?.damage *= 2 * extra_multiplier  // ow
		shooting_revolver.process_fire(target, owner, FALSE)
		return shot

	if(istype(firing_thing, /obj/item/toy/russian_revolver))
		// sucker
		var/obj/item/toy/russian_revolver/gun = firing_thing
		gun.spin_cylinder()
		gun.shoot_gun(owner)
		return FALSE

/datum/status_effect/revolver_spinning/proc/get_message(atom/ahead, obj/item/left, obj/item/right)
	// yearning for rust matches rn
	if((left.type in suicide_revolvers) && (right.type in suicide_revolvers))
		return "<span class='userdanger'>[owner] makes one last move, <i>spinning the barrels on both revolvers</i>, pointing them at [owner.p_their()] head and pulling the trigger!</span>"
	else if((left.type in suicide_revolvers) || (right.type in suicide_revolvers))
		return "<span class='userdanger'>[owner] makes one last move, <i>spinning the barrel on one revolver</i>, pointing it at [owner.p_their()] head, pointing the other forwards, and firing!</span>"
	else
		return "<span class='userdanger'>[owner] makes one last move, pointing both revolvers [isturf(ahead) ? "ahead" : "towards [ahead]"] and firing!</span>"


/datum/status_effect/revolver_spinning/on_timeout()
	. = ..()

	show_stopped_spinning_message = FALSE  // don't show the message again

	var/mob/living/carbon/human/H = owner
	var/obj/item/l_revolver = H.l_hand
	var/obj/item/r_revolver = H.r_hand

	if(!can_spin())
		qdel(src)

	var/ahead = locate(/mob/living) in get_step(owner, owner.dir)
	if(!ahead)
		ahead = get_edge_target_turf(owner, owner.dir)  // shoot straight ahead

	// meow here
	owner.visible_message(get_message(ahead, l_revolver, r_revolver))
	var/extra_multiplier = istajaran(H) ? 2 : 1  // meow

	var/shot_left = fire(extra_multiplier, ahead, l_revolver)
	var/shot_right = fire(extra_multiplier, ahead, r_revolver)

	if(shot_left && shot_right && !(l_revolver.type in nonlethal_revolvers) && !(r_revolver.type in nonlethal_revolvers))
		if(isliving(ahead))
			var/mob/living/L = ahead
			L.visible_message(
				"<span class='danger'>[owner]'s sheer skill blows [ahead] to bits!</span>",
				"<span class='userdanger'>[owner]'s sheer skill blows you to bits!</span>"
			)
			add_attack_logs(owner, L, "ocelot emote gibbed")
			L.gib()


	to_chat(owner, "<i><span class=narsie>You're pretty good...</span></i>")
	playsound(owner, 'sound/effects/ocelot.ogg', 120, FALSE)

