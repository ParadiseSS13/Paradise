/* Library Items
 *
 * Contains:
 *		Bookcase
 *		Book
 *		Barcode Scanner
 */


/*
 * Bookcase
 */

/obj/structure/bookcase
	name = "bookcase"
	icon = 'icons/obj/library.dmi'
	icon_state = "book-0"
	anchored = 1
	density = 1
	opacity = 1
	burn_state = FLAMMABLE
	burntime = 30
	var/health = 50
	var/tmp/busy = 0
	var/list/allowed_books = list(/obj/item/weapon/book, /obj/item/weapon/spellbook, /obj/item/weapon/storage/bible, /obj/item/weapon/tome) //Things allowed in the bookcase

/obj/structure/bookcase/initialize()
	..()
	for(var/obj/item/I in loc)
		if(is_type_in_list(I, allowed_books))
			I.forceMove(src)
	update_icon()

/obj/structure/bookcase/attackby(obj/O as obj, mob/user as mob, params)
	if(busy) //So that you can't mess with it while deconstructing
		return 1
	if(is_type_in_list(O, allowed_books))
		if(!user.drop_item())
			return
		O.forceMove(src)
		update_icon()
		return 1
	else if(istype(O, /obj/item/weapon/storage/bag/books))
		var/obj/item/weapon/storage/bag/books/B = O
		for(var/obj/item/T in B.contents)
			if(istype(T, /obj/item/weapon/book) || istype(T, /obj/item/weapon/spellbook) || istype(T, /obj/item/weapon/tome) || istype(T, /obj/item/weapon/storage/bible))
				B.remove_from_storage(T, src)
		to_chat(user, "<span class='notice'>You empty [O] into [src].</span>")
		update_icon()
		return 1
	else if(istype(O, /obj/item/weapon/wrench))
		user.visible_message("<span class='warning'>[user] starts disassembling \the [src].</span>", \
		"<span class='notice'>You start disassembling \the [src].</span>")
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		busy = 1

		if(do_after(user,50, target = src))
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 75, 1)
			user.visible_message("<span class='warning'>[user] disassembles \the [src].</span>", \
			"<span class='notice'>You disassemble \the [src].</span>")
			busy = 0
			density = 0
			qdel(src)
		else
			busy = 0
		return 1
	else if(istype(O, /obj/item/weapon/pen))
		var/newname = stripped_input(user, "What would you like to title this [name]?")
		if(newname)
			name = ("bookcase ([sanitize(newname)])")
		return 1
	else
		switch(O.damtype)
			if("fire")
				health -= O.force * 1
			if("brute")
				health -= O.force * 0.75
			else
		if(health <= 0)
			visible_message("<span class=warning>The bookcase is smashed apart!</span>")
			qdel(src)
		return ..()

/obj/structure/bookcase/attack_hand(var/mob/user as mob)
	if(contents.len)
		var/obj/item/weapon/book/choice = input("Which book would you like to remove from [src]?") as null|anything in contents
		if(choice)
			if(user.incapacitated() || user.lying || !Adjacent(user))
				return
			if(!user.get_active_hand())
				user.put_in_hands(choice)
			else
				choice.forceMove(get_turf(src))
			update_icon()

/obj/structure/bookcase/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/I in contents)
				qdel(I)
			qdel(src)
			return
		if(2.0)
			for(var/obj/item/I in contents)
				if(prob(50))
					qdel(I)
			qdel(src)
			return
		if(3.0)
			if(prob(50))
				qdel(src)
			return
	return

/obj/structure/bookcase/Destroy()
	for(var/i in 1 to 5)
		new /obj/item/stack/sheet/wood(get_turf(src))
	for(var/obj/item/I in contents)
		if(is_type_in_list(I, allowed_books))
			I.forceMove(get_turf(src))
	return ..()

/obj/structure/bookcase/update_icon()
	if(contents.len < 5)
		icon_state = "book-[contents.len]"
	else
		icon_state = "book-5"


/obj/structure/bookcase/manuals/medical
	name = "Medical Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/manual/medical_cloning(src)
		update_icon()


/obj/structure/bookcase/manuals/engineering
	name = "Engineering Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/manual/engineering_construction(src)
		new /obj/item/weapon/book/manual/engineering_particle_accelerator(src)
		new /obj/item/weapon/book/manual/engineering_hacking(src)
		new /obj/item/weapon/book/manual/engineering_guide(src)
		new /obj/item/weapon/book/manual/engineering_singularity_safety(src)
		new /obj/item/weapon/book/manual/robotics_cyborgs(src)
		update_icon()

/obj/structure/bookcase/manuals/research_and_development
	name = "R&D Manuals bookcase"

	New()
		..()
		new /obj/item/weapon/book/manual/research_and_development(src)
		update_icon()


/*
 * Book
 */
/obj/item/weapon/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = 3		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("bashed", "whacked", "educated")
	burn_state = FLAMMABLE

	var/dat			 // Actual page content
	var/due_date = 0 // Game time in 1/10th seconds
	var/author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title		 // The real name of the book.
	var/carved = 0	 // Has the book been hollowed out for use as a secret storage item?
	var/forbidden = 0     // Prevent ordering of this book. (0=no, 1=yes, 2=emag only)
	var/obj/item/store	// What's in the book?

