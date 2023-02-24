//ALCOHOL WOO
/datum/reagent/consumable/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	reagent_state = LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" // rgb: 64, 64, 48
	addiction_chance = 3
	addiction_threshold = 150
	minor_addiction = TRUE
	addict_supertype = /datum/reagent/consumable/ethanol
	var/dizzy_adj = 3
	var/alcohol_perc = 1 //percentage of ethanol in a beverage 0.0 - 1.0
	taste_description = "liquid fire"

/datum/reagent/consumable/ethanol/New()
	addict_supertype = /datum/reagent/consumable/ethanol

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/M)
	M.AdjustDrunk(alcohol_perc)
	M.AdjustDizzy(dizzy_adj)
	return ..()

/datum/reagent/consumable/ethanol/reaction_obj(obj/O, volume)
	if(istype(O,/obj/item/paper))
		if(istype(O,/obj/item/paper/contract/infernal))
			O.visible_message("<span class='warning'>The solution ignites on contact with [O].</span>")
		else
			var/obj/item/paper/paperaffected = O
			paperaffected.clearpaper()
			paperaffected.visible_message("<span class='notice'>The solution melts away the ink on the paper.</span>")
	if(istype(O,/obj/item/book))
		if(volume >= 5)
			var/obj/item/book/affectedbook = O
			affectedbook.dat = null
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
	drink_desc = "A freezing pint of beer"
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
	drink_desc = "a refreshing glass of traditional cider"
	taste_description = "cider"

/datum/reagent/consumable/ethanol/whiskey
	name = "Whiskey"
	id = "whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
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
	dizzy_adj = 3
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
	dizzy_adj = 5
	alcohol_perc = 0.7
	drink_icon = "absintheglass"
	drink_name = "Glass of Absinthe"
	drink_desc = "The green fairy is going to get you now!"
	taste_description = "fucking pain"

//copy paste from LSD... shoot me
/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/M)
	M.AdjustHallucinate(5)
	M.last_hallucinator_log = name
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
	dizzy_adj = 7
	alcohol_perc = 1
	drink_icon = "glass_brown2"
	drink_name = "Hooch"
	drink_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
	taste_description = "pure resignation"

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
	dizzy_adj = 5
	drink_icon = "rumglass"
	drink_name = "Glass of Rum"
	drink_desc = "Now you want to Pray for a pirate suit, don't you?"
	taste_description = "rum"

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

/datum/reagent/consumable/ethanol/vodka/on_mob_life(mob/living/M)
	..()
	if(prob(50))
		M.radiation = max(0, M.radiation-1)

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
	dizzy_adj = 2
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
	dizzy_adj = 4
	alcohol_perc = 0.4
	drink_icon = "cognacglass"
	drink_name = "Glass of cognac"
	drink_desc = "Damn, you feel like some kind of French aristocrat just by holding this."
	taste_description = "cognac"

/datum/reagent/consumable/ethanol/suicider //otherwise known as "I want to get so smashed my liver gives out and I die from alcohol poisoning".
	name = "Suicider"
	id = "suicider"
	description = "An unbelievably strong and potent variety of Cider."
	color = "#CF3811"
	dizzy_adj = 20
	alcohol_perc = 1 //because that's a thing it's supposed to do, I guess
	drink_icon = "suicider"
	drink_name = "Suicider"
	drink_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
	taste_description = "approaching death"

/datum/reagent/consumable/ethanol/ale
	name = "Ale"
	id = "ale"
	description = "A dark alchoholic beverage made by malted barley and yeast."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.1
	drink_icon = "aleglass"
	drink_name = "Ale glass"
	drink_desc = "A freezing pint of delicious Ale"
	taste_description = "ale"

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Thirteen Loko"
	id = "thirteenloko"
	description = "A potent mixture of caffeine and alcohol."
	reagent_state = LIQUID
	color = "#102000" // rgb: 16, 32, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.3
	heart_rate_increase = 1
	drink_icon = "thirteen_loko_glass"
	drink_name = "Glass of Thirteen Loko"
	drink_desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass"
	taste_description = "party"

/datum/reagent/consumable/ethanol/thirteenloko/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-7)
	update_flags |= M.AdjustSleeping(-2, FALSE)
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(5)
	return ..() | update_flags


/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////

/datum/reagent/consumable/ethanol/bilk
	name = "Bilk"
	id = "bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	reagent_state = LIQUID
	color = "#895C4C" // rgb: 137, 92, 76
	nutriment_factor = 2 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "glass_brown"
	drink_name = "Glass of bilk"
	drink_desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."
	taste_description = "bilk"

/datum/reagent/consumable/ethanol/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	description = "Nuclear proliferation never tasted so good."
	reagent_state = LIQUID
	color = "#666300" // rgb: 102, 99, 0
	alcohol_perc = 0.2
	drink_icon = "atomicbombglass"
	drink_name = "Atomic Bomb"
	drink_desc = "Nanotrasen cannot take legal responsibility for your actions after imbibing."
	taste_description = "a long, fiery burn"

/datum/reagent/consumable/ethanol/threemileisland
	name = "THree Mile Island Iced Tea"
	id = "threemileisland"
	description = "Made for a woman, strong enough for a man."
	reagent_state = LIQUID
	color = "#666340" // rgb: 102, 99, 64
	alcohol_perc = 0.2
	drink_icon = "threemileislandglass"
	drink_name = "Three Mile Island Ice Tea"
	drink_desc = "A glass of this is sure to prevent a meltdown."
	taste_description = "a creeping heat"

/datum/reagent/consumable/ethanol/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	reagent_state = LIQUID
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
	reagent_state = LIQUID
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
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "gintonicglass"
	drink_name = "Gin and Tonic"
	drink_desc = "A mild but still great cocktail. Drink up, like a true Englishman."
	taste_description = "bitter medicine"

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	description = "Rum, mixed with cola. Viva la revolution."
	reagent_state = LIQUID
	color = "#3E1B00" // rgb: 62, 27, 0
	alcohol_perc = 0.2
	drink_icon = "cubalibreglass"
	drink_name = "Cuba Libre"
	drink_desc = "A classic mix of rum and cola."
	taste_description = "liberation"

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	reagent_state = LIQUID
	color = "#3E1B00" // rgb: 62, 27, 0
	alcohol_perc = 0.3
	drink_icon = "whiskeycolaglass"
	drink_name = "Whiskey Cola"
	drink_desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
	taste_description = "whiskey and coke"

/datum/reagent/consumable/ethanol/martini
	name = "Classic Martini"
	id = "martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "martiniglass"
	drink_name = "Classic Martini"
	drink_desc = "Damn, the bartender even stirred it, not shook it."
	taste_description = "class"

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "martiniglass"
	drink_name = "Vodka martini"
	drink_desc ="A bastardisation of the classic martini. Still great."
	taste_description = "class and potatoes"

