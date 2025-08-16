/**
 * Lava turf, burns things that are on it.
 * Currently a subtype of floor so that footsteps work on it.
 * Perhaps we could move it down to /turf/simulated/lava someday, as I dont think footsteps over lava are very important.
 */
/turf/simulated/floor/lava
	name = "lava"
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "lava-255"
	base_icon_state = "lava"
	gender = PLURAL //"That's some lava."
	baseturf = /turf/simulated/floor/lava //lava all the way down
	slowdown = 2
	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_FLOOR_LAVA)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_LAVA)
	intact = FALSE
	floor_tile = null
	real_layer = PLATING_LAYER


/turf/simulated/floor/lava/ex_act()
	return

/turf/simulated/floor/lava/acid_act(acidpwr, acid_volume)
	return

/turf/simulated/floor/lava/Entered(atom/movable/AM)
	..()
	if(burn_stuff(AM))
		START_PROCESSING(SSprocessing, src)

/turf/simulated/floor/lava/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(burn_stuff(AM))
		START_PROCESSING(SSprocessing, src)

/turf/simulated/floor/lava/process()
	if(!burn_stuff())
		STOP_PROCESSING(SSprocessing, src)

/turf/simulated/floor/lava/singularity_act()
	return

/turf/simulated/floor/lava/singularity_pull(S, current_size)
	return

/turf/simulated/floor/plating/lava/make_plating()
	return

/turf/simulated/floor/plating/lava/remove_plating()
	return

/turf/simulated/floor/plating/lava/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/simulated/floor/lava/is_safe()
	if(find_safeties() && ..())
		return TRUE
	return FALSE

/turf/simulated/floor/lava/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	if(!pass_info.is_living)
		return TRUE

	return pass_info.is_flying || pass_info.is_megafauna || (locate(/obj/structure/bridge_walkway) in src)

/turf/simulated/floor/lava/proc/burn_stuff(AM)
	. = FALSE

	if(find_safeties())
		return FALSE

	var/thing_to_check = src
	if(AM)
		thing_to_check = list(AM)
	for(var/atom/thing in thing_to_check)
		if(HAS_TRAIT(thing, TRAIT_FLYING))
			continue	//YOU'RE FLYING OVER IT

		if(isobj(thing))
			var/obj/O = thing
			if(!O.simulated)
				continue
			if((O.resistance_flags & (LAVA_PROOF|INDESTRUCTIBLE)) || O.throwing)
				continue
			. = TRUE
			if((O.resistance_flags & (ON_FIRE)))
				continue
			if(!(O.resistance_flags & FLAMMABLE))
				O.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
			if(O.resistance_flags & FIRE_PROOF)
				O.resistance_flags &= ~FIRE_PROOF
			if(O.armor.getRating(FIRE) > 50) //obj with 100% fire armor still get slowly burned away.
				O.armor = O.armor.setRating(fire_value = 50)
			O.fire_act(10000, 1000)

		else if(isliving(thing))
			. = TRUE
			var/mob/living/L = thing
			var/buckle_check = L.buckling
			if(!buckle_check)
				buckle_check = L.buckled
			if(isobj(buckle_check))
				var/obj/O = buckle_check
				if(O.resistance_flags & LAVA_PROOF)
					continue
			else if(isliving(buckle_check))
				var/mob/living/live = buckle_check
				if("lava" in live.weather_immunities)
					continue

			if("lava" in L.weather_immunities)
				continue

			L.adjustFireLoss(20)
			if(L) //mobs turning into object corpses could get deleted here.
				L.adjust_fire_stacks(20)
				L.IgniteMob()

/// Lava isn't a good foundation to build on.
/turf/simulated/floor/lava/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/stack/rods/lava))
		var/obj/item/stack/rods/lava/R = used
		var/obj/structure/lattice/lava/H = locate(/obj/structure/lattice/lava, src)
		if(H)
			to_chat(user, "<span class='warning'>There is already a lattice here!</span>")
			return ITEM_INTERACT_COMPLETE
		if(R.use(1))
			to_chat(user, "<span class='warning'>You construct a lattice.</span>")
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/lava(locate(x, y, z))
			return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='warning'>You need one rod to build a heatproof lattice.</span>")
			return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice/lava, src)
		if(!L)
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>")
			return ITEM_INTERACT_COMPLETE
		var/obj/item/stack/tile/plasteel/S = used
		if(S.use(1))
			qdel(L)
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You build a floor.</span>")
			ChangeTurf(/turf/simulated/floor/plating, keep_icon = FALSE)
			return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")
			return ITEM_INTERACT_COMPLETE

/turf/simulated/floor/lava/screwdriver_act()
	return

/turf/simulated/floor/lava/welder_act()
	return

/turf/simulated/floor/lava/break_tile()
	return

/turf/simulated/floor/lava/burn_tile()
	return

/turf/simulated/floor/lava/can_cross_safely(atom/movable/crossing)
	if(isliving(crossing))
		var/mob/living/crosser = crossing
		return (locate(/obj/structure/bridge_walkway) in src) || HAS_TRAIT(crossing, TRAIT_FLYING) || ("lava" in crosser.weather_immunities)
	return locate(/obj/structure/bridge_walkway) in src || HAS_TRAIT(crossing, TRAIT_FLYING)

/turf/simulated/floor/lava/lava_land_surface
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND
	baseturf = /turf/simulated/floor/chasm/straight_down/lava_land_surface

