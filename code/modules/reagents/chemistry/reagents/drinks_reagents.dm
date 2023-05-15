/datum/reagent/consumable/drink/orangejuice
	name = "Orange juice"
	id = "orangejuice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#E78108" // rgb: 231, 129, 8
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

/datum/reagent/consumable/drink/pineapplejuice
	name = "Pineapple Juice"
	id = "pineapplejuice"
	description = "Pineapples juiced into a liquid. Sweet and sugary."
	color = "#e5b437"
	drink_icon = "glass_orange"
	drink_name = "Glass of pineapple juice"
	drink_desc = "A bright drink, sweet and sugary."
	taste_description = "pineapple juice"

/datum/reagent/consumable/drink/tomatojuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

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
	drink_name = "Glass of  carrot juice"
	drink_desc = "Just like a carrot, but without the crunching."
	taste_description = "carrot juice"

/datum/reagent/consumable/drink/carrotjuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustEyeBlurry(-2 SECONDS)
	M.AdjustEyeBlind(-2 SECONDS)
	if(current_cycle > 20 && prob(current_cycle - 10))
		update_flags |= M.cure_nearsighted(EYE_DAMAGE, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/doctor_delight
	name = "The Doctor's Delight"
	id = "doctorsdelight"
	description = "A gulp a day keeps the MediBot away. That's probably for the best."
	reagent_state = LIQUID
	color = "#FF8CFF" // rgb: 255, 140, 255
	drink_icon = "doctorsdelightglass"
	drink_name = "Doctor's Delight"
	drink_desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
	taste_description = "healthy dietary choices"

/datum/reagent/consumable/drink/doctor_delight/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/triple_citrus
	name = "Triple Citrus"
	id = "triple_citrus"
	description = "A refreshing mixed drink of orange, lemon and lime juice."
	reagent_state = LIQUID
	color = "#B5FF00"
	drink_icon = "triplecitrus"
	drink_name = "Glass of Triplecitrus Juice"
	drink_desc = "As colorful and healthy as it is delicious."
	taste_description = "citrus juice"

/datum/reagent/consumable/drink/triple_citrus/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		M.adjustToxLoss(-rand(1,2))

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

/datum/reagent/consumable/drink/watermelonjuice
	name = "Watermelon Juice"
	id = "watermelonjuice"
	description = "Delicious juice made from watermelon."
	color = "#863333" // rgb: 134, 51, 51
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
	drink_icon = "banana"
	drink_name = "Glass of banana juice"
	drink_desc = "The raw essence of a banana. HONK"
	taste_description = "banana juice"

/datum/reagent/consumable/drink/banana/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(HAS_TRAIT(M, TRAIT_COMIC_SANS) || issmall(M))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/nothing
	name = "Nothing"
	id = "nothing"
	description = "Absolutely nothing."
	drink_icon = "nothing"
	drink_name = "Nothing"
	drink_desc = "Absolutely nothing."
	taste_description = "nothing... how?"

/datum/reagent/consumable/drink/nothing/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && M.mind && M.mind.miming)
		update_flags |= M.adjustBruteLoss(-1, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
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
	description = "The fatty, still liquid part of milk. Why don't you mix this with some scotch, eh?"
	color = "#F1F1F1"
	drink_name = "Glass of cream"
	drink_desc = "Ewwww..."
	taste_description = "cream"

/datum/reagent/consumable/drink/milk/chocolate_milk
	name = "Chocolate milk"
	id ="chocolate_milk"
	description = "Chocolate-flavored milk, tastes like being a kid again."
	color = "#652109"
	drink_name = "Chocolate milk"
	drink_desc = "Smells like childhood. What would they need to add to make it taste like childhood too?"
	taste_description = "chocolate milk"

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
	var/update_flags = STATUS_UPDATE_NONE
	if(isvulpkanin(M) || istajaran(M) || isfarwa(M) || iswolpin(M))
		update_flags |= M.adjustToxLoss(2, FALSE)
	return ..() | update_flags

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

/datum/reagent/consumable/drink/tea
	name = "Tea"
	id = "tea"
	description = "Tasty black tea: It has antioxidants. It's good for you!"
	color = "#101000" // rgb: 16, 16, 0
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
	color = "#104038" // rgb: 16, 64, 56
	drink_icon = "icetea"
	drink_name = "Iced Tea"
	drink_desc = "No relation to a certain rap artist/ actor."
	taste_description = "cold tea"

/datum/reagent/consumable/drink/bananahonk
	name = "Banana Honk"
	id = "bananahonk"
	description = "A drink from Clown Heaven."
	color = "#664300" // rgb: 102, 67, 0
	drink_icon = "bananahonkglass"
	drink_name = "Banana Honk"
	drink_desc = "A drink from Banana Heaven."
	taste_description = "HONK"

/datum/reagent/consumable/drink/bananahonk/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(HAS_TRAIT(M, TRAIT_COMIC_SANS) || issmall(M))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/silencer
	name = "Silencer"
	id = "silencer"
	description = "A drink from Mime Heaven."
	color = "#664300" // rgb: 102, 67, 0
	drink_icon = "silencerglass"
	drink_name = "Silencer"
	drink_desc = "A drink from mime Heaven."
	taste_description = "mphhhh"

/datum/reagent/consumable/drink/silencer/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && (M.job in list("Mime")))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/chocolatepudding
	name = "Chocolate Pudding"
	id = "chocolatepudding"
	description = "A great dessert for chocolate lovers."
	color = "#800000"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "chocolatepudding"
	drink_name = "Chocolate Pudding"
	drink_desc = "A decadent chocolate dessert, in drinkable form."
	taste_description = "chocolate"