/datum/reagent/consumable/ethanol/white_russian
	name = "White Russian"
	id = "whiterussian"
	description = "That's just, like, your opinion, man..."
	reagent_state = LIQUID
	color = "#A68340" // rgb: 166, 131, 64
	alcohol_perc = 0.3
	drink_icon = "whiterussianglass"
	drink_name = "White Russian"
	drink_desc = "A very nice looking drink. But that's just, like, your opinion, man."
	taste_description = "very creamy alcohol"

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Screwdriver"
	id = "screwdrivercocktail"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.3
	drink_icon = "screwdriverglass"
	drink_name = "Screwdriver"
	drink_desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
	taste_description = "a naughty secret"

/datum/reagent/consumable/ethanol/booger
	name = "Booger"
	id = "booger"
	description = "Eww..."
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.2
	drink_icon = "booger"
	drink_name = "Booger"
	drink_desc = "Eww..."
	taste_description = "a fruity mess"

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "bloodymaryglass"
	drink_name = "Bloody Mary"
	drink_desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."
	taste_description = "tomatoes with booze"

/datum/reagent/consumable/ethanol/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	description = "Whoah, this stuff looks volatile!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.7 //ouch
	drink_icon = "gargleblasterglass"
	drink_name = "Pan-Galactic Gargle Blaster"
	drink_desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."
	taste_description = "the number fourty two"

/datum/reagent/consumable/ethanol/flaming_homer
	name = "Flaming Moe"
	id = "flamingmoe"
	description = "This appears to be a mixture of various alcohols blended with prescription medicine. It is lightly toasted..."
	reagent_state = LIQUID
	color = "#58447f" //rgb: 88, 66, 127
	alcohol_perc = 0.5
	drink_icon = "flamingmoeglass"
	drink_name = "Flaming Moe"
	drink_desc = "Happiness is just a Flaming Moe away!"
	taste_description = "caramelised booze and sweet, salty medicine"

/datum/reagent/consumable/ethanol/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	reagent_state = LIQUID
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
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "tequilasunriseglass"
	drink_name = "Tequila Sunrise"
	drink_desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."
	taste_description = "fruity alcohol"

/datum/reagent/consumable/ethanol/toxins_special
	name = "Toxins Special"
	id = "toxinsspecial"
	description = "This thing is FLAMING!. CALL THE DAMN SHUTTLE!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "toxinsspecialglass"
	drink_name = "Toxins Special"
	drink_desc = "Whoah, this thing is on FIRE"
	taste_description = "FIRE"

