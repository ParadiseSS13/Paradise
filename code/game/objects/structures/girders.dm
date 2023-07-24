/obj/structure/girder
	name = "girder"
	icon_state = "girder"
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	var/state = GIRDER_NORMAL
	var/girderpasschance = 20 // percentage chance that a projectile passes through the girder.
	max_integrity = 200
	var/can_displace = TRUE //If the girder can be moved around by crowbarring it
	var/metalUsed = 2 //used to determine amount returned in deconstruction
	var/metal_type = /obj/item/stack/sheet/metal

/obj/structure/girder/examine(mob/user)
	. = ..()
	switch(state)
		if(GIRDER_REINF)
			. += "<span class='notice'>The support struts are <b>screwed</b> in place.</span>"
		if(GIRDER_REINF_STRUTS)
			. += "<span class='notice'>The support struts are <i>unscrewed</i> and the inner <b>grille</b> is intact.</span>"
		if(GIRDER_NORMAL)
			if(can_displace)
				. += "<span class='notice'>The bolts are <b>lodged</b> in place.</span>"
		if(GIRDER_DISPLACED)
			. += "<span class='notice'>The bolts are <i>loosened</i>, but the <b>screws</b> are holding [src] together.</span>"
		if(GIRDER_DISASSEMBLED)
			. += "<span class='notice'>[src] is disassembled! You probably shouldn't be able to see this examine message.</span>"
	. += "<span class='notice'>Various types of metal sheets can be used on this to create different kinds of walls.</span>"
	. += "<span class='notice'>Apply a crowbar to this item to cause any walls to be made to be false walls. Use a wrench on this item to deconstruct it.</span>"


/obj/structure/girder/proc/refundMetal(metalAmount) //refunds metal used in construction when deconstructed
	for(var/i=0;i < metalAmount;i++)
		new metal_type(get_turf(src))

/obj/structure/girder/temperature_expose(datum/gas_mixture/air, exposed_temperature)
	..()
	var/temp_check = exposed_temperature
	if(temp_check >= GIRDER_MELTING_TEMP)
		take_damage(10)

