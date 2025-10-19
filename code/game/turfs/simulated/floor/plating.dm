/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	icon = 'icons/turf/floors/plating.dmi'
	intact = FALSE
	floor_tile = null
	var/unfastened = FALSE
	footstep = FOOTSTEP_PLATING
	smoothing_groups = list(SMOOTH_GROUP_TURF)
	real_layer = PLATING_LAYER

/turf/simulated/floor/plating/Initialize(mapload)
	. = ..()
	icon_plating = icon_state
	update_icon()

/turf/simulated/floor/plating/get_broken_states()
	return list("floorscorched1", "floorscorched2")

/turf/simulated/floor/plating/damaged/Initialize(mapload)
	. = ..()
	break_tile()

/turf/simulated/floor/plating/burnt/Initialize(mapload)
	. = ..()
	burn_tile()

/turf/simulated/floor/plating/damaged/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plating/burnt/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plating/update_icon_state()
	if(!broken && !burnt)
		icon_state = icon_plating //Because asteroids are 'platings' too.

/turf/simulated/floor/plating/examine(mob/user)
	. = ..()

	if(unfastened)
		. += "<span class='warning'>It has been unfastened.</span>"

/turf/simulated/floor/plating/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stack/rods))
		if(broken || burnt)
			to_chat(user, "<span class='warning'>Repair the plating first!</span>")
			return ITEM_INTERACT_COMPLETE
		var/obj/item/stack/rods/R = used
		if(R.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two rods to make a reinforced floor!</span>")
			return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='notice'>You begin reinforcing the floor...</span>")
			if(do_after(user, 30 * used.toolspeed, target = src))
				if(R.get_amount() >= 2 && !istype(src, /turf/simulated/floor/engine))
					ChangeTurf(/turf/simulated/floor/engine)
					playsound(src, used.usesound, 80, 1)
					R.use(2)
					to_chat(user, "<span class='notice'>You reinforce the floor.</span>")
				return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/stack/tile))
		if(!broken && !burnt)
			var/obj/item/stack/tile/W = used
			if(!W.use(1))
				return ITEM_INTERACT_COMPLETE
			ChangeTurf(W.turf_type)
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
			return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='warning'>This section is too damaged to support a tile! Use a welder to fix the damage.</span>")
			return ITEM_INTERACT_COMPLETE
	else if(is_glass_sheet(used))
		if(broken || burnt)
			to_chat(user, "<span class='warning'>Repair the plating first!</span>")
			return ITEM_INTERACT_COMPLETE
		var/obj/item/stack/sheet/R = used
		if(R.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two sheets to build a [used.name] floor!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You begin swapping the plating for [used]...</span>")
		if(do_after(user, 3 SECONDS * used.toolspeed, target = src))
			if(R.get_amount() >= 2 && !transparent_floor)
				if(istype(used, /obj/item/stack/sheet/plasmaglass)) //So, what type of glass floor do we want today?
					ChangeTurf(/turf/simulated/floor/transparent/glass/plasma)
				else if(istype(used, /obj/item/stack/sheet/plasmarglass))
					ChangeTurf(/turf/simulated/floor/transparent/glass/reinforced/plasma)
				else if(istype(used, /obj/item/stack/sheet/glass))
					ChangeTurf(/turf/simulated/floor/transparent/glass)
				else if(istype(used, /obj/item/stack/sheet/rglass))
					ChangeTurf(/turf/simulated/floor/transparent/glass/reinforced)
				else if(istype(used, /obj/item/stack/sheet/titaniumglass))
					ChangeTurf(/turf/simulated/floor/transparent/glass/titanium)
				else if(istype(used, /obj/item/stack/sheet/plastitaniumglass))
					ChangeTurf(/turf/simulated/floor/transparent/glass/titanium/plasma)
				playsound(src, used.usesound, 80, TRUE)
				R.use(2)
				to_chat(user, "<span class='notice'>You swap the plating for [used].</span>")
				new /obj/item/stack/sheet/metal(src, 2)
			return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/storage/backpack/satchel_flat)) //if you click plating with a smuggler satchel, place it on the plating please
		if(user.drop_item())
			used.forceMove(src)

		return ITEM_INTERACT_COMPLETE

	return ..()

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
	. = ..()
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
		TerraformTurf(baseturf, keep_icon = FALSE)

/turf/simulated/floor/plating/airless
	name = "airless plating"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plating/airless/Initialize(mapload)
	. = ..()
	name = "plating"

/turf/simulated/floor/plating/lavaland_air
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	icon_regular_floor = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000
	floor_tile = /obj/item/stack/rods
	footstep = FOOTSTEP_PLATING

/turf/simulated/floor/engine/update_icon_state()
	if(!broken && !burnt)
		icon_state = icon_regular_floor
	if(icon_regular_floor != icon_states(icon))
		icon_state = "engine"

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