/datum/reagent/consumable/drink/vanillapudding
	name = "Vanilla Pudding"
	id = "vanillapudding"
	description = "A great dessert for vanilla lovers."
	color = "#FAFAD2"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "vanillapudding"
	drink_name = "Vanilla Pudding"
	drink_desc = "A rich vanilla dessert, in drinkable form."
	taste_description = "vanilla"

/datum/reagent/consumable/drink/cherryshake
	name = "Cherry Shake"
	id = "cherryshake"
	description = "A cherry flavored milkshake."
	color = "#FFB6C1"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "cherryshake"
	drink_name = "Cherry Shake"
	drink_desc = "A cherry flavored milkshake."
	taste_description = "cherry milkshake"

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

/datum/reagent/consumable/drink/pumpkin_latte
	name = "Pumpkin Latte"
	id = "pumpkin_latte"
	description = "A mix of pumpkin juice and coffee."
	color = "#F4A460"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	drink_icon = "pumpkin_latte"
	drink_name = "Pumpkin Latte"
	drink_desc = "A mix of coffee and pumpkin juice."
	taste_description = "overpriced hipster spices"

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
	color = "#E6CDFF"
	drink_name = "Grape Soda"
	drink_desc = "Made with real grapes! Shocking!"
	taste_description = "grape soda"

/datum/reagent/consumable/drink/coco/icecoco
	name = "Iced Cocoa"
	id = "icecoco"
	description = "Hot cocoa and ice, refreshing and cool."
	color = "#102838" // rgb: 16, 40, 56
	drink_icon = "icedcoffeeglass"
	drink_name = "Iced Cocoa"
	drink_desc = "A sweeter drink to perk you up and refresh you!"
	taste_description = "refreshingly cold cocoa"

/datum/reagent/consumable/drink/tonic
	name = "Tonic Water"
	id = "tonic"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#664300" // rgb: 102, 67, 0
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
	color = "#619494" // rgb: 97, 148, 148
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
	reagent_state = LIQUID
	color = "#100800" // rgb: 16, 8, 0
	adj_drowsy = -10 SECONDS
	drink_icon = "glass_brown"
	drink_name = "Glass of Space Cola"
	drink_desc = "A glass of refreshing Space Cola."
	taste_description = "cola"

/datum/reagent/consumable/drink/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	adj_sleepy = -4 SECONDS
	drink_icon = "nuka_colaglass"
	drink_name = "Nuka Cola"
	drink_desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland."
	harmless = FALSE
	taste_description = "radioactive cola"

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
	color = "#102000" // rgb: 16, 32, 0
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
	color = "#102000" // rgb: 16, 32, 0
	adj_drowsy = -12 SECONDS
	drink_icon = "dr_gibb_glass"
	drink_name = "Glass of Dr. Gibb"
	drink_desc = "Dr. Gibb. Not as dangerous as the name might imply."
	taste_description = "cherry soda"

