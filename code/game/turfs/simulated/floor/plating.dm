/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	icon = 'icons/turf/floors/plating.dmi'
	intact = FALSE
	floor_tile = null
	broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	burnt_states = list("floorscorched1", "floorscorched2")
	var/unfastened = FALSE
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_groups = list(SMOOTH_GROUP_TURF)
	real_layer = PLATING_LAYER

/turf/simulated/floor/plating/Initialize(mapload)
	. = ..()
	icon_plating = icon_state
	update_icon()

/turf/simulated/floor/plating/damaged/Initialize(mapload)
	. = ..()
	break_tile()

/turf/simulated/floor/plating/burnt/Initialize(mapload)
	. = ..()
	burn_tile()

/turf/simulated/floor/plating/update_icon_state()
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
			ChangeTurf(W.turf_type, keep_icon = FALSE)
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
		else
			to_chat(user, "<span class='warning'>This section is too damaged to support a tile! Use a welder to fix the damage.</span>")
		return TRUE

	else if(is_glass_sheet(C))
		if(broken || burnt)
			to_chat(user, "<span class='warning'>Repair the plating first!</span>")
			return TRUE
		var/obj/item/stack/sheet/R = C
		if(R.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two sheets to build a [C.name] floor!</span>")
			return TRUE
		to_chat(user, "<span class='notice'>You begin swapping the plating for [C]...</span>")
		if(do_after(user, 3 SECONDS * C.toolspeed, target = src))
			if(R.get_amount() >= 2 && !transparent_floor)
				if(istype(C, /obj/item/stack/sheet/plasmaglass)) //So, what type of glass floor do we want today?
					ChangeTurf(/turf/simulated/floor/transparent/glass/plasma)
				else if(istype(C, /obj/item/stack/sheet/plasmarglass))
					ChangeTurf(/turf/simulated/floor/transparent/glass/reinforced/plasma)
				else if(istype(C, /obj/item/stack/sheet/glass))
					ChangeTurf(/turf/simulated/floor/transparent/glass)
				else if(istype(C, /obj/item/stack/sheet/rglass))
					ChangeTurf(/turf/simulated/floor/transparent/glass/reinforced)
				else if(istype(C, /obj/item/stack/sheet/titaniumglass))
					ChangeTurf(/turf/simulated/floor/transparent/glass/titanium)
				else if(istype(C, /obj/item/stack/sheet/plastitaniumglass))
					ChangeTurf(/turf/simulated/floor/transparent/glass/titanium/plasma)
				playsound(src, C.usesound, 80, TRUE)
				R.use(2)
				to_chat(user, "<span class='notice'>You swap the plating for [C].</span>")
				new /obj/item/stack/sheet/metal(src, 2)
			return TRUE

	else if(istype(C, /obj/item/storage/backpack/satchel_flat)) //if you click plating with a smuggler satchel, place it on the plating please
		if(user.drop_item())
			C.forceMove(src)

		return TRUE

/turf/simulated/floor/plating/screwdriver_act(mob/user, obj/item/I)
	if(!I.tool_use_check(user, 0))
		return
	. = TRUE
	if(locate(/obj/structure/cable) in src)
		to_chat(user, "<span class='notice'>There is a cable still attached to [src]. Remove it first!</span>")
		return
	to_chat(user, "<span class='notice'>You start [unfastened ? "fastening" : "unfastening"] [src].</span>")
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
	if(user.a_intent == INTENT_HARM) // no repairing on harm intent, so you can use the welder in a fight near damaged paneling without welding your eyes out
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

/turf/simulated/floor/plating/remove_plating(mob/user)
	if(baseturf == /turf/space)
		ReplaceWithLattice()
	else
		TerraformTurf(baseturf)

/turf/simulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plating/airless/Initialize(mapload)
	. = ..()
	name = "plating"

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000
	floor_tile = /obj/item/stack/rods
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

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

/turf/simulated/floor/engine/cult/Initialize(mapload)
	. = ..()
	if(SSticker.mode)//only do this if the round is going..otherwise..fucking asteroid..
		icon_state = SSticker.cultdat.cult_floor_icon_state

/turf/simulated/floor/engine/cult/narsie_act()
	return

//air filled floors; used in atmos pressure chambers

/turf/simulated/floor/engine/n20
	name = "\improper N2O floor"
	sleeping_agent = 60000
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/co2
	name = "\improper CO2 floor"
	carbon_dioxide = 50000
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/plasma
	name = "plasma floor"
	toxins = 70000
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/engine/o2
	name = "\improper O2 floor"
	oxygen = 100000
	nitrogen = 0

/turf/simulated/floor/engine/n2
	name = "\improper N2 floor"
	nitrogen = 100000
	oxygen = 0

/turf/simulated/floor/engine/air
	name = "air floor"
	oxygen = 2644
	nitrogen = 10580


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

/turf/simulated/floor/plating/ironsand
	name = "Iron Sand"
	icon = 'icons/turf/floors/ironsand.dmi'
	icon_state = "ironsand1"

/turf/simulated/floor/plating/ironsand/Initialize(mapload)
	. = ..()
	icon_state = "ironsand[rand(1,15)]"

/turf/simulated/floor/plating/ironsand/remove_plating()
	return

/turf/simulated/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/plating/snow/ex_act(severity)
	return

/turf/simulated/floor/plating/snow/remove_plating()
	return

/turf/simulated/floor/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

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

/turf/simulated/floor/plating/metalfoam/update_icon_state()
	switch(metal)
		if(MFOAM_ALUMINUM)
			icon_state = "metalfoam"
		if(MFOAM_IRON)
			icon_state = "ironfoam"

/turf/simulated/floor/plating/metalfoam/attackby(obj/item/C, mob/user, params)
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
	icon = 'icons/turf/floors.dmi'
	icon_state = "alienpod1"

/turf/simulated/floor/plating/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1, 9)]"

/turf/simulated/floor/plating/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice_turf-0"
	oxygen = 22
	nitrogen = 82
	temperature = 180
	baseturf = /turf/simulated/floor/plating/ice
	slowdown = TRUE

/turf/simulated/floor/plating/ice/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY)

/turf/simulated/floor/plating/ice/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/simulated/floor/plating/ice/smooth
	icon_state = "ice_turf-255"
	base_icon_state = "ice_turf"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_FLOOR_ICE)
	smoothing_groups = list(SMOOTH_GROUP_FLOOR_ICE)

/turf/simulated/floor/plating/nitrogen
	oxygen = 0
	nitrogen = MOLES_N2STANDARD + MOLES_O2STANDARD
