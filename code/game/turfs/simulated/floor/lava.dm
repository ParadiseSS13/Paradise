/turf/simulated/floor/plating/lava
	name = "lava"
	icon_state = "lava"
	gender = PLURAL //"That's some lava."
	baseturf = /turf/simulated/floor/plating/lava //lava all the way down
	slowdown = 2
	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

/turf/simulated/floor/plating/lava/ex_act()
	return

/turf/simulated/floor/plating/lava/acid_act(acidpwr, acid_volume)
	return

/turf/simulated/floor/plating/lava/airless
	temperature = TCMB

/turf/simulated/floor/plating/lava/Entered(atom/movable/AM)
	if(burn_stuff(AM))
		START_PROCESSING(SSprocessing, src)

/turf/simulated/floor/plating/lava/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(burn_stuff(AM))
		START_PROCESSING(SSprocessing, src)

/turf/simulated/floor/plating/lava/process()
	if(!burn_stuff())
		STOP_PROCESSING(SSprocessing, src)

/turf/simulated/floor/plating/lava/singularity_act()
	return

/turf/simulated/floor/plating/lava/singularity_pull(S, current_size)
	return

/turf/simulated/floor/plating/lava/make_plating()
	return

/turf/simulated/floor/plating/lava/remove_plating()
	return

/turf/simulated/floor/plating/lava/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/simulated/floor/plating/lava/is_safe()
	if(find_safeties() && ..())
		return TRUE
	return FALSE

/turf/simulated/floor/plating/lava/proc/burn_stuff(AM)
	. = FALSE

	if(find_safeties())
		return FALSE

	var/thing_to_check = src
	if(AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
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
			if(L.flying)
				continue	//YOU'RE FLYING OVER IT
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


/turf/simulated/floor/plating/lava/attackby(obj/item/C, mob/user, params) //Lava isn't a good foundation to build on
	if(istype(C, /obj/item/stack/rods/lava))
		var/obj/item/stack/rods/lava/R = C
		var/obj/structure/lattice/lava/H = locate(/obj/structure/lattice/lava, src)
		if(H)
			to_chat(user, "<span class='warning'>There is already a lattice here!</span>")
			return
		if(R.use(1))
			to_chat(user, "<span class='warning'>You construct a lattice.</span>")
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/lava(locate(x, y, z))
		else
			to_chat(user, "<span class='warning'>You need one rod to build a heatproof lattice.</span>")
			return


/turf/simulated/floor/plating/lava/screwdriver_act()
	return

/turf/simulated/floor/plating/lava/welder_act()
	return

/turf/simulated/floor/plating/lava/break_tile()
	return

/turf/simulated/floor/plating/lava/burn_tile()
	return

/turf/simulated/floor/plating/lava/smooth
	name = "lava"
	baseturf = /turf/simulated/floor/plating/lava/smooth
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "lava-255"
	base_icon_state = "lava"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_FLOOR_LAVA)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_LAVA)

/turf/simulated/floor/plating/lava/smooth/lava_land_surface
	temperature = 300
	oxygen = 14
	nitrogen = 23
	planetary_atmos = TRUE
	baseturf = /turf/simulated/floor/chasm/straight_down/lava_land_surface

/turf/simulated/floor/plating/lava/smooth/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/plating/lava/smooth/lava_land_surface/plasma
	name = "liquid plasma"
	desc = "A flowing stream of chilled liquid plasma. You probably shouldn't get in."
	icon = 'icons/turf/floors/liquidplasma.dmi'
	icon_state = "liquidplasma-255"
	base_icon_state = "liquidplasma"
	baseturf = /turf/simulated/floor/plating/lava/smooth/lava_land_surface/plasma

	light_range = 3
	light_power = 0.75
	light_color = LIGHT_COLOR_PINK

/turf/simulated/floor/plating/lava/smooth/lava_land_surface/plasma/examine(mob/user)
	. = ..()
	. += "<span class='info'>Some <b>liquid plasma<b> could probably be scooped up with a <b>container</b>.</span>"

/turf/simulated/floor/plating/lava/smooth/lava_land_surface/plasma/attackby(obj/item/I, mob/user, params)
	if(!I.is_open_container())
		return ..()
	if(!I.reagents.add_reagent("plasma", 10))
		to_chat(user, "<span class='warning'>[I] is full.</span>")
		return
	to_chat(user, "<span class='notice'>You scoop out some plasma from the [src] using [I].</span>")

/turf/simulated/floor/plating/lava/smooth/lava_land_surface/plasma/burn_stuff(AM)
	. = FALSE
	if(find_safeties())
		return FALSE

	var/thing_to_check = src
	if(AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(isobj(thing))
			var/obj/O = thing
			if(!O.simulated)
				continue
			if((O.resistance_flags & (LAVA_PROOF|INDESTRUCTIBLE)) || O.throwing)
				continue
			. = TRUE
			if((O.resistance_flags & ON_FIRE))
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
		if(burn_living.flying)
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

/turf/simulated/floor/plating/lava/smooth/mapping_lava
	name = "Adaptive lava / chasm / plasma"
	icon_state = "mappinglava"
	base_icon_state = "mappinglava"
	baseturf = /turf/simulated/floor/plating/lava/smooth/mapping_lava
	temperature = 300
	oxygen = 14
	nitrogen = 23
	planetary_atmos = TRUE


/turf/simulated/floor/plating/lava/smooth/mapping_lava/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD //Lateload is needed, otherwise atmos does not setup right on the turf roundstart, leading it to be vacume. This is bad.

/turf/simulated/floor/plating/lava/smooth/mapping_lava/LateInitialize()
	. = ..()
	ChangeTurf(SSmapping.lavaland_theme, ignore_air = TRUE)


