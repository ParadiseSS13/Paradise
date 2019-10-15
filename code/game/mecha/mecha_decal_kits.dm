///////////////
// PAINT GUN //
///////////////
// By: Pidgey
//
// All decals and colour palettes are applied to mechs via this item. As a base feature, users can apply base coats to ther armour of mechs and recolour their little blinkenlights.
// Paint guns accept pattern chips (/obj/item/mecha_decal_container) which can be loaded into them by attacking the gun with the chip, similar to a magazine.
//
// Each pattern chip grants access to one or more decals (/datum/mecha/mecha_decal) which can then be placed onto a compatible mech as a group. It is possible to create a custom paint job 
// and decal conmbination, ejecting it from the paint gun as a pattern chip. This chip can then be placed in other paint guns or back into the current one to create a custom pattern.
// 
// Standard paint guns also include a nanotrasen logo already in the memory banks. Hail corporate!
//

/obj/item/mecha_paint_gun
    name = "exosuit paint gun"
    desc = "An automated gun-shaped device used to apply or strip off paint and other decals, compatible with most standard exosuit models."
    icon = 'icons/mecha/mecha_decals.dmi'
    icon_state = "mech-painter"

    var/emagged = FALSE
    var/install_sound = 'sound/items/deconstruct.ogg'
    var/spray_sound = 'sound/effects/spray2.ogg'
    var/icon/overlay_icon

    w_class = WEIGHT_CLASS_SMALL
    slot_flags = SLOT_BELT

    // Decal kits must be installed in the exosuit paint gun prior to use.
    var/list/obj/item/mecha_decal_container/available_decal_containers

    var/obj/mecha/current_mecha
    var/next_pattern_at = 0     // Limits the rate at which the user can generate pattern chips.

/obj/item/mecha_paint_gun/Initialize()
    available_decal_containers = list(new/obj/item/mecha_decal_container/nanotrasen_logo)
    colour_overlay("#000000")
    ..()

/obj/item/mecha_paint_gun/proc/colour_overlay(var/colour)
    overlays.Cut()
    overlay_icon = new(icon, "mech-painter-overlay")
    overlay_icon.Blend(colour, ICON_ADD)
    overlays += overlay_icon

/obj/item/mecha_paint_gun/attack_obj(obj/O, mob/user)
    if(istype(O, /obj/mecha))
        openUI(O, user)
    else
        . = ..()

/obj/item/mecha_paint_gun/attackby(obj/O, mob/user)
    if(istype(O, /obj/item/mecha_decal_container))
        install_decal_container(O)
        user.drop_item()
        O.loc = null
    else
        . = ..()

/obj/item/mecha_paint_gun/proc/install_decal_container(var/obj/item/mecha_decal_container/D)
    for(var/obj/item/mecha_decal_container/C in available_decal_containers)
        if(C.decal_name == D.decal_name)
            to_chat(usr, "<span class='warning'>There is already a chip of that type installed!</span>")
            return
    available_decal_containers.Add(D)
    to_chat(usr, "<span class='notice'>You slot [D] into [src].</span>")
    playsound(loc, install_sound, 50, 1)

/obj/item/mecha_paint_gun/proc/delete_decal_container(var/obj/item/mecha_decal_container/D)
    available_decal_containers.Remove(D)

/obj/item/mecha_paint_gun/proc/UI_colour_box(var/colour)
    return "<span style='font-face: fixedsys; background-color: [colour]; color: [colour]'>___</span>"

/obj/item/mecha_paint_gun/proc/UI_bg_grey(var/text)
    text = "<span style='background-color: grey;'> [text] </span>"
    return text

