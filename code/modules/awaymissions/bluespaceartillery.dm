/obj/machinery/computer/artillerycontrol
	name = "bluespace artillery control"
	icon_screen = "accelerator"
	icon_keyboard = "accelerator_key"
	icon_state = "computer-wires"
	req_access = list(access_cent_commander)
	var/last_fire = 0
	var/reload_cooldown = 180 // 3 minute cooldown
	var/area/targetarea
	
	light_color = LIGHT_COLOR_LIGHTBLUE

/obj/machinery/computer/artillerycontrol/attack_ai(user as mob)
	to_chat(user, "<span class='warning'>Access denied.</span>")
	return
	
/obj/machinery/computer/artillerycontrol/attack_hand(user as mob)
	ui_interact(user)
	
/obj/machinery/computer/artillerycontrol/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	var/time_to_wait = round(reload_cooldown - ((world.time / 10) - last_fire), 1)
	var/mins = round(time_to_wait / 60)
	var/seconds = time_to_wait - (60*mins)
	data["reloadtime_mins"] = mins
	data["reloadtime_secs"] = (seconds < 10) ? "0[seconds]" : seconds
	if(targetarea)
		var/areaname = sanitize(targetarea.name)
		data["target"] = "Locked on to [areaname]"
	else
		data["target"] = "No Lock"

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "bluespace_artillery.tmpl", "Bluespace Control", 400, 260)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
		
/obj/machinery/computer/artillerycontrol/Topic(href, href_list)
	if(..())
		return 1
		
	if(href_list["area"])	
		var/A
		A = input("Select the target area.", "Select Area", A) in ghostteleportlocs|null
		var/area/thearea = ghostteleportlocs[A]
		if(..() || !istype(thearea))
			return
			
		targetarea = thearea
		
	if(href_list["fire"])
		var/delta = (world.time / 10) - last_fire
		if(reload_cooldown > delta)
			return 1
			
		command_announcement.Announce("Bluespace artillery fire detected. Brace for impact.")
		message_admins("[key_name_admin(usr)] has launched an artillery strike.", 1)
		var/list/L = list()
		for(var/turf/T in get_area_turfs(targetarea.type))
			L += T
		var/loc = pick(L)
		explosion(loc,2,5,11)
		last_fire = world.time / 10
		
	nanomanager.update_uis(src)

/obj/structure/artilleryplaceholder
	name = "artillery"
	icon = 'icons/obj/machines/artillery.dmi'
	anchored = 1
	density = 1

/obj/structure/artilleryplaceholder/decorative
	density = 0
