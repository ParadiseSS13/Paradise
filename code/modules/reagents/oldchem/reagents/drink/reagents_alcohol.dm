//ALCOHOL WOO
/datum/reagent/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	reagent_state = LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" // rgb: 64, 64, 48
	var/datum/martial_art/drunk_brawling/F = new
	var/dizzy_adj = 3
	var/slurr_adj = 3
	var/confused_adj = 2
	var/slur_start = 65			//amount absorbed after which mob starts slurring
	var/brawl_start = 75		//amount absorbed after which mob switches to drunken brawling as a fighting style
	var/confused_start = 130	//amount absorbed after which mob starts confusing directions
	var/vomit_start = 180	//amount absorbed after which mob starts vomitting
	var/blur_start = 260	//amount absorbed after which mob starts getting blurred vision
	var/pass_out = 325	//amount absorbed after which mob starts passing out

/datum/reagent/ethanol/on_mob_life(var/mob/living/M as mob, var/alien)
	// Sobering multiplier.
	// Sober block makes it more difficult to get drunk
	var/sober_str=!(SOBER in M.mutations)?1:2
	M:nutrition += nutriment_factor
	holder.remove_reagent(src.id, FOOD_METABOLISM)
	if(!src.data) data = 1
	src.data++

	var/d = data

	// make all the beverages work together
	for(var/datum/reagent/ethanol/A in holder.reagent_list)
		if(isnum(A.data)) d += A.data

	d/=sober_str

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species && (H.species.name == "Skrell" || H.species.name =="Neara"))	 //Skrell and Neara get very drunk very quickly.
			d*=5

	M.dizziness += dizzy_adj.
	if(d >= slur_start && d < pass_out)
		if (!M:slurring) M:slurring = 1
		M:slurring += slurr_adj/sober_str
	if(d >= brawl_start && ishuman(M))
		var/mob/living/carbon/human/H = M
		F.teach(H,1)
		if(src.volume < 3)
			if(H.martial_art == F)
				F.remove(H)
	if(d >= confused_start && prob(33))
		if (!M:confused) M:confused = 1
		M.confused = max(M:confused+(confused_adj/sober_str),0)
	if(d >= blur_start)
		M.eye_blurry = max(M.eye_blurry, 10/sober_str)
		M:drowsyness  = max(M:drowsyness, 0)
	if(d >= vomit_start)
		if(prob(8))
			M.fakevomit()
	if(d >= pass_out)
		M:paralysis = max(M:paralysis, 20/sober_str)
		M:drowsyness  = max(M:drowsyness, 30/sober_str)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/liver/L = H.internal_organs_by_name["liver"]
			if (istype(L))
				L.take_damage(0.1, 1)
			H.adjustToxLoss(0.1)
	holder.remove_reagent(src.id, 0.4)
	..()
	return

/datum/reagent/ethanol/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/item/weapon/paper))
		var/obj/item/weapon/paper/paperaffected = O
		paperaffected.clearpaper()
		usr << "The solution melts away the ink on the paper."
	if(istype(O,/obj/item/weapon/book))
		if(volume >= 5)
			var/obj/item/weapon/book/affectedbook = O
			affectedbook.dat = null
			usr << "The solution melts away the ink on the book."
		else
			usr << "It wasn't enough..."
	return

/datum/reagent/ethanol/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 15)
		return


/datum/reagent/ethanol/beer	//It's really much more stronger than other drinks.
	name = "Beer"
	id = "beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/beer/on_mob_life(var/mob/living/M as mob)
		..()
		M:jitteriness = max(M:jitteriness-3,0)
		return

/datum/reagent/ethanol/cider
	name = "Cider"
	id = "cider"
	description = "An alcoholic beverage derived from apples."
	color = "#174116"

/datum/reagent/ethanol/whiskey
	name = "Whiskey"
	id = "whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4

