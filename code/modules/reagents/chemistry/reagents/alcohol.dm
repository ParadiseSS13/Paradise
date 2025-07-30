//ALCOHOL WOO
/datum/reagent/consumable/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	reagent_state = LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" // rgb: 64, 64, 48
	var/dizzy_adj = 6 SECONDS
	var/alcohol_perc = 1 //percentage of ethanol in a beverage 0.0 - 1.0
	taste_description = "liquid fire"
	goal_department = "Bar"

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/M)
	M.AdjustDrunk(alcohol_perc STATUS_EFFECT_CONSTANT)
	M.AdjustDizzy(dizzy_adj, bound_upper = 1.5 MINUTES)
	return ..()

/datum/reagent/consumable/ethanol/reaction_obj(obj/O, volume)
	if(istype(O,/obj/item/paper))
		var/obj/item/paper/paperaffected = O
		paperaffected.clearpaper()
		paperaffected.visible_message("<span class='notice'>The solution melts away the ink on the paper.</span>")
	if(istype(O,/obj/item/book))
		if(volume >= 5)
			var/obj/item/book/affectedbook = O
			for(var/page in affectedbook.pages)
				affectedbook.pages[page] = " " //we're blanking the pages not making em null
			affectedbook.visible_message("<span class='notice'>The solution melts away the ink on the book.</span>")
		else
			O.visible_message("<span class='warning'>It wasn't enough...</span>")

/datum/reagent/consumable/ethanol/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(method == REAGENT_TOUCH)
		M.adjust_fire_stacks(volume / 15)


/datum/reagent/consumable/ethanol/beer
	name = "Beer"
	id = "beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon ="beerglass"
	drink_name = "Beer glass"
	drink_desc = "A freezing pint of beer."
	taste_description = "beer"

/datum/reagent/consumable/ethanol/cider
	name = "Cider"
	id = "cider"
	description = "An alcoholic beverage derived from apples."
	color = "#174116"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "rewriter"
	drink_name = "Cider"
	drink_desc = "A refreshing glass of traditional cider."
	taste_description = "cider"

/datum/reagent/consumable/ethanol/whiskey
	name = "Whiskey"
	id = "whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.4
	drink_icon = "whiskeyglass"
	drink_name = "Glass of whiskey"
	drink_desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
	taste_description = "whiskey"

/datum/reagent/consumable/ethanol/specialwhiskey
	name = "Special Blend Whiskey"
	id = "specialwhiskey"
	description = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	taste_description = "class"

/datum/reagent/consumable/ethanol/gin
	name = "Gin"
	id = "gin"
	description = "It's gin. In space. I say, good sir."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "ginvodkaglass"
	drink_name = "Glass of gin"
	drink_desc = "A crystal clear glass of Griffeater gin."
	taste_description = "gin"

/datum/reagent/consumable/ethanol/absinthe
	name = "Absinthe"
	id = "absinthe"
	description = "Watch out that the Green Fairy doesn't come for you!"
	color = "#33EE00" // rgb: lots, ??, ??
	overdose_threshold = 30
	dizzy_adj = 10 SECONDS
	alcohol_perc = 0.7
	drink_icon = "absinthebottle"
	drink_name = "Glass of Absinthe"
	drink_desc = "The green fairy is going to get you now!"
	taste_description = "fucking pain"
	allowed_overdose_process = TRUE

//copy paste from LSD... shoot me
/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/M)
	M.AdjustHallucinate(5 SECONDS)
	return ..()

/datum/reagent/consumable/ethanol/absinthe/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/ethanol/hooch
	name = "Hooch"
	id = "hooch"
	description = "Either someone's failure at cocktail making or attempt in alcohol production. In any case, do you really want to drink that?"
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 14 SECONDS
	drink_icon = "glass_brown2"
	drink_name = "Hooch"
	drink_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
	taste_description = "pure resignation"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/hooch/on_mob_life(mob/living/carbon/M)
	if(M.mind && M.mind.assigned_role == "Assistant")
		M.heal_organ_damage(1, 1)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/rum
	name = "Rum"
	id = "rum"
	description = "Popular with the sailors. Not very popular with everyone else."
	color = "#664300" // rgb: 102, 67, 0
	overdose_threshold = 30
	alcohol_perc = 0.4
	dizzy_adj = 10 SECONDS
	drink_icon = "rumglass"
	drink_name = "Glass of Rum"
	drink_desc = "Now you want to Pray for a pirate suit, don't you?"
	taste_description = "rum"
	allowed_overdose_process = TRUE

/datum/reagent/consumable/ethanol/rum/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/ethanol/mojito
	name = "Mojito"
	id = "mojito"
	description = "If it's good enough for Spesscuba, it's good enough for you."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "mojito"
	drink_name = "Glass of Mojito"
	drink_desc = "Fresh from Spesscuba."
	taste_description = "mojito"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/vodka
	name = "Vodka"
	id = "vodka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "ginvodkaglass"
	drink_name = "Glass of vodka"
	drink_desc = "The glass contain wodka. Xynta."
	taste_description = "vodka"

/datum/reagent/consumable/ethanol/sake
	name = "Sake"
	id = "sake"
	description = "Anime's favorite drink."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "sake"
	drink_name = "Glass of Sake"
	drink_desc = "A glass of Sake."
	taste_description = "sake"

/datum/reagent/consumable/ethanol/tequila
	name = "Tequila"
	id = "tequila"
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
	color = "#A8B0B7" // rgb: 168, 176, 183
	alcohol_perc = 0.4
	drink_icon = "tequilaglass"
	drink_name = "Glass of Tequila"
	drink_desc = "Now all that's missing is the weird colored shades!"
	taste_description = "tequila"

/datum/reagent/consumable/ethanol/vermouth
	name = "Vermouth"
	id = "vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "vermouthglass"
	drink_name = "Glass of Vermouth"
	drink_desc = "You wonder why you're even drinking this straight."
	taste_description = "vermouth"

/datum/reagent/consumable/ethanol/wine
	name = "Wine"
	id = "wine"
	description = "An premium alchoholic beverage made from distilled grape juice."
	color = "#7E4043" // rgb: 126, 64, 67
	dizzy_adj = 4 SECONDS
	alcohol_perc = 0.2
	drink_icon = "wineglass"
	drink_name = "Glass of wine"
	drink_desc = "A very classy looking drink."
	taste_description = "wine"

/datum/reagent/consumable/ethanol/cognac
	name = "Cognac"
	id = "cognac"
	description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.4
	drink_icon = "cognacglass"
	drink_name = "Glass of cognac"
	drink_desc = "Damn, you feel like some kind of French aristocrat just by holding this."
	taste_description = "cognac"