/turf/simulated/floor/engine/wrench_act(mob/living/user, obj/item/wrench/W)
	if(!user)
		return
	. = TRUE
	to_chat(user, "<span class='notice'>You begin removing rods...</span>")
	if(W.use_tool(src, user, 3 SECONDS, 0, 50))
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
	icon_regular_floor = "cult"

/turf/simulated/floor/engine/cult/update_icon_state()
	if(!broken && !burnt)
		icon_state = icon_regular_floor
	if(icon_regular_floor != icon_states(icon))
		icon_state = "cult"

/turf/simulated/floor/engine/cult/Initialize(mapload)
	. = ..()
	icon_state = GET_CULT_DATA(cult_floor_icon_state, initial(icon_state))

/turf/simulated/floor/engine/cult/Entered(atom/A, atom/OL, ignoreRest)
	. = ..()
	var/counter = 0
	for(var/obj/effect/temp_visual/cult/turf/open/floor/floor in contents)
		if(++counter == 3)
			return

	if(!. && isliving(A))
		addtimer(CALLBACK(src, PROC_REF(spawn_visual)), 0.2 SECONDS, TIMER_DELETE_ME)

/turf/simulated/floor/engine/cult/proc/spawn_visual()
	new /obj/effect/temp_visual/cult/turf/open/floor(src)

/turf/simulated/floor/engine/cult/narsie_act()
	return

/turf/simulated/floor/engine/cult/lavaland_air
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

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

/turf/simulated/floor/engine/xenobio
	oxygen = 0
	temperature = 80
	nitrogen = 100

/turf/simulated/floor/engine/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/engine/airless/nodecay
	atmos_mode = ATMOS_MODE_NO_DECAY

/turf/simulated/floor/engine/asteroid
	temperature = 1000
	oxygen = 0
	nitrogen = 0
	carbon_dioxide = 1.2
	toxins = 10
	atmos_mode = ATMOS_MODE_NO_DECAY

/turf/simulated/floor/engine/lavaland_air
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/turf/simulated/floor/engine/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(floor_tile)
			if(prob(30))
				new floor_tile(src)
				make_plating(TRUE)
		else if(prob(30))
			ReplaceWithLattice()

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
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

/turf/simulated/floor/snow/ex_act(severity)
	return

/turf/simulated/floor/snow/pry_tile(obj/item/C, mob/user, silent = FALSE)
	return

/turf/simulated/floor/plating/metalfoam
	name = "foamed metal plating"
	icon_state = "metalfoam"
	/// which kind of metal this will turn into
	var/metal_kind = METAL_FOAM_ALUMINUM

/turf/simulated/floor/plating/metalfoam/iron
	icon_state = "ironfoam"
	metal_kind = METAL_FOAM_IRON

/turf/simulated/floor/plating/metalfoam/update_icon_state()
	switch(metal_kind)
		if(METAL_FOAM_ALUMINUM)
			icon_state = "metalfoam"
		if(METAL_FOAM_IRON)
			icon_state = "ironfoam"

/turf/simulated/floor/plating/metalfoam/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK

	if(istype(attacking) && attacking.force)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		var/smash_prob = max(0, attacking.force * 17 - metal_kind * 25) // A crowbar will have a 60% chance of a breakthrough on alum, 35% on iron
		if(prob(smash_prob))
			// YAR BE CAUSIN A HULL BREACH
			visible_message("<span class='danger'>[user] smashes through \the [src] with \the [attacking]!</span>")
			smash()
			return FINISH_ATTACK
		else
			visible_message("<span class='warning'>[user]'s [attacking.name] bounces against \the [src]!</span>")
			return FINISH_ATTACK

/turf/simulated/floor/plating/metalfoam/attack_animal(mob/living/simple_animal/M)
	M.do_attack_animation(src)
	if(M.melee_damage_upper == 0)
		M.visible_message("<span class='notice'>[M] nudges \the [src].</span>")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, TRUE, 1)
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

/// Used in situations like the anomalous crystal where we want
/// floors that look and act like asteroid floors but aren't.
/// This doesn't allow you to dig sand out of it but whatever.
/turf/simulated/floor/plating/false_asteroid
	gender = PLURAL
	name = "volcanic floor"
	baseturf = /turf/simulated/floor/plating/false_asteroid
	icon_state = "basalt"
	icon_plating = "basalt"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	var/environment_type = "basalt"
	var/turf_type = /turf/simulated/floor/plating/false_asteroid
	var/floor_variance = 20 //probability floor has a different icon state

/turf/simulated/floor/plating/false_asteroid/AfterChange(ignore_air, keep_cabling)
	. = ..()
	if(prob(floor_variance))
		icon_plating = "[environment_type][rand(0,12)]"
