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
	resistance_flags = FLAMMABLE
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 0)
	var/tmp/busy = 0
	var/list/allowed_books = list(/obj/item/book, /obj/item/spellbook, /obj/item/storage/bible, /obj/item/tome) //Things allowed in the bookcase

/obj/structure/bookcase/Initialize()
	..()
	for(var/obj/item/I in loc)
		if(is_type_in_list(I, allowed_books))
			I.forceMove(src)
	update_icon()

/obj/structure/bookcase/attackby(obj/item/O as obj, mob/user as mob, params)
	if(busy) //So that you can't mess with it while deconstructing
		return TRUE
	if(is_type_in_list(O, allowed_books))
		if(!user.drop_item())
			return
		O.forceMove(src)
		update_icon()
		return TRUE
	else if(istype(O, /obj/item/storage/bag/books))
		var/obj/item/storage/bag/books/B = O
		for(var/obj/item/T in B.contents)
			if(istype(T, /obj/item/book) || istype(T, /obj/item/spellbook) || istype(T, /obj/item/tome) || istype(T, /obj/item/storage/bible))
				B.remove_from_storage(T, src)
		to_chat(user, "<span class='notice'>You empty [O] into [src].</span>")
		update_icon()
		return TRUE
	else if(istype(O, /obj/item/wrench))
		user.visible_message("<span class='warning'>[user] starts disassembling \the [src].</span>", \
		"<span class='notice'>You start disassembling \the [src].</span>")
		playsound(get_turf(src), O.usesound, 50, 1)
		busy = TRUE

		if(do_after(user, 50 * O.toolspeed, target = src))
			playsound(get_turf(src), O.usesound, 75, 1)
			user.visible_message("<span class='warning'>[user] disassembles \the [src].</span>", \
			"<span class='notice'>You disassemble \the [src].</span>")
			busy = FALSE
			density = 0
			deconstruct(TRUE)
		else
			busy = FALSE
		return TRUE
	else if(istype(O, /obj/item/pen))
		rename_interactive(user, O)
		return TRUE
	else
		return ..()

/obj/structure/bookcase/attack_hand(mob/user as mob)
	if(contents.len)
		var/obj/item/book/choice = input("Which book would you like to remove from [src]?") as null|anything in contents
		if(choice)
			if(user.incapacitated() || user.lying || !Adjacent(user))
				return
			if(!user.get_active_hand())
				user.put_in_hands(choice)
			else
				choice.forceMove(get_turf(src))
			update_icon()

/obj/structure/bookcase/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/wood(loc, 5)
	for(var/obj/item/I in contents)
		if(is_type_in_list(I, allowed_books))
			I.forceMove(get_turf(src))
	qdel(src)

/obj/structure/bookcase/update_icon()
	if(contents.len < 5)
		icon_state = "book-[contents.len]"
	else
		icon_state = "book-5"


/obj/structure/bookcase/manuals/medical
	name = "Medical Manuals bookcase"

/obj/structure/bookcase/manuals/medical/Initialize()
	. = ..()
	new /obj/item/book/manual/medical_cloning(src)
	update_icon()


/obj/structure/bookcase/manuals/engineering
	name = "Engineering Manuals bookcase"

/obj/structure/bookcase/manuals/engineering/Initialize()
	. = ..()
	new /obj/item/book/manual/engineering_construction(src)
	new /obj/item/book/manual/engineering_particle_accelerator(src)
	new /obj/item/book/manual/engineering_hacking(src)
	new /obj/item/book/manual/engineering_guide(src)
	new /obj/item/book/manual/engineering_singularity_safety(src)
	new /obj/item/book/manual/robotics_cyborgs(src)
	update_icon()

/obj/structure/bookcase/manuals/research_and_development
	name = "R&D Manuals bookcase"

/obj/structure/bookcase/manuals/research_and_development/Initialize()
	. = ..()
	new /obj/item/book/manual/research_and_development(src)
	update_icon()

/obj/structure/bookcase/sop
	name = "bookcase (Standard Operating Procedures)"

/obj/structure/bookcase/sop/Initialize()
	. = ..()
	new /obj/item/book/manual/sop_command(src)
	new /obj/item/book/manual/sop_engineering(src)
	new /obj/item/book/manual/sop_general(src)
	new /obj/item/book/manual/sop_legal(src)
	new /obj/item/book/manual/sop_medical(src)
	new /obj/item/book/manual/sop_science(src)
	new /obj/item/book/manual/sop_security(src)
	new /obj/item/book/manual/sop_service(src)
	new /obj/item/book/manual/sop_supply(src)
	update_icon()

/*
 * Book
 */
/obj/item/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	force = 2
	w_class = WEIGHT_CLASS_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("bashed", "whacked")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound =  'sound/items/handling/book_pickup.ogg'

	var/title		 // The real name of the book.
	var/dat			 // Actual page content
	var/summary
	var/author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/rating       //Book Rating - Only Applicable to books that are printed from database

	///0 - Normal book, 1 - Special Book
	var/unique = 0
	///Prevents book from being uploaded - For all printed books
	var/copyright = FALSE

	var/libraryid // Game time in 1/10th seconds
	var/due_date

	var/carved = FALSE	 // Has the book been hollowed out for use as a secret storage item?
	var/obj/item/store	// What's in the book?
	/// Book DRM. If this var is TRUE, it cannot be scanned and re-uploaded