/datum/reagent/ethanol/specialwhiskey
	name = "Special Blend Whiskey"
	id = "specialwhiskey"
	description = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
	color = "#664300" // rgb: 102, 67, 0
	slur_start = 30		//amount absorbed after which mob starts slurring
	brawl_start = 40

/datum/reagent/ethanol/gin
	name = "Gin"
	id = "gin"
	description = "It's gin. In space. I say, good sir."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 3

/datum/reagent/ethanol/absinthe
	name = "Absinthe"
	id = "absinthe"
	description = "Watch out that the Green Fairy doesn't come for you!"
	color = "#33EE00" // rgb: lots, ??, ??
	overdose_threshold = 30
	dizzy_adj = 5
	slur_start = 25
	brawl_start = 40
	confused_start = 100

//copy paste from LSD... shoot me
/datum/reagent/ethanol/absinthe/on_mob_life(var/mob/M)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	data++
	M:hallucination += 5
	if(volume > overdose_threshold)
		M:adjustToxLoss(1)
	..()
	return

/datum/reagent/ethanol/rum
	name = "Rum"
	id = "rum"
	description = "Popular with the sailors. Not very popular with everyone else."
	color = "#664300" // rgb: 102, 67, 0
	overdose_threshold = 30

/datum/reagent/ethanol/rum/on_mob_life(var/mob/living/M as mob)
	..()
	M.dizziness +=5
	if(volume > overdose_threshold)
		M:adjustToxLoss(1)
	return

/datum/reagent/ethanol/mojito
	name = "Mojito"
	id = "mojito"
	description = "If it's good enough for Spesscuba, it's good enough for you."
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/vodka
	name = "Vodka"
	id = "vodka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/sake
	name = "Sake"
	id = "sake"
	description = "Anime's favorite drink."
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/tequilla
	name = "Tequila"
	id = "tequilla"
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
	color = "#A8B0B7" // rgb: 168, 176, 183

/datum/reagent/ethanol/vermouth
	name = "Vermouth"
	id = "vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/wine
	name = "Wine"
	id = "wine"
	description = "An premium alchoholic beverage made from distilled grape juice."
	color = "#7E4043" // rgb: 126, 64, 67
	dizzy_adj = 2
	slur_start = 65			//amount absorbed after which mob starts slurring
	confused_start = 145	//amount absorbed after which mob starts confusing directions

/datum/reagent/ethanol/cognac
	name = "Cognac"
	id = "cognac"
	description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	confused_start = 115	//amount absorbed after which mob starts confusing directions

/datum/reagent/ethanol/suicider //otherwise known as "I want to get so smashed my liver gives out and I die from alcohol poisoning".
	name = "Suicider"
	id = "suicider"
	description = "An unbelievably strong and potent variety of Cider."
	color = "#CF3811"
	dizzy_adj = 20
	slurr_adj = 20
	confused_adj = 3
	slur_start = 15
	brawl_start = 25
	confused_start = 40
	blur_start = 60
	pass_out = 80

/datum/reagent/ethanol/ale
	name = "Ale"
	id = "ale"
	description = "A dark alchoholic beverage made by malted barley and yeast."
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/thirteenloko
	name = "Thirteen Loko"
	id = "thirteenloko"
	description = "A potent mixture of caffeine and alcohol."
	reagent_state = LIQUID
	color = "#102000" // rgb: 16, 32, 0

/datum/reagent/ethanol/thirteenloko/on_mob_life(var/mob/living/M as mob)
	..()
	M:nutrition += nutriment_factor
	holder.remove_reagent(src.id, FOOD_METABOLISM)
	M:drowsyness = max(0,M:drowsyness-7)
	//if(!M:sleeping_willingly)
	//	M:sleeping = max(0,M.sleeping-2)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature-5)
	M.Jitter(1)
	return


/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////

/datum/reagent/ethanol/bilk
	name = "Bilk"
	id = "bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	reagent_state = LIQUID
	color = "#895C4C" // rgb: 137, 92, 76

