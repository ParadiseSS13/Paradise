/obj/machinery/gameboard
	name = "Virtual Gameboard"
	icon_state = "gboard_on"
	desc = "A holographic table allowing the crew to have fun(TM) on boring shifts! One player per board."
	density = TRUE
	anchored = TRUE
	light_color = LIGHT_COLOR_LIGHTBLUE

	var/cooling_down = 0

/obj/machinery/gameboard/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/gameboard(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/cable_coil(null, 3)
	component_parts += new /obj/item/stack/sheet/glass(null, 1)
	RefreshParts()

/obj/machinery/gameboard/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(3, 1)

/obj/machinery/gameboard/update_icon_state()
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

	var/datum/asset/chess_asset = get_asset_datum(/datum/asset/group/chess)
	chess_asset.send(user)

	var/dat = replacetext(file2text('html/chess.html'), "\[hsrc]", UID())
	var/datum/browser/popup = new(user, "SpessChess", name, 500, 800, src)
	popup.set_content(dat)
	popup.add_stylesheet("chess", 'html/browser/chess.css')
	popup.add_script("boardui", 'html/browser/boardui.js')
	popup.add_script("garbochess", 'html/browser/garbochess.js')
	popup.add_script("jquery-1.8.2.min", 'html/browser/jquery-1.8.2.min.js')
	popup.add_script("jquery-ui-1.8.24.custom.min", 'html/browser/jquery-ui-1.8.24.custom.min.js')
	popup.set_window_options("titlebar=0")
	popup.open()
	user.set_machine(src)

/obj/machinery/gameboard/proc/close_game() //yes, shamelessly copied over from arcade_base
	in_use = 0
	for(var/mob/user in viewers(world.view, src))			// I don't know who you are.
		if(user.client && user.machine == src)				// I will look for you,
			user.unset_machine()							// I will find you,
			user << browse(null, "window=SpessChess")	// And I will kill you.

/obj/machinery/gameboard/Topic(href, list/href_list)
	. = ..()
	var/prize = /obj/item/stack/tickets
	if(.)
		return

	if(href_list["checkmate"])
		if(cooling_down)
			message_admins("Too many checkmates on chessboard, possible HREF exploits: [key_name_admin(usr)] on [src] (<A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
			return
		visible_message("<span class='notice'><span class='name'>[src.name]</span> beeps, \"WINNER!\"</span>")
		new prize(get_turf(src), 80)
		close_game()
		cooling_down = 1
		spawn(600)
			cooling_down = 0

	if(href_list["close"])
		close_game()

/obj/machinery/gameboard/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I, ignore_panel = TRUE))
		return TRUE

/obj/machinery/gameboard/wrench_act(mob/user, obj/item/I)
	if(default_unfasten_wrench(user, I))
		return TRUE
