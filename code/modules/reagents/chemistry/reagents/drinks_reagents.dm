/datum/reagent/consumable/drink/orangejuice
	name = "Orange juice"
	id = "orangejuice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	drink_icon = "glass_orange"
	drink_name = "Glass of Orange juice"
	drink_desc = "Vitamins! Yay!"
	taste_description = "orange juice"

/datum/reagent/consumable/drink/orangejuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(30))
		update_flags |= M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/tomatojuice
	name = "Tomato Juice"
	id = "tomatojuice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#C00609"
	drink_icon = "glass_red"
	drink_name = "Glass of Tomato juice"
	drink_desc = "Are you sure this is tomato juice?"
	taste_description = "tomato juice"

/datum/reagent/consumable/drink/tomatojuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/pineapplejuice
	name = "Pineapple Juice"
	id = "pineapplejuice"
	description = "Pineapples juiced into a liquid. Sweet and sugary."
	color = "#e5b437"
	drink_icon = "glass_orange"
	drink_name = "Glass of pineapple juice"
	drink_desc = "A bright drink, sweet and sugary."
	taste_description = "pineapple juice"

/datum/reagent/consumable/drink/limejuice
	name = "Lime Juice"
	id = "limejuice"
	description = "The sweet-sour juice of limes."
	color = "#68E735"
	drink_icon = "glass_green"
	drink_name = "Glass of Lime juice"
	drink_desc = "A glass of sweet-sour lime juice."
	taste_description = "lime juice"

/datum/reagent/consumable/drink/limejuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/carrotjuice
	name = "Carrot juice"
	id = "carrotjuice"
	description = "Just like a carrot, but without the crunching."
	color = "#FFA500"
	drink_icon = "carrotjuice"
	drink_name = "Glass of carrot juice"
	drink_desc = "Just like a carrot, but without the crunching."
	taste_description = "carrot juice"

/datum/reagent/consumable/drink/carrotjuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustEyeBlurry(-2 SECONDS)
	M.AdjustEyeBlind(-2 SECONDS)
	if(current_cycle > 20 && prob(current_cycle - 10))
		update_flags |= M.cure_nearsighted(EYE_DAMAGE, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/beetjuice
	name = "Beet juice"
	id = "beetjuice"
	description = "Sweet as a 'sugar beet' would imply."
	color = "#7E0243"
	drink_icon = "glass_magenta"
	drink_name = "Glass of beet juice"
	drink_desc = "Sweet as a 'sugar beet' would imply."
	taste_description = "beet juice"

/datum/reagent/consumable/drink/plumjuice
	name = "Plum juice"
	id = "plumjuice"
	description = "A fan favorite of old people across the galaxy."
	color = "#99305D"
	drink_icon = "glass_magenta"
	drink_name = "Glass of plum juice"
	drink_desc = "A fan favorite of old people across the galaxy."
	taste_description = "prune juice"

/datum/reagent/consumable/drink/lettucejuice
	name = "Lettuce juice"
	id = "lettucejuice"
	description = "They say you should eat your greens, but drinking them is just as good."
	color = "#79B330"
	drink_icon = "glass_green"
	drink_name = "Glass of lettuce juice"
	drink_desc = "They say you should eat your greens, but drinking them is just as good."
	taste_description = "lettuce juice"

/datum/reagent/consumable/drink/doctor_delight
	name = "The Doctor's Delight"
	id = "doctorsdelight"
	description = "A gulp a day keeps the MediBot away. That's probably for the best."
	color = "#754389"
	drink_icon = "doctorsdelightglass"
	drink_name = "Doctor's Delight"
	drink_desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
	taste_description = "healthy dietary choices"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/doctor_delight/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/triple_citrus
	name = "Triple Citrus"
	id = "triple_citrus"
	description = "A refreshing mixed drink of orange, lemon and lime juice."
	color = "#B5FF00"
	drink_icon = "triplecitrus"
	drink_name = "Glass of triple citrus Juice"
	drink_desc = "As colorful and healthy as it is delicious."
	taste_description = "citrus juice"

/datum/reagent/consumable/drink/triple_citrus/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(15))
		update_flags |= M.adjustToxLoss(-rand(1, 2), FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/berryjuice
	name = "Berry Juice"
	id = "berryjuice"
	description = "A delicious blend of several different kinds of berries."
	color = "#B23A4E"
	drink_icon = "berryjuice"
	drink_name = "Glass of berry juice"
	drink_desc = "Berry juice. Or maybe it's jam. Who cares?"
	taste_description = "berry juice"

/datum/reagent/consumable/drink/poisonberryjuice
	name = "Poison Berry Juice"
	id = "poisonberryjuice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#B23A4E"
	drink_icon = "poisonberryjuice"
	drink_name = "Glass of poison berry juice"
	drink_desc = "A glass of deadly juice."
	taste_description = "berry juice"

/datum/reagent/consumable/drink/poisonberryjuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/applejuice
	name = "Apple Juice"
	id = "applejuice"
	description = "The sweet juice of an apple, fit for all ages."
	color = "#FBF969"
	drink_name = "Apple Juice"
	drink_desc = "Apple juice. Maybe it would have been better in a pie..."
	taste_description = "apple juice"

/datum/reagent/consumable/bungojuice
	name = "Bungo Juice"
	id = "bungojuice"
	description = "Exotic! You feel like you are on vacation already."
	color = "#F9E43D"
	drink_name = "Bungo Juice"
	drink_desc = "Exotic! You feel like you are on vacation already."
	taste_description = "succulent bungo with an acidic poisonous tang"

/datum/reagent/consumable/drink/watermelonjuice
	name = "Watermelon Juice"
	id = "watermelonjuice"
	description = "Delicious juice made from watermelon."
	color = "#ae2631"
	drink_name = "Watermelon Juice"
	drink_desc = "Almost water."
	taste_description = "watermelon juice"

/datum/reagent/consumable/drink/lemonjuice
	name = "Lemon Juice"
	id = "lemonjuice"
	description = "This juice is VERY sour."
	color = "#E5F249"
	drink_icon = "lemonglass"
	drink_name = "Glass of lemonjuice"
	drink_desc = "Sour..."
	taste_description = "lemon juice"

/datum/reagent/consumable/drink/grapejuice
	name = "Grape Juice"
	id = "grapejuice"
	description = "This juice is known to stain shirts."
	color = "#993399" // rgb: 153, 51, 153
	drink_name = "Grape Juice"
	drink_desc = "If you leave it out for long enough, it might turn into wine."
	taste_description = "grape juice"

/datum/reagent/consumable/drink/banana
	name = "Banana Juice"
	id = "banana"
	description = "The raw essence of a banana."
	color = "#F6F834"
	process_flags = ORGANIC | SYNTHETIC
	drink_icon = "banana"
	drink_name = "Glass of banana juice"
	drink_desc = "The raw essence of a banana. HONK"
	taste_description = "banana juice"

/datum/reagent/consumable/drink/banana/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(HAS_TRAIT(M, TRAIT_COMIC_SANS) || issmall(M))
		update_flags |= M.adjustBruteLoss(-1, FALSE, robotic = TRUE)
		update_flags |= M.adjustFireLoss(-1, FALSE, robotic = TRUE)
	return ..() | update_flags

/datum/reagent/consumable/drink/nothing
	name = "Nothing"
	id = "nothing"
	description = "Absolutely nothing."
	process_flags = ORGANIC | SYNTHETIC
	drink_icon = "nothing"
	drink_name = "Nothing"
	drink_desc = "Absolutely nothing."
	taste_description = "nothing... how?"

/datum/reagent/consumable/drink/nothing/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && M.mind && M.mind.miming)
		update_flags |= M.adjustBruteLoss(-1, FALSE, robotic = TRUE)
		update_flags |= M.adjustFireLoss(-1, FALSE, robotic = TRUE)
	return ..() | update_flags

