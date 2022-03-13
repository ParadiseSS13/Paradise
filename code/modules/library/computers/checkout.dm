/*
 * Library Computer
 */
/obj/machinery/computer/library/checkout
	name = "Check-In/Out Computer"
	icon = 'icons/obj/library.dmi'
	icon_state = "computer"
	anchored = 1
	density = 1
	var/arcanecheckout = 0
	//var/screenstate = 0 // 0 - Main Menu, 1 - Inventory, 2 - Checked Out, 3 - Check Out a Book
	var/buffer_book
	var/buffer_mob


	var/bibledelay = 0 // LOL NO SPAM (1 minute delay) -- Doohl
	var/booklist

