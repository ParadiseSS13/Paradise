/datum/reagent/drink/orangejuice
	name = "Orange juice"
	id = "orangejuice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#E78108" // rgb: 231, 129, 8

/datum/reagent/drink/orangejuicde/on_mob_life(mob/living/M)
	if(M.getOxyLoss() && prob(30))
		M.adjustOxyLoss(-1*REM)
	..()

/datum/reagent/drink/tomatojuice
	name = "Tomato Juice"
	id = "tomatojuice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#731008" // rgb: 115, 16, 8

/datum/reagent/drink/tomatojuice/on_mob_life(mob/living/M)
	if(M.getFireLoss() && prob(20))
		M.adjustFireLoss(-1)
	..()

/datum/reagent/drink/limejuice
	name = "Lime Juice"
	id = "limejuice"
	description = "The sweet-sour juice of limes."
	color = "#365E30" // rgb: 54, 94, 48

/datum/reagent/drink/limejuice/on_mob_life(mob/living/M)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)
	..()

/datum/reagent/drink/carrotjuice
	name = "Carrot juice"
	id = "carrotjuice"
	description = "It is just like a carrot but without crunching."
	color = "#973800" // rgb: 151, 56, 0

/datum/reagent/drink/carrotjuicde/on_mob_life(mob/living/M)
	M.eye_blurry = max(M.eye_blurry-1 , 0)
	M.eye_blind = max(M.eye_blind-1 , 0)
	switch(current_cycle)
		if(1 to 20)
			//nothing
		if(21 to INFINITY)
			if(prob(current_cycle-10))
				M.disabilities &= ~NEARSIGHTED
	..()

/datum/reagent/drink/doctor_delight
	name = "The Doctor's Delight"
	id = "doctorsdelight"
	description = "A gulp a day keeps the MediBot away. That's probably for the best."
	reagent_state = LIQUID
	color = "#FF8CFF" // rgb: 255, 140, 255

/datum/reagent/drink/doctors_delight/on_mob_life(mob/living/M)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)
	..()

/datum/reagent/drink/berryjuice
	name = "Berry Juice"
	id = "berryjuice"
	description = "A delicious blend of several different kinds of berries."
	color = "#863333" // rgb: 134, 51, 51

/datum/reagent/drink/poisonberryjuice
	name = "Poison Berry Juice"
	id = "poisonberryjuice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353" // rgb: 134, 51, 83

/datum/reagent/drink/poisonberryjuice/on_mob_life(mob/living/M)
	M.adjustToxLoss(1)
	..()

/datum/reagent/drink/watermelonjuice
	name = "Watermelon Juice"
	id = "watermelonjuice"
	description = "Delicious juice made from watermelon."
	color = "#863333" // rgb: 134, 51, 51

/datum/reagent/drink/lemonjuice
	name = "Lemon Juice"
	id = "lemonjuice"
	description = "This juice is VERY sour."
	color = "#863333" // rgb: 175, 175, 0

/datum/reagent/drink/grapejuice
	name = "Grape Juice"
	id = "grapejuice"
	description = "This juice is known to stain shirts."
	color = "#993399" // rgb: 153, 51, 153

/datum/reagent/drink/banana
	name = "Banana Juice"
	id = "banana"
	description = "The raw essence of a banana."
	color = "#863333" // rgb: 175, 175, 0

/datum/reagent/drink/banana/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	if((ishuman(M) && M.job in list("Clown") ) || issmall(M))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	..()

/datum/reagent/drink/nothing
	name = "Nothing"
	id = "nothing"
	description = "Absolutely nothing."

/datum/reagent/drink/nothing/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	if(ishuman(M) && M.job in list("Mime"))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	..()

/datum/reagent/drink/potato_juice
	name = "Potato Juice"
	id = "potato"
	description = "Juice of the potato. Bleh."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/drink/milk
	name = "Milk"
	id = "milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" // rgb: 223, 223, 223

/datum/reagent/drink/milk/on_mob_life(mob/living/M)
	if(M.getBruteLoss() && prob(20))
		M.adjustBruteLoss(-1)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 2)
	..()

/datum/reagent/drink/milk/soymilk
	name = "Soy Milk"
	id = "soymilk"
	description = "An opaque white liquid made from soybeans."
	color = "#DFDFC7" // rgb: 223, 223, 199

/datum/reagent/drink/milk/cream
	name = "Cream"
	id = "cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" // rgb: 223, 215, 175

/datum/reagent/drink/milk/chocolate_milk
	name = "Chocolate milk"
	id ="chocolate_milk"
	description = "Chocolate-flavored milk, tastes like being a kid again."
	color = "#85432C"

/datum/reagent/drink/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And coco beans."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#403010" // rgb: 64, 48, 16
	adj_temp_hot = 5

/datum/reagent/drink/coffee
	name = "Coffee"
	id = "coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" // rgb: 72, 32, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	adj_temp_hot = 25
	overdose_threshold = 45
	addiction_chance = 1 // It's true.
	heart_rate_increase = 1

/datum/reagent/drink/coffee/on_mob_life(mob/living/M)
	if(holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 5)
	if(prob(50))
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
	..()

/datum/reagent/drink/coffee/overdose_process(mob/living/M, severity)
	if(volume > 45)
		M.Jitter(5)

/datum/reagent/drink/coffee/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#102838" // rgb: 16, 40, 56
	adj_temp_hot = 0
	adj_temp_cool = 5

/datum/reagent/drink/coffee/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp_hot = 5

/datum/reagent/drink/coffee/soy_latte/on_mob_life(mob/living/M)
	..()
	M.SetSleeping(0)
	if(M.getBruteLoss() && prob(20))
		M.adjustBruteLoss(-1)

/datum/reagent/drink/coffee/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	description = "A nice, strong and tasty beverage while you are reading."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp_hot = 5

/datum/reagent/drink/coffee/cafe_latte/on_mob_life(mob/living/M)
	..()
	M.SetSleeping(0)
	if(M.getBruteLoss() && prob(20))
		M.adjustBruteLoss(-1)

/datum/reagent/drink/coffee/cafe_latte/cafe_mocha
	name = "Cafe Mocha"
	id = "cafe_mocha"
	description = "The perfect blend of coffe, milk, and chocolate."
	color = "#673629"

/datum/reagent/drink/tea
	name = "Tea"
	id = "tea"
	description = "Tasty black tea: It has antioxidants. It's good for you!"
	color = "#101000" // rgb: 16, 16, 0
	adj_dizzy = -2
	adj_drowsy = -1
	adj_sleepy = -3
	adj_temp_hot = 20

/datum/reagent/drink/tea/on_mob_life(mob/living/M)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)
	..()

/datum/reagent/drink/tea/icetea
	name = "Iced Tea"
	id = "icetea"
	description = "No relation to a certain rap artist/ actor."
	color = "#104038" // rgb: 16, 64, 56
	adj_temp_hot = 0
	adj_temp_cool = 5

/datum/reagent/drink/bananahonk
	name = "Banana Mama"
	id = "bananahonk"
	description = "A drink from Clown Heaven."
	nutriment_factor = 1 * FOOD_METABOLISM
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/drink/bananahonk/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	if((ishuman(M) && M.job in list("Clown") ) || issmall(M))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	..()

/datum/reagent/drink/silencer
	name = "Silencer"
	id = "silencer"
	description = "A drink from Mime Heaven."
	nutriment_factor = 1 * FOOD_METABOLISM
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/drink/silencer/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	if(ishuman(M) && M.job in list("Mime"))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	..()