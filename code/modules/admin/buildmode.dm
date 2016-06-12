#define BASIC_BUILDMODE 1
#define ADV_BUILDMODE 2
#define VAR_BUILDMODE 3
#define THROW_BUILDMODE 4
#define AREA_BUILDMODE 5
#define COPY_BUILDMODE 6
#define AREAEDIT_BUILDMODE 7
#define FILL_BUILDMODE 8
#define LINK_BUILDMODE 9
#define NUM_BUILDMODES 9

/obj/screen/buildmode
	icon = 'icons/misc/buildmode.dmi'
	var/datum/click_intercept/buildmode/bd

/obj/screen/buildmode/New(bld)
	..()
	bd = bld

/obj/screen/buildmode/mode
	name = "Toggle Mode"
	icon_state = "buildmode1"
	screen_loc = "NORTH,WEST"

/obj/screen/buildmode/mode/Click(location, control, params)
	var/list/pa = params2list(params)

	if(pa.Find("left"))
		bd.toggle_modes()
	else if(pa.Find("right"))
		bd.change_settings(usr)
	update_icon()
	return 1

/obj/screen/buildmode/mode/update_icon()
	icon_state = "buildmode[bd.mode]"
	return

/obj/screen/buildmode/help
	icon_state = "buildhelp"
	screen_loc = "NORTH,WEST+1"
	name = "Buildmode Help"

/obj/screen/buildmode/help/Click()
	bd.show_help(usr)
	return 1

/obj/screen/buildmode/bdir
	icon_state = "build"
	screen_loc = "NORTH,WEST+2"
	name = "Change Dir"

/obj/screen/buildmode/bdir/update_icon()
	dir = bd.build_dir
	return

/obj/screen/buildmode/bdir/Click()
	bd.change_dir()
	update_icon()
	return 1

/obj/screen/buildmode/quit
	icon_state = "buildquit"
	screen_loc = "NORTH,WEST+3"
	name = "Quit Buildmode"

/obj/screen/buildmode/quit/Click()
	bd.quit()
	return 1

/obj/screen/buildmode/dir/Click()
	bd.change_dir()
	update_icon()
	return 1

/obj/effect/buildmode_reticule
	var/image/I
	var/client/cl

/obj/effect/buildmode_reticule/New(var/turf/t, var/client/c)
	loc = t
	I = image('icons/mob/blob.dmi', t, "marker",19.0,2) // Sprite reuse wooo
	cl = c
	cl.images += I

/obj/effect/buildmode_reticule/proc/deselect()
	qdel(src)

/obj/effect/buildmode_reticule/Destroy()
	cl.images -= I
	cl = null
	qdel(I)

/obj/effect/buildmode_line
	var/image/I 
	var/client/cl

/obj/effect/buildmode_line/New(var/client/c, var/atom/atom_a, var/atom/atom_b, var/linename)
	name = linename
	loc = get_turf(atom_a)
	I = image('icons/misc/mark.dmi', src, "line", 19.0)
	var/x_offset = ((atom_b.x * 32) + atom_b.pixel_x) - ((atom_a.x * 32) + atom_a.pixel_x)
	var/y_offset = ((atom_b.y * 32) + atom_b.pixel_y) - ((atom_a.y * 32) + atom_a.pixel_y)
	
	var/matrix/M = matrix()
	M.Translate(0, 16)
	M.Scale(1, sqrt((x_offset * x_offset) + (y_offset * y_offset)) / 32)
	M.Turn(90 - Atan2(x_offset, y_offset)) // So... You pass coords in order x,y to this version of atan2. It should be called acsc2.
	M.Translate(atom_a.pixel_x, atom_a.pixel_y)
	
	transform = M
	cl = c
	cl.images += I

/obj/effect/buildmode_line/Destroy()
	if(I)
		if(istype(cl))
			cl.images -= I
			cl = null
		qdel(I)
		I = null
	return ..()

/datum/click_intercept
	var/client/holder = null
	var/list/obj/screen/buttons = list()