/obj/structure/girder/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/gun/energy/plasmacutter))
		to_chat(user, "<span class='notice'>You start slicing apart the girder...</span>")
		if(do_after(user, 40 * W.toolspeed, target = src))
			if(!src)
				return
			playsound(loc, W.usesound, 100, 1)
			to_chat(user, "<span class='notice'>You slice apart the girder.</span>")
			refundMetal(metalUsed)
			qdel(src)

	else if(istype(W, /obj/item/pickaxe/drill/diamonddrill))
		to_chat(user, "<span class='notice'>You drill through the girder!</span>")
		refundMetal(metalUsed)
		qdel(src)

	else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
		playsound(loc, W.usesound, 100, 1)
		to_chat(user, "<span class='notice'>You disintegrate the girder!</span>")
		refundMetal(metalUsed)
		qdel(src)

	else if(istype(W, /obj/item/pyro_claws))
		playsound(loc, W.usesound, 100, 1)
		to_chat(user, "<span class='notice'>You melt the girder!</span>")
		refundMetal(metalUsed)
		qdel(src)

	else if(istype(W, /obj/item/stack))
		if(iswallturf(loc))
			to_chat(user, "<span class='warning'>There is already a wall present!</span>")
			return
		if(!isfloorturf(loc))
			to_chat(user, "<span class='warning'>A floor must be present to build a false wall!</span>")
			return
		if (locate(/obj/structure/falsewall) in loc.contents)
			to_chat(user, "<span class='warning'>There is already a false wall present!</span>")
			return
		if(istype(W, /obj/item/stack/sheet/runed_metal))
			to_chat(user, "<span class='warning'>You can't seem to make the metal bend.</span>")
			return

		if(istype(W,/obj/item/stack/rods))
			var/obj/item/stack/rods/S = W
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need at least five rods to create a false wall!</span>")
					return
				to_chat(user, "<span class='notice'>You start building a reinforced false wall...</span>")
				if(do_after(user, 20, target = src))
					if(!loc || !S || S.get_amount() < 5)
						return
					S.use(5)
					to_chat(user, "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
					var/obj/structure/falsewall/iron/FW = new (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(S.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need at least five rods to add plating!</span>")
					return
				to_chat(user, "<span class='notice'>You start adding plating...</span>")
				if (do_after(user, 40, target = src))
					if(!loc || !S || S.get_amount() < 5)
						return
					S.use(5)
					to_chat(user, "<span class='notice'>You add the plating.</span>")
					var/turf/T = get_turf(src)
					T.ChangeTurf(/turf/simulated/wall/mineral/iron)
					transfer_fingerprints_to(T)
					qdel(src)
				return

		if(istype(W, /obj/item/stack/ore/glass/basalt))
			var/obj/item/stack/ore/glass/basalt/A = W
			if(state == GIRDER_DISPLACED)
				if(A.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need at least two [A] to create a false wall!</span>")
					return
				if(do_after(user, 2 SECONDS, target = src))
					if(!loc || !A || A.get_amount() < 2)
						return
					A.use(2)
					to_chat(user, "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
					var/obj/structure/falsewall/rock_ancient/FW = new (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(A.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need at least two [A] to add plating!</span>")
					return
				to_chat(user, "<span class='notice'>You start adding [A]...</span>")
				if(do_after(user, 4 SECONDS, target = src))
					if(!src || !A || A.get_amount() < 2)
						return
					A.use(2)
					to_chat(user, "<span class='notice'>You add [A].</span>")
					var/turf/parent_turf = get_turf(src)
					parent_turf.ChangeTurf(/turf/simulated/mineral/ancient)
					for(var/turf/simulated/mineral/X in parent_turf.loc)
						X.add_hiddenprint(usr)
					qdel(src)
				return

		if(!istype(W,/obj/item/stack/sheet))
			return

		var/obj/item/stack/sheet/S = W
		if(!S.wall_allowed)
			to_chat(user, "<span class='warning'>You don't think that is good material for a wall!</span>")
			return

		if(istype(S, /obj/item/stack/sheet/wood))
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two planks of wood to create a false wall!</span>")
					return
				to_chat(user, "<span class='notice'>You start building a false wall...</span>")
				if(do_after(user, 20, target = src))
					if(!loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
					var/obj/structure/falsewall/wood/falsewood = new(loc)
					transfer_fingerprints_to(falsewood)
					qdel(src)
			else
				if(S.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two planks of wood to finish a wall!</span>")
					return
				to_chat(user, "<span class='notice'>You start adding plating...</span>")
				if(do_after(user, 40 * W.toolspeed, target = src))
					if(!src || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, "<span class='notice'>You add the plating.</span>")
					var/turf/Tsrc = get_turf(src)
					Tsrc.ChangeTurf(/turf/simulated/wall/mineral/wood)
					for(var/turf/simulated/wall/mineral/wood/X in Tsrc.loc)
						if(X)
							X.add_hiddenprint(usr)
					qdel(src)
				return

		else if(istype(S, /obj/item/stack/sheet/metal))
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two sheets of metal to create a false wall!</span>")
					return
				to_chat(user, "<span class='notice'>You start building a false wall...</span>")
				if(do_after(user, 20, target = src))
					if(!loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
					var/obj/structure/falsewall/F = new(loc)
					transfer_fingerprints_to(F)
					qdel(src)
			else
				if(S.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two sheets of metal to finish a wall!</span>")
					return
				to_chat(user, "<span class='notice'>You start adding plating...</span>")
				if(do_after(user, 40 * W.toolspeed, target = src))
					if(!src || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, "<span class='notice'>You add the plating.</span>")
					var/turf/Tsrc = get_turf(src)
					Tsrc.ChangeTurf(/turf/simulated/wall)
					for(var/turf/simulated/wall/X in Tsrc.loc)
						if(X)
							X.add_hiddenprint(usr)
					qdel(src)
				return

		if(istype(S, /obj/item/stack/sheet/plasteel))
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need at least two sheets to create a false wall!</span>")
					return
				to_chat(user, "<span class='notice'>You start building a reinforced false wall...</span>")
				if(do_after(user, 20, target = src))
					if(!loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, "<span class='notice'>You create a reinforced false wall. Push on it to open or close the passage.</span>")
					var/obj/structure/falsewall/reinforced/FW = new (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(state == GIRDER_REINF)
					if(S.get_amount() < 1)
						return
					to_chat(user, "<span class='notice'>You start finalizing the reinforced wall...</span>")
					if(do_after(user, 50, target = src))
						if(!src || !S || S.get_amount() < 1)
							return
						S.use(1)
						to_chat(user, "<span class='notice'>You fully reinforce the wall.</span>")
						var/turf/Tsrc = get_turf(src)
						Tsrc.ChangeTurf(/turf/simulated/wall/r_wall)
						for(var/turf/simulated/wall/r_wall/X in Tsrc.loc)
							if(X)
								X.add_hiddenprint(usr)
						qdel(src)
					return
				else
					if(S.get_amount() < 1)
						return
					to_chat(user, "<span class='notice'>You start reinforcing the girder...</span>")
					if(do_after(user,60, target = src))
						if(!src || !S || S.get_amount() < 1)
							return
						S.use(1)
						to_chat(user, "<span class='notice'>You reinforce the girder.</span>")
						var/obj/structure/girder/reinforced/R = new (loc)
						transfer_fingerprints_to(R)
						qdel(src)
					return

		if(S.sheettype)
			var/M = S.sheettype
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need at least two sheets to create a false wall!</span>")
					return
				if(do_after(user, 20, target = src))
					if(!loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
					var/F = text2path("/obj/structure/falsewall/[M]")
					var/obj/structure/FW = new F (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(S.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need at least two sheets to add plating!</span>")
					return
				to_chat(user, "<span class='notice'>You start adding plating...</span>")
				if(do_after(user,40, target = src))
					if(!src || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, "<span class='notice'>You add the plating.</span>")
					var/turf/Tsrc = get_turf(src)
					Tsrc.ChangeTurf(text2path("/turf/simulated/wall/mineral/[M]"))
					for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
						if(X)
							X.add_hiddenprint(usr)
					qdel(src)
				return

		add_hiddenprint(user)

	else
		return ..()

/obj/structure/girder/crowbar_act(mob/user, obj/item/I)
	if(!can_displace || state != GIRDER_NORMAL)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You start dislodging the girder...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_NORMAL)
		return
	to_chat(user, "<span class='notice'>You dislodge the girder.</span>")
	var/obj/structure/girder/displaced/D = new (loc)
	transfer_fingerprints_to(D)
	qdel(src)

/obj/structure/girder/screwdriver_act(mob/user, obj/item/I)
	if(state != GIRDER_DISPLACED && state != GIRDER_REINF && state != GIRDER_REINF_STRUTS)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	switch(state)
		if(GIRDER_DISPLACED)
			TOOL_ATTEMPT_DISMANTLE_MESSAGE
			if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_DISPLACED)
				return
			state = GIRDER_DISASSEMBLED
			TOOL_DISMANTLE_SUCCESS_MESSAGE
			var/obj/item/stack/sheet/metal/M = new(loc, 2)
			M.add_fingerprint(user)
			qdel(src)
		if(GIRDER_REINF)
			to_chat(user, "<span class='notice'>You start unsecuring support struts...</span>")
			if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_REINF)
				return
			to_chat(user, "<span class='notice'>You unsecure the support struts.</span>")
			state = GIRDER_REINF_STRUTS
		if(GIRDER_REINF_STRUTS)
			to_chat(user, "<span class='notice'>You start securing support struts...</span>")
			if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_REINF_STRUTS)
				return
			to_chat(user, "<span class='notice'>You secure the support struts.</span>")
			state = GIRDER_REINF

/obj/structure/girder/wirecutter_act(mob/user, obj/item/I)
	if(state != GIRDER_REINF_STRUTS)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You start removing the inner grille...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_REINF_STRUTS)
		return
	to_chat(user, "<span class='notice'>You remove the inner grille.</span>")
	new /obj/item/stack/sheet/plasteel(get_turf(src))
	var/obj/structure/girder/G = new (loc)
	transfer_fingerprints_to(G)
	qdel(src)

/obj/structure/girder/wrench_act(mob/user, obj/item/I)
	if(state != GIRDER_NORMAL && state != GIRDER_DISPLACED)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(state == GIRDER_NORMAL)
		TOOL_ATTEMPT_DISMANTLE_MESSAGE
		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_NORMAL)
			return
		state = GIRDER_DISASSEMBLED
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		refundMetal(metalUsed)
		qdel(src)
	else
		if(!isfloorturf(loc))
			to_chat(user, "<span class='warning'>A floor must be present to secure the girder!</span>")
			return
		to_chat(user, "<span class='notice'>You start securing the girder...</span>")
		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_DISPLACED)
			return
		to_chat(user, "<span class='notice'>You secure the girder.</span>")
		var/obj/structure/girder/G = new(loc)
		transfer_fingerprints_to(G)
		qdel(src)

/obj/structure/girder/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		refundMetal(metalUsed)
		qdel(src)

/obj/structure/girder/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return prob(girderpasschance)
	else
		if(istype(mover, /obj/item/projectile))
			return prob(girderpasschance)
		else
			return 0

/obj/structure/girder/CanPathfindPass(obj/item/card/id/ID, dir, caller, no_id = FALSE)
	. = !density
	if(ismovable(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSGRILLE)

/obj/structure/girder/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		var/remains = pick(/obj/item/stack/rods, /obj/item/stack/sheet/metal)
		new remains(loc)
	qdel(src)

/obj/structure/girder/narsie_act()
	if(prob(25))
		new /obj/structure/girder/cult(loc)
		qdel(src)

/obj/structure/girder/displaced
	name = "displaced girder"
	icon_state = "displaced"
	anchored = FALSE
	state = GIRDER_DISPLACED
	girderpasschance = 25
	max_integrity = 120

/obj/structure/girder/reinforced
	name = "reinforced girder"
	icon_state = "reinforced"
	state = GIRDER_REINF
	girderpasschance = 0
	max_integrity = 350

/obj/structure/girder/cult
	name = "runed girder"
	desc = "Framework made of a strange and shockingly cold metal. It doesn't seem to have any bolts."
	icon = 'icons/obj/cult.dmi'
	icon_state = "cultgirder"
	can_displace = FALSE
	metalUsed = 1
	metal_type = /obj/item/stack/sheet/runed_metal

/obj/structure/girder/cult/Initialize(mapload)
	. = ..()
	icon_state = SSticker.cultdat?.cult_girder_icon_state

/obj/structure/girder/cult/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/melee/cultblade/dagger) && iscultist(user)) //Cultists can demolish cult girders instantly with their dagger
		user.visible_message("<span class='warning'>[user] strikes [src] with [W]!</span>", "<span class='notice'>You demolish [src].</span>")
		refundMetal(metalUsed)
		qdel(src)
	else if(istype(W, /obj/item/gun/energy/plasmacutter))
		to_chat(user, "<span class='notice'>You start slicing apart the girder...</span>")
		if(do_after(user, 40* W.toolspeed, target = src))
			playsound(loc, W.usesound, 100, 1)
			to_chat(user, "<span class='notice'>You slice apart the girder.</span>")
			var/obj/item/stack/sheet/runed_metal/R = new(get_turf(src))
			R.amount = 1
			transfer_fingerprints_to(R)
			qdel(src)
	else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
		var/obj/item/pickaxe/drill/jackhammer/D = W
		to_chat(user, "<span class='notice'>Your jackhammer smashes through the girder!</span>")
		var/obj/item/stack/sheet/runed_metal/R = new(get_turf(src))
		R.amount = 1
		transfer_fingerprints_to(R)
		D.playDigSound()
		qdel(src)

	else if(istype(W, /obj/item/stack/sheet/runed_metal))
		var/obj/item/stack/sheet/runed_metal/R = W
		if(R.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need at least one sheet of runed metal to construct a runed wall!</span>")
			return 0
		user.visible_message("<span class='notice'>[user] begins laying runed metal on [src]...</span>", "<span class='notice'>You begin constructing a runed wall...</span>")
		if(do_after(user, 10, target = src))
			if(R.get_amount() < 1 || !R)
				return
			user.visible_message("<span class='notice'>[user] plates [src] with runed metal.</span>", "<span class='notice'>You construct a runed wall.</span>")
			R.use(1)
			var/turf/T = get_turf(src)
			T.ChangeTurf(/turf/simulated/wall/cult)
			qdel(src)
	else
		return ..()

/obj/structure/girder/cult/narsie_act()
	return

/obj/structure/girder/cult/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/runed_metal(drop_location(), 1)
	qdel(src)
