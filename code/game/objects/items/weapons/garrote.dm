/*
 * Contains:
 * 	Traitor fiber wire
 * 	Improvised garrotes
 */

/// 12TC traitor item
/obj/item/garrote
	name = "fiber wire"
	desc = "A length of razor-thin wire with an elegant wooden handle on either end.<br>You suspect you'd have to be behind the target to use this weapon effectively."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "garrot_wrap"
	w_class = WEIGHT_CLASS_TINY
	var/mob/living/carbon/human/strangling
	var/improvised = FALSE
	var/garrote_time
	new_attack_chain = TRUE

/obj/item/garrote/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed)

/obj/item/garrote/Destroy()
	strangling = null
	return ..()

/obj/item/garrote/update_icon_state()
	if(strangling) // If we're strangling someone we want our icon to stay wielded
		icon_state = "garrot_[improvised ? "I_" : ""]unwrap"
	else
		icon_state = "garrot_[improvised ? "I_" : ""][HAS_TRAIT(src, TRAIT_WIELDED) ? "un" : ""]wrap"

/// Made via tablecrafting
/obj/item/garrote/improvised
	name = "garrote"
	desc = "A length of cable with a shoddily-carved wooden handle tied to either end.<br>You suspect you'd have to be behind the target to use this weapon effectively."
	icon_state = "garrot_I_wrap"
	improvised = TRUE

/obj/item/garrote/improvised/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, wield_callback = CALLBACK(src, PROC_REF(wield)))

/obj/item/garrote/proc/wield(obj/item/source, mob/living/carbon/user)
	if(!strangling)
		return
	user.visible_message(
		SPAN_NOTICE("[user] removes [src] from [strangling]'s neck."),
		SPAN_WARNING("You remove [src] from [strangling]'s neck."),
		SPAN_HEAR("You hear the wire slip free!")
	)

	strangling = null
	update_icon(UPDATE_ICON_STATE)
	STOP_PROCESSING(SSobj, src)

/obj/item/garrote/interact_with_atom(mob/living/carbon/human/target, mob/living/carbon/human/user, list/modifiers)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(garrote_time > world.time) // Cooldown.
		return ITEM_INTERACT_COMPLETE

	if(!ishuman(user))
		to_chat(user, SPAN_WARNING("You lack the dexterity to use this!"))
		return ITEM_INTERACT_COMPLETE

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, SPAN_WARNING("You must use both hands to garrote [target]!"))
		return ITEM_INTERACT_COMPLETE

	if(!ishuman(target))
		to_chat(user, SPAN_WARNING("You don't think that garroting [target] would be very effective...!"))
		return ITEM_INTERACT_COMPLETE

	if(target == user)
		user.suicide() // This will display a prompt for confirmation first.
		return ITEM_INTERACT_COMPLETE

	if(target.dir != user.dir && !target.incapacitated())
		to_chat(user, SPAN_WARNING("You cannot use [src] on [target] from that angle!"))
		return ITEM_INTERACT_COMPLETE

	if(improvised && ((target.head && (target.head.flags_cover & HEADCOVERSMOUTH)) || (target.wear_mask && (target.wear_mask.flags_cover & MASKCOVERSMOUTH)))) // Improvised garrotes are blocked by mouth-covering items.
		to_chat(user, SPAN_WARNING("[target]'s neck is blocked by something [target.p_theyre()] wearing!"))
		return ITEM_INTERACT_COMPLETE

	if(strangling)
		to_chat(user, SPAN_WARNING("You cannot use [src] on two people at once!"))
		return ITEM_INTERACT_COMPLETE

	activate_self(user)

	user.swap_hand() // For whatever reason the grab will not properly work if we don't have the free hand active.
	var/obj/item/grab/grab = target.grabbedby(user, TRUE)
	user.swap_hand()

	if(grab && istype(grab))
		if(improvised) // Improvised garrotes start you off with a passive grab, but will lock you in place. A quick stun to drop items but not to make it unescapable
			target.Stun(1 SECONDS)
			target.Immobilize(2 SECONDS)
		else
			grab.state = GRAB_NECK
			grab.hud.icon_state = "kill"
			grab.hud.name = "kill"
			target.AdjustSilence(2 SECONDS)

	garrote_time = world.time + 1 SECONDS
	START_PROCESSING(SSobj, src)
	strangling = target
	add_fingerprint(user)
	update_icon(UPDATE_ICON_STATE)

	playsound(loc, 'sound/weapons/cablecuff.ogg', 15, TRUE, -10, ignore_walls = FALSE)

	target.visible_message(
		SPAN_DANGER("[user] comes from behind and begins garroting [target] with [src]!"),
		SPAN_USERDANGER("[user] begins garroting you with [src]![improvised ? "" : " You are unable to speak!"]"),
		SPAN_HEAR("You hear struggling and wire strain against flesh!")
		)

	return ITEM_INTERACT_COMPLETE

/obj/item/garrote/process()
	if(!strangling)
		// Our mark got gibbed or similar
		update_icon(UPDATE_ICON_STATE)
		STOP_PROCESSING(SSobj, src)
		return

	if(!ishuman(loc))
		strangling = null
		update_icon(UPDATE_ICON_STATE)
		STOP_PROCESSING(SSobj, src)
		return

	var/mob/living/carbon/human/user = loc
	var/obj/item/grab/G

	if(src == user.r_hand && istype(user.l_hand, /obj/item/grab))
		G = user.l_hand

	else if(src == user.l_hand && istype(user.r_hand, /obj/item/grab))
		G = user.r_hand

	else
		user.visible_message(
			SPAN_WARNING("[user] loses [user.p_their()] grip on [strangling]'s neck!"),
			SPAN_WARNING("You lose your grip on [strangling]'s neck!"),
			SPAN_HEAR("You hear the wire slip free!")
		)

		strangling = null
		update_icon(UPDATE_ICON_STATE)
		STOP_PROCESSING(SSobj, src)

		return

	if(!G.affecting)
		user.visible_message(
			SPAN_WARNING("[user] loses [user.p_their()] grip on [strangling]'s neck!"),
			SPAN_WARNING("You lose your grip on [strangling]'s neck!"),
			SPAN_HEAR("You hear the wire slip free!")
		)

		strangling = null
		update_icon(UPDATE_ICON_STATE)
		STOP_PROCESSING(SSobj, src)

		return

	if(G.state < GRAB_NECK) // Only possible with improvised garrotes, essentially this will stun people as if they were aggressively grabbed. Allows for resisting out if you're quick, but not running away.
		strangling.Immobilize(3 SECONDS)

	if(improvised)
		strangling.Stuttering(6 SECONDS)
		strangling.apply_damage(2, OXY, "head")
		return

	strangling.AbsoluteSilence(6 SECONDS) // Non-improvised effects
	if(G.state == GRAB_KILL)
		strangling.PreventOxyHeal(6 SECONDS)
		strangling.AdjustLoseBreath(6 SECONDS)
		strangling.apply_damage(4, OXY, "head")

/obj/item/garrote/suicide_act(mob/user)
	user.visible_message(SPAN_SUICIDE("[user] is wrapping [src] around [user.p_their()] neck and pulling the handles! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/weapons/cablecuff.ogg', 15, TRUE, -10, ignore_walls = FALSE)
	return OXYLOSS
