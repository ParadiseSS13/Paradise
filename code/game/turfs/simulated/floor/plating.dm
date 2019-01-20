/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	icon = 'icons/turf/floors/plating.dmi'
	intact = 0
	floor_tile = null
	broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	burnt_states = list("floorscorched1", "floorscorched2")

	footstep_sounds = list(
	"human" = list('sound/effects/footstep/plating_human.ogg'),
	"xeno"  = list('sound/effects/footstep/plating_xeno.ogg')
	)

/turf/simulated/floor/plating/New()
	..()
	icon_plating = icon_state
	update_icon()

/turf/simulated/floor/plating/update_icon()
	if(!..())
		return
	if(!broken && !burnt)
		icon_state = icon_plating //Because asteroids are 'platings' too.

/turf/simulated/floor/plating/attackby(obj/item/C, mob/user, params)
	if(..())
		return 1

	if(istype(C, /obj/item/stack/rods))
		if(broken || burnt)
			to_chat(user, "<span class='warning'>Repair the plating first!</span>")
			return 1
		var/obj/item/stack/rods/R = C
		if(R.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two rods to make a reinforced floor!</span>")
			return 1
		else
			to_chat(user, "<span class='notice'>You begin reinforcing the floor...</span>")
			if(do_after(user, 30 * C.toolspeed, target = src))
				if(R.get_amount() >= 2 && !istype(src, /turf/simulated/floor/engine))
					ChangeTurf(/turf/simulated/floor/engine)
					playsound(src, C.usesound, 80, 1)
					R.use(2)
					to_chat(user, "<span class='notice'>You reinforce the floor.</span>")
				return 1

	else if(istype(C, /obj/item/stack/tile))
		if(!broken && !burnt)
			var/obj/item/stack/tile/W = C
			if(!W.use(1))
				return
			ChangeTurf(W.turf_type)
			playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
		else
			to_chat(user, "<span class='warning'>This section is too damaged to support a tile! Use a welder to fix the damage.</span>")
		return 1

	else if(istype(C, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = C
		if( welder.isOn() && (broken || burnt) )
			if(welder.remove_fuel(0,user))
				to_chat(user, "<span class='danger'>You fix some dents on the broken plating.</span>")
				playsound(src, welder.usesound, 80, 1)
				overlays -= current_overlay
				current_overlay = null
				burnt = 0
				broken = 0
				update_icon()
			return 1

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

/turf/simulated/floor/engine/make_plating(var/force = 0)
	if(force)
		..()
	return //unplateable

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

/turf/simulated/floor/engine/ex_act(severity,target)
	switch(severity)
		if(1)
			if(prob(80))
				ReplaceWithLattice()
			else if(prob(50))
				qdel(src)
			else
				if(builtin_tile)
					builtin_tile.loc = src
					builtin_tile = null
				make_plating(1)
		if(2)
			if(prob(50))
				make_plating(1)

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/simulated/floor/engine/cult/New()
	..()
	if(ticker.mode)//only do this if the round is going..otherwise..fucking asteroid..
		icon_state = ticker.cultdat.cult_floor_icon_state

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
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			make_plating() //does not actually do anything
		else
			if(prob(30))
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

/turf/simulated/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/simulated/floor/plating/snow/ex_act(severity)
	return

/turf/simulated/floor/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/simulated/floor/snow/ex_act(severity)
	return


// CATWALKS
// Space and plating, all in one buggy fucking turf!
// These are *so* fucking bad it makes me want to kill myself
/turf/simulated/floor/plating/airless/catwalk
	icon = 'icons/turf/catwalks.dmi'
	icon_state = "catwalk0"
	name = "catwalk"
	desc = "Cats really don't like these things."

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

/turf/simulated/floor/plating/airless/catwalk/New()
	..()
	set_light(4) //starlight
	name = "catwalk"
	update_icon(1)

/turf/simulated/floor/plating/airless/catwalk/update_icon(var/propogate=1)
	underlays.Cut()
	underlays += new /icon('icons/turf/space.dmi',SPACE_ICON_STATE)

	var/dirs = 0
	for(var/direction in cardinal)
		var/turf/T = get_step(src,direction)
		if(istype(T, /turf/simulated/floor/plating/airless/catwalk))
			var/turf/simulated/floor/plating/airless/catwalk/C=T
			dirs |= direction
			if(propogate)
				C.update_icon(0)
	icon_state="catwalk[dirs]"

/turf/simulated/floor/plating/airless/catwalk/attackby(obj/item/C, mob/user, params)
	if(istype(C, /obj/item/stack/rods))
		return 1
	else if(istype(C, /obj/item/stack/tile))
		return 1

	if(..())
		return 1

	if(!broken && isscrewdriver(C))
		to_chat(user, "<span class='notice'>You unscrew the catwalk's rods.</span>")
		new /obj/item/stack/rods(src, 1)
		ReplaceWithLattice()
		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			if(istype(T, /turf/simulated/floor/plating/airless/catwalk))
				var/turf/simulated/floor/plating/airless/catwalk/CW=T
				CW.update_icon(0)
		playsound(src, C.usesound, 80, 1)

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
		return 1
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
	ChangeTurf(/turf/space)

/turf/simulated/floor/plating/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/simulated/floor/plating/abductor/New()
	..()
	icon_state = "alienpod[rand(1,9)]"
