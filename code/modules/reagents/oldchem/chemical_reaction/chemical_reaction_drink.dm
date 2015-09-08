/datum/chemical_reaction/

	hot_coco
		name = "Hot Coco"
		id = "hot_coco"
		result = "hot_coco"
		required_reagents = list("water" = 5, "coco" = 1)
		result_amount = 5

	chocolate_milk
		name = "Chocolate Milk"
		id = "chocolate_milk"
		result = "chocolate_milk"
		required_reagents = list("chocolate" = 1, "milk" = 1)
		result_amount = 2
		mix_message = "The mixture turns a nice brown color."

	coffee
		name = "Coffee"
		id = "coffee"
		result = "coffee"
		required_reagents = list("coffeepowder" = 1, "water" = 5)
		result_amount = 5

	tea
		name = "Tea"
		id = "tea"
		result = "tea"
		required_reagents = list("teapowder" = 1, "water" = 5)
		result_amount = 5




	goldschlager
		name = "Goldschlager"
		id = "goldschlager"
		result = "goldschlager"
		required_reagents = list("vodka" = 10, "gold" = 1)
		result_amount = 10

	patron
		name = "Patron"
		id = "patron"
		result = "patron"
		required_reagents = list("tequilla" = 10, "silver" = 1)
		result_amount = 10

	bilk
		name = "Bilk"
		id = "bilk"
		result = "bilk"
		required_reagents = list("milk" = 1, "beer" = 1)
		result_amount = 2

	icetea
		name = "Iced Tea"
		id = "icetea"
		result = "icetea"
		required_reagents = list("ice" = 1, "tea" = 3)
		result_amount = 4

	icecoffee
		name = "Iced Coffee"
		id = "icecoffee"
		result = "icecoffee"
		required_reagents = list("ice" = 1, "coffee" = 3)
		result_amount = 4

	nuka_cola
		name = "Nuka Cola"
		id = "nuka_cola"
		result = "nuka_cola"
		required_reagents = list("uranium" = 1, "cola" = 6)
		result_amount = 6

	moonshine
		name = "Moonshine"
		id = "moonshine"
		result = "moonshine"
		required_reagents = list("nutriment" = 10)
		required_catalysts = list("enzyme" = 5)
		result_amount = 10

	wine
		name = "Wine"
		id = "wine"
		result = "wine"
		required_reagents = list("berryjuice" = 10)
		required_catalysts = list("enzyme" = 5)
		result_amount = 10

	spacebeer
		name = "Space Beer"
		id = "spacebeer"
		result = "beer"
		required_reagents = list("cornoil" = 10)
		required_catalysts = list("enzyme" = 5)
		result_amount = 10

	vodka
		name = "Vodka"
		id = "vodka"
		result = "vodka"
		required_reagents = list("potato" = 10)
		required_catalysts = list("enzyme" = 5)
		result_amount = 10
	sake
		name = "Sake"
		id = "sake"
		result = "sake"
		required_reagents = list("rice" = 10,"water" = 5)
		required_catalysts = list("enzyme" = 5)
		result_amount = 15

	kahlua
		name = "Kahlua"
		id = "kahlua"
		result = "kahlua"
		required_reagents = list("coffee" = 5, "sugar" = 5, "rum" = 5)
		required_catalysts = list("enzyme" = 5)
		result_amount = 5

	kahluaVodka
		name = "KahluaVodka"
		id = "kahlauVodka"
		result = "kahlua"
		required_reagents = list("coffee" = 5, "sugar" = 5, "vodka" = 5)
		required_catalysts = list("enzyme" = 5)
		result_amount = 5
	gin_tonic
		name = "Gin and Tonic"
		id = "gintonic"
		result = "gintonic"
		required_reagents = list("gin" = 2, "tonic" = 1)
		result_amount = 3
		mix_message = "The tonic water and gin mix together perfectly."

	cuba_libre
		name = "Cuba Libre"
		id = "cubalibre"
		result = "cubalibre"
		required_reagents = list("rum" = 2, "cola" = 1)
		result_amount = 3

	mojito
		name = "Mojito"
		id = "mojito"
		result = "mojito"
		required_reagents = list("rum" = 1, "sugar" = 1, "limejuice" = 1, "sodawater" = 1)
		result_amount = 4

	martini
		name = "Classic Martini"
		id = "martini"
		result = "martini"
		required_reagents = list("gin" = 2, "vermouth" = 1)
		result_amount = 3

	vodkamartini
		name = "Vodka Martini"
		id = "vodkamartini"
		result = "vodkamartini"
		required_reagents = list("vodka" = 2, "vermouth" = 1)
		result_amount = 3

	white_russian
		name = "White Russian"
		id = "whiterussian"
		result = "whiterussian"
		required_reagents = list("blackrussian" = 3, "cream" = 2)
		result_amount = 5

	whiskey_cola
		name = "Whiskey Cola"
		id = "whiskeycola"
		result = "whiskeycola"
		required_reagents = list("whiskey" = 2, "cola" = 1)
		result_amount = 3

	screwdriver
		name = "Screwdriver"
		id = "screwdrivercocktail"
		result = "screwdrivercocktail"
		required_reagents = list("vodka" = 2, "orangejuice" = 1)
		result_amount = 3

	bloody_mary
		name = "Bloody Mary"
		id = "bloodymary"
		result = "bloodymary"
		required_reagents = list("vodka" = 1, "tomatojuice" = 2, "limejuice" = 1)
		result_amount = 4

	gargle_blaster
		name = "Pan-Galactic Gargle Blaster"
		id = "gargleblaster"
		result = "gargleblaster"
		required_reagents = list("vodka" = 1, "gin" = 1, "whiskey" = 1, "cognac" = 1, "limejuice" = 1)
		result_amount = 5

	brave_bull
		name = "Brave Bull"
		id = "bravebull"
		result = "bravebull"
		required_reagents = list("tequilla" = 2, "kahlua" = 1)
		result_amount = 3

	tequilla_sunrise
		name = "Tequilla Sunrise"
		id = "tequillasunrise"
		result = "tequillasunrise"
		required_reagents = list("tequilla" = 2, "orangejuice" = 1)
		result_amount = 3

	toxins_special
		name = "Toxins Special"
		id = "toxinsspecial"
		result = "toxinsspecial"
		required_reagents = list("rum" = 2, "vermouth" = 1, "plasma" = 2)
		result_amount = 5

	beepsky_smash
		name = "Beepksy Smash"
		id = "beepksysmash"
		result = "beepskysmash"
		required_reagents = list("limejuice" = 2, "whiskey" = 2, "iron" = 1)
		result_amount = 4

	doctor_delight
		name = "The Doctor's Delight"
		id = "doctordelight"
		result = "doctorsdelight"
		required_reagents = list("limejuice" = 1, "tomatojuice" = 1, "orangejuice" = 1, "cream" = 1)
		result_amount = 5

	irish_cream
		name = "Irish Cream"
		id = "irishcream"
		result = "irishcream"
		required_reagents = list("whiskey" = 2, "cream" = 1)
		result_amount = 3

	manly_dorf
		name = "The Manly Dorf"
		id = "manlydorf"
		result = "manlydorf"
		required_reagents = list ("beer" = 1, "ale" = 2)
		result_amount = 3

	suicider
		name = "Suicider"
		id = "suicider"
		result = "suicider"
		required_reagents = list ("vodka" = 1, "cider" = 1, "fuel" = 1, "epinephrine" = 1)
		result_amount = 4
		mix_message = "The drinks and chemicals mix together, emitting a potent smell."

	irish_coffee
		name = "Irish Coffee"
		id = "irishcoffee"
		result = "irishcoffee"
		required_reagents = list("irishcream" = 1, "coffee" = 1)
		result_amount = 2

	b52
		name = "B-52"
		id = "b52"
		result = "b52"
		required_reagents = list("irishcream" = 1, "kahlua" = 1, "cognac" = 1)
		result_amount = 3

	atomicbomb
		name = "Atomic Bomb"
		id = "atomicbomb"
		result = "atomicbomb"
		required_reagents = list("b52" = 10, "uranium" = 1)
		result_amount = 10

	margarita
		name = "Margarita"
		id = "margarita"
		result = "margarita"
		required_reagents = list("tequilla" = 2, "limejuice" = 1)
		result_amount = 3

	longislandicedtea
		name = "Long Island Iced Tea"
		id = "longislandicedtea"
		result = "longislandicedtea"
		required_reagents = list("vodka" = 1, "gin" = 1, "tequilla" = 1, "cubalibre" = 1)
		result_amount = 4

	threemileisland
		name = "Three Mile Island Iced Tea"
		id = "threemileisland"
		result = "threemileisland"
		required_reagents = list("longislandicedtea" = 10, "uranium" = 1)
		result_amount = 10

	whiskeysoda
		name = "Whiskey Soda"
		id = "whiskeysoda"
		result = "whiskeysoda"
		required_reagents = list("whiskey" = 2, "sodawater" = 1)
		result_amount = 3

	black_russian
		name = "Black Russian"
		id = "blackrussian"
		result = "blackrussian"
		required_reagents = list("vodka" = 3, "kahlua" = 2)
		result_amount = 5

	manhattan
		name = "Manhattan"
		id = "manhattan"
		result = "manhattan"
		required_reagents = list("whiskey" = 2, "vermouth" = 1)
		result_amount = 3

	manhattan_proj
		name = "Manhattan Project"
		id = "manhattan_proj"
		result = "manhattan_proj"
		required_reagents = list("manhattan" = 10, "uranium" = 1)
		result_amount = 10

	vodka_tonic
		name = "Vodka and Tonic"
		id = "vodkatonic"
		result = "vodkatonic"
		required_reagents = list("vodka" = 2, "tonic" = 1)
		result_amount = 3

	gin_fizz
		name = "Gin Fizz"
		id = "ginfizz"
		result = "ginfizz"
		required_reagents = list("gin" = 2, "sodawater" = 1, "limejuice" = 1)
		result_amount = 4

	bahama_mama
		name = "Bahama mama"
		id = "bahama_mama"
		result = "bahama_mama"
		required_reagents = list("rum" = 2, "orangejuice" = 2, "limejuice" = 1, "ice" = 1)
		result_amount = 6

	singulo
		name = "Singulo"
		id = "singulo"
		result = "singulo"
		required_reagents = list("vodka" = 5, "radium" = 1, "wine" = 5)
		result_amount = 10

	alliescocktail
		name = "Allies Cocktail"
		id = "alliescocktail"
		result = "alliescocktail"
		required_reagents = list("martini" = 1, "vodka" = 1)
		result_amount = 2

	demonsblood
		name = "Demons Blood"
		id = "demonsblood"
		result = "demonsblood"
		required_reagents = list("rum" = 1, "spacemountainwind" = 1, "blood" = 1, "dr_gibb" = 1)
		result_amount = 4

	booger
		name = "Booger"
		id = "booger"
		result = "booger"
		required_reagents = list("cream" = 1, "banana" = 1, "rum" = 1, "watermelonjuice" = 1)
		result_amount = 4

	antifreeze
		name = "Anti-freeze"
		id = "antifreeze"
		result = "antifreeze"
		required_reagents = list("vodka" = 2, "cream" = 1, "ice" = 1)
		result_amount = 4

	barefoot
		name = "Barefoot"
		id = "barefoot"
		result = "barefoot"
		required_reagents = list("berryjuice" = 1, "cream" = 1, "vermouth" = 1)
		result_amount = 3


