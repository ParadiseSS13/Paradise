#define BARCODE_MODE_SCAN_SELECT     1
#define BARCODE_MODE_SCAN_INVENTORY  2
#define BARCODE_MODE_CHECKOUT        3
#define BARCODE_MODE_CHECKIN         4

/*
 * Bookcase
 */

/obj/structure/bookcase
	name = "bookcase"
	icon = 'icons/obj/library.dmi'
	icon_state = "bookshelf-0"
	anchored = TRUE
	density = TRUE
	opacity = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 0)
	var/list/allowed_books = list(/obj/item/book, /obj/item/spellbook, /obj/item/storage/bible, /obj/item/tome) //Things allowed in the bookcase

/obj/structure/bookcase/Initialize(mapload)
	. = ..()
	if(mapload)
		// same reasoning as closets
		addtimer(CALLBACK(src, PROC_REF(take_contents)), 0)

/obj/structure/bookcase/proc/take_contents()
	for(var/obj/item/I in get_turf(src))
		if(is_type_in_list(I, allowed_books))
			I.forceMove(src)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/bookcase/attackby(obj/item/O, mob/user)
	if(is_type_in_list(O, allowed_books))
		if(!user.drop_item())
			return
		O.forceMove(src)
		update_icon(UPDATE_ICON_STATE)
		return TRUE
	if(istype(O, /obj/item/storage/bag/books))
		var/obj/item/storage/bag/books/B = O
		for(var/obj/item/T in B.contents)
			if(is_type_in_list(T, allowed_books))
				B.remove_from_storage(T, src)
		to_chat(user, "<span class='notice'>You empty [O] into [src].</span>")
		update_icon(UPDATE_ICON_STATE)
		return TRUE
	if(is_pen(O))
		rename_interactive(user, O)
		return TRUE

	return ..()

/obj/structure/bookcase/attack_hand(mob/user)
	if(!length(contents))
		return

	var/obj/item/book/choice = input(user, "Which book would you like to remove from [src]?") as null|anything in contents
	if(!choice)
		return
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!user.get_active_hand())
		user.put_in_hands(choice)
	else
		choice.forceMove(get_turf(src))
	update_icon(UPDATE_ICON_STATE)

/obj/structure/bookcase/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/wood(loc, 5)
	for(var/obj/item/I in contents)
		if(is_type_in_list(I, allowed_books))
			I.forceMove(get_turf(src))
	..()

/obj/structure/bookcase/update_icon_state()
	icon_state = "bookshelf-[min(length(contents), 5)]"


/obj/structure/bookcase/screwdriver_act(mob/user, obj/item/I)
	if(flags & NODECONSTRUCT)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return
	TOOL_DISMANTLE_SUCCESS_MESSAGE
	deconstruct(TRUE)

/obj/structure/bookcase/wrench_act(mob/user, obj/item/I)
	. = TRUE

	default_unfasten_wrench(user, I, 0)

/obj/structure/bookcase/manuals/medical
	name = "Medical Manuals bookcase"

/obj/structure/bookcase/manuals/medical/Initialize()
	. = ..()
	new /obj/item/book/manual/medical_cloning(src)
	update_icon(UPDATE_ICON_STATE)


/obj/structure/bookcase/manuals/engineering
	name = "Engineering Manuals bookcase"

/obj/structure/bookcase/manuals/engineering/Initialize()
	. = ..()
	new /obj/item/book/manual/wiki/engineering_construction(src)
	new /obj/item/book/manual/engineering_particle_accelerator(src)
	new /obj/item/book/manual/wiki/hacking(src)
	new /obj/item/book/manual/wiki/engineering_guide(src)
	new /obj/item/book/manual/engineering_singularity_safety(src)
	new /obj/item/book/manual/wiki/robotics_cyborgs(src)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/bookcase/manuals/research_and_development
	name = "R&D Manuals bookcase"

/obj/structure/bookcase/manuals/research_and_development/Initialize()
	. = ..()
	new /obj/item/book/manual/research_and_development(src)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/bookcase/sop
	name = "bookcase (Standard Operating Procedures)"

/obj/structure/bookcase/sop/Initialize()
	. = ..()
	new /obj/item/book/manual/wiki/sop_command(src)
	new /obj/item/book/manual/wiki/sop_engineering(src)
	new /obj/item/book/manual/wiki/sop_general(src)
	new /obj/item/book/manual/wiki/sop_legal(src)
	new /obj/item/book/manual/wiki/sop_medical(src)
	new /obj/item/book/manual/wiki/sop_science(src)
	new /obj/item/book/manual/wiki/sop_security(src)
	new /obj/item/book/manual/wiki/sop_service(src)
	new /obj/item/book/manual/wiki/sop_supply(src)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/bookcase/random
	var/category = null
	var/book_count = 5
	icon_state = "random_bookcase"
	anchored = TRUE