/datum/reagent/ethanol/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	description = "Nuclear proliferation never tasted so good."
	reagent_state = LIQUID
	color = "#666300" // rgb: 102, 99, 0

/datum/reagent/ethanol/threemileisland
	name = "THree Mile Island Iced Tea"
	id = "threemileisland"
	description = "Made for a woman, strong enough for a man."
	reagent_state = LIQUID
	color = "#666340" // rgb: 102, 99, 64

/datum/reagent/ethanol/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/patron
	name = "Patron"
	id = "patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	reagent_state = LIQUID
	color = "#585840" // rgb: 88, 88, 64

/datum/reagent/ethanol/gintonic
	name = "Gin and Tonic"
	id = "gintonic"
	description = "An all time classic, mild cocktail."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	description = "Rum, mixed with cola. Viva la revolution."
	reagent_state = LIQUID
	color = "#3E1B00" // rgb: 62, 27, 0

/datum/reagent/ethanol/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	reagent_state = LIQUID
	color = "#3E1B00" // rgb: 62, 27, 0

/datum/reagent/ethanol/martini
	name = "Classic Martini"
	id = "martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/white_russian
	name = "White Russian"
	id = "whiterussian"
	description = "That's just, like, your opinion, man..."
	reagent_state = LIQUID
	color = "#A68340" // rgb: 166, 131, 64

/datum/reagent/ethanol/screwdrivercocktail
	name = "Screwdriver"
	id = "screwdrivercocktail"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16

/datum/reagent/ethanol/booger
	name = "Booger"
	id = "booger"
	description = "Ewww..."
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16

/datum/reagent/ethanol/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	description = "Whoah, this stuff looks volatile!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/tequilla_sunrise
	name = "Tequila Sunrise"
	id = "tequillasunrise"
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/toxins_special
	name = "Toxins Special"
	id = "toxinsspecial"
	description = "This thing is FLAMING!. CALL THE DAMN SHUTTLE!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/beepsky_smash
	name = "Beepsky Smash"
	id = "beepskysmash"
	description = "Deny drinking this and prepare for THE LAW."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "You take a tiny sip and feel a burning sensation..."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	description = "Whiskey-imbued cream, what else would you expect from the Irish."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/moonshine
	name = "Moonshine"
	id = "moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/b52
	name = "B-52"
	id = "b52"
	description = "Coffee, Irish Cream, and congac. You will get bombed."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/irishcoffee
	name = "Irish Coffee"
	id = "irishcoffee"
	description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/margarita
	name = "Margarita"
	id = "margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/black_russian
	name = "Black Russian"
	id = "blackrussian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	reagent_state = LIQUID
	color = "#360000" // rgb: 54, 0, 0

/datum/reagent/ethanol/manhattan
	name = "Manhattan"
	id = "manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	description = "A scienitst's drink of choice, for pondering ways to blow up the station."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	description = "Ultimate refreshment."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	description = "Ultimate refreshment."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/barefoot
	name = "Barefoot"
	id = "barefoot"
	description = "Barefoot and pregnant"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/snowwhite
	name = "Snow White"
	id = "snowwhite"
	description = "A cold refreshment"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	description = "AHHHH!!!!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 10
	slurr_adj = 10

/datum/reagent/ethanol/vodkatonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	description = "For when a gin and tonic isn't russian enough."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3

/datum/reagent/ethanol/ginfizz
	name = "Gin Fizz"
	id = "ginfizz"
	description = "Refreshingly lemony, deliciously dry."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	slurr_adj = 3

/datum/reagent/ethanol/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	description = "Tropic cocktail."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/singulo
	name = "Singulo"
	id = "singulo"
	description = "A blue-space beverage!"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	dizzy_adj = 15
	slurr_adj = 15

/datum/reagent/ethanol/sbiten
	name = "Sbiten"
	id = "sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/sbiten/on_mob_life(var/mob/living/M as mob)
	..()
	if (M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature+50) //310 is the normal bodytemp. 310.055
	return