/datum/reagent/consumable/drink/potato_juice
	name = "Potato Juice"
	id = "potato"
	description = "Juice of the potato. Bleh."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	drink_icon = "glass_brown"
	drink_name = "Glass of  potato juice"
	drink_desc = "Who in the hell requests this? Gross!"
	taste_description = "puke, you're pretty sure"

/datum/reagent/consumable/drink/milk
	name = "Milk"
	id = "milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#F1F1F1"
	drink_icon = "glass_white"
	drink_name = "Glass of milk"
	drink_desc = "White and nutritious goodness!"
	taste_description = "milk"

/datum/reagent/consumable/drink/milk/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 2)
	return ..() | update_flags

/datum/reagent/consumable/drink/milk/soymilk
	name = "Soy Milk"
	id = "soymilk"
	description = "An opaque white liquid made from soybeans."
	color = "#DCD3AF"
	drink_name = "Glass of soy milk"
	drink_desc = "White and nutritious soy goodness!"
	taste_description = "fake milk"

/datum/reagent/consumable/drink/milk/cream
	name = "Cream"
	id = "cream"
	description = "A mix of higher-fat fractions of milk that have been skimmed off. Occasionally drunk straight, but more often used as a mixer or culinary ingrediant."
	drink_name = "Glass of cream"
	drink_desc = "A glass of cream, a mix of higher-fat fractions of milk that have been skimmed off. Occasionally drunk straight, but more often used as a mixer or culinary ingrediant."
	taste_description = "cream"

/datum/reagent/consumable/drink/milk/chocolate_milk
	name = "Chocolate milk"
	id ="chocolate_milk"
	description = "Chocolate-flavored milk, tastes like being a kid again."
	color = "#652109"
	drink_name = "Chocolate milk"
	drink_desc = "Smells like childhood. What would they need to add to make it taste like childhood too?"
	taste_description = "chocolate milk"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And cocoa beans."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#401101"
	drink_icon = "hot_coco"
	drink_name = "Glass of hot coco"
	drink_desc = "Delicious and cozy."
	taste_description = "chocolate"

/datum/reagent/consumable/drink/hot_coco/on_mob_life(mob/living/M)
	if(M.bodytemperature < 310) // 310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	return ..()

/datum/reagent/consumable/drink/coffee
	name = "Coffee"
	id = "coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" // rgb: 72, 32, 0
	nutriment_factor = 0
	adj_dizzy = -10 SECONDS
	adj_drowsy = -6 SECONDS
	adj_sleepy = -4 SECONDS
	overdose_threshold = 45
	addiction_chance = 2 // It's true.
	addiction_chance_additional = 20
	addiction_threshold = 10
	minor_addiction = TRUE
	heart_rate_increase = 1
	drink_icon = "glass_brown"
	drink_name = "Glass of coffee"
	drink_desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."
	taste_description = "coffee"

/datum/reagent/consumable/drink/coffee/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 5)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/overdose_process(mob/living/M, severity)
	if(volume > 45)
		M.Jitter(10 SECONDS)
	return list(0, STATUS_UPDATE_NONE)

/datum/reagent/consumable/drink/coffee/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#33250A"
	drink_icon = "icedcoffeeglass"
	drink_name = "Iced Coffee"
	drink_desc = "A drink to perk you up and refresh you!"
	taste_description = "refreshingly cold coffee"

/datum/reagent/consumable/drink/coffee/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	color = "#8A6723"
	adj_sleepy = 0
	drink_icon = "soy_latte"
	drink_name = "Soy Latte"
	drink_desc = "A nice and refrshing beverage while you are reading."
	taste_description = "milkish coffee"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/coffee/soy_latte/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.SetSleeping(0)
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	description = "A nice, strong and tasty beverage while you are reading."
	color = "#7A5C21"
	adj_sleepy = 0
	drink_icon = "cafe_latte"
	drink_name = "Cafe Latte"
	drink_desc = "A nice, strong and refreshing beverage while you are reading."
	taste_description = "milky coffee"

/datum/reagent/consumable/drink/coffee/cafe_latte/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.SetSleeping(0)
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/cafe_latte/cafe_mocha
	name = "Cafe Mocha"
	id = "cafe_mocha"
	description = "The perfect blend of coffee, milk, and chocolate."
	color = "#3E2603"
	drink_name = "Cafe Mocha"
	drink_desc = "The perfect blend of coffee, milk, and chocolate."
	taste_description = "chocolatey coffee"

