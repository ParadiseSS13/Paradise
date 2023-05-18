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

#define LWAP_LOCK_CAP 10

/datum/status_effect/lwap_scope
	id = "lwap_scope"
	alert_type = null
	duration = -1
	tick_interval = 4
	/// The number of people the gun has locked on to. Caps at 10 for sanity.
	var/locks = 0
	/// What direction the owner was in when using the scope.
	var/owner_dir = 0

/datum/status_effect/lwap_scope/on_creation(mob/living/new_owner, stored_dir = 0)
	owner_dir = stored_dir
	return ..()

/datum/status_effect/lwap_scope/tick()
	locks = 0
	var/turf/owner_turf = get_turf(owner)
	var/scope_turf
	for(var/turf/T in RANGE_EDGE_TURFS(7, owner_turf))
		if(get_dir(owner, T) != owner_dir)
			continue
		if(T in range(owner, 6))
			continue
		scope_turf = T
		break
	if(scope_turf)
		for(var/mob/living/L in range(10, scope_turf))
			if(locks >= LWAP_LOCK_CAP)
				return
			if(L == owner || L.stat == DEAD || isslime(L) || ismonkeybasic(L)) //xenobio moment
				continue
			new /obj/effect/temp_visual/lwap_ping(owner.loc, owner, L)
			locks++

#undef LWAP_LOCK_CAP

/obj/effect/temp_visual/lwap_ping
	duration = 0.5 SECONDS
	randomdir = FALSE
	icon = 'icons/obj/projectiles.dmi'
	/// The image shown to lwap users
	var/image/lwap_image
	/// The person with the lwap at the moment, really just used to remove this from their screen
	var/source_UID
	/// The icon state applied to the image created for this ping.
	var/real_icon_state = "red_laser"

/obj/effect/temp_visual/lwap_ping/Initialize(mapload, mob/living/looker, mob/living/creature)
	. = ..()
	if(!looker || !creature)
		return INITIALIZE_HINT_QDEL
	lwap_image = image(icon = icon, loc = src, icon_state = real_icon_state, layer = ABOVE_ALL_MOB_LAYER, pixel_x = ((creature.x - looker.x) * 32), pixel_y = ((creature.y - looker.y) * 32))
	lwap_image.plane = ABOVE_LIGHTING_PLANE
	lwap_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	source_UID = looker.UID()
	add_mind(looker)

/obj/effect/temp_visual/lwap_ping/Destroy()
	var/mob/living/previous_user = locateUID(source_UID)
	if(previous_user)
		remove_mind(previous_user)
	// Null so we don't shit the bed when we delete
	lwap_image = null
	return ..()

/// Add the image to the lwap user's screen
/obj/effect/temp_visual/lwap_ping/proc/add_mind(mob/living/looker)
	looker.client?.images |= lwap_image

/// Remove the image from the lwap user's screen
/obj/effect/temp_visual/lwap_ping/proc/remove_mind(mob/living/looker)
	looker.client?.images -= lwap_image
