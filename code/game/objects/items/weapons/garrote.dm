/*
 * Contains:
 * 	Traitor fiber wire
 * 	Improvised garrotes
 */

/obj/item/garrote // 12TC traitor item
	name = "fiber wire"
	desc = "A length of razor-thin wire with an elegant wooden handle on either end.<br>You suspect you'd have to be behind the target to use this weapon effectively."
	icon_state = "garrot_wrap"
	w_class = WEIGHT_CLASS_TINY
	var/mob/living/carbon/human/strangling
	var/improvised = FALSE
	var/garrote_time

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

/obj/item/garrote/improvised // Made via tablecrafting
	name = "garrote"
	desc = "A length of cable with a shoddily-carved wooden handle tied to either end.<br>You suspect you'd have to be behind the target to use this weapon effectively."
	icon_state = "garrot_I_wrap"
	improvised = TRUE

/obj/item/garrote/improvised/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, wield_callback=CALLBACK(src, PROC_REF(wield)))


/obj/item/garrote/proc/wield(obj/item/source, mob/living/carbon/user)
	if(!strangling)
		return
	user.visible_message("<span class='notice'>[user] removes [src] from [strangling]'s neck.</span>",
			"<span class='warning'>You remove [src] from [strangling]'s neck.</span>")

	strangling = null
	update_icon(UPDATE_ICON_STATE)
	STOP_PROCESSING(SSobj, src)


/obj/item/garrote/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(garrote_time > world.time) // Cooldown
		return

	if(!ishuman(user)) // spap_hand is a proc of /mob/living, user is simply /mob
		return

	var/mob/living/carbon/human/U = user

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, "<span class = 'warning'>You must use both hands to garrote [M]!</span>")
		return

	if(!ishuman(M))
		to_chat(user, "<span class = 'warning'>You don't think that garroting [M] would be very effective...</span>")
		return

	if(M == U)
		U.suicide() // This will display a prompt for confirmation first.
		return

	if(M.dir != U.dir)
		to_chat(user, "<span class='warning'>You cannot use [src] on [M] from that angle!</span>")
		return

	if(improvised && ((M.head && (M.head.flags_cover & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags_cover & MASKCOVERSMOUTH)))) // Improvised garrotes are blocked by mouth-covering items.
		to_chat(user, "<span class = 'warning'>[M]'s neck is blocked by something [M.p_theyre()] wearing!</span>")

	if(strangling)
		to_chat(user, "<span class = 'warning'>You cannot use [src] on two people at once!</span>")
		return

	attack_self(user)

	U.swap_hand() // For whatever reason the grab will not properly work if we don't have the free hand active.
	var/obj/item/grab/G = M.grabbedby(U, 1)
	U.swap_hand()

	if(G && istype(G))
		if(improvised) // Improvised garrotes start you off with a passive grab, but keep you stunned like an agressive grab.
			M.Stun(2 SECONDS)
		else
			G.state = GRAB_NECK
			G.hud.icon_state = "kill"
			G.hud.name = "kill"
			M.AdjustSilence(2 SECONDS)

	garrote_time = world.time + 10
	START_PROCESSING(SSobj, src)
	strangling = M
	update_icon(UPDATE_ICON_STATE)

	playsound(loc, 'sound/weapons/cablecuff.ogg', 15, 1, -10, ignore_walls = FALSE)

	M.visible_message("<span class='danger'>[U] comes from behind and begins garroting [M] with [src]!</span>", \
				"<span class='userdanger'>[U] begins garroting you with [src]![improvised ? "" : " You are unable to speak!"]</span>", \
				"You hear struggling and wire strain against flesh!")

	return

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
		user.visible_message("<span class='warning'>[user] loses [user.p_their()] grip on [strangling]'s neck.</span>", \
				"<span class='warning'>You lose your grip on [strangling]'s neck.</span>")

		strangling = null
		update_icon(UPDATE_ICON_STATE)
		STOP_PROCESSING(SSobj, src)

		return

	if(!G.affecting)
		user.visible_message("<span class='warning'>[user] loses [user.p_their()] grip on [strangling]'s neck.</span>", \
				"<span class='warning'>You lose your grip on [strangling]'s neck.</span>")

		strangling = null
		update_icon(UPDATE_ICON_STATE)
		STOP_PROCESSING(SSobj, src)

		return

	if(G.state < GRAB_NECK) // Only possible with improvised garrotes, essentially this will stun people as if they were aggressively grabbed. Allows for resisting out if you're quick, but not running away.
		strangling.Stun(6 SECONDS)

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
	user.visible_message("<span class='suicide'>[user] is wrapping [src] around [user.p_their()] neck and pulling the handles! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/cablecuff.ogg', 15, 1, -10, ignore_walls = FALSE)
	return OXYLOSS
