/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	icon = 'icons/turf/floors/plating.dmi'
	intact = FALSE
	floor_tile = null
	broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	burnt_states = list("floorscorched1", "floorscorched2")

	var/unfastened = FALSE

	footstep_sounds = list(
	"human" = list('sound/effects/footstep/plating_human.ogg'),
	"xeno"  = list('sound/effects/footstep/plating_xeno.ogg')
	)

/turf/simulated/floor/plating/New()
	..()
	icon_plating = icon_state
	update_icon()

/turf/simulated/floor/plating/damaged/New()
	..()
	break_tile()

/turf/simulated/floor/plating/burnt/New()
	..()
	burn_tile()

/turf/simulated/floor/plating/update_icon()
	if(!..())
		return
	if(!broken && !burnt)
		icon_state = icon_plating //Because asteroids are 'platings' too.

/turf/simulated/floor/plating/examine(mob/user)
	. = ..()

	if(unfastened)
		. += "<span class='warning'>It has been unfastened.</span>"

/turf/simulated/floor/plating/attackby(obj/item/C, mob/user, params)
	if(..())
		return TRUE

	if(istype(C, /obj/item/stack/rods))
		if(broken || burnt)
			to_chat(user, "<span class='warning'>Repair the plating first!</span>")
			return TRUE
		var/obj/item/stack/rods/R = C
		if(R.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two rods to make a reinforced floor!</span>")
			return TRUE
		else
			to_chat(user, "<span class='notice'>You begin reinforcing the floor...</span>")
			if(do_after(user, 30 * C.toolspeed, target = src))
				if(R.get_amount() >= 2 && !istype(src, /turf/simulated/floor/engine))
					ChangeTurf(/turf/simulated/floor/engine)
					playsound(src, C.usesound, 80, 1)
					R.use(2)
					to_chat(user, "<span class='notice'>You reinforce the floor.</span>")
				return TRUE

	else if(istype(C, /obj/item/stack/tile))
		if(!broken && !burnt)
			var/obj/item/stack/tile/W = C
			if(!W.use(1))
				return
			ChangeTurf(W.turf_type)
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
		else
			to_chat(user, "<span class='warning'>This section is too damaged to support a tile! Use a welder to fix the damage.</span>")
		return TRUE

/turf/simulated/floor/plating/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You start [unfastened ? "fastening" : "unfastening"] [src].</span>")
	. = TRUE
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You [unfastened ? "fasten" : "unfasten"] [src].</span>")
	unfastened = !unfastened

/turf/simulated/floor/plating/welder_act(mob/user, obj/item/I)
	if(!broken && !burnt && !unfastened)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(unfastened)
		to_chat(user, "<span class='warning'>You start removing [src], exposing space after you're done!</span>")
		if(!I.use_tool(src, user, 50, volume = I.tool_volume * 2)) //extra loud to let people know something's going down
			return
		new /obj/item/stack/tile/plasteel(get_turf(src))
		remove_plating(user)
		return
	if(I.use_tool(src, user, volume = I.tool_volume)) //If we got this far, something needs fixing
		to_chat(user, "<span class='notice'>You fix some dents on the broken plating.</span>")
		overlays -= current_overlay
		current_overlay = null
		burnt = FALSE
		broken = FALSE
		update_icon()

/turf/simulated/floor/plating/proc/remove_plating(mob/user)
	if(baseturf == /turf/space)
		ReplaceWithLattice()
	else
		TerraformTurf(baseturf)

/turf/simulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/plating/airless/New()
	..()
	name = "plating"

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	var/insulated
	heat_capacity = 325000
	floor_tile = /obj/item/stack/rods

/turf/simulated/floor/engine/break_tile()
	return //unbreakable

/turf/simulated/floor/engine/burn_tile()
	return //unburnable

/turf/simulated/floor/engine/make_plating(force = 0)
	if(force)
		..()
	return //unplateable

/turf/simulated/floor/engine/attack_hand(mob/user as mob)
	user.Move_Pulled(src)

/turf/simulated/floor/engine/pry_tile(obj/item/C, mob/user, silent = FALSE)
	return

/turf/simulated/floor/engine/acid_act(acidpwr, acid_volume)
	acidpwr = min(acidpwr, 50) //we reduce the power so reinf floor never get melted.
	. = ..()

/turf/simulated/floor/engine/attackby(obj/item/C as obj, mob/user as mob, params)
	if(!C || !user)
		return
	if(istype(C, /obj/item/wrench))
		to_chat(user, "<span class='notice'>You begin removing rods...</span>")
		playsound(src, C.usesound, 80, 1)
		if(do_after(user, 30 * C.toolspeed, target = src))
			if(!istype(src, /turf/simulated/floor/engine))
				return
			new /obj/item/stack/rods(src, 2)
			ChangeTurf(/turf/simulated/floor/plating)
			return

	if(istype(C, /obj/item/stack/sheet/plasteel) && !insulated) //Insulating the floor
		to_chat(user, "<span class='notice'>You begin insulating [src]...</span>")
		if(do_after(user, 40, target = src) && !insulated) //You finish insulating the insulated insulated insulated insulated insulated insulated insulated insulated vacuum floor
			to_chat(user, "<span class='notice'>You finish insulating [src].</span>")
			var/obj/item/stack/sheet/plasteel/W = C
			W.use(1)
			thermal_conductivity = 0
			insulated = 1
			name = "insulated " + name
			return

/turf/simulated/floor/engine/ex_act(severity)
	switch(severity)
		if(1)
			ChangeTurf(baseturf)
		if(2)
			if(prob(50))
				ChangeTurf(baseturf)

/turf/simulated/floor/engine/blob_act(obj/structure/blob/B)
	if(prob(25))
		ChangeTurf(baseturf)

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/simulated/floor/engine/cult/New()
	..()
	if(SSticker.mode)//only do this if the round is going..otherwise..fucking asteroid..
		icon_state = SSticker.cultdat.cult_floor_icon_state

/turf/simulated/floor/engine/cult/narsie_act()
	return

/turf/simulated/floor/engine/cult/ratvar_act()
	. = ..()
	if(istype(src, /turf/simulated/floor/engine/cult)) //if we haven't changed type
		var/previouscolor = color
		color = "#FAE48C"
		animate(src, color = previouscolor, time = 8)

/turf/simulated/floor/engine/n20/New()
	..()
	var/datum/gas_mixture/adding = new
	var/datum/gas/sleeping_agent/trace_gas = new

	trace_gas.moles = 6000
	adding.trace_gases += trace_gas
	adding.temperature = T20C

	assume_air(adding)

/turf/simulated/floor/engine/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		if(floor_tile)
			if(prob(30))
				new floor_tile(src)
				make_plating()
		else if(prob(30))
			ReplaceWithLattice()

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/engine/insulated
	name = "insulated reinforced floor"
	icon_state = "engine"
	insulated = 1
	thermal_conductivity = 0

/turf/simulated/floor/engine/insulated/vacuum
	name = "insulated vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/plating/ironsand
	name = "Iron Sand"
	icon = 'icons/turf/floors/ironsand.dmi'
	icon_state = "ironsand1"

/turf/simulated/floor/plating/ironsand/New()
	..()
	icon_state = "ironsand[rand(1,15)]"

/turf/simulated/floor/plating/ironsand/remove_plating()
	return

/turf/simulated/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/simulated/floor/plating/snow/ex_act(severity)
	return

/turf/simulated/floor/plating/snow/remove_plating()
	return

/turf/simulated/floor/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/simulated/floor/snow/ex_act(severity)
	return

/turf/simulated/floor/snow/pry_tile(obj/item/C, mob/user, silent = FALSE)
	return

/turf/simulated/floor/plating/metalfoam
	name = "foamed metal plating"
	icon_state = "metalfoam"
	var/metal = MFOAM_ALUMINUM

/turf/simulated/floor/plating/metalfoam/iron
	icon_state = "ironfoam"
	metal = MFOAM_IRON

/turf/simulated/floor/plating/metalfoam/update_icon()
	switch(metal)
		if(MFOAM_ALUMINUM)
			icon_state = "metalfoam"
		if(MFOAM_IRON)
			icon_state = "ironfoam"

/turf/simulated/floor/plating/metalfoam/attackby(var/obj/item/C, mob/user, params)
	if(..())
		return TRUE

	if(istype(C) && C.force)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		var/smash_prob = max(0, C.force*17 - metal*25) // A crowbar will have a 60% chance of a breakthrough on alum, 35% on iron
		if(prob(smash_prob))
			// YAR BE CAUSIN A HULL BREACH
			visible_message("<span class='danger'>[user] smashes through \the [src] with \the [C]!</span>")
			smash()
		else
			visible_message("<span class='warning'>[user]'s [C.name] bounces against \the [src]!</span>")

/turf/simulated/floor/plating/metalfoam/attack_animal(mob/living/simple_animal/M)
	M.do_attack_animation(src)
	if(M.melee_damage_upper == 0)
		M.visible_message("<span class='notice'>[M] nudges \the [src].</span>")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		M.visible_message("<span class='danger'>\The [M] [M.attacktext] [src]!</span>")
		smash(src)

/turf/simulated/floor/plating/metalfoam/attack_alien(mob/living/carbon/alien/humanoid/M)
	M.visible_message("<span class='danger'>[M] tears apart \the [src]!</span>")
	smash(src)

/turf/simulated/floor/plating/metalfoam/burn_tile()
	smash()

/turf/simulated/floor/plating/metalfoam/proc/smash()
	ChangeTurf(baseturf)

/turf/simulated/floor/plating/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/simulated/floor/plating/abductor/New()
	..()
	icon_state = "alienpod[rand(1,9)]"

/turf/simulated/floor/plating/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/floors/ice_turfs.dmi'
	icon_state = "unsmooth"
	oxygen = 22
	nitrogen = 82
	temperature = 180
	baseturf = /turf/simulated/floor/plating/ice
	slowdown = TRUE
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/simulated/floor/plating/ice/smooth, /turf/simulated/floor/plating/ice)

/turf/simulated/floor/plating/ice/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, TRUE)

/turf/simulated/floor/plating/ice/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/simulated/floor/plating/ice/smooth
	icon_state = "smooth"
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith = list(/turf/simulated/floor/plating/ice/smooth, /turf/simulated/floor/plating/ice)
