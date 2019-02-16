/obj/item/soapstone
    name = "soapstone"
    desc = "Leave informative messages for the crew, including the crew of future shifts!\n(Disclaimer: Does not work on shuttles)\n WARNING: Side effects may include beatings, bannings and orbital bombardment."
    icon = 'icons/obj/items.dmi'
    icon_state = "soapstone"
    throw_speed = 3
    throw_range = 5
    w_class = WEIGHT_CLASS_TINY
    var/tool_speed = 50
    var/remaining_uses = 3


/obj/item/soapstone/examine(mob/user)
    . = ..()
    to_chat(usr, "It has [remaining_uses] uses left.")

/obj/item/soapstone/afterattack(atom/target, mob/user, proximity)
    var/turf/T = get_turf(target)
    if(!proximity)
        return

    if(!remaining_uses)
        // The dull chisel is dull.
        to_chat(usr, "<span class='warning'>[src] is dull It cannot engrave.</span>")

    var/obj/structure/chisel_message/already_message = locate(/obj/structure/chisel_message) in T

    if(!good_chisel_message_location(T))
        to_chat(usr, "<span class='warning'>It's not an appropriate location to engrave on [T].</span>")
        return

    if(already_message)
        user.visible_message("<span class='notice'>[user] starts erasing [already_message].</span>", "<span class='notice'>You start erasing [already_message].</span>", "<span class='italics'>You hear a chipping sound.</span>")
        playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)

        if(do_after(user, tool_speed, target=target) && spend_use())
            user.visible_message("<span class='notice'>[user] has erased [already_message].</span>", "<span class='notice'>You erased [already_message].</span>")
            already_message.persists = FALSE
            qdel(already_message)
            playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
        return

    var/message = stripped_input(user, "What would you like to engrave?", "Message")
    if(!message)
        to_chat(usr, "You decide not to engrave anything.")
        return

    if(!target.Adjacent(user) && locate(/obj/structure/chisel_message) in T)
        to_chat(usr, "You decide not to engrave anything.")
        return

    playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
    user.visible_message("<span class='notice'>[user] starts engraving a message into [T].</span>", "You start engraving a message into [T].", "<span class='italics'>You hear a chipping sound.</span>")
    if(do_after(user, tool_speed, target=T))
        if(!locate(/obj/structure/chisel_message in T) && spend_use())
            to_chat(usr, "You engrave a message into [T].")
            playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
            var/obj/structure/chisel_message/M = new(T)
            M.register(user, message)

/obj/item/soapstone/proc/spend_use(mob/user)
    if(!remaining_uses)
        . = FALSE
    else
        remaining_uses--
        if(!remaining_uses)
            name = "dull [name]"
        . = TRUE

 /* Persistent engraved messages, etched onto the station turfs to serve
   as instructions and/or memes for the next generation of spessmen.
    Limited in location to station_z only. Can be smashed out or exploded,
   but only permamently removed with the librarian's soapstone.
*/

/proc/good_chisel_message_location(turf/T)
    if(!T)
        . = FALSE
    else if(istype(get_area(T), /area/shuttle))
        . = FALSE
    else if(!(isfloorturf(T) || iswallturf(T)))
        . = FALSE
    else
        . = TRUE

/obj/structure/chisel_message
    name = "engraved message"
    desc = "A message from a past traveler."
    icon = 'icons/obj/stationobjs.dmi'
    icon_state = "soapstone_message"
    density = 0
    anchored = 1
    luminosity = 1
    obj_integrity = 30
    max_integrity = 30

    var/hidden_message
    var/creator_key
    var/realdate
    var/id
    var/persists = TRUE

/obj/structure/chisel_message/examine(mob/user)
    ..()
    to_chat(usr, "<span class='notice'>The inscription reads: <i>[hidden_message]</i></span>")

/obj/structure/chisel_message/Destroy()
    if(!persists)
        delete_soapstone_message(src.id)
    . = ..()

/obj/structure/chisel_message/update_icon()
    ..()
    var/hash = md5(hidden_message)
    var/newcolor = copytext(hash, 1, 7)
    color = "#[newcolor]"

/obj/structure/chisel_message/proc/register(mob/user, newmessage)
	hidden_message = sanitizeSQL(newmessage) // SANITIZE ALL THE THINGS
	creator_key = sanitizeSQL(user.ckey)
	var/map = sanitizeSQL(using_map.station_name)
	var/coord = "[src.x], [src.y], [src.z]"
	var/DBQuery/save_soapstone = dbcon.NewQuery("INSERT INTO [format_table_name("soapstone")] (ckey, coord, message_text, map) VALUES ('[creator_key]', '[coord]', '[hidden_message]', '[map]')")
	if(!save_soapstone.Execute())
		var/err = save_soapstone.ErrorMsg()
		log_game("SQL ERROR during soapstone message saving. Error : \[[err]\]\n")
	update_icon()