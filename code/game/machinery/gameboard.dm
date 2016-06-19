/obj/machinery/gameboard
	name = "Virtual Gameboard"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gboard_on"
	desc = "A holographic table allowing the crew to have fun(TM) on boring shifts! One player per board."
	density = 1
	anchored = 1
	use_power = 1
	var/cooling_down = 0
	light_color = LIGHT_COLOR_LIGHTBLUE

/obj/machinery/gameboard/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/gameboard(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/cable_coil(null, 3)
	component_parts += new /obj/item/stack/sheet/glass(null, 1)
	RefreshParts()

/obj/machinery/gameboard/power_change()
	. = ..()
	update_icon()
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(3, 3)

/obj/machinery/gameboard/update_icon()
	if(stat & NOPOWER)
		icon_state = "gboard_off"
	else
		icon_state = "gboard_on"

/obj/machinery/gameboard/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(src.in_use)
		to_chat(user, "This gameboard is already in use!")
		return
	if(!anchored)
		to_chat(user, "The gameboard is not secured!")
		return
	interact(user)

/obj/machinery/gameboard/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	dat = replacetext(file2text('html/chess.html'), "\[hsrc]", "\ref[src]")
	var/datum/asset/simple/chess/assets = get_asset_datum(/datum/asset/simple/chess)
	assets.send(user)

	var/datum/browser/popup = new(user, "SpessChess", name, 500, 800, src)
	popup.set_content(dat)
	popup.add_stylesheet("chess.css", 'html/browser/chess.css')
	popup.add_script("garbochess.js", 'html/browser/garbochess.js')
	//popup.add_script("boardui.js", 'html/browser/boardui.js')
	popup.add_script("jquery-1.8.2.min.js", 'html/browser/jquery-1.8.2.min.js')
	popup.add_script("jquery-ui-1.8.24.custom.min.js", 'html/browser/jquery-ui-1.8.24.custom.min.js')
	popup.set_window_options("titlebar=0")
	popup.open()
	user.set_machine(src)

/obj/machinery/gameboard/proc/close_game() //yes, shamelessly copied over from arcade_base
	in_use = 0
	for(var/mob/user in viewers(world.view, src))			// I don't know who you are.
		if(user.client && user.machine == src)				// I will look for you,
			user.unset_machine()							// I will find you,
			user << browse(null, "window=SpessChess")	// And I will kill you.
	return

/obj/machinery/gameboard/Topic(var/href, var/list/href_list)
	. = ..()
	var/prize = /obj/item/stack/tickets
	if(.)
		return

	if(href_list["checkmate"])
		if(cooling_down)
			message_admins("Too many checkmates on chessboard, possible HREF exploits: [key_name_admin(usr)] on [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
			return
		visible_message("<span class='info'><span class='name'>[src.name]</span> beeps, \"WINNER!\"</span>")
		new prize(get_turf(src), 80)
		close_game()
		cooling_down = 1
		spawn(600)
			cooling_down = 0

	if(href_list["close"])
		close_game()

/obj/machinery/gameboard/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob, params)
	if(istype(G, /obj/item/weapon/wrench))
		default_unfasten_wrench(user, G)
	else if(istype(G, /obj/item/weapon/crowbar))
		default_deconstruction_crowbar(G, ignore_panel = 1)
