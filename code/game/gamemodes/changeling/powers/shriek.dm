/datum/action/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal cords shift, allowing us to briefly emit a noise that deafens and confuses the weak minded. Costs 30 chemicals."
	helptext = "Emits a high frequency sound that confuses and deafens humans, blows out nearby lights and overloads cyborg sensors."
	button_icon_state = "resonant_shriek"
	chemical_cost = 30
	dna_cost = 1
	req_human = 1

//A flashy ability, good for crowd control and sowing chaos.
/datum/action/changeling/resonant_shriek/sting_action(var/mob/user)
	for(var/mob/living/M in get_mobs_in_view(4, user))
		if(iscarbon(M))
			if(!M.mind || !M.mind.changeling)
				M.MinimumDeafTicks(30)
				M.AdjustConfused(20)
				M.Jitter(50)
			else
				M << sound('sound/effects/screech.ogg')

		if(issilicon(M))
			M << sound('sound/weapons/flash.ogg')
			M.Weaken(rand(5,10))

	for(var/obj/machinery/light/L in range(4, user))
		L.on = 1
		L.break_light_tube()

	feedback_add_details("changeling_powers","RS")
	return 1

/datum/action/changeling/dissonant_shriek
	name = "Dissonant Shriek"
	desc = "We shift our vocal cords to release a high frequency sound that overloads nearby electronics. Costs 30 chemicals."
	button_icon_state = "dissonant_shriek"
	chemical_cost = 30
	dna_cost = 1

//A flashy ability, good for crowd control and sewing chaos.
/datum/action/changeling/dissonant_shriek/sting_action(var/mob/user)
	for(var/obj/machinery/light/L in range(5, usr))
		L.on = 1
		L.break_light_tube()
	empulse(get_turf(user), 2, 4, 1)
	return 1