/obj/item/mecha_paint_gun/proc/openUI(obj/mecha/M, mob/user)
    current_mecha = M
    if(!current_mecha.cosmetics_enabled || !current_mecha.basecoat_icon)
        to_chat(user, "<span class='warning'>[src] is not compatible with this exosuit!</span>")
        return
    var/dat
    user.set_machine(src)
    if(!current_mecha)
        dat += "<b>No exosuit selected.</b><br/>"
    else
        dat += "<div class='paintGun'>"
        dat += "<b>Base Coat:</b> <A href='?src=[UID()];choice=set_base'>Colour</A>[UI_colour_box(current_mecha.basecoat_colour)] <A href='?src=[UID()];choice=default_base'>Default</A><br/>"
        dat += "<b>Glow:</b> <A href='?src=[UID()];choice=set_glow'>Colour</A>[UI_colour_box(current_mecha.glow_colour)] <A href='?src=[UID()];choice=default_glow'>Default</A><br/><br/>"
        if(current_mecha.decals.len != 0)
            dat += "<b>Decals Applied to [current_mecha.name]:</b><br/>"
            for(var/datum/mecha/mecha_decal/decal in current_mecha.decals)
                if(decal.mutable_colour)
                    dat += "[decal.decal_name]: <A href='?src=[UID()];decalcolour=\ref[decal]'>Colour</A>[UI_colour_box(decal.decal_colour)] "
                if(decal.can_strip)
                    dat += "[decal.decal_name]: <A href='?src=[UID()];decalstrip=\ref[decal]'>Strip</A>"
                dat += "<br/>"
            dat += "<br/>"

        dat += "<b>Installed Decals:</b><br/>"
        if(available_decal_containers.len > 0)
            for(var/obj/item/mecha_decal_container/D in available_decal_containers)
                if(!(current_mecha.type in D.compatible_mecha))
                    dat += "[UI_bg_grey(D.decal_name)] Incompatible!<br/>"
                else
                    var/found_nonapplied_decal = FALSE
                    var/list/decalstrings = current_mecha.get_decal_strings()
                    for(var/datum/mecha/mecha_decal/MD in D.decals)
                        if(!(MD.decal_string in decalstrings)) 
                            found_nonapplied_decal = TRUE
                    if(found_nonapplied_decal || D.basecoat || D.glow) // If there is a base coat or glow colour, always have asn option to apply it.
                        dat += "<A href='?src=[UID()];decalapply=\ref[D]'>[D.decal_name]</A> "
                        for(var/datum/mecha/mecha_decal/MD in D.decals)
                            if(MD.mutable_colour)
                                dat += "<A href='?src=[UID()];innerdecalcolour=\ref[MD]'>Colour</A>[UI_colour_box(MD.decal_colour)] "
                    else
                        dat += "[UI_bg_grey(D.decal_name)] Already applied!"
                    if(D.deletable)
                        dat += "<A href='?src=[UID()];decaldelete=\ref[D]'>Delete</A>"
                    dat += "<br/>"      
        dat += "<br/><A href='?src=[UID()];choice=decalsave'>Save Exosuit Pattern</A>"
        dat += "<br/><A href='?src=[UID()];choice=defaultdecals'>Return All To Default</A><br/><br/>"

    var/datum/browser/popup = new(user, "mechapaintgun", "<u>Exosuit Paint Gun:</u> [current_mecha]", 400, 600)
    popup.set_content(dat)
    popup.open()
    return

