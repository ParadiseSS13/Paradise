//===Клинки через грудной имплант===
/obj/item/organ/internal/cyberimp/chest/serpentid_blades
	name = "neuronodule of blades"
	desc = "control organ of upper blades"
	icon_state = "chest_implant"
	parent_organ = "chest"
	actions_types = list(/datum/action/item_action/organ_action/toggle/switch_blades)
	contents = newlist(/obj/item/kitchen/knife/combat/serpentblade,/obj/item/kitchen/knife/combat/serpentblade)
	action_icon = list(/datum/action/item_action/organ_action/toggle/switch_blades = 'modular_ss220/species/serpentids/icons/organs.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle/switch_blades = "serpentid_hand_act")
	var/obj/item/holder_l = null
	var/icon_file = 'modular_ss220/species/serpentids/icons/mob/r_serpentid.dmi'
	var/new_icon_state = "blades_0"
	var/mutable_appearance/old_overlay
	var/mutable_appearance/new_overlay
	var/overlay_color
	var/blades_active = FALSE
	var/activation_in_progress = FALSE
	unremovable = TRUE
	emp_proof = TRUE
	var/first_recollor = TRUE

/datum/action/item_action/organ_action/toggle/switch_blades
	name = "Switch Threat Mode"
	desc = "Switch your stance to show other your intentions"
	button_overlay_icon = 'modular_ss220/species/serpentids/icons/organs.dmi'
	button_overlay_icon_state = "serpentid_hand_act"

/obj/item/organ/internal/cyberimp/chest/serpentid_blades/on_life()
	. = ..()
	if(first_recollor)
		update_icon(UPDATE_OVERLAYS)
		first_recollor = FALSE
	if(blades_active)
		var/isleft = owner.hand
		var/obj/item/item = (isleft ? owner.get_inactive_hand() : owner.get_active_hand())
		if(!istype(item, /obj/item/grab))
			owner.drop_r_hand()

/obj/item/organ/internal/cyberimp/chest/serpentid_blades/render()
	var/mutable_appearance/our_MA = mutable_appearance(icon_file, new_icon_state, layer = -INTORGAN_LAYER)
	return our_MA

/obj/item/organ/internal/cyberimp/chest/serpentid_blades/ui_action_click()
	if(activation_in_progress)
		return
	if(crit_fail || (!holder_l && !length(contents)))
		to_chat(owner, span_warning("Вы не можете поднять клинки"))
		return
	var/extended = holder_l && !(holder_l in src)
	if(extended)
		if(!activation_in_progress)
			activation_in_progress = TRUE
			Retract()
	else if(!activation_in_progress)
		activation_in_progress = TRUE
		if(do_after(owner, 20*(owner.dna.species.action_mult), FALSE, owner))
			holder_l = null
			Extend()
	activation_in_progress = FALSE

/obj/item/organ/internal/cyberimp/chest/serpentid_blades/update_overlays()
	. = .. ()
	if(old_overlay)
		owner.overlays -= old_overlay
	if(owner)
		var/icon/blades_icon = new/icon("icon" = icon_file, "icon_state" = new_icon_state)
		var/obj/item/organ/external/chest/torso = owner.get_limb_by_name("chest")
		var/body_color = torso.s_col
		blades_icon.Blend(body_color, ICON_ADD)
		new_overlay = mutable_appearance(blades_icon)
		old_overlay = new_overlay
		owner.overlays += new_overlay

/obj/item/organ/internal/cyberimp/chest/serpentid_blades/proc/Extend()
	if(!(contents[1] in src))
		return
	if(status & ORGAN_DEAD)
		return

	holder_l = contents[1]

	holder_l.flags |= NODROP
	holder_l.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	holder_l.slot_flags = null
	holder_l.w_class = WEIGHT_CLASS_HUGE
	holder_l.materials = null

	for(var/arm_slot in list(ITEM_SLOT_LEFT_HAND,ITEM_SLOT_RIGHT_HAND))
		var/obj/item/arm_item = owner.get_item_by_slot(arm_slot)

		if(arm_item)
			if(istype(arm_item, /obj/item/offhand))
				var/obj/item/offhand_arm_item = owner.get_active_hand()
				to_chat(owner, span_warning("Your hands are too encumbered wielding [offhand_arm_item] to deploy [src]!"))
				return
			else if(!owner.drop_item_to_ground(arm_item))
				to_chat(owner, span_warning("Your [arm_item] interferes with [src]!"))
				return
			else
				to_chat(owner, span_notice("You drop [arm_item] to activate [src]!"))

	if(!owner.put_in_l_hand(holder_l))
		return

	blades_active = TRUE
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)
	new_icon_state = "blades_1"
	update_icon(UPDATE_OVERLAYS)
	return TRUE

/obj/item/organ/internal/cyberimp/chest/serpentid_blades/proc/Retract()
	if(status & ORGAN_DEAD)
		return

	owner.transfer_item_to(holder_l, src, force = TRUE)
	holder_l = null
	blades_active = FALSE
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)
	new_icon_state = "blades_0"
	update_icon(UPDATE_OVERLAYS)

