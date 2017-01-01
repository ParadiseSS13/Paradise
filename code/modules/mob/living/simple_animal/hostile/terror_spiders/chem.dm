// Terror Spider, Black, Deadly Venom

/datum/reagent/terror_black_toxin
	name = "Black Widow venom"
	id = "terror_black_toxin"
	description = "An incredibly toxic venom injected by the Black Widow spider."
	color = "#CF3600"
	metabolization_rate = 0.1

/datum/reagent/terror_black_toxin/on_mob_life(mob/living/M)
	if(volume < 15)
		// bitten once, die slowly. Easy to survive a single bite - just go to medbay.
		// total damage: 2/tick, human health 150 until crit, = 75 ticks, = 150 seconds = 2.5 minutes to get to medbay.
		M.adjustToxLoss(2) // same damage/tick as tabun cycle 0 to 60
	else if(volume < 30)
		// bitten twice, die more quickly, muscle cramps make movement difficult. Call medics immediately.
		// total damage: 4, human health 150 until crit, = 37.5 ticks, = 75s = 1m15s until death
		M.adjustToxLoss(4)
		M.Confused(3)
		M.EyeBlurry(3)
	else if(volume < 45)
		// bitten thrice, die very quickly, severe muscle cramps make movement very difficult. Even calling for help probably won't save you.
		// total damage: 8, human health 150 until crit, = 18.75 ticks, = 37s until death
		M.adjustToxLoss(8) // a bit worse than coiine
		M.Confused(6)
		M.EyeBlurry(6)
	else
		// bitten 4 or more times, whole body goes into shock/death
		// total damage: 12, human health 150 until crit, = 12.5 ticks, = 25s until death
		M.adjustToxLoss(12)
		M.EyeBlurry(6)
		M.Paralyse(5)
	..()