/datum/reagent/consumable/drink/coffee/cafe_latte/pumpkin_latte
	name = "Pumpkin Latte"
	id = "pumpkin_latte"
	description = "A mix of pumpkin juice and coffee."
	color = "#F4A460"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	drink_icon = "pumpkin_latte"
	drink_name = "Pumpkin Latte"
	drink_desc = "A mix of coffee and pumpkin juice."
	taste_description = "overpriced hipster spices"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/tea
	name = "Tea"
	id = "tea"
	description = "Tasty black tea: It has antioxidants. It's good for you!"
	color = "#5d2409"
	nutriment_factor = 0
	adj_dizzy = -4 SECONDS
	adj_drowsy = -2 SECONDS
	adj_sleepy = -6 SECONDS
	addiction_chance = 1
	addiction_chance_additional = 1
	addiction_threshold = 10
	minor_addiction = TRUE
	drink_icon = "glass_brown"
	drink_name = "Glass of Tea"
	drink_desc = "A glass of hot tea. Perhaps a cup with a handle would have been smarter?"
	taste_description = "tea"

/datum/reagent/consumable/drink/tea/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		if(HAS_TRAIT(M, TRAIT_CHAV))
			update_flags |= M.adjustBruteLoss(-1, FALSE)
			update_flags |= M.adjustFireLoss(-1, FALSE)
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/tea/icetea
	name = "Iced Tea"
	id = "icetea"
	description = "No relation to a certain rap artist/ actor."
	color = "#73280d"
	drink_icon = "icetea"
	drink_name = "Iced Tea"
	drink_desc = "No relation to a certain rap artist/ actor."
	taste_description = "cold tea"

/datum/reagent/consumable/drink/bananahonk
	name = "Banana Honk"
	id = "bananahonk"
	description = "A drink from Clown Heaven."
	color = "#d4c540"
	process_flags = ORGANIC | SYNTHETIC
	drink_icon = "bananahonkglass"
	drink_name = "Banana Honk"
	drink_desc = "A drink from Banana Heaven."
	taste_description = "HONK"

/datum/reagent/consumable/drink/bananahonk/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(HAS_TRAIT(M, TRAIT_COMIC_SANS) || issmall(M))
		update_flags |= M.adjustBruteLoss(-1, FALSE, robotic = TRUE)
		update_flags |= M.adjustFireLoss(-1, FALSE, robotic = TRUE)
	return ..() | update_flags

/datum/reagent/consumable/drink/silencer
	name = "Silencer"
	id = "silencer"
	description = "A drink from Mime Heaven."
	color = "#7c8287"
	process_flags = ORGANIC | SYNTHETIC
	drink_icon = "silencerglass"
	drink_name = "Silencer"
	drink_desc = "A drink from mime Heaven."
	taste_description = "mphhhh"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/silencer/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && M.mind && M.mind.miming)
		update_flags |= M.adjustBruteLoss(-1, FALSE, robotic = TRUE)
		update_flags |= M.adjustFireLoss(-1, FALSE, robotic = TRUE)
	return ..() | update_flags

/datum/reagent/consumable/drink/chocolatepudding
	name = "Chocolate Pudding"
	id = "chocolatepudding"
	description = "A great dessert for chocolate lovers."
	color = "#63230d"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "chocolatepudding"
	drink_name = "Chocolate Pudding"
	drink_desc = "A decadent chocolate dessert, in drinkable form."
	taste_description = "chocolate"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/vanillapudding
	name = "Vanilla Pudding"
	id = "vanillapudding"
	description = "A great dessert for vanilla lovers."
	color = "#cbbe8a"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "vanillapudding"
	drink_name = "Vanilla Pudding"
	drink_desc = "A rich vanilla dessert, in drinkable form."
	taste_description = "vanilla"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/cherryshake
	name = "Cherry Shake"
	id = "cherryshake"
	description = "A cherry flavored milkshake."
	color = "#ff7970"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "cherryshake"
	drink_name = "Cherry Shake"
	drink_desc = "A cherry flavored milkshake."
	taste_description = "cherry milkshake"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/bluecherryshake
	name = "Blue Cherry Shake"
	id = "bluecherryshake"
	description = "An exotic milkshake."
	color = "#00F1FF"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "bluecherryshake"
	drink_name = "Blue Cherry Shake"
	drink_desc = "An exotic blue milkshake."
	taste_description = "blues"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/drink/gibbfloats
	name = "Gibb Floats"
	id = "gibbfloats"
	description = "Ice cream on top of a Dr. Gibb glass."
	color = "#B22222"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	drink_icon= "gibbfloats"
	drink_name = "Gibbfloat"
	drink_desc = "Dr. Gibb with ice cream on top."
	taste_description = "taste revolution"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/pumpkinjuice
	name = "Pumpkin Juice"
	id = "pumpkinjuice"
	description = "Juiced from real pumpkin."
	color = "#FFA500"
	drink_name = "Pumpkin Juice"
	drink_desc = "Healthy and tasty!"
	taste_description = "autumn"

/datum/reagent/consumable/drink/blumpkinjuice
	name = "Blumpkin Juice"
	id = "blumpkinjuice"
	description = "Juiced from real blumpkin."
	color = "#00BFFF"
	drink_name = "Blumpkin Juice"
	drink_desc = "Unhealthy and revolting! It seems to be glowing..."
	taste_description = "caustic puke"

/datum/reagent/consumable/drink/grape_soda
	name = "Grape soda"
	id = "grapesoda"
	description = "Beloved of children and teetotalers."
	color = "#b570ff"
	drink_name = "Grape Soda"
	drink_desc = "Made with real grapes! Shocking!"
	taste_description = "grape soda"

