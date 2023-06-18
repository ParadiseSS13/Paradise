/*
	Somone should totally add an action button to select a location when observing the map
	and it display a list to select from (TGUI maybe!? color coded !? YES?)
	then show an icon like YouAreHere there
*/

/obj/machinery/holomap
	name = "Holomap"
	desc = "It displays a holographic map of the station."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "map"
	anchored = TRUE
	idle_power_consumption = 5
	active_power_consumption = 15
	var/display_map //for mappers who want to add holomaps for off station locations, otherwise it gets set in Initialize()
	var/list/display_targets = list()
	var/image/holomap_projection
	var/image/YouAreHere

/obj/machinery/holomap/Initialize(mapload)
	. = ..()
	if(!display_map)
		display_map = SSmapping.map_datum.technical_name
	var/icon/base_icon = make_map()
	var/icon/alpha_mask = icon('icons/effects/480x480.dmi', "scanline") //Scanline effect.
	base_icon.AddAlphaMask(alpha_mask)
	holomap_projection = image(base_icon, loc = src, layer = ABOVE_HUD_PLANE, pixel_x = -240, pixel_y = -240)
	holomap_projection.plane = ABOVE_HUD_PLANE
	holomap_projection.filters = filter(type = "drop_shadow", size = 8, color = "#ffffff65")
	YouAreHere = image('icons/effects/holomap_icons.dmi', src, "YouAreHere", 22.1 , 2, -256+(x*2), -256+(y*2))
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
	for(var/x_index in 1 to 240)
		for(var/y_index in 1 to 240)
			var/turf/T = locate(x_index, y_index, 2)
			var/area/A = get_area(T)
			var/icon_to_use = 'icons/effects/holomap_parts.dmi'
			var/icon_state_to_use
			var/dir_to_use = 2
			var/list/directions_to_aliens = list()

			if(isfloorturf(T) && !locate(/obj/structure/window) in T)
				icon_state_to_use = "floor"

			else if(iswallturf(T) || istype(T, /turf/simulated/mineral) || locate(/obj/structure/window) in T)
				var/list/cardinals = list(NORTH, SOUTH, EAST, WEST)
				var/number_of_solid_turfs_neighbors = 0
				var/space_found = FALSE
				icon_state_to_use = "full"
				for(var/i in 1 to 4)
					var/turf/found_turf = get_step(T, cardinals[i])
					var/area/found_area = get_area(found_turf)
					if(found_area == /area/space || isspaceturf(found_turf))
						icon_state_to_use = "full" //repeated since we might have set it to be "wall" already
						space_found = TRUE
						break
					if(found_area != A || locate(/obj/machinery/door/airlock) in found_turf)
						icon_state_to_use = "wall"
						directions_to_aliens += cardinals[i] //this will work right... surely

					if(iswallturf(found_turf) || istype(found_turf, /turf/simulated/mineral) || locate(/obj/structure/window) in found_turf)
						number_of_solid_turfs_neighbors++

				if(number_of_solid_turfs_neighbors >= 3)
					icon_state_to_use = "full"
					space_found = TRUE

				if(!space_found)
					switch(length(directions_to_aliens))
						if(0)
							icon_state_to_use = "full"
						if(1)
							dir_to_use = directions_to_aliens[1]
						if(2)
							if((directions_to_aliens[1] == NORTH && directions_to_aliens[2] == SOUTH) || (directions_to_aliens[1] == SOUTH && directions_to_aliens[2] == NORTH))
								dir_to_use = NORTH
							else if((directions_to_aliens[1] == EAST && directions_to_aliens[2] == WEST) || (directions_to_aliens[1] == WEST && directions_to_aliens[2] == EAST))
								dir_to_use = EAST
							else
								if(directions_to_aliens[1] == NORTH)
									if(directions_to_aliens[2] == EAST)
										dir_to_use = NORTHEAST
									else
										dir_to_use = NORTHWEST
								else if(directions_to_aliens[1] == SOUTH)
									if(directions_to_aliens[2] == EAST)
										dir_to_use = SOUTHEAST
									else
										dir_to_use = SOUTHWEST
								else if(directions_to_aliens[1] == EAST )
									if(directions_to_aliens[2] == NORTH)
										dir_to_use = NORTHEAST
									else
										dir_to_use = SOUTHEAST
								else
									if(directions_to_aliens[2] == NORTH)
										dir_to_use = NORTHWEST
									else
										dir_to_use = SOUTHWEST
						if(3)
							icon_state_to_use = "full"
						if(4)
							icon_state_to_use = "full"

			else //if its space then nothing
				continue

			var/icon/I = icon(icon_to_use, icon_state_to_use, dir_to_use)

			I.SwapColor(COLOR_WHITE, get_area_color(A))
			I.SwapColor(COLOR_BLACK, get_area_color(A, TRUE))

			bigassicon.Blend(I, ICON_OVERLAY, x_index*2, y_index*2)

	return bigassicon





/obj/machinery/holomap/proc/get_area_color(area/A, floor_varient=FALSE)
	//don't look too closely at this, I blame the mappers

	//SHUTTLES
	if(istype(A, /area/shuttle))
		return floor_varient ? "#bdbdbd" : "#FFFFFF"

	//AI SAT
	if(istype(A, /area/turret_protected) || istype(A, /area/aisat))
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


