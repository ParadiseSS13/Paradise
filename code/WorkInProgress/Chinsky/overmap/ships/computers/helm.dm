/obj/machinery/computer/helm
	name = "helm control console"
	icon_state = "id"
	var/state = "status"
	var/obj/effect/map/ship/linked			//connected overmap object
	var/autopilot = 0
	var/manual_control = 0
	var/list/known_sectors = list()
	var/dx		//desitnation
	var/dy		//coordinates

/obj/machinery/computer/helm/initialize()
	linked = map_sectors["[z]"]
	if (linked)
		if(!linked.nav_control)
			linked.nav_control = src
		testing("Helm console at level [z] found a corresponding overmap object '[linked.name]'.")
	else
		testing("Helm console at level [z] was unable to find a corresponding overmap object.")

	for(var/level in map_sectors)
		var/obj/effect/map/sector/S = map_sectors["[level]"]
		if (istype(S) && S.always_known)
			var/datum/data/record/R = new()
			R.fields["name"] = S.name
			R.fields["x"] = S.x
			R.fields["y"] = S.y
			known_sectors += R

/obj/machinery/computer/helm/process()
	..()
	if (autopilot && dx && dy)
		var/turf/T = locate(dx,dy,1)
		if(linked.loc == T)
			if(linked.is_still())
				autopilot = 0
			else
				linked.decelerate()

		var/brake_path = linked.get_brake_path()

		if(get_dist(linked.loc, T) > brake_path)
			linked.accelerate(get_dir(linked.loc, T))
		else
			linked.decelerate()

		return

/obj/machinery/computer/helm/relaymove(var/mob/user, direction)
	if(manual_control && linked)
		linked.relaymove(user,direction)
		return 1

/obj/machinery/computer/helm/check_eye(var/mob/user as mob)
	if (!manual_control)
		return null
	if (!get_dist(user, src) > 1 || user.blinded || !linked )
		return null
	user.reset_view(linked)
	return 1

/obj/machinery/computer/helm/attack_hand(var/mob/user as mob)
	if(..())
		user.unset_machine()
		manual_control = 0
		return

	if(!isAI(user))
		user.set_machine(src)

	ui_interact(user)

/obj/machinery/computer/helm/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(!linked)
		return

	var/data[0]
	data["state"] = state

	data["sector"] = linked.current_sector ? linked.current_sector.name : "Deep Space"
	data["sector_info"] = linked.current_sector ? linked.current_sector.desc : "Not Available"
	data["s_x"] = linked.x
	data["s_y"] = linked.y
	data["dest"] = dy && dx
	data["d_x"] = dx
	data["d_y"] = dy
	data["speed"] = linked.get_speed()
	data["accel"] = round(linked.get_acceleration())
	data["heading"] = linked.get_heading() ? dir2angle(linked.get_heading()) : 0
	data["autopilot"] = autopilot
	data["manual_control"] = manual_control

	var/list/locations[0]
	for (var/datum/data/record/R in known_sectors)
		var/list/rdata[0]
		rdata["name"] = R.fields["name"]
		rdata["x"] = R.fields["x"]
		rdata["y"] = R.fields["y"]
		rdata["reference"] = "\ref[R]"
		locations.Add(list(rdata))

	data["locations"] = locations

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "helm.tmpl", "[linked.name] Helm Control", 380, 530)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/helm/Topic(href, href_list)
	if(..())
		return

	if (!linked)
		return

	if (href_list["add"])
		var/datum/data/record/R = new()
		var/sec_name = input("Input naviation entry name", "New navigation entry", "Sector #[known_sectors.len]") as text
		if(!sec_name)
			sec_name = "Sector #[known_sectors.len]"
		R.fields["name"] = sec_name
		switch(href_list["add"])
			if("current")
				R.fields["x"] = linked.x
				R.fields["y"] = linked.y
			if("new")
				var/newx = input("Input new entry x coordinate", "Coordinate input", linked.x) as num
				R.fields["x"] = Clamp(newx, 1, world.maxx)
				var/newy = input("Input new entry y coordinate", "Coordinate input", linked.y) as num
				R.fields["y"] = Clamp(newy, 1, world.maxy)
		known_sectors += R

	if (href_list["remove"])
		var/datum/data/record/R = locate(href_list["remove"])
		known_sectors.Remove(R)

	if (href_list["setx"])
		var/newx = input("Input new destiniation x coordinate", "Coordinate input", dx) as num|null
		if (newx)
			dx = Clamp(newx, 1, world.maxx)

	if (href_list["sety"])
		var/newy = input("Input new destiniation y coordinate", "Coordinate input", dy) as num|null
		if (newy)
			dy = Clamp(newy, 1, world.maxy)

	if (href_list["x"] && href_list["y"])
		dx = text2num(href_list["x"])
		dy = text2num(href_list["y"])

	if (href_list["reset"])
		dx = 0
		dy = 0

	if (href_list["move"])
		var/ndir = text2num(href_list["move"])
		linked.relaymove(usr, ndir)

	if (href_list["brake"])
		linked.decelerate()

	if (href_list["apilot"])
		autopilot = !autopilot

	if (href_list["manual"])
		manual_control = !manual_control

	if (href_list["state"])
		state = href_list["state"]
	add_fingerprint(usr)
	updateUsrDialog()

