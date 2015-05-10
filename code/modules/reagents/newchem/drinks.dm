datum/reagent/ginsonic
	name = "Gin and sonic"
	id = "ginsonic"
	description = "GOTTA GET CRUNK FAST BUT LIQUOR TOO SLOW"
	reagent_state = LIQUID
	color = "#1111CF"

/datum/chemical_reaction/ginsonic
	name = "ginsonic"
	id = "ginsonic"
	result = "ginsonic"
	required_reagents = list("gintonic" = 1, "methamphetamine" = 1)
	result_amount = 2
	mix_message = "The drink turns electric blue and starts quivering violently."

datum/reagent/ginsonic/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(10))
		M.reagents.add_reagent("methamphetamine",1.2)
	M.reagents.add_reagent("ethanol",1.4)
	if(prob(8))
		M.say(pick("Gotta go fast!", "Let's juice.", "I feel a need for speed!", "Way Past Cool!"))
	if(prob(8))
		switch(pick(1, 2, 3))
			if(1)
				M << "<span class='notice'>Time to speed, keed!</span>"
			if(2)
				M << "<span class='notice'>Let's juice.</span>"
			if(3)
				M << "<span class='notice'>Way Past Cool!</span>"
	..()
	return
