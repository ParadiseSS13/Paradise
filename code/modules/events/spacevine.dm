//Types of usual mutations
#define	POSITIVE 			1
#define	NEGATIVE			2
#define	MINOR_NEGATIVE		3

/datum/event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	var/obj/effect/spacevine/SV = new()

	for(var/area/hallway/A in world)
		for(var/turf/F in A)
			if(F.Enter(SV))
				turfs += F

	qdel(SV)

	if(turfs.len) //Pick a turf to spawn at if we can
		var/turf/T = pick(turfs)
		new/obj/effect/spacevine_controller(T) //spawn a controller at turf


/datum/spacevine_mutation
	var/name = ""
	var/severity = 1
	var/hue
	var/quality

/datum/spacevine_mutation/proc/add_mutation_to_vinepiece(obj/effect/spacevine/holder)
	holder.mutations |= src
	holder.color = hue

/datum/spacevine_mutation/proc/process_mutation(obj/effect/spacevine/holder)
	return

/datum/spacevine_mutation/proc/process_temperature(obj/effect/spacevine/holder, temp, volume)
	return

/datum/spacevine_mutation/proc/on_birth(obj/effect/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_grow(obj/effect/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_death(obj/effect/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_hit(obj/effect/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	. = expected_damage

/datum/spacevine_mutation/proc/on_cross(obj/effect/spacevine/holder, mob/crosser)
	return

/datum/spacevine_mutation/proc/on_chem(obj/effect/spacevine/holder, datum/reagent/R)
	return

/datum/spacevine_mutation/proc/on_eat(obj/effect/spacevine/holder, mob/living/eater)
	return

/datum/spacevine_mutation/proc/on_spread(obj/effect/spacevine/holder, turf/target)
	return

/datum/spacevine_mutation/proc/on_buckle(obj/effect/spacevine/holder, mob/living/buckled)
	return

/datum/spacevine_mutation/proc/on_explosion(severity, obj/effect/spacevine/holder)
	return


/datum/spacevine_mutation/space_covering
	name = "space protective"
	hue = "#aa77aa"
	quality = POSITIVE

/turf/simulated/floor/vines
	color = "#aa77aa"
	icon_state = "vinefloor"
	broken_states = list()


//All of this shit is useless for vines

/turf/simulated/floor/vines/attackby()
	return

/turf/simulated/floor/vines/burn_tile()
	return

/turf/simulated/floor/vines/break_tile()
	return

/turf/simulated/floor/vines/make_plating()
	return

/turf/simulated/floor/vines/break_tile_to_plating()
	return

/turf/simulated/floor/vines/ex_act(severity)
	if(severity < 3)
		ChangeTurf(baseturf)

/turf/simulated/floor/vines/narsie_act()
	if(prob(20))
		ChangeTurf(baseturf) //nar sie eats this shit

/turf/simulated/floor/vines/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(50))
			ChangeTurf(baseturf)

/turf/simulated/floor/vines/ChangeTurf(turf/open/floor/T)
	. = ..()
	//Do this *after* the turf has changed as qdel in spacevines will call changeturf again if it hasn't
	for(var/obj/effect/spacevine/SV in src)
		qdel(SV)

/datum/spacevine_mutation/space_covering
	var/static/list/coverable_turfs

/datum/spacevine_mutation/space_covering/New()
	. = ..()
	if(!coverable_turfs)
		coverable_turfs = typecacheof(list(
			/turf/space
		))
		coverable_turfs -= typecacheof(list(
			/turf/space/transit
		))

/datum/spacevine_mutation/space_covering/on_grow(obj/effect/spacevine/holder)
	process_mutation(holder)

/datum/spacevine_mutation/space_covering/process_mutation(obj/effect/spacevine/holder)
	var/turf/T = get_turf(holder)
	if(is_type_in_typecache(T, coverable_turfs))
		var/currtype = T.type
		T.ChangeTurf(/turf/simulated/floor/vines)
		T.baseturf = currtype

/datum/spacevine_mutation/space_covering/on_death(obj/effect/spacevine/holder)
	var/turf/T = get_turf(holder)
	if(istype(T, /turf/simulated/floor/vines))
		T.ChangeTurf(T.baseturf)

/datum/spacevine_mutation/bluespace
	name = "bluespace"
	hue = "#3333ff"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/bluespace/on_spread(obj/effect/spacevine/holder, turf/target)
	if(holder.energy > 1 && !locate(/obj/effect/spacevine) in target)
		holder.master.spawn_spacevine_piece(target, holder)

/datum/spacevine_mutation/light
	name = "light"
	hue = "#ffff00"
	quality = POSITIVE
	severity = 4

/datum/spacevine_mutation/light/on_grow(obj/effect/spacevine/holder)
	if(holder.energy)
		holder.set_light(severity)

/datum/spacevine_mutation/toxicity
	name = "toxic"
	hue = "#ff00ff"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/toxicity/on_cross(obj/effect/spacevine/holder, mob/living/crosser)
	if(issilicon(crosser))
		return
	if(prob(severity) && istype(crosser) && !isvineimmune(crosser))
		to_chat(crosser, "<span class='alert'>You accidently touch the vine and feel a strange sensation.</span>")
		crosser.adjustToxLoss(5)

/datum/spacevine_mutation/toxicity/on_eat(obj/effect/spacevine/holder, mob/living/eater)
	if(!isvineimmune(eater))
		eater.adjustToxLoss(5)

/datum/spacevine_mutation/explosive  //OH SHIT IT CAN CHAINREACT RUN!!!
	name = "explosive"
	hue = "#ff0000"
	quality = NEGATIVE
	severity = 2

/datum/spacevine_mutation/explosive/on_explosion(explosion_severity, obj/effect/spacevine/holder)
	if(explosion_severity < 3)
		qdel(holder)
	else
		. = 1
		spawn(5)
			qdel(holder)

/datum/spacevine_mutation/explosive/on_death(obj/effect/spacevine/holder, mob/hitter, obj/item/I)
	explosion(holder.loc, 0, 0, severity, 0, 0)

/datum/spacevine_mutation/fire_proof
	name = "fire proof"
	hue = "#ff8888"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/fire_proof/process_temperature(obj/effect/spacevine/holder, temp, volume)
	return 1

/datum/spacevine_mutation/fire_proof/on_hit(obj/effect/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	if(I && I.damtype == "fire")
		. = 0
	else
		. = expected_damage

/datum/spacevine_mutation/vine_eating
	name = "vine eating"
	hue = "#ff7700"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/vine_eating/on_spread(obj/effect/spacevine/holder, turf/target)
	var/obj/effect/spacevine/prey = locate() in target
	if(prey && !prey.mutations.Find(src))  //Eat all vines that are not of the same origin
		qdel(prey)

/datum/spacevine_mutation/aggressive_spread  //very OP, but im out of other ideas currently
	name = "aggressive spreading"
	hue = "#333333"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/aggressive_spread/on_spread(obj/effect/spacevine/holder, turf/target)
	target.ex_act(severity) // vine immunity handled at /mob/ex_act

/datum/spacevine_mutation/aggressive_spread/on_buckle(obj/effect/spacevine/holder, mob/living/buckled)
	buckled.ex_act(severity)

/datum/spacevine_mutation/transparency
	name = "transparent"
	hue = ""
	quality = POSITIVE

/datum/spacevine_mutation/transparency/on_grow(obj/effect/spacevine/holder)
	holder.set_opacity(0)
	holder.alpha = 125

/datum/spacevine_mutation/thorns
	name = "thorny"
	hue = "#666666"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/thorns/on_cross(obj/effect/spacevine/holder, mob/living/crosser)
	if(prob(severity) && istype(crosser) && !isvineimmune(holder))
		var/mob/living/M = crosser
		M.adjustBruteLoss(5)
		to_chat(M, "<span class='alert'>You cut yourself on the thorny vines.</span>")

/datum/spacevine_mutation/thorns/on_hit(obj/effect/spacevine/holder, mob/living/hitter, obj/item/I, expected_damage)
	if(prob(severity) && istype(hitter) && !isvineimmune(holder))
		var/mob/living/M = hitter
		M.adjustBruteLoss(5)
		to_chat(M, "<span class='alert'>You cut yourself on the thorny vines.</span>")
	. =	expected_damage

/datum/spacevine_mutation/woodening
	name = "hardened"
	hue = "#997700"
	quality = NEGATIVE

/datum/spacevine_mutation/woodening/on_grow(obj/effect/spacevine/holder)
	if(holder.energy)
		holder.density = 1
	holder.maxhealth = 100
	holder.health = holder.maxhealth

/datum/spacevine_mutation/woodening/on_hit(obj/effect/spacevine/holder, mob/living/hitter, obj/item/I, expected_damage)
	if(!is_sharp(I))
		. = expected_damage * 0.5
	else
		. = expected_damage

/datum/spacevine_mutation/flowering
	name = "flowering"
	hue = "#0A480D"
	quality = NEGATIVE
	severity = 10

/datum/spacevine_mutation/flowering/on_grow(obj/effect/spacevine/holder)
	if(holder.energy == 2 && prob(severity) && !locate(/obj/structure/alien/resin/flower_bud_enemy) in range(5,holder))
		new /obj/structure/alien/resin/flower_bud_enemy(get_turf(holder))

/datum/spacevine_mutation/flowering/on_cross(obj/effect/spacevine/holder, mob/living/crosser)
	if(prob(25))
		holder.entangle(crosser)


// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/effect/spacevine
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = 1
	density = 0
	layer = MOB_LAYER + 0.8
	mouse_opacity = 2 //Clicking anywhere on the turf is good enough
	pass_flags = PASSTABLE | PASSGRILLE
	var/health = 50
	var/maxhealth = 50
	var/energy = 0
	var/obj/effect/spacevine_controller/master = null
	var/list/mutations = list()

/obj/effect/spacevine/New()
	..()
	color = "#ffffff"

/obj/effect/spacevine/examine(mob/user)
	..()
	var/text = "This one is a"
	if(mutations.len)
		for(var/A in mutations)
			var/datum/spacevine_mutation/SM = A
			text += " [SM.name]"
	else
		text += " normal"
	text += " vine."
	to_chat(user, text)

/obj/effect/spacevine/Destroy()
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_death(src)
	if(master)
		master.vines -= src
		master.growth_queue -= src
		if(!master.vines.len)
			var/obj/item/seeds/kudzu/KZ = new(loc)
			KZ.mutations |= mutations
			KZ.set_potency(master.mutativeness * 10)
			KZ.set_production((master.spread_cap / initial(master.spread_cap)) * 5)
	master = null
	mutations.Cut()
	set_opacity(0)
	if(buckled_mob)
		unbuckle_mob()
	return ..()

/obj/effect/spacevine/proc/add_mutation(datum/spacevine_mutation/mutation)
	mutations |= mutation
	color = mutation.hue

/obj/effect/spacevine/proc/on_chem_effect(datum/reagent/R)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_chem(src, R)
	if(!override && istype(R, /datum/reagent/glyphosate))
		if(prob(50))
			qdel(src)

/obj/effect/spacevine/proc/eat(mob/eater)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_eat(src, eater)
	if(!override)
		if(prob(10))
			eater.say("Nom")
		qdel(src)

/obj/effect/spacevine/attackby(obj/item/weapon/W, mob/user, params)
	if (!W || !user || !W.type)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	var/force = W.force

	if(istype(W, /obj/item/weapon/scythe))
		force = force * 4
		for(var/obj/effect/spacevine/B in orange(1,src))
			B.health = health - force
			if(B.health < 1)
				qdel(B)

		health = health - force

		if(health < 1)
			qdel(src)

		return

	if(is_sharp(W))
		force = force * 4

	if(W && W.damtype == "fire")
		force = force * 4

	for(var/datum/spacevine_mutation/SM in mutations)
		force = SM.on_hit(src, user, W, force) //on_hit now takes override damage as arg and returns new value for other mutations to permutate further

	health = health - force
	if(health < 1)
		qdel(src)

	..()

/obj/effect/spacevine/Crossed(mob/crosser)
	if(isliving(crosser))
		for(var/datum/spacevine_mutation/SM in mutations)
			SM.on_cross(src, crosser)

/obj/effect/spacevine/attack_hand(mob/user)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	user_unbuckle_mob(user, user)

/obj/effect/spacevine/attack_alien(mob/living/user)
	eat(user)

/obj/effect/spacevine_controller
	invisibility = 101
	var/list/obj/effect/spacevine/vines = list()
	var/list/growth_queue = list()
	var/spread_multiplier = 5
	var/spread_cap = 30
	var/list/mutations_list = list()
	var/mutativeness = 1

/obj/effect/spacevine_controller/New(loc, list/muts, potency, production)
	color = "#ffffff"
	spawn_spacevine_piece(loc, , muts)
	processing_objects.Add(src)
	init_subtypes(/datum/spacevine_mutation/, mutations_list)
	if(potency != null)
		mutativeness = potency / 10
	if(production != null)
		spread_cap *= production / 5
		spread_multiplier /= production / 5
	..()


/obj/effect/spacevine_controller/ex_act() //only killing all vines will end this suffering
	return

/obj/effect/spacevine_controller/singularity_act()
	return

/obj/effect/spacevine_controller/singularity_pull()
	return

/obj/effect/spacevine_controller/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/effect/spacevine_controller/proc/spawn_spacevine_piece(turf/location, obj/effect/spacevine/parent, list/muts)
	var/obj/effect/spacevine/SV = new(location)
	growth_queue += SV
	vines += SV
	SV.master = src
	if(muts && muts.len)
		for(var/datum/spacevine_mutation/M in muts)
			M.add_mutation_to_vinepiece(SV)
		return
	if(parent)
		SV.mutations |= parent.mutations
		SV.color = parent.color
		if(prob(mutativeness))
			var/list/random_mutations_picked = mutations_list - SV.mutations
			if(random_mutations_picked.len)
				var/datum/spacevine_mutation/randmut = pick(random_mutations_picked)
				randmut.add_mutation_to_vinepiece(SV)

	for(var/datum/spacevine_mutation/SM in SV.mutations)
		SM.on_birth(SV)

/obj/effect/spacevine_controller/process()
	if(!vines)
		qdel(src) //space vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return

	var/length = 0

	length = min( spread_cap , max( 1 , vines.len / spread_multiplier ) )
	var/i = 0
	var/list/obj/effect/spacevine/queue_end = list()

	for(var/obj/effect/spacevine/SV in growth_queue)
		if(qdeleted(SV))
			continue
		i++
		queue_end += SV
		growth_queue -= SV
		for(var/datum/spacevine_mutation/SM in SV.mutations)
			SM.process_mutation(SV)
		if(SV.energy < 2) //If tile isn't fully grown
			if(prob(20))
				SV.grow()
		else //If tile is fully grown
			SV.entangle_mob()

		//if(prob(25))
		SV.spread()
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end

/obj/effect/spacevine/proc/grow()
	if(!energy)
		icon_state = pick("Med1", "Med2", "Med3")
		energy = 1
		set_opacity(1)
	else
		icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		energy = 2

	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_grow(src)

/obj/effect/spacevine/proc/entangle_mob()
	if(!buckled_mob && prob(25))
		for(var/mob/living/V in loc)
			entangle(V)
			if(has_buckled_mobs())
				break //only capture one mob at a time


/obj/effect/spacevine/proc/entangle(mob/living/V)
	if(!V || isvineimmune(V))
		return
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_buckle(src, V)
	if((V.stat != DEAD) && (V.buckled != src)) //not dead or captured
		to_chat(V, "<span class='danger'>The vines [pick("wind", "tangle", "tighten")] around you!</span>")
		buckle_mob(V, 1)

/obj/effect/spacevine/proc/spread()
	var/direction = pick(cardinal)
	var/turf/stepturf = get_step(src,direction)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_spread(src, stepturf)
		stepturf = get_step(src,direction) //in case turf changes, to make sure no runtimes happen
	if(!locate(/obj/effect/spacevine, stepturf))
		if(stepturf.Enter(src))
			if(master)
				master.spawn_spacevine_piece(stepturf, src)

/obj/effect/spacevine/ex_act(severity)
	var/i
	for(var/datum/spacevine_mutation/SM in mutations)
		i += SM.on_explosion(severity, src)
	if(!i && prob(100/severity))
		qdel(src)

/obj/effect/spacevine/temperature_expose(null, temp, volume)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.process_temperature(src, temp, volume)
	if(!override)
		qdel(src)

/obj/effect/spacevine/CanPass(atom/movable/mover, turf/target, height=0)
	if(isvineimmune(mover))
		. = TRUE
	else
		. = ..()

/proc/isvineimmune(atom/A)
	. = FALSE
	if(isliving(A))
		var/mob/living/M = A
		if(("vines" in M.faction) || ("plants" in M.faction))
			. = TRUE