/obj/item/book/attack_self(mob/user as mob)
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

/obj/item/book/attackby(obj/item/W as obj, mob/user as mob, params)
	if(carved)
		if(!store)
			if(W.w_class < WEIGHT_CLASS_NORMAL)
				user.drop_item()
				W.forceMove(src)
				store = W
				to_chat(user, "<span class='notice'>You put [W] in [title].</span>")
				return
			else
				to_chat(user, "<span class='notice'>[W] won't fit in [title].</span>")
				return
		else
			to_chat(user, "<span class='notice'>There's already something in [title]!</span>")
			return
	if(istype(W, /obj/item/pen))
		if(unique)
			to_chat(user, "These pages don't seem to take the ink well. Looks like you can't modify it.")
			return
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
				var/content = strip_html(input(usr, "Write your book's contents (HTML NOT allowed):") as message|null, MAX_BOOK_MESSAGE_LEN)
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
	else if(istype(W, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/scanner = W
		if(!scanner.check_connection(user))
			return
		switch(scanner.mode) // 0 - Scan only, 1 - Attempt to Add to Inventory, 2 - Checkout Book, 3 - Check In Book
			if(0)
				scanner.computer.select_book(src)
				playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
				to_chat(user, "[scanner]'s screen flashes: 'Book selected in library computer.'")
			if(1)
				if(scanner.computer.inventoryAdd(src))
					playsound(src, 'sound/items/scannerbeep.ogg', 15, TRUE)
					to_chat(user, "[scanner]'s screen flashes: 'Title added to general inventory.'")
				else
					playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
					to_chat(user, "[scanner]'s screen flashes: 'Title already in general inventory.'")
			if(2)
				var/confirm = alert("Are you sure you want to checkout [src] to [scanner.computer.patron_name]?", "Confirm Checkout", "Yes", "No")
				if(confirm == "No")
					return
				if(scanner.computer.checkout(src))
					playsound(src, 'sound/items/scannerbeep.ogg', 15, TRUE)
					to_chat(user, "[scanner]'s screen flashes: 'Title checked out to [scanner.computer.patron_name].'")
				else
					playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
					to_chat(user, "[scanner]'s screen flashes: 'ERROR! Book Checkout Unsuccesful.'")
			if(3)
				if(scanner.computer.checkin(src))
					playsound(src, 'sound/items/scannerbeep.ogg', 15, TRUE)
					to_chat(user, "[scanner]'s screen flashes: 'Title checked back into general inventory.'")
				else
					playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
					to_chat(user, "[scanner]'s screen flashes: 'ERROR! Book Checkout Unsuccesful.'")
		return
	else if(istype(W, /obj/item/kitchen/knife) && !carved)
		carve_book(user, W)
	else
		return ..()

/obj/item/book/wirecutter_act(mob/user, obj/item/I)
	return carve_book(user, I)

/obj/item/book/attack(mob/M, mob/living/user)
	if(user.a_intent == INTENT_HELP)
		force = 0
		attack_verb = list("educated")
	else
		force = initial(force)
		attack_verb = list("bashed", "whacked")
	..()

/obj/item/book/proc/carve_book(mob/user, obj/item/I)
	if(!I.sharp && I.tool_behaviour != TOOL_WIRECUTTER) //Only sharp and wirecutter things can carve books
		to_chat(user, "<span class='warning>You can't carve [title] using that!</span>")
		return
	if(carved)
		return
	to_chat(user, "<span class='notice'>You begin to carve out [title].</span>")
	if(I.use_tool(src, user, 30, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You carve out the pages from [title]! You didn't want to read it anyway.</span>")
		carved = TRUE
		return TRUE
/*
 * Barcode Scanner
 */
/obj/item/barcodescanner
	name = "barcode scanner"
	desc = "A scanner used for managing library books, one can connect it the library system by tapping on a computer with it in hand."
	icon = 'icons/obj/library.dmi'
	icon_state ="scanner"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	/// Associated Library Computer, needed to perform actions
	var/obj/machinery/computer/library/computer
	// 0 - Scan only, 1 - Attempt to Add to Inventory, 2 - Checkout Book, 3 - Check In Book
	var/mode = 0

/obj/item/barcodescanner/attack_self(mob/user as mob)
	if(!check_connection(user))
		return
	mode++
	if(mode > 3)
		mode = 0
	var/modedesc
	switch(mode)
		if(0)
			modedesc = "Scan book to computer."
		if(1)
			modedesc = "Scan book into to general inventory."
		if(2)
			modedesc = "Checkout Book"
		if(3)
			modedesc = "Checkin Book"
		else
			modedesc = "ERROR"
	playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
	to_chat(user, "[src] mode: [modedesc]")

/obj/item/barcodescanner/proc/check_connection(mob/user as mob)
	if(computer)
		return TRUE
	else
		playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
		to_chat(user, "Please reconnect [src] to a library computer.")
		return FALSE
