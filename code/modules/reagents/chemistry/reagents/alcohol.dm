//ALCOHOL WOO
/datum/reagent/consumable/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	reagent_state = LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" // rgb: 64, 64, 48
	var/dizzy_adj = 3
	var/alcohol_perc = 1 //percentage of ethanol in a beverage 0.0 - 1.0
	taste_description = "liquid fire"

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/M)
	M.AdjustDrunk(alcohol_perc)
	M.AdjustDizzy(dizzy_adj)
	return ..()

/datum/reagent/consumable/ethanol/reaction_obj(obj/O, volume)
	if(istype(O,/obj/item/paper))
		if(istype(O,/obj/item/paper/contract/infernal))
			to_chat(usr, "The solution ignites on contact with the [O].")
		else
			var/obj/item/paper/paperaffected = O
			paperaffected.clearpaper()
			to_chat(usr, "The solution melts away the ink on the paper.")
	if(istype(O,/obj/item/book))
		if(volume >= 5)
			var/obj/item/book/affectedbook = O
			affectedbook.dat = null
			to_chat(usr, "The solution melts away the ink on the book.")
		else
			to_chat(usr, "It wasn't enough...")

/datum/reagent/consumable/ethanol/reaction_mob(mob/living/M, method=TOUCH, volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(method == TOUCH)
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
	drink_icon = "absinthebottle"
	drink_name = "Glass of Absinthe"
	drink_desc = "The green fairy is going to get you now!"
	taste_description = "fucking pain"

//copy paste from LSD... shoot me
/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/M)
	M.AdjustHallucinate(5)
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

/datum/reagent/consumable/ethanol/sake
	name = "Sake"
	id = "sake"
	description = "Anime's favorite drink."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "ginvodkaglass"
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
	name = "Red Wine"
	id = "wine"
	description = "An premium alcoholic beverage made from distilled grape juice."
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
	description = "A sweet and strongly alcoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
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
	description = "A dark alcoholic beverage made by malted barley and yeast."
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

/datum/reagent/consumable/ethanol/anisette
	name = "Anisette"
	id = "anisette"
	description = "A sweetened aniseed-derived liqueur usually used as a cocktail ingredient."
	color = "#d3d3d3"
	alcohol_perc = 0.2
	drink_icon = "anisetteglass"
	drink_name = "Glass of Anisette"
	drink_desc = "A glass of sweet liqueur with a scent of aniseed."
	taste_description = "aniseed"

/datum/reagent/consumable/ethanol/aperol
	name = "Aperol"
	id = "aperol"
	description = "Velvety and rounded, with a hint of orange."
	color = "#ffa500"
	alcohol_perc = 0.1
	drink_icon = "aperolglass"
	drink_name = "Glass of Aperol"
	drink_desc = "A glass of aperol: velvety and rounded, with a hint of orange."
	taste_description = "smooth orange and wood"

/datum/reagent/consumable/ethanol/appleliqueur
	name = "Apple Liqueur"
	id = "appleliqueur"
	description = "A sweetened alcoholic beverage with an apple flavour. Slightly sour."
	color = "#fffdd0"
	alcohol_perc = 0.2
	drink_icon = "apple_liqueur_glass"
	drink_name = "Glass of Apple Liqueur"
	drink_desc = "A glass of sweet liqueur with a scent of apple."
	taste_description = "sweet apple"

/datum/reagent/consumable/ethanol/apricotliqueur
	name = "Apricot Liqueur"
	id = "apricotliqueur"
	description = "A sweetened alcoholic beverage with an apricot flavour. Tangy!"
	color = "#fed8b1"
	alcohol_perc = 0.2
	drink_icon = "apricot_liqueur_glass"
	drink_name = "Glass of Apricot Liqueur"
	drink_desc = "A glass of sweet liqueur with a scent of apricot."
	taste_description = "sweet apricot"

/datum/reagent/consumable/ethanol/bitters
	name = "Bitters"
	id = "bitters"
	description = "Lightly alcoholic and very bitter."
	color = "#b3b3b3"
	alcohol_perc = 0.2
	drink_icon = "glass_clear"
	drink_name = "Glass of Bitters"
	drink_desc = "A glass of bitter herbal alcohol, said to be helpful for nausea."
	taste_description = "bitterness"

