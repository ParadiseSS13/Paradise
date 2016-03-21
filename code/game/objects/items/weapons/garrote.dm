/obj/item/weapon/twohanded/garrote
	name = "fiber wire"
	desc = "A length of razor-thin wire with a wooden handle on either end.<br>You suspect you'd have to be behind the target to use this weapon effectively."
	icon_state = "garrot_wrap"
	w_class = 1
	var/mob/living/carbon/human/strangling

/obj/item/weapon/twohanded/garrote/update_icon()
	if(strangling) // If we're strangling someone we want our icon to stay wielded
		icon_state = "garrot_unwrap"
		return

	icon_state = "garrot_[wielded ? "un" : ""]wrap"

/obj/item/weapon/twohanded/garrote/wield(mob/living/carbon/user)
	if(strangling)
		user.visible_message("<span class='warning'>[user] removes the [src] from [strangling]'s neck.</span>", \
				"<span class='warning'>You remove the [src] from [strangling]'s neck.</span>")

		strangling = null
		update_icon()
		processing_objects.Remove(src)

	else
		..()

/obj/item/weapon/twohanded/garrote/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!wielded)
		user << "<span class = 'warning'>You must use both hands to garrote [M]!</span>"
		return

	if(!istype(M, /mob/living/carbon/human))
		user << "<span class = 'warning'>You don't think that garroting [M] would be very effective...</span>"
		return

	if(M == user)
		user << "<span class = 'info'>You decide against strangling yourself for the time being.</span>"

	if(M.dir != user.dir)
		user << "<span class='warning'>You cannot use [src] on [M] from that angle!</span>"
		return

	if(strangling)
		user << "<span class = 'warning'>You cannot use [src] on two people at once!</span>"
		return

	unwield(user)

	if(!istype(user, /mob/living/carbon/human)) // spap_hand is a proc of /mob/living, user is simply /mob
		return
	var/mob/living/carbon/human/U = user

	U.swap_hand() // For whatever reason the grab will not properly work if we don't have the free hand active.
	M.grabbedby(U, 1)
	var/obj/item/weapon/grab/G = U.get_active_hand()
	U.swap_hand()

	if(G && istype(G))
		G.state = GRAB_NECK
		G.hud.icon_state = "kill"
		G.hud.name = "kill"

	processing_objects.Add(src)
	strangling = M
	update_icon()

	playsound(src.loc, 'sound/weapons/cablecuff.ogg', 15, 1, -1)

	M.visible_message("<span class='danger'>[user] comes from behind and begins garroting [M] with the [src]!</span>", \
				  "<span class='userdanger'>[user]\ begins garroting you with the [src]! You are unable to speak!</span>", \
				  "You hear struggling and wire strain against flesh!")

	return

/obj/item/weapon/twohanded/garrote/process()

	if(!istype(loc, /mob/living/carbon/human))
		strangling = null
		update_icon()
		processing_objects.Remove(src)
		return

	var/mob/living/carbon/human/user = loc
	var/mob/living/carbon/human/target = strangling
	var/obj/item/weapon/grab/G

	if(src == user.r_hand && istype(user.l_hand, /obj/item/weapon/grab))
		G = user.l_hand

	else if(src == user.l_hand && istype(user.r_hand, /obj/item/weapon/grab))
		G = user.r_hand

	else
		user.visible_message("<span class='warning'>[user] loses his grip on [target]'s neck.</span>", \
				 "<span class='warning'>You lose your grip on [target]'s neck.</span>")

		strangling = null
		update_icon()
		processing_objects.Remove(src)

		return

	if(!G.affecting)
		user.visible_message("<span class='warning'>[user] loses his grip on [target]'s neck.</span>", \
				"<span class='warning'>You lose your grip on [target]'s neck.</span>")

		strangling = null
		update_icon()
		processing_objects.Remove(src)

		return

	strangling.silent += 1
	strangling.adjustOxyLoss(2)
	strangling.apply_damage(2, BRUTE, "head", sharp = 1, edge = 1, used_weapon = "Razor Wire") // Razor sharp wire, causes bleeding in the neck but only if the head is unarmored.

/obj/item/weapon/twohanded/garrote/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is wrapping the [src] around \his neck and pulling the handles! It looks like \he's trying to commit suicide.</span>")
	playsound(src.loc, 'sound/weapons/cablecuff.ogg', 15, 1, -1)
	return (OXYLOSS)