/datum/reagent/consumable/ethanol/toxins_special/on_mob_life(mob/living/M)
	if(M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Beepsky Smash"
	id = "beepskysmash"
	description = "Deny drinking this and prepare for THE LAW."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "beepskysmashglass"
	description = "Whiskey-imbued cream, what else would you expect from the Irish."
	drink_name = "Beepsky Smash"
	drink_desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."
	taste_description = "THE LAW"

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_life(mob/living/M)
	var/update_flag = STATUS_UPDATE_NONE
	update_flag |= M.Stun(1, FALSE)
	return ..() | update_flag

/datum/reagent/consumable/ethanol/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	reagent_state = LIQUID
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
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "manlydorfglass"
	drink_name = "The Manly Dorf"
	drink_desc = "A manly concotion made from Ale and Beer. Intended for true men only."
	taste_description = "manliness"

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "longislandicedteaglass"
	drink_name = "Long Island Iced Tea"
	drink_desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	taste_description = "fruity alcohol"

/datum/reagent/consumable/ethanol/moonshine
	name = "Moonshine"
	id = "moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.8 //yeeehaw
	drink_icon = "glass_clear"
	drink_name = "Moonshine"
	drink_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
	taste_description = "prohibition"

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	id = "b52"
	description = "Coffee, Irish Cream, and congac. You will get bombed."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "b52glass"
	drink_name = "B-52"
	drink_desc = "Kahlua, Irish Cream, and congac. You will get bombed."
	taste_description = "destruction"

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Irish Coffee"
	id = "irishcoffee"
	description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "irishcoffeeglass"
	drink_name = "Irish Coffee"
	drink_desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
	taste_description = "coffee and booze"

/datum/reagent/consumable/ethanol/margarita
	name = "Margarita"
	id = "margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "margaritaglass"
	drink_name = "Margarita"
	drink_desc = "On the rocks with salt on the rim. Arriba~!"
	taste_description = "daisies"

/datum/reagent/consumable/ethanol/black_russian
	name = "Black Russian"
	id = "blackrussian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	reagent_state = LIQUID
	color = "#360000" // rgb: 54, 0, 0
	alcohol_perc = 0.4
	drink_icon = "blackrussianglass"
	drink_name = "Black Russian"
	drink_desc = "For the lactose-intolerant. Still as classy as a White Russian."
	taste_description = "sweet alcohol"

/datum/reagent/consumable/ethanol/manhattan
	name = "Manhattan"
	id = "manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	reagent_state = LIQUID
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
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "proj_manhattanglass"
	drink_name = "Manhattan Project"
	drink_desc = "A scientist's drink of choice, for thinking how to blow up the station."
	taste_description = "the apocalypse"

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	description = "Ultimate refreshment."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "whiskeysodaglass2"
	drink_name = "Whiskey Soda"
	drink_desc = "Ultimate refreshment."
	taste_description = "mediocrity"

/datum/reagent/consumable/ethanol/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	description = "Ultimate refreshment."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "antifreeze"
	drink_name = "Anti-freeze"
	drink_desc = "The ultimate refreshment."
	taste_description = "poor life choices"

/datum/reagent/consumable/ethanol/antifreeze/on_mob_life(mob/living/M)
	if(M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/barefoot
	name = "Barefoot"
	id = "barefoot"
	description = "Barefoot and pregnant"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "b&p"
	drink_name = "Barefoot"
	drink_desc = "Barefoot and pregnant"
	taste_description = "pregnancy"

/datum/reagent/consumable/ethanol/snowwhite
	name = "Snow White"
	id = "snowwhite"
	description = "A cold refreshment"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "snowwhite"
	drink_name = "Snow White"
	drink_desc = "A cold refreshment."
	taste_description = "a poisoned apple"

/datum/reagent/consumable/ethanol/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	description = "AHHHH!!!!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 10
	alcohol_perc = 0.4
	drink_icon = "demonsblood"
	drink_name = "Demons Blood"
	drink_desc = "Just looking at this thing makes the hair at the back of your neck stand up."
	taste_description = "<span class='warning'>evil</span>"

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	description = "For when a gin and tonic isn't russian enough."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	alcohol_perc = 0.3
	drink_icon = "vodkatonicglass"
	drink_name = "Vodka and Tonic"
	drink_desc = "For when a gin and tonic isn't russian enough."
	taste_description = "bitter medicine"

/datum/reagent/consumable/ethanol/ginfizz
	name = "Gin Fizz"
	id = "ginfizz"
	description = "Refreshingly lemony, deliciously dry."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	alcohol_perc = 0.4
	drink_icon = "ginfizzglass"
	drink_name = "Gin Fizz"
	drink_desc = "Refreshingly lemony, deliciously dry."
	taste_description = "fizzy alcohol"

/datum/reagent/consumable/ethanol/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	description = "Tropic cocktail."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "bahama_mama"
	drink_name = "Bahama Mama"
	drink_desc = "Tropic cocktail"
	taste_description = "HONK"

/datum/reagent/consumable/ethanol/singulo
	name = "Singulo"
	id = "singulo"
	description = "A blue-space beverage!"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	dizzy_adj = 15
	alcohol_perc = 0.7
	drink_icon = "singulo"
	drink_name = "Singulo"
	drink_desc = "A blue-space beverage."
	taste_description = "infinity"

/datum/reagent/consumable/ethanol/sbiten
	name = "Sbiten"
	id = "sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "sbitenglass"
	drink_name = "Sbiten"
	drink_desc = "A spicy mix of Vodka and Spice. Very hot."
	taste_description = "comforting warmth"

/datum/reagent/consumable/ethanol/sbiten/on_mob_life(mob/living/M)
	if(M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	description = "Creepy time!"
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.3
	drink_icon = "devilskiss"
	drink_name = "Devils Kiss"
	drink_desc = "Creepy time!"
	taste_description = "naughtiness"

/datum/reagent/consumable/ethanol/red_mead
	name = "Red Mead"
	id = "red_mead"
	description = "The true Viking drink! Even though it has a strange red color."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "red_meadglass"
	drink_name = "Red Mead"
	drink_desc = "A True Vikings Beverage, though its color is strange."
	taste_description = "blood"

/datum/reagent/consumable/ethanol/mead
	name = "Mead"
	id = "mead"
	description = "A Vikings drink, though a cheap one."
	reagent_state = LIQUID
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
	reagent_state = LIQUID
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
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "grogglass"
	drink_name = "Grog"
	drink_desc = "A fine and cepa drink for Space."
	taste_description = "strongly diluted rum"

/datum/reagent/consumable/ethanol/aloe
	name = "Aloe"
	id = "aloe"
	description = "So very, very, very good."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "aloe"
	drink_name = "Aloe"
	drink_desc = "Very, very, very good."
	taste_description = "healthy skin"

/datum/reagent/consumable/ethanol/andalusia
	name = "Andalusia"
	id = "andalusia"
	description = "A nice, strange named drink."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "andalusia"
	drink_name = "Andalusia"
	drink_desc = "A nice, strange named drink."
	taste_description = "sweet alcohol"

/datum/reagent/consumable/ethanol/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	description = "A drink made from your allies."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "alliescocktail"
	drink_name = "Allies cocktail"
	drink_desc = "A drink made from your allies."
	taste_description = "victory"

/datum/reagent/consumable/ethanol/acid_spit
	name = "Acid Spit"
	id = "acidspit"
	description = "A drink by Nanotrasen. Made from live aliens."
	reagent_state = LIQUID
	color = "#365000" // rgb: 54, 80, 0
	alcohol_perc = 0.3
	drink_icon = "acidspitglass"
	drink_name = "Acid Spit"
	drink_desc = "A drink from Nanotrasen. Made from live aliens."
	taste_description = "PAIN"

/datum/reagent/consumable/ethanol/amasec
	name = "Amasec"
	id = "amasec"
	description = "Official drink of the Imperium."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "amasecglass"
	drink_name = "Amasec"
	drink_desc = "Always handy before COMBAT!!!"
	taste_description = "a stunbaton"

/datum/reagent/consumable/ethanol/neurotoxin
	name = "Neuro-toxin"
	id = "neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = LIQUID
	color = "#2E2E61" // rgb: 46, 46, 97
	dizzy_adj = 6
	alcohol_perc = 0.7
	heart_rate_decrease = 1
	drink_icon = "neurotoxinglass"
	drink_name = "Neurotoxin"
	drink_desc = "A drink that is guaranteed to knock you silly."
	taste_description = "brain damageeeEEeee"

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle >= 13)
		update_flags |= M.Weaken(3, FALSE)
	if(current_cycle >= 55)
		update_flags |= M.Druggy(55, FALSE)
	if(current_cycle >= 200)
		update_flags |= M.adjustToxLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/hippies_delight
	name = "Hippie's Delight"
	id = "hippiesdelight"
	description = "You just don't get it maaaan."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	drink_icon = "hippiesdelightglass"
	drink_name = "Hippie's Delight"
	drink_desc = "A drink enjoyed by people during the 1960's."
	taste_description = "colors"

/datum/reagent/consumable/ethanol/hippies_delight/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.Druggy(50, FALSE)
	switch(current_cycle)
		if(1 to 5)
			M.Stuttering(1)
			M.Dizzy(10)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Stuttering(1)
			M.Jitter(20)
			M.Dizzy(20)
			update_flags |= M.Druggy(45, FALSE)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			M.Stuttering(1)
			M.Jitter(40)
			M.Dizzy(40)
			update_flags |= M.Druggy(60, FALSE)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	return ..() | update_flags

/datum/reagent/consumable/ethanol/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "A stingy drink."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.7
	dizzy_adj = 5
	drink_icon = "changelingsting"
	drink_name = "Changeling Sting"
	drink_desc = "A stingy drink."
	taste_description = "a tiny prick"

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	description = "Mmm, tastes like chocolate cake..."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.3
	dizzy_adj = 5
	drink_icon = "irishcarbomb"
	drink_name = "Irish Car Bomb"
	drink_desc = "An irish car bomb."
	taste_description = "troubles"

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	description = "A Syndicate bomb"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "syndicatebomb"
	drink_name = "Syndicate Bomb"
	drink_desc = "A syndicate bomb."
	taste_description = "a job offer"

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	description = "The surprise is, it's green!"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "erikasurprise"
	name = "Erika Surprise"
	drink_desc = "The surprise is, it's green!"
	taste_description = "disappointment"

/datum/reagent/consumable/ethanol/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.5
	dizzy_adj = 10
	drink_icon = "driestmartiniglass"
	drink_name = "Driest Martini"
	drink_desc = "Only for the experienced. You think you see sand floating in the glass."
	taste_description = "dust and ashes"

/datum/reagent/consumable/ethanol/driestmartini/on_mob_life(mob/living/M)
	if(current_cycle >= 55 && current_cycle < 115)
		M.AdjustStuttering(10)
	return ..()

/datum/reagent/consumable/ethanol/kahlua
	name = "Kahlua"
	id = "kahlua"
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "kahluaglass"
	drink_name = "Glass of RR coffee Liquor"
	drink_desc = "DAMN, THIS THING LOOKS ROBUST"
	taste_description = "coffee and alcohol"

/datum/reagent/consumable/ethanol/kahlua/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDizzy(-5)
	M.AdjustDrowsy(-3)
	update_flags |= (M.AdjustSleeping(-2) ? STATUS_UPDATE_STAT : STATUS_UPDATE_NONE)
	M.Jitter(5)
	return ..() | update_flags

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

/datum/reagent/ginsonic/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-5)
	if(prob(25))
		update_flags |= M.AdjustParalysis(-1, FALSE)
		update_flags |= M.AdjustStunned(-1, FALSE)
		update_flags |= M.AdjustWeakened(-1, FALSE)
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

/datum/reagent/consumable/ethanol/drunkenblumpkin
	name = "Drunken Blumpkin"
	id = "drunkenblumpkin"
	description = "A weird mix of whiskey and blumpkin juice."
	color = "#1EA0FF" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "drunkenblumpkin"
	drink_name = "Drunken Blumpkin"
	drink_desc = "A drink for the drunks"
	taste_description = "weirdness"

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

/datum/reagent/consumable/ethanol/dragons_breath //inaccessible to players, but here for admin shennanigans
	name = "Dragon's Breath"
	id = "dragonsbreath"
	description = "Possessing this stuff probably breaks the Geneva convention."
	reagent_state = LIQUID
	color = "#DC0000"
	alcohol_perc = 1
	can_synth = FALSE
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
	if(prob(8))
		to_chat(M, "<span class='userdanger'>Oh god! Oh GODD!!</span>")
	if(prob(50))
		to_chat(M, "<span class='danger'>Your throat burns terribly!</span>")
		M.emote(pick("scream","cry","choke","gasp"))
		update_flags |= M.Stun(1, FALSE)
	if(prob(8))
		to_chat(M, "<span class='danger'>Why!? WHY!?</span>")
	if(prob(8))
		to_chat(M, "<span class='danger'>ARGHHHH!</span>")
	if(prob(2 * volume))
		to_chat(M, "<span class='userdanger'>OH GOD OH GOD PLEASE NO!!</b></span>")
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
	reagent_state = LIQUID
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
		metabolization_rate += 9 * REAGENTS_METABOLISM //gets removed from organics very fast
		if(prob(25))
			metabolization_rate += 40 * REAGENTS_METABOLISM
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
	reagent_state = LIQUID
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
	reagent_state = LIQUID
	color = "#adb21f"
	alcohol_perc = 0.2
	drink_icon = "trinaryglass"
	drink_name = "Glass of Trinary"
	drink_desc = "Colorful drink made for synthetic crewmembers. It doesn't seem like it would taste well."
	taste_description = "modem static"

/datum/reagent/consumable/ethanol/synthanol/servo
	name = "Servo"
	id = "servo"
	description = "A drink containing some organic ingredients, but meant only for synthetics."
	reagent_state = LIQUID
	color = "#5b3210"
	alcohol_perc = 0.25
	drink_icon = "servoglass"
	drink_name = "Glass of Servo"
	drink_desc = "Chocolate - based drink made for IPCs. Not sure if anyone's actually tried out the recipe."
	taste_description = "motor oil and cocoa"

/datum/reagent/consumable/ethanol/synthanol/uplink
	name = "Uplink"
	id = "uplink"
	description = "A potent mix of alcohol and synthanol. Will only work on synthetics."
	reagent_state = LIQUID
	color = "#e7ae04"
	alcohol_perc = 0.15
	drink_icon = "uplinkglass"
	drink_name = "Glass of Uplink"
	drink_desc = "An exquisite mix of the finest liquoirs and synthanol. Meant only for synthetics."
	taste_description = "a GUI in visual basic"

/datum/reagent/consumable/ethanol/synthanol/synthnsoda
	name = "Synth 'n Soda"
	id = "synthnsoda"
	description = "The classic drink adjusted for a robot's tastes."
	reagent_state = LIQUID
	color = "#7204e7"
	alcohol_perc = 0.25
	drink_icon = "synthnsodaglass"
	drink_name = "Glass of Synth 'n Soda"
	drink_desc = "Classic drink altered to fit the tastes of a robot. Bad idea to drink if you're made of carbon."
	taste_description = "fizzy motor oil"

/datum/reagent/consumable/ethanol/synthanol/synthignon
	name = "Synthignon"
	id = "synthignon"
	description = "Someone mixed wine and alcohol for robots. Hope you're proud of yourself."
	reagent_state = LIQUID
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
	can_synth = FALSE
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

/datum/reagent/consumable/ethanol/fruit_wine/proc/generate_data_info(list/data)
	var/minimum_percent = 0.15 //Percentages measured between 0 and 1.
	var/list/primary_tastes = list()
	var/list/secondary_tastes = list()
	drink_name = "glass of [name]"
	drink_desc = description
	for(var/taste in tastes)
		switch(tastes[taste])
			if(minimum_percent*2 to INFINITY)
				primary_tastes += taste
			if(minimum_percent to minimum_percent*2)
				secondary_tastes += taste

	var/minimum_name_percent = 0.35
	name = ""
	var/list/names_in_order = sortTim(names, /proc/cmp_numeric_dsc, TRUE)
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
	if(names_in_order.len <= 3)
		fruits = names_in_order
	else
		for(var/i in 1 to 3)
			fruits += names_in_order[i]
		fruits += "other plants"
	var/fruit_list = english_list(fruits)
	description = "A [alcohol_description] wine brewed from [fruit_list]."

	var/flavor = ""
	if(!primary_tastes.len)
		primary_tastes = list("[alcohol_description] alcohol")
	flavor += english_list(primary_tastes)
	if(secondary_tastes.len)
		flavor += ", with a hint of "
		flavor += english_list(secondary_tastes)
	taste_description = flavor
	if(holder.my_atom)
		holder.my_atom.on_reagent_change()

/datum/reagent/consumable/ethanol/bacchus_blessing //An EXTREMELY powerful drink. Smashed in seconds, dead in minutes.
	name = "Bacchus' Blessing"
	id = "bacchus_blessing"
	description = "Unidentifiable mixture. Unmeasurably high alcohol content."
	color = rgb(51, 19, 3) //Sickly brown
	dizzy_adj = 21
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
		switch(rand(1, 3))
			if(1)
				to_chat(M, "<span class='warning'>You feel hungry...</span>")
			if(2)
				update_flags |= M.adjustToxLoss(1, FALSE)
				to_chat(M, "<span class='warning'>Your stomach grumbles painfully!</span>")
			else
				pass()
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

/datum/reagent/consumable/ethanol/rainbow_sky
	name = "Rainbow Sky"
	id = "rainbow_sky"
	description = "A drink that shimmers with all the colors of the rainbow with notes of the galaxy."
	color = "#ffffff"
	dizzy_adj = 10
	alcohol_perc = 1.5
	drink_icon = "rainbow_sky"
	drink_name = "Rainbow Sky"
	drink_desc = "A drink that shimmers with all the colors of the rainbow with notes of the galaxy."
	taste_description = "rainbow"

/datum/reagent/consumable/ethanol/rainbow_sky/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-1, FALSE)
	update_flags |= M.adjustFireLoss(-1, FALSE)
	update_flags |= M.Druggy(15, FALSE)
	M.Jitter(5)
	M.AdjustHallucinate(10)
	M.last_hallucinator_log = name
	return ..() | update_flags

