/**
 * # Stealth Implant
 *
 * Implant which allows you to summon an MGS-style cardboard box that turns you invisble after a short delay.
 */
/obj/item/implant/stealth
	name = "S3 bio-chip"
	desc = "Allows you to be hidden in plain sight."
	implant_state = "implant-syndicate"
	implant_data = /datum/implant_fluff/stealth
	actions_types = list(/datum/action/item_action/agent_box)

/obj/item/implanter/stealth
	name = "bio-chip implanter (stealth)"
	implant_type = /obj/item/implant/stealth

/datum/action/item_action/agent_box
	name = "Deploy Box"
	desc = "Find inner peace, here, in the box."
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS | AB_CHECK_STUNNED
	background_icon_state = "bg_agent"
	button_icon_state = "deploy_box"
	use_itemicon = FALSE
	/// If TRUE, the box can't be deployed
	var/on_cooldown = FALSE

/datum/action/item_action/agent_box/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	if(istype(owner.loc, /obj/structure/closet/cardboard/agent))
		var/obj/structure/closet/cardboard/agent/box = owner.loc
		if(box.open())
			owner.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)
			recall_box_animation()
		return
	// Box closing from here on out.
	if(on_cooldown)
		return FALSE
	if(!isturf(owner.loc)) //Don't let the player use this to escape mechs/welded closets.
		to_chat(owner, "<span class='warning'>You need more space to activate this implant!</span>")
		return
	addtimer(VARSET_CALLBACK(src, on_cooldown, FALSE), 10 SECONDS)
	on_cooldown = TRUE
	owner.playsound_local(owner, 'sound/misc/box_deploy.ogg', 50, TRUE)
	spawn_box()

/datum/action/item_action/agent_box/proc/spawn_box()
	// Do the box's fade in spawn animation with an image so it follows the owner.
	var/image/fake_box = image('icons/obj/cardboard_boxes.dmi', owner, "agentbox", ABOVE_MOB_LAYER)
	flick_overlay_view(fake_box, owner, 0.4 SECONDS)
	fake_box.alpha = 0
	fake_box.pixel_z = 30
	animate(fake_box, pixel_z = fake_box.pixel_z - 30, alpha = fake_box.alpha + 255, time = 3, loop = 1)
	sleep(3)

	// Spawn the actual box
	var/obj/structure/closet/cardboard/agent/box = new(get_turf(owner), owner)
	box.implant_user_UID = owner.UID()
	// Slightly shorter time since we needed 0.3s to to do the spawn animation.
	INVOKE_ASYNC(box, TYPE_PROC_REF(/obj/structure/closet/cardboard/agent, go_invisible), 1.7 SECONDS)
	box.create_fake_box()
	owner.forceMove(box)

/datum/action/item_action/agent_box/proc/recall_box_animation()
	var/image/fake_box = image('icons/obj/cardboard_boxes.dmi', owner, "agentbox", ABOVE_MOB_LAYER)
	flick_overlay_view(fake_box, owner, 0.4 SECONDS)
	animate(fake_box, pixel_z = fake_box.pixel_z + 30, alpha = fake_box.alpha - 255, time = 3, loop = 1)

/datum/action/item_action/agent_box/Grant(mob/grant_to)
	. = ..()
	if(owner)
		RegisterSignal(owner, COMSIG_HUMAN_SUICIDE_ACT, PROC_REF(suicide_act))

/datum/action/item_action/agent_box/Remove(mob/M)
	if(owner)
		UnregisterSignal(owner, COMSIG_HUMAN_SUICIDE_ACT)
	return ..()

/datum/action/item_action/agent_box/proc/suicide_act(datum/source)
	SIGNAL_HANDLER

	if(!istype(owner.loc, /obj/structure/closet/cardboard/agent))
		return
	var/obj/structure/closet/cardboard/agent/box = owner.loc
	owner.visible_message("<span class='suicide'>[owner] falls out of [box]! It looks like [owner.p_they()] committed suicide!</span>")
	owner.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)
	INVOKE_ASYNC(box, TYPE_PROC_REF(/obj/structure/closet/cardboard/agent, open))
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom/movable, throw_at), get_turf(owner))
	return OXYLOSS

// Stealth implant box
/obj/structure/closet/cardboard/agent
	name = "inconspicious box"
	desc = "It's so normal that you didn't notice it before."
	icon_state = "agentbox"
	max_integrity = 1
	move_speed_multiplier = 0.5 // You can move at normal walk speed while in this box.
	/// UID of the person who summoned this box with an implant.
	var/implant_user_UID
	// This has to be a separate object and not just an image because the image will inherit the box's 0 alpha while it is stealthed.
	/// A holder effect which follows the src box so we can display an image to the person inside the box.
	var/obj/effect/fake_box
	/// The box image attached to the `fake_box` object.
	var/image/box_img

/obj/structure/closet/cardboard/agent/Destroy()
	var/mob/living/implant_user = locateUID(implant_user_UID)
	implant_user?.client?.images -= box_img
	QDEL_NULL(fake_box)
	QDEL_NULL(box_img)
	return ..()

/obj/structure/closet/cardboard/agent/open()
	. = ..()
	if(!.)
		return FALSE
	qdel(src)

// When the box is opened, it's deleted, so we never need to update this.
/obj/structure/closet/cardboard/agent/update_icon_state()
	return

/obj/structure/closet/cardboard/agent/proc/create_fake_box()
	if(fake_box)
		return
	fake_box = new(get_turf(src))
	fake_box.mouse_opacity = MOUSE_OPACITY_TRANSPARENT // This object should be completely invisible.
	box_img = image(icon, fake_box, icon_state, ABOVE_MOB_LAYER)
	box_img.alpha = 128
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(move_fake_box))
	var/mob/living/implant_user = locateUID(implant_user_UID)
	implant_user.client?.images += box_img

/obj/structure/closet/cardboard/agent/proc/move_fake_box(datum/source, oldloc, move_dir)
	SIGNAL_HANDLER

	// For non-standard movement such as teleports.
	if(!move_dir)
		fake_box.loc = get_turf(src)
		return
	// For basic 8-directional movement.
	fake_box.loc = get_step(fake_box, move_dir)

/obj/structure/closet/cardboard/agent/proc/go_invisible(invis_time = 2 SECONDS)
	animate(src, alpha = 0, time = invis_time)
	sleep(invis_time)
	// This is so people can't locate the box by spamming right click everywhere.
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/closet/cardboard/agent/proc/reveal()
	alpha = 255
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	addtimer(CALLBACK(src, PROC_REF(go_invisible)), 1 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/structure/closet/cardboard/agent/Bump(atom/A)
	. = ..()
	if(isliving(A))
		reveal()

/obj/structure/closet/cardboard/agent/Bumped(atom/movable/A)
	. = ..()
	if(isliving(A))
		reveal()
