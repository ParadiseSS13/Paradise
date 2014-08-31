
/*
	Objects used to construct computers, and objects that can be inserted into them, etc.

	TODO:
	* Synthesizer part (toybox, injectors, etc)
*/



/obj/item/part/computer
	name = "computer part"
	desc = "Holy jesus you donnit now"
	gender = PLURAL
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "hdd1"
	w_class = 2.0

	var/emagged = 0
	crit_fail = 0

	// the computer that this device is attached to
	var/obj/machinery/computer3/computer

	// If the computer is attacked by an item it will reference this to decide which peripheral(s) are affected.
	var/list/attackby_types	= list()
	proc/allow_attackby(var/obj/item/I as obj,var/mob/user as mob)

		for(var/typekey in attackby_types)
			if(istype(I,typekey))
				return 1
		return 0

	proc/init(var/obj/machinery/computer/target)
		computer = target
		// continue to handle all other type-specific procedures

/*
	Below are all the miscellaneous components
	For storage drives, see storage.dm
	For networking parts, see
*/

/obj/item/part/computer/ai_holder
	name = "intelliCard computer module"
	desc = "Contains a specialized nacelle for dealing with highly sensitive equipment without interference."

	attackby_types = list(/obj/item/device/aicard)

	var/mob/living/silicon/ai/occupant	= null
	var/busy = 0

	// Ninja gloves check
	attack_hand(mob/user as mob)
		if(ishuman(user) && istype(user:gloves, /obj/item/clothing/gloves/space_ninja) && user:gloves:candrain && !user:gloves:draining)
			if(user:wear_suit:s_control)
				user:wear_suit.transfer_ai("AIFIXER","NINJASUIT",src,user)
			else
				user << "\red <b>ERROR</b>: \black Remote access channel disabled."
			return
		..()

	attackby(obj/I as obj,mob/user as mob)
		if(computer && !computer.stat)
			if(istype(I, /obj/item/device/aicard))
				I:transfer_ai("AIFIXER","AICARD",src,user)
				if(computer.program)
					computer.program.update_icon()
				computer.update_icon()
				return
		..()

/*
	ID computer cardslot - reading and writing slots
*/

/obj/item/part/computer/cardslot
	name = "magnetic card slot"
	desc = "Contains a slot for reading magnetic swipe cards."

	var/obj/item/weapon/card/reader	= null
	var/obj/item/weapon/card/writer	= null	// so that you don't need to typecast dual cardslots, but pretend it's not here
											// alternately pretend they did it to save money on manufacturing somehow
	var/dualslot = 0 // faster than typechecking
	attackby_types = list(/obj/item/weapon/card)

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		if(istype(I,/obj/item/weapon/card))
			insert(I)
			return
		..(I,user)

	proc/insert(var/obj/item/weapon/card/card)
		if(!computer)
			return 0
		if(reader != null)
			usr << "There is already something in the slot!"
			return 0
		if(istype(card,/obj/item/weapon/card/emag)) // emag reader slot
			usr << "You insert \the [card], and the computer grinds, sparks, and beeps.  After a moment, the card ejects itself."
			computer.emagged = 1
			return 1
		var/mob/living/L = usr
		L.drop_item()
		card.loc = src
		reader = card

	proc/remove()
		reader.loc = loc
		var/mob/living/carbon/human/user = usr
		if(istype(user) && !user.get_active_hand())
			user.put_in_hands(reader)
		reader = null

	// Authorizes the user based on the computer's requirements
	proc/authenticate()
		return computer.check_access(reader)

	proc/addfile(var/datum/file/F)
		if(!dualslot || !istype(writer,/obj/item/weapon/card/data))
			return 0
		var/obj/item/weapon/card/data/D = writer
		if(D.files.len > 3)
			return 0
		D.files += F
		return 1

/obj/item/part/computer/cardslot/dual
	name	= "magnetic card reader"
	desc	= "Contains slots for inserting magnetic swipe cards for reading and writing."
	dualslot = 1

	insert(var/obj/item/weapon/card/card,var/slot = 0)
		if(!computer)
			return 0

		if(istype(card,/obj/item/weapon/card/emag) && !reader) // emag reader slot
			usr.visible_message("[computer]'s screen flickers for a moment.","You insert \the [card].  After a moment, the card ejects itself, and [computer] beeps.","[computer] beeps.")
			computer.emagged = 1
			return 1

		if(slot == 1)				// 1: writer
			if(writer != null)
				usr << "There's already a card in that slot!"
				return 0
			var/mob/living/L = usr
			L.drop_item()
			card.loc = src
			writer = card
			return 1
		else if(slot == 2)			// 2: reader
			if(reader != null)
				usr << "There's already a card in that slot!"
				return 0
			var/mob/living/L = usr
			L.drop_item()
			card.loc = src
			reader = card
			return 1
		else						// 0: auto
			if(reader && writer)
				usr << "Both slots are full!"
				return 0
			var/mob/living/L = usr
			L.drop_item()
			card.loc = src
			if(reader)
				writer = card
				return 1
			if(istype(card,/obj/item/weapon/card/id) && !(access_change_ids in card:access) && !writer) // not authorized
				writer = card
				return 1
			if(!reader)
				reader = card
				return 1
			return 0

	remove(var/obj/item/weapon/card/card)
		if(card != reader && card != writer)
			return

		if(card == reader) reader = null
		if(card == writer) writer = null
		card.loc = loc

		var/mob/living/carbon/human/user = usr
		if(ishuman(user) && !user.get_active_hand())
			user.put_in_hands(card)