/datum/reagent/consumable/ethanol/champagne
	name = "Champagne"
	id = "champagne"
	description = "Excellent sparkling champagne. For those who want to stand out among vinokurs."
	color = "#d0d312"
	alcohol_perc = 0.2
	drink_icon = "champagneglass"
	drink_name = "Glass of Champagne"
	drink_desc = "Excellent sparkling champagne. For those who want to stand out among vinokurs."
	taste_description = "sparkling sunshine"

/datum/reagent/consumable/ethanol/aperol
	name = "Aperol"
	id = "aperol"
	description = "Oh-oh-oh... It looks like it's an ambush for the liver"
	color = "#b9000a"
	alcohol_perc = 0.2
	drink_icon = "aperolglass"
	drink_name = "Glass of Aperol"
	drink_desc = "Oh-oh-oh... It looks like it's an ambush for the liver"
	taste_description = "herbaceous sweetness"

/datum/reagent/consumable/ethanol/jagermeister
	name = "Jagermeister"
	id = "jagermeister"
	description = "The drunkard hunter came from deep space, and it looks like he found a victim."
	color = "#200b0b"
	alcohol_perc = 0.4
	dizzy_adj = 3
	drink_icon = "jagermeisterglass"
	drink_name = "Glass of Jagermeister"
	drink_desc = "The drunkard hunter came from deep space, and it looks like he found a victim."
	taste_description = "btterness of hunting"

