/*
 * Contains:
 * 	Traitor fiber wire
 * 	Improvised garrotes
 */

/obj/item/weapon/twohanded/garrote // 12TC traitor item
	name = "fiber wire"
	desc = "A length of razor-thin wire with an elegant wooden handle on either end.<br>You suspect you'd have to be behind the target to use this weapon effectively."
	icon_state = "garrot_wrap"
	w_class = 1
	var/mob/living/carbon/human/strangling
	var/improvised = 0
	var/garrote_time

/obj/item/weapon/twohanded/garrote/update_icon()
	if(strangling) // If we're strangling someone we want our icon to stay wielded
		icon_state = "garrot_unwrap"
		return

	icon_state = "garrot_[wielded ? "un" : ""]wrap"

/obj/item/weapon/twohanded/garrote/improvised // Made via tablecrafting
	name = "garrote"
	desc = "A length of cable with a shoddily-carved wooden handle tied to either end.<br>You suspect you'd have to be behind the target to use this weapon effectively."
	icon_state = "garrot_I_wrap"
	improvised = 1

/obj/item/weapon/twohanded/garrote/improvised/update_icon()
	if(strangling)
		icon_state = "garrot_I_unwrap"
		return

	icon_state = "garrot_I_[wielded ? "un" : ""]wrap"

/obj/item/weapon/twohanded/garrote/wield(mob/living/carbon/user)
	if(strangling)
		user.visible_message("<span class='info'>[user] removes the [src] from [strangling]'s neck.</span>", \
				"<span class='warning'>You remove the [src] from [strangling]'s neck.</span>")

		strangling = null
		update_icon()
		processing_objects.Remove(src)

	else
		..()

/obj/item/weapon/twohanded/garrote/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(garrote_time > world.time) // Cooldown
		return

	if(!istype(user, /mob/living/carbon/human)) // spap_hand is a proc of /mob/living, user is simply /mob
		return

	var/mob/living/carbon/human/U = user

	if(!wielded)
		user << "<span class = 'warning'>You must use both hands to garrote [M]!</span>"
		return

	if(!istype(M, /mob/living/carbon/human))
		user << "<span class = 'warning'>You don't think that garroting [M] would be very effective...</span>"
		return

	if(M == U)
		U.suicide() // This will display a prompt for confirmation first.
		return

	if(M.dir != U.dir)
		user << "<span class='warning'>You cannot use [src] on [M] from that angle!</span>"
		return

	if(improvised && ((M.head && (M.head.flags & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags & MASKCOVERSMOUTH)))) // Improvised garrotes are blocked by mouth-covering items.
		user << "<span class = 'warning'>[M]'s neck is blocked by something they're wearing!</span>"

	if(strangling)
		user << "<span class = 'warning'>You cannot use [src] on two people at once!</span>"
		return

	unwield(U)

	U.swap_hand() // For whatever reason the grab will not properly work if we don't have the free hand active.
	M.grabbedby(U, 1)
	var/obj/item/weapon/grab/G = U.get_active_hand()
	U.swap_hand()

	if(G && istype(G))
		if(improvised) // Improvised garrotes start you off with a passive grab, but keep you stunned like an agressive grab.
			M.Stun(1)
		else
			G.state = GRAB_NECK
			G.hud.icon_state = "kill"
			G.hud.name = "kill"
			M.silent += 1

	garrote_time = world.time + 10
	processing_objects.Add(src)
	strangling = M
	update_icon()

	playsound(src.loc, 'sound/weapons/cablecuff.ogg', 15, 1, -1)

	M.visible_message("<span class='danger'>[U] comes from behind and begins garroting [M] with the [src]!</span>", \
				  "<span class='userdanger'>[U]\ begins garroting you with the [src]![improvised ? "" : " You are unable to speak!"]</span>", \
				  "You hear struggling and wire strain against flesh!")

	return

/obj/item/weapon/twohanded/garrote/process()

	if(!istype(loc, /mob/living/carbon/human))
		strangling = null
		update_icon()
		processing_objects.Remove(src)
		return

	var/mob/living/carbon/human/user = loc
	var/obj/item/weapon/grab/G

	if(src == user.r_hand && istype(user.l_hand, /obj/item/weapon/grab))
		G = user.l_hand

	else if(src == user.l_hand && istype(user.r_hand, /obj/item/weapon/grab))
		G = user.r_hand

	else
		user.visible_message("<span class='warning'>[user] loses his grip on [strangling]'s neck.</span>", \
				 "<span class='warning'>You lose your grip on [strangling]'s neck.</span>")

		strangling = null
		update_icon()
		processing_objects.Remove(src)

		return

	if(!G.affecting)
		user.visible_message("<span class='warning'>[user] loses his grip on [strangling]'s neck.</span>", \
				"<span class='warning'>You lose your grip on [strangling]'s neck.</span>")

		strangling = null
		update_icon()
		processing_objects.Remove(src)

		return

	if(G.state < GRAB_NECK) // Only possible with improvised garrotes, essentially this will stun people as if they were aggressively grabbed. Allows for resisting out if you're quick, but not running away.
		strangling.Stun(3)

	if(improvised)
		strangling.stuttering = max(strangling.stuttering, 3)
		strangling.apply_damage(2, OXY, "head")
		return


	strangling.silent = max(strangling.silent,  3) // Non-improvised effects
	strangling.apply_damage(4, OXY, "head")


/obj/item/weapon/twohanded/garrote/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is wrapping the [src] around \his neck and pulling the handles! It looks like \he's trying to commit suicide.</span>")
	playsound(src.loc, 'sound/weapons/cablecuff.ogg', 15, 1, -1)
	return (OXYLOSS)