/datum/reagent/consumable/drink/icecoco
	name = "Iced Cocoa"
	id = "icecoco"
	description = "Hot cocoa and ice, refreshing and cool."
	color = "#5d2c28"
	drink_icon = "icedcoffeeglass"
	drink_name = "Iced Cocoa"
	drink_desc = "A sweeter drink to perk you up and refresh you!"
	taste_description = "refreshingly cold cocoa"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/tonic
	name = "Tonic Water"
	id = "tonic"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#5999c4"
	adj_dizzy = -10 SECONDS
	adj_drowsy = -6 SECONDS
	adj_sleepy = -4 SECONDS
	drink_icon = "glass_clear"
	drink_name = "Glass of Tonic Water"
	drink_desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	taste_description = "bitterness"

/datum/reagent/consumable/drink/sodawater
	name = "Soda Water"
	id = "sodawater"
	description = "A can of club soda. Why not make a scotch and soda?"
	color = "#619494"
	adj_dizzy = -10 SECONDS
	adj_drowsy = -6 SECONDS
	drink_icon = "glass_clear"
	drink_name = "Glass of Soda Water"
	drink_desc = "Soda water. Why not make a scotch and soda?"
	taste_description = "fizz"

/datum/reagent/consumable/drink/ice
	name = "Ice"
	id = "ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148
	drink_icon = "iceglass"
	drink_name = "Glass of ice"
	drink_desc = "Generally, you're supposed to put something else in there too..."
	taste_description = "cold"

/datum/reagent/consumable/drink/ice/on_mob_life(mob/living/M)
	M.bodytemperature = max(M.bodytemperature - 5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0)
	return ..()

/datum/reagent/consumable/drink/space_cola
	name = "Cola"
	id = "cola"
	description = "A refreshing beverage."
	color = "#401a08"
	adj_drowsy = -10 SECONDS
	drink_icon = "glass_brown"
	drink_name = "Glass of Space Cola"
	drink_desc = "A glass of refreshing Space Cola."
	taste_description = "cola"

/datum/reagent/consumable/drink/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	description = "Cola, cola never changes."
	color = "#0e0502"
	adj_sleepy = -4 SECONDS
	drink_icon = "nuka_colaglass"
	drink_name = "Nuka Cola"
	drink_desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland."
	harmless = FALSE
	taste_description = "radioactive cola"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/drink/nuka_cola/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Jitter(40 SECONDS)
	M.Druggy(60 SECONDS)
	M.AdjustDizzy(10 SECONDS)
	M.SetDrowsy(0)
	ADD_TRAIT(M, TRAIT_GOTTAGONOTSOFAST, id)
	return ..() | update_flags

/datum/reagent/consumable/drink/nuka_cola/on_mob_delete(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_GOTTAGONOTSOFAST, id)
	..()

/datum/reagent/consumable/drink/spacemountainwind
	name = "Space Mountain Wind"
	id = "spacemountainwind"
	description = "Blows right through you like a space wind."
	color = "#58d92e"
	adj_drowsy = -14 SECONDS
	adj_sleepy = -2 SECONDS
	drink_icon = "Space_mountain_wind_glass"
	drink_name = "Glass of Space Mountain Wind"
	drink_desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
	taste_description = "lime soda"

/datum/reagent/consumable/drink/dr_gibb
	name = "Dr. Gibb"
	id = "dr_gibb"
	description = "A delicious blend of 42 different flavours"
	color = "#bf0d16"
	adj_drowsy = -12 SECONDS
	drink_icon = "dr_gibb_glass"
	drink_name = "Glass of Dr. Gibb"
	drink_desc = "Dr. Gibb. Not as dangerous as the name might imply."
	taste_description = "cherry soda"

/datum/reagent/consumable/drink/space_up
	name = "Space-Up"
	id = "space_up"
	description = "Tastes like a hull breach in your mouth."
	color = "#446693"
	drink_icon = "space-up_glass"
	drink_name = "Glass of Space-up"
	drink_desc = "Space-up. It helps keep your cool."
	taste_description = "lemon soda"

/datum/reagent/consumable/drink/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	id = "lemon_lime"
	color = "#BEC80F"
	taste_description = "citrus soda"

/datum/reagent/consumable/drink/lemonade
	name = "Lemonade"
	description = "Oh the nostalgia..."
	id = "lemonade"
	color = "#FFFF00" // rgb: 255, 255, 0
	drink_icon = "lemonade"
	drink_name = "Lemonade"
	drink_desc = "Oh the nostalgia..."
	taste_description = "lemonade"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	id = "kiraspecial"
	color = "#c97b0d"
	drink_icon = "kiraspecial"
	drink_name = "Kira Special"
	drink_desc = "Long live the guy who everyone had mistaken for a girl. Baka!"
	taste_description = "citrus soda"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/brownstar
	name = "Brown Star"
	description = "It's not what it sounds like..."
	id = "brownstar"
	color = "#9F3400" // rgb: 159, 052, 000
	drink_icon = "brownstar"
	drink_name = "Brown Star"
	drink_desc = "Its not what it sounds like..."
	taste_description = "orange soda"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	id = "milkshake"
	color = "#ddcaa6"
	drink_icon = "milkshake"
	drink_name = "Milkshake"
	drink_desc = "Glorious brainfreezing mixture."
	taste_description = "milkshake"

/datum/reagent/consumable/drink/rewriter
	name = "Rewriter"
	description = "The secret of the sanctuary of the Librarian..."
	id = "rewriter"
	color = "#1f6f3a"
	drink_icon = "rewriter"
	drink_name = "Rewriter"
	drink_desc = "The secret of the sanctuary of the Librarian..."
	taste_description = "coffee...soda?"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/rewriter/on_mob_life(mob/living/M)
	M.Jitter(10 SECONDS)
	return ..()