/obj/item/mecha_paint_gun/Topic(href, href_list)
    if(..())
        return 1
    if(href_list["choice"])
        if(current_mecha.occupant)
            to_chat(usr, "<span class='warning'>The exosuit must be unoccupied before you can paint it!</span>")
            return
        switch(href_list["choice"])
            if("set_base")
                if(current_mecha.Adjacent(usr))
                    var/chosencolour = input("Select the new base colour:", "Base Colour", current_mecha.basecoat_colour) as color|null
                    if(do_after_once(usr, 15, target = current_mecha))
                        current_mecha.basecoat_colour = chosencolour
                        colour_overlay(current_mecha.basecoat_colour)
                        to_chat(usr, "<span class='notice'>You carefully cover the exosuit in a new coat of paint.</span>")
                        playsound(loc, spray_sound, 50, 1, -6)
                        openUI(current_mecha, usr)
            if("set_glow")
                if(current_mecha.Adjacent(usr))
                    var/chosencolour = input("Select the new glow colour:", "Glow Colour", current_mecha.glow_colour) as color|null
                    if(do_after_once(usr, 15, target = current_mecha))
                        current_mecha.glow_colour = chosencolour
                        colour_overlay(current_mecha.glow_colour)
                        to_chat(usr, "<span class='notice'>You carefully cover the exosuit in a new coat of paint.</span>")
                        playsound(loc, spray_sound, 50, 1, -6)
                        openUI(current_mecha, usr)
            if("default_base")
                if(current_mecha.Adjacent(usr) && do_after_once(usr, 15, target = current_mecha))
                    current_mecha.basecoat_colour = initial(current_mecha.basecoat_colour)
                    to_chat(usr, "<span class='notice'>You carefully cover the exosuit in a new coat of paint.</span>")
                    playsound(loc, spray_sound, 50, 1, -6)
                    openUI(current_mecha, usr)
            if("default_glow")
                if(current_mecha.Adjacent(usr) && do_after_once(usr, 15, target = current_mecha))
                    current_mecha.glow_colour = initial(current_mecha.glow_colour)
                    to_chat(usr, "<span class='notice'>You carefully cover the exosuit in a new coat of paint.</span>")
                    playsound(loc, spray_sound, 50, 1, -6)
                    openUI(current_mecha, usr)
            if("defaultdecals")
                if(current_mecha.Adjacent(usr) && do_after_once(usr, 15, target = current_mecha))
                    current_mecha.decals = list()
                    for(var/datum/mecha/mecha_decal/MD in current_mecha.default_decals)
                        current_mecha.decals.Add(MD.clone())
                    current_mecha.basecoat_colour = initial(current_mecha.basecoat_colour)
                    current_mecha.glow_colour = initial(current_mecha.glow_colour)
                    to_chat(usr, "<span class='notice'>You strip all the decals off [current_mecha] and return it to its original colour scheme.</span>")
                    playsound(loc, spray_sound, 50, 1, -6)
                    openUI(current_mecha, usr)
            if("decalsave")
                if(current_mecha.Adjacent(usr))
                    var/input_text = copytext(reject_bad_text(input(usr,"Pattern name?","Set Pattern Name","")),1,MAX_NAME_LEN)
                    if(input_text)
                        save_pattern(current_mecha, current_mecha.decals, input_text) 
                        openUI(current_mecha, usr)
        current_mecha.redraw_cache()
    
    if(href_list["decalcolour"])
        if(current_mecha.occupant)
            to_chat(usr, "<span class='warning'>The exosuit must be unoccupied before you can paint it!</span>")
            return
        if(current_mecha.Adjacent(usr))
            var/hrefstring = href_list["decalcolour"]
            var/datum/mecha/mecha_decal/D = locate(hrefstring)
            var/chosencolour = input("Select the new decal colour:", "Decal Colour", D.decal_colour) as color|null
            if(do_after_once(usr, 15, target = current_mecha))
                D.decal_colour = chosencolour
                colour_overlay(D.decal_colour)
                to_chat(usr, "<span class='notice'>You carefully spray over the decal, recolouring it neatly.</span>")
                playsound(loc, spray_sound, 50, 1, -6)
                current_mecha.redraw_cache()
                openUI(current_mecha, usr)

    if(href_list["innerdecalcolour"])
        var/hrefstring = href_list["innerdecalcolour"]
        var/datum/mecha/mecha_decal/D = locate(hrefstring)
        D.decal_colour = input("Select the new decal colour:", "Decal Colour", D.decal_colour) as color|null
        colour_overlay(D.decal_colour)
        openUI(current_mecha, usr)

    if(href_list["decalstrip"])
        if(current_mecha.occupant)
            to_chat(usr, "<span class='warning'>The exosuit must be unoccupied before you can paint it!</span>")
            return
        if(current_mecha.Adjacent(usr) && do_after_once(usr, 15, target = current_mecha))
            var/hrefstring = href_list["decalstrip"]
            var/datum/mecha/mecha_decal/D = locate(hrefstring)
            current_mecha.strip_decal(D)
            qdel(D)
            to_chat(usr, "<span class='notice'>You carefully strip off the decal.</span>")
            playsound(loc, spray_sound, 50, 1, -6)
            openUI(current_mecha, usr)

    if(href_list["decalapply"])
        if(current_mecha.occupant)
            to_chat(usr, "<span class='warning'>The exosuit must be unoccupied before you can paint it!</span>")
            return
        var/hrefstring = href_list["decalapply"]
        var/obj/item/mecha_decal_container/D = locate(hrefstring)
        if(current_mecha.Adjacent(usr) && do_after_once(usr, 15, target = current_mecha))
            if(D.install_on_mecha(current_mecha))
                to_chat(usr, "<span class='notice'>You spray the exosuit down as tiny manipulators handle the small details.</span>")
                playsound(loc, spray_sound, 50, 1, -6)
                openUI(current_mecha, usr)

    if(href_list["decaldelete"])
        var/hrefstring = href_list["decaldelete"]
        var/obj/item/mecha_decal_container/D = locate(hrefstring)
        delete_decal_container(D)
        openUI(current_mecha, usr)