// Heals ~0.5 tox damage per cycle, but only if the damage is light.
/datum/reagent/consumable/ethanol/bitters/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if((M.getToxLoss() <= 15) && prob(50))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/blackcurrantliqueur
	name = "Blackcurrant Liqueur"
	id = "blackcurrantliqueur"
	description = "A sweetened alcoholic beverage with a blackcurrant flavour. Tangy!"
	color = "#800080"
	alcohol_perc = 0.2
	drink_icon = "blackcurrant_liqueur_glass"
	drink_name = "Glass of Blackcurrant Liqueur"
	drink_desc = "A glass of sweet liqueur with a scent of blackcurrant."
	taste_description = "tangy blackcurrant"

/datum/reagent/consumable/ethanol/boukha
	name = "Boukha"
	id = "boukha"
	description = "A clear spirit made of figs."
	color = "#b3b3b3"
	alcohol_perc = 0.4
	drink_icon = "boukhaglass"
	drink_name = "Glass of Boukha"
	drink_desc = "A glass of clear spirits. It smells a little of figs."
	taste_description = "burning figs"

/datum/reagent/consumable/ethanol/champagne
	name = "Champagne"
	id = "champagne"
	description = "A bubbly wine."
	color = "#f3e5ab"
	alcohol_perc = 0.1
	drink_icon = "champagneglass"
	drink_name = "Glass of Champagne"
	drink_desc = "A fancy glass of lightly fizzing white wine."
	taste_description = "fizzy wine"

/datum/reagent/consumable/ethanol/chocolateliqueur
	name = "Creme de Cacao"
	id = "chocolateliqueur"
	description = "Chocolate liqueur."
	color = "#d4aa8e"
	alcohol_perc = 0.2
	drink_icon = "cremedecacaoglass"
	drink_name = "Glass of Creme de Cacao"
	drink_desc = "Creme de Cacao: A snooty way of saying chocolate liqueur."
	taste_description = "creamy chocolate"

/datum/reagent/consumable/ethanol/almondliqueur
	name = "Creme de Noyaux"
	id = "almondliqueur"
	description = "An almond flavoured liqueur that contains trace amounts of cyanide."
	color = "#ffa6a6"
	alcohol_perc = 0.2
	drink_icon = "cremedenoyauxglass"
	drink_name = "Glass of Creme de Noyaux"
	drink_desc = "For when you want to be poisoned, but only a little bit."
	taste_description = "almonds"

/datum/reagent/consumable/ethanol/almondliqueur/on_mob_life(mob/living/M)
	if(prob(10))
		M.reagents.add_reagent("cyanide", 0.1)
	return ..()

/datum/reagent/consumable/ethanol/kumis
	name = "Kumis"
	id = "kumis"
	description = "Fermented horse milk. Yummy!"
	color = "#f4f0db"
	alcohol_perc = 0.05
	drink_icon = "kumisglass"
	drink_name = "Glass of Kumis"
	drink_desc = "A fermented milk beverage. Exotic!"
	taste_description = "salty cheese"

/datum/reagent/consumable/ethanol/grappa
	name = "Grappa"
	id = "grappa"
	description = "A very strong grape brandy."
	color = "#fed8b1"
	alcohol_perc = 0.6
	drink_icon = "grappaglass"
	drink_name = "Glass of Grappa"
	drink_desc = "A glass of very strong grape brandy."
	taste_description = "sweet, sweet fire"

/datum/reagent/consumable/ethanol/pearliqueur
	name = "Pear Liqueur"
	id = "pearliqueur"
	description = "An alcoholic beverage with a pear flavour. Mild and sweet."
	color = "#fffdd0"
	alcohol_perc = 0.2
	drink_icon = "pearliqueurglass"
	drink_name = "Glass of Pear Liqueur"
	drink_desc = "A glass of sweet liqueur with a scent of pear."
	taste_description = "mild sweetness"

/datum/reagent/consumable/ethanol/whitewine
	name = "White Wine"
	id = "whitewine"
	description = "An alternative to the darker, more nutty red wines."
	color = "#fffdd0"
	alcohol_perc = 0.2
	drink_icon = "whitewineglass"
	drink_name = "Glass of White Wine"
	drink_desc = "A glass of clear white wine. It has a flowery scent."
	taste_description = "dried flowers"