/datum/reagent/consumable/drink/arnold_palmer
	name = "Arnold Palmer"
	id = "arnold_palmer"
	description = "A wholesome mixture of lemonade and iced tea."
	color = "#af934c"
	drink_icon = "arnoldpalmer"
	drink_name = "Arnold Palmer"
	drink_desc = "A wholesome mixture of lemonade and iced tea... looks like somebody didn't stir this one very well."
	taste_description = "sweet and fizzy"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/fyrsskar_tears
	name = "Tears of Fyrsskar"
	id = "fyrsskartears"
	description = "Plasmonic based drink that was consumed by ancient inhabitants of Skrellian homeworld to purge impurities."
	color = "#C300AE" // rgb: 195, 0, 174
	drink_icon = "fyrsskartears"
	drink_name = "Tears of Fyrsskar"
	drink_desc = "Plasmonic based drink that was consumed by ancient inhabitants of Skrellian homeworld to purge impurities."
	taste_description = "plasma"
	var/alcohol_perc = 0.05
	var/dizzy_adj = 6 SECONDS
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/fyrsskar_tears/on_mob_add(mob/living/M)
	if(isskrell(M))
		ADD_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE, id)
	RegisterSignal(M, COMSIG_AFTER_SPECIES_CHANGE, PROC_REF(on_species_change))
	return ..()

/datum/reagent/consumable/drink/fyrsskar_tears/on_mob_life(mob/living/M)
	if(!isskrell(M))
		return ..()

	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id, 5)
	// imitate alcohol effects using current cycle
	M.AdjustDrunk(alcohol_perc STATUS_EFFECT_CONSTANT)
	M.AdjustDizzy(dizzy_adj, bound_upper = 1.5 MINUTES)
	return ..()

/datum/reagent/consumable/drink/fyrsskar_tears/on_mob_delete(mob/living/M)
	if(isskrell(M))
		REMOVE_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE, id)
	UnregisterSignal(M, COMSIG_AFTER_SPECIES_CHANGE)
	return ..()

/datum/reagent/consumable/drink/fyrsskar_tears/proc/on_species_change(mob/living/M)
	SIGNAL_HANDLER // COMSIG_AFTER_SPECIES_CHANGE
	if(!isskrell(M))
		REMOVE_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE, id)
	else
		ADD_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE, id)

/datum/reagent/consumable/drink/lean
	name = "Lean"
	id = "lean"
	description = "Also known as Purple Drank."
	color = "#8b3cd9"
	drink_icon = "lean"
	drink_name = "Lean"
	drink_desc = "Also known as Purple Drank."
	taste_description = "sweet druggy soda"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/drink/melonade
	name = "Melonade"
	description = "A slushy, sour, melon-lemonade."
	id = "melonade"
	color = "#e8313f" // rgb: 232, 49, 63
	drink_icon = "melonade_glass"
	drink_name = "Tall Glass of Melonade"
	drink_desc = "This would go great with 147 fluffity puffity marshalays."
	taste_description = "summer fruit"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/melonade/on_mob_life(mob/living/M)
	if(M.satiety < 600)
		M.satiety += 5
	return ..()

/datum/reagent/consumable/drink/tapioca_pearls
	name = "Tapioca Pearls"
	description = "Tapioca pearls made from starch ground by cassava root. Tastes pretty good in tea."
	id = "tapiocapearls"
	color = "#222222"
	drink_icon = "tapiocapearls"
	drink_name = "Tapioca Pearls"
	drink_desc = "This would go great with sugar, milk, and tea."
	taste_description = "chewy starch"

/datum/reagent/consumable/drink/tea/bubbletea
	name = "Bubble Tea"
	description = "A tea-based drink made with tapioca pearls. Known by some as boba tea."
	id = "bubbletea"
	drink_icon = "bubbletea"
	drink_name = "Bubble Tea"
	drink_desc = "You feel trendy for drinking this."
	taste_description = "sweet tea with chewy pearls"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/tea/milktea
	name = "Milk Tea"
	description = "Tea and milk mixed together. Both sweet and creamy."
	id = "milktea"
	color = "#bfa46f"
	drink_icon = "milktea"
	drink_name = "Milk Tea"
	drink_desc = "A refreshing and sweet beverage."
	taste_description = "sweet milky tea"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/tea/bubblemilktea
	name = "Bubble Milk Tea"
	description = "A tea-based drink made with milk and tapioca pearls. Known by some as boba milk tea."
	id = "bubblemilktea"
	color = "#d4b483"
	drink_icon = "bubblemilktea"
	drink_name = "Bubble Milk Tea"
	drink_desc = "You feel extra trendy for drinking this."
	taste_description = "sweet milky tea with chewy pearls"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/royrogers
	name = "Roy Rogers"
	description = "A cola classic from the days of Earth."
	id = "royrogers"
	color = "#8F1909"
	drink_icon = "royrogers_glass"
	drink_name = "Roy Rogers"
	drink_desc = "The rootinest, tootinest drink you can get at the bar without any alcohol."
	taste_description = "berries and cola"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/shirleytemple
	name = "Shirley Temple"
	description = "A bubbly, fruity delight from the days of Earth."
	id = "shirleytemple"
	color = "#FF7970"
	drink_icon = "shirleytemple_glass"
	drink_name = "Shirley Temple"
	drink_desc = "A soft drink classic with a cherry on top."
	taste_description = "berries and carbonation"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/partypunch
	name = "Party Punch"
	description = "A vibrant mix of fruit juices. A real punch of flavor."
	id = "partypunch"
	color = "#E8313f"
	drink_icon = "partypunch_glass"
	drink_name = "Glass of Party Punch"
	drink_desc = "A vibrant mix of fruit juices. A real punch of flavor."
	taste_description = "a punch of fruit"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/coffee/eggcoffee
	name = "Egg Coffee"
	description = "Rich coffee with custard foam."
	id = "eggcoffee"
	color = "#824D27"
	drink_icon = "eggcoffee_glass"
	drink_name = "Glass Mug of Egg Coffee"
	drink_desc = "Rich coffee with custard foam."
	taste_description = "rich foam"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/coffee/eggcoffee/on_mob_life(mob/living/M)
	if(prob(3))
		M.reagents.add_reagent("cholesterol", rand(1, 2))
	return ..()