// Emagging adds the syndicate logo to the paint gun but otherwise does nothing. Pointless badassery?
/obj/item/mecha_paint_gun/emag_act()
    if(!emagged)
        available_decal_containers.Add(new/obj/item/mecha_decal_container/syndicate_logo)
        visible_message("[src] sparks briefly.")
        emagged = TRUE

// Creates and spawns a new exosuit pattern on the ground featuring the current exosuit design. 30 second cooldown.
/obj/item/mecha_paint_gun/proc/save_pattern(obj/mecha/M, list/datum/mecha/mecha_decal/decal_list, var/pattern_name) 
    if(world.time >= next_pattern_at)
        var/obj/item/mecha_decal_container/D = new()
        D.name = "custom exosuit decal pattern ([pattern_name])"
        D.decal_name = "CUSTOM: [pattern_name]"
        D.desc = "A custom exosuit design that also overwrites the base coat of the target exosuit."
        D.decals = list()
        for(var/datum/mecha/mecha_decal/MD in decal_list)
            D.decals.Add(MD.clone())
        D.compatible_mecha = list(M.type)     // Only the exosuit this pattern was made for is compatible with a custom save.
        D.loc = usr.loc
        D.basecoat = current_mecha.basecoat_colour
        D.glow = current_mecha.glow_colour
        D.deletable = TRUE                    // Custom patterns are ALWAYS deletable.
        to_chat(usr, "<span class='notice'>A pattern chip drops out of [src]'s input slot!</span>")
        next_pattern_at = world.time + (30 SECONDS)
    else
        to_chat(usr, "<span class='warning'>The internal synthesizers haven't finished a new chip yet!</span>")

// COMPATIBILITY DEFINES
// All constructable mechs except honker and reticence.
#define COMPATIBLE_MECHA_COMMON list(/obj/mecha/working/ripley, /obj/mecha/working/ripley/firefighter, /obj/mecha/medical/odysseus, /obj/mecha/combat/durand, /obj/mecha/combat/gygax, /obj/mecha/combat/phazon)
// All constructable mechs
#define COMPATIBLE_MECHA_ALL_CONSTRUCTABLE list(/obj/mecha/working/ripley, /obj/mecha/working/ripley/firefighter, /obj/mecha/medical/odysseus, /obj/mecha/combat/durand, /obj/mecha/combat/gygax, /obj/mecha/combat/phazon, /obj/mecha/combat/honker, /obj/mecha/combat/reticence)
// All mechs (Unless you mean literally ALL mechs, don't use this)
#define COMPATIBLE_MECHA_ALL typesof(/obj/mecha)
// Common combat mechs
#define COMPATIBLE_MECHA_COMBAT list(/obj/mecha/combat/durand, /obj/mecha/combat/gygax, /obj/mecha/combat/phazon)
// Single mechs
#define COMPATIBLE_MECHA_RIPLEY list(/obj/mecha/working/ripley, /obj/mecha/working/ripley/firefighter, /obj/mecha/working/ripley/deathripley)
#define COMPATIBLE_MECHA_ODYSSEUS list(/obj/mecha/medical/odysseus)
#define COMPATIBLE_MECHA_DURAND list(/obj/mecha/combat/durand)
#define COMPATIBLE_MECHA_GYGAX list(/obj/mecha/combat/gygax)
#define COMPATIBLE_MECHA_PHAZON list(/obj/mecha/combat/phazon)
#define COMPATIBLE_MECHA_HONKER list(/obj/mecha/combat/honker)
#define COMPATIBLE_MECHA_RETICENCE list(/obj/mecha/combat/reticence)

