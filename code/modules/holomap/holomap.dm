/*
	Somone should totally add an action button to select a location when observing the map
	and it display a list to select from (TGUI maybe!? color coded !? YES?)
	then show an icon like you_are_here there
*/

///this will hold images rendered at roundstart
GLOBAL_LIST_EMPTY(holomaps)

/datum/holomap
	var/obj/screen/holomap/using
	var/obj/screen/you_are_here/arrow

/datum/holomap/New(list/r, zed, x_in, y_in, z_in)
	..()

	var/icon_key = "[zed]_[r[1]]-[r[2]]-[r[3]]-[r[4]]"

	if(GLOB.holomaps[icon_key])
		using = GLOB.holomaps[icon_key]
	else
		using = new/obj/screen/holomap(r, zed)
		using.screen_loc = ui_holomap
		GLOB.holomaps[icon_key] = using

	if(zed == z_in)
		arrow = new/obj/screen/you_are_here(x_in, y_in)

/obj/screen/holomap
	var/image/holomap_projection
	var/list/region_selection = list()
	var/zlevel_rendered

/obj/screen/holomap/New(list/region, rendered)
	..()

	screen_loc = ui_holomap
	region_selection = region
	zlevel_rendered = rendered

	var/icon/base_icon

	base_icon = make_map()
	var/icon/alpha_mask = icon('icons/effects/480x480.dmi', "scanline") //Scanline effect.
	base_icon.AddAlphaMask(alpha_mask)
	holomap_projection = image(base_icon, loc = vis_contents, layer = ABOVE_HUD_PLANE)
	holomap_projection.plane = ABOVE_HUD_PLANE
	holomap_projection.filters = filter(type = "drop_shadow", size = 8, color = "#ffffffd4")

	appearance = holomap_projection

/obj/screen/you_are_here
	name = "You are here!"
	icon = 'icons/effects/holomap_icons.dmi'
	icon_state = "you_are_here"
	layer = ABOVE_HUD_LAYER + 0.1
	plane = ABOVE_HUD_PLANE

/obj/screen/you_are_here/New(x_in, y_in)
	..()
	//these are the tile position from center 0 upto +7 and -7)
	var/big_x = round((x_in - 128) / 16, 1)
	var/big_y = round((y_in - 128) / 16, 1)
	//these are the pixel position from the tile position anywhere from 0 upto +16 and -16)
	var/small_x = (((x_in - 8) * 2) % 32) - 16
	var/small_y = (((y_in - 8) * 2) % 32) - 16
	//we have to put the correct sign infrot of them for the screen_loc system to recognise it
	big_x = big_x == 0 ? "" : big_x > 0 ? "+[big_x]" : big_x
	big_y = big_y == 0 ? "" : big_y > 0 ? "+[big_y]" : big_y

	screen_loc = "CENTER[big_x][small_x == "" ? "" : ":[small_x]"],CENTER[big_y][small_y == "" ? "" : ":[small_y]"]"

/obj/machinery/holomap
	name = "Holomap"
	desc = "It displays a holographic map of the station."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "map"
	anchored = TRUE
	idle_power_consumption = 5
	active_power_consumption = 15
	///this is so you can have holomap display other zlevels, default is the one its on
	var/zlevel_rendered
	//for mappers who want to add holomaps for off station locations, otherwise it defaults to the entire zlevel in Initialize()
	//use sparingly, dont make regions different only by a few values, just make it a single one across both instances (they are very costly to make and store)
	/// should be a list {start x, start y, end x, end y} start should be bottom left corner; end should be top right... everything inside gets rendered (out of 255)
	var/list/region_selection = list(1, 1, 255, 255)
	/// this holds all the people it is currently displaying to
	var/list/display_targets = list()
	/// the screen obj that holds the image for your viewing pleasure
	var/datum/holomap/my_map

/obj/machinery/holomap/Initialize(mapload)
	. = ..()

	if(!zlevel_rendered)
		zlevel_rendered = z

	my_map = new /datum/holomap(region_selection, zlevel_rendered, x, y, z)

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
	if(user in display_targets)
		stopdisplaymap(user)
	else
		displaymap(user)

