// Foam
// Similar to smoke, but spreads out more
// metal foams leave behind a foamed metal wall

/obj/effect/particle_effect/foam
	name = "foam"
	icon_state = "foam"
	opacity = 0
	anchored = 1
	density = 0
	layer = OBJ_LAYER + 0.9
	animate_movement = 0
	var/amount = 3
	var/expand = 1
	var/metal = 0

/obj/effect/particle_effect/foam/New(loc, ismetal=0)
	..(loc)
	icon_state = "[ismetal ? "m":""]foam"
	if(!ismetal && reagents)
		color = mix_color_from_reagents(reagents.reagent_list)
	metal = ismetal
	playsound(src, 'sound/effects/bubbles2.ogg', 80, 1, -3)
	spawn(3 + metal*3)
		process()
	spawn(120)
		processing_objects.Remove(src)
		sleep(30)

		if(metal)
			var/turf/T = get_turf(src)
			if(istype(T, /turf/space))
				T.ChangeTurf(/turf/simulated/floor/plating/metalfoam)
				var/turf/simulated/floor/plating/metalfoam/MF = get_turf(src)
				MF.metal = metal
				MF.update_icon()

			var/obj/structure/foamedmetal/M = new(src.loc)
			M.metal = metal
			M.updateicon()

		flick("[icon_state]-disolve", src)
		sleep(5)
		qdel(src)
	return

// on delete, transfer any reagents to the floor
/obj/effect/particle_effect/foam/Destroy()
	if(!metal && reagents)
		reagents.handle_reactions()
		for(var/atom/A in oview(1, src))
			if(A == src)
				continue
			if(reagents.total_volume)
				var/fraction = 5 / reagents.total_volume
				reagents.reaction(A, TOUCH, fraction)
	return ..()

/obj/effect/particle_effect/foam/process()
	if(--amount < 0)
		return

	for(var/direction in cardinal)

		var/turf/T = get_step(src,direction)
		if(!T)
			continue

		if(!T.Enter(src))
			continue

		var/obj/effect/particle_effect/foam/F = locate() in T
		if(F)
			continue

		F = new /obj/effect/particle_effect/foam(T, metal)
		F.amount = amount
		if(!metal)
			F.create_reagents(15)
			if(reagents)
				for(var/datum/reagent/R in reagents.reagent_list)
					F.reagents.add_reagent(R.id, min(R.volume, 3), R.data, reagents.chem_temp)
				F.color = mix_color_from_reagents(reagents.reagent_list)

// foam disolves when heated
// except metal foams
/obj/effect/particle_effect/foam/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!metal && prob(max(0, exposed_temperature - 475)))
		flick("[icon_state]-disolve", src)

		spawn(5)
			qdel(src)

/obj/effect/particle_effect/foam/Crossed(atom/movable/AM)
	if(metal)
		return

	if(iscarbon(AM))
		var/mob/living/carbon/M =	AM
		if(M.slip("foam", 5, 2))
			if(reagents)
				for(var/reagent_id in reagents.reagent_list)
					var/amount = M.reagents.get_reagent_amount(reagent_id)
					if(amount < 25)
						M.reagents.add_reagent(reagent_id, min(round(amount / 2), 15))
				if(reagents.total_volume)
					var/fraction = 5 / reagents.total_volume
					reagents.reaction(M, TOUCH, fraction)

/datum/effect_system/foam_spread
	effect_type = /obj/effect/particle_effect/foam
	var/amount = 5				// the size of the foam spread.
	var/list/carried_reagents	// the IDs of reagents present when the foam was mixed
	var/metal = 0				// 0=foam, 1=metalfoam, 2=ironfoam
	var/temperature = T0C
	var/list/banned_reagents = list("smoke_powder", "fluorosurfactant", "stimulants")