/datum/reagent/consumable/ethanol/raspberryliqueur
	name = "Raspberry Liqueur"
	id = "raspberryliqueur"
	description = "An alcoholic beverage with a raspberry flavour. Zesty."
	color = "#5e1224"
	alcohol_perc = 0.2
	drink_icon = "raspberryliqueurglass"
	drink_name = "Glass of Raspberry Liqueur"
	drink_desc = "A glass of sweet liqueur with a scent of raspberry."
	taste_description = "raspberry"

/datum/reagent/consumable/ethanol/vanillaliqueur
	name = "Vanilla Liqueur"
	id = "vanillaliqueur"
	description = "An alcoholic beverage with a vanilla flavour. Smooth."
	color = "#fffdd0"
	alcohol_perc = 0.2
	drink_icon = "vanillaliqueurglass"
	drink_name = "Glass of Vanilla Liqueur"
	drink_desc = "A glass of sweet liqueur with a scent of vanilla."
	taste_description = "sweet vanilla"

/datum/reagent/consumable/ethanol/beer/darkbeer
	name = "Stout Beer"
	id = "darkbeer"
	description = "Normally you'd assume this dark beer is beer's evil counterpart, but it's really just heavier and more filling."
	color = "#654321"
	alcohol_perc = 0.2
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "stoutbeerglass"
	drink_name = "Glass of Stout Beer"
	drink_desc = "Normally you'd assume this dark beer is beer's evil counterpart, but it's really just heavier and more filling."
	taste_description = "earthiness"

/datum/reagent/consumable/ethanol/beer/bluespacebeer
	name = "Bluespace Beer"
	id = "bluespacebeer"
	description = "It looks like ordinary beer, but the way it swirls and moves is strangely disjointed."
	drink_icon = "bluespacebeerglass"
	drink_name = "Glass of... Beer?"
	drink_desc = "It looks like ordinary beer, but the way it swirls and moves is strangely disjointed. Staring at it too long makes your head hurt."

// Has a 90% chance of becoming more beer. Effectively, drinking 1 unit is drinking 10.
/datum/reagent/consumable/ethanol/beer/bluespacebeer/on_mob_life(mob/living/M)
	if(prob(90))
		M.reagents.add_reagent("bluespacebeer", metabolization_rate)
	return ..()

/datum/reagent/consumable/ethanol/amaretto
	name = "Amaretto"
	id = "amaretto"
	description = "A alcoholic beverage that tastes like almond."
	color = "#9a5611" // rgb: 154,86,17
	alcohol_perc = 0.2
	drink_name = "Glass of Amaretto"
	drink_desc = "A classy slightly bitter drink."
	taste_description = "amaretto"
	
/datum/reagent/consumable/ethanol/bourbon
	name = "Bourbon"
	id = "bourbon"
	description = "A light alcoholic beverage primarily made out of corn."
	color = "#9a5611" // rgb: 154,86,17
	alcohol_perc = 0.4
	drink_icon = "bourbonglass"
	drink_name = "Glass of Bourbon"
	drink_desc = "This is a glass of Bourbon by holding this you think you should drink this responsibly."
	taste_description = "bourbon"

/datum/reagent/consumable/ethanol/brandy
	name = "Brandy"
	id = "brandy"
	description = "A light alcoholic beverage primarily made out of corn."
	color = "#9a5611" // rgb: 154,86,17
	alcohol_perc = 0.4
	drink_name = "Glass of Brandy"
	drink_desc = "A glass of well aged Brandy."
	taste_description = "brandy"

/datum/reagent/consumable/ethanol/bluecuracao
	name = "Blue Curacao"
	id = "bluecuracao"
	description = "A beautiful looking blue liqueur."
	color = "#9a5611" // rgb: 154,86,17
	alcohol_perc = 0.2
	drink_icon = "bluecuracaoglass"
	drink_name = "Glass of Blue Curacao"
	drink_desc = "A beautiful blue slightly bitter drink."
	taste_description = "blue curacao"

/datum/reagent/consumable/ethanol/cointreau
	name = "Cointreau"
	id = "cointreau"
	description = "A colorless liqueur, which apparently tastes like oranges."
	color = "#9a5611" // rgb: 154,86,17
	alcohol_perc = 0.2
	drink_name = "Glass of Cointreau"
	drink_desc = "A glass of colorless curacao."
	taste_description = "cointreau"

