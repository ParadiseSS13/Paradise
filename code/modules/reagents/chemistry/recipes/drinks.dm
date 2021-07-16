
/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = "hot_coco"
	result = /datum/reagent/consumable/hot_coco
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/cocoa = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/chocolate_milk
	name = "Chocolate Milk"
	id = "chocolate_milk"
	result = /datum/reagent/consumable/drink/milk/chocolate_milk
	required_reagents = list(/datum/reagent/consumable/chocolate = 1, /datum/reagent/consumable/drink/milk = 1)
	result_amount = 2
	mix_message = "The mixture turns a nice brown color."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/coffee
	name = "Coffee"
	id = "coffee"
	result = /datum/reagent/consumable/drink/coffee
	required_reagents = list(/datum/reagent/toxin/coffeepowder = 1, /datum/reagent/water = 5)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/tea
	name = "Tea"
	id = "tea"
	result = /datum/reagent/consumable/drink/tea
	required_reagents = list(/datum/reagent/toxin/teapowder = 1, /datum/reagent/water = 5)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	result = /datum/reagent/consumable/ethanol/goldschlager
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 10, /datum/reagent/gold = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/patron
	name = "Patron"
	id = "patron"
	result = /datum/reagent/consumable/ethanol/patron
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 10, /datum/reagent/silver = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/bilk
	name = "Bilk"
	id = "bilk"
	result = /datum/reagent/consumable/ethanol/bilk
	required_reagents = list(/datum/reagent/consumable/drink/milk = 1, /datum/reagent/consumable/ethanol/beer = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/icetea
	name = "Iced Tea"
	id = "icetea"
	result = /datum/reagent/consumable/drink/tea/icetea
	required_reagents = list(/datum/reagent/consumable/drink/cold/ice = 1, /datum/reagent/consumable/drink/tea = 3)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	result = /datum/reagent/consumable/drink/coffee/icecoffee
	required_reagents = list(/datum/reagent/consumable/drink/cold/ice = 1, /datum/reagent/consumable/drink/coffee = 3)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	result = /datum/reagent/consumable/drink/cold/nuka_cola
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/consumable/drink/cold/space_cola = 6)
	result_amount = 6
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/moonshine
	name = "Moonshine"
	id = "moonshine"
	result = /datum/reagent/consumable/ethanol/moonshine
	required_reagents = list(/datum/reagent/consumable/nutriment = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/wine
	name = "Wine"
	id = "wine"
	result = /datum/reagent/consumable/ethanol/wine
	required_reagents = list(/datum/reagent/consumable/drink/grapejuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/spacebeer
	name = "Space Beer"
	id = "spacebeer"
	result = /datum/reagent/consumable/ethanol/beer
	required_reagents = list(/datum/reagent/consumable/cornoil = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/vodka
	name = "Vodka"
	id = "vodka"
	result = /datum/reagent/consumable/ethanol/vodka
	required_reagents = list(/datum/reagent/consumable/drink/potato_juice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/sake
	name = "Sake"
	id = "sake"
	result = /datum/reagent/consumable/ethanol/sake
	required_reagents = list(/datum/reagent/consumable/rice = 10, /datum/reagent/water = 5)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	result_amount = 15
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/kahlua
	name = "Kahlua"
	id = "kahlua"
	result = /datum/reagent/consumable/ethanol/kahlua
	required_reagents = list(/datum/reagent/consumable/drink/coffee = 5, /datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/ethanol/rum = 5)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/kahluaVodka
	name = "KahluaVodka"
	id = "kahlauVodka"
	result = /datum/reagent/consumable/ethanol/kahlua
	required_reagents = list(/datum/reagent/consumable/drink/coffee = 5, /datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/ethanol/vodka = 5)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	id = "gintonic"
	result = /datum/reagent/consumable/ethanol/gintonic
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/drink/cold/tonic = 1)
	result_amount = 3
	mix_message = "The tonic water and gin mix together perfectly."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	result = /datum/reagent/consumable/ethanol/cuba_libre
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/drink/cold/space_cola = 2, /datum/reagent/consumable/drink/limejuice = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/mojito
	name = "Mojito"
	id = "mojito"
	result = /datum/reagent/consumable/ethanol/mojito
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/cold/sodawater = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/martini
	name = "Classic Martini"
	id = "martini"
	result = /datum/reagent/consumable/ethanol/martini
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/ethanol/vermouth = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	result = /datum/reagent/consumable/ethanol/vodkamartini
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/ethanol/vermouth = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/white_russian
	name = "White Russian"
	id = "whiterussian"
	result = /datum/reagent/consumable/ethanol/white_russian
	required_reagents = list(/datum/reagent/consumable/ethanol/black_russian = 3, /datum/reagent/consumable/drink/milk/cream = 2)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	result = /datum/reagent/consumable/ethanol/whiskey_cola
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/drink/cold/space_cola = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	id = "screwdrivercocktail"
	result = /datum/reagent/consumable/ethanol/screwdrivercocktail
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/drink/orangejuice = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	result = /datum/reagent/consumable/ethanol/bloody_mary
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/drink/tomatojuice = 2, /datum/reagent/consumable/drink/limejuice = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	result = /datum/reagent/consumable/ethanol/gargle_blaster
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/ethanol/cognac = 1, /datum/reagent/consumable/drink/limejuice = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/flaming_homer
	name = "Flaming Moe"
	id = "flamingmoe"
	result = /datum/reagent/consumable/ethanol/flaming_homer
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/cognac = 1, /datum/reagent/consumable/ethanol/tequila = 1, /datum/reagent/medicine/salglu_solution = 1) //Close enough
	min_temp = T0C + 100 //Fire makes it good!
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'
	mix_message = "The concoction bursts into flame!"

/datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	result = /datum/reagent/consumable/ethanol/brave_bull
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/ethanol/kahlua = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/tequila_sunrise
	name = "Tequila Sunrise"
	id = "tequilasunrise"
	result = /datum/reagent/consumable/ethanol/tequila_sunrise
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/drink/orangejuice = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/toxins_special
	name = "Toxins Special"
	id = "toxinsspecial"
	result = /datum/reagent/consumable/ethanol/toxins_special
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/ethanol/vermouth = 1, /datum/reagent/plasma = 2)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/beepsky_smash
	name = "Beepksy Smash"
	id = "beepksysmash"
	result = /datum/reagent/consumable/ethanol/beepsky_smash
	required_reagents = list(/datum/reagent/consumable/drink/limejuice = 2, /datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/iron = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	id = "doctordelight"
	result = /datum/reagent/consumable/drink/doctor_delight
	required_reagents = list(/datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/tomatojuice = 1, /datum/reagent/consumable/drink/orangejuice = 1, /datum/reagent/consumable/drink/milk/cream = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	result = /datum/reagent/consumable/ethanol/irish_cream
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/drink/milk/cream = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	result = /datum/reagent/consumable/ethanol/manly_dorf
	required_reagents = list (/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/ale = 2)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/suicider
	name = "Suicider"
	id = "suicider"
	result = /datum/reagent/consumable/ethanol/suicider
	required_reagents = list (/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/cider = 1, /datum/reagent/fuel = 1, /datum/reagent/medicine/epinephrine = 1)
	result_amount = 4
	mix_message = "The drinks and chemicals mix together, emitting a potent smell."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	id = "irishcoffee"
	result = /datum/reagent/consumable/ethanol/irishcoffee
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/drink/coffee = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/b52
	name = "B-52"
	id = "b52"
	result = /datum/reagent/consumable/ethanol/b52
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/cognac = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	result = /datum/reagent/consumable/ethanol/atomicbomb
	required_reagents = list(/datum/reagent/consumable/ethanol/b52 = 10, /datum/reagent/uranium = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/margarita
	name = "Margarita"
	id = "margarita"
	result = /datum/reagent/consumable/ethanol/margarita
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/drink/limejuice = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	result = /datum/reagent/consumable/ethanol/longislandicedtea
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/tequila = 1, /datum/reagent/consumable/ethanol/cuba_libre = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	result = /datum/reagent/consumable/ethanol/threemileisland
	required_reagents = list(/datum/reagent/consumable/ethanol/longislandicedtea = 10, /datum/reagent/uranium = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	result = /datum/reagent/consumable/ethanol/whiskeysoda
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/drink/cold/sodawater = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/black_russian
	name = "Black Russian"
	id = "blackrussian"
	result = /datum/reagent/consumable/ethanol/black_russian
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 3, /datum/reagent/consumable/ethanol/kahlua = 2)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/manhattan
	name = "Manhattan"
	id = "manhattan"
	result = /datum/reagent/consumable/ethanol/manhattan
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/ethanol/vermouth = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	result = /datum/reagent/consumable/ethanol/manhattan_proj
	required_reagents = list(/datum/reagent/consumable/ethanol/manhattan = 10, /datum/reagent/uranium = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	result = /datum/reagent/consumable/ethanol/vodkatonic
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/drink/cold/tonic = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	id = "ginfizz"
	result = /datum/reagent/consumable/ethanol/ginfizz
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/drink/cold/sodawater = 1, /datum/reagent/consumable/drink/limejuice = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	result = /datum/reagent/consumable/ethanol/bahama_mama
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/drink/orangejuice = 2, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/cold/ice = 1)
	result_amount = 6
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/singulo
	name = "Singulo"
	id = "singulo"
	result = /datum/reagent/consumable/ethanol/singulo
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 5, /datum/reagent/radium = 1, /datum/reagent/consumable/ethanol/wine = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	result = /datum/reagent/consumable/ethanol/alliescocktail
	required_reagents = list(/datum/reagent/consumable/ethanol/martini = 1, /datum/reagent/consumable/ethanol/vodka = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	result = /datum/reagent/consumable/ethanol/demonsblood
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/drink/cold/spacemountainwind = 1, /datum/reagent/blood = 1, /datum/reagent/consumable/drink/cold/dr_gibb = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/booger
	name = "Booger"
	id = "booger"
	result = /datum/reagent/consumable/ethanol/booger
	required_reagents = list(/datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/drink/banana = 1, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/drink/watermelonjuice = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	result = /datum/reagent/consumable/ethanol/antifreeze
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/drink/cold/ice = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/adminfreeze
	name = "Admin Freeze"
	id = "adminfreeze"
	result = /datum/reagent/consumable/ethanol/adminfreeze
	required_reagents = list(/datum/reagent/consumable/ethanol/neurotoxin = 1, /datum/reagent/consumable/ethanol/toxins_special = 1, /datum/reagent/consumable/ethanol/fernet = 1, /datum/reagent/consumable/ethanol/moonshine = 1, /datum/reagent/medicine/morphine = 1)
	min_temp = T0C + 100
	result_amount = 5
	mix_sound = 'sound/effects/adminhelp.ogg'

/datum/chemical_reaction/barefoot
	name = "Barefoot"
	id = "barefoot"
	result = /datum/reagent/consumable/ethanol/barefoot
	required_reagents = list(/datum/reagent/consumable/drink/berryjuice = 1, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/ethanol/vermouth = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/daquiri
	name = "Daiquiri"
	id = "daiquiri"
	result = /datum/reagent/consumable/ethanol/daiquiri
	required_reagents = list(/datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/drink/cold/ice = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'


////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

/datum/chemical_reaction/sbiten
	name = "Sbiten"
	id = "sbiten"
	result = /datum/reagent/consumable/ethanol/sbiten
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 10, /datum/reagent/consumable/capsaicin = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/red_mead
	name = "Red Mead"
	id = "red_mead"
	result = /datum/reagent/consumable/ethanol/red_mead
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/ethanol/mead = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/mead
	name = "Mead"
	id = "mead"
	result = /datum/reagent/consumable/ethanol/mead
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/water = 1)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	result = /datum/reagent/consumable/ethanol/iced_beer
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 10, /datum/reagent/consumable/frostoil = 1)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/iced_beer2
	name = "Iced Beer"
	id = "iced_beer"
	result = /datum/reagent/consumable/ethanol/iced_beer
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 5, /datum/reagent/consumable/drink/cold/ice = 1)
	result_amount = 6
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/grog
	name = "Grog"
	id = "grog"
	result = /datum/reagent/consumable/ethanol/grog
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/water = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	result = /datum/reagent/consumable/drink/coffee/soy_latte
	required_reagents = list(/datum/reagent/consumable/drink/coffee = 1, /datum/reagent/consumable/drink/milk/soymilk = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	result = /datum/reagent/consumable/drink/coffee/cafe_latte
	required_reagents = list(/datum/reagent/consumable/drink/coffee = 1, /datum/reagent/consumable/drink/milk = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cafe_mocha
	name = "Cafe Mocha"
	id = "cafe_mocha"
	result = /datum/reagent/consumable/drink/coffee/cafe_latte/cafe_mocha
	required_reagents = list(/datum/reagent/consumable/drink/coffee/cafe_latte = 1, /datum/reagent/consumable/chocolate = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/acidspit
	name = "Acid Spit"
	id = "acidspit"
	result = /datum/reagent/consumable/ethanol/acid_spit
	required_reagents = list(/datum/reagent/acid = 1, /datum/reagent/consumable/ethanol/wine = 5)
	result_amount = 6
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/amasec
	name = "Amasec"
	id = "amasec"
	result = /datum/reagent/consumable/ethanol/amasec
	required_reagents = list(/datum/reagent/iron = 1, /datum/reagent/consumable/ethanol/wine = 5, /datum/reagent/consumable/ethanol/vodka = 5)
	result_amount = 10
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	result = /datum/reagent/consumable/ethanol/changelingsting
	required_reagents = list(/datum/reagent/consumable/ethanol/screwdrivercocktail = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/lemonjuice = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/aloe
	name = "Aloe"
	id = "aloe"
	result = /datum/reagent/consumable/ethanol/aloe
	required_reagents = list(/datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/drink/watermelonjuice = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/andalusia
	name = "Andalusia"
	id = "andalusia"
	result = /datum/reagent/consumable/ethanol/andalusia
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/drink/lemonjuice = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	result = /datum/reagent/consumable/ethanol/neurotoxin
	required_reagents = list(/datum/reagent/consumable/ethanol/gargle_blaster = 1, /datum/reagent/medicine/ether = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/snowwhite
	name = "Snow White"
	id = "snowwhite"
	result = /datum/reagent/consumable/ethanol/snowwhite
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/drink/cold/lemon_lime = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	result = /datum/reagent/consumable/ethanol/irishcarbomb
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, /datum/reagent/consumable/ethanol/irish_cream = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	result = /datum/reagent/consumable/ethanol/syndicatebomb
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/whiskey_cola = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	result = /datum/reagent/consumable/ethanol/erikasurprise
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/drink/banana = 1, /datum/reagent/consumable/drink/cold/ice = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	result = /datum/reagent/consumable/ethanol/devilskiss
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/rum = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	id = "hippiesdelight"
	result = /datum/reagent/consumable/ethanol/hippies_delight
	required_reagents = list(/datum/reagent/psilocybin = 1, /datum/reagent/consumable/ethanol/gargle_blaster = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	id = "bananahonk"
	result = /datum/reagent/consumable/drink/bananahonk
	required_reagents = list(/datum/reagent/consumable/drink/banana = 1, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/sugar = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/silencer
	name = "Silencer"
	id = "silencer"
	result = /datum/reagent/consumable/drink/silencer
	required_reagents = list(/datum/reagent/consumable/drink/nothing = 1, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/sugar = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	result = /datum/reagent/consumable/ethanol/driestmartini
	required_reagents = list(/datum/reagent/consumable/drink/nothing = 1, /datum/reagent/consumable/ethanol/gin = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/lemonade
	name = "Lemonade"
	id = "lemonade"
	result = /datum/reagent/consumable/drink/cold/lemonade
	required_reagents = list(/datum/reagent/consumable/drink/lemonjuice = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/water = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/kiraspecial
	name = "Kira Special"
	id = "kiraspecial"
	result = /datum/reagent/consumable/drink/cold/kiraspecial
	required_reagents = list(/datum/reagent/consumable/drink/orangejuice = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/cold/sodawater = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/brownstar
	name = "Brown Star"
	id = "brownstar"
	result = /datum/reagent/consumable/drink/cold/brownstar
	required_reagents = list(/datum/reagent/consumable/drink/orangejuice = 2, /datum/reagent/consumable/drink/cold/space_cola = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/milkshake
	name = "Milkshake"
	id = "milkshake"
	result = /datum/reagent/consumable/drink/cold/milkshake
	required_reagents = list(/datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/drink/cold/ice = 2, /datum/reagent/consumable/drink/milk = 2)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/rewriter
	name = "Rewriter"
	id = "rewriter"
	result = /datum/reagent/consumable/drink/cold/rewriter
	required_reagents = list(/datum/reagent/consumable/drink/cold/spacemountainwind = 1, /datum/reagent/consumable/drink/coffee = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/ginsonic
	name = "ginsonic"
	id = "ginsonic"
	result = /datum/reagent/ginsonic
	required_reagents = list(/datum/reagent/consumable/ethanol/gintonic = 1, /datum/reagent/methamphetamine = 1)
	result_amount = 2
	mix_message = "The drink turns electric blue and starts quivering violently."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/applejack
	name = "applejack"
	id = "applejack"
	result = /datum/reagent/consumable/ethanol/applejack
	required_reagents = list(/datum/reagent/consumable/ethanol/cider = 2)
	max_temp = T0C
	result_amount = 1
	mix_message = "The drink darkens as the water freezes, leaving the concentrated cider behind."
	mix_sound = null

/datum/chemical_reaction/jackrose
	name = "jackrose"
	id = "jackrose"
	result = /datum/reagent/consumable/ethanol/jackrose
	required_reagents = list(/datum/reagent/consumable/ethanol/applejack = 4, /datum/reagent/consumable/drink/lemonjuice = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/synthanol
	name = "Synthanol"
	id = "synthanol"
	result = /datum/reagent/consumable/ethanol/synthanol
	required_reagents = list(/datum/reagent/lube = 1, /datum/reagent/plasma = 1, /datum/reagent/fuel = 1)
	result_amount = 3
	mix_message = "The chemicals mix to create shiny, blue substance."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/synthanol/robottears
	name = "Robot Tears"
	id = "robottears"
	result = /datum/reagent/consumable/ethanol/synthanol/robottears
	required_reagents = list(/datum/reagent/consumable/ethanol/synthanol = 1, /datum/reagent/oil = 1, /datum/reagent/consumable/drink/cold/sodawater = 1)
	result_amount = 3
	mix_message = "The ingredients combine into a stiff, dark goo."

/datum/chemical_reaction/synthanol/trinary
	name = "Trinary"
	id = "trinary"
	result = /datum/reagent/consumable/ethanol/synthanol/trinary
	required_reagents = list(/datum/reagent/consumable/ethanol/synthanol = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/orangejuice = 1)
	result_amount = 3
	mix_message = "The ingredients mix into a colorful substance."

/datum/chemical_reaction/synthanol/servo
	name = "Servo"
	id = "servo"
	result = /datum/reagent/consumable/ethanol/synthanol/servo
	required_reagents = list(/datum/reagent/consumable/ethanol/synthanol = 2, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/hot_coco = 1)
	result_amount = 4
	mix_message = "The ingredients mix into a dark brown substance."

/datum/chemical_reaction/synthanol/uplink
	name = "Uplink"
	id = "uplink"
	result = /datum/reagent/consumable/ethanol/synthanol/uplink
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/tequila = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/ethanol/synthanol = 1)
	result_amount = 5
	mix_message = "The chemicals mix to create a shiny, orange substance."

/datum/chemical_reaction/synthanol/synthnsoda
	name = "Synth 'n Soda"
	id = "synthnsoda"
	result = /datum/reagent/consumable/ethanol/synthanol/synthnsoda
	required_reagents = list(/datum/reagent/consumable/ethanol/synthanol = 1, /datum/reagent/consumable/drink/cold/space_cola = 1)
	result_amount = 2
	mix_message = "The chemicals mix to create a smooth, fizzy substance."

/datum/chemical_reaction/synthanol/synthignon
	name = "Synthignon"
	id = "synthignon"
	result = /datum/reagent/consumable/ethanol/synthanol/synthignon
	required_reagents = list(/datum/reagent/consumable/ethanol/synthanol = 1, /datum/reagent/consumable/ethanol/wine = 1)
	result_amount = 2
	mix_message = "The chemicals mix to create a fine, red substance."

/datum/chemical_reaction/triple_citrus
	name = "triple_citrus"
	id = "triple_citrus"
	result = /datum/reagent/consumable/drink/triple_citrus
	required_reagents = list(/datum/reagent/consumable/drink/lemonjuice = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/orangejuice = 1)
	result_amount = 3
	mix_message = "The citrus juices begin to blend together."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/chocolatepudding
	name = "Chocolate Pudding"
	id = "chocolatepudding"
	result = /datum/reagent/consumable/drink/chocolatepudding
	required_reagents = list(/datum/reagent/consumable/cocoa = 5, /datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/egg = 5)
	result_amount = 20
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/vanillapudding
	name = "Vanilla Pudding"
	id = "vanillapudding"
	result = /datum/reagent/consumable/drink/vanillapudding
	required_reagents = list(/datum/reagent/consumable/vanilla = 5, /datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/egg = 5)
	result_amount = 20
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cherryshake
	name = "Cherry Shake"
	id = "cherryshake"
	result = /datum/reagent/consumable/drink/cherryshake
	required_reagents = list(/datum/reagent/consumable/cherryjelly = 1, /datum/reagent/consumable/drink/cold/ice = 1, /datum/reagent/consumable/drink/milk/cream = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/bluecherryshake
	name = "Blue Cherry Shake"
	id = "bluecherryshake"
	result = /datum/reagent/consumable/drink/bluecherryshake
	required_reagents = list(/datum/reagent/consumable/bluecherryjelly = 1, /datum/reagent/consumable/drink/cold/ice = 1, /datum/reagent/consumable/drink/milk/cream = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/drunkenblumpkin
	name = "Drunken Blumpkin"
	id = "drunkenblumpkin"
	result = /datum/reagent/consumable/ethanol/drunkenblumpkin
	required_reagents = list(/datum/reagent/consumable/drink/blumpkinjuice = 1, /datum/reagent/consumable/ethanol/irish_cream = 2, /datum/reagent/consumable/drink/cold/ice = 1)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/pumpkin_latte
	name = "Pumpkin space latte"
	id = "pumpkin_latte"
	result = /datum/reagent/consumable/drink/pumpkin_latte
	required_reagents = list(/datum/reagent/consumable/drink/pumpkinjuice = 5, /datum/reagent/consumable/drink/coffee = 5, /datum/reagent/consumable/drink/milk/cream = 5)
	result_amount = 15
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/gibbfloats
	name = "Gibb Floats"
	id = "gibbfloats"
	result = /datum/reagent/consumable/drink/gibbfloats
	required_reagents = list(/datum/reagent/consumable/drink/cold/dr_gibb = 5, /datum/reagent/consumable/drink/cold/ice = 5, /datum/reagent/consumable/drink/milk/cream = 5)
	result_amount = 15
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/grape_soda
	name = "grape soda"
	id = "grapesoda"
	result = /datum/reagent/consumable/drink/grape_soda
	required_reagents = list(/datum/reagent/consumable/drink/grapejuice = 1, /datum/reagent/consumable/drink/cold/sodawater = 1)
	result_amount = 2
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/eggnog
	name = "eggnog"
	id = "eggnog"
	result = /datum/reagent/consumable/ethanol/eggnog
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 5, /datum/reagent/consumable/drink/milk/cream = 5, /datum/reagent/consumable/egg = 5)
	result_amount = 15
	mix_message = "The eggs nog together. Pretend that \"nog\" is a verb."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/hooch
	name = "Hooch"
	id = "hooch"
	result = /datum/reagent/consumable/ethanol/hooch
	required_reagents = list(/datum/reagent/consumable/ethanol = 2, /datum/reagent/fuel = 1)
	result_amount = 3
	required_catalysts = list(/datum/reagent/consumable/enzyme = 1)

/datum/chemical_reaction/bacchus_blessing
	name = "Bacchus' Blessing"
	id = "bacchus_blessing"
	result = /datum/reagent/consumable/ethanol/bacchus_blessing
	required_reagents = list(/datum/reagent/consumable/ethanol/hooch = 1, /datum/reagent/consumable/ethanol/absinthe = 1, /datum/reagent/consumable/ethanol/manly_dorf = 1, /datum/reagent/consumable/ethanol/syndicatebomb = 1)
	result_amount = 4
	mix_message = "<span class='warning'>The mixture turns to a sickening froth.</span>"

/datum/chemical_reaction/icecoco
	name = "Iced Cocoa"
	id = "icecoco"
	result = /datum/reagent/consumable/drink/coco/icecoco
	required_reagents = list(/datum/reagent/consumable/drink/cold/ice = 1, /datum/reagent/consumable/hot_coco = 3)
	result_amount = 4
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/fernet_cola
	name = "Fernet Cola"
	id = "fernet_cola"
	result = /datum/reagent/consumable/ethanol/fernet/fernet_cola
	required_reagents = list(/datum/reagent/consumable/ethanol/fernet = 1, /datum/reagent/consumable/drink/cold/space_cola = 2)
	result_amount = 3
	mix_message = "The ingredients mix into a dark brown godly substance"
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'