/datum/reagent/consumable/drink/horchata
	name = "Horchata"
	description = "Sweetened rice milk topped with cinnamon."
	id = "horchata"
	color = "#E0DDD5"
	drink_icon = "horchata_glass"
	drink_name = "Glass of Horchata"
	drink_desc = "Sweetened rice milk topped with cinnamon."
	taste_description = "cinnamony rice milk"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/monstermix
	name = "Monster Mix"
	description = "A mix of every soda in the dispenser. You monster."
	id = "monstermix"
	color = "#CBFF71"
	drink_icon = "monstermix_glass"
	drink_name = "Glass of Monster Mix"
	drink_desc = "A mix of every soda in the dispenser. You monster."
	taste_description = "an unholy amalgam"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/spessamatosmash
	name = "Spessamato Smash"
	description = "Fruity yet salty."
	id = "tomato_spaceup"
	color = "#B72429"
	drink_icon = "tomato_spaceup"
	drink_name = "Glass of Spessamato Smash"
	drink_desc = "Fruity yet salty."
	taste_description = "sparkling tomato"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/eggcream
	name = "Egg Cream"
	description = "Smells like custard."
	id = "eggcream"
	color = "#F5D4BB"
	drink_icon = "eggcream_glass"
	drink_name = "Glass of Egg Cream"
	drink_desc = "You now have a glass of custard."
	taste_description = "sweet egg"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/eggcream/on_mob_life(mob/living/M)
	if(prob(2))
		M.reagents.add_reagent("cholesterol", rand(1, 2))
	return ..()

/datum/reagent/consumable/drink/beetshrub
	name = "Beet Shrub"
	description = "So, so sour."
	id = "beetshrub"
	color = "#99305D"
	drink_icon = "beetshrub_glass"
	drink_name = "Glass of Beet Shrub"
	drink_desc = "The vinegar gives this far more bite than any ordinary person would drink straight."
	taste_description = "vinegar"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/drink/berrybeetrefresher
	name = "Berry Beet Refresher"
	description = "Tangy, sweet, with just a bit of bite."
	id = "berrybeetrefresher"
	color = "#C7437C"
	drink_icon = "berry_beet_refresher"
	drink_name = "Glass of Berry Beet Refresher"
	drink_desc = "Tangy, sweet, with just a bit of bite."
	taste_description = "tangy, bubbly fruit"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/drink/smoothie
	name = "Empty Smoothie"
	id = "smoothie"
	color = "#9933FF"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "glass_magenta"
	drink_name = "Glass of Empty Smoothie"
	drink_desc = ABSTRACT_TYPE_DESC

/datum/reagent/consumable/drink/smoothie/on_mob_life(mob/living/M)
	if(M.satiety < 600)
		M.satiety += 5
	return ..()

/datum/reagent/consumable/drink/smoothie/pbnbanana
	name = "Peanut Butter and Banana Smoothie"
	description = "This is so smooth, it's definitely made with creamy peanut butter."
	id = "smoothie_pbnbanana"
	color = "#F3BC58"
	drink_icon = "smoothie_pbnbanana"
	drink_name = "Glass of PB Banana Smoothie"
	drink_desc = "So smooth and fluffy."
	taste_description = "nutty banana"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/smoothie/veryberry
	name = "Very Berry Smoothie"
	description = "Berries give this creamy beverage its speckled appearance."
	id = "smoothie_veryberry"
	color = "#C7437C"
	drink_icon = "smoothie_veryberry"
	drink_name = "Glass of Very Berry Smoothie"
	drink_desc = "Berries give this creamy beverage its speckled appearance."
	taste_description = "berries and cream"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/vegetablemix
	name = "Vegetable Juice Mix"
	description = "More vitamins than you can shake a stick at."
	id = "vegjuice"
	color = "#B36131"
	drink_icon = "vegjuice_glass"
	drink_name = "Glass of Vegetable Juice"
	drink_desc = "Mellow and creamy vegetable juice."
	taste_description = "so many vitamins"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/drink/vegetablemix/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustEyeBlurry(-0.5 SECONDS)
	M.AdjustEyeBlind(-0.5 SECONDS)
	if(M.satiety < 600)
		M.satiety += 5
	if(prob(10))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	if(current_cycle > 20 && prob(2))
		update_flags |= M.cure_nearsighted(EYE_DAMAGE, FALSE)
	if(prob(5))
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/electrolytes
	name = "Electrolytes"
	description = "That's fancy talk for salted water."
	id = "electrolytes"
	color = "#67D6F0"
	drink_icon = "electrolytes_glass"
	drink_name = "Glass of Electrolytes"
	drink_desc = "The fastest way to rehydration without an IV."
	taste_description = "salt"
	adj_dizzy = -5 SECONDS
	process_flags = ORGANIC | SYNTHETIC
	max_kidney_damage = 3

/datum/reagent/consumable/drink/electrolytes/on_mob_life(mob/living/M)
	M.AdjustConfused(-5 SECONDS)
	M.AdjustEyeBlurry(-2 SECONDS)
	if(ishuman(M) && prob(10))
		var/mob/living/carbon/human/H = M
		if(!(NO_BLOOD in H.dna.species.species_traits))//do not restore blood on things with no blood by nature.
			if(H.blood_volume < BLOOD_VOLUME_NORMAL)
				H.blood_volume += 0.5
	return ..()

/datum/reagent/consumable/drink/gingerale
	name = "Ginger Ale"
	description = "Spicy and fizzy soda."
	id = "ginger_ale"
	color = "#996B2B"
	drink_icon = "ginger_ale_glass"
	drink_name = "Glass of Ginger Ale"
	drink_desc = "Spicy and fizzy soda."
	taste_description = "sweet, carbonated ginger"

/datum/reagent/consumable/drink/electrolytes/top_up
	name = "Top-Up"
	description = "A sports drink for the busy spessman."
	id = "top_up"
	color = "#3c5e8b"
	drink_icon = "top_up_glass"
	drink_name = "Glass of Top-Up"
	drink_desc = "A sports drink for the busy spessman."
	taste_description = "lemony lectrolytes"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/electrolytes/zero_day
	name = "Zero Day"
	description = "This beverage keeps leaking and leaking."
	id = "zero_day"
	color = "#9dafad"
	drink_icon = "zero_day_glass"
	drink_name = "Glass of Zero Day"
	drink_desc = "A data breach in a glass."
	taste_description = "half-emptiness"
	COOLDOWN_DECLARE(drip_cooldown)
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/electrolytes/zero_day/on_new(data)
	..()
	START_PROCESSING(SSprocessing, src)