////////////
// Decals //
////////////
// Defines a single overlay to be applied to a mech. Icon is pulled by combining the mech's root decal string ([mech_type]-decal)
// with the decal's decal string and a state modifier for the final form [mech_type]-decal-[decal_string] (-open, -broken).
// 
// A typical set of icons contains 3 states: one 4-directional one for a moving, occupied mech, one for an unoccupied open mech and 
// one for a destroyed mech. If you do not need an icon for one or more of those states, PLEASE remember to set the corresponding 
// has_state flag; Failing to do so will cause issues with the layering.
//
/datum/mecha/mecha_decal
    var/decal_string                        // The string which is added to the mech's decal_root in order to apply the icon. 
    var/decal_name                          // The name shown by the decal UI.
    var/mutable_colour = FALSE              // Whether the colour can be set. Off for things with a set colour, like the nanotrasen logo.
    var/glowing = FALSE                     // Determines the layer the overlays are placed on. Will shine in the dark if true.
    var/decal_layer = 1                     // The higher the decal layer, the less things will cover it.
    var/decal_colour = "#000000"            // If the colour can be set, it is read from here when determining overlays.
    var/can_strip = TRUE                    // Mech default decals have this automatically set to false.
    var/list/obj/mecha/compatible_mecha     // Which mech types the kit can be applied to.

    // Used to correctly render layering effects. Set to false if your decal doesn't have one of these states or bad things will happen.
    var/has_state_occupied = TRUE           // Does a state exist which represents an occupied mech?
    var/has_state_open = TRUE               // Does a state exist which represents an open mech?
    var/has_state_broken = TRUE             // Does a state exist which represents an destroyed mech?

/datum/mecha/mecha_decal/proc/clone()          // Creates a copy of itself to be stored in the mecha being painted.
    var/datum/mecha/mecha_decal/copy = new()
    copy.decal_string = decal_string
    copy.decal_name = decal_name
    copy.mutable_colour = mutable_colour
    copy.glowing = glowing
    copy.decal_layer = decal_layer
    copy.decal_colour = decal_colour
    copy.compatible_mecha = compatible_mecha
    copy.has_state_occupied = has_state_occupied
    copy.has_state_open = has_state_open
    copy.has_state_broken = has_state_broken
    return copy

// DECAL DEFINITIONS
/datum/mecha/mecha_decal/stripes
    decal_string = "stripes"
    decal_name = "Racing Stripes"
    mutable_colour = TRUE
    decal_colour = "#A00000"  
    compatible_mecha = COMPATIBLE_MECHA_RIPLEY

/datum/mecha/mecha_decal/nanotrasen_logo
    decal_string = "nt_logo"
    decal_name = "Nanotrasen Logo"
    decal_layer = 2
    mutable_colour = FALSE
    decal_colour = "#000000"  
    compatible_mecha = COMPATIBLE_MECHA_COMMON
    has_state_open = FALSE

/datum/mecha/mecha_decal/syndicate_logo
    decal_string = "syn_logo"
    decal_name = "Syndicate Logo"
    decal_layer = 2
    mutable_colour = FALSE
    decal_colour = "#000000"  
    compatible_mecha = COMPATIBLE_MECHA_COMMON
    has_state_open = FALSE

/datum/mecha/mecha_decal/titan
    decal_string = "titan"
    decal_name = "Titan Skull"
    mutable_colour = FALSE
    decal_layer = 3
    compatible_mecha = COMPATIBLE_MECHA_RIPLEY

