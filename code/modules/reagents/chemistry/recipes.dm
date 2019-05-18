///////////////////////////////////////////////////////////////////////////////////
/datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	var/list/required_reagents = list()
	var/list/required_catalysts = list()

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/atom/required_container = null // the container required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/result_amount = 0
	var/list/secondary_results = list()		//additional reagents produced by the reaction
	var/min_temp = 0		//Minimum temperature required for the reaction to occur (heat to/above this). min_temp = 0 means no requirement
	var/max_temp = 9999		//Maximum temperature allowed for the reaction to occur (cool to/below this).
	var/mix_message = "The solution begins to bubble."
	var/mix_sound = 'sound/effects/bubbles.ogg'

/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return

var/list/chemical_mob_spawn_meancritters = list() // list of possible hostile mobs
var/list/chemical_mob_spawn_nicecritters = list() // and possible friendly mobs
/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_faction = "chemicalsummon")
	if(holder && holder.my_atom)
		if(chemical_mob_spawn_meancritters.len <= 0 || chemical_mob_spawn_nicecritters.len <= 0)
			for(var/T in typesof(/mob/living/simple_animal))
				var/mob/living/simple_animal/SA = T
				switch(initial(SA.gold_core_spawnable))
					if(CHEM_MOB_SPAWN_HOSTILE)
						chemical_mob_spawn_meancritters += T
					if(CHEM_MOB_SPAWN_FRIENDLY)
						chemical_mob_spawn_nicecritters += T
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/area/my_area = get_area(T)
		var/message = "A [reaction_name] reaction has occured in [my_area.name]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</A>)"
		message += " ([ADMIN_VV(A,"VV")])"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [key_name_admin(M)]([ADMIN_QUE(M,"?")]) ([ADMIN_FLW(M,"FLW")])"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
			C.flash_eyes()
		for(var/i = 1, i <= amount_to_spawn, i++)
			var/chosen
			if(reaction_name == "Friendly Gold Slime")
				chosen = pick(chemical_mob_spawn_nicecritters)
			else
				chosen = pick(chemical_mob_spawn_meancritters)
			var/mob/living/simple_animal/C = new chosen
			C.faction |= mob_faction
			C.forceMove(get_turf(holder.my_atom))
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(C, pick(NORTH,SOUTH,EAST,WEST))

/proc/goonchem_vortex(turf/T, setting_type, volume)
	if(setting_type)
		new /obj/effect/temp_visual/implosion(T)
		playsound(T, 'sound/effects/whoosh.ogg', 25, 1) //credit to Robinhood76 of Freesound.org for this.
	else
		new /obj/effect/temp_visual/shockwave(T)
		playsound(T, 'sound/effects/bang.ogg', 25, 1)
	for(var/atom/movable/X in view(2 + setting_type  + (volume > 30 ? 1 : 0), T))
		if(istype(X, /obj/effect))
			continue  //stop pulling smoke and hotspots please
		if(X && !X.anchored && X.move_resist <= MOVE_FORCE_DEFAULT)
			if(setting_type)
				X.throw_at(T, 20 + round(volume * 2), 1 + round(volume / 10))
			else
				X.throw_at(get_edge_target_turf(T, get_dir(T, X)), 20 + round(volume * 2), 1 + round(volume / 10))