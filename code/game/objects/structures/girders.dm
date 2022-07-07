/obj/structure/girder
	name = "girder"
	icon_state = "girder"
	anchored = 1
	density = 1
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
			. += span_notice("The support struts are <b>screwed</b> in place.")
		if(GIRDER_REINF_STRUTS)
			. += span_notice("The support struts are <i>unscrewed</i> and the inner <b>grille</b> is intact.")
		if(GIRDER_NORMAL)
			if(can_displace)
				. += span_notice("The bolts are <b>lodged</b> in place.")
		if(GIRDER_DISPLACED)
			. += span_notice("The bolts are <i>loosened</i>, but the <b>screws</b> are holding [src] together.")
		if(GIRDER_DISASSEMBLED)
			. += span_notice("[src] is disassembled! You probably shouldn't be able to see this examine message.")

/obj/structure/girder/detailed_examine()
	return "Use metal sheets on this to build a normal wall. Adding plasteel instead will make a reinforced wall.<br>\
			A false wall can be made by using a crowbar on this girder, and then adding metal or plasteel.<br>\
			You can dismantle the girder with a wrench."

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
		to_chat(user, span_notice("You start slicing apart the girder..."))
		if(do_after(user, 40 * W.toolspeed, target = src))
			if(!src)
				return
			playsound(loc, W.usesound, 100, 1)
			to_chat(user, span_notice("You slice apart the girder."))
			refundMetal(metalUsed)
			qdel(src)

	else if(istype(W, /obj/item/pickaxe/drill/diamonddrill))
		to_chat(user, span_notice("You drill through the girder!"))
		refundMetal(metalUsed)
		qdel(src)

	else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
		playsound(loc, W.usesound, 100, 1)
		to_chat(user, span_notice("You disintegrate the girder!"))
		refundMetal(metalUsed)
		qdel(src)

	else if(istype(W, /obj/item/stack))
		if(iswallturf(loc))
			to_chat(user, span_warning("There is already a wall present!"))
			return
		if(!isfloorturf(loc))
			to_chat(user, span_warning("A floor must be present to build a false wall!"))
			return
		if (locate(/obj/structure/falsewall) in loc.contents)
			to_chat(user, span_warning("There is already a false wall present!"))
			return
		if(istype(W, /obj/item/stack/sheet/runed_metal))
			to_chat(user, span_warning("You can't seem to make the metal bend."))
			return

		if(istype(W,/obj/item/stack/rods))
			var/obj/item/stack/rods/S = W
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 5)
					to_chat(user, span_warning("You need at least five rods to create a false wall!"))
					return
				to_chat(user, span_notice("You start building a reinforced false wall..."))
				if(do_after(user, 20, target = src))
					if(!loc || !S || S.get_amount() < 5)
						return
					S.use(5)
					to_chat(user, span_notice("You create a false wall. Push on it to open or close the passage."))
					var/obj/structure/falsewall/iron/FW = new (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(S.get_amount() < 5)
					to_chat(user, span_warning("You need at least five rods to add plating!"))
					return
				to_chat(user, span_notice("You start adding plating..."))
				if (do_after(user, 40, target = src))
					if(!loc || !S || S.get_amount() < 5)
						return
					S.use(5)
					to_chat(user, span_notice("You add the plating."))
					var/turf/T = get_turf(src)
					T.ChangeTurf(/turf/simulated/wall/mineral/iron)
					transfer_fingerprints_to(T)
					qdel(src)
				return

		if(!istype(W,/obj/item/stack/sheet))
			return

		var/obj/item/stack/sheet/S = W
		if(!S.wall_allowed)
			to_chat(user, span_warning("You don't think that is good material for a wall!"))
			return

		if(istype(S, /obj/item/stack/sheet/wood))
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					to_chat(user, span_warning("You need two planks of wood to create a false wall!"))
					return
				to_chat(user, span_notice("You start building a false wall..."))
				if(do_after(user, 20, target = src))
					if(!loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, span_notice("You create a false wall. Push on it to open or close the passage."))
					var/obj/structure/falsewall/wood/falsewood = new(loc)
					transfer_fingerprints_to(falsewood)
					qdel(src)
			else
				if(S.get_amount() < 2)
					to_chat(user, span_warning("You need two planks of wood to finish a wall!"))
					return
				to_chat(user, span_notice("You start adding plating..."))
				if(do_after(user, 40 * W.toolspeed, target = src))
					if(!src || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, span_notice("You add the plating."))
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
					to_chat(user, span_warning("You need two sheets of metal to create a false wall!"))
					return
				to_chat(user, span_notice("You start building a false wall..."))
				if(do_after(user, 20, target = src))
					if(!loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, span_notice("You create a false wall. Push on it to open or close the passage."))
					var/obj/structure/falsewall/F = new(loc)
					transfer_fingerprints_to(F)
					qdel(src)
			else
				if(S.get_amount() < 2)
					to_chat(user, span_warning("You need two sheets of metal to finish a wall!"))
					return
				to_chat(user, span_notice("You start adding plating..."))
				if(do_after(user, 40 * W.toolspeed, target = src))
					if(!src || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, span_notice("You add the plating."))
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
					to_chat(user, span_warning("You need at least two sheets to create a false wall!"))
					return
				to_chat(user, span_notice("You start building a reinforced false wall..."))
				if(do_after(user, 20, target = src))
					if(!loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, span_notice("You create a reinforced false wall. Push on it to open or close the passage."))
					var/obj/structure/falsewall/reinforced/FW = new (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(state == GIRDER_REINF)
					if(S.get_amount() < 1)
						return
					to_chat(user, span_notice("You start finalizing the reinforced wall..."))
					if(do_after(user, 50, target = src))
						if(!src || !S || S.get_amount() < 1)
							return
						S.use(1)
						to_chat(user, span_notice("You fully reinforce the wall."))
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
					to_chat(user, span_notice("You start reinforcing the girder..."))
					if(do_after(user,60, target = src))
						if(!src || !S || S.get_amount() < 1)
							return
						S.use(1)
						to_chat(user, span_notice("You reinforce the girder."))
						var/obj/structure/girder/reinforced/R = new (loc)
						transfer_fingerprints_to(R)
						qdel(src)
					return

		if(S.sheettype)
			var/M = S.sheettype
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					to_chat(user, span_warning("You need at least two sheets to create a false wall!"))
					return
				if(do_after(user, 20, target = src))
					if(!loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, span_notice("You create a false wall. Push on it to open or close the passage."))
					var/F = text2path("/obj/structure/falsewall/[M]")
					var/obj/structure/FW = new F (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(S.get_amount() < 2)
					to_chat(user, span_warning("You need at least two sheets to add plating!"))
					return
				to_chat(user, span_notice("You start adding plating..."))
				if(do_after(user,40, target = src))
					if(!src || !S || S.get_amount() < 2)
						return
					S.use(2)
					to_chat(user, span_notice("You add the plating."))
					var/turf/Tsrc = get_turf(src)
					Tsrc.ChangeTurf(text2path("/turf/simulated/wall/mineral/[M]"))
					for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
						if(X)
							X.add_hiddenprint(usr)
					qdel(src)
				return

		add_hiddenprint(user)

	else if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if(P.pipe_type in list(0, 1, 5))	//simple pipes, simple bends, and simple manifolds.
			if(!user.drop_item())
				return
			P.loc = src.loc
			to_chat(user, span_notice("You fit the pipe into \the [src]."))
	else
		return ..()

/obj/structure/girder/crowbar_act(mob/user, obj/item/I)
	if(!can_displace || state != GIRDER_NORMAL)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, span_notice("You start dislodging the girder..."))
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_NORMAL)
		return
	to_chat(user, span_notice("You dislodge the girder."))
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
			to_chat(user, span_notice("You start unsecuring support struts..."))
			if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_REINF)
				return
			to_chat(user, span_notice("You unsecure the support struts."))
			state = GIRDER_REINF_STRUTS
		if(GIRDER_REINF_STRUTS)
			to_chat(user, span_notice("You start securing support struts..."))
			if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_REINF_STRUTS)
				return
			to_chat(user, span_notice("You secure the support struts."))
			state = GIRDER_REINF

