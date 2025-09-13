/obj/structure/pondering_orb
	name = "pondering orb"
	desc = "Ponder your plans for the station using this farsight artefact."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scrying_orb" //TODO : Placeholder sprite
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/mob/dead/observer/ghost // owners ghost when active

/obj/structure/pondering_orb/attack_hand(mob/user)
	ADD_TRAIT(user, SCRYING, SCRYING_ORB)
	user.visible_message("<span class='notice'>[user] stares into [src], [user.p_their()] eyes glazing over.</span>",
					"<span class='danger'>You stare into [src], you can see the entire universe!</span>")
	ghost = user.ghostize(ghost_name = "Magic Spirit of [user.name]", ghost_color = COLOR_BLUE)
	while(!QDELETED(user))
		if(user.key || QDELETED(src))
			user.visible_message("<span class='notice'>[user] blinks, returning to the world around [user.p_them()].</span>",
								"<span class='danger'>You look away from [src].</span>")
			break
		if(!Adjacent(user))
			user.grab_ghost()
			user.visible_message("<span class='notice'>[user]'s focus is forced away from [src].</span>",
								"<span class='userdanger'>Your vision is ripped away from [src].</span>")
			break
		sleep(5)
	if(QDELETED(user))
		return
	user.remove_atom_colour(ADMIN_COLOUR_PRIORITY, COLOR_BLUE)
	REMOVE_TRAIT(user, SCRYING, SCRYING_ORB)
