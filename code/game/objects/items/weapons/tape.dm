/obj/item/stack/tape_roll
	name = "tape roll"
	desc = "A roll of sticky tape. Possibly for taping ducks... or was that ducts?"
	icon = 'icons/obj/tapes.dmi'
	icon_state = "taperoll"
	singular_name = "tape roll"
	w_class = WEIGHT_CLASS_TINY
	amount = 25
	max_amount = 25

/obj/item/stack/tape_roll/New(loc, amount=null)
	..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/stack/tape_roll/attack(mob/living/carbon/human/M, mob/living/user)
	if(!istype(M)) //What good is a duct tape mask if you are unable to speak?
		return
	if(M.wear_mask)
		to_chat(user, "Remove [M.p_their()] mask first!")
		return
	if(amount < 2)
		to_chat(user, "You'll need more tape for this!")
		return
	if(!M.check_has_mouth())
		to_chat(user, "[M.p_they(TRUE)] [M.p_have()] no mouth to tape over!")
		return
	user.visible_message("<span class='warning'>[user] is taping [M]'s mouth closed!</span>",
	"<span class='notice'>You try to tape [M == user ? "your own" : "[M]'s"] mouth shut!</span>",
	"<span class='warning'>You hear tape ripping.</span>")
	if(!do_after(user, 50, target = M))
		return
	if(!use(2))
		to_chat(user, "<span class='notice'>You don't have enough tape!</span>")
		return
	if(M.wear_mask)
		to_chat(user, "<span class='notice'>[M == user ? user : M]'s mouth is already covered!</span>")
		return
	user.visible_message("<span class='warning'>[user] tapes [M]'s mouth shut!</span>",
	"<span class='notice'>You cover [M == user ? "your own" : "[M]'s"] mouth with a piece of duct tape.[M == user ? null : " That will shut them up."]</span>")
	var/obj/item/clothing/mask/muzzle/G = new /obj/item/clothing/mask/muzzle/tapegag
	M.equip_to_slot(G, SLOT_HUD_WEAR_MASK)
	G.add_fingerprint(user)

/obj/item/stack/tape_roll/update_icon_state()
	var/amount = get_amount()
	if((amount <= 2) && (amount > 0))
		icon_state = "taperoll"
	if((amount <= 4) && (amount > 2))
		icon_state = "taperoll-2"
	if((amount <= 6) && (amount > 4))
		icon_state = "taperoll-3"
	if(amount > 6)
		icon_state = "taperoll-4"
	else
		icon_state = "taperoll-4"

/*
	else if(istype(I, /obj/item/stack/tape_roll))
		if(isstorage(src)) //Don't tape the bag if we can put the duct tape inside it instead
			var/obj/item/storage/bag = src
			if(bag.can_be_inserted(I))
				return ..()
		var/obj/item/stack/tape_roll/TR = I
		var/list/clickparams = params2list(params)
		var/x_offset = text2num(clickparams["icon-x"])
		var/y_offset = text2num(clickparams["icon-y"])
		if(GetComponent(/datum/component/ducttape))
			to_chat(user, "<span class='notice'>[src] already has some tape attached!</span>")
			return
		if(TR.use(1))
			to_chat(user, "<span class='notice'>You apply some tape to [src].</span>")
			AddComponent(/datum/component/ducttape, src, user, x_offset, y_offset)
			anchored = TRUE
			user.transfer_fingerprints_to(src)
		else
			to_chat(user, "<span class='notice'>You don't have enough tape to do that!</span>")
*/

/obj/item/stack/sticky_tape
	name = "sticky tape"
	singular_name = "sticky tape"
	desc = "Used for sticking to things for sticking said things to people."
	icon = 'icons/obj/tapes.dmi'
	icon_state = "taperoll"
	var/prefix = "sticky"
	w_class = WEIGHT_CLASS_TINY
	flags = NOBLUDGEON
	amount = 5
	max_amount = 5
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/sticky_tape
	var/list/conferred_embed = EMBED_HARMLESS
	///The tape type you get when ripping off a piece of tape.
	var/obj/tape_gag = /obj/item/clothing/mask/muzzle/tapegag

/obj/item/stack/sticky_tape/Initialize(mapload)
	. = ..()

/obj/item/stack/sticky_tape/update_icon_state()
	var/amount = get_amount()
	if((amount <= 2) && (amount > 0))
		icon_state = "taperoll"
	if((amount <= 4) && (amount > 2))
		icon_state = "taperoll-2"
	if((amount <= 6) && (amount > 4))
		icon_state = "taperoll-3"
	if(amount > 6)
		icon_state = "taperoll-4"
	else
		icon_state = "taperoll-4"

/obj/item/stack/sticky_tape/attack_hand(mob/user, list/modifiers)
	var/obj/item/held_item = user.get_inactive_hand()
	if(held_item && held_item == src)
		if(zero_amount())
			return
		playsound(user, 'sound/items/duct_tape_rip.ogg', 50, TRUE)
		if(!do_after(user, 1 SECONDS))
			return
		var/new_tape_gag = new tape_gag(src)
		user.put_in_hands(new_tape_gag)
		use(1)
		to_chat(user, span_notice("You rip off a piece of tape."))
		playsound(user, 'sound/items/duct_tape_snap.ogg', 50, TRUE)
		return TRUE
	return ..()

/obj/item/stack/sticky_tape/examine(mob/user)
	. = ..()
	. += "[span_notice("You could rip a piece off by using an empty hand.")]"

/obj/item/stack/sticky_tape/afterattack(obj/item/target, mob/living/user, proximity)
	if(!proximity)
		return

	if(!istype(target))
		return

	if(target.embedding && target.embedding == conferred_embed)
		to_chat(user, span_warning("[target] is already coated in [src]!"))
		return .

	user.visible_message(span_notice("[user] begins wrapping [target] with [src]."), span_notice("You begin wrapping [target] with [src]."))
	playsound(user, 'sound/items/duct_tape_rip.ogg', 50, TRUE)

	if(do_after(user, 3 SECONDS, target=target))
		playsound(user, 'sound/items/duct_tape_snap.ogg', 50, TRUE)
		use(1)

		if(target.embedding && target.embedding == conferred_embed)
			to_chat(user, span_warning("[target] is already coated in [src]!"))
			return .

		target.embedding = conferred_embed
		target.update_embedding()
		to_chat(user, span_notice("You finish wrapping [target] with [src]."))
		target.name = "[prefix] [target.name]"

		if(isgrenade(target))
			var/obj/item/grenade/sticky_bomb = target
			sticky_bomb.sticky = TRUE

	return .

/obj/item/stack/sticky_tape/super
	name = "super sticky tape"
	singular_name = "super sticky tape"
	desc = "Quite possibly the most mischevious substance in the galaxy. Use with extreme lack of caution."
	prefix = "super sticky"
	conferred_embed = EMBED_HARMLESS_SUPERIOR
	merge_type = /obj/item/stack/sticky_tape/super
	tape_gag = /obj/item/clothing/mask/muzzle/tapegag/super

/obj/item/stack/sticky_tape/pointy
	name = "pointy tape"
	singular_name = "pointy tape"
	desc = "Used for sticking to things for sticking said things inside people."
	icon_state = "tape_spikes"
	prefix = "pointy"
	conferred_embed = EMBED_POINTY
	merge_type = /obj/item/stack/sticky_tape/pointy
	tape_gag = /obj/item/clothing/mask/muzzle/tapegag/pointy

/obj/item/stack/sticky_tape/pointy/super
	name = "super pointy tape"
	singular_name = "super pointy tape"
	desc = "You didn't know tape could look so sinister. Welcome to Space Station 13."
	prefix = "super pointy"
	conferred_embed = EMBED_POINTY_SUPERIOR
	merge_type = /obj/item/stack/sticky_tape/pointy/super
	tape_gag = /obj/item/clothing/mask/muzzle/tapegag/pointy/super