/datum/reagent/ethanol/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	description = "Creepy time!"
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16

/datum/reagent/ethanol/red_mead
	name = "Red Mead"
	id = "red_mead"
	description = "The true Viking drink! Even though it has a strange red color."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/mead
	name = "Mead"
	id = "mead"
	description = "A Vikings drink, though a cheap one."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	description = "A beer which is so cold the air around it freezes."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/iced_beer/on_mob_life(var/mob/living/M as mob)
	..()
	if (M.bodytemperature < 270)
		M.bodytemperature = min(270, M.bodytemperature-40) //310 is the normal bodytemp. 310.055
	return

/datum/reagent/ethanol/grog
	name = "Grog"
	id = "grog"
	description = "Watered down rum, Nanotrasen approves!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/aloe
	name = "Aloe"
	id = "aloe"
	description = "So very, very, very good."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/andalusia
	name = "Andalusia"
	id = "andalusia"
	description = "A nice, strange named drink."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	description = "A drink made from your allies."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/acid_spit
	name = "Acid Spit"
	id = "acidspit"
	description = "A drink by Nanotrasen. Made from live aliens."
	reagent_state = LIQUID
	color = "#365000" // rgb: 54, 80, 0

/datum/reagent/ethanol/amasec
	name = "Amasec"
	id = "amasec"
	description = "Official drink of the Imperium."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0


/datum/reagent/ethanol/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = LIQUID
	color = "#2E2E61" // rgb: 46, 46, 97

/datum/reagent/ethanol/neurotoxin/on_mob_life(var/mob/living/M as mob)
	M.weakened = max(M.weakened, 3)
	if(!data)
		data = 1
	data++
	M.dizziness +=6
	if(data >= 15 && data <45)
		if (!M.slurring)
			M.slurring = 1
		M.slurring += 3
	else if(data >= 45 && prob(50) && data <55)
		M.confused = max(M.confused+3,0)
	else if(data >=55)
		M.druggy = max(M.druggy, 55)
	else if(data >=200)
		M.adjustToxLoss(2)
	..()
	return

/datum/reagent/ethanol/bananahonk
	name = "Banana Mama"
	id = "bananahonk"
	description = "A drink from Clown Heaven."
	nutriment_factor = 1 * FOOD_METABOLISM
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/bananahonk/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(istype(M, /mob/living/carbon/human) && M.job in list("Clown"))
		if(!M) M = holder.my_atom
		M.heal_organ_damage(1,1)
		M.nutrition += nutriment_factor
		..()
		return
	..()

/datum/reagent/ethanol/silencer
	name = "Silencer"
	id = "silencer"
	description = "A drink from Mime Heaven."
	nutriment_factor = 1 * FOOD_METABOLISM
	color = "#664300" // rgb: 102, 67, 0

/datum/reagent/ethanol/silencer/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(istype(M, /mob/living/carbon/human) && M.job in list("Mime"))
		if(!M) M = holder.my_atom
		M.heal_organ_damage(1,1)
		M.nutrition += nutriment_factor
		..()
		return
	..()

/datum/reagent/ethanol/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "A stingy drink."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/changelingsting/on_mob_life(var/mob/living/M as mob)
	..()
	M.dizziness +=5
	return

/datum/reagent/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	description = "Mmm, tastes like chocolate cake..."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/irishcarbomb/on_mob_life(var/mob/living/M as mob)
	..()
	M.dizziness +=5
	return

/datum/reagent/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	description = "A Syndicate bomb"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	description = "The surprise is, it's green!"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1 * FOOD_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113

/datum/reagent/ethanol/driestmartini/on_mob_life(var/mob/living/M as mob)
	if(!data) data = 1
	data++
	M.dizziness +=10
	if(data >= 55 && data <115)
		if (!M.stuttering) M.stuttering = 1
		M.stuttering += 10
	else if(data >= 115 && prob(33))
		M.confused = max(M.confused+15,15)
	..()

	return