/datum/reagent/consumable/ethanol/watermelonliqueur
	name = "Watermelon Liqueur"
	id = "watermelonliqueur"
	description = "A fruity alcoholic beverage."
	color = "#fd8f8f" // rgb: 253,143,143
	alcohol_perc = 0.2
	drink_icon = "glass_red"
	drink_name = "Glass of Watermelon Liqueur"
	drink_desc = "Who could have known that alcohol could taste this fruity..."
	taste_description = "watermelon and alcohol"

/datum/reagent/consumable/ethanol/mintliqueur
	name = "Mint Liqueur"
	id = "mintliqueur"
	description = "A minty alcoholic beverage."
	color = "#62d462" // rgb: 98,212,98
	alcohol_perc = 0.2
	drink_icon = "glass_green"
	drink_name = "Glass of Mint Liqueur"
	drink_desc = "Who could have known that alcohol could taste this minty..."
	taste_description = "minty alcohol"

/datum/reagent/consumable/ethanol/peachliqueur
	name = "Peach Liqueur"
	id = "peachliqueur"
	description = "A fruity alcoholic beverage."
	color = "#f9c667" // rgb: 249,198,103
	alcohol_perc = 0.2
	drink_icon = "glass_orange"
	drink_name = "Glass of Peach Liqueur"
	drink_desc = "Who could have known that alcohol could taste this fruity..."
	taste_description = "peach and alcohol"

/datum/reagent/consumable/ethanol/bananaliqueur
	name = "Banana Liqueur"
	id = "bananaliqueur"
	description = "A fruity alcoholic beverage."
	color = "#DADB17" // rgb: 218,219,23
	alcohol_perc = 0.2
	drink_icon = "glass_yellow"
	drink_name = "Glass of Banana Liqueur"
	drink_desc = "Who could have known that alcohol could taste this fruity..."
	taste_description = "banana and alcohol"

/datum/reagent/consumable/ethanol/violetliqueur
	name = "Violet Liqueur"
	id = "violetliqueur"
	description = "A floral alcoholic beverage."
	color = "#6d116d" // rgb: 109,17,109
	alcohol_perc = 0.2
	drink_name = "Glass of Violet Liqueur"
	drink_desc = "Glass full of sweet and floral tasting liqueur."
	taste_description = "sweet floral alcohol"

/datum/reagent/consumable/ethanol/nutliqueur
	name = "Nut Liqueur"
	id = "nutliqueur"
	description = "A nutty alcoholic beverage."
	color = "#9a5611" // rgb: 154,86,17
	alcohol_perc = 0.2
	drink_name = "Glass of Nut Liqueur"
	drink_desc = "Glass full of nut tasting liqueur."
	taste_description = "nuts and alcohol"

/datum/reagent/consumable/ethanol/cherryliqueur
	name = "Cherry Liqueur"
	id = "cherryliqueur"
	description = "A fruity alcoholic beverage."
	color = "#FA98FB" // rgb: 250,152,251
	alcohol_perc = 0.2
	drink_name = "Glass of Cherry Liqueur"
	drink_desc = "Who could have known that alcohol could taste this fruity..."
	taste_description = "cherry and alcohol"

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

/datum/reagent/consumable/ethanol/dragons_breath/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST && prob(20))
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

/datum/reagent/consumable/ethanol/redroyal
	name = "Red Royal"
	id = "redroyal"
	description = "A really strong drink only for the strong."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.5
	drink_icon = "redroyal"
	drink_name = "Red Royal"
	drink_desc = "A delicious and refreshing cocktail, perfect for summer."
	taste_description = "strong alcohol"

/datum/reagent/consumable/ethanol/strawberrydaiquiri
	name = "Strawberry Daiquiri"
	id = "strawberrydaiquiri"
	description = "A delicious and refreshing cocktail, perfect for summer."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "strawberrydaiquiri"
	drink_name = "Strawberry Daiquiri"
	drink_desc = "A delicious and refreshing cocktail, perfect for summer."
	taste_description = "strawberry and alcohol"

/datum/reagent/consumable/ethanol/paradise
	name = "Paradise"
	id = "paradise"
	description = "A nice classic gin martini."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.4
	drink_icon = "paradise"
	drink_name = "Paradise"
	drink_desc = "A nice classic gin martini."
	taste_description = "classic alcohol"

