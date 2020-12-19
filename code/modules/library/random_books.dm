/obj/item/book/manual/random
	icon_state = "random_book"

/obj/item/book/manual/random/New()
	..()
	var/static/banned_books = list(/obj/item/book/manual/random, /obj/item/book/manual/nuclear)
	var/newtype = pick(subtypesof(/obj/item/book/manual) - banned_books)
	new newtype(loc)
	qdel(src)

/obj/item/book/random
	icon_state = "random_book"
	var/amount = 1
	var/category = null

/obj/item/book/random/Initialize()
	..()
	create_random_books(amount, src.loc, TRUE, category)
	qdel(src)

/obj/item/book/random/triple
	amount = 3

/obj/structure/bookcase/random
	var/category = null
	var/book_count = 2
	icon_state = "random_bookcase"
	anchored = TRUE

/obj/structure/bookcase/random/New()
	. = ..()
	if(!book_count || !isnum(book_count))
		update_icon()
		return
	book_count += pick(-1,-1,0,1,1)
	create_random_books(book_count, src, FALSE, category)
	update_icon()

// why is this a global proc
/proc/create_random_books(amount = 2, location, fail_loud = FALSE, category = null)
	. = list()
	if(!isnum(amount) || amount<1)
		return
	if(!SSdbcore.IsConnected())
		if(fail_loud || prob(5))
			var/obj/item/paper/P = new(location)
			P.info = "There once was a book from Nantucket<br>But the database failed us, so f*$! it.<br>I tried to be good to you<br>Now this is an I.O.U<br>If you're feeling entitled, well, stuff it!<br><br><font color='gray'>~</font>"
			P.update_icon()
		return
	if(prob(25))
		category = null
	var/c = ""
	var/list/sql_params = list()
	if(category)
		c = " AND category=:category"
		sql_params["category"] = category
	
	sql_params["amount"] = amount
	var/datum/db_query/query_get_random_books = SSdbcore.NewQuery("SELECT author, title, content FROM [format_table_name("library")] WHERE (isnull(flagged) OR flagged = 0)[c] GROUP BY title ORDER BY rand() LIMIT :amount", sql_params)
	if(!query_get_random_books.warn_execute())
		qdel(query_get_random_books)
		return

	while(query_get_random_books.NextRow())
		var/obj/item/book/B = new(location)
		. += B
		B.author	=	query_get_random_books.item[1]
		B.title		=	query_get_random_books.item[2]
		B.dat		=	query_get_random_books.item[3]
		B.name		=	"Book: [B.title]"
		B.icon_state=	"book[rand(1,8)]"
	qdel(query_get_random_books)

/obj/structure/bookcase/random/fiction
	name = "bookcase (Fiction)"
	category = "Fiction"
/obj/structure/bookcase/random/nonfiction
	name = "bookcase (Non-Fiction)"
	category = "Non-fiction"
/obj/structure/bookcase/random/religion
	name = "bookcase (Religion)"
	category = "Religion"
/obj/structure/bookcase/random/adult
	name = "bookcase (Adult)"
	category = "Adult"

/obj/structure/bookcase/random/reference
	name = "bookcase (Reference)"
	category = "Reference"
	var/ref_book_prob = 20

/obj/structure/bookcase/random/reference/Initialize(mapload)
	. = ..()
	while(book_count > 0 && prob(ref_book_prob))
		book_count--
		new /obj/item/book/manual/random(src)