/datum/reagent/consumable/ethanol/schnaps
	name = "Schnaps"
	id = "schnaps"
	description = "From such a schnapps it's not a sin to start yodeling."
	color = "#e0e0e0"
	alcohol_perc = 0.4
	dizzy_adj = 1
	drink_icon = "schnapsglass"
	drink_name = "Glass of Schnaps"
	drink_desc = "From such a schnapps it's not a sin to start yodeling."
	taste_description = "wheat mint"

/datum/reagent/consumable/ethanol/sambuka
	name = "Sambuka"
	id = "sambuka"
	description = "Flying into space, many thought that they had grasped fate."
	color = "#e0e0e0"
	alcohol_perc = 0.45
	dizzy_adj = 1
	drink_icon = "sambukaglass"
	drink_name = "Glass of Sambuka"
	drink_desc = "Flying into space, many thought that they had grasped fate."
	taste_description = "twirly fire"

/datum/reagent/consumable/ethanol/bluecuracao
	name = "Blue Curacao"
	id = "bluecuracao"
	description = "The fuse is ready, the blue has already lit up."
	color = "#16c9ff"
	alcohol_perc = 0.35
	drink_icon = "bluecuracaoglass"
	drink_name = "Glass of Blue Curacao"
	drink_desc = "The fuse is ready, the blue has already lit up."
	taste_description = "explosive blue"

/datum/reagent/consumable/ethanol/bitter
	name = "Bitter"
	id = "bitter"
	description = "Don't mix up the label sizes, because I won't change anything."
	color = "#d44071"
	alcohol_perc = 0.45
	dizzy_adj = 2
	drink_icon = "bitterglass"
	drink_name = "Glass of bitter"
	drink_desc = "Don't mix up the label sizes, because I won't change anything."
	taste_description = "vacuum bitterness"

/datum/reagent/consumable/ethanol/sheridan
	name = "Sheridan's"
	id = "sheridan"
	description = "Refrigerate, pour at an angle of 45, do not mix, enjoy."
	color = "#3a3d2e"
	alcohol_perc = 0.35
	drink_icon = "sheridanglass"
	drink_name = "Glass of Sheridan's"
	drink_desc = "Refrigerate, pour at an angle of 45, do not mix, enjoy."
	taste_description = "creamy coffee"

////////////////////////////Cocktails///////////////////////////////
/datum/reagent/consumable/ethanol/black_blood
	name = "Black Blood"
	id = "black_blood"
	description = "Need to drink faster before it starts to curdle."
	color = "#252521"
	alcohol_perc = 0.45
	drink_icon = "black_blood"
	drink_name = "Black Blood"
	drink_desc = "Need to drink faster before it starts to curdle."
	taste_description = "bloody darkness"

/datum/reagent/consumable/ethanol/light_storm
	name = "Light Storm"
	id = "light_storm"
	description = "Even away from the ocean, you can feel this shaking."
	color = "#4b4b44"
	alcohol_perc = 0.6
	drink_icon = "light_storm"
	drink_name = "Light Storm"
	drink_desc = "Even away from the ocean, you can feel this shaking."
	taste_description = "sea excitement"

/datum/reagent/consumable/ethanol/cream_heaven
	name = "Cream Heaven"
	id = "cream_heaven"
	description = "This is a touch of cream and coffee, a real creation of heaven."
	color = "#4b4b44"
	alcohol_perc = 0.25
	drink_icon = "cream_heaven"
	drink_name = "Cream Heaven"
	drink_desc = "This is a touch of cream and coffee, a real creation of heaven."
	taste_description = "coffee cloud"

/datum/reagent/consumable/ethanol/negroni
	name = "Negroni"
	id = "negroni"
	description = "Bitters are very good for the liver, and gin has a bad effect on you. Here they balance each other."
	color = "#ad3948"
	alcohol_perc = 0.4
	drink_icon = "negroni"
	drink_name = "Negroni"
	drink_desc = "Bitters are very good for the liver, and gin has a bad effect on you. Here they balance each other."
	taste_description = "sweet parade"

/datum/reagent/consumable/ethanol/hirosima
	name = "Hirosima"
	id = "hirosima"
	description = "My hands are up to the elbows in blood... Oh, wait, it's alcohol."
	color = "#598317"
	alcohol_perc = 0.3
	drink_icon = "hirosima"
	drink_name = "Hirosima"
	drink_desc = "My hands are up to the elbows in blood... Oh, wait, it's alcohol."
	taste_description = "alcoholic ashes"

/datum/reagent/consumable/ethanol/nagasaki
	name = "nagasaki"
	id = "nagasaki"
	description = "At first, no one knew what would happen next. The intoxication was terrible. There is no doubt that this is the strongest intoxication that a person has ever seen."
	color = "#18c212"
	alcohol_perc = 0.7
	drink_icon = "nagasaki"
	drink_name = "Nagasaki"
	drink_desc = "At first, no one knew what would happen next. The intoxication was terrible. There is no doubt that this is the strongest intoxication that a person has ever seen."
	taste_description = "radioactive ash"

/datum/reagent/consumable/ethanol/chocolate_sheridan
	name = "Chocolate Sheridan's"
	id = "chocolate_sheridan"
	description = "In situations when you really want to cheer up and drink."
	color = "#332a1a"
	alcohol_perc = 0.3
	drink_icon = "chocolate_sheridan"
	drink_name = "Chocolate Sheridan's"
	drink_desc = "In situations when you really want to cheer up and drink."
	taste_description = "alcoholic mocha"