/datum/reagent/consumable/ethanol/mintini
	name = "Mintini"
	id = "mintini"
	description = "A martini with a nice hint of mint."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.4
	drink_icon = "mintini"
	drink_name = "Mintini"
	drink_desc = "A martini with a nice hint of mint."
	taste_description = "minty alcohol"

/datum/reagent/consumable/ethanol/mapleleaf
	name = "Maple Leaf"
	id = "mapleleaf"
	description = "A maple-icious cocktail."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.4
	drink_icon = "mapleleaf"
	drink_name = "Maple Leaf"
	drink_desc = "A maple-icious cocktail."
	taste_description = "sweetness and alcohol"

/datum/reagent/consumable/ethanol/daiquiri
	name = "Daiquiri"
	id = "daiquiri"
	description = "A nice, strong, refreshing drink."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.4
	drink_icon = "daiquiri"
	drink_name = "Daiquiri"
	drink_desc = "A nice, strong, refreshing drink."
	taste_description = "sweet and sour alcohol"

/datum/reagent/consumable/ethanol/coconuthawaiian
	name = "Coconut Hawaiian"
	id = "coconuthawaiian"
	description = "This blue beverage will have you crooning like Elvis."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "coconuthawaiian"
	drink_name = "Coconut Hawaiian"
	drink_desc = "This blue beverage will have you crooning like Elvis."
	taste_description = "fruity alcohol"

/datum/reagent/consumable/ethanol/bronx
	name = "Bronx"
	id = "bronx"
	description = "A nice martini with orange juice."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.4
	drink_icon = "bronx"
	drink_name = "Bronx"
	drink_desc = "A nice martini with orange juice."
	taste_description = "orange juice and martini"

/datum/reagent/consumable/ethanol/bluearrow
	name = "Blue Arrow"
	id = "bluearrow"
	description = "Basically a martini, but this one is blue."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.4
	drink_icon = "bluearrow"
	drink_name = "Blue Arrow"
	drink_desc = "Basically a martini, but this one is blue."
	taste_description = "alcohol"

/datum/reagent/consumable/ethanol/summerhoedown
	name = "Summer Hoedown"
	id = "summerhoedown"
	description = "This drink is great for a nice beach day during summer."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "summerhoedown"
	drink_name = "Summer Hoedown"
	drink_desc = "This drink is great for a nice beach day during summer."
	taste_description = "sweet fruity alcohol"

/datum/reagent/consumable/ethanol/four_horsemen
	name = "Four Horsemen"
	id = "four_horsemen"
	description = "An excuse to drink a lot of spirits at once!"
	reagent_state = LIQUID
	color = "#b5651d"
	alcohol_perc = 0.6
	drink_icon = "four_horsemen"
	drink_name = "Four Horsemen"
	drink_desc = "An excuse to drink a lot of spirits at once!"
	taste_description = "apocalyptic fire"

/datum/reagent/consumable/ethanol/absinthe_frappe
	name = "Absinthe Frappe"
	id = "absinthe_frappe"
	description = "Absinthe, but chilled and fizzy!"
	reagent_state = LIQUID
	color = "#90ee90"
	alcohol_perc = 0.6
	drink_icon = "absinthe_frappe"
	drink_name = "Absinthe Frappe"
	drink_desc = "Absinthe, but chilled and fizzy!"
	taste_description = "fizzy pain"

/datum/reagent/consumable/ethanol/fourth_of_july
	name = "Fourth of July"
	id = "fourth_of_july"
	description = "A festive layered cocktail."
	reagent_state = LIQUID
	color = "#b6b6b6"
	alcohol_perc = 0.2
	drink_icon = "fourth_of_july"
	drink_name = "Fourth of July"
	drink_desc = "A festive layered cocktail."
	taste_description = "patriotism"

/datum/reagent/consumable/ethanol/aperol_spritz
	name = "Aperol Spritz"
	id = "aperol_spritz"
	description = "A very fizzy orange-flavoured cocktail."
	reagent_state = LIQUID
	color = "#ffa500"
	alcohol_perc = 0.2
	drink_icon = "aperol_spritz"
	drink_name = "Aperol Spritz"
	drink_desc = "A very fizzy cocktail with a slight orange flavour."
	taste_description = "alcoholic orange soda"

