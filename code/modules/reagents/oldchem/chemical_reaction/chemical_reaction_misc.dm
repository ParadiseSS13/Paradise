/datum/chemical_reaction/
// foam and foam precursor

	surfactant
		name = "Foam surfactant"
		id = "foam surfactant"
		result = "fluorosurfactant"
		required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)
		result_amount = 5
		mix_message = "A head of foam results from the mixture's constant fizzing."


	foam
		name = "Foam"
		id = "foam"
		result = null
		required_reagents = list("fluorosurfactant" = 1, "water" = 1)
		result_amount = 2

		on_reaction(var/datum/reagents/holder, var/created_volume)


			var/location = get_turf(holder.my_atom)
			for(var/mob/M in viewers(5, location))
				M << "\red The solution violently bubbles!"

			location = get_turf(holder.my_atom)

			for(var/mob/M in viewers(5, location))
				M << "\red The solution spews out foam!"

			//world << "Holder volume is [holder.total_volume]"
			//for(var/datum/reagent/R in holder.reagent_list)
			//	world << "[R.name] = [R.volume]"

			var/datum/effect/effect/system/foam_spread/s = new()
			s.set_up(created_volume, location, holder, 0)
			s.start()
			holder.clear_reagents()
			return

	metalfoam
		name = "Metal Foam"
		id = "metalfoam"
		result = null
		required_reagents = list("aluminum" = 3, "fluorosurfactant" = 1, "sacid" = 1)
		result_amount = 5

		on_reaction(var/datum/reagents/holder, var/created_volume)


			var/location = get_turf(holder.my_atom)

			for(var/mob/M in viewers(5, location))
				M << "\red The solution spews out a metalic foam!"

			var/datum/effect/effect/system/foam_spread/s = new()
			s.set_up(created_volume, location, holder, 1)
			s.start()
			return

	ironfoam
		name = "Iron Foam"
		id = "ironlfoam"
		result = null
		required_reagents = list("iron" = 3, "fluorosurfactant" = 1, "sacid" = 1)
		result_amount = 5

		on_reaction(var/datum/reagents/holder, var/created_volume)


			var/location = get_turf(holder.my_atom)

			for(var/mob/M in viewers(5, location))
				M << "\red The solution spews out a metalic foam!"

			var/datum/effect/effect/system/foam_spread/s = new()
			s.set_up(created_volume, location, holder, 2)
			s.start()
			return

	// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
	ammonia
		name = "Ammonia"
		id = "ammonia"
		result = "ammonia"
		required_reagents = list("hydrogen" = 3, "nitrogen" = 1)
		result_amount = 3
		mix_message = "The mixture bubbles, emitting an acrid reek."

	diethylamine
		name = "Diethylamine"
		id = "diethylamine"
		result = "diethylamine"
		required_reagents = list ("ammonia" = 1, "ethanol" = 1)
		result_amount = 2
		min_temp = 374
		mix_message = "A horrible smell pours forth from the mixture."

	space_cleaner
		name = "Space cleaner"
		id = "cleaner"
		result = "cleaner"
		required_reagents = list("ammonia" = 1, "water" = 1, "ethanol" = 1)
		result_amount = 3
		mix_message = "Ick, this stuff really stinks. Sure does make the container sparkle though!"

	sulfuric_acid
		name = "Sulfuric Acid"
		id = "sacid"
		result = "sacid"
		required_reagents = list("sulfur" = 1, "oxygen" = 1, "hydrogen" = 1)
		result_amount = 2
		mix_message = "The mixture gives off a sharp acidic tang."

///////Changeling Blood Test/////////////
/*
	changeling_test
		name = "Changeling blood test"
		id = "changelingblood"
		result = "blood"
		required_reagents = list("blood" = 5)
		required_catalysts = list("fuel")
		result_amount = 1 //Needs this in order to check the donor, as the data var in the reacted blood gets transferred.
		on_reaction(var/datum/reagents/holder, var/created_volume)
			if(!holder.reagent_list) //reagent_list is not null
				return
			var/datum/reagent/blood/B = locate() in holder.reagent_list
			if(!B) //B is not null
				return
			var/mob/living/carbon/human/H = B.data["donor"]
			if(!H) //H is not null.
				return
			if(H.mind && H.mind.changeling) //Checks if H, the blood donor is a ling.
				for(var/mob/M in viewers(get_turf(holder.my_atom), null))
					M.show_message( "<span class='danger'>The blood writhes and wriggles and sizzles away from the container!</span>", 1, "<span class='warning'>You hear bubbling and sizzling.</span>", 2)
			else
				for(var/mob/M in viewers(get_turf(holder.my_atom), null))
					M.show_message( "<span class ='notice'>The blood seems to break apart in the fuel.</span>", 1)
			holder.del_reagent("blood")
			return
*/

	plastication
		name = "Plastic"
		id = "solidplastic"
		result = null
		required_reagents = list("facid" = 10, "plasticide" = 20)
		result_amount = 1
		on_reaction(var/datum/reagents/holder)
			var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/mineral/plastic
			M.amount = 10
			M.loc = get_turf(holder.my_atom)
			return



//Not really misc chems, but not enough to deserve their own file
/*
	silicate
		name = "Silicate"
		id = "silicate"
		result = "silicate"
		required_reagents = list("aluminum" = 1, "silicon" = 1, "oxygen" = 1)
		result_amount = 3
*/

	space_drugs
		name = "Space Drugs"
		id = "space_drugs"
		result = "space_drugs"
		required_reagents = list("mercury" = 1, "sugar" = 1, "lithium" = 1)
		result_amount = 3
		mix_message = "Slightly dizzying fumes drift from the solution."

	lube
		name = "Space Lube"
		id = "lube"
		result = "lube"
		required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)
		result_amount = 3
		mix_message = "The substance turns a striking cyan and becomes oily."

	holy_water
		name = "Holy Water"
		id = "holywater"
		result = "holywater"
		required_reagents = list("water" = 1, "mercury" = 1, "wine" = 1)
		result_amount = 3
		mix_message = "The water somehow seems purified. Or maybe defiled."


	lsd
		name = "Lysergic acid diethylamide"
		id = "lsd"
		result = "lsd"
		required_reagents = list("diethylamine" = 1, "fungus" = 1)
		result_amount = 3
		mix_message = "The mixture turns a rather unassuming color and settles."