/obj/item/weapon/book/attack_self(var/mob/user as mob)
	if(carved)
		if(store)
			to_chat(user, "<span class='notice'>[store] falls out of [title]!</span>")
			store.forceMove(get_turf(loc))
			store = null
			return
		else
			to_chat(user, "<span class='notice'>The pages of [title] have been cut out!</span>")
			return
	if(src.dat)
		user << browse("<TT><I>Penned by [author].</I></TT> <BR>" + "[dat]", "window=book")
		if(!isobserver(user))
			user.visible_message("[user] opens a book titled \"[title]\" and begins reading intently.")
		onclose(user, "book")
	else
		to_chat(user, "This book is completely blank!")

/obj/item/weapon/book/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(carved)
		if(!store)
			if(W.w_class < 3)
				user.drop_item()
				W.forceMove(src)
				store = W
				to_chat(user, "<span class='notice'>You put [W] in [title].</span>")
				return 1
			else
				to_chat(user, "<span class='notice'>[W] won't fit in [title].</span>")
				return 1
		else
			to_chat(user, "<span class='notice'>There's already something in [title]!</span>")
			return 1
	if(istype(W, /obj/item/weapon/pen))
		if(unique)
			to_chat(user, "These pages don't seem to take the ink well. Looks like you can't modify it.")
			return 1
		var/choice = input("What would you like to change?") in list("Title", "Contents", "Author", "Cancel")
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(stripped_input(usr, "Write a new title:"))
				if(!newtitle)
					to_chat(usr, "The title is invalid.")
					return 1
				else
					src.name = newtitle
					src.title = newtitle
			if("Contents")
				var/content = strip_html(input(usr, "Write your book's contents (HTML NOT allowed):"), MAX_BOOK_MESSAGE_LEN) as message|null
				if(!content)
					to_chat(usr, "The content is invalid.")
					return 1
				else
					src.dat += content
			if("Author")
				var/newauthor = stripped_input(usr, "Write the author's name:")
				if(!newauthor)
					to_chat(usr, "The name is invalid.")
					return 1
				else
					src.author = newauthor
		return 1
	else if(istype(W, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = W
		if(!scanner.computer)
			to_chat(user, "[W]'s screen flashes: 'No associated computer found!'")
		else
			switch(scanner.mode)
				if(0)
					scanner.book = src
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer.'")
				if(1)
					scanner.book = src
					scanner.computer.buffer_book = src.name
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Book title stored in associated computer buffer.'")
				if(2)
					scanner.book = src
					for(var/datum/borrowbook/b in scanner.computer.checkouts)
						if(b.bookname == src.name)
							scanner.computer.checkouts.Remove(b)
							to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Book has been checked in.'")
							return 1
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. No active check-out record found for current title.'")
				if(3)
					scanner.book = src
					for(var/obj/item/weapon/book in scanner.computer.inventory)
						if(book == src)
							to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Title already present in inventory, aborting to avoid duplicate entry.'")
							return 1
					scanner.computer.inventory.Add(src)
					to_chat(user, "[W]'s screen flashes: 'Book stored in buffer. Title added to general inventory.'")
		return 1
	else if(istype(W, /obj/item/weapon/kitchen/knife) || iswirecutter(W))
		if(carved)
			return 1
		to_chat(user, "<span class='notice'>You begin to carve out [title].</span>")
		if(do_after(user, 30, target = src))
			to_chat(user, "<span class='notice'>You carve out the pages from [title]! You didn't want to read it anyway.</span>")
			carved = 1
			return 1
	else
		return ..()


/*
 * Barcode Scanner
 */
/obj/item/weapon/barcodescanner
	name = "barcode scanner"
	icon = 'icons/obj/library.dmi'
	icon_state ="scanner"
	throw_speed = 1
	throw_range = 5
	w_class = 1
	var/obj/machinery/computer/library/checkout/computer // Associated computer - Modes 1 to 3 use this
	var/obj/item/weapon/book/book	 //  Currently scanned book
	var/mode = 0 					// 0 - Scan only, 1 - Scan and Set Buffer, 2 - Scan and Attempt to Check In, 3 - Scan and Attempt to Add to Inventory

	attack_self(mob/user as mob)
		mode += 1
		if(mode > 3)
			mode = 0
		to_chat(user, "[src] Status Display:")
		var/modedesc
		switch(mode)
			if(0)
				modedesc = "Scan book to local buffer."
			if(1)
				modedesc = "Scan book to local buffer and set associated computer buffer to match."
			if(2)
				modedesc = "Scan book to local buffer, attempt to check in scanned book."
			if(3)
				modedesc = "Scan book to local buffer, attempt to add book to general inventory."
			else
				modedesc = "ERROR"
		to_chat(user, " - Mode [mode] : [modedesc]")
		if(src.computer)
			to_chat(user, "<font color=green>Computer has been associated with this unit.</font>")
		else
			to_chat(user, "<font color=red>No associated computer found. Only local scans will function properly.</font>")
		to_chat(user, "\n")