/datum/reagent/consumable/ethanol/panamian
	name = "Panama"
	id = "panamian"
	description = "It will connect your blood and alcohol like a Katun gateway."
	color = "#3164a7"
	alcohol_perc = 0.6
	drink_icon = "panamian"
	drink_name = "Panama"
	drink_desc = "It will connect your blood and alcohol like a Katun gateway."
	taste_description = "shipping channel"

/datum/reagent/consumable/ethanol/pegu_club
	name = "Pegu Club"
	id = "pegu_club"
	description = "It's like a group of gentlemen colonizing your tongue."
	color = "#a5702b"
	alcohol_perc = 0.5
	drink_icon = "pegu_club"
	drink_name = "Pegu Club"
	drink_desc = "It's like a group of gentlemen colonizing your tongue."
	taste_description = "shipping channel"

/datum/reagent/consumable/ethanol/jagermachine
	name = "Jagermachine"
	id = "jagermachine"
	description = "A true detail hunter."
	color = "#6b0b74"
	alcohol_perc = 0.55
	drink_icon = "jagermachine"
	drink_name = "Jagermachine"
	drink_desc = "A true detail hunter."
	taste_description = "stealing parts"

/datum/reagent/consumable/ethanol/blue_cybesauo
	name = "Blue Cybesauo"
	id = "blue_cybesauo"
	description = "The blue is similar to the blue screen of death."
	color = "#0b7463"
	alcohol_perc = 0.4
	drink_icon = "blue_cybesauo"
	drink_name = "Blue Cybesauo"
	drink_desc = "The blue is similar to the blue screen of death."
	taste_description = "error 0xc000001b"

/datum/reagent/consumable/ethanol/alcomender
	name = "Alcomender"
	id = "alcomender"
	description = "A glass in the form of a mender, a favorite among doctors."
	color = "#6b0059"
	alcohol_perc = 1.4 ////Heal burn
	drink_icon = "alcomender"
	drink_name = "Alcomender"
	drink_desc = "A glass in the form of a mender, a favorite among doctors."
	taste_description = "funny medicine"

/datum/reagent/consumable/ethanol/amnesia
	name = "Star Amnesia"
	id = "amnesia"
	description = "Is it just a bottle of medical alcohol?"
	color = "#6b0059"
	alcohol_perc = 1.2 ////Ethanol and Hooch
	drink_icon = "amnesia"
	drink_name = "Star Amnesia"
	drink_desc = "Is it just a bottle of medical alcohol?"
	taste_description = "disco amnesia"

/datum/reagent/consumable/ethanol/johnny
	name = "Silverhand"
	id = "johnny"
	description = "Wake the heck up, samurai. We have a station to burn."
	color = "#c41414"
	alcohol_perc = 0.6
	drink_icon = "johnny"
	drink_name = "Silverhand"
	drink_desc = "Wake the heck up, samurai. We have a station to burn."
	taste_description = "superstar fading"

/datum/reagent/consumable/ethanol/cosmospoliten
	name = "Cosmospoliten"
	id = "cosmospoliten"
	description = "Then try to prove that you are straight and not a woman if you got caught with him."
	color = "#b1483a"
	alcohol_perc = 0.5
	drink_icon = "cosmospoliten"
	drink_name = "Cosmospoliten"
	drink_desc = "Then try to prove that you are straight and not a woman if you got caught with him."
	taste_description = "orientation reversal"

/datum/reagent/consumable/ethanol/oldfashion
	name = "Old Fashion"
	id = "oldfashion"
	description = "Rumor has it that this cocktail is the oldest, but however, this is a completely different story."
	color = "#6b4017"
	alcohol_perc = 0.6
	drink_icon = "oldfashion"
	drink_name = "Old Fashion"
	drink_desc = "Rumor has it that this cocktail is the oldest, but however, this is a completely different story."
	taste_description = "old times"

/datum/reagent/consumable/ethanol/french_75
	name = "French 75"
	id = "french_75"
	description = "Charge the liver, aim, fire!"
	color = "#b1953a"
	alcohol_perc = 0.4
	drink_icon = "french_75"
	drink_name = "French 75"
	drink_desc = "Charge the liver, aim, fire!"
	taste_description = "artillery bombing"

/datum/reagent/consumable/ethanol/gydroseridan
	name = "Gydroridan"
	id = "gydroseridan"
	description = "Hydraulic separation of layers will help us in efficiency."
	color = "#3a99b1"
	alcohol_perc = 0.5
	drink_icon = "gydroseridan"
	drink_name = "Gydroridan"
	drink_desc = "Hydraulic separation of layers will help us in efficiency."
	taste_description = "hydraulic power"

/datum/reagent/consumable/ethanol/milk_plus
	name = "Milk +"
	id = "milk_plus"
	description = "When a man cannot choose he ceases to be a man."
	color = "#DFDFDF"
	alcohol_perc = 0.8
	drink_icon = "milk_plus"
	drink_name = "Milk +"
	drink_desc = "When a man cannot choose he ceases to be a man."
	taste_description = "loss of human"

/datum/reagent/consumable/ethanol/teslasingylo
	name = "God Of Power"
	id = "teslasingylo"
	description = "A real horror for the SMES and the APC. Don't overload them."
	color = "#0300ce"
	alcohol_perc = 0.7
	drink_icon = "teslasingylo"
	drink_name = "God Of Power"
	drink_desc = "A real horror for the SMES and the APC. Don't overload them."
	taste_description = "electricity bless"

/datum/reagent/consumable/ethanol/light
	name = "Light"
	id = "light"
	description = "A favorite among Nian and Dionea, someone say that this is a mini thermonuclear reaction, but only shhh..."
	color = "#fffb00"
	alcohol_perc = 0.2
	drink_icon = "light"
	drink_name = "Light"
	drink_desc = "A favorite among Nian and Dionea, someone say that this is a mini thermonuclear reaction, but only shhh..."
	taste_description = "star warmth"

/datum/reagent/consumable/ethanol/bees_knees
	name = "Bee's Knees"
	id = "bees_knees"
	description = "As if the fact is that the bee carries pollen in the area of the knees and ... Nevermind."
	color = "#e8f71f"
	alcohol_perc = 0.5
	drink_icon = "bees_knees"
	drink_name = "Bee's Knees"
	drink_desc = "As if the fact is that the bee carries pollen in the area of the knees and ... Nevermind."
	taste_description = "honey love"

/datum/reagent/consumable/ethanol/aviation
	name = "Aviation"
	id = "aviation"
	description = "It's hard to make cocktails when a zeppelin flies over your house."
	color = "#c48f8f"
	alcohol_perc = 0.5
	drink_icon = "aviation"
	drink_name = "Aviation"
	drink_desc = "It's hard to make cocktails when a zeppelin flies over your house."
	taste_description = "blowing the wind"

/datum/reagent/consumable/ethanol/fizz
	name = "Fizz"
	id = "fizz"
	description = "It's like living with a feral cat."
	color = "#b6b6b6"
	alcohol_perc = 0.3
	drink_icon = "fizz"
	drink_name = "Fizz"
	drink_desc = "It's like living with a feral cat."
	taste_description = "fizzing"