/datum/click_intercept/New(client/c)
	create_buttons()
	holder = c
	holder.click_intercept = src
	holder.show_popup_menus = 0
	holder.screen += buttons

/datum/click_intercept/Destroy()
	for(var/button in buttons)
		qdel(button)


/datum/click_intercept/proc/create_buttons()
	return

/datum/click_intercept/proc/InterceptClickOn(user,params,atom/object)
	return

/datum/click_intercept/proc/quit()
	holder.screen -= buttons
	holder.click_intercept = null
	holder.show_popup_menus = 1
	qdel(src)



/datum/click_intercept/buildmode
	var/mode = BASIC_BUILDMODE
	var/build_dir = SOUTH
	var/atom/movable/throw_atom = null
	var/obj/effect/buildmode_reticule/cornerA = null
	var/obj/effect/buildmode_reticule/cornerB = null
	var/generator_path = null
	var/varholder = "name"
	var/valueholder = "derp"
	var/objholder = /obj/structure/closet
	var/area/storedarea = null
	var/image/areaimage
	var/atom/movable/stored = null
	var/list/link_lines = list()
	var/obj/link_obj
	var/valid_links = 0

/datum/click_intercept/buildmode/New(client/c)
	..()
	areaimage = image('icons/turf/areas.dmi',null,"yellow")
	holder.images += areaimage

/datum/click_intercept/buildmode/Destroy()
	stored = null
	Reset()
	areaimage.loc = null
	qdel(areaimage)
	..()

/datum/click_intercept/buildmode/create_buttons()
	buttons += new /obj/screen/buildmode/mode(src)
	buttons += new /obj/screen/buildmode/help(src)
	buttons += new /obj/screen/buildmode/bdir(src)
	buttons += new /obj/screen/buildmode/quit(src)

/datum/click_intercept/buildmode/proc/toggle_modes()
	mode = (mode % NUM_BUILDMODES) +1
	Reset()
	return