/datum/reagent/consumable/ethanol/apocalypse_now
	name = "Apocalypse Now"
	id = "apocalypse_now"
	description = "A milky, layered cocktail from before good-tasting cocktails were invented."
	reagent_state = LIQUID
	color = "#d4aa8e"
	alcohol_perc = 0.2
	drink_icon = "apocalypse_now"
	drink_name = "Apocalypse Now"
	drink_desc = "A milky, layered cocktail from before good-tasting cocktails were invented."
	taste_description = "contradictions"

/datum/reagent/consumable/ethanol/apple_martini
	name = "Apple Martini"
	id = "apple_martini"
	description = "Apple Martini"
	reagent_state = LIQUID
	color = "#90ee90"
	alcohol_perc = 0.2
	drink_icon = "apple_martini"
	drink_name = "Apple Martini"
	drink_desc = "Some called this an 'Apple-tini'. Those people are long dead."
	taste_description = "tangy martini"

/datum/reagent/consumable/ethanol/b54
	name = "B-54"
	id = "b54"
	description = "It's like a B-52, but exactly 2 better."
	reagent_state = LIQUID
	color = "#d4aa8e"
	alcohol_perc = 0.2
	drink_icon = "b-54"
	drink_name = "B-54"
	drink_desc = "It's like a B-52, but exactly 2 better."
	taste_description = "a +2 enhancement bonus"

/datum/reagent/consumable/ethanol/bazooka_joe
	name = "Bazooka Joe"
	id = "bazooka_joe"
	description = "Bazooka Joe"
	reagent_state = LIQUID
	color = "#90ee90"
	alcohol_perc = 0.2
	drink_icon = "bazooka_joe"
	drink_name = "Bazooka Joe"
	drink_desc = "Named after an ancient capitalist icon."
	taste_description = "bubblegum"

/datum/reagent/consumable/ethanol/bloody_brain
	name = "Bloody Brain"
	id = "bloody_brain"
	description = "Bloody Brain"
	reagent_state = LIQUID
	color = "#ffcccb"
	alcohol_perc = 0.2
	drink_icon = "bloody_brain"
	drink_name = "Bloody Brain"
	drink_desc = "Curdled cream looks a lot like brain matter if you half close your eyes."
	taste_description = "spooks"

/datum/reagent/consumable/ethanol/chocolatini
	name = "Chocolatini"
	id = "chocolatini"
	description = "Chocolatini"
	reagent_state = LIQUID
	color = "#d4aa8e"
	alcohol_perc = 0.2
	drink_icon = "chocolatini"
	drink_name = "Chocolatini"
	drink_desc = "How is this even a martini?"
	taste_description = "cream and chocolate"

/datum/reagent/consumable/ethanol/rastini
	name = "Rastini"
	id = "rastini"
	description = "Rastini"
	reagent_state = LIQUID
	color = "#90ee90"
	alcohol_perc = 0.2
	// No cranberry liqueur, so I had to improvise
	drink_icon = "crantini"
	drink_name = "Rastini"
	drink_desc = "A very tart martini; a 'tart-tini' if you will."
	taste_description = "tart martini"

/datum/reagent/consumable/ethanol/death_ita
	name = "Death In The Afternoon"
	id = "death_ita"
	description = "Death In The Afternoon"
	reagent_state = LIQUID
	color = "#f0fff0"
	alcohol_perc = 0.2
	drink_icon = "death_ita"
	drink_name = "Death In The Afternoon"
	drink_desc = "A cloudy, fizzy mixture of absinthe and champagne optimized for the most classy of benders."
	taste_description = "alcoholism"

/datum/reagent/consumable/ethanol/diamond_fizz
	name = "Diamond Fizz"
	id = "diamond_fizz"
	description = "Diamond Fizz"
	reagent_state = LIQUID
	color = "#b3b3b3"
	alcohol_perc = 0.5
	drink_icon = "diamond_fizz"
	drink_name = "Diamond Fizz"
	drink_desc = "A strong, fizzy cocktail usually made for shots. This one, however, is in a full-size glass. Are you okay?"
	taste_description = "fizzy, alcoholic lemonade"

/datum/reagent/consumable/ethanol/expresso_martini
	name = "Expresso Martini"
	id = "expresso_martini"
	description = "Expresso Martini"
	reagent_state = LIQUID
	color = "#d4aa8e"
	alcohol_perc = 0.2
	drink_icon = "expresso_martini"
	drink_name = "Expresso Martini"
	drink_desc = "A martini, this time with coffee. WHY ARE THERE SO MANY TYPES OF MARTINI?"
	taste_description = "mounting frustration"