/datum/reagent/consumable/ethanol/brandy_crusta
	name = "Brandy Crusta"
	id = "brandy_crusta"
	description = "The sugar crust may not be sweet at all."
	color = "#754609"
	alcohol_perc = 0.4
	drink_icon = "brandy_crusta"
	drink_name = "Brandy Crusta"
	drink_desc = "The sugar crust may not be sweet at all."
	taste_description = "salty-sweet"

/datum/reagent/consumable/ethanol/aperolspritz
	name = "Aperol Spritz"
	id = "aperolspritz"
	description = "Many consider it a separate alcohol, but it's more like a knight in chess."
	color = "#c43d3d"
	alcohol_perc = 0.5
	drink_icon = "aperolspritz"
	drink_name = "Aperol Spritz"
	drink_desc = "Many consider it a separate alcohol, but it's more like a knight in chess."
	taste_description = "separateness of taste"

/datum/reagent/consumable/ethanol/sidecar
	name = "Sidecar"
	id = "sidecar"
	description = "This cocktail is very popular. It was first introduced by the popular bartender This McGarry from Buck's Club."
	color = "#b15416"
	alcohol_perc = 0.4
	drink_icon = "sidecar"
	drink_name = "Sidecar"
	drink_desc = "This cocktail is very popular. It was first introduced by the popular bartender This McGarry from Buck's Club."
	taste_description = "orange alcoh"

/datum/reagent/consumable/ethanol/daiquiri
	name = "Daiquiri"
	id = "daiquiri"
	description = "Just try, try again for me! With the headshot power of a Daiquiri!"
	color = "#b6b6b6"
	alcohol_perc = 0.4
	drink_icon = "daiquiri"
	drink_name = "Daiquiri"
	drink_desc = "Just try, try again for me! With the headshot power of a Daiquiri!"
	taste_description = "headshot"

/datum/reagent/consumable/ethanol/tuxedo
	name = "Tuxedo"
	id = "tuxedo"
	description = "I can promise you a Colombian tie."
	color = "#888686"
	alcohol_perc = 0.5
	drink_icon = "tuxedo"
	drink_name = "Tuxedo"
	drink_desc = "I can promise you a Colombian tie."
	taste_description = "strictness of style"

/datum/reagent/consumable/ethanol/telegol
	name = "Telegol"
	id = "telegol"
	description = "Many are still puzzling over the question of this cocktail. Anyway, it still exists... Or not."
	color = "#4218a3"
	alcohol_perc = 0.5
	drink_icon = "telegol"
	drink_name = "Telegol"
	drink_desc = "Many are still puzzling over the question of this cocktail. Anyway, it still exists... Or not."
	taste_description = "fourteen dimension"

/datum/reagent/consumable/ethanol/horse_neck
	name = "Horse Neck"
	id = "horse_neck"
	description = "Be careful with your horse's shoes."
	color = "#c45d09"
	alcohol_perc = 0.5
	drink_icon = "horse_neck"
	drink_name = "Horse Neck"
	drink_desc = "Be careful with your horse's shoes."
	taste_description = "horsepower"

/datum/reagent/consumable/ethanol/cuban_sunset
	name = "Cuban Sunset"
	id = "cuban_sunset"
	description = "A new day, with a new coup."
	color = "#d88948"
	alcohol_perc = 0.6
	drink_icon = "cuban_sunset"
	drink_name = "Cuban Sunset"
	drink_desc = "A new day, with a new coup."
	taste_description = "totalitarianism"

/datum/reagent/consumable/ethanol/sake_bomb
	name = "Sake Bomb"
	id = "sake_bomb"
	description = "Carpet bombing your bamboo liver."
	color = "#e2df2e"
	alcohol_perc = 0.3
	drink_icon = "sake_bomb"
	drink_name = "Sake Bomb"
	drink_desc = "Carpet bombing your bamboo liver."
	taste_description = "beer and sake"

/datum/reagent/consumable/ethanol/blue_havai
	name = "Blue Havai"
	id = "blue_havai"
	description = "The same blue as brown eyes."
	color = "#296129"
	alcohol_perc = 0.2
	drink_icon = "blue_havai"
	drink_name = "Blue Havai"
	drink_desc = "The same blue as brown eyes."
	taste_description = "neon dawn"

/datum/reagent/consumable/ethanol/woo_woo
	name = "Woo Woo"
	id = "woo_woo"
	description = "And which child came up with this name? Yeah, I see, the question is settled."
	color = "#e22e2e"
	alcohol_perc = 0.5
	drink_icon = "woo_woo"
	drink_name = "Woo Woo"
	drink_desc = "And which child came up with this name? Yeah, I see, the question is settled."
	taste_description = "woo woo"

/datum/reagent/consumable/ethanol/mulled_wine
	name = "Mulled Wine"
	id = "mulled_wine"
	description = "Just a hot wine with spices, but so pleasant."
	color = "#fd4b4b"
	alcohol_perc = 0.2
	drink_icon = "mulled_wine"
	drink_name = "Mulled Wine"
	drink_desc = "Just a hot wine with spices, but so pleasant."
	taste_description = "hot wine"

/datum/reagent/consumable/ethanol/white_bear
	name = "White Bear"
	id = "white_bear"
	description = "Two historical enemies, in one circle."
	color = "#d8b465"
	alcohol_perc = 0.5
	drink_icon = "white_bear"
	drink_name = "White Bear"
	drink_desc = "Two historical enemies, in one circle."
	taste_description = "ideological war"

/datum/reagent/consumable/ethanol/vampiro
	name = "Vampiro"
	id = "vampiro"
	description = "Has nothing to do with vampires, except that color."
	color = "#8d0000"
	alcohol_perc = 0.45
	drink_icon = "vampiro"
	drink_name = "Vampiro"
	drink_desc = "Has nothing to do with vampires, except that color."
	taste_description = "exhaustion"

/datum/reagent/consumable/ethanol/queen_mary
	name = "Queen Mary"
	id = "queen_mary"
	description = "Mary was cleaned of blood, and it turned out that she was also red."
	color = "#bd2f2f"
	alcohol_perc = 0.35
	drink_icon = "queen_mary"
	drink_name = "Queen Mary"
	drink_desc = "Mary was cleaned of blood, and it turned out that she was also red."
	taste_description = "cherry beer"

/datum/reagent/consumable/ethanol/inabox
	name = "Box"
	id = "inabox"
	description = "This... Just a box?"
	color = "#5a3e0b"
	alcohol_perc = 0.4
	drink_icon = "inabox"
	drink_name = "Box"
	drink_desc = "This... Just a box?"
	taste_description = "stealth"

/datum/reagent/consumable/ethanol/beer_berry_royal
	name = "Beer Berry Royal"
	id = "beer_berry_royal"
	description = "For some reason, they continue to float up and down."
	color = "#684b16"
	alcohol_perc = 0.25
	drink_icon = "beer_berry_royal"
	drink_name = "Beer Berry Royal"
	drink_desc = "For some reason, they continue to float up and down."
	taste_description = "beer berry"