/obj/machinery/holomap/proc/displaymap(mob/M)
	if(!M.client)
		return
	display_targets |= M
	M.client.screen += my_map.using
	M.client.screen += my_map.arrow
	update_icon(UPDATE_ICON)
	if(do_after(M, 5 MINUTES, FALSE, src, FALSE))
		atom_say("<span class='warning'>Maximum display time reached, shutting down session.</span>")
		stopdisplaymap(M)
	else
		stopdisplaymap(M)

/obj/machinery/holomap/proc/stopdisplaymap(mob/user)
	display_targets -= user
	user.client.screen -= my_map.using
	user.client.screen -= my_map.arrow
	update_icon(UPDATE_ICON)

/obj/machinery/holomap/update_icon()
	. = ..()

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

/obj/screen/holomap/proc/make_map()
	var/icon/bigassicon = icon('icons/effects/480x480.dmi',"blank")
	/*
		We're using a 480x480 icon since thats 15x15 32x32 tiles (default view range)
		Since maps aren't that (they are 255x255) the compromise is defaulting to render
		starting from [9,9] up to [248,248] which is the center portion of the map with
		a border of 8 tiles that get culled. This can be changed with `region_selection`;
		Any region larger than 240 will have its edges culled to fit, regardless of the
		region size it will be centered in the `bigassicon`. Happy Viewing.
	*/
	var/region_width = (region_selection[3] - region_selection[1]) + 1
	var/region_height = (region_selection[4] - region_selection[2]) + 1

	var/region_x_start = (region_width > 240) ? 9 : region_selection[1]
	var/region_y_start = (region_height > 240) ? 9 : region_selection[2]

	var/region_x_finish = (region_width > 240) ? region_x_start + 239 : region_selection[3]
	var/region_y_finish = (region_width > 240) ? region_y_start + 239 : region_selection[4]

	var/render_x_start = (region_width > 240) ? -8 : 128 - (region_width / 2)
	var/render_y_start = (region_width > 240) ? -8 : 128 - (region_height / 2)

	var/icon_to_use = 'icons/effects/holomap_parts.dmi'

	for(var/x_index in region_x_start to region_x_finish)
		for(var/y_index in region_y_start to region_y_finish)
			var/turf/T = locate(x_index, y_index, zlevel_rendered)
			var/area/A = get_area(T)
			var/W = FALSE
			for(var/obj/structure/window/full/WW in T.contents)
				W = TRUE
				break
			for(var/obj/effect/spawner/window/WW in T.contents)
				W = TRUE
				break

			/*
				This works by using 2x2 sprites from 'icons/effects/holomap_parts.dmi' to construct the holomap;
				We use different colors that we will swap later on for floors and walls (BLACK-->floor;WHITE-->wall)
				The walls can either be a full 2x2 pixel box, 1x2 pixel wall, or a 3/4 pixel corner depending on their surroundings...
				All the following logic is to determine what icon to use.
			*/
			//this is what all the logic is for, setting this variable
			var/icon_state_to_use
			//as well as this since it modifies the wall sprite
			var/dir_to_use = 2

			//the following variables are set conditionally on the state of the turf
			//so we can render the right sprite for this turf
			var/neighbor_space = FALSE
			var/list/neighbors_alien = list()
			var/list/neighbors_solid = list()

	//--------------{{{ DISCOVERY PHASE }}}------------------------------

			for(var/i in GLOB.cardinal)
				var/turf/found_turf = get_step(T, i)
				var/area/found_area = get_area(found_turf)
				var/found_window = FALSE

				for(var/obj/structure/window/full/WW in found_turf.contents)
					found_window = TRUE
					break
				for(var/obj/effect/spawner/window/WW in found_turf.contents)
					found_window = TRUE
					break

				for(var/j in GLOB.diagonals)
					var/turf/found_s_turf = get_step(T, j)
					var/area/found_s_area = get_area(found_s_turf)
					if(found_s_area == /area/space || isspaceturf(found_s_turf))
						neighbor_space = TRUE
						break

				if(neighbor_space || found_area == /area/space || isspaceturf(found_turf))
					neighbor_space = TRUE
					break

				if(found_area != A || locate(/obj/machinery/door/airlock) in found_turf)
					neighbors_alien += i
					continue

				if(iswallturf(found_turf) || istype(found_turf, /turf/simulated/mineral) || found_window)
					neighbors_solid += i

	//-----------------{{{ RENDERING PHASE }}}----------------------------

			if(neighbor_space || length(neighbors_solid) >= 3)
				if(iswallturf(T) || istype(T, /turf/simulated/mineral) || W)
					icon_state_to_use = "full"
				else if(isfloorturf(T))
					icon_state_to_use = "floor"

			//--> (not next to space; not surrounded; less than 3 solid neighbors)
			else if(iswallturf(T) || istype(T, /turf/simulated/mineral) || W)
				if(length(neighbors_alien) == 1)
					icon_state_to_use = "wall"
					if(length(neighbors_solid) == 1)
						if((neighbors_alien[1] == NORTH && neighbors_solid[1] == SOUTH) || (neighbors_alien[1] == WEST && neighbors_solid[1] == EAST))
							dir_to_use = NORTHWEST
						else if(neighbors_alien[1] == SOUTH && neighbors_solid[1] == NORTH)
							dir_to_use = SOUTHWEST
						else if(neighbors_alien[1] == EAST && neighbors_solid[1] == WEST)
							dir_to_use = NORTHEAST
						else
							dir_to_use = neighbors_alien[1]
					else
						dir_to_use = neighbors_alien[1]
				else if(length(neighbors_alien) == 2)
					icon_state_to_use = "wall"
					if((neighbors_alien[1] == NORTH && neighbors_alien[2] == SOUTH))
						icon_state_to_use = "full"
					else if((neighbors_alien[1] == NORTH && neighbors_alien[2] == EAST))
						dir_to_use = NORTHEAST
					else if(neighbors_alien[1] == NORTH && neighbors_alien[2] == WEST)
						dir_to_use = NORTHWEST
					else if(neighbors_alien[1] == SOUTH && neighbors_alien[2] == EAST)
						dir_to_use = SOUTHEAST
					else if(neighbors_alien[1] == SOUTH && neighbors_alien[2] == WEST)
						dir_to_use = SOUTHWEST
				else
					switch(length(neighbors_solid))
						if(0)
							icon_state_to_use =  "full"
						if(1)
							if(length(neighbors_alien))
								icon_state_to_use =  "full"
							else
								icon_state_to_use = "wall"
								if(neighbors_solid[1] == SOUTH || neighbors_solid[1] == NORTH)
									dir_to_use = WEST
								else if(neighbors_solid[1] == EAST || neighbors_solid[1] == WEST)
									dir_to_use = NORTH
						if(2)
							if(length(neighbors_alien))
								icon_state_to_use =  "full"
							else
								icon_state_to_use = "wall"
								if(neighbors_solid[1] == NORTH && neighbors_solid[2] == SOUTH)
									dir_to_use = WEST
								else if((neighbors_solid[1] == NORTH && neighbors_solid[2] == EAST))
									dir_to_use = NORTH
								else if(neighbors_solid[1] == NORTH && neighbors_solid[2] == WEST)
									dir_to_use = NORTH
								else if(neighbors_solid[1] == SOUTH && neighbors_solid[2] == EAST)
									dir_to_use = NORTHWEST
								else if(neighbors_solid[1] == SOUTH && neighbors_solid[2] == WEST)
									dir_to_use = WEST
								else if(neighbors_solid[1] == EAST && neighbors_solid[2] == WEST)
									dir_to_use = NORTH
			else if(isfloorturf(T))
				icon_state_to_use = "floor"

			//finally we can create the icon we are gonna use
			var/icon/I = icon(icon_to_use, icon_state_to_use, dir_to_use)

			//replace the black and white with the appropriate colors of the area
			if(icon_state_to_use) //no point in running the checks without any pixels to color
				I.SwapColor(COLOR_WHITE, get_area_color(A.type))
				I.SwapColor(COLOR_BLACK, get_area_color(A.type, TRUE))

			bigassicon.Blend(I, ICON_OVERLAY, ((render_x_start + x_index) * 2) - 1, ((render_y_start + y_index) * 2) - 1)

	return bigassicon

	#define DEPARTMENTAL_AREAS_MASTERLIST list(DEPARTMENTAL_AREAS_SHUTTLE, DEPARTMENTAL_AREAS_AISAT, DEPARTMENTAL_AREAS_COMMAND, DEPARTMENTAL_AREAS_SECURITY, DEPARTMENTAL_AREAS_RESEARCH, DEPARTMENTAL_AREAS_MEDICAL, DEPARTMENTAL_AREAS_ENGINEERING, DEPARTMENTAL_AREAS_CARGO, DEPARTMENTAL_AREAS_SERVICE, DEPARTMENTAL_AREAS_DORMS, DEPARTMENTAL_AREAS_ROCK)

	//-----first list is whitelist
	//-----second list is blacklist
	//-----third is for floor color
	//-----fourth is for wall color

	#define DEPARTMENTAL_AREAS_SHUTTLE list(list(/area/shuttle), list(), "#bdbdbd",  "#FFFFFF")

	#define DEPARTMENTAL_AREAS_AISAT list(list(/area/turret_protected, /area/aisat, /area/tcommsat), list(), "#144640", "#009180")

	#define DEPARTMENTAL_AREAS_COMMAND list(list(/area/bridge, /area/teleporter, /area/crew_quarters/heads, /area/crew_quarters/chief, /area/crew_quarters/captain, /area/ntrep, /area/blueshield, /area/ai_monitored, /area/security/nuke_storage, /area/server, /area/crew_quarters/hor, /area/solar,	/area/engine/chiefs_office,	/area/medical/cmo, /area/security/hos), list(/area/teleporter/quantum), "#1e1a5e", "#08009f")

	#define DEPARTMENTAL_AREAS_SECURITY list(list(/area/security, /area/security/vacantoffice2, /area/lawoffice, /area/crew_quarters/courtroom, /area/magistrateoffice), list(/area/security/vacantoffice), "#7c090d", "#d00000")

	#define DEPARTMENTAL_AREAS_RESEARCH list(list(/area/toxins, /area/medical/research,	/area/assembly/robotics, /area/assembly/chargebay), list(), "#6a0b79", "#9e00dd")

	#define DEPARTMENTAL_AREAS_MEDICAL list(list(/area/medical), list(), "#1d849e", "#3ad8ff")

	#define DEPARTMENTAL_AREAS_ENGINEERING list(list(/area/engine, /area/storage/tech, /area/storage/secure, /area/atmos, /area/maintenance/electrical,	/area/maintenance/turbine, /area/maintenance/incinerator, /area/maintenance/portsolar, /area/maintenance/starboardsolar, /area/maintenance/auxsolarport, /area/maintenance/auxsolarstarboard), list(),"#766e00", "#f1d100")

	#define DEPARTMENTAL_AREAS_CARGO list(list(/area/quartermaster, /area/maintenance/disposal), list(/area/maintenance/disposal/external), "#5c4429", "#a27749")

	#define DEPARTMENTAL_AREAS_SERVICE list(list(/area/crew_quarters/bar, /area/crew_quarters/theatre, /area/crew_quarters/kitchen,	/area/crew_quarters/cafe, /area/mimeoffice, /area/clownoffice, /area/hydroponics, /area/library, /area/chapel, /area/janitor, /area/expedition), list(/area/hydroponics/abandoned_garden), "#0b5916", "#23940d")

	#define DEPARTMENTAL_AREAS_DORMS list(list(/area/hallway, /area/crew_quarters, /area/civilian, /area/teleporter/quantum, /area/storage, /area/holodeck), list(), "#6c6c6c", "#b6b6b6")

	#define DEPARTMENTAL_AREAS_ROCK list(list(/area/mine/unexplored/cere), list(), "#51473c", "#715c51")


/obj/screen/holomap/proc/get_area_color(area_type, is_floor=FALSE)
	var/found_it = FALSE
	for(var/list/k in DEPARTMENTAL_AREAS_MASTERLIST)
		for(var/i in k[1])
			if(found_it)
				break
			if(area_type == i)
				found_it = TRUE
				break
			var/list/types_to_compare = typesof(i)
			for(var/j in types_to_compare)
				if(area_type == j)
					found_it = TRUE
					break
		if(found_it)
			for(var/i in k[2])
				if(!found_it)
					break
				if(area_type == i)
					found_it = FALSE
					break
				var/list/types_to_compare = typesof(i)
				for(var/j in types_to_compare)
					if(area_type == j)
						found_it = FALSE
						break
		if(found_it)
			return is_floor ? k[3] : k[4]

	//maints + unspecified
	return is_floor ? "#171e16" : "#373a2a"




