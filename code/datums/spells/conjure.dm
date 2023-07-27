/obj/effect/proc_holder/spell/aoe/conjure
	desc = "This spell conjures objs of the specified types in range."
	/// Determines what exactly will be summoned. Should be text, like list("/mob/simple_animal/bot/ed209").
	var/list/summon_type = list()
	/// 0=permanent, any other time in deciseconds.
	var/summon_lifespan = 0
	/// Amount of objects summoned.
	var/summon_amt = 1
	/// If set to `TRUE`, adds dense tiles to possible spawn places.
	var/summon_ignore_density = FALSE
	/// If set to `TRUE`, each new object is summoned on a new spawn point.
	var/summon_ignore_prev_spawn_points = 0

	/// Vars of the summoned objects will be replaced with those where they meet. Should have format of list("emagged" = 1,"name" = "Wizard's Justicebot"), for example.
	var/list/newVars = list()
	/// Go Go Gadget Inheritance
	var/delay = 1

	var/cast_sound = 'sound/items/welder.ogg'


/obj/effect/proc_holder/spell/aoe/conjure/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/conjure/cast(list/targets,mob/living/user = usr)
	var/list/what_conjure_summoned = list()
	playsound(get_turf(user), cast_sound, 50,1)
	for(var/turf/T in targets)
		if(T.density && !summon_ignore_density)
			targets -= T
	playsound(get_turf(src), cast_sound, 50, 1)

	if(do_after(user, delay, target = user))
		for(var/i=0,i<summon_amt,i++)
			if(!targets.len)
				break
			var/summoned_object_type = pick(summon_type)
			var/spawn_place = pick(targets)
			if(summon_ignore_prev_spawn_points)
				targets -= spawn_place
			if(ispath(summoned_object_type,/turf))
				if(istype(get_turf(user), /turf/simulated/floor/shuttle) || istype(get_turf(user), /turf/simulated/wall/shuttle))
					to_chat(user, "<span class='warning'>You can't build things on shuttles!</span>")
					break
				var/turf/O = spawn_place
				var/N = summoned_object_type
				O.ChangeTurf(N)
			else
				var/atom/summoned_object = new summoned_object_type(spawn_place)
				what_conjure_summoned += summoned_object

				for(var/varName in newVars)
					if(varName in summoned_object.vars)
						summoned_object.vars[varName] = newVars[varName]
				summoned_object.admin_spawned = TRUE

				if(summon_lifespan)
					QDEL_IN(summoned_object, summon_lifespan)
	else
		cooldown_handler.start_recharge(0.5 SECONDS)


	return what_conjure_summoned


/obj/effect/proc_holder/spell/aoe/conjure/summonEdSwarm //test purposes
	name = "Dispense Wizard Justice"
	desc = "This spell dispenses wizard justice."
	summon_type = list(/mob/living/simple_animal/bot/ed209)
	summon_amt = 10
	newVars = list("emagged" = 1,"name" = "Wizard's Justicebot")
	aoe_range = 3