/datum/reagent/consumable/ethanol/sazerac
	name = "Sazerac"
	id = "sazerac"
	description = "The best pharmacists are bartenders."
	color = "#7c6232"
	alcohol_perc = 0.4
	drink_icon = "sazerac"
	drink_name = "Sazerac"
	drink_desc = "The best pharmacists are bartenders."
	taste_description = "bitter whiskey"

/datum/reagent/consumable/ethanol/monako
	name = "Monako"
	id = "monako"
	description = "You might think there are more fruits on the market."
	color = "#7c6232"
	alcohol_perc = 0.5
	drink_icon = "monako"
	drink_name = "Monako"
	drink_desc = "You might think there are more fruits on the market."
	taste_description = "fruit gin"

/datum/reagent/consumable/ethanol/irishempbomb
	name = "Irish EMP Bomb"
	id = "irishempbomb"
	description = "Mmm, tastes like shut down..."
	color = "#123eb8"
	alcohol_perc = 0.6
	drink_icon = "irishempbomb"
	drink_name = "Irish EMP Bomb"
	drink_desc = "Mmm, tastes like shut down..."
	taste_description = "electromagnetic impulse"

/datum/reagent/consumable/ethanol/codelibre
	name = "Code Libre"
	id = "codelibre"
	description = "Por Code libre!"
	color = "#a126b1"
	alcohol_perc = 0.55
	drink_icon = "codelibre"
	drink_name = "Code Libre"
	drink_desc = "Por Code libre!"
	taste_description = "code liberation"

/datum/reagent/consumable/ethanol/blackicp
	name = "Black ICP"
	id = "blackicp"
	description = "I'm sorry I wasn't responding, can you repeat that?"
	color = "#a126b1"
	alcohol_perc = 0.5
	drink_icon = "blackicp"
	drink_name = "Black ICP"
	drink_desc = "I'm sorry I wasn't responding, can you repeat that?"
	taste_description = "monitor replacing"

/datum/reagent/consumable/ethanol/slime_drink
	name = "Slime Drink"
	id = "slime_drink"
	description = "Don't worry, it's just jelly."
	color = "#dd3e32"
	alcohol_perc = 0.2
	drink_icon = "slime_drink"
	drink_name = "Slime Drink"
	drink_desc = "Don't worry, it's just jelly. And slime been dead for a long time."
	taste_description = "jelly alcohol"

/datum/reagent/consumable/ethanol/innocent_erp
	name = "Innocent ERP"
	id = "innocent_erp"
	description = "Remember that big brother sees everything."
	color = "#746463"
	alcohol_perc = 0.5
	drink_icon = "innocent_erp"
	drink_name = "Innocent ERP"
	drink_desc = "Remember that big brother sees everything."
	taste_description = "loss of flirtatiousness"

/datum/reagent/consumable/ethanol/nasty_slush
	name = "Nasty Slush"
	id = "nasty_slush"
	description = "The name has nothing to do with the drink itself."
	color = "#462c0a"
	alcohol_perc = 0.55
	drink_icon = "nasty_slush"
	drink_name = "Nasty Slush"
	drink_desc = "The name has nothing to do with the drink itself."
	taste_description = "nasty slush"

/datum/reagent/consumable/ethanol/blue_lagoon
	name = "Blue Lagoon"
	id = "blue_lagoon"
	description = "What could be better than relaxing on the beach with a good drink?"
	color = "#1edddd"
	alcohol_perc = 0.5
	drink_icon = "blue_lagoon"
	drink_name = "Blue Lagoon"
	drink_desc = "What could be better than relaxing on the beach with a good drink?"
	taste_description = "beach relaxation"

/datum/reagent/consumable/ethanol/green_fairy
	name = "Green Fairy"
	id = "green_fairy"
	description = "Some kind of abnormal green."
	color = "#54dd1e"
	alcohol_perc = 0.6
	drink_icon = "green_fairy"
	drink_name = "Green Fairy"
	drink_desc = "Some kind of abnormal green."
	taste_description = "faith in fairies"

/datum/reagent/consumable/ethanol/home_lebovsky
	name = "Home Lebowski"
	id = "home_lebovsky"
	description = "Let me explain something to you. Um, I am not Home Lebowski. You're Home Lebowski. I'm The Dude."
	color = "#422b00"
	alcohol_perc = 0.35
	drink_icon = "home_lebovsky"
	drink_name = "Home Lebowski"
	drink_desc = "Let me explain something to you. Um, I am not Home Lebowski. You're Home Lebowski. I'm The Dude."
	taste_description = "dressing gown"

/datum/reagent/consumable/ethanol/top_billing
	name = "Top Billing"
	id = "top_billing"
	description = "In a prominent place, our top billing!"
	color = "#0b573d"
	alcohol_perc = 0.4
	drink_icon = "top_billing"
	drink_name = "Top Billing"
	drink_desc = "In a prominent place, our top billing!"
	taste_description = "advertising space"

/datum/reagent/consumable/ethanol/trans_siberian_express
	name = "Trans-Siberian Express"
	id = "trans_siberian_express"
	description = "From Vladivostok to delirium tremens in a day."
	color = "#e2a600"
	alcohol_perc = 0.5
	drink_icon = "trans_siberian_express"
	drink_name = "Trans-Siberian express"
	drink_desc = "From Vladivostok to delirium tremens in a day."
	taste_description = "terrible infrastructure"

/datum/reagent/consumable/ethanol/sun
	name = "Sun"
	id = "sun"
	description = "Red sun over paradise!"
	color = "#bd1c1c"
	alcohol_perc = 0.4
	drink_icon = "sun"
	drink_name = "Sun"
	drink_desc = "Red sun over paradise!"
	taste_description = "sun heat"

/datum/reagent/consumable/ethanol/tick_tack
	name = "Tick-Tock"
	id = "tick_tack"
	description = "Tick-Tock, Tick-Tock Bzzzzz..."
	color = "#118020"
	alcohol_perc = 0.3
	drink_icon = "tick_tack"
	drink_name = "Tick-Tock"
	drink_desc = "Tick-Tock, Tick-Tock Bzzzzz..."
	taste_description = "clock tick"

/datum/reagent/consumable/ethanol/uragan_shot
	name = "Uragan Shot"
	id = "uragan_shot"
	description = "Is it a uragan? But no, it's urahol."
	color = "#da6631"
	alcohol_perc = 0.35
	drink_icon = "uragan_shot"
	drink_name = "Uragan Shot"
	drink_desc = "Is it a uragan? But no, it's urahol."
	taste_description = "gusts of wind"

/datum/reagent/consumable/ethanol/new_yorker
	name = "New Yorker"
	id = "new_yorker"
	description = "Be careful with the stock exchange, otherwise it will be 'Black Tuesday.'"
	color = "#da3131"
	alcohol_perc = 0.4
	drink_icon = "new_yorker"
	drink_name = "New Yorker"
	drink_desc = "Be careful with the stock exchange, otherwise it will be 'Black Tuesday.'"
	taste_description = "the collapse"
