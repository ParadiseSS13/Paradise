/obj/machinery/gameboard
	name = "Virtual Gameboard"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gboard_on"
	desc = "A holographic table allowing the crew to have fun™ on boring shifts! One player per board."
	density = 1
	anchored = 1
	use_power = 1

/obj/machinery/gameboard/power_change()
    . = ..()
    update_icon()

/obj/machinery/gameboard/update_icon()
    if(stat & NOPOWER)
        icon_state = "gboard_off"
    else
        icon_state = "gboard_on"

/obj/machinery/gameboard/attack_hand(mob/user)
    . = ..()
    if (.)
        return
    interact(user)

/obj/machinery/gameboard/interact(mob/user)
    . = ..()
    if (.)
        return

    var/dat
    dat = file2text('html/chess.html')
    var/datum/asset/simple/chess/assets = get_asset_datum(/datum/asset/simple/chess)
    assets.send(user)

    var/datum/browser/popup = new(user, "SpessChess", name, 500, 800)
    popup.set_content(dat)
    popup.add_stylesheet("chess.css", 'html/browser/chess.css')
    popup.add_script("garbochess.js", 'html/browser/garbochess.js')
    popup.add_script("boardui.js", 'html/browser/boardui.js')
    popup.add_script("jquery-1.8.2.min.js", 'html/browser/jquery-1.8.2.min.js')
    popup.add_script("jquery-ui-1.8.24.custom.min.js", 'html/browser/jquery-ui-1.8.24.custom.min.js')
    popup.open()