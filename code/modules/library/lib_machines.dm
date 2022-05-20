/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "Book Binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = 1
	density = 1

/obj/machinery/bookbinder/attackby(obj/item/I, mob/user)
	var/obj/item/paper/P = I
	if(default_unfasten_wrench(user, I))
		power_change()
		return
	if(istype(P))
		user.drop_item()
		user.visible_message("[user] loads some paper into [src].", "You load some paper into [src].")
		src.visible_message("[src] begins to hum as it warms up its printing drums.")
		sleep(rand(200,400))
		src.visible_message("[src] whirs as it prints and binds a new book.")
		var/obj/item/book/b = new(loc)
		b.dat = P.info
		b.name = "Print Job #[rand(100, 999)]"
		b.icon_state = "book[rand(1,16)]"
		qdel(P)
		return 1
	else
		return ..()
