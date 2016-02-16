/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	floor_tile = null
	broken_states = list("platingdmg1", "platingdmg2", "platingdmg3")
	burnt_states = list("panelscorched")

	footstep_sounds = list(
	"human" = list('sound/effects/footstep/plating_human.ogg'),
	"xeno"  = list('sound/effects/footstep/plating_xeno.ogg')
	)

/turf/simulated/floor/plating/New()
	..()
	icon_plating = icon_state

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
			user << "<span class='warning'>Repair the plating first!</span>"
			return
		var/obj/item/stack/rods/R = C
		if (R.get_amount() < 2)
			user << "<span class='warning'>You need two rods to make a reinforced floor!</span>"
			return
		else
			user << "<span class='notice'>You begin reinforcing the floor...</span>"
			if(do_after(user, 30, target = src))
				if (R.get_amount() >= 2 && !istype(src, /turf/simulated/floor/engine))
					ChangeTurf(/turf/simulated/floor/engine)
					playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
					R.use(2)
					user << "<span class='notice'>You reinforce the floor.</span>"
				return

	else if(istype(C, /obj/item/stack/tile))
		if(!broken && !burnt)
			var/obj/item/stack/tile/W = C
			if(!W.use(1))
				return
			ChangeTurf(W.turf_type)
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
		else
			user << "<span class='warning'>This section is too damaged to support a tile! Use a welder to fix the damage.</span>"

	else if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/welder = C
		if( welder.isOn() && (broken || burnt) )
			if(welder.remove_fuel(0,user))
				user << "<span class='danger'>You fix some dents on the broken plating.</span>"
				playsound(src, 'sound/items/Welder.ogg', 80, 1)
				icon_state = icon_plating
				burnt = 0
				broken = 0

/turf/simulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/plating/airless/New()
	..()
	name = "plating"

/turf/simulated/floor/plating/airless/catwalk
	icon = 'icons/turf/catwalks.dmi'
	icon_state = "Floor3"
	name = "catwalk"
	desc = "Cats really don't like these things."

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
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

/turf/simulated/floor/engine/attackby(obj/item/weapon/C as obj, mob/user as mob, params)
	if(!C || !user)
		return
	if(istype(C, /obj/item/weapon/wrench))
		user << "<span class='notice'>You begin removing rods...</span>"
		playsound(src, 'sound/items/Ratchet.ogg', 80, 1)
		if(do_after(user, 30, target = src))
			if(!istype(src, /turf/simulated/floor/engine))
				return
			new /obj/item/stack/rods(src, 2)
			ChangeTurf(/turf/simulated/floor/plating)
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

/turf/simulated/floor/engine/cult/narsie_act()
	return

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



/turf/simulated/floor/plating/ironsand/New()
	..()
	name = "Iron Sand"
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
	underlays += new /icon('icons/turf/space.dmi',"[((x + y) ^ ~(x * y) + z) % 25]")

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
	if(..())
		return

	if(!broken && isscrewdriver(C))
		user << "<span class='notice'>You unscrew the catwalk's rods.</span>"
		new /obj/item/stack/rods(src, 1)
		ReplaceWithLattice()
		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			if(istype(T, /turf/simulated/floor/plating/airless/catwalk))
				var/turf/simulated/floor/plating/airless/catwalk/CW=T
				CW.update_icon(0)
		playsound(src, 'sound/items/Screwdriver.ogg', 80, 1)

/turf/simulated/floor/plasteel/airless
	name = "airless floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/plasteel/airless/New()
	..()
	name = "floor"