/datum/mecha/mecha_decal/titaneyes
    decal_string = "titaneyes"
    decal_name = "Titan Eyes"
    mutable_colour = TRUE
    glowing = TRUE
    decal_layer = 4
    decal_colour = "#00AB00"
    compatible_mecha = COMPATIBLE_MECHA_RIPLEY

/datum/mecha/mecha_decal/deathripley
    decal_string = "deathripley"
    decal_name = "Death Ripley"
    mutable_colour = TRUE
    decal_layer = 2
    decal_colour = "#8C0000"
    compatible_mecha = COMPATIBLE_MECHA_RIPLEY

/datum/mecha/mecha_decal/odysseus_visor
    decal_string = "visor"
    decal_name = "Odysseus Visor"
    mutable_colour = TRUE
    decal_layer = 1
    decal_colour = "#857149"
    compatible_mecha = COMPATIBLE_MECHA_ODYSSEUS  

// HONKER DECALS OH GOD
// Honker has a whopping 11 default decals allowing each individual body part to be recoloured.
// Honkers also have the ability to randomize all their colours. It's a hell of a stress test and gloriously tasteless.

/datum/mecha/mecha_decal/honker_nose
    decal_string = "h_nose"
    decal_name = "Honker Nose"
    mutable_colour = TRUE
    glowing = TRUE
    decal_layer = 1
    decal_colour = "#8c0000"
    has_state_broken = FALSE
    compatible_mecha = COMPATIBLE_MECHA_HONKER

/datum/mecha/mecha_decal/honker_hair
    decal_string = "h_hair"
    decal_name = "Honker Hair"
    mutable_colour = TRUE
    decal_layer = 1
    decal_colour = "#603300"
    compatible_mecha = COMPATIBLE_MECHA_HONKER

/datum/mecha/mecha_decal/honker_arms
    decal_string = "h_arms"
    decal_name = "Honker Arms"
    mutable_colour = TRUE
    decal_layer = 1
    decal_colour = "#790000"
    compatible_mecha = COMPATIBLE_MECHA_HONKER

/datum/mecha/mecha_decal/honker_braces
    decal_string = "h_braces"
    decal_name = "Honker Braces"
    mutable_colour = TRUE
    decal_layer = 1
    decal_colour = "#8b0000"
    has_state_open = FALSE
    compatible_mecha = COMPATIBLE_MECHA_HONKER

/datum/mecha/mecha_decal/honker_horn
    decal_string = "h_horn"
    decal_name = "Honker Horn"
    mutable_colour = TRUE
    decal_layer = 1
    decal_colour = "#2d2d2d"
    has_state_broken = FALSE
    compatible_mecha = COMPATIBLE_MECHA_HONKER

/datum/mecha/mecha_decal/honker_legs
    decal_string = "h_legs"
    decal_name = "Honker Legs"
    mutable_colour = TRUE
    decal_layer = 1
    decal_colour = "#790000"
    compatible_mecha = COMPATIBLE_MECHA_HONKER

/datum/mecha/mecha_decal/honker_mortar
    decal_string = "h_mortar"
    decal_name = "Honker Mortar"
    mutable_colour = TRUE
    decal_layer = 1
    decal_colour = "#790000"
    compatible_mecha = COMPATIBLE_MECHA_HONKER

/datum/mecha/mecha_decal/honker_mouth
    decal_string = "h_mouth"
    decal_name = "Honker Mouth"
    mutable_colour = TRUE
    decal_layer = 2
    decal_colour = "#7f0000"
    compatible_mecha = COMPATIBLE_MECHA_HONKER

/datum/mecha/mecha_decal/honker_shoes
    decal_string = "h_shoes"
    decal_name = "Honker Shoes"
    mutable_colour = TRUE
    decal_layer = 1
    decal_colour = "#7f0000"
    compatible_mecha = COMPATIBLE_MECHA_HONKER

/datum/mecha/mecha_decal/honker_vest
    decal_string = "h_vest"
    decal_name = "Honker Vest"
    mutable_colour = TRUE
    decal_layer = 1
    decal_colour = "#730000"
    compatible_mecha = COMPATIBLE_MECHA_HONKER

