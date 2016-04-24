/obj/structure/window/full
	sheets = 2
	dir=SOUTHWEST
	level = 3

/obj/structure/window/full/CheckExit(atom/movable/O as mob|obj, target as turf)
	return 1

/obj/structure/window/full/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	return 0

/obj/structure/window/full/is_fulltile()
	return 1

//merges adjacent full-tile windows into one (blatant ripoff from game/smoothwall.dm)
/obj/structure/window/full/update_icon()
	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//this way it will only update full-tile ones
	//This spawn is here so windows get properly updated when one gets deleted.
	spawn(2)
		if(!src) return
		if(!is_fulltile())
			return
		var/junction = 0 //will be used to determine from which side the window is connected to other windows
		if(anchored)
			for(var/obj/structure/window/full/W in orange(src,1))
				if(W.anchored && W.density) //Only counts anchored, not-destroyed full-tile windows.
					if(abs(x-W.x)-abs(y-W.y) ) 		//doesn't count windows, placed diagonally to src
						junction |= get_dir(src,W)
		icon_state = "[basestate][junction]"
		return

/obj/structure/window/full/basic
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it."
	icon_state = "window"
	basestate = "window"

/obj/structure/window/full/plasmabasic
	name = "plasma window"
	desc = "A plasma-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."
	basestate = "plasmawindow"
	icon_state = "plasmawindow"
	shardtype = /obj/item/weapon/shard/plasma
	glasstype = /obj/item/stack/sheet/plasmaglass
	health = 120


/obj/structure/window/full/plasmareinforced
	name = "reinforced plasma window"
	desc = "A plasma-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic plasma windows are insanely fireproof."
	basestate = "plasmarwindow"
	icon_state = "plasmarwindow"
	shardtype = /obj/item/weapon/shard/plasma
	glasstype = /obj/item/stack/sheet/plasmaglass
	reinf = 1
	health = 160


/obj/structure/window/full/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow"
	basestate = "rwindow"
	health = 40
	reinf = 1

/obj/structure/window/full/reinforced/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/stack/rods) && state == 0)
		var/obj/item/stack/rods/R = W
		if(R.amount < 2)
			return
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		to_chat(user, "<span class='notice'>Now adding rods...</span>")
		if(do_after(user, 20, target=src))
			if(!src || !R || R.amount < 2)
				return
			R.use(2)
			to_chat(user, "<span class='notice'>You added the rods!</span>")
			var/obj/structure/window/full/shuttle/N = new(src.loc)
			N.state = 0
			N.anchored = 0
			N.air_update_turf(1)
			disassembled = 1
			qdel(src)
		return
	. = ..()

/obj/structure/window/full/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon_state = "twindow"
	basestate = "twindow"
	opacity = 1

/obj/structure/window/full/reinforced/tinted/frosted
	name = "frosted window"
	desc = "It looks rather strong and frosted over. Looks like it might take a few less hits then a normal reinforced window."
	icon_state = "fwindow"
	basestate = "fwindow"
	health = 30

/obj/structure/window/full/shuttle
	name = "shuttle window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "shuttle_window"
	basestate = "shuttle_window"
	health = 160
	reinf = 1
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/window/full/shuttle)

/obj/structure/window/full/shuttle/New()
	..()
	color = null
	if(icon != 'icons/obj/smooth_structures/shuttle_window.dmi')
		smooth = SMOOTH_FALSE
	update_icon()

/obj/structure/window/full/shuttle/update_icon() //icon_state has to be set manually
	if(smooth)
		icon_state = ""
		smooth_icon(src)
		smooth_icon_neighbors(src)
	update_walls() // Update smoothwalls, since they use shuttle windows as smoothables.
	return

/obj/structure/window/full/shuttle/proc/update_walls()
	for(var/cdir in cardinal)
		var/turf/simulated/wall/shuttle/T = get_step(src, cdir)
		if(istype(T))
			T.do_old_smooth()

/obj/structure/window/full/shuttle/Move()
	. = ..()
	update_icon()

/obj/structure/window/full/shuttle/dark
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "window5"
	basestate = "window5"