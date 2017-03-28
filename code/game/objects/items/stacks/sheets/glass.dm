/* Glass stack types
 * Contains:
 *		Glass sheets
 *		Reinforced glass sheets
 *		Glass shards - TODO: Move this into code/game/object/item/weapons
 *		Plasma Glass Sheets
 *		Reinforced Plasma Glass Sheets (AKA Holy fuck strong windows)

 Todo: Create a unified construct_window(sheet, user, created_window, full_window)

 */

/*
 * Glass sheets
 */
/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	origin_tech = "materials=1"
	var/created_window = /obj/structure/window/basic
	var/full_window = /obj/structure/window/full/basic
	merge_type = /obj/item/stack/sheet/glass

/obj/item/stack/sheet/glass/fifty
	amount = 50

/obj/item/stack/sheet/glass/cyborg
	materials = list()

/obj/item/stack/sheet/glass/attack_self(mob/user as mob)
	construct_window(user)

/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(CC.amount < 5)
			to_chat(user, "\b There is not enough wire in this coil. You need 5 lengths.")
			return
		CC.use(5)
		to_chat(user, "<span class='notice'>You attach wire to the [name].</span>")
		new /obj/item/stack/light_w(user.loc)
		src.use(1)
	else if( istype(W, /obj/item/stack/rods) )
		var/obj/item/stack/rods/V  = W
		var/obj/item/stack/sheet/rglass/RG = new (user.loc)
		RG.add_fingerprint(user)
		RG.add_to_stacks(user)
		V.use(1)
		var/obj/item/stack/sheet/glass/G = src
		src = null
		var/replace = (user.get_inactive_hand()==G)
		G.use(1)
		if(!G && !RG && replace)
			user.put_in_hands(RG)
	else
		return ..()