/datum/mecha/mecha_decal/honker_stripes
    decal_string = "h_stripes"
    decal_name = "Honker Stripes"
    mutable_colour = TRUE
    decal_layer = 1
    decal_colour = "#808080"
    compatible_mecha = COMPATIBLE_MECHA_HONKER

////////////////////
// Decal Patterns //
////////////////////
// Container object which may hold more than one pattern. Must be installed in a paint gun prior to use.
// Decals are added to the mech in sequential order.

/obj/item/mecha_decal_container
    name = "exosuit decal chip"
    desc = "A wafer-thin data storage card made to slot into an exosuit paint gun."
    icon = 'icons/mecha/mecha_decals.dmi'
    icon_state = "pattern-chip"
    w_class = WEIGHT_CLASS_TINY

    var/decal_name                                      // The name shown by the decal UI.
    var/list/datum/mecha/mecha_decal/decals             // Contained decals
    var/list/obj/mecha/compatible_mecha = list()        // Mechs this pattern may be applied to.
    var/basecoat                                        // If set to a colour, overwrites the mech's base colour on application.
    var/glow                                            // If set to a colour, overwrites the mech's glow colour on application.
    var/deletable = FALSE                               // If true, the paint gun UI will present an option to delete this item. Always true for custom decal kits.

/obj/item/mecha_decal_container/proc/install_on_mecha(obj/mecha/M)
    if(decals && (M.type in compatible_mecha))
        for(var/datum/mecha/mecha_decal/decal in decals)
            M.add_decal(decal.clone())
        if(basecoat)
            M.basecoat_colour = basecoat
        if(glow)
            M.glow_colour = glow
        return TRUE
    else
        to_chat(usr, "<span class='warning'>[src] is not compatible with [M]!</span>")
        return FALSE

/obj/item/mecha_decal_container/examine()
    . = ..()

// PATTERN DEFINITIONS

// Ripley Compatible
/obj/item/mecha_decal_container/Initialize()
    ..()
    name = "exosuit decal chip ([decal_name])"

/obj/item/mecha_decal_container/titan/Initialize()
    decal_name = "Titan's Fist Ripley"
    decals = list(new/datum/mecha/mecha_decal/titan, new/datum/mecha/mecha_decal/titaneyes)
    compatible_mecha = COMPATIBLE_MECHA_RIPLEY
    ..()

/obj/item/mecha_decal_container/nanotrasen_logo/Initialize()
    decal_name = "NT Logo"
    decals = list(new/datum/mecha/mecha_decal/nanotrasen_logo)
    compatible_mecha = COMPATIBLE_MECHA_COMMON
    ..()

/obj/item/mecha_decal_container/syndicate_logo/Initialize()
    icon_state = "pattern-chip-syn"
    decal_name = "Syndicate Logo"
    desc = "A wafer-thin card made to slot into an exosuit paint gun. This one looks quite suspicious."
    decals = list(new/datum/mecha/mecha_decal/syndicate_logo)
    compatible_mecha = COMPATIBLE_MECHA_COMMON
    ..()

/obj/item/mecha_decal_container/stripes/Initialize()
    decal_name = "Stripes"
    decals = list(new/datum/mecha/mecha_decal/stripes)
    compatible_mecha = COMPATIBLE_MECHA_RIPLEY
    ..()

/obj/item/mecha_decal_container/deathripley/Initialize()
    decal_name = "Death Ripley"
    decals = list(new/datum/mecha/mecha_decal/deathripley)
    compatible_mecha = COMPATIBLE_MECHA_RIPLEY
    ..()

#undef COMPATIBLE_MECHA_COMMON
#undef COMPATIBLE_MECHA_ALL_CONSTRUCTABLE
#undef COMPATIBLE_MECHA_RIPLEY
#undef COMPATIBLE_MECHA_ODYSSEUS
#undef COMPATIBLE_MECHA_DURAND
#undef COMPATIBLE_MECHA_GYGAX
#undef COMPATIBLE_MECHA_PHAZON
#undef COMPATIBLE_MECHA_HONKER
#undef COMPATIBLE_MECHA_RETICENCE




