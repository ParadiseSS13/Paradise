#define SOLID 1
#define LIQUID 2
#define GAS 3
#define FOOD_METABOLISM 0.4
#define REM REAGENTS_EFFECT_MULTIPLIER


// Terror Spider, Black, Deadly Venom

/datum/reagent/terror_black_toxin
	name = "Black Widow venom"
	id = "terror_black_toxin"
	description = "An incredibly toxic venom injected by the Black Widow spider."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.1

/datum/reagent/terror_black_toxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if (volume >= 45)
		// bitten 4 or more times, whole body goes into shock/death
		// total damage: 12, human health 150 until crit, = 12.5 ticks, = 25s until death
		M.adjustToxLoss(12)
		M.eye_blurry = max(M.eye_blurry, 9)
		M.Paralyse(5)
	else if (volume >= 30)
		// bitten thrice, die very quickly, severe muscle cramps make movement very difficult. Even calling for help probably won't save you.
		// total damage: 8, human health 150 until crit, = 18.75 ticks, = 37s until death
		M.adjustToxLoss(8) // a bit worse than coiine
		M.confused = max(M.confused, 6)
		M.eye_blurry = max(M.eye_blurry, 6)
	else if (volume >= 15)
		// bitten twice, die more quickly, muscle cramps make movement difficult. Call medics immediately.
		// total damage: 4, human health 150 until crit, = 37.5 ticks, = 75s = 1m15s until death
		M.adjustToxLoss(4)
		M.confused = max(M.confused, 3)
		M.eye_blurry = max(M.eye_blurry, 3)
	else
		// bitten once, die slowly. Easy to survive a single bite - just go to medbay.
		// total damage: 2/tick, human health 150 until crit, = 75 ticks, = 150 seconds = 2.5 minutes to get to medbay.
		M.adjustToxLoss(2) // same damage/tick as tabun cycle 0 to 60
	..()
	return

// Terror Spider, White, Tranq

/datum/reagent/terror_white_tranq
	name = "White Spider tranquilizer"
	id = "terror_white_tranq"
	description = "A venom that incapacitites those who attack the White Death spider."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.1

/datum/reagent/terror_white_tranq/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	// effects are similar to ketamine, aka the sleepy pen
	if(current_cycle >= 3)
		M.confused = max(M.confused, 5)
	if(current_cycle >= 6)
		M.eye_blurry = max(M.eye_blurry, 5)
	if(current_cycle >= 10)
		M.Paralyse(10)
	..()
	return

// Terror Spider, White, Egg Venom

/datum/reagent/terror_white_toxin
	name = "White Spider venom"
	id = "terror_white_toxin"
	description = "A venom consisting of thousands of tiny spider eggs. When injected under the skin, they feed on living flesh and grow into new spiders."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 1

/datum/reagent/terror_white_toxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(iscarbon(M))
		if(!M.get_int_organ(/obj/item/organ/internal/body_egg))
			new/obj/item/organ/internal/body_egg/terror_eggs(M)
	return

// Terror Spider, Queen Toxin

/datum/reagent/terror_queen_toxin
	name = "Terror Queen venom"
	id = "terror_queen_toxin"
	description = "A royally potent venom."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 2

/datum/reagent/terror_queen_toxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	// make them hallucinate a lot, like a changeling sting
	if (M.hallucination < 400)
		M.hallucination += 50
	return