/obj/structure/bookcase/random/Initialize(mapload)
	. = ..()
	var/list/books = GLOB.library_catalog.get_random_book(book_count, doAsync = FALSE)
	for(var/datum/cachedbook/book as anything in books)
		new /obj/item/book(src, book, TRUE, FALSE)
	update_icon(UPDATE_ICON_STATE)

/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "Book Binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = TRUE
	density = TRUE

	var/datum/cachedbook/selected_content = new()
	var/printing = FALSE

/obj/machinery/bookbinder/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/bookbinder/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/bookbinder/attack_ghost(mob/user)
	ui_interact(user)


/obj/machinery/bookbinder/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/paper))
		select_paper(I)
	if(istype(I, /obj/item/paper_bundle))
		select_paper_stack(I)
	if(istype(I, /obj/item/book))
		select_book(I)
	if(default_unfasten_wrench(user, I, time = 60))
		return

	return ..()

/obj/machinery/bookbinder/proc/select_paper(obj/item/paper/P)
	selected_content.title = P.name
	selected_content.author = null
	selected_content.content = list(P.info)

/obj/machinery/bookbinder/proc/select_paper_stack(obj/item/paper_bundle/P)
	selected_content.title = P.name
	selected_content.author = null
	selected_content.content = list()
	for(var/obj/item/paper/I in P.contents)
		selected_content.content += I.info

/obj/machinery/bookbinder/proc/select_book(obj/item/book/B)
	if(!B || B.protected || B.carved)
		return
	selected_content.title = B.title
	selected_content.author = B.author
	selected_content.author = B.summary
	selected_content.content = B.pages
	for(var/c in B.categories)
		if(c)
			selected_content.categories += c

/obj/machinery/bookbinder/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BookBinder", name, 700, 400, master_ui, state)
		ui.open()

/obj/machinery/bookbinder/ui_data(mob/user)
	var/list/data = list()

	var/list/selected_book_data = list(
		"title" = selected_content.title ? selected_content.title : "not specified",
		"author" = selected_content.author ? selected_content.author : "not specified",
		"summary" = selected_content.summary ? selected_content.summary : "no summary",
		"copyright" = selected_content.copyright ? selected_content.copyright : FALSE,
		"categories" = selected_content.categories ? selected_content.categories : list()
	)
	data["selectedbook"] = selected_book_data
	data["modal"] = ui_modal_data(src)
	return data

/obj/machinery/bookbinder/ui_static_data(mob/user)
	var/list/static_data = list()

	static_data["book_categories"] = list()
	for(var/datum/library_category/category in GLOB.library_catalog.categories)
		var/category_info = list(
			"category_id" = category.category_id,
			"description" = category.description,
		)
		static_data["book_categories"] += list(category_info)

	return static_data

/obj/machinery/bookbinder/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	if(ui_act_modal(action, params))
		return

	add_fingerprint(ui.user)

	switch(action)
		if("print_book")
			if(!printing)
				printing = TRUE
				visible_message("<span class='notice'>[src] begins to hum as it warms up its printing drums.</span>")
				addtimer(CALLBACK(src, PROC_REF(print_book)), 5 SECONDS)
			else
				playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
		if("toggle_binder_category")
			var/category_id = text2num(params["category_id"])
			if(category_id in selected_content.categories)
				selected_content.categories -= category_id
			else
				if(length(selected_content.categories) >= 3)
					playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
					return
				selected_content.categories += category_id

/obj/machinery/bookbinder/proc/ui_act_modal(action, list/params)
	. = TRUE
	var/id = params["id"] // The modal's ID
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("edit_selected_title")
					ui_modal_input(src, id, "Please input the new title:", null, arguments, selected_content.title)
				if("edit_selected_author")
					ui_modal_input(src, id, "Please input the new author:", null, arguments, selected_content.author)
				if("edit_selected_summary")
					ui_modal_input(src, id, "Please input the new summary:", null, arguments, selected_content.summary)
				else
					return FALSE
		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("edit_selected_title")
					if(length(answer) >= MAX_NAME_LEN)
						return
					selected_content.title = strip_html(answer)
				if("edit_selected_author")
					if(length(answer) >= MAX_NAME_LEN)
						return
					selected_content.author = strip_html(answer)
				if("edit_selected_summary")
					if(length(answer) >= MAX_SUMMARY_LEN)
						return
					selected_content.summary = strip_html(answer)
				else
					return FALSE
		else
			return FALSE

/obj/machinery/bookbinder/proc/print_book()
	visible_message("<span class='notice'>[src] whirs as it prints and binds a new book.</span>")
	new /obj/item/book(loc, selected_content, FALSE, FALSE)
	printing = FALSE

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
	var/list/modes = list(BARCODE_MODE_SCAN_SELECT, BARCODE_MODE_SCAN_INVENTORY, BARCODE_MODE_CHECKOUT, BARCODE_MODE_CHECKIN)
	/// Associated Library Computer, needed to perform actions
	var/obj/machinery/computer/library/computer
	var/mode = BARCODE_MODE_SCAN_SELECT