/datum/reagent/consumable/drink/electrolytes/zero_day/process()
	if(!..())
		return
	if(!istype(holder.my_atom, /obj/item/reagent_containers/iv_bag) && !istype(holder.my_atom, /obj/item/reagent_containers/drinks))
		return
	if(!COOLDOWN_FINISHED(src, drip_cooldown))
		return
	holder.remove_reagent("zero_day", 1)
	var/turf/T = get_turf(holder.my_atom)
	var/drop_type = /obj/effect/decal/cleanable/reagent/drip
	var/obj/effect/decal/cleanable/reagent/drip/drop = locate() in T
	if(drop)
		if(drop.amount < 5)
			drop.amount++
			var/image/I = image(drop.icon, drop.random_icon_states)
			I.icon += drop.basecolor
			drop.overlays |= I
			drop.basecolor = color
			drop.update_icon()
	else
		drop = new drop_type(T, color)
		drop.desc = "Looks like someone spilled their drink."
		drop.update_icon()
	COOLDOWN_START(src, drip_cooldown, 2.6 SECONDS)

/datum/reagent/consumable/drink/electrolytes/tcp_sip
	name = "TCP Sip"
	description = "A non-synthanolic refreshment for synthetics."
	id = "tcp_sip"
	color = "#467ae6"
	drink_icon = "tcp_sip_glass"
	drink_name = "Glass of TCP Sip"
	drink_desc = "A non-synthanolic refreshment for synthetics."
	taste_description = "half-emptiness"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/drink/electrolytes/tcp_sip/on_mob_life(mob/living/M)
	metabolization_rate = REAGENTS_METABOLISM
	if(M.dna.species.reagent_tag & PROCESS_SYN)
		return ..()
	metabolization_rate += 3.6 // gets removed from organics very fast
	if(prob(25))
		metabolization_rate += 15
		M.fakevomit()
	return ..()

/datum/reagent/consumable/drink/electrolytes/tcp_sip/ginger_beep
	name = "Ginger Beep"
	description = "A gingery refreshment for synthetics."
	id = "ginger_beep"
	color = "#bd994d"
	drink_icon = "ginger_beep_glass"
	drink_name = "Glass of Ginger Beep"
	drink_desc = "A gingery refreshment for synthetics. Fizzy, too."
	taste_description = "static and spice"

/datum/reagent/consumable/drink/electrolytes/tcp_sip/cog_a_cola
	name = "Cog-a-Cola"
	description = "A non-synthanolic soda for synthetics."
	id = "cog_a_cola"
	color = "#7f300b"
	drink_icon = "cog_a_cola_glass"
	drink_name = "Glass of Cog-a-Cola"
	drink_desc = "A non-synthanolic soda for synthetics."
	taste_description = "sugary bubbles with a hint of oil"

/datum/reagent/consumable/drink/electrolytes/tcp_sip/electrocharge
	name = "Electrocharge"
	description = "A non-synthanolic beverage to keep a synthetic's battery high."
	id = "electrocharge"
	color = "#9090a8"
	drink_icon = "electrocharge_glass"
	drink_name = "Glass of Electrocharge"
	drink_desc = "A real charge-up for synthetics."
	taste_description = "a full battery"
	goal_difficulty = REAGENT_GOAL_HARD
	COOLDOWN_DECLARE(drink_message_cooldown)
	COOLDOWN_DECLARE(drink_overcharge_cooldown)

/datum/reagent/consumable/drink/electrolytes/tcp_sip/electrocharge/on_mob_life(mob/living/M)
	metabolization_rate = REAGENTS_METABOLISM
	if(!(M.dna.species.reagent_tag & PROCESS_SYN))
		return ..()
	var/obj/item/organ/internal/cell/microbattery = M.get_organ_slot("heart")
	if(!istype(microbattery)) // if there's no microbattery don't bother
		return ..()
	if(M.nutrition > NUTRITION_LEVEL_FULL && prob(10) && COOLDOWN_FINISHED(src, drink_overcharge_cooldown))
		do_sparks(2, FALSE, M)
		M.visible_message(
			SPAN_NOTICE("[M] lets off a few sparks."),
			SPAN_NOTICE("You feel a little <i>too</i> charged up."),
			SPAN_NOTICE("Something fizzles nearby.")
		)
		microbattery.receive_damage(2, TRUE) // this drink is not great for you when you're already charged
		COOLDOWN_START(src, drink_overcharge_cooldown, 30 SECONDS)
	if(M.nutrition < NUTRITION_LEVEL_WELL_FED)
		M.nutrition += 1
	if(M.nutrition < NUTRITION_LEVEL_HUNGRY)
		metabolization_rate += 0.8 // charging triple means burning through triple
		M.nutrition += 2
		if(COOLDOWN_FINISHED(src, drink_message_cooldown))
			to_chat(M, SPAN_NOTICE("You feel relief surging through your wires!"))
			COOLDOWN_START(src, drink_message_cooldown, 10 MINUTES)
	return ..()

/datum/reagent/consumable/drink/electrolytes/tcp_sip/battery_acid
	name = "Battery Acid"
	description = "An acidic beverage for synthetics."
	id = "battery_acid"
	color = "#d0e7ea"
	drink_icon = "battery_acid_glass"
	drink_name = "Glass of Battery Acid"
	drink_desc = "So acidic, it forms an acid like its namesake on the rim of the glass."
	taste_description = "fried wires"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/drink/electrolytes/tcp_sip/processor_punch
	name = "Processor Punch"
	description = "A sweetened, non-synthanolic, synthetic sip."
	id = "processor_punch"
	color = "#88242d"
	drink_icon = "processor_punch_glass"
	drink_name = "Glass of Processor Punch"
	drink_desc = "A sweetened, non-synthanolic, synthetic sip."
	taste_description = "a punch to the processors"