//Проки на обработку при поднятом клинке
/datum/species/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style) //Handles any species-specific attackhand events.
	if(!istype(M))
		return
	var/obj/item/organ/internal/cyberimp/chest/serpentid_blades/blades_implant = M.get_int_organ(/obj/item/organ/internal/cyberimp/chest/serpentid_blades)
	if(blades_implant)
		if(blades_implant.owner.invisibility != INVISIBILITY_OBSERVER)
			blades_implant.owner.reset_visibility()
		if(blades_implant.blades_active)
			if((M != H) && M.a_intent != INTENT_HELP && H.check_shields(M, 0, M.name, attack_type = UNARMED_ATTACK))
				add_attack_logs(M, H, "Melee attacked with blades (miss/block)")
				H.visible_message(span_warning("[M] attempted to touch [H]!"))
				return FALSE

			switch(M.a_intent)
				if(INTENT_HELP)
					help(M, H, attacker_style)


				if(INTENT_GRAB)
					blades_grab(M, H, attacker_style)

				if(INTENT_HARM)
					blades_harm(M, H, attacker_style)

				if(INTENT_DISARM)
					blades_disarm(M, H, attacker_style)
		else
			. = ..()
	else
		. = ..()

//Модификация усиленного граба
/datum/species/proc/blades_grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message(span_warning("[target] blocks [user]'s grab attempt!"))
		return FALSE
	if(!attacker_style && target.buckled)
		target.buckled.user_unbuckle_mob(target, user)
		return TRUE
	if(user.hand)
		user.swap_hand()
	target.grabbedby(user)
	var/obj/item/grab/grab_item = user.get_active_hand()
	grab_item.state = GRAB_AGGRESSIVE
	grab_item.icon_state = "grabbed1"

//Модификация усиленного дизарма
/datum/species/proc/blades_disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(user == target)
		return FALSE
	if(target.check_block())
		target.visible_message(span_warning("[target] blocks [user]'s disarm attempt!"))
		return FALSE
	if(SEND_SIGNAL(target, COMSIG_HUMAN_ATTACKED, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FALSE
	if(target.absorb_stun(0))
		target.visible_message(span_warning("[target] is not affected by [user]'s disarm attempt!"))
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		playsound(target.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
		return FALSE
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	if(target.move_resist > (user.pull_force * 2))
		return FALSE
	if(!(target.status_flags & CANPUSH))
		return FALSE
	if(target.anchored)
		return FALSE
	if(target.buckled)
		target.buckled.unbuckle_mob(target)

	for(var/i = 1; i <= 2; i++)
		var/shove_dir = get_dir(user.loc, target.loc)
		var/turf/shove_to = get_step(target.loc, shove_dir)
		playsound(shove_to, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		if(shove_to == user.loc)
			return FALSE

		//Directional checks to make sure that we're not shoving through a windoor or something like that
		var/directional_blocked = FALSE
		var/target_turf = get_turf(target)
		if(shove_dir in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)) // if we are moving diagonially, we need to check if there are dense walls either side of us
			var/turf/T = get_step(target.loc, turn(shove_dir, 45)) // check to the left for a dense turf
			if(T.density)
				directional_blocked = TRUE
			else
				T = get_step(target.loc, turn(shove_dir, -45)) // check to the right for a dense turf
				if(T.density)
					directional_blocked = TRUE

		if(!directional_blocked)
			for(var/obj/obj_content in target_turf) // check the tile we are on for border
				if(obj_content.flags & ON_BORDER && obj_content.dir & shove_dir && obj_content.density)
					directional_blocked = TRUE
					break
		if(!directional_blocked)
			for(var/obj/obj_content in shove_to) // check tile we are moving to for borders
				if(obj_content.flags & ON_BORDER && obj_content.dir & turn(shove_dir, 180) && obj_content.density)
					directional_blocked = TRUE
					break

		if(!directional_blocked)
			for(var/atom/movable/AM in shove_to)
				if(AM.shove_impact(target, user)) // check for special interactions EG. tabling someone
					return TRUE

		var/moved = target.Move(shove_to, shove_dir)
		if(!moved) //they got pushed into a dense object
			add_attack_logs(user, target, "Disarmed into a dense object", ATKLOG_ALL)
			target.visible_message(span_warning("[user] slams [target] into an obstacle!"), \
									span_userdanger("You get slammed into the obstacle by [user]!"), \
									"You hear a loud thud.")
			if(!HAS_TRAIT(target, TRAIT_FLOORED))
				target.KnockDown(3 SECONDS)
				addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, SetKnockDown), 0), 3 SECONDS) // so you cannot chain stun someone
			else if(!user.IsStunned())
				target.Stun(0.5 SECONDS)
		else
			var/obj/item/active_hand = target.get_active_hand()
			if(target.IsSlowed() && active_hand && !IS_HORIZONTAL(user) && !HAS_TRAIT(active_hand, TRAIT_WIELDED) && !istype(active_hand, /obj/item/grab))
				target.drop_item()
				add_attack_logs(user, target, "Disarmed object out of hand", ATKLOG_ALL)
			else
				target.Slowed(2.5 SECONDS, 0.5)
				var/obj/item/I = target.get_active_hand()
				if(I)
					to_chat(target, span_warning("Your grip on [I] loosens!"))
				add_attack_logs(user, target, "Disarmed, shoved back", ATKLOG_ALL)
		target.stop_pulling()

//Модификация усиленного дизарма
/datum/species/proc/blades_harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You don't want to harm [target]!"))
		return FALSE
	if(target != user && handle_harm_antag(user, target))
		return FALSE
	if(target.check_block())
		target.visible_message(span_warning("[target] blocks [user]'s attack!"))
		return FALSE
	if(SEND_SIGNAL(target, COMSIG_HUMAN_ATTACKED, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FALSE
	if(!user.hand)
		user.swap_hand()
	var/obj/item/kitchen/knife/combat/serpentblade/blade = user.get_active_hand()
	blade.attack(target, user)
