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
	var/icon/base_icon = make_map()
	var/icon/alpha_mask = icon('icons/effects/480x480.dmi', "scanline")//Scanline effect.
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


/*GAME PLAN

	1 -> make image size of 255*32
	2 -> paint exterior walls and windows 2x2 (everytile in space alldirs check for area != space or nearspace)
	3 -> paint interior walls 1x2 (start from maints, then hallways, then go department to department area by area)
	  -- maint walls we favor the half of the wall up against the maint to paint, same with hallways
	  -- for rooms we paint the half of the wall not shared w/ the room in question
	4 -> paint airlocks (lead into area that shared w/ airlock)
	5 -> color all painted things using custom area color key
	6 -> shrink to 480x480 & save to file

	Figure out how the hell nanomaps do this, bruh

 */

/obj/machinery/holomap/proc/make_map()
	var/icon/bigassicon = icon('icons/effects/480x480',"blank")
	for(var/x_index in 1 to 240)
		for(var/y_index in 1 to 240)
			var/turf/T = locate(x_index, y_index, 2)
			var/area/A = get_area(T)
			var/icon/I = icon('icons/effects/holomap_parts.dmi')

			if(isfloor(T))
				icon_state = "floor"
			else if(iswall(T) || locate(/obj/structure/window) in T)
				var/list/cardinals = list(NORTH, SOUTH, EAST, WEST)
				I.icon_state = "full"
				I.dir = 0
				for(var/i in 1 to 4)
					var/turf/found_turf = get_step(T, cardinals[i])
					var/area/found_area = get_area(found_turf)
					if(found_area == /area/space)
						I.icon_state = "full" //repeated since we might have set it to be "wall" already
						break
					if(found_area != A)
						I.icon_state = "wall"
						I.dir << cardinals[i] //this will work right... surely
			else //if its space then nothing
				continue

			I.SwapColor(COLOR_WHITE, get_area_color(A))

			bigassicon.Blend(I, ICON_OVERLAY, x_index*2, y_index*2)

	return bigassicon

/obj/machinery/holomap/proc/get_area_color(area/A)
	//AI SAT
	if(istype(A, area/turret_protected) || istype(A, area/aisat))
		return "#009180"

	//COMMAND
	if(istype(A, area/bridge) || istype(A, area/teleporter) || istype(A, area/heads) || istype(A, area/blueshield) || istype(A, area/ai_monitored) || istype(A, area/security/nuke_storage) || istype(A, area/server) || istype(A, area/crew_quarters/hor))
		return "#08009f"

	//SECURITY
	if(istype(A, area/security) || istype(A, area/lawoffice) || istype(A, area/crewquarters/courtroom) || istype(A, area/magistrateoffice))
		return "#d00000"

	//RESEARCH
	if(istype(A, area/toxins) || istype(A, area/medical/research) || istype(A, area/assembly/robotics) || istype(A, area/assembly/chargebay))
		return "#9e00dd"

	//MEDBAY
	if(istype(A, area/medical))
		return "#3ad8ff"

	//ENGINEERING
	if(istype(A, area/engine) || istype(A, area/storage) || istype(A, area/atmos) || istype(A, area/maintenance/electrical) || istype(A, area/maintenance/turbine) || istype(A, area/maintenance/incinerator))
		return "#f1d100"

	//CARGO
	if(istype(A, area/quartermaster) || istype(A, area/maintenance/disposal))
		return "#a27749"

	//SERVICE
	if(istype(A, area/crew_quarters/bar) || istype(A, area/crew_quarters/theatre) || istype(A, area/crew_quarters/kitchen) || istype(A, area/crew_quarters/cafe) || istype(A, area/mimeoffice) || istype(A, area/clownoffice) || istype(A, area/hydroponics) || istype(A, area/library) || istype(A, area/chapel))
		return "#23940d"

	//DORMS + HALLS
	if(istype(A, area/hallway) || istype(A, area/crew_quarters) || istype(A, area/civilian))
		return "#b6b6b6"

	//maints + unspecified
	return "#373a2a"