/obj/item/barcodescanner/attack_self(mob/user)
	if(!check_connection(user))
		return
	mode++
	if(mode > length(modes))
		mode = modes[1]
	var/modedesc
	switch(mode)
		if(BARCODE_MODE_SCAN_SELECT)
			modedesc = "Scan book to computer."
		if(BARCODE_MODE_SCAN_INVENTORY)
			modedesc = "Scan book into to general inventory."
		if(BARCODE_MODE_CHECKOUT)
			modedesc = "Checkout Book"
		if(BARCODE_MODE_CHECKIN)
			modedesc = "Checkin Book"
		else
			modedesc = "ERROR"
	playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
	to_chat(user, "<span class='notice'>[src] mode: [modedesc]</span>")

/obj/item/barcodescanner/proc/connect(obj/machinery/computer/library/library_computer)
	if(!istype(library_computer))
		return FALSE
	if(computer == library_computer)
		return TRUE //we're succesfully connected already, let player know it was a "succesful connection"

	disconnect() //clear references to old computer, we have to unregister signals
	computer = library_computer
	RegisterSignal(library_computer, COMSIG_PARENT_QDELETING, PROC_REF(disconnect))
	return TRUE

/obj/item/barcodescanner/proc/disconnect()
	if(!computer)
		return //proc will runtime if computer is null
	UnregisterSignal(computer, COMSIG_PARENT_QDELETING)
	computer = null

/obj/item/barcodescanner/proc/scanID(obj/item/card/id/ID, mob/user)
	if(!check_connection(user))
		return

	if(!ID.registered_name)
		computer.user_data.patron_name = null
		computer.user_data.patron_account = null //account number should reset every scan so we don't accidently have an account number but no name
		playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
		to_chat(user, "<span class='warning'>[src]'s screen flashes: 'ERROR! No name associated with this ID Card'</span>")
		return //no point in continuing if the ID card has no associated name!

	computer.user_data.patron_name = ID.registered_name
	playsound(src, 'sound/items/scannerbeep.ogg', 15, TRUE)
	if(!ID.associated_account_number)
		computer.user_data.patron_account = null
		to_chat(user, "<span class='warning'>[src]'s screen flashes: 'WARNING! Patron without associated account number Selected'</span>")
		return

	computer.user_data.patron_account = ID.associated_account_number
	to_chat(user, "<span class='notice'>[src]'s screen flashes: 'Patron Selected'</span>")

/obj/item/barcodescanner/proc/scanBook(obj/item/book/B, mob/user as mob)
	if(!check_connection(user))
		return

	switch(mode)
		if(BARCODE_MODE_SCAN_SELECT)
			computer.select_book(B)
			playsound(src, 'sound/machines/terminal_select.ogg', 15, TRUE)
			to_chat(user, "<span class='notice'>[src]'s screen flashes: 'Book selected in library computer.'</span>")
		if(BARCODE_MODE_SCAN_INVENTORY)
			if(computer.inventoryAdd(B))
				playsound(src, 'sound/items/scannerbeep.ogg', 15, TRUE)
				to_chat(user, "<span class='notice'>[src]'s screen flashes: 'Title added to general inventory.'</span>")
			else
				playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
				to_chat(user, "<span class='notice'>[src]'s screen flashes: 'Title already in general inventory.'</span>")
		if(BARCODE_MODE_CHECKOUT)
			var/confirm
			if(!computer.user_data.patron_account)
				confirm = alert("Warning: patron does not have an associated account number! Are you sure you want to checkout [B] to [computer.user_data.patron_name]?", "Confirm Checkout", "Yes", "No")
			else
				confirm = alert("Are you sure you want to checkout [B] to [computer.user_data.patron_name]?", "Confirm Checkout", "Yes", "No")

			if(confirm == "No")
				return
			if(computer.checkout(B))
				playsound(src, 'sound/items/scannerbeep.ogg', 15, TRUE)
				to_chat(user, "<span class='notice'>[src]'s screen flashes: 'Title checked out to [computer.user_data.patron_name].'</span>")
			else
				playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
				to_chat(user, "<span class='notice'>[src]'s screen flashes: 'ERROR! Book Checkout Unsuccessful.'</span>")
		if(BARCODE_MODE_CHECKIN)
			if(computer.checkin(B))
				playsound(src, 'sound/items/scannerbeep.ogg', 15, TRUE)
				to_chat(user, "<span class='notice'>[src]'s screen flashes: 'Title checked back into general inventory.'</span>")
			else
				playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
				to_chat(user, "<span class='notice'>[src]'s screen flashes: 'ERROR! Book Checkout Unsuccessful.'</span>")

/obj/item/barcodescanner/proc/check_connection(mob/user as mob) //fuck you null references!
	if(computer)
		return TRUE
	else
		playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
		to_chat(user, "<span class='notice'>Please reconnect [src] to a library computer.</span>")
		return FALSE