/datum/reagent/consumable/ethanol/french_martini
	name = "French Martini"
	id = "french_martini"
	description = "French Martini"
	reagent_state = LIQUID
	color = "#ffaaaa"
	alcohol_perc = 0.2
	drink_icon = "french_martini"
	drink_name = "French Martini"
	drink_desc = "Yet another martini, also quite tart. S'il vous plaît, tuez-moi maintenant."
	taste_description = "creeping burn-out"

/datum/reagent/consumable/ethanol/french_76
	name = "French 76"
	id = "french_76"
	description = "French 76"
	reagent_state = LIQUID
	color = "#f0ffff"
	alcohol_perc = 0.2
	drink_icon = "french_76"
	drink_name = "French 76"
	drink_desc = "A vodka sour topped with champagne."
	taste_description = "sour vodka"

/datum/reagent/consumable/ethanol/hawaiian_vodka
	name = "Hawaiian Vodka"
	id = "hawaiian_vodka"
	description = "Hawaiian Vodka"
	reagent_state = LIQUID
	color = "#E78108"
	alcohol_perc = 0.2
	drink_icon = "hawaiian_vodka"
	drink_name = "Hawaiian Vodka"
	drink_desc = "A vodka sour with a tropical twist."
	taste_description = "tropical vodka"

/datum/reagent/consumable/ethanol/irish_cactus
	name = "Irish Cactus"
	id = "irish_cactus"
	description = "Irish Cactus"
	reagent_state = LIQUID
	color = "#f0ffff"
	alcohol_perc = 0.2
	drink_icon = "irish_cactus"
	drink_name = "Irish Cactus"
	drink_desc = "A simple but surprisingly pleasant mix of irish cream and tequila."
	taste_description = "a fruity dessert"

/datum/reagent/consumable/ethanol/irish_flag
	name = "Irish Flag"
	id = "irish_flag"
	description = "Irish Flag"
	reagent_state = LIQUID
	color = "#f0ffff"
	alcohol_perc = 0.2
	drink_icon = "irish_flag_shot"
	drink_name = "Irish Flag"
	drink_desc = "A layered shot particularly loved by people who love irish culture and have never been to ireland."
	taste_description = "patriotism?"

/datum/reagent/consumable/ethanol/jelly_bean
	name = "Jelly Bean"
	id = "jelly_bean"
	description = "Jelly Bean"
	reagent_state = LIQUID
	color = "#f0ffff"
	alcohol_perc = 0.2
	drink_icon = "jelly_bean"
	drink_name = "Jelly Bean"
	drink_desc = "A sweet and glowing cocktail that tastes like candy."
	taste_description = "a fruity girl drink"

/datum/reagent/consumable/ethanol/kamikaze
	name = "Kamikaze"
	id = "kamikaze"
	description = "Kamikaze"
	reagent_state = LIQUID
	color = "#f0ffff"
	alcohol_perc = 0.2
	drink_icon = "kamikaze"
	drink_name = "Kamikaze"
	drink_desc = "A cloudy vodka sour with a strong citrus tang."
	taste_description = "tangy vodka"

/datum/reagent/consumable/ethanol/midnight_millionaire
	name = "Midnight Millionaire"
	id = "midnight_millionaire"
	description = "Midnight Millionaire"
	reagent_state = LIQUID
	color = "#f0ffff"
	alcohol_perc = 0.4
	drink_icon = "midnight_millionaire"
	drink_name = "Midnight Millionaire"
	drink_desc = "For when your champagne is not making you drunk enough."
	taste_description = "champaigne and vodka"

/datum/reagent/consumable/ethanol/mimosa
	name = "Mimosa"
	id = "mimosa"
	description = "Mimosa"
	reagent_state = LIQUID
	color = "#b3b3b3"
	alcohol_perc = 0.4
	drink_icon = "mimosa"
	drink_name = "Mimosa"
	drink_desc = "A fizzy screwdriver."
	taste_description = "fizzy alcoholic orange juice"

/datum/reagent/consumable/ethanol/para_cuba
	name = "Para Cuba"
	id = "para_cuba"
	description = "Para Cuba"
	reagent_state = LIQUID
	color = "#f08080"
	alcohol_perc = 0.4
	drink_icon = "para_cuba"
	drink_name = "Para Cuba"
	drink_desc = "A bright red rum-based fruit cocktail."
	taste_description = "fruity rum"

