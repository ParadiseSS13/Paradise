/turf/simulated/floor/plating/catwalk
	name = "Catwalk"
	desc = "See-through and cat-proof."
	icon = 'icons/turf/floors.dmi'
	icon_state = "catwalk_white"
	var/iscovered = 1
	var/base_state = "plating"	//so it wouldn't look like plating in the map tool

/turf/simulated/floor/plating/catwalk/New()
	..()
	icon_state = base_state	//swaps to the actual sprite it'll use
	update_overlays()

/turf/simulated/floor/plating/catwalk/proc/update_overlays()
	var/image/I = image(icon = 'icons/obj/catwalks.dmi', icon_state = "catwalk_white", loc = src, layer = 2.51)	//layer 2.51 is right above all on-plating stuff (pipes, disposals, cables)
	if(iscovered)
		overlays += I
	else
		overlays -= I
		qdel(I)

/turf/simulated/floor/plating/catwalk/attackby(obj/item/W, mob/user, params)
	if(iscovered)
		if(istype(W,/obj/item/crowbar))	//instant, but doesn't refund
			to_chat(user, "<span class='notice'>You pry apart the catwalk.</span>")
			playsound(src, W.usesound, 80, 1)
			iscovered = FALSE
			update_overlays()
			ChangeTurf(/turf/simulated/floor/plating)
			return 1
		if(istype(W,/obj/item/screwdriver))
			to_chat(user, "<span class='notice'>You begin to unscrew the rods and disassemble the catwalk...</span>")
			if(do_after(user, 20 * W.toolspeed, target = src))
				new /obj/item/stack/rods(src, 2)	//screwdriver refunds, but takes longer
				playsound(src, W.usesound, 80, 1)
				to_chat(user, "<span class='notice'>You disassemble the catwalk.</span>")
				iscovered = FALSE
				update_overlays()
				ChangeTurf(/turf/simulated/floor/plating)
			return 1
		if(istype(W,/obj/item/floor_painter))
			to_chat(user, "<span class='notice'>You begin dying the catwalk...</span>")
			if(do_after(user, 20 * W.toolspeed, target = src))
				to_chat(user, "<span class='notice'>You dye the catwalk with a darker color.</span>")
				playsound(src, 'sound/items/deconstruct.ogg', 80, 1)
				iscovered = FALSE
				update_overlays()
				ChangeTurf(/turf/simulated/floor/plating/catwalk/dark)
			return 1

/turf/simulated/floor/plating/catwalk/dark
	icon_state = "catwalk_dark"

/turf/simulated/floor/plating/catwalk/dark/update_overlays()
	var/image/I = image(icon = 'icons/obj/catwalks.dmi', icon_state = "catwalk_dark", loc = src, layer = 2.51)
	if(iscovered)
		overlays += I
	else
		overlays -= I
		qdel(I)

/turf/simulated/floor/plating/catwalk/dark/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/floor_painter) && iscovered)
		to_chat(user, "<span class='notice'>You begin dying over the catwalk...</span>")
		if(do_after(user, 20 * W.toolspeed, target = src))
			to_chat(user, "<span class='notice'>You dye the catwalk a brighter color.</span>")
			playsound(src, 'sound/items/deconstruct.ogg', 80, 1)
			iscovered = FALSE
			update_overlays()
			ChangeTurf(/turf/simulated/floor/plating/catwalk)
		return 1
	..()