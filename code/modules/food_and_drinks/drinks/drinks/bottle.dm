

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom

/obj/item/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	throwforce = 15
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	var/const/duration = 13 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/isGlass = 1 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

/obj/item/reagent_containers/food/drinks/bottle/proc/smash(mob/living/target, mob/living/user, ranged = 0)

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	var/new_location = get_turf(loc)
	var/obj/item/broken_bottle/B = new /obj/item/broken_bottle(new_location)
	if(ranged)
		B.loc = new_location
	else
		user.drop_item()
		user.put_in_active_hand(B)
	B.icon_state = icon_state

	var/icon/I = new('icons/obj/drinks.dmi', icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	if(isGlass)
		if(prob(33))
			new/obj/item/shard(new_location)
		playsound(src, "shatter", 70, 1)
	else
		B.name = "broken carton"
		B.force = 0
		B.throwforce = 0
		B.desc = "A carton with the bottom half burst open. Might give you a papercut."
	transfer_fingerprints_to(B)

	qdel(src)

/obj/item/reagent_containers/food/drinks/bottle/attack(mob/living/target, mob/living/user)

	if(!target)
		return

	if(user.a_intent != INTENT_HARM || !isGlass)
		return ..()

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm [target]!</span>")
		return

	force = 15 //Smashing bottles over someoen's head hurts.

	var/obj/item/organ/external/affecting = user.zone_selected //Find what the player is aiming at

	var/armor_block = 0 //Get the target's armor values for normal attack damage.
	var/armor_duration = 0 //The more force the bottle has, the longer the duration.

	//Calculating duration and calculating damage.
	if(ishuman(target))

		var/mob/living/carbon/human/H = target
		var/headarmor = 0 // Target's head armor
		armor_block = H.run_armor_check(affecting, "melee","","",armour_penetration) // For normal attack damage

		//If they have a hat/helmet and the user is targeting their head.
		if(istype(H.head, /obj/item/clothing/head) && affecting == "head")

			// If their head has an armor value, assign headarmor to it, else give it 0.
			if(H.head.armor["melee"])
				headarmor = H.head.armor["melee"]
			else
				headarmor = 0
		else
			headarmor = 0

		//Calculate the weakening duration for the target.
		armor_duration = (duration - headarmor) + force

	else
		//Only humans can have armor, right?
		armor_block = target.run_armor_check(affecting, "melee")
		if(affecting == "head")
			armor_duration = duration + force
	armor_duration /= 10

	//Apply the damage!
	armor_block = min(90, armor_block)
	target.apply_damage(force, BRUTE, affecting, armor_block)

	// You are going to knock someone out for longer if they are not wearing a helmet.
	var/head_attack_message = ""
	if(affecting == "head" && iscarbon(target))
		head_attack_message = " on the head"
		//Weaken the target for the duration that we calculated and divide it by 5.
		if(armor_duration)
			target.apply_effect(min(armor_duration, 10) , WEAKEN) // Never weaken more than a flash!

	//Display an attack message.
	if(target != user)
		target.visible_message("<span class='danger'>[user] has hit [target][head_attack_message] with a bottle of [name]!</span>", \
				"<span class='userdanger'>[user] has hit [target][head_attack_message] with a bottle of [name]!</span>")
	else
		user.visible_message("<span class='danger'>[target] hits [target.p_them()]self with a bottle of [name][head_attack_message]!</span>", \
				"<span class='userdanger'>[target] hits [target.p_them()]self with a bottle of [name][head_attack_message]!</span>")

	//Attack logs
	add_attack_logs(user, target, "Hit with [src]")

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	SplashReagents(target)

	//Finally, smash the bottle. This kills (del) the bottle.
	smash(target, user)

/obj/item/reagent_containers/food/drinks/bottle/proc/SplashReagents(mob/M)
	if(reagents && reagents.total_volume)
		M.visible_message("<span class='danger'>The contents of \the [src] splashes all over [M]!</span>")
		reagents.reaction(M, TOUCH)
		reagents.clear_reagents()

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/broken_bottle
	name = "Broken Bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	item_state = "beer"
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("stabbed", "slashed", "attacked")
	var/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")
	sharp = 1

/obj/item/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	list_reagents = list("gin" = 100)

/obj/item/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"
	list_reagents = list("whiskey" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"
	list_reagents = list("vodka" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vodka/badminka
	name = "Badminka Vodka"
	desc = "The label's written in Cyrillic. All you can make out is the name and a word that looks vaguely like 'Vodka'."
	icon_state = "badminka"
	list_reagents = list("vodka" = 100)

/obj/item/reagent_containers/food/drinks/bottle/tequila
	name = "Caccavo Guaranteed Quality Tequila"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	list_reagents = list("tequila" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing."
	icon_state = "bottleofnothing"
	list_reagents = list("nothing" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana
	name = "Jolly Jug"
	desc = "A jug filled with banana juice."
	icon_state = "bottleofjolly"
	list_reagents = list("banana" = 100)

/obj/item/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequila, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	list_reagents = list("patron" = 100)

/obj/item/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"
	list_reagents = list("rum" = 100)

/obj/item/reagent_containers/food/drinks/bottle/holywater
	name = "flask of holy water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	list_reagents = list("holywater" = 100)

/obj/item/reagent_containers/food/drinks/bottle/holywater/hell
	desc = "A flask of holy water...it's been sitting in the Necropolis a while though."
	list_reagents = list("hell_water" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	list_reagents = list("vermouth" = 100)

/obj/item/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK."
	icon_state = "kahluabottle"
	list_reagents = list("kahlua" = 100)

/obj/item/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	list_reagents = list("goldschlager" = 100)

/obj/item/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alcoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	list_reagents = list("cognac" = 100)

/obj/item/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	list_reagents = list("wine" = 100)

/obj/item/reagent_containers/food/drinks/bottle/absinthe
	name = "Yellow Marquee Absinthe"
	desc = "A strong alcoholic drink brewed and distributed by Yellow Marquee."
	icon_state = "absinthebottle"
	list_reagents = list("absinthe" = 100)

/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium
	name = "Gwyn's Premium Absinthe"
	desc = "A potent alcoholic beverage, almost makes you forget the ash in your lungs."
	icon_state = "absinthepremium"

/obj/item/reagent_containers/food/drinks/bottle/hcider
	name = "Jian Hard Cider"
	desc = "Apple juice for adults."
	icon_state = "hcider"
	volume = 50
	list_reagents = list("suicider" = 50)

/obj/item/reagent_containers/food/drinks/bottle/amaretto
	name = "Salizo Luxury Amaretto"
	desc = "Old and classy bottle of amaretto."
	icon_state = "amarettobottle"
	list_reagents = list("amaretto" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bourbon
	name = "Jim Dean Bourbon"
	desc = "A nice bottle of a strong alcoholic beverage"
	icon_state = "bourbonbottle"
	list_reagents = list("bourbon" = 100)

/obj/item/reagent_containers/food/drinks/bottle/brandy
	name = "Grand Bouldier Grain Brandy "
	desc = "A nice bottle of well aged strong alcoholic beverage"
	icon_state = "brandybottle"
	list_reagents = list("brandy" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bluecuracao
	name = "Mennaker's Bluest Curacao"
	desc = "A alchoholic beverage that is bright blue."
	icon_state = "bluecuracao"
	list_reagents = list("bluecuracao" = 100)

/obj/item/reagent_containers/food/drinks/bottle/cointreau
	name = "Gillani's Triple Sec Cointreau"
	desc = "A bottle of nice and tasty colorless curacao."
	icon_state = "cointreau"
	list_reagents = list("cointreau" = 100)

/obj/item/reagent_containers/food/drinks/bottle/watermelonliqueur
	name = "Great Groppa's Watermelon Liqueur"
	desc = "A sweet and fruity drink for the weak."
	icon_state = "watermelonliqueur"
	list_reagents = list("watermelonliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/mintliqueur
	name = "Hopburg Minty Liqueur"
	desc = "A bottle full of refreshing and minty liqueur."
	icon_state = "mintliqueur"
	list_reagents = list("mintliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/peachliqueur
	name = "Sagurena Sweet Peach Liqueur"
	desc = "A sweet and fruity drink for the weak."
	icon_state = "peachliqueur"
	list_reagents = list("peachliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bananaliqueur
	name = "Gifford's Banana Liqueur"
	desc = "A sweet and fruity drink for the weak."
	icon_state = "bananaliqueur"
	list_reagents = list("bananaliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/violetliqueur
	name = "Bitter Truth Violet Liqueur"
	desc = "A drink that is distrinctly floral and sweet."
	icon_state = "violetliqueur"
	list_reagents = list("violetliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/nutliqueur
	name = "Di Nocino Hazelnut Liqueur"
	desc = "A bottle full of nut liqueur."
	icon_state = "nutliqueur"
	list_reagents = list("nutliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/cherryliqueur
	name = "De Kaiya Wild Cherry Liqueur"
	desc = "A sweet and fruity drink for the weak."
	icon_state = "cherryliqueur"
	list_reagents = list("cherryliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/anisette
	name = "Chateau De Baton Anisette"
	desc = "A sweetened aniseed-derived liqueur usually used as a cocktail ingredient."
	icon_state = "anisette"
	volume = 100
	list_reagents = list("anisette" = 50)

/obj/item/reagent_containers/food/drinks/bottle/aperol
	name = "Barber's Special Aperol"
	desc = "It's special because nobody ever drinks it."
	icon_state = "aperol"
	volume = 100
	list_reagents = list("aperol" = 100)

/obj/item/reagent_containers/food/drinks/bottle/appleliqueur
	name = "Yellow Marquee Apple Liqueur"
	desc = "A sweetened alcoholic beverage with an apple flavour. Slightly sour."
	icon_state = "apple_liqueur"
	volume = 100
	list_reagents = list("appleliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/apricotliqueur
	name = "Yellow Marquee Apricot Liqueur"
	desc = "A sweetened alcoholic beverage with an apricot flavour. Pleasantly tangy."
	icon_state = "apricot_liqueur"
	volume = 100
	list_reagents = list("apricotliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/bitters
	name = "Chateau De Baton Bitters"
	desc = "Lightly alcoholic and very bitter, much like your standard security officer."
	icon_state = "bitters"
	volume = 100
	list_reagents = list("bitters" = 100)

/obj/item/reagent_containers/food/drinks/bottle/blackcurrantliqueur
	name = "Yellow Marquee Blackcurrant Liqueur"
	desc = "A sweetened alcoholic beverage with a blackcurrant flavour."
	icon_state = "blackcurrant_liqueur"
	volume = 100
	list_reagents = list("blackcurrantliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/boukha
	name = "Maghreb Boukha"
	desc = "A distilled spirit produced from figs. The basis of many cocktails."
	icon_state = "boukha"
	volume = 100
	list_reagents = list("boukha" = 100)

/obj/item/reagent_containers/food/drinks/bottle/caramelsyrup
	name = "Caramel Syrup"
	desc = "A smooth, non-alcoholic caramel flavouring usually used in cocktails or desserts."
	icon_state = "caramel_syrup"
	volume = 100
	list_reagents = list("caramelsyrup" = 100)

/obj/item/reagent_containers/food/drinks/bottle/champagne
	name = "Champagne"
	desc = "Bubbly wine. Technically not supposed to be called 'Champagne' unless it comes from Space France, but nobody cares."
	icon_state = "champagne"
	volume = 100
	list_reagents = list("champagne" = 100)

/obj/item/reagent_containers/food/drinks/bottle/chocolateliqueur
	name = "Yellow Marquee Creme de Cacao"
	desc = "A fancy name for sweetened chocolate liqueur."
	icon_state = "creme_de_cacao"
	volume = 100
	list_reagents = list("chocolateliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/chocolatesyrup
	name = "Chocolate Syrup"
	desc = "A very sweet, non-alcoholic chocolate flavouring usually used in cocktails or desserts."
	icon_state = "chocolate_syrup"
	volume = 100
	list_reagents = list("chocolatesyrup" = 100)

/obj/item/reagent_containers/food/drinks/bottle/almondliqueur
	name = "Yellow Marquee Creme de Noyaux"
	desc = "An almond flavoured liqueur that contains trace amounts of cyanide."
	icon_state = "creme_de_noyaux"
	volume = 100
	list_reagents = list("almondliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/kumis
	name = "Kumis"
	desc = "Fermented horse milk. Why would you even drink this?"
	icon_state = "kumis"
	volume = 100
	list_reagents = list("kumis" = 100)

/obj/item/reagent_containers/food/drinks/bottle/grappa
	name = "Grappa"
	desc = "A strong grape brandy."
	icon_state = "grappa"
	volume = 100
	list_reagents = list("grappa" = 100)

/obj/item/reagent_containers/food/drinks/bottle/pearliqueur
	name = "Yellow Marquee Pear Liqueur"
	desc = "A sweetened alcoholic beverage with a pear flavour."
	icon_state = "pear_liqueur"
	volume = 100
	list_reagents = list("pearliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/whitewine
	name = "Doublebeard Bearded White Wine"
	desc = "A dry white wine made from prosecco grapes. Fancy."
	icon_state = "prosecco"
	volume = 100
	list_reagents = list("whitewine" = 100)

/obj/item/reagent_containers/food/drinks/bottle/raspberryliqueur
	name = "Yellow Marquee Raspberry Liqueur"
	desc = "A sweetened alcoholic beverage with a raspberry flavour."
	icon_state = "raspberry_liqueur"
	volume = 100
	list_reagents = list("raspberryliqueur" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vanillaliqueur
	name = "Yellow Marquee Vanilla Liqueur"
	desc = "A sweetened alcoholic beverage with a vanilla flavour."
	icon_state = "vanilla_liqueur"
	volume = 100
	list_reagents = list("vanillaliqueur" = 100)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/reagent_containers/food/drinks/bottle/orangejuice
	name = "orange juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("orangejuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/cream
	name = "milk cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("cream" = 100)

/obj/item/reagent_containers/food/drinks/bottle/tomatojuice
	name = "tomato juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("tomatojuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/limejuice
	name = "lime juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("limejuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/strawberryjuice
	name = "strawberry juice"
	desc = "Delicious sweet juice, made from strawberries."
	icon_state = "strawberryjuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("strawberryjuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/pineapplejuice
	name = "pineapple juice"
	desc = "Sugary goodness in a carton."
	icon_state = "pineapplejuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("pineapplejuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/coconutjuice
	name = "coconut juice"
	desc = "Sweet juice straight from a coconut."
	icon_state = "coconutjuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("coconutjuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/raspberryjuice
	name = "raspberry juice"
	desc = "Sweet but tangy."
	icon_state = "raspberryjuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("raspberryjuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/pearjuice
	name = "pear juice"
	desc = "Mild and pleasant."
	icon_state = "pearjuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("pearjuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/peachjuice
	name = "peach juice"
	desc = "Sweet and tasty!"
	icon_state = "peachjuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("peachjuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/mangojuice
	name = "mango juice"
	desc = "Undeniably tropical."
	icon_state = "mangojuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("mangojuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/grapefruitjuice
	name = "grapefruit juice"
	desc = "Strong and bitter."
	icon_state = "grapefruitjuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("grapefruitjuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/grapejuice
	name = "grape juice"
	desc = "Not old enough to get drunk on."
	icon_state = "grapejuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("grapejuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/cranberryjuice
	name = "cranberry juice"
	desc = "Sour. Very sour."
	icon_state = "cranberryjuice"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("cranberryjuice" = 100)

/obj/item/reagent_containers/food/drinks/bottle/maplesyrup
	name = "maple syrup"
	desc = "This has sweet written all over it. It must be very sweet."
	icon_state = "maplesyrup"
	list_reagents = list("maplesyrup" = 100)

/obj/item/reagent_containers/food/drinks/bottle/vanillasyrup
	name = "Vanilla Syrup"
	desc = "A sweet, non-alcoholic vanilla flavouring usually used in cocktails or desserts."
	icon_state = "vanilla_syrup"
	volume = 100
	list_reagents = list("vanillasyrup" = 100)

/obj/item/reagent_containers/food/drinks/bottle/milk
	name = "milk"
	desc = "Soothing milk."
	icon_state = "milk"
	item_state = "carton"
	throwforce = 0
	isGlass = 0
	list_reagents = list("milk" = 100)

////////////////////////// MOLOTOV ///////////////////////
/obj/item/reagent_containers/food/drinks/bottle/molotov
	name = "molotov cocktail"
	desc = "A throwing weapon used to ignite things, typically filled with an accelerant. Recommended highly by rioters and revolutionaries. Light and toss."
	icon_state = "vodkabottle"
	list_reagents = list()
	var/list/accelerants = list(/datum/reagent/consumable/ethanol,/datum/reagent/fuel,/datum/reagent/clf3,/datum/reagent/phlogiston,
							/datum/reagent/napalm,/datum/reagent/hellwater,/datum/reagent/plasma,/datum/reagent/plasma_dust)
	var/active = 0

/obj/item/reagent_containers/food/drinks/bottle/molotov/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/food/drinks/bottle/B = locate() in contents
	if(B)
		icon_state = B.icon_state
		B.reagents.copy_to(src, 100)
		if(!B.isGlass)
			desc += " You're not sure if making this out of a carton was the brightest idea."
			isGlass = 0

/obj/item/reagent_containers/food/drinks/bottle/molotov/throw_impact(atom/target,mob/thrower)
	var/firestarter = 0
	for(var/datum/reagent/R in reagents.reagent_list)
		for(var/A in accelerants)
			if(istype(R, A))
				firestarter = 1
				break
	SplashReagents(target)
	if(firestarter && active)
		target.fire_act()
		new /obj/effect/hotspot(get_turf(target))
	..()

/obj/item/reagent_containers/food/drinks/bottle/molotov/attackby(obj/item/I, mob/user, params)
	if(is_hot(I) && !active)
		active = 1
		var/turf/bombturf = get_turf(src)
		var/area/bombarea = get_area(bombturf)
		message_admins("[key_name(user)][ADMIN_QUE(user,"?")] has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[bombarea] (JMP)</a>.")
		log_game("[key_name(user)] has primed a [name] for detonation at [bombarea] ([bombturf.x],[bombturf.y],[bombturf.z]).")

		to_chat(user, "<span class='info'>You light [src] on fire.</span>")
		overlays += fire_overlay
		if(!isGlass)
			spawn(50)
				if(active)
					var/counter
					var/target = loc
					for(counter = 0, counter < 2, counter++)
						if(istype(target, /obj/item/storage))
							var/obj/item/storage/S = target
							target = S.loc
					if(istype(target, /atom))
						var/atom/A = target
						SplashReagents(A)
						A.fire_act()
					qdel(src)

/obj/item/reagent_containers/food/drinks/bottle/molotov/attack_self(mob/user)
	if(active)
		if(!isGlass)
			to_chat(user, "<span class='danger'>The flame's spread too far on it!</span>")
			return
		to_chat(user, "<span class='info'>You snuff out the flame on \the [src].</span>")
		overlays -= fire_overlay
		active = 0
