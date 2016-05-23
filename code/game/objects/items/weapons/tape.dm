/obj/item/stack/tape_roll
	name = "tape roll"
	desc = "A roll of sticky tape. Possibly for taping ducks... or was that ducts?"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "taperoll"
	w_class = 1
	amount = 10
	max_amount = 10

/obj/item/stack/tape_roll/New(var/loc, var/amount=null)
	..()

	update_icon()

/obj/item/stack/tape_roll/attack(mob/living/carbon/human/M as mob, mob/living/user as mob)
	if(M.wear_mask)
		to_chat(user, "Remove their mask first!")
	else if(amount < 2)
		to_chat(user, "You'll need more tape for this!")
	else if(!M.check_has_mouth())
		to_chat(user, "They have no mouth to tape over!")
	else
		if(M == user)
			to_chat(user, "You try to tape your own mouth shut.")
		else
			to_chat(user, "You try to tape [M]'s mouth shut.")
			M.visible_message("<span class='warning'>[user] tries to tape [M]'s mouth closed!</span>")
		if(do_after(user, 50, target = M))
			if(M == user)
				to_chat(user, "You cover your own mouth with a piece of duct tape.")
			else
				to_chat(user, "You cover [M]'s mouth with a piece of duct tape. That will shut them up!")
				M.visible_message("<span class='warning'>[user] tapes [M]'s mouth shut!</span>")
			var/obj/item/clothing/mask/muzzle/G = new /obj/item/clothing/mask/muzzle/tapegag
			M.equip_to_slot(G, slot_wear_mask)
			G.add_fingerprint(user)
			amount = amount - 2
	if(amount <= 0)
		user.unEquip(src, 1)
		qdel(src)



/* -- Disabled for now until it has a use --
/obj/item/stack/tape_roll/attack_self(mob/user as mob)
	to_chat(user, "You remove a length of tape from [src].")

	var/obj/item/weapon/ducttape/tape = new()
	user.put_in_hands(tape)
*/

/obj/item/stack/tape_roll/proc/stick(var/obj/item/weapon/W, mob/user)
	if(!istype(W, /obj/item/weapon/paper))
		return

	user.unEquip(W)
	var/obj/item/weapon/ducttape/tape = new(get_turf(src))
	tape.attach(W)
	user.put_in_hands(tape)

/obj/item/stack/tape_roll/update_icon()
	var/amount = get_amount()
	if((amount <= 2) && (amount > 0))
		icon_state = "taperoll"
	if((amount <= 4) && (amount > 2))
		icon_state = "taperoll-2"
	if((amount <= 6) && (amount > 4))
		icon_state = "taperoll-3"
	if((amount > 6))
		icon_state = "taperoll-4"
	else
		icon_state = "taperoll-4"

/obj/item/weapon/ducttape
	name = "tape"
	desc = "A piece of sticky tape."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "tape"
	w_class = 1
	layer = 4
	anchored = 1 //it's sticky, no you cant move it

	var/obj/item/weapon/stuck = null

/obj/item/weapon/ducttape/New()
	..()
	flags |= NOBLUDGEON

/obj/item/weapon/ducttape/examine(mob/user)
	return stuck.examine(user)

/obj/item/weapon/ducttape/proc/attach(var/obj/item/weapon/W)
	stuck = W
	W.forceMove(src)
	icon_state = W.icon_state + "_taped"
	name = W.name + " (taped)"
	overlays = W.overlays

/obj/item/weapon/ducttape/attack_self(mob/user)
	if(!stuck)
		return

	to_chat(user, "You remove \the [initial(name)] from [stuck].")

	user.unEquip(src)
	stuck.forceMove(get_turf(src))
	user.put_in_hands(stuck)
	stuck = null
	overlays = null
	qdel(src)

/obj/item/weapon/ducttape/afterattack(var/A, mob/user, flag, params)
	if(!in_range(user, A) || istype(A, /obj/machinery/door) || !stuck)
		return

	var/turf/target_turf = get_turf(A)
	var/turf/source_turf = get_turf(user)

	var/dir_offset = 0
	if(target_turf != source_turf)
		dir_offset = get_dir(source_turf, target_turf)
		if(!(dir_offset in cardinal))
			to_chat(user, "You cannot reach that from here.")// can only place stuck papers in cardinal directions, to
			return											 // reduce papers around corners issue.

	user.unEquip(src)
	forceMove(source_turf)

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			pixel_x = text2num(mouse_control["icon-x"]) - 16
			if(dir_offset & EAST)
				pixel_x += 32
			else if(dir_offset & WEST)
				pixel_x -= 32
		if(mouse_control["icon-y"])
			pixel_y = text2num(mouse_control["icon-y"]) - 16
			if(dir_offset & NORTH)
				pixel_y += 32
			else if(dir_offset & SOUTH)
				pixel_y -= 32