/turf/simulated/floor/lava/lava_land_surface/plasma
	name = "liquid plasma"
	desc = "A flowing stream of chilled liquid plasma. You probably shouldn't get in."
	icon = 'icons/turf/floors/liquidplasma.dmi'
	icon_state = "liquidplasma-255"
	base_icon_state = "liquidplasma"
	baseturf = /turf/simulated/floor/lava/lava_land_surface/plasma

	light_range = 3
	light_color = LIGHT_COLOR_PINK

/turf/simulated/floor/lava/lava_land_surface/plasma/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Some <b>liquid plasma<b> could probably be scooped up with a <b>container</b>.</span>"

/turf/simulated/floor/lava/lava_land_surface/plasma/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!used.is_open_container())
		return ..()
	if(!used.reagents.add_reagent("plasma", 10))
		to_chat(user, "<span class='warning'>[used] is full.</span>")
		return ITEM_INTERACT_COMPLETE

	to_chat(user, "<span class='notice'>You scoop out some plasma from the [src] using [used].</span>")
	return ITEM_INTERACT_COMPLETE

/turf/simulated/floor/lava/lava_land_surface/plasma/burn_stuff(AM)
	. = FALSE
	if(find_safeties())
		return FALSE

	var/thing_to_check = src
	if(AM)
		thing_to_check = list(AM)
	for(var/atom/thing in thing_to_check)
		if(HAS_TRAIT(thing, TRAIT_FLYING))
			continue	//YOU'RE FLYING OVER IT

		if(isobj(thing))
			var/obj/O = thing
			if(!O.simulated)
				continue
			if((O.resistance_flags & (LAVA_PROOF|INDESTRUCTIBLE)) || O.throwing)
				continue
			. = TRUE
			if(O.resistance_flags & ON_FIRE)
				continue
			if(!(O.resistance_flags & FLAMMABLE))
				O.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
			if(O.resistance_flags & FIRE_PROOF)
				O.resistance_flags &= ~FIRE_PROOF
			if(O.armor.getRating(FIRE) > 50) //obj with 100% fire armor still get slowly burned away.
				O.armor = O.armor.setRating(fire_value = 50)
			O.fire_act(10000, 1000)

		if(!isliving(thing))
			continue
		. = TRUE
		var/mob/living/burn_living = thing
		if(HAS_TRAIT(burn_living, TRAIT_FLYING))
			continue	//YOU'RE FLYING OVER IT
		var/buckle_check = burn_living.buckling
		if(!buckle_check)
			buckle_check = burn_living.buckled
		if(isobj(buckle_check))
			var/obj/O = buckle_check
			if(O.resistance_flags & LAVA_PROOF)
				continue
		else if(isliving(buckle_check))
			var/mob/living/live = buckle_check
			if("lava" in live.weather_immunities)
				continue
		if("lava" in burn_living.weather_immunities)
			continue
		burn_living.adjustFireLoss(2)
		if(QDELETED(burn_living))
			return
		burn_living.adjust_fire_stacks(20) //dipping into a stream of plasma would probably make you more flammable than usual
		burn_living.IgniteMob()
		burn_living.adjust_bodytemperature(-rand(50, 65)) //its cold, man
		if(!ishuman(burn_living) || prob(65))
			return
		var/mob/living/carbon/human/burn_human = burn_living
		var/datum/species/burn_species = burn_human.dna.species
		if(istype(burn_species, /datum/species/plasmaman) || istype(burn_species, /datum/species/machine)) //ignore plasmamen/robotic species.
			return

		burn_human.adjustToxLoss(15) //Cold mutagen is bad for you, more at 11.
		burn_human.adjustFireLoss(15)

/turf/simulated/floor/lava/mapping_lava
	name = "Adaptive lava / chasm / plasma"
	icon_state = "mappinglava"
	base_icon_state = "mappinglava"
	baseturf = /turf/simulated/floor/lava/mapping_lava
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/turf/simulated/floor/lava/mapping_lava/normal_air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	atmos_mode = ATMOS_MODE_SEALED
	atmos_environment = null

/turf/simulated/floor/lava/plasma
	name = "liquid plasma"
	desc = "A swirling pit of liquid plasma. It bubbles ominously."
	icon = 'icons/turf/floors/liquidplasma.dmi'
	icon_state = "liquidplasma-255"
	base_icon_state = "liquidplasma"
	baseturf = /turf/simulated/floor/lava/plasma
	light_range = 3
	light_color = LIGHT_COLOR_PINK

// special turf for the asteroid core on EmeraldStation
/turf/simulated/floor/lava/plasma/fuming
	baseturf = /turf/simulated/floor/lava/plasma/fuming
	atmos_mode = ATMOS_MODE_NO_DECAY

	// Hot Ass Plasma lava
	temperature = 1000
	oxygen = 0
	nitrogen = 0
	carbon_dioxide = 1.2
	toxins = 10

/turf/simulated/floor/lava/mapping_lava/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD //Lateload is needed, otherwise atmos does not setup right on the turf roundstart, leading it to be vacume. This is bad.

/turf/simulated/floor/lava/mapping_lava/LateInitialize()
	. = ..()
	if(SSmapping.lavaland_theme?.primary_turf_type)
		ChangeTurf(SSmapping.lavaland_theme.primary_turf_type, ignore_air = TRUE)
