SUBSYSTEM_DEF(debugview)
	name = "Debug View"
	wait = 1 // SS_TICKER subsystem, so wait is in ticks
	flags = SS_TICKER|SS_NO_INIT
	offline_implications = "Shift+F3 will no longer show a debug view. No immediate action is needed."
	cpu_display = SS_CPUDISPLAY_LOW
	/// List of clients currently processing
	var/list/client/processing = list()

/datum/controller/subsystem/debugview/fire(resumed)
	// Dont generate text if no one is there to look at it
	if(!length(processing))
		return

	// Generate debug text
	var/list/entries = list()
	entries += "CPU: [round(world.cpu, 1)] | MCPU: [round(world.map_cpu, 1)] | FPS/TPS: [world.fps] | Clients: [length(GLOB.clients)] | BYOND: [world.byond_version].[world.byond_build]"
	entries += "\[Air] Cost: [SSair.get_cost()]ms | MT: [round(SSair.cost_milla_tick, 1)]ms | IT: [SSair.interesting_tile_count] | HS: [SSair.hotspot_count] | WT: [SSair.windy_tile_count]"
	entries += "\[Debug] Cost: [round(SSdebugview.cost, 1)]ms | P: [length(SSdebugview.processing)]" // meta af (tbf we need to know how much were using)
	entries += "\[FP] Cost: [round(SSfastprocess.cost, 1)]ms | P: [length(SSfastprocess.processing)]"
	// Snowflakery for SSgarbage
	var/list/counts = list()
	for(var/list/L in SSgarbage.queues)
		counts += length(L)
	entries += "\[GC] Cost: [round(SSgarbage.cost, 1)]ms | Q: [counts.Join(",")] H: [SSgarbage.delslasttick] | S: [SSgarbage.gcedlasttick]"
	entries += "\[Input] Cost: [round(SSinput.cost, 1)]ms"
	entries += "\[Lighting] Cost: [round(SSlighting.cost, 1)]ms | SQ: [length(SSlighting.sources_queue)] | CQ: [length(SSlighting.corners_queue)] | OQ: [length(SSlighting.objects_queue)]"
	entries += "\[Machines] Cost: [round(SSmachines.cost, 1)]ms | M: [length(SSmachines.processing)] | P: [length(SSmachines.powernets)]"
	entries += "\[Mobs] Cost: [round(SSmobs.cost, 1)]ms | P: [length(GLOB.mob_living_list)]"
	entries += "\[Objects] Cost: [round(SSobj.cost, 1)]ms | P: [length(SSobj.processing)]"
	entries += "\[Processing] Cost: [round(SSprocessing.cost, 1)]ms | P: [length(SSprocessing.processing)]"
	entries += "\[Projectiles] Cost: [round(SSprojectiles.cost, 1)]ms | P: [length(SSprojectiles.processing)]"
	entries += "\[Runechat] Cost: [round(SSrunechat.cost, 1)]ms | AM: [SSrunechat.bucket_count] | SQ: [length(SSrunechat.second_queue)]"
	entries += "\[TGUI] Cost: [round(SStgui.cost, 1)]ms | P: [length(SStgui.open_uis)]]"
	entries += "\[Timer] Cost: [round(SStimer.cost, 1)]ms | B: [SStimer.bucket_count] | P: [length(SStimer.second_queue)] | RST: [SStimer.bucket_reset_count]"

	// Do some parsing to format it properly
	var/out_text = entries.Join("\n")
	var/mty = 480 - 9 * length(entries)

	// And update the clients
	for(var/client/C as anything in processing)
		C.debug_text_overlay.maptext_y = mty
		C.debug_text_overlay.maptext = "<span class='maptext' style='background-color: #272727;'>[out_text]</span>"

/datum/controller/subsystem/debugview/proc/start_processing(client/C)
	C.debug_text_overlay = new /atom/movable/screen/debugtextholder(null, C)
	C.screen |= C.debug_text_overlay
	processing |= C

/datum/controller/subsystem/debugview/proc/stop_processing(client/C)
	processing -= C
	C.screen -= C.debug_text_overlay
	QDEL_NULL(C.debug_text_overlay)

/atom/movable/screen/debugtextholder
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "empty"
	screen_loc = "TOP,LEFT"
	plane = HUD_PLANE_DEBUGVIEW
	maptext_height = 480 // 15 * 32 (15 tiles, 32 pixels each)
	maptext_width = 480 // changes with prefs

/atom/movable/screen/debugtextholder/Initialize(mapload, client/C)
	. = ..()
	update_view(C)

/atom/movable/screen/debugtextholder/proc/update_view(client/C)
	var/list/viewsizes = getviewsize(C.view)
	maptext_width = viewsizes[1] * world.icon_size

// Make a verb for dumping full SS stats
/client/proc/ss_breakdown()
	set name = "SS Info Breakdown"
	set category = "Debug"

	if(!check_rights(R_DEBUG|R_VIEWRUNTIMES))
		return

	var/datum/browser/popup = new(usr, "ss_breakdown", "Subsystem Breakdown", 1100, 850)

	var/list/html = list()
	html += "CPU: [round(world.cpu, 1)] | MCPU: [round(world.map_cpu, 1)] | FPS/TPS: [world.fps] | Clients: [length(GLOB.clients)] | BYOND: [world.byond_version].[world.byond_build]"
	html += "--- SS BREAKDOWN ---"
	for(var/datum/controller/subsystem/SS as anything in Master.subsystems)
		// We dont care about subsystems that arent firing (or are unable to)
		if((SS.flags & SS_NO_FIRE) || !SS.can_fire)
			continue

		html += "[SS.state_colour()]\[[SS.state_letter()]][SS.ss_id]</font>\t[SS.get_cost()]ms | [round(SS.tick_usage, 1)]% [SS.get_stat_details() ? "| [SS.get_stat_details()] " : ""]| <a href=byond://?_src_=vars;Vars=[SS.UID()]>VV Edit</a>"

	popup.set_content(html.Join("<br>"))
	popup.open(FALSE)