/datum/reagent/consumable/ethanol/pina_colada
	name = "Pina Colada"
	id = "pina_colada"
	description = "Pina Colada"
	reagent_state = LIQUID
	color = "#00FFFF"
	alcohol_perc = 0.4
	drink_icon = "pina_colada"
	drink_name = "Pina Colada"
	drink_desc = "A bright yellow rum-based fruit cocktail."
	taste_description = "tropical rum"

/datum/reagent/consumable/ethanol/pink_squirrel
	name = "Pink Squirrel"
	id = "pink_squirrel"
	description = "Pink Squirrel"
	reagent_state = LIQUID
	color = "#ffB0B0"
	alcohol_perc = 0.4
	drink_icon = "pink_squirrel"
	drink_name = "Pink Squirrel"
	drink_desc = "A creamy, almond-flavoured cocktail."
	taste_description = "delicious poison"

/datum/reagent/consumable/ethanol/purple_passion
	name = "Purple Passion"
	id = "purple_passion"
	description = "Purple Passion"
	reagent_state = LIQUID
	color = "#ffB0B0"
	alcohol_perc = 0.4
	drink_icon = "purple_passion"
	drink_name = "Purple Passion"
	drink_desc = "A refreshing, bitter citrus cocktail with vodka."
	taste_description = "bitter citrus"

/datum/reagent/consumable/ethanol/showbiz
	name = "Showbiz"
	id = "showbiz"
	description = "Showbiz"
	reagent_state = LIQUID
	color = "#ffB0B0"
	alcohol_perc = 0.4
	drink_icon = "showbiz"
	drink_name = "Showbiz"
	drink_desc = "Sweet blackcurrant soured with grapefruit and fortified with vodka."
	taste_description = "berries and citrus"

/datum/reagent/consumable/ethanol/traffic_light
	name = "Traffic Light"
	id = "traffic_light"
	description = "Traffic Light"
	reagent_state = LIQUID
	color = "#ffB0B0"
	alcohol_perc = 0.4
	drink_icon = "traffic_light"
	drink_name = "Traffic Light"
	drink_desc = "A layered cocktail with cranberry juice, orange juice and absinthe. Zero to a hundred real quick."
	taste_description = "a roaring engine"

/datum/reagent/consumable/ethanol/winter_chill
	name = "Winter Chill"
	id = "winter_chill"
	description = "Winter Chill"
	reagent_state = LIQUID
	color = "#B0B0FF"
	alcohol_perc = 0.4
	drink_icon = "winter_chill"
	drink_name = "Winter Chill"
	drink_desc = "An orange-flavoured cocktail that's blue for some reason."
	taste_description = "refreshment"

/datum/reagent/consumable/ethanol/zipper
	name = "Zipper"
	id = "zipper"
	description = "Zipper"
	reagent_state = LIQUID
	color = "#B0B0FF"
	alcohol_perc = 0.4
	drink_icon = "zipper"
	drink_name = "Zipper"
	drink_desc = "A zesty raspberry cocktail with a touch of soda."
	taste_description = "sparkles"

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
	if(!M.isSynthetic())
		holder.remove_reagent(id, 3.6) //gets removed from organics very fast
		if(prob(25))
			holder.remove_reagent(id, 15)
			M.fakevomit()
	return ..()

/datum/reagent/consumable/ethanol/synthanol/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(M.isSynthetic())
		return
	if(method == INGEST)
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

/datum/reagent/consumable/ethanol/synthanol/devskiss
	name = "Devs Kiss"
	id = "devskiss"
	description = "Like a devils kiss, but for robots."
	reagent_state = LIQUID
	color = "#d004e7"
	alcohol_perc = 0.3
	drink_icon = "devs_kiss"
	drink_name = "Devs Kiss"
	drink_desc = "Dedicated to the good men and women who slaved over many a sleepless night to grant robots the ability to get drunk."
	taste_description = "crunch time"

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
	drink_icon = "glass_brown2"
	drink_name = "Bacchus' Blessing"
	drink_desc = "You didn't think it was possible for a liquid to be so utterly revolting. Are you sure about this...?"
	taste_description = "a wall of bricks"