/datum/reagent/consumable/drink/space_up
	name = "Space-Up"
	id = "space_up"
	description = "Tastes like a hull breach in your mouth."
	color = "#C7DF67"
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

/datum/reagent/consumable/drink/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	id = "kiraspecial"
	color = "#CCCC99" // rgb: 204, 204, 153
	drink_icon = "kiraspecial"
	drink_name = "Kira Special"
	drink_desc = "Long live the guy who everyone had mistaken for a girl. Baka!"
	taste_description = "citrus soda"

/datum/reagent/consumable/drink/brownstar
	name = "Brown Star"
	description = "It's not what it sounds like..."
	id = "brownstar"
	color = "#9F3400" // rgb: 159, 052, 000
	drink_icon = "brownstar"
	drink_name = "Brown Star"
	drink_desc = "Its not what it sounds like..."
	taste_description = "orange soda"

/datum/reagent/consumable/drink/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	id = "milkshake"
	color = "#AEE5E4" // rgb" 174, 229, 228
	drink_icon = "milkshake"
	drink_name = "Milkshake"
	drink_desc = "Glorious brainfreezing mixture."
	taste_description = "milkshake"

/datum/reagent/consumable/drink/rewriter
	name = "Rewriter"
	description = "The secret of the sanctuary of the Librarian..."
	id = "rewriter"
	color = "#485000" // rgb:72, 080, 0
	drink_icon = "rewriter"
	drink_name = "Rewriter"
	drink_desc = "The secret of the sanctuary of the Librarian..."
	taste_description = "coffee...soda?"

/datum/reagent/consumable/drink/rewriter/on_mob_life(mob/living/M)
	M.Jitter(10 SECONDS)
	return ..()

/datum/reagent/consumable/drink/arnold_palmer
	name = "Arnold Palmer"
	id = "arnold_palmer"
	description = "A wholesome mixture of lemonade and iced tea."
	color = "#8B5427" // rgb: 139, 84, 39
	drink_icon = "arnoldpalmer"
	drink_name = "Arnold Palmer"
	drink_desc = "A wholesome mixture of lemonade and iced tea... looks like somebody didn't stir this one very well."
	taste_description = "sweet and fizzy"

/datum/reagent/consumable/drink/fyrsskar_tears
	name = "Tears of Fyrsskar"
	id = "fyrsskartears"
	description = "Plasmonic based drink that was consumed by ancient inhabitants of Skrellian homeworld."
	color = "#C300AE" // rgb: 195, 0, 174
	drink_icon = "fyrsskartears"
	drink_name = "Tears of Fyrsskar"
	drink_desc = "Plasmonic based drink that was consumed by ancient inhabitants of Skrellian homeworld."
	taste_description = "plasma"
	var/alcohol_perc = 0.05
	var/dizzy_adj = 6 SECONDS

/datum/reagent/consumable/drink/fyrsskar_tears/on_mob_add(mob/living/M)
	if(isskrell(M))
		ADD_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE, id)

/datum/reagent/consumable/drink/fyrsskar_tears/on_mob_life(mob/living/M)
	if(!isskrell(M))
		return ..()
	// imitate alcohol effects using current cycle
	M.AdjustDrunk(alcohol_perc STATUS_EFFECT_CONSTANT)
	M.AdjustDizzy(dizzy_adj, bound_upper = 1.5 MINUTES)
	return ..()

/datum/reagent/consumable/drink/fyrsskar_tears/on_mob_delete(mob/living/M)
	if(isskrell(M))
		REMOVE_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE, id)

/datum/reagent/consumable/drink/lean
	name = "Lean"
	id = "lean"
	description = "Also known as Purple Drank."
	color = "#f249d6"
	drink_icon = "lean"
	drink_name = "Lean"
	drink_desc = "Also known as Purple Drank."
	taste_description = "sweet druggy soda"
