
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
	w_class = 2

	var/emagged = 0
	crit_fail = 0

	// the computer that this device is attached to
	var/obj/machinery/computer3/computer

	// If the computer is attacked by an item it will reference this to decide which peripheral(s) are affected.
	var/list/attackby_types	= list()
	proc/allow_attackby(var/obj/item/I as obj,var/mob/user as mob, params)

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

	attackby(obj/I as obj,mob/user as mob, params)
		if(computer && !computer.stat)
			if(istype(I, /obj/item/device/aicard))
				I:transfer_ai("AIFIXER","AICARD",src,user)
				if(computer.program)
					computer.program.update_icon()
				computer.update_icon()
				computer.occupant = occupant
		..()
		return

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

	emag_act(user as mob)
		if(!writer)
			to_chat(usr, "You insert \the card, and the computer grinds, sparks, and beeps.  After a moment, the card ejects itself.")
			computer.emagged = 1
			return 1
		else
			to_chat(usr, "You are unable to insert \the card, as the reader slot is occupied")
			return 0

	attackby(var/obj/item/I as obj, var/mob/user as mob, params)
		if(istype(I,/obj/item/weapon/card))
			insert(I)
			return
		..(I,user)

	// cardslot.insert(card, slot)
	// card: The card obj you want to insert (usually your ID)
	// slot: Which slot to insert into (1: reader, 2: writer, 3: auto), 3 default
	proc/insert(var/obj/item/weapon/card/card, var/slot = 3)
		if(!computer)
			return 0
		// This shouldn't happen, just in case..
		if(slot == 2 && !dualslot)
			to_chat(usr, "This device has only one card slot")
			return 0

		var/mob/living/L = usr
		switch(slot)
			if(1)
				if(equip_to_reader(card, L))
					to_chat(usr, "You insert the card into reader slot")
				else
					to_chat(usr, "There is already something in the reader slot.")
			if(2)
				if(equip_to_writer(card, L))
					to_chat(usr, "You insert the card into writer slot")
				else
					to_chat(usr, "There is already something in the reader slot.")
			if(3)
				if(equip_to_reader(card, L))
					to_chat(usr, "You insert the card into reader slot")
				else if(equip_to_writer(card, L) && dualslot)
					to_chat(usr, "You insert the card into writer slot")
				else if(dualslot)
					to_chat(usr, "There is already something in both slots.")
				else
					to_chat(usr, "There is already something in the reader slot.")

	// Usage of insert() preferred, as it also tells result to the user.
	proc/equip_to_reader(var/obj/item/weapon/card/card, var/mob/living/L)
		if(!reader)
			L.drop_item()
			card.loc = src
			reader = card
			return 1
		return 0

	proc/equip_to_writer(var/obj/item/weapon/card/card, var/mob/living/L)
		if(!writer && dualslot)
			L.drop_item()
			card.loc = src
			writer = card
			return 1
		return 0

	// cardslot.remove(slot)
	// slot: Which slot to remove card(s) from (1: reader only, 2: writer only, 3: both [works even with one card], 4: reader and if empty then writer ), 3 default
	proc/remove(var/slot = 3)
		var/mob/living/L = usr
		switch(slot)
			if(1)
				if(remove_reader(L))
					to_chat(L, "You remove the card from reader slot")
				else
					to_chat(L, "There is no card in the reader slot")
			if(2)
				if(remove_writer(L))
					to_chat(L, "You remove the card from writer slot")
				else
					to_chat(L, "There is no card in the writer slot")
			if(3)
				if(remove_reader(L))
					if(remove_writer(L))
						to_chat(L, "You remove cards from both slots")
					else
						to_chat(L, "You remove the card from reader slot")
				else
					if(remove_writer(L))
						to_chat(L, "You remove the card from writer slot")
					else
						to_chat(L, "There are no cards in both slots")
			if(4)
				if(!remove_reader(L))
					if(remove_writer(L))
						to_chat(L, "You remove the card from writer slot")
					else if(!dualslot)
						to_chat(L, "There is no card in the reader slot")
					else
						to_chat(L, "There are no cards in both slots")
				else
					to_chat(L, "You remove the card from reader slot")


	proc/remove_reader(var/mob/living/L)
		if(reader)
			reader.loc = loc
			if(istype(L) && !L.get_active_hand())
				L.put_in_hands(reader)
			else
				reader.loc = computer.loc
			reader = null
			return 1
		return 0

	proc/remove_writer(var/mob/living/L)
		if(writer && dualslot)
			writer.loc = loc
			if(istype(L) && !L.get_active_hand())
				L.put_in_hands(writer)
			else
				writer.loc = computer.loc
			writer = null
			return 1
		return 0




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


	/*
	// Atlantis: Reworked card manipulation a bit.
	// No need for separated code for dual and single readers.
	// Both is handled in single-slot reader code now, thanks to the "dualslot" var.
	// Leaving this code here if someone wants to somehow use it, just uncomment.

	insert(var/obj/item/weapon/card/card,var/slot = 0)
		if(!computer)
			return 0

		if(istype(card,/obj/item/weapon/card/emag) && !reader) // emag reader slot
			usr.visible_message("[computer]'s screen flickers for a moment.","You insert \the [card].  After a moment, the card ejects itself, and [computer] beeps.","[computer] beeps.")
			computer.emagged = 1
			return 1

		if(slot == 1)				// 1: writer
			if(writer != null)
				to_chat(usr, "There's already a card in that slot!")
				return 0
			var/mob/living/L = usr
			L.drop_item()
			card.loc = src
			writer = card
			return 1
		else if(slot == 2)			// 2: reader
			if(reader != null)
				to_chat(usr, "There's already a card in that slot!")
				return 0
			var/mob/living/L = usr
			L.drop_item()
			card.loc = src
			reader = card
			return 1
		else						// 0: auto
			if(reader && writer)
				to_chat(usr, "Both slots are full!")
				return 0
			var/mob/living/L = usr
			L.drop_item()
			card.loc = src
			if(reader)
				writer = card
				computer.updateUsrDialog()
				return 1
			if(istype(card,/obj/item/weapon/card/id) && !(access_change_ids in card:access) && !writer) // not authorized
				writer = card
				computer.updateUsrDialog()
				return 1
			if(!reader)
				reader = card
				computer.updateUsrDialog()
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
		else
			card.loc = computer.loc
*/