/// otherwise known as "I want to get so smashed my liver gives out and I die from alcohol poisoning".
/datum/reagent/consumable/ethanol/suicider
	name = "Suicider"
	id = "suicider"
	description = "An unbelievably strong and potent variety of Cider."
	color = "#CF3811"
	dizzy_adj = 40 SECONDS
	drink_icon = "suicider"
	drink_name = "Suicider"
	drink_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
	taste_description = "approaching death"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/ale
	name = "Ale"
	id = "ale"
	description = "A dark alchoholic beverage made by malted barley and yeast."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.1
	drink_icon = "aleglass"
	drink_name = "Ale glass"
	drink_desc = "A freezing pint of delicious Ale."
	taste_description = "ale"

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Thirteen Loko"
	id = "thirteenloko"
	description = "A potent mixture of caffeine and alcohol."
	color = "#102000" // rgb: 16, 32, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.3
	heart_rate_increase = 1
	drink_icon = "thirteen_loko_glass"
	drink_name = "Glass of Thirteen Loko"
	drink_desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass"
	taste_description = "party"

/datum/reagent/consumable/ethanol/thirteenloko/on_mob_life(mob/living/M)
	M.AdjustDrowsy(-14 SECONDS)
	M.AdjustSleeping(-4 SECONDS)
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(10 SECONDS)
	return ..()


/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////

/datum/reagent/consumable/ethanol/bilk
	name = "Bilk"
	id = "bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	color = "#895C4C" // rgb: 137, 92, 76
	nutriment_factor = 2 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "glass_brown"
	drink_name = "Glass of bilk"
	drink_desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."
	taste_description = "bilk"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	description = "Nuclear proliferation never tasted so good."
	color = "#666300" // rgb: 102, 99, 0
	alcohol_perc = 0.2
	drink_icon = "atomicbombglass"
	drink_name = "Atomic Bomb"
	drink_desc = "Nanotrasen cannot take legal responsibility for your actions after imbibing."
	taste_description = "a long, fiery burn"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/ethanol/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	description = "Made for a woman, strong enough for a man."
	color = "#666340" // rgb: 102, 99, 64
	alcohol_perc = 0.2
	drink_icon = "threemileislandglass"
	drink_name = "Three Mile Island Ice Tea"
	drink_desc = "A glass of this is sure to prevent a meltdown."
	taste_description = "a creeping heat"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/ethanol/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "ginvodkaglass"
	drink_name = "Glass of goldschlager"
	drink_desc = "100 proof that teen girls will drink anything with gold in it."
	taste_description = "a deep, spicy warmth"

/datum/reagent/consumable/ethanol/patron
	name = "Patron"
	id = "patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	color = "#585840" // rgb: 88, 88, 64
	alcohol_perc = 0.4
	drink_icon = "patronglass"
	drink_name = "Glass of Patron"
	drink_desc = "Drinking patron in the bar, with all the subpar ladies."
	taste_description = "a gift"

/datum/reagent/consumable/ethanol/gintonic
	name = "Gin and Tonic"
	id = "gintonic"
	description = "An all time classic, mild cocktail."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "gintonicglass"
	drink_name = "Gin and Tonic"
	drink_desc = "A mild but still great cocktail. Drink up, like a true Englishman."
	taste_description = "bitter medicine"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	description = "Rum, mixed with cola. Viva la revolution."
	color = "#3E1B00" // rgb: 62, 27, 0
	alcohol_perc = 0.2
	drink_icon = "cubalibreglass"
	drink_name = "Cuba Libre"
	drink_desc = "A classic mix of rum and cola."
	taste_description = "liberation"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	color = "#3E1B00" // rgb: 62, 27, 0
	alcohol_perc = 0.3
	drink_icon = "whiskeycolaglass"
	drink_name = "Whiskey Cola"
	drink_desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
	taste_description = "whiskey and coke"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/daiquiri
	name = "Daiquiri"
	id = "daiquiri"
	description = "Lime juice and sugar mixed with rum. A sweet and refreshing mix."
	color = "#61d961" // rgb: 38, 85, 38
	alcohol_perc = 0.4
	drink_icon = "daiquiriglass"
	drink_name = "Daiquiri"
	drink_desc = "When Botany gives you limes, make daiquiris."
	taste_description = "sweetened lime juice and rum"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/martini
	name = "Classic Martini"
	id = "martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "martiniglass"
	drink_name = "Classic Martini"
	drink_desc = "Damn, the bartender even stirred it, not shook it."
	taste_description = "class"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "martiniglass"
	drink_name = "Vodka martini"
	drink_desc ="A bastardisation of the classic martini. Still great."
	taste_description = "class and potatoes"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/white_russian
	name = "White Russian"
	id = "whiterussian"
	description = "That's just, like, your opinion, man..."
	color = "#A68340" // rgb: 166, 131, 64
	alcohol_perc = 0.3
	drink_icon = "whiterussianglass"
	drink_name = "White Russian"
	drink_desc = "A very nice looking drink. But that's just, like, your opinion, man."
	taste_description = "very creamy alcohol"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Screwdriver"
	id = "screwdrivercocktail"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.3
	drink_icon = "screwdriverglass"
	drink_name = "Screwdriver"
	drink_desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
	taste_description = "a naughty secret"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/booger
	name = "Booger"
	id = "booger"
	description = "Eww..."
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.2
	drink_icon = "booger"
	drink_name = "Booger"
	drink_desc = "Eww..."
	taste_description = "a fruity mess"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "bloodymaryglass"
	drink_name = "Bloody Mary"
	drink_desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."
	taste_description = "tomatoes with booze"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	description = "Whoah, this stuff looks volatile!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.7 //ouch
	drink_icon = "gargleblasterglass"
	drink_name = "Pan-Galactic Gargle Blaster"
	drink_desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."
	taste_description = "the number fourty two"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/flaming_homer
	name = "Flaming Moe"
	id = "flamingmoe"
	description = "This appears to be a mixture of various alcohols blended with prescription medicine. It is lightly toasted..."
	color = "#58447f" //rgb: 88, 66, 127
	alcohol_perc = 0.5
	drink_icon = "flamingmoeglass"
	drink_name = "Flaming Moe"
	drink_desc = "Happiness is just a Flaming Moe away!"
	taste_description = "caramelised booze and sweet, salty medicine"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "bravebullglass"
	drink_name = "Brave Bull"
	drink_desc = "Tequila and Coffee liquor, brought together in a mouthwatering mixture. Drink up."
	taste_description = "sweet alcohol"