/datum/effect_system/foam_spread/set_up(amt=5, loca, datum/reagents/carry = null, metalfoam = 0)
	amount = min(round(amt/5, 1), 7)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

	carried_reagents = list()
	metal = metalfoam
	temperature = carry.chem_temp

	// bit of a hack here. Foam carries along any reagent also present in the glass it is mixed
	// with (defaults to water if none is present). Rather than actually transfer the reagents,
	// this makes a list of the reagent ids and spawns 1 unit of that reagent when the foam disolves.

	if(carry && !metal)
		for(var/datum/reagent/R in carry.reagent_list)
			carried_reagents[R.id] = R.volume

/datum/effect_system/foam_spread/start()
	spawn(0)
		var/obj/effect/particle_effect/foam/F = locate() in location
		if(F)
			F.amount += amount
			F.amount = min(F.amount, 27)
			return

		F = new /obj/effect/particle_effect/foam(location, metal)
		F.amount = amount

		if(!metal)			// don't carry other chemicals if a metal foam
			F.create_reagents(15)

			if(carried_reagents)
				for(var/id in carried_reagents)
					if(banned_reagents.Find("[id]"))
						continue
					var/datum/reagent/reagent_volume = carried_reagents[id]
					F.reagents.add_reagent(id, min(reagent_volume, 3), null, temperature)
				F.color = mix_color_from_reagents(F.reagents.reagent_list)
			else
				F.reagents.add_reagent("cleaner", 1)
				F.color = mix_color_from_reagents(F.reagents.reagent_list)

// wall formed by metal foams
// dense and opaque, but easy to break

/obj/structure/foamedmetal
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	density = 1
	opacity = 1 	// changed in New()
	anchored = 1
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	var/metal = MFOAM_ALUMINUM

/obj/structure/foamedmetal/initialize()
	..()
	air_update_turf(1)

/obj/structure/foamedmetal/Destroy()
	density = 0
	air_update_turf(1)
	return ..()

/obj/structure/foamedmetal/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/foamedmetal/proc/updateicon()
	if(metal == MFOAM_ALUMINUM)
		icon_state = "metalfoam"
	else
		icon_state = "ironfoam"

/obj/structure/foamedmetal/ex_act(severity)
	qdel(src)

/obj/structure/foamedmetal/blob_act()
	qdel(src)

/obj/structure/foamedmetal/bullet_act()
	if(metal==MFOAM_ALUMINUM || prob(50))
		qdel(src)

/obj/structure/foamedmetal/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if((HULK in user.mutations) || (prob(75 - metal*25)))
		user.visible_message("<span class='warning'>[user] smashes through \the [src].</span>", "<span class='notice'>You smash through \the [src].</span>")
		qdel(src)
	else
		to_chat(user, "<span class='notice'>You hit the metal foam but bounce off it.</span>")

/obj/structure/foamedmetal/attackby(obj/item/I, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		G.affecting.loc = src.loc
		user.visible_message("<span class='warning'>[G.assailant] smashes [G.affecting] through the foamed metal wall.</span>")
		qdel(I)
		qdel(src)
		return

	if(prob(I.force*20 - metal*25))
		user.visible_message("<span class='warning'>[user] smashes through the foamed metal with \the [I].</span>", "<span class='notice'>You smash through the foamed metal with \the [I].</span>")
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You hit the metal foam to no effect.</span>")

/obj/structure/foamedmetal/attack_animal(mob/living/simple_animal/M)
	M.do_attack_animation(src)
	if(M.melee_damage_upper == 0)
		M.visible_message("<span class='notice'>[M] nudges \the [src].</span>")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		M.visible_message("<span class='danger'>\The [M] [M.attacktext] [src]!</span>")
		qdel(src)

/obj/structure/foamedmetal/attack_alien(mob/living/carbon/alien/humanoid/M)
	M.visible_message("<span class='danger'>[M] tears apart \the [src]!</span>");
	qdel(src)

/obj/structure/foamedmetal/CanPass(atom/movable/mover, turf/target, height=1.5)
	return !density

/obj/structure/foamedmetal/CanAtmosPass()
	return !density