/obj/item/stack/sheet/glass/proc/construct_window(mob/user as mob)
	if(!user || !src)	return 0
	if(!istype(user.loc,/turf)) return 0
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='danger'>You don't have the dexterity to do this!</span>")
		return 0
	var/title = "Sheet-Glass"
	title += " ([src.amount] sheet\s left)"
	switch(input(title, "What would you like to construct?") in list("One Direction Window", "Full Window", "Fishbowl", "Fish Tank", "Wall Aquarium", "Cancel"))
		if("One Direction Window")
			if(!src)	return 1
			if(src.loc != user)	return 1

			var/list/directions = new/list(cardinal)
			var/i = 0
			for(var/obj/structure/window/win in user.loc)
				i++
				if(i >= 4)
					to_chat(user, "<span class='danger'>There are too many windows in this location.</span>")
					return 1
				directions-=win.dir
				if(win.is_fulltile())
					to_chat(user, "<span class='danger'>Can't let you do that.</span>")
					return 1

			//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
			var/dir_to_set = 2
			for(var/direction in list( user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
				var/found = 0
				for(var/obj/structure/window/WT in user.loc)
					if(WT.dir == direction)
						found = 1
				if(!found)
					dir_to_set = direction
					break

			var/obj/structure/window/W
			W = new /obj/structure/window/basic( user.loc, 0 )
			W.dir = dir_to_set
			W.ini_dir = W.dir
			W.state = 0
			W.anchored = 0
			W.air_update_turf(1)
			src.use(1)
		if("Full Window")
			if(!src)	return 1
			if(src.loc != user)	return 1
			if(src.amount < 2)
				to_chat(user, "<span class='danger'>You need more glass to do that.</span>")
				return 1
			if(locate(/obj/structure/window/full) in user.loc)
				to_chat(user, "<span class='danger'>There is a full window in the way.</span>")
				return 1
			var/obj/structure/window/W = new full_window( user.loc, 0 )
			W.state = 0
			W.anchored = 0
			W.air_update_turf(1)
			src.use(2)
		if("Fishbowl")
			if(!src)	return 1
			if(src.loc != user)	return 1
			var/obj/machinery/fishtank/F = new /obj/machinery/fishtank/bowl(user.loc, 0)
			F.air_update_turf(1)
			src.use(1)
		if("Fish Tank")
			if(!src)	return 1
			if(src.loc != user)	return 1
			if(src.amount < 3)
				to_chat(user, "<span class='danger'>You need more glass to do that.</span>")
				return 1
			var/obj/machinery/fishtank/F = new /obj/machinery/fishtank/tank(user.loc, 0)
			F.air_update_turf(1)
			src.use(3)
		if("Wall Aquarium")
			if(!src)	return 1
			if(src.loc != user)	return 1
			if(src.amount < 4)
				to_chat(user, "<span class='danger'>You need more glass to do that.</span>")
				return 1
			var/obj/machinery/fishtank/F = new /obj/machinery/fishtank/wall(user.loc, 0)
			F.air_update_turf(1)
			src.use(4)
	return 0


/*
 * Reinforced glass sheets
 */
/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT/2, MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	origin_tech = "materials=2"
	var/created_window = /obj/structure/window/reinforced
	var/full_window = /obj/structure/window/full/reinforced
	merge_type = /obj/item/stack/sheet/rglass

/obj/item/stack/sheet/rglass/cyborg
	materials = list()

/obj/item/stack/sheet/rglass/attack_self(mob/user as mob)
	construct_window(user)

/obj/item/stack/sheet/rglass/proc/construct_window(mob/user as mob)
	if(!user || !src)	return 0
	if(!istype(user.loc,/turf)) return 0
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='danger'>You don't have the dexterity to do this!</span>")
		return 0
	var/title = "Sheet Reinf. Glass"
	title += " ([src.amount] sheet\s left)"
	switch(input(title, "Would you like full tile glass a one direction glass pane or a windoor?") in list("One Direction", "Full Window", "Windoor", "Cancel"))
		if("One Direction")
			if(!src)	return 1
			if(src.loc != user)	return 1
			var/list/directions = new/list(cardinal)
			var/i = 0
			for(var/obj/structure/window/win in user.loc)
				i++
				if(i >= 4)
					to_chat(user, "<span class='danger'>There are too many windows in this location.</span>")
					return 1
				directions-=win.dir
				if(win.is_fulltile())
					to_chat(user, "<span class='danger'>Can't let you do that.</span>")
					return 1

			//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
			var/dir_to_set = 2
			for(var/direction in list( user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
				var/found = 0
				for(var/obj/structure/window/WT in user.loc)
					if(WT.dir == direction)
						found = 1
				if(!found)
					dir_to_set = direction
					break

			var/obj/structure/window/W
			W = new /obj/structure/window/reinforced( user.loc, 1 )
			W.state = 0
			W.dir = dir_to_set
			W.ini_dir = W.dir
			W.anchored = 0
			src.use(1)

		if("Full Window")
			if(!src)	return 1
			if(src.loc != user)	return 1
			if(src.amount < 2)
				to_chat(user, "<span class='danger'>You need more glass to do that.</span>")
				return 1
			if(locate(/obj/structure/window/full) in user.loc)
				to_chat(user, "<span class='danger'>There is a window in the way.</span>")
				return 1
			var/obj/structure/window/W = new full_window( user.loc, 0 )
			W.state = 0
			W.anchored = 0
			src.use(2)

		if("Windoor")
			if(!src || src.loc != user) return 1

			if(isturf(user.loc) && locate(/obj/structure/windoor_assembly/, user.loc))
				to_chat(user, "<span class='danger'>There is already a windoor assembly in that location.</span>")
				return 1

			if(isturf(user.loc) && locate(/obj/machinery/door/window/, user.loc))
				to_chat(user, "<span class='danger'>There is already a windoor in that location.</span>")
				return 1

			if(src.amount < 5)
				to_chat(user, "<span class='danger'>You need more glass to do that.</span>")
				return 1

			var/obj/structure/windoor_assembly/WD
			WD = new /obj/structure/windoor_assembly(user.loc)
			WD.state = "01"
			WD.anchored = 0
			src.use(5)
			switch(user.dir)
				if(SOUTH)
					WD.dir = SOUTH
					WD.ini_dir = SOUTH
				if(EAST)
					WD.dir = EAST
					WD.ini_dir = EAST
				if(WEST)
					WD.dir = WEST
					WD.ini_dir = WEST
				else//If the user is facing northeast. northwest, southeast, southwest or north, default to north
					WD.dir = NORTH
					WD.ini_dir = NORTH
		else
			return 1


	return 0


/obj/item/stack/sheet/plasmaglass
	name = "plasma glass"
	desc = "A very strong and very resistant sheet of a plasma-glass alloy."
	singular_name = "glass sheet"
	icon_state = "sheet-plasmaglass"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT*2)
	origin_tech = "materials=3;plasmatech=2"
	var/created_window = /obj/structure/window/plasmabasic
	var/full_window = /obj/structure/window/full/plasmabasic


/obj/item/stack/sheet/plasmaglass/attack_self(mob/user as mob)
	construct_window(user)

/obj/item/stack/sheet/plasmaglass/attackby(obj/item/W, mob/user, params)
	..()
	if( istype(W, /obj/item/stack/rods) )
		var/obj/item/stack/rods/V  = W
		var/obj/item/stack/sheet/plasmarglass/RG = new (user.loc)
		RG.add_fingerprint(user)
		RG.add_to_stacks(user)
		V.use(1)
		var/obj/item/stack/sheet/glass/G = src
		src = null
		var/replace = (user.get_inactive_hand()==G)
		G.use(1)
		if(!G && !RG && replace)
			user.put_in_hands(RG)
	else
		return ..()

/obj/item/stack/sheet/plasmaglass/proc/construct_window(mob/user as mob)
	if(!user || !src)  return 0
	if(!istype(user.loc,/turf)) return 0
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='danger'> You don't have the dexterity to do this!")
		return 0
	var/title = "Plasma-glass alloy"
	title += " ([src.amount] sheet\s left)"
	switch(alert(title, "Would you like full tile glass or one direction?", "One Direction", "Full Window", "Cancel", null))
		if("One Direction")
			if(!src)  return 1
			if(src.loc != user)  return 1
			var/list/directions = new/list(cardinal)
			var/i = 0
			for(var/obj/structure/window/win in user.loc)
				i++
				if(i >= 4)
					to_chat(user, "<span class='danger'>There are too many windows in this location.</span>")
					return 1
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					to_chat(user, "<span class='danger'>Can't let you do that.</span>")
					return 1
			//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
			var/dir_to_set = 2
			for(var/direction in list( user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
				var/found = 0
				for(var/obj/structure/window/WT in user.loc)
					if(WT.dir == direction)
						found = 1
				if(!found)
					dir_to_set = direction
					break
			var/obj/structure/window/W
			W = new /obj/structure/window/plasmabasic( user.loc, 0 )
			W.dir = dir_to_set
			W.ini_dir = W.dir
			W.state = 0
			W.anchored = 0
			src.use(1)
		if("Full Window")
			if(!src)  return 1
			if(src.loc != user)  return 1
			if(src.amount < 2)
				to_chat(user, "<span class='danger'>You need more glass to do that.</span>")
				return 1
			if(locate(/obj/structure/window) in user.loc)
				to_chat(user, "<span class='danger'>There is a window in the way.</span>")
				return 1
			var/obj/structure/window/W = new full_window( user.loc, 0 )
			W.state = 0
			W.anchored = 0
			src.use(2)
	return 0

/*
 * Reinforced plasma glass sheets
 */
/obj/item/stack/sheet/plasmarglass
	name = "reinforced plasma glass"
	desc = "Plasma glass which seems to have rods or something stuck in them."
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-plasmarglass"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT/2, MAT_GLASS=MINERAL_MATERIAL_AMOUNT*2)
	origin_tech = "materials=3;plasmatech=2"
	var/created_window = /obj/structure/window/plasmareinforced
	var/full_window = /obj/structure/window/full/plasmareinforced


/obj/item/stack/sheet/plasmarglass/attack_self(mob/user as mob)
	construct_window(user)

/obj/item/stack/sheet/plasmarglass/proc/construct_window(mob/user as mob)
	if(!user || !src)  return 0
	if(!istype(user.loc,/turf)) return 0
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='danger'>You don't have the dexterity to do this!</span>")
		return 0
	var/title = "Reinforced plasma-glass alloy"
	title += " ([src.amount] sheet\s left)"
	switch(alert(title, "Would you like full tile glass or one direction?", "One Direction", "Full Window", "Cancel", null))
		if("One Direction")
			if(!src)  return 1
			if(src.loc != user)  return 1
			var/list/directions = new/list(cardinal)
			var/i = 0
			for(var/obj/structure/window/win in user.loc)
				i++
				if(i >= 4)
					to_chat(user, "<span class='danger'>There are too many windows in this location.</span>")
					return 1
				directions-=win.dir
				if(!(win.ini_dir in cardinal))
					to_chat(user, "<span class='danger'>Can't let you do that.</span>")
					return 1
			//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
			var/dir_to_set = 2
			for(var/direction in list( user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
				var/found = 0
				for(var/obj/structure/window/WT in user.loc)
					if(WT.dir == direction)
						found = 1
				if(!found)
					dir_to_set = direction
					break
			var/obj/structure/window/W
			W = new /obj/structure/window/plasmareinforced( user.loc, 0 )
			W.dir = dir_to_set
			W.ini_dir = W.dir
			W.state = 0
			W.anchored = 0
			src.use(1)
		if("Full Window")
			if(!src)  return 1
			if(src.loc != user)  return 1
			if(src.amount < 2)
				to_chat(user, "<span class='danger'>You need more glass to do that.</span>")
				return 1
			if(locate(/obj/structure/window) in user.loc)
				to_chat(user, "<span class='danger'>There is a window in the way.</span>")
				return 1
			var/obj/structure/window/W = new full_window( user.loc, 0 )
			W.state = 0
			W.anchored = 0
			src.use(2)
	return 0