/datum/click_intercept/buildmode/proc/show_help(mob/user)
	switch(mode)
		if(BASIC_BUILDMODE)
			to_chat(user, "<span class='notice'>***********************************************************</span>")
			to_chat(user, "<span class='notice'>Left Mouse Button        = Construct / Upgrade</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button       = Deconstruct / Delete / Downgrade</span>")
			to_chat(user, "<span class='notice'>Left Mouse Button + ctrl = R-Window</span>")
			to_chat(user, "<span class='notice'>Left Mouse Button + alt  = Airlock</span>")
			to_chat(user, "")
			to_chat(user, "<span class='notice'>Use the button in the upper left corner to</span>")
			to_chat(user, "<span class='notice'>change the direction of built objects.</span>")
			to_chat(user, "<span class='notice'>***********************************************************</span>")
		if(ADV_BUILDMODE)
			to_chat(user, "<span class='notice'>***********************************************************</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Set object type</span>")
			to_chat(user, "<span class='notice'>Left Mouse Button on turf/obj          = Place objects</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button                     = Delete objects</span>")
			to_chat(user, "")
			to_chat(user, "<span class='notice'>Use the button in the upper left corner to</span>")
			to_chat(user, "<span class='notice'>change the direction of built objects.</span>")
			to_chat(user, "<span class='notice'>***********************************************************</span>")
		if(VAR_BUILDMODE)
			to_chat(user, "<span class='notice'>***********************************************************</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Select var(type) & value</span>")
			to_chat(user, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Set var(type) & value</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button on turf/obj/mob     = Reset var's value</span>")
			to_chat(user, "<span class='notice'>***********************************************************</span>")
		if(THROW_BUILDMODE)
			to_chat(user, "<span class='notice'>***********************************************************</span>")
			to_chat(user, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Select</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button on turf/obj/mob     = Throw</span>")
			to_chat(user, "<span class='notice'>***********************************************************</span>")
		if(AREA_BUILDMODE)
			to_chat(user, "<span class='notice'>***********************************************************</span>")
			to_chat(user, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Select corner</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Select generator</span>")
			to_chat(user, "<span class='notice'>***********************************************************</span>")
		if(COPY_BUILDMODE)
			to_chat(user, "<span class='notice'>***********************************************************</span>")
			to_chat(user, "<span class='notice'>Left Mouse Button on obj/turf/mob   = Spawn a Copy of selected target</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button on obj/mob = Select target to copy</span>")
			to_chat(user, "<span class='notice'>***********************************************************</span>")
		if(AREAEDIT_BUILDMODE)
			to_chat(user, "<span class='notice'>***********************************************************</span>")
			to_chat(user, "<span class='notice'>Left Mouse Button on obj/turf/mob  = Paint area</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button on obj/turf/mob = Select area to paint</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Create new area</span>")
			to_chat(user, "<span class='notice'>***********************************************************</span>")
		if(FILL_BUILDMODE)
			to_chat(user, "<span class='notice'>***********************************************************</span>")
			to_chat(user, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Select corner</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Select object type</span>")
			to_chat(user, "<span class='notice'>***********************************************************</span>")
		if(LINK_BUILDMODE)
			to_chat(user, "<span class='notice'>***********************************************************</span>")
			to_chat(user, "<span class='notice'>Left Mouse Button on obj  = Select button to link</span>")
			to_chat(user, "<span class='notice'>Right Mouse Button on obj = Link/unlink to selected button")
			to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/click_intercept/buildmode/proc/change_settings(mob/user)
	switch(mode)
		if(BASIC_BUILDMODE)

			return 1
		if(ADV_BUILDMODE)
			var/target_path = input(user,"Enter typepath:" ,"Typepath","/obj/structure/closet")
			objholder = text2path(target_path)
			if(!ispath(objholder))
				objholder = pick_closest_path(target_path)
				if(!objholder || ispath(objholder, /area))
					objholder = /obj/structure/closet
					alert("That path is not allowed.")
			else
				if(ispath(objholder,/mob) && !check_rights(R_DEBUG,0))
					objholder = /obj/structure/closet
		if(VAR_BUILDMODE)
			var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "viruses", "cuffed", "ka", "last_eaten", "urine")

			varholder = input(user,"Enter variable name:" ,"Name", "name")
			if(varholder in locked && !check_rights(R_DEBUG,0))

				return 1
			var/thetype = input(user,"Select variable type:" ,"Type") in list("text","number","mob-reference","obj-reference","turf-reference")
			if(!thetype) return 1
			switch(thetype)
				if("text")
					valueholder = input(user,"Enter variable value:" ,"Value", "value") as text
				if("number")
					valueholder = input(user,"Enter variable value:" ,"Value", 123) as num
				if("mob-reference")
					valueholder = input(user,"Enter variable value:" ,"Value") as mob in mob_list
				if("obj-reference")
					valueholder = input(user,"Enter variable value:" ,"Value") as obj in world
				if("turf-reference")
					valueholder = input(user,"Enter variable value:" ,"Value") as turf in world
		if(AREA_BUILDMODE)
			var/list/gen_paths = subtypesof(/datum/mapGenerator)

			var/type = input(user,"Select Generator Type","Type") as null|anything in gen_paths
			if(!type) return

			generator_path = type
			cornerA = null
			cornerB = null
		if(AREAEDIT_BUILDMODE)
			var/target_path = input(user,"Enter typepath:", "Typepath", "/area")
			var/areatype = text2path(target_path)
			if(ispath(areatype,/area))
				var/areaname = input(user,"Enter area name:", "Area name", "Area")
				if(!areaname || !length(areaname))
					return
				storedarea = new areatype
				storedarea.power_equip = 0
				storedarea.power_light = 0
				storedarea.power_environ = 0
				storedarea.always_unpowered = 0
				storedarea.name = areaname
				areaimage.loc = storedarea
		if(FILL_BUILDMODE)
			var/target_path = input(user,"Enter typepath:" ,"Typepath","/obj/structure/closet")
			objholder = text2path(target_path)
			if(!ispath(objholder))
				objholder = pick_closest_path(target_path)
				if(!objholder || ispath(objholder, /area))
					objholder = /obj/structure/closet
					return
			else
				if(ispath(objholder,/mob) && !check_rights(R_DEBUG,0))
					objholder = /obj/structure/closet
			deselect_region()

/datum/click_intercept/buildmode/proc/change_dir()
	switch(build_dir)
		if(NORTH)
			build_dir = EAST
		if(EAST)
			build_dir = SOUTH
		if(SOUTH)
			build_dir = WEST
		if(WEST)
			build_dir = NORTHWEST
		if(NORTHWEST)
			build_dir = NORTH
	return 1

/datum/click_intercept/buildmode/proc/deselect_region()
	qdel(cornerA)
	cornerA = null
	qdel(cornerB)
	cornerB = null

/datum/click_intercept/buildmode/proc/Reset()//Reset temporary variables
	deselect_region()
	if(mode == AREAEDIT_BUILDMODE)
		areaimage.loc = storedarea
	else
		areaimage.loc = null
	for(var/obj/effect/buildmode_line/L in link_lines)
		qdel(L)
		link_lines -= L

/datum/click_intercept/buildmode/proc/select_tile(var/turf/T)
	return new /obj/effect/buildmode_reticule(T, holder)

/proc/togglebuildmode(mob/M as mob in player_list)
	set name = "Toggle Build Mode"
	set category = "Special Verbs"
	if(M.client)
		if(istype(M.client.click_intercept,/datum/click_intercept/buildmode))
			var/datum/click_intercept/buildmode/B = M.client.click_intercept
			B.quit()
			log_admin("[key_name(usr)] has left build mode.")
		else
			new/datum/click_intercept/buildmode(M.client)
			message_admins("[key_name(usr)] has entered build mode.")
			log_admin("[key_name(usr)] has entered build mode.")

/datum/click_intercept/buildmode/InterceptClickOn(user,params,atom/object) //Click Intercept
	var/list/pa = params2list(params)
	var/right_click = pa.Find("right")
	var/left_click = pa.Find("left")
	var/alt_click = pa.Find("alt")
	var/ctrl_click = pa.Find("ctrl")

	. = 1
	switch(mode)
		if(BASIC_BUILDMODE)
			if(istype(object,/turf) && left_click && !alt_click && !ctrl_click)
				var/turf/T = object
				if(istype(object,/turf/space))
					T.ChangeTurf(/turf/simulated/floor/plasteel)
				else if(istype(object,/turf/simulated/floor))
					T.ChangeTurf(/turf/simulated/wall)
				else if(istype(object,/turf/simulated/wall))
					T.ChangeTurf(/turf/simulated/wall/r_wall)
				log_admin("Build Mode: [key_name(user)] built [T] at ([T.x],[T.y],[T.z])")
				return
			else if(right_click)
				log_admin("Build Mode: [key_name(user)] deleted [object] at ([object.x],[object.y],[object.z])")
				if(istype(object,/turf/simulated/wall))
					var/turf/T = object
					T.ChangeTurf(/turf/simulated/floor/plasteel)
				else if(istype(object,/turf/simulated/floor))
					var/turf/T = object
					T.ChangeTurf(/turf/space)
				else if(istype(object,/turf/simulated/wall/r_wall))
					var/turf/T = object
					T.ChangeTurf(/turf/simulated/wall)
				else if(istype(object,/obj))
					qdel(object)
				return
			else if(istype(object,/turf) && alt_click && left_click)
				log_admin("Build Mode: [key_name(user)] built an airlock at ([object.x],[object.y],[object.z])")
				new/obj/machinery/door/airlock(get_turf(object))
			else if(istype(object,/turf) && ctrl_click && left_click)
				switch(build_dir)
					if(NORTH)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = NORTH
					if(SOUTH)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = SOUTH
					if(EAST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = EAST
					if(WEST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = WEST
					if(NORTHWEST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = NORTHWEST
				log_admin("Build Mode: [key_name(user)] built a window at ([object.x],[object.y],[object.z])")

		if(ADV_BUILDMODE)
			if(left_click)
				if(ispath(objholder,/turf))
					var/turf/T = get_turf(object)
					log_admin("Build Mode: [key_name(user)] modified [T] ([T.x],[T.y],[T.z]) to [objholder]")
					T.ChangeTurf(objholder)
				else
					var/obj/A = new objholder (get_turf(object))
					A.dir = build_dir
					log_admin("Build Mode: [key_name(user)] modified [A]'s ([A.x],[A.y],[A.z]) dir to [build_dir]")
			else if(right_click)
				if(isobj(object))
					log_admin("Build Mode: [key_name(user)] deleted [object] at ([object.x],[object.y],[object.z])")
					qdel(object)

		if(VAR_BUILDMODE)
			if(left_click) //I cant believe this shit actually compiles.
				if(object.vars.Find(varholder))
					log_admin("Build Mode: [key_name(user)] modified [object.name]'s [varholder] to [valueholder]")
					object.vars[varholder] = valueholder
				else
					to_chat(user, "<span class='warning'>[initial(object.name)] does not have a var called '[varholder]'</span>")
			if(right_click)
				if(object.vars.Find(varholder))
					log_admin("Build Mode: [key_name(user)] modified [object.name]'s [varholder] to [valueholder]")
					object.vars[varholder] = initial(object.vars[varholder])
				else
					to_chat(user, "<span class='warning'>[initial(object.name)] does not have a var called '[varholder]'</span>")

		if(THROW_BUILDMODE)
			if(left_click)
				if(isturf(object))
					return
				throw_atom = object
			if(right_click)
				if(throw_atom)
					throw_atom.throw_at(object, 10, 1,user)
					log_admin("Build Mode: [key_name(user)] threw [throw_atom] at [object] ([object.x],[object.y],[object.z])")
		if(AREA_BUILDMODE)
			if(!cornerA)
				cornerA = select_tile(get_turf(object))
				return
			if(cornerA && !cornerB)
				cornerB = select_tile(get_turf(object))
			if(left_click) //rectangular
				if(cornerA && cornerB)
					if(!generator_path)
						to_chat(user, "<span class='warning'>Select generator type first.</span>")
					else
						var/datum/mapGenerator/G = new generator_path
						G.defineRegion(cornerA.loc,cornerB.loc,1)
						G.generate()
					deselect_region()
					return

			//Something wrong - Reset
			deselect_region()
		if(COPY_BUILDMODE)
			if(left_click)
				var/turf/T = get_turf(object)
				if(stored)
					DuplicateObject(stored, perfectcopy=1, sameloc=0,newloc=T)
			else if(right_click)
				if(ismovableatom(object)) // No copying turfs for now.
					to_chat(user, "<span class='notice'>[object] set as template.</span>")
					stored = object
		if(AREAEDIT_BUILDMODE)
			if(left_click)
				if(!storedarea)
					return
				var/turf/T = get_turf(object)
				if(get_area(T) != storedarea)
					storedarea.contents.Add(T)
			else if(right_click)
				var/turf/T = get_turf(object)
				storedarea = get_area(T)
				areaimage.loc = storedarea
		if(FILL_BUILDMODE)
			if(!cornerA)
				cornerA = select_tile(get_turf(object))
				return
			if(cornerA && !cornerB)
				cornerB = select_tile(get_turf(object))
			if(left_click) //rectangular
				if(cornerA && cornerB)
					if(!objholder)
						to_chat(user, "<span class='warning'>Select object type first.</span>")
					else
						for(var/turf/T in block(get_turf(cornerA),get_turf(cornerB)))
							if(ispath(objholder,/turf))
								T.ChangeTurf(objholder)
							else
								var/obj/A = new objholder(T)
								A.dir = build_dir
					deselect_region()
					return

			//Something wrong - Reset
			deselect_region()
		if(LINK_BUILDMODE)
			if(left_click && istype(object, /obj/machinery))
				link_obj = object
			if(right_click && istype(object, /obj/machinery))
				if(istype(link_obj, /obj/machinery/door_control) && istype(object, /obj/machinery/door/airlock))
					var/obj/machinery/door_control/M = link_obj
					var/obj/machinery/door/airlock/P = object
					if(!M.id || M.id == "")
						M.id = input(holder, "Please select an ID for the button", "Buildmode", "")
						if(!M.id || M.id == "")
							goto(line_jump)
					if(P.id_tag == M.id && (P in range(M.range, M)) && P.id_tag && P.id_tag != "")
						P.id_tag = null
						to_chat(holder, "[P] unlinked.")
						goto(line_jump)
					if(!M.normaldoorcontrol)
						if(link_lines.len && alert(holder, "Warning: This will disable links to connected pod doors. Continue?", "Buildmode", "Yes", "No") == "No")
							goto(line_jump)
						M.normaldoorcontrol = 1
					if(P.id_tag && alert(holder, "Warning: This will unlink something else from the door. Continue?", "Buildmode", "Yes", "No") == "No")
						goto(line_jump)
					P.id_tag = M.id
				if(istype(link_obj, /obj/machinery/door_control) && istype(object, /obj/machinery/door/poddoor))
					var/obj/machinery/door_control/M = link_obj
					var/obj/machinery/door/poddoor/P = object
					if(!M.id || M.id == "")
						M.id = input(holder, "Please select an ID for the button", "Buildmode", "")
						if(!M.id || M.id == "")
							goto(line_jump)
					if(P.id_tag == M.id && P.id_tag && P.id_tag != "")
						P.id_tag = null
						to_chat(holder, "[P] unlinked.")
						goto(line_jump)
					if(M.normaldoorcontrol)
						if(link_lines.len && alert(holder, "Warning: This will disable links to connected airlocks. Continue?", "Buildmode", "Yes", "No") == "No")
							goto(line_jump)
						M.normaldoorcontrol = 0
					if(!M.id || M.id == "")
						M.id = input(holder, "Please select an ID for the button", "Buildmode", "")
						if(!M.id || M.id == "")
							goto(line_jump)
					if(P.id_tag && P.id_tag != 1 && alert(holder, "Warning: This will unlink something else from the door. Continue?", "Buildmode", "Yes", "No") == "No")
						goto(line_jump)
					P.id_tag = M.id
			
			line_jump // For the goto
			valid_links = 0
			for(var/obj/effect/buildmode_line/L in link_lines)
				qdel(L)
				link_lines -= L
			
			if(istype(link_obj, /obj/machinery/door_control))
				var/obj/machinery/door_control/M = link_obj
				for(var/obj/machinery/door/airlock/P in range(M.range,M))
					if(P.id_tag == M.id)
						var/obj/effect/buildmode_line/L = new(holder, M, P, "[M.name] to [P.name]")
						L.color = M.normaldoorcontrol ? "#339933" : "#993333"
						if(M.normaldoorcontrol)
							valid_links = 1
						link_lines += L
						var/obj/effect/buildmode_line/L2 = new(holder, P, M, "[M.name] to [P.name]") // Yes, reversed one so that you can see it from both sides.
						L2.color = L.color
						link_lines += L2
				for(var/obj/machinery/door/poddoor/P in world)
					if(P.id_tag == M.id)
						var/obj/effect/buildmode_line/L = new(holder, M, P, "[M.name] to [P.name]")
						L.color = M.normaldoorcontrol ? "#993333" : "#339933"
						if(M.normaldoorcontrol)
							valid_links = 0
						link_lines += L
						var/obj/effect/buildmode_line/L2 = new(holder, P, M, "[M.name] to [P.name]") // Yes, reversed one so that you can see it from both sides.
						L2.color = L.color
						link_lines += L2
