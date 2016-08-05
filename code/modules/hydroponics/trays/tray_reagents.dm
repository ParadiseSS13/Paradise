
//Process reagents being put into the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents()

	if(!reagents) return

	if(reagents.total_volume <= 0)
		return

	for(var/datum/reagent/R in reagents.reagent_list)

		var/reagent_total = reagents.get_reagent_amount(R.id)

		//These are here because they have checks that would clutter up the switch statement cases, and thus get handled after the switch(readability)
		var/water_value = 0
		var/health_value = 0
		var/production_stat_value = 0
		var/potency_stat_value = 0


		switch(R.id)
		/* EXAMPLE:
		*
		*	if("example")
		*		//Nutrients
		*		nutrilevel += reagent_total * <nutrient value>
		*
		*		//Water
		*		water_value = <water value>
		*
		*		//Toxins
		*		toxins += reagent_total * <toxin value>
		*
		*		//Weeds and Pests
		*		weedlevel += reagent_total * <weed value>
		*		pestlevel += reagent_total * <pest value>
		*
		*		//Mutagens
		*		handle_mutagens(reagent_total, <min_value>, <step_value>)
		*
		*		//Modifiers
		*		yield_mod += reagent_total * <yield_mod value>
		*		mutation_mod += reagent_total * <mutation_mod vlaue>
		*
		*		//Health
		*		health_value = <health value>
		*
		*		//Production Stat
		*		production_stat_value = <production stat value>
		*
		*		//Potency Stat
		*		potency_stat_value = <potency stat value>
		*
		*/

			if("adminordrazine")
				nutrilevel += reagent_total * 1
				water_value = 1
				weedlevel += reagent_total * -5
				pestlevel += reagent_total * -5
				yield_mod += reagent_total * 1
				mutation_mod += reagent_total * 1
				health_value = 1
			if("ammonia")
				nutrilevel += reagent_total * 1
				health_value = 0.5
			if("atrazine")
				toxins += reagent_total * 3
				weedlevel += reagent_total * -8
				mutation_mod += reagent_total * 0.2
				health_value = -2
			if("beer")
				nutrilevel += reagent_total * 0.25
				water_value = 0.7
				health_value = -0.05
			if("charcoal")
				toxins += reagent_total * -2
			if("chlorine")
				water_value = -0.5
				toxins += reagent_total * 1.5
				weedlevel += reagent_total * -3
				health_value = -1
			if("cryoxadone")
				toxins += reagent_total * -3
				if(seed && !dead)
					health += reagent_total * 3
			if("diethylamine")
				nutrilevel += reagent_total * 2
				pestlevel += reagent_total * -2
				health_value = 1
			if("eznutrient")
				nutrilevel += reagent_total * 1
			if("facid")
				toxins += reagent_total * 3
				weedlevel += reagent_total * -4
				health_value = -2
			if("fishwater")
				nutrilevel += reagent_total * 0.75
				water_value = 1
			if("fluorine")
				water_value = -0.5
				toxins = reagent_total * 2.5
				weedlevel += reagent_total * -4
				health_value = -2
			if("holywater")
				water_value = 1
				health_value = 0.1
			if("left4zed")
				nutrilevel += reagent_total * 1
				mutation_mod += reagent_total * 0.2
			if("milk")
				nutrilevel += reagent_total * 0.1
				water_value = 0.9
			if("mutagen")
				handle_mutagens(reagent_total, 1, 5)
			if("nutriment")
				nutrilevel += reagent_total * 1
				yield_mod += reagent_total * 0.15
				health_value = 0.25
			if("phosphorus")
				nutrilevel += reagent_total * 0.1
				water_value = -0.5
				weedlevel += reagent_total * -2
				health_value = -0.75
			if("plantmatter")
				nutrilevel += reagent_total * 1.25
				yield_mod += reagent_total * 0.15
				health_value = 0.25
			if("protein")
				nutrilevel += reagent_total * 1.75
				yield_mod += reagent_total * 0.15
				health_value = 0.25
			if("radium")
				toxins += reagent_total * 2
				handle_mutagens(reagent_total, 10, 10)
				mutation_mod += reagent_total * 0.2
				health_value = -1.5
			if("robustharvest")
				nutrilevel += reagent_total * 1
				yield_mod += reagent_total * 0.2
			if("sacid")
				toxins += reagent_total * 1.5
				weedlevel += reagent_total * -2
				health_value = -1
			if("saltpetre")
				health_value = 0.25
				production_stat_value = -0.02
				potency_stat_value = 0.01
			if("sodawater")
				nutrilevel += reagent_total * 0.1
				water_value = 1
				health_value = 0.1
			if("sugar")
				nutrilevel += reagent_total * 0.1
				weedlevel += reagent_total * 2
				pestlevel += reagent_total * 2
			if("toxin")
				toxins += reagent_total * 2
			if("water")
				water_value = 1

		//END SWITCH

		//Handle water changes
		if(water_value)
			var/water_change = 0
			water_change = reagent_total * water_value
			waterlevel += water_change
			if(water_value > 0)		//adding water dilutes toxins
				toxins -= round(water_change/4)

		//Handle health and stat changes (these require a non-dead seed to be present)
		if(seed && !dead)
			//Health
			if(health_value)
				health += reagent_total * health_value
			//Stats
			if(seed.get_trait(TRAIT_IMMUTABLE) <= 0)
				//Production
				if(production_stat_value && seed.get_trait(TRAIT_PRODUCTION) > 2)
					if(!isnull(plant_controller.seeds[seed.name]))	//This is so we don't affect plants in other trays unintentionally
						seed = seed.diverge(2)						//ENHANCE!
					else
						seed.update_name_prefixes(2)
					var/new_production = seed.get_trait(TRAIT_PRODUCTION) + (reagent_total * production_stat_value)
					seed.set_trait(TRAIT_PRODUCTION, max(2, new_production))		//can't drop below 2 with this method
				//Potency
				if(potency_stat_value)
					if(!isnull(plant_controller.seeds[seed.name]))	//This is so we don't affect plants in other trays unintentionally
						seed = seed.diverge(2)						//ENHANCE!
					else
						seed.update_name_prefixes(2)
					var/new_potency = seed.get_trait(TRAIT_POTENCY) + (reagent_total * potency_stat_value)
					seed.set_trait(TRAIT_POTENCY, max(0, min(100, new_potency)))		//can't go above 100 or below 0 with this method

	//END FOR LOOP

	reagents.clear_reagents()
	check_health()		//This calls check_level_sanity, which is why it's not called from here directly

/obj/machinery/portable_atmospherics/hydroponics/proc/handle_mutagens(var/amount, var/min_amount, var/step_amount)
	//shouldn't be getting called without having reagent values supplied
	if(!amount || !step_amount || !step_amount)
		return
	//shouldn't be getting called with negative values
	if(amount < 0 || min_amount < 0 || step_amount < 0)
		return

	if(amount > min_amount)
		if(amount >= min_amount + (3 * step_amount))
			mutate(4)
		else if(amount >= min_amount + (2 * step_amount))
			mutate(3)
		else if(amount >= min_amount + step_amount)
			mutate(2)
		else if(amount >= min_amount)
			mutate(1)
