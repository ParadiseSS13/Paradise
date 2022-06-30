///Max Writeable Content Pages per book, players really don't need more than this
#define MAX_PAGES 5

/**
  * # Standard Book
  *
  * Game Object which stores pages of text usually written by players, has other editable information such as the book's
  * title, author, summary, and categories. Has other values that are generated when books are acquired through the library
  * computer.
  *
  * Like other User Interfaces that heavily rely on player input, using newer tools such as TGUI presents sanitization issues
  * so books will remain using BrowserUI until further notice.
  */
/obj/item/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state = "book"
	throw_speed = 1
	throw_range = 5
	force = 2
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashed", "whacked")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound =  'sound/items/handling/book_pickup.ogg'

	///Title & Real name of the book
	var/title
	//Who wrote the book, can be changed by pen or PC
	var/author
	///Short summary of the contents of the book, can be changed by pen or PC
	var/summary
	///Book Rating - Assigned by library computer based on how many/how players have rated this book
	var/rating
	///Book Categories - used for differentiating types of books, set by players upon upload, viewable upon examining book
	var/categories = list()
	///The background color of the book, useful for themed programmatic books, must be in #FFFFFF hex color format
	var/book_bgcolor = "#FFF2E5"
	///Content Pages of the books, this variable is a list of strings containting the HTML + Text of each page
	var/pages = list()
	///What page is the book currently opened to? Page 0 - Intro Page | Page 1-5 - Content Pages
	var/current_page = 0

	///Book UI Popup Height
	var/book_height = 400
	///Book UI Popup Width
	var/book_width = 400
	///Prevents book from being uploaded - For all printed books
	var/copyright = FALSE
	///Prevents book contents from being edited
	var/protected = FALSE
	///Book's id within the library system, unique to each book object, should not be declared manually
	var/libraryid
	///Indicates whether or not a books pages have been carved out
	var/carved = FALSE
	///Item that is stored inside the book
	var/obj/item/store

/obj/item/book/Initialize(mapload, datum/cachedbook/CB = null, _copyright = FALSE, _protected = FALSE)
	. = ..()
	if(CB)
		author = CB.author
		title = CB.title
		pages = CB.content
		summary = CB.summary
		categories = CB.categories
		copyright = _copyright
		protected = _protected
		rating = CB.rating
		name = "Book: [CB.title]"
		icon_state = "book[rand(1,8)]"


/obj/item/book/attack(mob/M, mob/living/user)
	if(user.a_intent == INTENT_HELP)
		force = 0
		attack_verb = list("educated")
	else
		force = initial(force)
		attack_verb = list("bashed", "whacked")
	..()

/obj/item/book/attack_self(mob/user as mob)
	if(carved)
		//Attempt to remove inserted object, if none found, remind user that someone vandalized their book (Bastards)!
		if(!remove_stored_item(user, FALSE))
			to_chat(user, "<span class='notice'>The pages of [title] have been cut out!</span>")
		return
	read_book(user)