/datum/reagent/consumable/ethanol/tequila_sunrise
	name = "Tequila Sunrise"
	id = "tequilasunrise"
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "tequilasunriseglass"
	drink_name = "Tequila Sunrise"
	drink_desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."
	taste_description = "fruity alcohol"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/toxins_special
	name = "Toxins Special"
	id = "toxinsspecial"
	description = "This thing is FLAMING!. CALL THE DAMN SHUTTLE!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "toxinsspecialglass"
	drink_name = "Toxins Special"
	drink_desc = "Whoah, this thing is on FIRE!"
	taste_description = "FIRE"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/toxins_special/on_mob_life(mob/living/M)
	if(M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Beepsky Smash"
	id = "beepskysmash"
	description = "Deny drinking this and prepare for THE LAW."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "beepskysmashglass"
	drink_name = "Beepsky Smash"
	drink_desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."
	taste_description = "THE LAW"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	description = "Whiskey-imbued cream, what else would you expect from the Irish."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "irishcreamglass"
	drink_name = "Irish Cream"
	drink_desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
	taste_description = "creamy alcohol"

/datum/reagent/consumable/ethanol/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "manlydorfglass"
	drink_name = "The Manly Dorf"
	drink_desc = "A manly concotion made from Ale and Beer. Intended for true men only."
	taste_description = "manliness"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "longislandicedteaglass"
	drink_name = "Long Island Iced Tea"
	drink_desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	taste_description = "fruity alcohol"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/moonshine
	name = "Moonshine"
	id = "moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.8 //yeeehaw
	drink_icon = "glass_clear"
	drink_name = "Moonshine"
	drink_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
	taste_description = "prohibition"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	id = "b52"
	description = "Coffee, Irish Cream, and congac. You will get bombed."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "b52glass"
	drink_name = "B-52"
	drink_desc = "Kahlua, Irish Cream, and congac. You will get bombed."
	taste_description = "destruction"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Irish Coffee"
	id = "irishcoffee"
	description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "irishcoffeeglass"
	drink_name = "Irish Coffee"
	drink_desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
	taste_description = "coffee and booze"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/margarita
	name = "Margarita"
	id = "margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "margaritaglass"
	drink_name = "Margarita"
	drink_desc = "On the rocks with salt on the rim. Arriba~!"
	taste_description = "daisies"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/black_russian
	name = "Black Russian"
	id = "blackrussian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	color = "#360000" // rgb: 54, 0, 0
	alcohol_perc = 0.4
	drink_icon = "blackrussianglass"
	drink_name = "Black Russian"
	drink_desc = "For the lactose-intolerant. Still as classy as a White Russian."
	taste_description = "sweet alcohol"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/manhattan
	name = "Manhattan"
	id = "manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "manhattanglass"
	drink_name = "Manhattan"
	drink_desc = "The Detective's undercover drink of choice. He never could stomach gin..."
	taste_description = "a bustling city"

/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	description = "A scientist's drink of choice, for pondering ways to blow up the station."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "proj_manhattanglass"
	drink_name = "Manhattan Project"
	drink_desc = "A scientist's drink of choice, for thinking how to blow up the station."
	taste_description = "the apocalypse"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	description = "Ultimate refreshment."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "whiskeysodaglass2"
	drink_name = "Whiskey Soda"
	drink_desc = "Ultimate refreshment."
	taste_description = "mediocrity"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	description = "Ultimate refreshment."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "antifreeze"
	drink_name = "Anti-freeze"
	drink_desc = "The ultimate refreshment."
	taste_description = "poor life choices"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/antifreeze/on_mob_life(mob/living/M)
	if(M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/adminfreeze
	name = "Admin Freeze"
	id = "adminfreeze"
	description = "Ultimate Punishment."
	color = "#30F0FF" // rgb: 048, 240, 255
	dizzy_adj = 8 SECONDS
	alcohol_perc = 1.5 // oof
	drink_icon = "adminfreeze"
	drink_name = "Admin Freeze"
	drink_desc = "The ultimate punishment."
	taste_description = "a series of bad decisions"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/ethanol/adminfreeze/reaction_mob(mob/living/M, method = REAGENT_INGEST, volume)
	..()
	if(method == REAGENT_INGEST)
		M.apply_status_effect(/datum/status_effect/freon/watcher)
		M.adjust_bodytemperature(-110)

/datum/reagent/consumable/ethanol/barefoot
	name = "Barefoot"
	id = "barefoot"
	description = "Barefoot and pregnant"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "b&p"
	drink_name = "Barefoot"
	drink_desc = "Barefoot and pregnant."
	taste_description = "pregnancy"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/snowwhite
	name = "Snow White"
	id = "snowwhite"
	description = "A cold refreshment"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "snowwhite"
	drink_name = "Snow White"
	drink_desc = "A cold refreshment."
	taste_description = "a poisoned apple"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	description = "AHHHH!!!!"
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 20 SECONDS
	alcohol_perc = 0.4
	drink_icon = "demonsblood"
	drink_name = "Demons Blood"
	drink_desc = "Just looking at this thing makes the hair at the back of your neck stand up."
	taste_description = "<span class='warning'>evil</span>"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	description = "For when a gin and tonic isn't russian enough."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.3
	drink_icon = "vodkatonicglass"
	drink_name = "Vodka and Tonic"
	drink_desc = "For when a gin and tonic isn't russian enough."
	taste_description = "bitter medicine"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/ginfizz
	name = "Gin Fizz"
	id = "ginfizz"
	description = "Refreshingly lemony, deliciously dry."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.4
	drink_icon = "ginfizzglass"
	drink_name = "Gin Fizz"
	drink_desc = "Refreshingly lemony, deliciously dry."
	taste_description = "fizzy alcohol"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	description = "Tropic cocktail."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "bahama_mama"
	drink_name = "Bahama Mama"
	drink_desc = "Tropic cocktail."
	taste_description = "HONK"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/singulo
	name = "Singulo"
	id = "singulo"
	description = "The edge of eternity, contained in a glass."
	color = "#2E6671" // rgb: 46, 102, 113
	dizzy_adj = 30 SECONDS
	alcohol_perc = 0.7
	drink_icon = "singulo"
	drink_name = "Singulo"
	drink_desc = "The edge of eternity, contained in a glass."
	taste_description = "infinity"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/sbiten
	name = "Sbiten"
	id = "sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "sbitenglass"
	drink_name = "Sbiten"
	drink_desc = "A spicy mix of Vodka and Spice. Very hot."
	taste_description = "comforting warmth"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/sbiten/on_mob_life(mob/living/M)
	if(M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	description = "Creepy time!"
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.3
	drink_icon = "devilskiss"
	drink_name = "Devils Kiss"
	drink_desc = "Creepy time!"
	taste_description = "naughtiness"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/red_mead
	name = "Red Mead"
	id = "red_mead"
	description = "The true Viking drink! Even though it has a strange red color."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "red_meadglass"
	drink_name = "Red Mead"
	drink_desc = "A True Vikings Beverage, though its color is strange."
	taste_description = "blood"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/ethanol/mead
	name = "Mead"
	id = "mead"
	description = "A Vikings drink, though a cheap one."
	color = "#664300" // rgb: 102, 67, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "meadglass"
	drink_name = "Mead"
	drink_desc = "A Vikings Beverage, though a cheap one."
	taste_description = "honey"

/datum/reagent/consumable/ethanol/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	description = "A beer which is so cold the air around it freezes."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "iced_beerglass"
	drink_name = "Iced Beer"
	drink_desc = "A beer so frosty, the air around it freezes."
	taste_description = "cold beer"

/datum/reagent/consumable/ethanol/iced_beer/on_mob_life(mob/living/M)
	if(M.bodytemperature > 270)
		M.bodytemperature = max(270, M.bodytemperature - (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/grog
	name = "Grog"
	id = "grog"
	description = "Watered down rum, Nanotrasen approves!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "grogglass"
	drink_name = "Grog"
	drink_desc = "A fine and cepa drink for Space."
	taste_description = "strongly diluted rum"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/aloe
	name = "Aloe"
	id = "aloe"
	description = "So very, very, very good."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "aloe"
	drink_name = "Aloe"
	drink_desc = "Very, very, very good."
	taste_description = "healthy skin"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/andalusia
	name = "Andalusia"
	id = "andalusia"
	description = "A nice, strange named drink."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "andalusia"
	drink_name = "Andalusia"
	drink_desc = "A nice, strange named drink."
	taste_description = "sweet alcohol"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	description = "A drink made from your allies."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "alliescocktail"
	drink_name = "Allies cocktail"
	drink_desc = "A drink made from your allies."
	taste_description = "victory"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/acid_spit
	name = "Acid Spit"
	id = "acidspit"
	description = "A drink by Nanotrasen. Made from live aliens."
	color = "#365000" // rgb: 54, 80, 0
	alcohol_perc = 0.3
	drink_icon = "acidspitglass"
	drink_name = "Acid Spit"
	drink_desc = "A drink from Nanotrasen. Made from live aliens."
	taste_description = "PAIN"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/amasec
	name = "Amasec"
	id = "amasec"
	description = "Official drink of the Imperium."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "amasecglass"
	drink_name = "Amasec"
	drink_desc = "Always handy before COMBAT!!!"
	taste_description = "a stunbaton"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/neurotoxin
	name = "Neuro-toxin"
	id = "neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#2E2E61" // rgb: 46, 46, 97
	dizzy_adj = 12 SECONDS
	alcohol_perc = 0.7
	heart_rate_decrease = 1
	drink_icon = "neurotoxinglass"
	drink_name = "Neurotoxin"
	drink_desc = "A drink that is guaranteed to knock you silly."
	taste_description = "brain damageeeEEeee"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle >= 13)
		M.Weaken(6 SECONDS)
	if(current_cycle >= 55)
		M.Druggy(110 SECONDS)
	if(current_cycle >= 200)
		update_flags |= M.adjustToxLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/hippies_delight
	name = "Hippie's Delight"
	id = "hippiesdelight"
	description = "You just don't get it maaaan."
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	drink_icon = "hippiesdelightglass"
	drink_name = "Hippie's Delight"
	drink_desc = "A drink enjoyed by people during the 1960's."
	taste_description = "colors"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/ethanol/hippies_delight/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(100 SECONDS)
	switch(current_cycle)
		if(1 to 5)
			M.Stuttering(2 SECONDS)
			M.Dizzy(20 SECONDS)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Stuttering(2 SECONDS)
			M.Jitter(40 SECONDS)
			M.Dizzy(40 SECONDS)
			M.Druggy(90 SECONDS)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			M.Stuttering(2 SECONDS)
			M.Jitter(80 SECONDS)
			M.Dizzy(80 SECONDS)
			M.Druggy(120 SECONDS)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	return ..() | update_flags

/datum/reagent/consumable/ethanol/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "A stingy drink."
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.7
	dizzy_adj = 10 SECONDS
	drink_icon = "changelingsting"
	drink_name = "Changeling Sting"
	drink_desc = "A stingy drink."
	taste_description = "a tiny prick"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/dublindrop
	name = "Dublin Drop"
	id = "dublindrop"
	description = "Mmm, tastes like chocolate cake..."
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.3
	dizzy_adj = 10 SECONDS
	drink_icon = "dublindrop"
	drink_name = "Dublin Drop"
	drink_desc = "A Dublin drop. Pub legends say one of the ingredients can bring back the dead."
	taste_description = "a belt in the gob"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	description = "A Syndicate bomb"
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "syndicatebomb"
	drink_name = "Syndicate Bomb"
	drink_desc = "A syndicate bomb."
	taste_description = "a job offer"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	description = "The surprise is, it's green!"
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "erikasurprise"
	drink_name = "Erika Surprise"
	drink_desc = "The surprise is, it's green!"
	taste_description = "disappointment"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.5
	dizzy_adj = 20 SECONDS
	drink_icon = "driestmartiniglass"
	drink_name = "Driest Martini"
	drink_desc = "Only for the experienced. You think you see sand floating in the glass."
	taste_description = "dust and ashes"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/driestmartini/on_mob_life(mob/living/M)
	if(current_cycle >= 55 && current_cycle < 115)
		M.AdjustStuttering(20 SECONDS)
	return ..()

/datum/reagent/consumable/ethanol/kahlua
	name = "Kahlua"
	id = "kahlua"
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "kahluaglass"
	drink_name = "Glass of RR coffee Liquor"
	drink_desc = "DAMN, THIS THING LOOKS ROBUST!"
	taste_description = "coffee and alcohol"

/datum/reagent/consumable/ethanol/kahlua/on_mob_life(mob/living/M)
	M.AdjustDizzy(-10 SECONDS)
	M.AdjustDrowsy(-6 SECONDS)
	M.AdjustSleeping(-4 SECONDS)
	M.Jitter(10 SECONDS)
	return ..()

/datum/reagent/ginsonic
	name = "Gin and sonic"
	id = "ginsonic"
	description = "GOTTA GET CRUNK FAST BUT LIQUOR TOO SLOW"
	reagent_state = LIQUID
	color = "#1111CF"
	drink_icon = "ginsonic"
	drink_name = "Gin and Sonic"
	drink_desc = "An extremely high amperage drink. Absolutely not for the true Englishman."
	taste_description = "SPEED"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/ginsonic/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-10 SECONDS)
	if(prob(25))
		M.AdjustParalysis(-2 SECONDS)
		M.AdjustStunned(-2 SECONDS)
		M.AdjustWeakened(-2 SECONDS)
		M.AdjustKnockDown(-2 SECONDS)
	if(prob(8))
		M.reagents.add_reagent("methamphetamine",1.2)
		var/sonic_message = pick("Gotta go fast!", "Time to speed, keed!", "I feel a need for speed!", "Let's juice.", "Juice time.", "Way Past Cool!")
		if(prob(50))
			M.say("[sonic_message]")
		else
			to_chat(M, "<span class='notice'>[sonic_message ]</span>")
	return ..() | update_flags

/datum/reagent/consumable/ethanol/applejack
	name = "Applejack"
	id = "applejack"
	description = "A highly concentrated alcoholic beverage made by repeatedly freezing cider and removing the ice."
	color = "#997A00"
	alcohol_perc = 0.4
	drink_icon = "cognacglass"
	drink_name = "Glass of applejack"
	drink_desc = "When cider isn't strong enough, you gotta jack it."
	taste_description = "strong cider"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/jackrose
	name = "Jack Rose"
	id = "jackrose"
	description = "A classic cocktail that had fallen out of fashion, but never out of taste,"
	color = "#664300"
	alcohol_perc = 0.4
	drink_icon = "patronglass"
	drink_name = "Jack Rose"
	drink_desc = "Drinking this makes you feel like you belong in a luxury hotel bar during the 1920s."
	taste_description = "style"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/drunkenblumpkin
	name = "Drunken Blumpkin"
	id = "drunkenblumpkin"
	description = "A weird mix of whiskey and blumpkin juice."
	color = "#1EA0FF" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "drunkenblumpkin"
	drink_name = "Drunken Blumpkin"
	drink_desc = "A drink for the drunks."
	taste_description = "weirdness"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/eggnog
	name = "Eggnog"
	id = "eggnog"
	description = "For enjoying the most wonderful time of the year."
	color = "#fcfdc6" // rgb: 252, 253, 198
	nutriment_factor = 2 * REAGENTS_METABOLISM
	alcohol_perc = 0.1
	drink_icon = "glass_yellow"
	drink_name = "Eggnog"
	drink_desc = "For enjoying the most wonderful time of the year."
	taste_description = "christmas spirit"
	goal_difficulty = REAGENT_GOAL_HARD

/// inaccessible to players, but here for admin shennanigans
/datum/reagent/consumable/ethanol/dragons_breath
	name = "Dragon's Breath"
	id = "dragonsbreath"
	description = "Possessing this stuff probably breaks the Geneva convention."
	color = "#DC0000"
	taste_description = "<span class='userdanger'>LIQUID FUCKING DEATH OH GOD WHAT THE FUCK</span>"

/datum/reagent/consumable/ethanol/dragons_breath/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST && prob(20))
		if(M.on_fire)
			M.adjust_fire_stacks(6)

/datum/reagent/consumable/ethanol/dragons_breath/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(M.reagents.has_reagent("milk"))
		to_chat(M, "<span class='notice'>The milk stops the burning. Ahhh.</span>")
		M.reagents.del_reagent("milk")
		M.reagents.del_reagent("dragonsbreath")
		return
	if(iswizard(M))
		M.reagents.del_reagent("dragonsbreath") //As funny as it is, let's not have new wizards dust themselfs.
		return
	if(prob(8))
		to_chat(M, "<span class='userdanger'>Oh god! Oh GODD!!</span>")
	if(prob(50))
		to_chat(M, "<span class='danger'>Your throat burns terribly!</span>")
		M.emote(pick("scream","cry","choke","gasp"))
		M.Stun(2 SECONDS, FALSE)
	if(prob(8))
		to_chat(M, "<span class='danger'>Why!? WHY!?</span>")
	if(prob(8))
		to_chat(M, "<span class='danger'>ARGHHHH!</span>")
	if(prob(2 * volume))
		to_chat(M, "<span class='userdanger'><b>OH GOD OH GOD PLEASE NO!!</b></span>")
		if(M.on_fire)
			M.adjust_fire_stacks(20)
		if(prob(50))
			to_chat(M, "<span class='userdanger'>IT BURNS!!!!</span>")
			M.visible_message("<span class='danger'>[M] is consumed in flames!</span>")
			M.dust()
			return
	return ..() | update_flags

// ROBOT ALCOHOL PAST THIS POINT
// WOOO!

/datum/reagent/consumable/ethanol/synthanol
	name = "Synthanol"
	id = "synthanol"
	description = "A runny liquid with conductive capacities. Its effects on synthetics are similar to those of alcohol on organics."
	color = "#1BB1FF"
	process_flags = ORGANIC | SYNTHETIC
	alcohol_perc = 0.5
	drink_icon = "synthanolglass"
	drink_name = "Glass of Synthanol"
	drink_desc = "The equivalent of alcohol for synthetic crewmembers. They'd find it awful if they had tastebuds too."
	taste_description = "motor oil"

/datum/reagent/consumable/ethanol/synthanol/on_mob_life(mob/living/M)
	metabolization_rate = REAGENTS_METABOLISM
	if(!(M.dna.species.reagent_tag & PROCESS_SYN))
		metabolization_rate += 3.6 //gets removed from organics very fast
		if(prob(25))
			metabolization_rate += 15
			M.fakevomit()
	return ..()

/datum/reagent/consumable/ethanol/synthanol/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(M.dna.species.reagent_tag & PROCESS_SYN)
		return
	if(method == REAGENT_INGEST)
		to_chat(M, pick("<span class = 'danger'>That was awful!</span>", "<span class = 'danger'>Yuck!</span>"))

/datum/reagent/consumable/ethanol/synthanol/robottears
	name = "Robot Tears"
	id = "robottears"
	description = "An oily substance that an IPC could technically consider a 'drink'."
	color = "#363636"
	alcohol_perc = 0.25
	drink_icon = "robottearsglass"
	drink_name = "Glass of Robot Tears"
	drink_desc = "No robots were hurt in the making of this drink."
	taste_description = "existential angst"

/datum/reagent/consumable/ethanol/synthanol/trinary
	name = "Trinary"
	id = "trinary"
	description = "A fruit drink meant only for synthetics, however that works."
	color = "#adb21f"
	alcohol_perc = 0.2
	drink_icon = "trinaryglass"
	drink_name = "Glass of Trinary"
	drink_desc = "Colorful drink made for synthetic crewmembers. It doesn't seem like it would taste well."
	taste_description = "modem static"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/synthanol/servo
	name = "Servo"
	id = "servo"
	description = "A drink containing some organic ingredients, but meant only for synthetics."
	color = "#5b3210"
	alcohol_perc = 0.25
	drink_icon = "servoglass"
	drink_name = "Glass of Servo"
	drink_desc = "Chocolate - based drink made for IPCs. Not sure if anyone's actually tried out the recipe."
	taste_description = "motor oil and cocoa"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/synthanol/uplink
	name = "Uplink"
	id = "uplink"
	description = "A potent mix of alcohol and synthanol. Will only work on synthetics."
	color = "#e7ae04"
	alcohol_perc = 0.15
	drink_icon = "uplinkglass"
	drink_name = "Glass of Uplink"
	drink_desc = "An exquisite mix of the finest liquoirs and synthanol. Meant only for synthetics."
	taste_description = "a GUI in visual basic"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/synthanol/synthnsoda
	name = "Synth 'n Soda"
	id = "synthnsoda"
	description = "The classic drink adjusted for a robot's tastes."
	color = "#7204e7"
	alcohol_perc = 0.25
	drink_icon = "synthnsodaglass"
	drink_name = "Glass of Synth 'n Soda"
	drink_desc = "Classic drink altered to fit the tastes of a robot. Bad idea to drink if you're made of carbon."
	taste_description = "fizzy motor oil"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/synthanol/synthignon
	name = "Synthignon"
	id = "synthignon"
	description = "Someone mixed wine and alcohol for robots. Hope you're proud of yourself."
	color = "#d004e7"
	alcohol_perc = 0.25
	drink_icon = "synthignonglass"
	drink_name = "Glass of Synthignon"
	drink_desc = "Someone mixed good wine and robot booze. Romantic, but atrocious."
	taste_description = "fancy motor oil"

/datum/reagent/consumable/ethanol/fruit_wine
	name = "Fruit Wine"
	id = "fruit_wine"
	description = "A wine made from grown plants."
	color = "#FFFFFF"
	alcohol_perc = 0.35
	taste_description = "bad coding"
	var/list/names = list("null fruit" = 1) //Names of the fruits used. Associative list where name is key, value is the percentage of that fruit.
	var/list/tastes = list("bad coding" = 1) //List of tastes. See above.

/datum/reagent/consumable/ethanol/fruit_wine/on_new(list/data)
	names = data["names"]
	tastes = data["tastes"]
	alcohol_perc = data["alcohol_perc"]
	color = data["color"]
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/on_merge(list/data, amount)
	var/diff = (amount/volume)
	if(diff < 1)
		color = BlendRGB(color, data["color"], diff/2) //The percentage difference over two, so that they take average if equal.
	else
		color = BlendRGB(color, data["color"], (1/diff)/2) //Adjust so it's always blending properly.
	var/oldvolume = volume-amount

	var/list/cachednames = data["names"]
	for(var/name in names | cachednames)
		names[name] = ((names[name] * oldvolume) + (cachednames[name] * amount)) / volume

	var/list/cachedtastes = data["tastes"]
	for(var/taste in tastes | cachedtastes)
		tastes[taste] = ((tastes[taste] * oldvolume) + (cachedtastes[taste] * amount)) / volume

	alcohol_perc *= oldvolume
	var/newzepwr = data["alcohol_perc"] * amount
	alcohol_perc += newzepwr
	alcohol_perc /= volume //Blending alcohol percentage to volume.
	generate_data_info(data)

#define MIN_WINE_PERCENT 0.15 //Percentages measured between 0 and 1.

/datum/reagent/consumable/ethanol/fruit_wine/proc/generate_data_info(list/data)
	var/list/primary_tastes = list()
	var/list/secondary_tastes = list()
	drink_name = "glass of [name]"
	drink_desc = description
	for(var/taste in tastes)
		switch(tastes[taste])
			if(MIN_WINE_PERCENT*2 to INFINITY)
				primary_tastes += taste
			if(MIN_WINE_PERCENT to MIN_WINE_PERCENT*2)
				secondary_tastes += taste

	var/minimum_name_percent = 0.35
	name = ""
	var/list/names_in_order = sortTim(names, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)
	var/named = FALSE
	for(var/fruit_name in names)
		if(names[fruit_name] >= minimum_name_percent)
			name += "[fruit_name] "
			named = TRUE
	if(named)
		name += "wine"
	else
		name = "mixed [names_in_order[1]] wine"

	var/alcohol_description
	switch(alcohol_perc)
		if(1.2 to INFINITY)
			alcohol_description = "suicidally strong"
		if(0.9 to 1.2)
			alcohol_description = "rather strong"
		if(0.7 to 0.9)
			alcohol_description = "strong"
		if(0.4 to 0.7)
			alcohol_description = "rich"
		if(0.2 to 0.4)
			alcohol_description = "mild"
		if(0 to 0.2)
			alcohol_description = "sweet"
		else
			alcohol_description = "watery" //How the hell did you get negative boozepwr?

	var/list/fruits = list()
	if(length(names_in_order) <= 3)
		fruits = names_in_order
	else
		for(var/i in 1 to 3)
			fruits += names_in_order[i]
		fruits += "other plants"
	var/fruit_list = english_list(fruits)
	description = "A [alcohol_description] wine brewed from [fruit_list]."

	var/flavor = ""
	if(!length(primary_tastes))
		primary_tastes = list("[alcohol_description] alcohol")
	flavor += english_list(primary_tastes)
	if(length(secondary_tastes))
		flavor += ", with a hint of "
		flavor += english_list(secondary_tastes)
	taste_description = flavor
	if(holder.my_atom)
		holder.my_atom.on_reagent_change()

#undef MIN_WINE_PERCENT

/// An EXTREMELY powerful drink. Smashed in seconds, dead in minutes.
/datum/reagent/consumable/ethanol/bacchus_blessing
	name = "Bacchus' Blessing"
	id = "bacchus_blessing"
	description = "Unidentifiable mixture. Unmeasurably high alcohol content."
	color = rgb(51, 19, 3) //Sickly brown
	dizzy_adj = 42 SECONDS
	alcohol_perc = 3 //I warned you
	drink_icon = "bacchusblessing"
	drink_name = "Bacchus' Blessing"
	drink_desc = "You didn't think it was possible for a liquid to be so utterly revolting. Are you sure about this...?"
	taste_description = "a wall of bricks"

/datum/reagent/consumable/ethanol/fernet
	name = "Fernet"
	id = "fernet"
	description = "An incredibly bitter herbal liqueur used as a digestif."
	color = "#1B2E24" // rgb: 27, 46, 36
	alcohol_perc = 0.5
	drink_icon = "fernetpuro"
	drink_name = "glass of pure fernet"
	drink_desc = "Why are you drinking this pure?"
	taste_description = "utter bitterness"
	var/remove_nutrition = 2

/datum/reagent/consumable/ethanol/fernet/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!M.nutrition)
		if(prob(66.66))
			to_chat(M, "<span class='warning'>You feel hungry...</span>")
		else if(prob(50))
			update_flags |= M.adjustToxLoss(1, FALSE)
			to_chat(M, "<span class='warning'>Your stomach grumbles painfully!</span>")
	else
		if(prob(60))
			M.adjust_nutrition(-remove_nutrition)
			M.overeatduration = 0
	return ..() | update_flags

/datum/reagent/consumable/ethanol/fernet/fernet_cola
	name = "Fernet Cola"
	id = "fernet_cola"
	description = "A very popular and bittersweet digestif, ideal after a heavy meal. Best served on a sawed-off cola bottle as per tradition."
	color = "#390600" // rgb: 57, 6, 0
	alcohol_perc = 0.2
	drink_icon = "fernetcola"
	drink_name = "glass of fernet cola"
	drink_desc = "A sawed-off cola bottle filled with Fernet Cola. You can hear cuarteto music coming from the inside."
	taste_description = "low class heaven"
	remove_nutrition = 1
	goal_difficulty = REAGENT_GOAL_EXCESSIVE

/datum/reagent/consumable/ethanol/gimlet
	name = "Gimlet"
	id = "gimlet"
	description = "A sharp cocktail dating back to the 19th century. Gin and lime, nothing else."
	color = "#DEF8AB" // rgb (222, 248, 171)
	alcohol_perc = 0.3
	drink_icon = "gimlet"
	drink_name = "Gimlet"
	drink_desc = "There are debates on whether this drink should be half gin and half lime, or three parts gin and one part lime. All you know is, it's alcohol."
	taste_description = "sharpness"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/sidecar
	name = "Sidecar"
	id = "sidecar"
	description = "A citrus cocktail of cognac, lemon and orange."
	color = "#D7A61E" // rgb (215, 166, 30)
	alcohol_perc = 0.4
	drink_icon = "sidecar"
	drink_name = "Sidecar"
	drink_desc = "You can smell the citrus from here!"
	taste_description = "smooth cognac and tart citrus"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/whiskey_sour
	name = "Whiskey Sour"
	id = "whiskeysour"
	description = "A tantalizing mixture of whiskey, sugar, lemon juice... and egg whites?"
	color = "#E4D629" // rgb (228, 214, 41)
	alcohol_perc = 0.6
	drink_icon = "whiskeysour"
	drink_name = "Whiskey Sour"
	drink_desc = "Lemon and whiskey, with a cute foamy head!"
	taste_description = "warm whiskey and sweetness"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/ethanol/mint_julep
	name = "Mint Julep"
	id = "mintjulep"
	description = "A refreshing, cold mix of whiskey and mint. Perfect for summer!"
	color = "#EAE2C8" // rgb (243, 226, 200)
	alcohol_perc = 0.4
	drink_icon = "mintjulep"
	drink_name = "Mint Julep"
	drink_desc = "A dainty glass of whiskey and mint on the rocks. Perfect for summer!"
	taste_description = "sweet and cooling mint"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/pina_colada
	name = "Pina Colada"
	id = "pinacolada"
	description = "Tropical deliciousness."
	color = "#F9D17D" // rgb (249, 209, 125)
	alcohol_perc = 0.4
	drink_icon = "pinacolada"
	drink_name = "Pina Colada"
	drink_desc = "After taking a sip, you feel contractually obligated to start singing a certain song of the same name."
	taste_description = "tart and tropical pineapple"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/bilkshake
	name = "Bilkshake"
	id = "bilkshake"
	description = "An upsetting treat that combines beer and milk."
	color = "#7B5835" // rgb: (123, 88, 53)
	nutriment_factor = 2 * REAGENTS_METABOLISM
	alcohol_perc = 0.1
	drink_icon = "bilkshake"
	drink_name = "Bilkshake"
	drink_desc = "Your mind bubbles and oozes as it tries to comprehend what it's seeing. What the HELL is this?"
	taste_description = "bilk, cream, and cold tears"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/sontse
	name = "Sontse"
	id = "sontse"
	description = "You see sun bobbing inside of this drink. How this is even possible?"
	color = "#DDB520" // rgb: 221, 181, 32
	alcohol_perc = 0.4
	drink_icon = "sontse"
	drink_name = "Sontse"
	drink_desc = "The Sun, The Sun, The Sun, The Sun, The Sun, THE SUN!"
	taste_description = "warmth and brightness"
	var/light_activated = FALSE
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/ethanol/sontse/on_mob_life(mob/living/M)
	if(current_cycle != 5 || !ismoth(M))
		return ..()
	to_chat(M, "<span class='warning'>The Sun was within you all this time!</span>")
	if(!light_activated)
		M.set_light(2)
		light_activated = TRUE
	return ..()

/datum/reagent/consumable/ethanol/sontse/on_mob_delete(mob/living/M)
	if(!ismoth(M))
		return ..()
	to_chat(M, "<span class='warning'>The Sun within you subsides.</span>")
	M.set_light(0)
	..()

/datum/reagent/consumable/ethanol/ahdomai_eclipse
	name = "Ahdomai's Eclipse"
	id = "ahdomaieclipse"
	description = "Blizzard in a glass. Tajaran signature drink!"
	color = "#DAE0E6" // rgb: 218, 224, 230
	alcohol_perc = 0.1
	drink_icon = "ahdomaieclipse"
	drink_name = "Ahdomai's Eclipse"
	drink_desc = "Blizzard in a glass. Tajaran signature drink!"
	taste_description = "ice"
	var/min_achievable_temp = 250
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/ahdomai_eclipse/on_mob_life(mob/living/M)
	. = ..()
	if(istajaran(M) && M.bodytemperature > min_achievable_temp)
		M.bodytemperature = max(min_achievable_temp, M.bodytemperature - (50 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/consumable/ethanol/beach_feast
	name = "Feast by the Beach"
	id = "beachfeast"
	description = "A classic Unathi drink. You can spot sand sediment at the bottom of the glass. The drink is hot as hell and more."
	color = "#E8E800" // rgb: 232, 232, 0
	alcohol_perc = 0.2
	drink_icon = "beachfeast"
	drink_name = "Feast by the Beach"
	drink_desc = "A classic Unathi drink. You can spot sand sediment at the bottom of the glass. The drink is hot as hell and more."
	taste_description = "sand"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/beach_feast/on_mob_life(mob/living/M)
	if(!isunathi(M))
		return ..()
	if(M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT))
	return ..()

/datum/reagent/consumable/ethanol/jungle_vox
	name = "Jungle Vox"
	id = "junglevox"
	description = "Classy drink in a glass vox head with a bit of liquid nitrogen added on."
	color = "#1ED1CE" // rgb: 30, 209, 206
	alcohol_perc = 0.2
	drink_icon = "junglevox"
	drink_name = "Jungle Vox"
	drink_desc = "Classy drink in a glass vox head with a bit of liquid nitrogen added on."
	taste_description = "bubbles"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/jungle_vox/on_mob_life(mob/living/M)
	if(current_cycle <= 5 || !isvox(M))
		return ..()
	if(M.health > 0)
		M.adjustOxyLoss(-1 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		M.AdjustLoseBreath(-2 SECONDS)
	return ..()

/datum/reagent/consumable/ethanol/slime_mold
	name = "Slime Mold"
	id = "slimemold"
	description = "You can swear that this jelly looks alive."
	color = "#C20458" // rgb: 194, 4, 88
	alcohol_perc = 0.2
	drink_icon = "slimemold"
	drink_name = "Slime Mold"
	drink_desc = "You can swear that this jelly looks alive."
	taste_description = "jelly"
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/ethanol/slime_mold/on_mob_life(mob/living/M)
	if(!isslimeperson(M))
		return ..()
	var/mob/living/carbon/human/H = M
	if(!(NO_BLOOD in H.dna.species.species_traits))
		if(H.blood_volume < BLOOD_VOLUME_NORMAL)
			H.blood_volume += REAGENTS_METABOLISM / 2 // half of the reagent is converted into blood, netting us just a little bit
	return ..()

/datum/reagent/consumable/ethanol/die_seife
	name = "Die Seife"
	id = "dieseife"
	description = "There is a piece of soap at the bottom of the glass and it is slowly melting."
	color = "#9D9E89" // rgb: 157, 158, 137
	alcohol_perc = 0.2
	drink_icon = "dieseife"
	drink_name = "Die Seife"
	drink_desc = "There is a piece of soap at the bottom of the glass and it is slowly melting."
	taste_description = "soap"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/die_seife/on_mob_life(mob/living/M)
	if(current_cycle % 10 != 0 || !isdrask(M))
		return ..()

	if(prob(50))
		to_chat(M, "<span class='warning'>Your skin emits a soapy liquid from its pores cleaning you in the process.</span>")
		M.clean_blood()
	return ..()

/datum/reagent/consumable/ethanol/acid_dreams
	name = "Acid Dreams"
	id = "aciddreams"
	description = "This one looks just weird and reeks of acid."
	color = "#B7FF6A" // rgb: 183, 255, 106
	alcohol_perc = 0.7
	drink_icon = "aciddreams"
	drink_name = "Acid Dreams"
	drink_desc = "This one looks just weird and reeks of acid."
	taste_description = "acid"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/acid_dreams/on_mob_life(mob/living/M)
	if(current_cycle % 10 != 0 || !isgrey(M))
		return ..()
	if(prob(50))
		var/list/mob/living/targets = list()
		for(var/mob/living/L in orange(14, M))
			if(L.stat == DEAD || !L.client) //we don't care about dead mobs
				continue
			targets += L
		if(length(targets))
			var/mob/living/target = pick(targets)
			to_chat(target, "<span class='warning'>You feel that [M.name] is somewhere near.</span>")
	return ..()

/datum/reagent/consumable/ethanol/islay_whiskey
	name = "Islay Whiskey"
	id = "islaywhiskey"
	description = "Named in honor of one of the most gritty and earth smelling types of Whiskey of Earth, this drink is a treat for any Diona."
	color = "#461300" // rgb: 70, 19, 0
	alcohol_perc = 0.2
	drink_icon = "islaywhiskey"
	drink_name = "Islay Whiskey"
	drink_desc = "Named in honor of one of the most gritty and earth smelling types of Whiskey of Earth, this drink is a treat for any Diona."
	taste_description = "soil"
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/islay_whiskey/on_mob_life(mob/living/M)
	if(current_cycle <=5 || !isdiona(M))
		return ..()

	var/mob/living/carbon/human/H = M
	var/turf/T = get_turf(H)
	var/light_amount = min(1, T.get_lumcount()) - 0.5

	if(light_amount > 0.2 && !H.suiciding && H.health > 0)
		H.adjustBruteLoss(-0.25)
		H.adjustToxLoss(-0.25)
		H.adjustOxyLoss(-0.25)
	return ..()

/datum/reagent/consumable/ethanol/ultramatter
	name = "Ultramatter"
	id = "ultramatter"
	description = "In the triangle of fire, this is apex of fuel."
	color = "#38004B" // rgb: 56, 0, 75
	alcohol_perc = 0.7
	drink_icon = "ultramatter"
	drink_name = "Ultramatter"
	drink_desc = "In the triangle of fire, this is apex of fuel."
	taste_description = "fire"
	var/on_fire = FALSE
	goal_difficulty = REAGENT_GOAL_HARD

/datum/reagent/consumable/ethanol/ultramatter/on_mob_life(mob/living/M)
	// species agnostic as it is DRINKS on_fire, so only plasmaman can get it
	if(on_fire)
		M.adjust_fire_stacks(-1)
		on_fire = FALSE

	if(current_cycle % 10 != 0 || !isplasmaman(M))
		return ..()

	if(prob(30))
		var/mob/living/carbon/human/H = M
		to_chat(M, "<span class='warning'>You expell flaming substance from within your suit.</span>")
		var/obj/item/clothing/under/plasmaman/suit = H.w_uniform
		if(suit)
			suit.next_extinguish = world.time + 10 SECONDS
		H.adjust_fire_stacks(1)
		H.IgniteMob()
		on_fire = TRUE

	return ..()

/datum/reagent/consumable/ethanol/howler
	name = "Howler"
	id = "howler"
	description = "Old classic human drink that was adopted by Vulpkanin."
	color = "#EC6400" // rgb: 236, 100, 0
	alcohol_perc = 0.2
	drink_icon = "howler"
	drink_name = "Howler"
	drink_desc = "Old classic human drink that was adopted by Vulpkanin."
	taste_description = "citrus"
	goal_difficulty = REAGENT_GOAL_EASY

/datum/reagent/consumable/ethanol/howler/on_mob_life(mob/living/M)
	if(!isvulpkanin(M))
		return ..()

	var/mob/living/carbon/human/H = M
	if(H.health > 0)
		H.adjustToxLoss(-0.5)

	return ..()

/datum/reagent/consumable/ethanol/diona_smash
	name = "Diona Smash"
	id = "dionasmash"
	description = "Fake Diona is floating carelessly in the middle of this drink."
	color = "#00531D" // rgb: 0, 83, 29
	alcohol_perc = 0.7
	drink_icon = "dionasmash"
	drink_name = "Diona Smash"
	drink_desc = "Fake Diona is floating carelessly in the middle of this drink."
	taste_description = "the crunch"
	var/mutated = FALSE
	goal_difficulty = REAGENT_GOAL_NORMAL

/datum/reagent/consumable/ethanol/diona_smash/on_mob_life(mob/living/M)
	if(mutated || !iskidan(M))
		return ..()

	to_chat(M, "<span class='warning'>Mmm, tasty.</span>")
	nutriment_factor = 1 * REAGENTS_METABOLISM
	mutated = TRUE

	return ..()

/datum/reagent/consumable/ethanol/lager
	name = "Lager"
	id = "lager"
	description = "A pale beer commonly drank by football hooligans"
	color = "#664300"
	alcohol_perc = 0.4
	drink_icon = "lagerglass"
	drink_name = "Starlink Lager"
	drink_desc = "A pale beer that's the cause of many a soccer-related fight."
	taste_description = "an own goal"

/datum/reagent/consumable/ethanol/stout
	name = "Stout"
	id = "stout"
	description = "A pitch black beer, high in iron content"
	color = "#000000"
	alcohol_perc = 0.4
	drink_icon = "stoutglass"
	drink_name = "Stout"
	drink_desc = "A pitch black beer from Ireland, high in iron content."
	taste_description = "the luck of the Irish"

/datum/reagent/consumable/ethanol/stout/on_mob_life(mob/living/M) // Replenishes blood, seeing as there's iron in it
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!(NO_BLOOD in H.dna.species.species_traits) && (H.blood_volume < BLOOD_VOLUME_NORMAL))
			H.blood_volume += 0.4
	return ..()