/obj/structure/girder/wirecutter_act(mob/user, obj/item/I)
	if(state != GIRDER_REINF_STRUTS)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, span_notice("You start removing the inner grille..."))
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_REINF_STRUTS)
		return
	to_chat(user, span_notice("You remove the inner grille."))
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
			to_chat(user, span_warning("A floor must be present to secure the girder!"))
			return
		to_chat(user, span_notice("You start securing the girder..."))
		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_DISPLACED)
			return
		to_chat(user, span_notice("You secure the girder."))
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

/obj/structure/girder/CanAStarPass(ID, dir, caller)
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
	anchored = 0
	state = GIRDER_DISPLACED
	girderpasschance = 25
	max_integrity = 120

/obj/structure/girder/reinforced
	name = "reinforced girder"
	icon_state = "reinforced"
	state = GIRDER_REINF
	girderpasschance = 0
	max_integrity = 350

/obj/structure/girder/reinforced/detailed_examine()
	return "Add another sheet of plasteel to finish."

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
		user.visible_message(span_warning("[user] strikes [src] with [W]!"), span_notice("You demolish [src]."))
		refundMetal(metalUsed)
		qdel(src)
	else if(istype(W, /obj/item/gun/energy/plasmacutter))
		to_chat(user, span_notice("You start slicing apart the girder..."))
		if(do_after(user, 40* W.toolspeed, target = src))
			playsound(loc, W.usesound, 100, 1)
			to_chat(user, span_notice("You slice apart the girder."))
			var/obj/item/stack/sheet/runed_metal/R = new(get_turf(src))
			R.amount = 1
			transfer_fingerprints_to(R)
			qdel(src)
	else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
		var/obj/item/pickaxe/drill/jackhammer/D = W
		to_chat(user, span_notice("Your jackhammer smashes through the girder!"))
		var/obj/item/stack/sheet/runed_metal/R = new(get_turf(src))
		R.amount = 1
		transfer_fingerprints_to(R)
		D.playDigSound()
		qdel(src)

	else if(istype(W, /obj/item/stack/sheet/runed_metal))
		var/obj/item/stack/sheet/runed_metal/R = W
		if(R.get_amount() < 1)
			to_chat(user, span_warning("You need at least one sheet of runed metal to construct a runed wall!"))
			return 0
		user.visible_message(span_notice("[user] begins laying runed metal on [src]..."), span_notice("You begin constructing a runed wall..."))
		if(do_after(user, 10, target = src))
			if(R.get_amount() < 1 || !R)
				return
			user.visible_message(span_notice("[user] plates [src] with runed metal."), span_notice("You construct a runed wall."))
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