/obj/item/book/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/pen))
		edit_book()
	else if(istype(I, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/scanner = I
		scanner.scanBook(src, user) //abstraction and proper scoping ftw | did you know barcode scanner code used to be here?
		return
	else if(I.sharp && !carved) //don't use sharp objects on your books if you don't want to carve out all of its pages kids!
		carve_book(user, I)
	else
		store_item(I)

/**
  * Internal Checker Proc
  *
  * Gives free pass to observers to read, ensures that all other mobs attempting to read book are A) literated and
  * B) are within range to actually read the book.
  */
/obj/item/book/proc/can_read(mob/user)
	if(isobserver(user)) //We check this first because ghosts should be able to read any book they can see no matter what
		return TRUE
	if(!in_range(src, user))
		return FALSE
	if(!user.is_literate()) //this person was 2 cool 4 school and cannot READ
		user.visible_message("You attempt to the read the book but remember that you don't actually know how to read.")
		return FALSE
	return TRUE

/**
  * Read Book Proc
  *
  * Checks if players is able to read book and that book is readable before calling the neccesary procs to open up UI
  */
/obj/item/book/proc/read_book(mob/user)
	if(!length(pages)) //You can't read a book with no pages in it
		to_chat(user, "This book is completely blank!")
		return
	if(!can_read(user))
		return
	user.visible_message("[user] opens a book titled \"[title]\" and begins reading intently.")
	show_content(user) //where all the magic happens
	onclose(user, "book")

/**
  * Show Content Proc
  *
  * Builds the browserUI html to show to the player then open up the User interface. It first build the header navigation
  * buttons and then builds the rest of the UI based on what page the player is turned to.
  */
/obj/item/book/proc/show_content(mob/user)
	var/dat = ""
	//First, we're going to choose/generate our header buttons for switching pages and store it in var/dat
	if(length(pages)) //No need to have page switching buttons if there's no pages
		if(current_page == 0)
			dat+= "<DIV STYLE='float:left; text-align:left; width:49.9%'></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:right; width:49.9%'><A href='?src=[UID()];next_page=1'>Next Page</A></DIV><BR><HR>"
		else if(current_page < length(pages))
			dat+= "<DIV STYLE='float:left; text-align:left; width:49.9%'><A href='?src=[UID()];prev_page=1'>Previous Page</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:right; width:49.9%'><A href='?src=[UID()];next_page=1'>Next Page</A></DIV><BR><HR>"
		else if(current_page == length(pages))
			dat+= "<DIV STYLE='float:left; text-align:left; width:49.9%'><A href='?src=[UID()];prev_page=1'>Previous Page</A></DIV>"
			dat+= "<DIV STYLE='float;left; text-align:right; width:49.9%'></DIV>"

	//Now we're going to display the header buttons + the current page selected, if it's page 0, we display the cover_page instead
	if(!current_page)
		var/cover_page = {"<center><h1>[title]</h1><br></h2>Written by: [author]</h2></center><br><hr><b>Summary:</b> [summary]"}
		user << browse("<body bgcolor='[book_bgcolor]'>[dat]<BR>" + "[cover_page]", "window=book[UID()];size=400x400")
		return
	else
		user << browse("<body bgcolor='[book_bgcolor]'>[dat]<BR>" + "[pages[current_page]]", "window=book[UID()]")

/obj/item/book/Topic(href, href_list)
	..()
	if(loc != usr && !Adjacent(usr))
		return
	if(href_list["next_page"])
		if(current_page > length(pages)) //should never be false, but just in-case
			current_page = length(pages)
			return
		current_page++
		playsound(loc, "pageturn", 50, 1)
		attack_self(usr) //scuffed but this is how you update the UI
		updateUsrDialog()
	if(href_list["prev_page"])
		if(current_page < 0) //should never be false, but just in-case
			current_page = 0
			return
		current_page--
		playsound(loc, "pageturn", 50, 1)
		attack_self(usr) //scuffed but this is how you update the UI
		updateUsrDialog()

/**
  * Edit Book Proc
  *
  * This is where a lot of the magic happens, upon interacting with the book with a pen, this proc will open up options
  * for the player to edit the book. Most importantly, this is where we account for player stupidity and maliciousness
  * any input must strip/reject bad text and HTML from user input, additionally we account for players trying to screw
  * with the Database. This will also limit the max characters players can upload at one time to prevent spamming.
  */
/obj/item/book/proc/edit_book(mob/user)
	if(protected) //we don't want people touching "special" books, especially ones that use iframes
		to_chat(user, "These pages don't seem to take the ink well. Looks like you can't modify it.")
		return
	var/choice = input("What would you like to edit?") in list("Title", "Edit Current Page", "Author", "Summary", "Add Page", "Remove Page", "Cancel")
	switch(choice)
		if("Title")
			var/newtitle = reject_bad_text(stripped_input(usr, "Write a new title:"))
			if(!newtitle)
				to_chat(usr, "The title is invalid.")
				return
			else
				//Like with paper, the name (not title) of the book should indicate that THIS IS A BOOK when actions are performed with it
				//this is to prevent players from naming it "Nuclear Authentification Disk" or "Energy Sword" to fuck with security
				name = "Book: " + newtitle
				title = newtitle
		if("Author")
			var/newauthor = stripped_input(usr, "Write the author's name:")
			if(!newauthor)
				to_chat(usr, "The name is invalid.")
				return
			else
				author = newauthor
		if("Summary")
			var/newsummary = strip_html(input(usr, "Write the new summary:") as message|null, MAX_SUMMARY_LEN)
			if(!newsummary)
				to_chat(usr, "The name is invalid.")
				return
			else
				summary = newsummary
		if("Edit Current Page")
			if(carved)
				to_chat(usr, "<span class='notice'>The pages of [title] have been cut out!</span>")
				return
			if(!current_page)
				to_chat(usr, "<span class='notice'>You need to turn to a page before writing in the book.</span>")
				return
			var/character_space_remaining = MAX_CHARACTERS_PER_BOOKPAGE - length(pages[current_page])
			if(character_space_remaining <= 0)
				to_chat(usr, "<span class='notice'>There's not enough space left on this page to write anything!</span>")
				return
			var/content = strip_html(input(usr, "Add Text to this page, you have [character_space_remaining] characters of space left:") as message|null, MAX_CHARACTERS_PER_BOOKPAGE)
			if(!content)
				to_chat(usr, "The content is invalid.")
				return
			//check if length of current text content + what player is adding is larger than our character limit
			else if((length(content) + length(pages[current_page])) > MAX_CHARACTERS_PER_BOOKPAGE)
				//if true, let's cut down the text to fit perfectly into our character limit, player is only half-pissed!
				pages[current_page] += dd_limittext(content, (MAX_CHARACTERS_PER_BOOKPAGE - length(pages[current_page])))
			else
				pages[current_page] += content
		if("Add Page")
			if(carved)
				to_chat(usr, "<span class='notice'>You can't add anymore pages, the pages of [title] have been cut out and the book is ruined!</span>")
				return
			if(length(pages) >= MAX_PAGES)
				to_chat(usr, "<span class='notice'>You can't fit anymore pages in this book!</span>")
				return
			to_chat(usr, "<span class='notice'>You add another page to the book!</span>")
			pages += " "
		if("Remove Page")
			if(!length(pages))
				to_chat(usr, "<span class='notice'>There aren't any pages in this book!</span>")
				return
			var/page_choice = stripped_input(usr, "There are [length(pages)] pages, which page number would you like to remove?")
			if(!isnum(page_choice) || page_choice > length(pages))
				to_chat(usr, "That is not an acceptable value.")
				return
			pages -= pages[page_choice]

/obj/item/book/proc/edit_page(content, page_number)
	if(!content)
		return
	if(length(pages) < page_number) //can't remove the page if it doesn't exist
		return
	pages += content

/obj/item/book/proc/add_page(content)
	var/text = content
	if(!text)
		text = " "
	if(length(pages) >= MAX_PAGES)
		return FALSE
	pages += text
	current_page = length(pages) //open to newely added page so player can edit it
	return TRUE

/obj/item/book/proc/remove_page(page_number)
	if(length(pages) < page_number) //can't remove the page if it doesn't exist
		return FALSE
	if(pages -= pages[page_number])
		page_number = length(pages) //if page_number is somehow at a value it shouldn't be we fix it here aswell
		return TRUE //we want to make sure whatever is calling this proc knows the operation was succesful
	return FALSE

/obj/item/book/proc/carve_book(mob/user, obj/item/I)
	if(carved)
		to_chat(user, "<span class='warning'>[title] has already been carved out!</span>")
		return
	if(!I.sharp)
		to_chat(user, "<span class='warning'>You can't carve [title] using that!</span>")
		return
	to_chat(user, "<span class='notice'>You begin to carve out [title].</span>")
	if(I.use_tool(src, user, 30, volume = I.tool_volume))
		user.visible_message("<span class='warning'>[user] appears to carve out the pages inside of [title]!</span>",\
				"<span class='danger'>You carve out [title].!</span>")
		carved = TRUE
		return TRUE

/obj/item/book/proc/store_item(obj/item/I, mob/user)
	if(store)
		to_chat(user, "<span class='notice'>There is already something in [src]!</span>")
		return

	//does it exist, if so is it an abstract item?
	if(!istype(I) || (I.flags & ABSTRACT))
		return
	if(I.flags & NODROP)
		to_chat(user, "<span class='notice'>[I] stays stuck to your hand when you try and hide it in the book!.</span>")
		return
	//Checking to make sure the item we're storing isn't larger than/equal to size of the book, prevents recursive storing aswell
	if(I.w_class >= w_class)
		to_chat(user, "<span class='notice'>[I] is to large to fit in [name].</span>")
		return

	user.drop_item()
	I.forceMove(src)
	store = I
	to_chat(user, "<span class='notice'>You hide [I] in [name].</span>")


/obj/item/book/proc/remove_stored_item(mob/user, thrown = FALSE)
	if(!store)
		if(!thrown) //we don't wanna display this message if the object falls out because it was thrown
			to_chat(user, "<span class='notice'>You search [name] but there is nothing in it!</span>")
		return FALSE
	if(!thrown)
		to_chat(user, "<span class='notice'>You carefully remove [store] from [name]!</span>")
	store.forceMove(get_turf(store.loc))
	store = null
	return TRUE

 //* Book Spawners n'stuff *//
/obj/item/book/random
	icon_state = "random_book"
	var/amount = 1

/obj/item/book/random/Initialize()
	..()
	var/list/books = GLOB.library_catalog.getRandomBooks(amount)
	for(var/datum/cachedbook/book as anything in books)
		var/obj/item/book/B = new(loc) //this really should be a constructor that accepts cachedbook datums at some point tbh
		B.author = book.author
		B.title = book.title
		B.pages = book.content
		B.summary = book.summary
		B.categories = book.categories
		B.copyright = TRUE
		B.rating = book.rating
		B.name = "Book: [book.title]"
		B.icon_state =	"book[rand(1,8)]"
	qdel(src)

/obj/item/book/random/triple
	amount = 3

 //* Codex Gigas *//
 //This book used to have its own dm file, due to devil code removal, it is now only a cosmetic item for the time being
 //this will be its resting place until it is used for something else eventually.
/obj/item/book/codex_gigas
	name = "\improper Codex Gigas"
	desc = "A book documenting the nature of devils, it seems whatever magic that once possessed this codex is long gone."
	icon_state = "demonomicon"
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	author = "Forces beyond your comprehension"
	protected = TRUE
	title = "The codex gigas"
	copyright = TRUE