/datum/reagent/consumable/drink/bubbly_beep
	name = "Bubbly Beep"
	description = "A squeaky-clean, foamy, synthetic beverage."
	id = "bubbly_beep"
	color = "#2984d1"
	drink_icon = "bubbly_beep_glass"
	drink_name = "Glass of Bubbly Beep"
	drink_desc = "The cleanest, bubbliest drink on the station."
	taste_description = "decontamination"
	goal_difficulty = REAGENT_GOAL_NORMAL
	process_flags = SYNTHETIC | ORGANIC
	COOLDOWN_DECLARE(drink_message_cooldown)

/datum/reagent/consumable/drink/bubbly_beep/on_mob_life(mob/living/M)
	metabolization_rate = REAGENTS_METABOLISM
	if(!(M.dna.species.reagent_tag & PROCESS_SYN))
		metabolization_rate += 3.6 // gets removed from organics very fast
		if(prob(50))
			metabolization_rate += 30
			M.fakevomit()
		return ..()
	if(/obj/effect/decal/cleanable in M)
		qdel(pick(/obj/effect/decal/cleanable/ in M))
	else
		M.clean_blood()
		if(COOLDOWN_FINISHED(src, drink_message_cooldown))
			to_chat(M, SPAN_NOTICE("The foam cleans you as it bubbles through your components."))
			COOLDOWN_START(src, drink_message_cooldown, 2 MINUTES)
	SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT)
	return ..()

/datum/reagent/consumable/drink/tin_and_tonic
	name = "Tin and Tonic"
	description = "A good sip for a synthetic curious about quinine."
	id = "tin_and_tonic"
	color = "#61a6a8"
	drink_icon = "tin_and_tonic_glass"
	drink_name = "Glass of Tin and Tonic"
	drink_desc = "A good sip for a synthetic curious about quinine."
	taste_description = "smoothly-running processors"
	goal_difficulty = REAGENT_GOAL_NORMAL
	process_flags = SYNTHETIC | ORGANIC

/datum/reagent/consumable/drink/tin_and_tonic/on_mob_life(mob/living/M)
	metabolization_rate = REAGENTS_METABOLISM
	if(!(M.dna.species.reagent_tag & PROCESS_SYN))
		metabolization_rate += 3.6 // gets removed from organics very fast
		return ..()
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBrainLoss(-0.5, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/salt_and_battery
	name = "Salt and Battery"
	description = "A particularly offensive beverage for synthetics."
	id = "salt_and_battery"
	color = "#959595"
	drink_icon = "salt_and_battery_glass"
	drink_name = "Glass of Salt and Battery"
	drink_desc = "Looks like it'll charge you up, but really it'll beat you down."
	taste_description = "assault to the batteries"
	goal_difficulty = REAGENT_GOAL_HARD
	process_flags = SYNTHETIC | ORGANIC

/datum/reagent/consumable/drink/salt_and_battery/on_mob_life(mob/living/M)
	metabolization_rate = REAGENTS_METABOLISM
	if(!(M.dna.species.reagent_tag & PROCESS_SYN))
		metabolization_rate += 3.6 // gets removed from organics very fast
		if(prob(15))
			metabolization_rate += 15
			M.fakevomit()
		return ..()
	var/datum/antagonist/mindflayer/flayer = M.mind?.has_antag_datum(/datum/antagonist/mindflayer)
	if(flayer && (flayer.total_swarms_gathered > 0)) // Inherited from conductive lube
		M.Jitter(15 SECONDS_TO_JITTER)
		if(prob(10))
			do_sparks(2, FALSE, M)
	M.bodytemperature += 5
	if(prob(20))
		metabolization_rate += 1.6 // if it kicks your butt, make it kick some of the drink out too.
		M.adjustBruteLoss(2, FALSE)
		playsound(get_turf(M), 'sound/effects/hit_punch.ogg', 60, TRUE)
		var/beat_verbs = pick("assaults","batters")
		M.Jitter(0.5 SECONDS)
		M.visible_message(
			SPAN_NOTICE("[M] is battered by an unseen assailant!"),
			SPAN_NOTICE("The beverage [beat_verbs] you!"),
			SPAN_WARNING("You hear empty punches against metal!")
		)
		if(prob(25))
			M.KnockDown(2 SECONDS)
	return ..()

/datum/reagent/consumable/drink/soft_reset
	name = "Soft Reset"
	description = "Maybe your systems could use this once in a while."
	id = "soft_reset"
	color = "#1f3a46"
	drink_icon = "soft_reset_glass"
	drink_name = "Glass of Soft Reset"
	drink_desc = "Have you tried turning it off and back on again?"
	taste_description = "a little reboot"
	goal_difficulty = REAGENT_GOAL_HARD
	process_flags = SYNTHETIC | ORGANIC
	COOLDOWN_DECLARE(reboot_cooldown)

/datum/reagent/consumable/drink/soft_reset/on_mob_life(mob/living/M)
	if(!(M.dna.species.reagent_tag & PROCESS_SYN))
		metabolization_rate += 3.6 // gets removed from organics very fast
		if(prob(50))
			metabolization_rate += 30
			M.fakevomit()
		return ..()
	if(prob(10))
		for(var/obj/effect/decal/cleanable/C in M)
			qdel(C)
		M.clean_blood()
		SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT)
	var/mob/living/carbon/Mc = M
	if(istype(Mc))
		Mc.wetlevel -= 2
	M.germ_level -= min(volume*20, M.germ_level)
	if(COOLDOWN_FINISHED(src, reboot_cooldown) && prob(10))
		to_chat(M, SPAN_NOTICE("Your systems prepare for a reboot."))
		M.Paralyse(3 SECONDS)
		M.Drowsy(10 SECONDS)
		metabolization_rate += 2.6 // get rid of it faster after rebooting
		COOLDOWN_START(src, reboot_cooldown, 10 MINUTES)
	if(prob(50))
		M.AdjustConfused(-5 SECONDS)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R == src)
			M.reagents.remove_reagent(R.id, 1)
			continue
		if(R.id == "ultralube" || R.id == "lube")
			// Flushes lube and ultra-lube even faster than other chems
			M.reagents.remove_reagent(R.id, 5)
		else
			M.reagents.remove_reagent(R.id, 2)
	return ..()