////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

	sbiten
		name = "Sbiten"
		id = "sbiten"
		result = "sbiten"
		required_reagents = list("vodka" = 10, "capsaicin" = 1)
		result_amount = 10

	red_mead
		name = "Red Mead"
		id = "red_mead"
		result = "red_mead"
		required_reagents = list("blood" = 1, "mead" = 1)
		result_amount = 2

	mead
		name = "Mead"
		id = "mead"
		result = "mead"
		required_reagents = list("sugar" = 1, "water" = 1)
		required_catalysts = list("enzyme" = 5)
		result_amount = 2

	iced_beer
		name = "Iced Beer"
		id = "iced_beer"
		result = "iced_beer"
		required_reagents = list("beer" = 10, "frostoil" = 1)
		result_amount = 10

	iced_beer2
		name = "Iced Beer"
		id = "iced_beer"
		result = "iced_beer"
		required_reagents = list("beer" = 5, "ice" = 1)
		result_amount = 6

	grog
		name = "Grog"
		id = "grog"
		result = "grog"
		required_reagents = list("rum" = 1, "water" = 1)
		result_amount = 2

	soy_latte
		name = "Soy Latte"
		id = "soy_latte"
		result = "soy_latte"
		required_reagents = list("coffee" = 1, "soymilk" = 1)
		result_amount = 2

	cafe_latte
		name = "Cafe Latte"
		id = "cafe_latte"
		result = "cafe_latte"
		required_reagents = list("coffee" = 1, "milk" = 1)
		result_amount = 2

	acidspit
		name = "Acid Spit"
		id = "acidspit"
		result = "acidspit"
		required_reagents = list("sacid" = 1, "wine" = 5)
		result_amount = 6

	amasec
		name = "Amasec"
		id = "amasec"
		result = "amasec"
		required_reagents = list("iron" = 1, "wine" = 5, "vodka" = 5)
		result_amount = 10

	changelingsting
		name = "Changeling Sting"
		id = "changelingsting"
		result = "changelingsting"
		required_reagents = list("screwdrivercocktail" = 1, "limejuice" = 1, "lemonjuice" = 1)
		result_amount = 5

	aloe
		name = "Aloe"
		id = "aloe"
		result = "aloe"
		required_reagents = list("cream" = 1, "whiskey" = 1, "watermelonjuice" = 1)
		result_amount = 2

	andalusia
		name = "Andalusia"
		id = "andalusia"
		result = "andalusia"
		required_reagents = list("rum" = 1, "whiskey" = 1, "lemonjuice" = 1)
		result_amount = 3

	neurotoxin
		name = "Neurotoxin"
		id = "neurotoxin"
		result = "neurotoxin"
		required_reagents = list("gargleblaster" = 1, "ether" = 1)
		result_amount = 2

	snowwhite
		name = "Snow White"
		id = "snowwhite"
		result = "snowwhite"
		required_reagents = list("beer" = 1, "lemon_lime" = 1)
		result_amount = 2

	irishcarbomb
		name = "Irish Car Bomb"
		id = "irishcarbomb"
		result = "irishcarbomb"
		required_reagents = list("ale" = 1, "irishcream" = 1)
		result_amount = 2

	syndicatebomb
		name = "Syndicate Bomb"
		id = "syndicatebomb"
		result = "syndicatebomb"
		required_reagents = list("beer" = 1, "whiskeycola" = 1)
		result_amount = 2

	erikasurprise
		name = "Erika Surprise"
		id = "erikasurprise"
		result = "erikasurprise"
		required_reagents = list("ale" = 1, "limejuice" = 1, "whiskey" = 1, "banana" = 1, "ice" = 1)
		result_amount = 5

	devilskiss
		name = "Devils Kiss"
		id = "devilskiss"
		result = "devilskiss"
		required_reagents = list("blood" = 1, "kahlua" = 1, "rum" = 1)
		result_amount = 3

	hippiesdelight
		name = "Hippies Delight"
		id = "hippiesdelight"
		result = "hippiesdelight"
		required_reagents = list("psilocybin" = 1, "gargleblaster" = 1)
		result_amount = 2

	bananahonk
		name = "Banana Honk"
		id = "bananahonk"
		result = "bananahonk"
		required_reagents = list("banana" = 1, "cream" = 1, "sugar" = 1)
		result_amount = 3

	silencer
		name = "Silencer"
		id = "silencer"
		result = "silencer"
		required_reagents = list("nothing" = 1, "cream" = 1, "sugar" = 1)
		result_amount = 3

	driestmartini
		name = "Driest Martini"
		id = "driestmartini"
		result = "driestmartini"
		required_reagents = list("nothing" = 1, "gin" = 1)
		result_amount = 2

	lemonade
		name = "Lemonade"
		id = "lemonade"
		result = "lemonade"
		required_reagents = list("lemonjuice" = 1, "sugar" = 1, "water" = 1)
		result_amount = 3

	kiraspecial
		name = "Kira Special"
		id = "kiraspecial"
		result = "kiraspecial"
		required_reagents = list("orangejuice" = 1, "limejuice" = 1, "sodawater" = 1)
		result_amount = 2

	brownstar
		name = "Brown Star"
		id = "brownstar"
		result = "brownstar"
		required_reagents = list("orangejuice" = 2, "cola" = 1)
		result_amount = 2

	milkshake
		name = "Milkshake"
		id = "milkshake"
		result = "milkshake"
		required_reagents = list("cream" = 1, "ice" = 2, "milk" = 2)
		result_amount = 5

	rewriter
		name = "Rewriter"
		id = "rewriter"
		result = "rewriter"
		required_reagents = list("spacemountainwind" = 1, "coffee" = 1)
		result_amount = 2