/*
	Somone should totally add an action button to select a location when observing the map
	and it display a list to select from (TGUI maybe!? color coded !? YES?)
	then show an icon like YouAreHere there
*/

///this will hold images rendered at roundstart
GLOBAL_LIST_EMPTY(holomaps)

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
	///should be a list {start x, start y, end x, end y} start should be bottom left corner; end should be top right... everything inside gets rendered (out of 255)
	var/list/region_selection = list(1,1,255,255)
	///this holds all the people it is currently displaying to
	var/list/display_targets = list()
	///this is set in Initialize with the correct offsets of the machine's position in the zlevel
	var/image/YouAreHere
	//this is the conditioned icon from the cache that will be displayed to users
	var/image/holomap_projection

/obj/machinery/holomap/Initialize(mapload)
	. = ..()

	zlevel_rendered = z

	var/icon/base_icon
	var/icon_key = "[zlevel_rendered]_[region_selection[1]]-[region_selection[2]]-[region_selection[3]]-[region_selection[4]]"

	if(GLOB.holomaps[icon_key])
		base_icon = GLOB.holomaps[icon_key]
	else
		base_icon = make_map()
		var/icon/alpha_mask = icon('icons/effects/480x480.dmi', "scanline") //Scanline effect.
		base_icon.AddAlphaMask(alpha_mask)
		GLOB.holomaps[icon_key] = base_icon

	holomap_projection = image(base_icon, loc = src, layer = ABOVE_HUD_PLANE, pixel_x = -240, pixel_y = -240)
	holomap_projection.plane = ABOVE_HUD_PLANE
	holomap_projection.filters = filter(type = "drop_shadow", size = 8, color = "#ffffffd4")
	YouAreHere = image('icons/effects/holomap_icons.dmi', src, "YouAreHere", 22.1 , 2, -256+(x*2), -256+(y*2))
	YouAreHere.plane = ABOVE_HUD_PLANE + 0.1

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
	M.vis_contents += YouAreHere
	M.vis_contents += holomap_projection
	M.client.images += YouAreHere
	M.client.images += holomap_projection
	update_icon()
	if(do_after(M, 5 MINUTES, FALSE, src, FALSE))
		atom_say("<span class='warning'>Maximum display time reached, shutting down session.</span>")
		stopdisplaymap(M)
	else
		stopdisplaymap(M)

/obj/machinery/holomap/proc/stopdisplaymap(mob/user)
	display_targets -= user
	user.client.images -= holomap_projection
	user.client.images -= YouAreHere
	update_icon()

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

/obj/machinery/holomap/proc/make_map()
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

	var/render_x_start = 128 - (region_width / 2)
	var/render_y_start = 128 - (region_height / 2)

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

				if(iswallturf(found_turf) || istype(found_turf, /turf/simulated/mineral) || found_window)
					neighbors_solid += i

			if(neighbor_space || length(neighbors_solid) >= 3)
				if(iswallturf(T) || istype(T, /turf/simulated/mineral) || W)
					icon_state_to_use = "full"
				else if(isfloorturf(T))
					icon_state_to_use = "floor"


			//--> (not next to space; not surrounded; less than 3 solid neighbors)
			else if(iswallturf(T) || istype(T, /turf/simulated/mineral) || W)
				if(length(neighbors_alien) == 1)
					icon_state_to_use = "wall"
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
			I.SwapColor(COLOR_WHITE, get_area_color(A))
			I.SwapColor(COLOR_BLACK, get_area_color(A, TRUE))

			bigassicon.Blend(I, ICON_OVERLAY, ((render_x_start + x_index) - 1) * 2, ((render_y_start + y_index) - 1) * 2)

	return bigassicon


/obj/machinery/holomap/proc/get_area_color(area/A, floor_varient=FALSE)
	//don't look too closely at this, I blame the mappers

	//SHUTTLES
	if(istype(A, /area/shuttle))
		return floor_varient ? "#bdbdbd" : "#FFFFFF"

	//AI SAT
	if(istype(A, /area/turret_protected) || istype(A, /area/aisat) || istype(A, /area/tcommsat))
		return floor_varient ? "#144640": "#009180"

	//COMMAND
	if(istype(A, /area/bridge) || (istype(A, /area/teleporter) && !istype(A, /area/teleporter/quantum)) || istype(A, /area/crew_quarters/heads) || istype(A, /area/crew_quarters/chief) || istype(A, /area/crew_quarters/captain) || istype(A, /area/ntrep) || istype(A, /area/blueshield) || istype(A, /area/ai_monitored) || istype(A, /area/security/nuke_storage) || istype(A, /area/server) || istype(A, /area/crew_quarters/hor) || istype(A, /area/solar)/*not a mistake, hijacking the color*/ || istype(A, /area/engine/chiefs_office) || istype(A, /area/medical/cmo) || istype(A, /area/security/hos))
		return floor_varient ? "#1e1a5e": "#08009f"

	//SECURITY
	if((istype(A, /area/security) && !(istype(A, /area/security/vacantoffice) || istype(A, /area/security/vacantoffice2)))|| istype(A, /area/lawoffice) || istype(A, /area/crew_quarters/courtroom) || istype(A, /area/magistrateoffice))
		return floor_varient ? "#7c090d": "#d00000"

	//RESEARCH
	if(istype(A, /area/toxins) || istype(A, /area/medical/research) || istype(A, /area/assembly/robotics) || istype(A, /area/assembly/chargebay))
		return floor_varient ? "#6a0b79": "#9e00dd"

	//MEDBAY
	if(istype(A, /area/medical))
		return floor_varient ? "#1d849e": "#3ad8ff"

	//ENGINEERING
	if(istype(A, /area/engine) || istype(A, /area/storage/tech) || istype(A, /area/storage/secure) || istype(A, /area/atmos) || istype(A, /area/maintenance/electrical) || istype(A, /area/maintenance/turbine) || istype(A, /area/maintenance/incinerator) || istype(A, /area/maintenance/portsolar) || istype(A, /area/maintenance/starboardsolar) || istype(A, /area/maintenance/auxsolarport) || istype(A, /area/maintenance/auxsolarstarboard))
		return floor_varient ? "#766e00": "#f1d100"

	//CARGO
	if(istype(A, /area/quartermaster) || (istype(A, /area/maintenance/disposal) && !istype(A, /area/maintenance/disposal/external)))
		return floor_varient ? "#5c4429": "#a27749"

	//SERVICE
	if(istype(A, /area/crew_quarters/bar) || istype(A, /area/crew_quarters/theatre) || istype(A, /area/crew_quarters/kitchen) || istype(A, /area/crew_quarters/cafe) || istype(A, /area/mimeoffice) || istype(A, /area/clownoffice) || (istype(A, /area/hydroponics) && !istype(A, /area/hydroponics/abandoned_garden))|| istype(A, /area/library) || istype(A, /area/chapel) || istype(A, /area/janitor))
		return floor_varient ? "#0b5916": "#23940d"

	//DORMS + HALLS
	if(istype(A, /area/hallway) || istype(A, /area/crew_quarters) || istype(A, /area/civilian) || istype(A, /area/expedition) || istype(A, /area/teleporter/quantum) || istype(A, /area/storage))
		return floor_varient ? "#6c6c6c": "#b6b6b6"

	//ROCK
	if(istype(A, /area/mine/unexplored/cere))
		return floor_varient ? "#51473c": "#715c51"

	//maints + unspecified
	return floor_varient ? "#171e16": "#373a2a"


