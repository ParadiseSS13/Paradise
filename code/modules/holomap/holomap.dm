/*
NOTE: the maps are still images in icons/effects/holomaps.dmi
	- they use map's technical name as their name, name any new images added to the dmi this
	- the maps are made from taking full sized renders of the map files as a png, resizing it to 480x480 pixels, and then painting exterior walls 2x2 and interior 1x1
	- doorways to maint are just 2x1 pixel openings, all other doorways should have single pixels off the walls that make the door leading into a room
	- thats just the style I used, otherwise go wild :o)

TO DO: add ability to somehow select from common locations to display, and put a respective marker on the map
*/

/obj/machinery/holomap
	name = "Holomap"
	desc = "It displays a holographic map of the station."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "map"
	anchored = TRUE
	idle_power_usage = 5
	active_power_usage = 15
	var/display_map //for mappers who want to add holomaps for off station locations, otherwise it gets set in Initialize()
	var/list/display_targets = list()
	var/image/holomap_projection
	var/image/YouAreHere

/obj/machinery/holomap/Initialize(mapload)
	. = ..()
	if(!display_map)
		display_map = SSmapping.map_datum.technical_name
	var/icon/base_icon = icon('icons/effects/holomaps.dmi', display_map)
	var/icon/alpha_mask = icon('icons/effects/holomaps.dmi', "scanline")//Scanline effect.
	base_icon.AddAlphaMask(alpha_mask)
	holomap_projection = image(base_icon, loc = src, layer = ABOVE_HUD_PLANE, pixel_x = -240, pixel_y = -208)
	holomap_projection.plane = ABOVE_HUD_PLANE
	YouAreHere = image('icons/effects/holomapicons.dmi', src, "YouAreHere", 22.1 , 2, ((480/255) * x) - 256, ((480/255) * y) - 226)
	YouAreHere.plane = 22.1

/obj/machinery/holomap/attack_hand(mob/user)
	. = ..()
	if(stat & (NOPOWER|BROKEN) || user.incapacitated() || !user.Adjacent(src))
		return

	if(!ishuman(user))
		atom_say("Unable to locate subject's optical organ. Place optical organ infront of device and try again.")
		return

	if(emagged)
		var/mob/living/carbon/M = user
		M.flash_eyes(2, 1)
	if(locate(user) in display_targets)
		stopdisplaymap(user)
	else
		displaymap(user)

/obj/machinery/holomap/proc/displaymap(mob/M)
	if(!M.client)
		return
	display_targets.Add(M)
	M.client.images += YouAreHere
	M.client.images += holomap_projection
	update_icon()
	if(do_after(M, 5 MINUTES, FALSE, src, FALSE))
		atom_say("Maximum display time reached, shutting down session.")
		stopdisplaymap(M)
	else
		stopdisplaymap(M)

/obj/machinery/holomap/proc/stopdisplaymap(mob/user)
	display_targets.Remove(user)
	user.client.images -= holomap_projection
	user.client.images -= YouAreHere
	update_icon()

/obj/machinery/holomap/update_icon()
	if(stat & (NOPOWER|BROKEN))
		icon_state = "map_off"
		return

	if(length(display_targets))
		icon_state = "map_projecting"
	else if(emagged)
		icon_state = "map_emag"
	else
		icon_state = "map"

/obj/machinery/holomap/emag_act(user as mob)
	emagged = TRUE
	to_chat(user, "You short out the emission regulators of [src]!")
	for(var/mob/living/carbon/M in display_targets)
		M.flash_eyes(2, 1)

/obj/machinery/holomap/power_change()
	. = ..()
	update_icon()
