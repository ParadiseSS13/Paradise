// MARK: CHAIN OF COMMAND
/obj/item/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	origin_tech = "combat=5"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/slash.ogg' //pls replace
	needs_permit = TRUE

/obj/item/chainofcommand/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='suicide'>[user] is strangling [user.p_themselves()] with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS

// MARK: ICE PICK
/obj/item/icepick
	name = "ice pick"
	desc = "Used for chopping ice. Also excellent for mafia esque murders."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "icepick"
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("stabbed", "jabbed", "iced,")
	needs_permit = TRUE

// MARK: CANDY SWORD
/obj/item/candy_sword
	name = "candy cane sword"
	desc = "A large candy cane with a sharpened point. Definitely too dangerous for schoolchildren."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "candy_sword"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	force = 10
	throwforce = 7
	attack_verb = list("slashed", "stabbed", "sliced", "caned")
	needs_permit = TRUE

// MARK: FLYSWATTER
/obj/item/flyswatter
	name = "flyswatter"
	desc = "Useful for killing insects of all sizes."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "flyswatter"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	force = 1
	throwforce = 1
	attack_verb = list("swatted", "smacked")
	hitsound = 'sound/effects/snap.ogg'
	w_class = WEIGHT_CLASS_SMALL
	needs_permit = TRUE
	//Things in this list will be instantly splatted.  Flyman weakness is handled in the flyman species weakness proc.
	var/list/strong_against

/obj/item/flyswatter/Initialize(mapload)
	. = ..()
	strong_against = typecacheof(list(
					/mob/living/basic/bee/,
					/mob/living/basic/butterfly,
					/mob/living/basic/cockroach,
					/obj/item/queen_bee))
	strong_against -= /mob/living/basic/bee/syndi // Syndi-bees have special anti-flyswatter tech installed

/obj/item/flyswatter/attack__legacy__attackchain(mob/living/M, mob/living/user, def_zone)
	. = ..()
	if(is_type_in_typecache(M, strong_against))
		new /obj/effect/decal/cleanable/insectguts(M.drop_location())
		user.visible_message("<span class='warning'>[user] splats [M] with [src].</span>",
			"<span class='warning'>You splat [M] with [src].</span>",
			"<span class='warning'>You hear a splat.</span>")
		if(isliving(M))
			var/mob/living/bug = M
			bug.death(TRUE)
		if(!QDELETED(M))
			qdel(M)
