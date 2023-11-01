
//////////////////////
//		Raw Meat	//
//////////////////////

/obj/item/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meat"
	filling_color = "#FF1C1C"
	bitesize = 3
	list_reagents = list("protein" = 3)
	tastes = list("meat" = 1)
	ingredient_name = "slab of meat"
	ingredient_name_plural = "slabs of meat"

/obj/item/reagent_containers/food/snacks/meat/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/kitchen/knife) || istype(W, /obj/item/scalpel))
		new /obj/item/reagent_containers/food/snacks/rawcutlet(src)
		new /obj/item/reagent_containers/food/snacks/rawcutlet(src)
		new /obj/item/reagent_containers/food/snacks/rawcutlet(src)
		user.visible_message( \
			"<span class ='notice'>[user] cuts [src] with [W]!</span>", \
			"<span class ='notice'>You cut [src] with [W]!</span>" \
			)
		qdel(src)
	else
		..()

/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/reagent_containers/food/snacks/meat/human
	name = "-meat"
	var/subjectname = ""
	var/subjectjob = null
	tastes = list("salty meat" = 1)

/obj/item/reagent_containers/food/snacks/meat/slab/meatproduct
	name = "meat product"
	desc = "A slab of reclaimed and chemically processed meat product."

/obj/item/reagent_containers/food/snacks/meat/slab/gorilla
	name = "gorilla meat"
	desc = "Much meatier than monkey meat."
	list_reagents = list("nutriment" = 5, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/meat/monkey
	//same as plain meat

/obj/item/reagent_containers/food/snacks/meat/corgi
	name = "corgi meat"
	desc = "Tastes like the Head of Personnel's hopes and dreams."

/obj/item/reagent_containers/food/snacks/meat/pug
	name = "pug meat"
	desc = "Slightly less adorable in sliced form."

/obj/item/reagent_containers/food/snacks/meat/ham
	name = "ham"
	desc = "For when you need to go ham."
	list_reagents = list("protein" = 3, "porktonium" = 10)

/obj/item/reagent_containers/food/snacks/meat/meatwheat
	name = "meatwheat clump"
	desc = "This doesn't look like meat, but your standards aren't <i>that</i> high to begin with."
	list_reagents = list("nutriment" = 3, "vitamin" = 2, "blood" = 5)
	filling_color = rgb(150, 0, 0)
	icon_state = "meatwheat_clump"
	bitesize = 4

/obj/item/reagent_containers/food/snacks/meat/tomatomeat
	name = "tomato meat slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	filling_color = "#DB0000"
	bitesize = 6
	list_reagents = list("protein" = 2)
	tastes = list("tomato" = 1)

/obj/item/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	desc = "A thin strip of raw meat."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "rawcutlet"
	bitesize = 1
	list_reagents = list("protein" = 1)

/obj/item/reagent_containers/food/snacks/rawcutlet/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/kitchen/knife) || istype(W, /obj/item/scalpel))
		user.visible_message( \
			"<span class ='notice'>[user] cuts the raw cutlet with [W]!</span>", \
			"<span class ='notice'>You cut the raw cutlet with [W]!</span>" \
			)
		var/obj/item/reagent_containers/food/snacks/raw_bacon/bacon = new(get_turf(src))
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			qdel(src)
			H.put_in_hands(bacon)
		else
			qdel(src)

//////////////////////////
//		Monster Meat	//
//////////////////////////

// Cannot be used in the usual meat-based food recipies but can be used as cloning pod biomass.

/obj/item/reagent_containers/food/snacks/monstermeat
	// Abstract object used for inheritance. I don't see why you would want one.
	// It's just a convenience to set all monstermeats as biomass-able at once,
	// in the GLOB.cloner_biomass_items list.
	// DOES NOT SPAWN NATURALLY!
	name = "abstract monster meat"
	desc = "A slab of abstract monster meat. This shouldn't exist, contact a coder about this if you are seeing it in-game."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "bearmeat"

/obj/item/reagent_containers/food/snacks/monstermeat/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	filling_color = "#DB0000"
	bitesize = 3
	list_reagents = list("protein" = 12, "morphine" = 5, "vitamin" = 2)
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat
	name = "meat"
	desc = "A slab of meat. It's green!"
	icon_state = "xenomeat"
	filling_color = "#43DE18"
	bitesize = 6
	list_reagents = list("protein" = 3, "vitamin" = 1)
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat. Not very appetizing."
	icon_state = "spidermeat"
	bitesize = 3
	list_reagents = list("protein" = 3, "toxin" = 3, "vitamin" = 1)
	tastes = list("cobwebs" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/lizardmeat
	name = "mutant lizard meat"
	desc = "A peculiar slab of meat. It looks scaly and radioactive."
	icon_state = "xenomeat"
	filling_color = "#43DE18"
	bitesize = 3
	list_reagents = list("protein" = 3, "toxin" = 3)
	tastes = list("tough meat" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider. You don't really want to eat this, do you?"
	icon_state = "spiderleg"
	list_reagents = list("protein" = 2, "toxin" = 2)
	tastes = list("cobwebs" = 1, "creepy motion" = 1)

/obj/item/reagent_containers/food/snacks/raw_bacon
	name = "raw bacon"
	desc = "God's gift to man in uncooked form."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "raw_bacon"
	list_reagents = list("nutriment" = 1, "porktonium" = 10)
	tastes = list("bacon" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/spidereggs
	name = "spider eggs"
	desc = "A cluster of juicy spider eggs. A great side dish for when you don't care about your health."
	icon_state = "spidereggs"
	list_reagents = list("protein" = 2, "toxin" = 2)
	tastes = list("cobwebs" = 1, "spider juice" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/goliath
	name = "goliath meat"
	desc = "A slab of goliath meat. It's not very edible now, but it cooks great in lava."
	icon_state = "goliathmeat"
	list_reagents = list("protein" = 3, "toxin" = 5)
	tastes = list("tough meat" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/goliath/burn()
	visible_message("<span class='notice'>[src] finishes cooking!</span>")
	new /obj/item/reagent_containers/food/snacks/goliath_steak(loc)
	qdel(src)

//////////////////////
//	Cooked Meat		//
//////////////////////

/obj/item/reagent_containers/food/snacks/meatsteak
	name = "meat steak"
	desc = "A piece of hot spicy meat."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meatstake"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 3
	list_reagents = list("nutriment" = 5)
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/bacon
	name = "bacon"
	desc = "It looks crispy and tastes amazing! Mmm... Bacon."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "bacon"
	list_reagents = list("nutriment" = 4, "porktonium" = 10, "msg" = 4)
	tastes = list("bacon" = 1)

/obj/item/reagent_containers/food/snacks/telebacon
	name = "tele bacon"
	desc = "It tastes a little odd but it's still delicious."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "bacon"
	var/obj/item/radio/beacon/bacon/baconbeacon
	list_reagents = list("nutriment" = 4, "porktonium" = 10)
	tastes = list("bacon" = 1)

/obj/item/reagent_containers/food/snacks/telebacon/Initialize(mapload)
	. = ..()
	baconbeacon = new /obj/item/radio/beacon/bacon(src)

/obj/item/reagent_containers/food/snacks/telebacon/Destroy()
	QDEL_NULL(baconbeacon)
	return ..()

/obj/item/reagent_containers/food/snacks/telebacon/On_Consume(mob/M, mob/user)
	if(!reagents.total_volume)
		baconbeacon.forceMove(user)
		baconbeacon.digest_delay()
		baconbeacon = null

/obj/item/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meatball"
	filling_color = "#DB0000"
	list_reagents = list("protein" = 4, "vitamin" = 1)
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed and cased meat."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "sausage"
	filling_color = "#DB0000"
	list_reagents = list("protein" = 6, "vitamin" = 1, "porktonium" = 10)
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "cutlet"
	list_reagents = list("protein" = 2)
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "spidereggsham"
	trash = /obj/item/trash/plate
	bitesize = 4
	list_reagents = list("nutriment" = 6)
	tastes = list("cobwebs" = 1, "the colour green" = 1)

/obj/item/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "spiderlegcooked"
	trash = /obj/item/trash/plate
	bitesize = 3
	list_reagents = list("nutriment" = 3, "capsaicin" = 2)
	tastes = list("cobwebs" = 1, "hot peppers" = 1)

/obj/item/reagent_containers/food/snacks/wingfangchu
	name = "wing fang chu"
	desc = "A savory dish of alien wing wang in soy. Wait, what?"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#43DE18"
	list_reagents = list("nutriment" = 6, "soysauce" = 5, "vitamin" = 2)
	tastes = list("soy" = 1)

/obj/item/reagent_containers/food/snacks/goliath_steak
	name = "goliath steak"
	desc = "A delicious, lava cooked steak."
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "goliathsteak"
	trash = null
	list_reagents = list("protein" = 6, "vitamin" = 2)
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/fried_vox
	name = "Kentucky Fried Vox"
	desc = "Bucket of voxxy, yaya!"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fried_vox"
	trash = /obj/item/trash/fried_vox
	list_reagents = list("nutriment" = 3, "protein" = 5)
	tastes = list("quills" = 1, "the shoal" = 1)

//////////////////////
//		Cubes		//
//////////////////////

/obj/item/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bitesize = 12
	filling_color = "#ADAC7F"
	var/faction
	var/datum/species/monkey_type = /datum/species/monkey
	list_reagents = list("nutriment" = 2)
	tastes = list("the jungle" = 1, "bananas" = 1)

/obj/item/reagent_containers/food/snacks/monkeycube/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	if(volume >= 1)
		return Expand()

/obj/item/reagent_containers/food/snacks/monkeycube/wash(mob/user, atom/source)
	user.drop_item()
	forceMove(get_turf(source))
	return 1

/obj/item/reagent_containers/food/snacks/monkeycube/proc/Expand()
	if(LAZYLEN(SSmobs.cubemonkeys) >= GLOB.configuration.general.monkey_cube_cap)
		if(fingerprintslast)
			to_chat(get_mob_by_ckey(fingerprintslast), "<span class='warning'>Bluespace harmonics prevent the spawning of more than [GLOB.configuration.general.monkey_cube_cap] monkeys on the station at one time!</span>")
		else
			visible_message("<span class='notice'>[src] fails to expand!</span>")
		return
	if(!QDELETED(src))
		visible_message("<span class='notice'>[src] expands!</span>")
		if(fingerprintslast)
			log_game("Cube ([monkey_type]) inflated, last touched by: " + fingerprintslast)
		else
			log_game("Cube ([monkey_type]) inflated, last touched by: NO_DATA")
		var/mob/living/carbon/human/creature = new /mob/living/carbon/human(get_turf(src))
		if(faction)
			creature.faction = faction
		if(LAZYLEN(fingerprintshidden))
			creature.fingerprintshidden = fingerprintshidden
		creature.set_species(monkey_type)
		SSmobs.cubemonkeys += creature
		qdel(src)

/obj/item/reagent_containers/food/snacks/monkeycube/syndicate
	faction = list("neutral", "syndicate")

/obj/item/reagent_containers/food/snacks/monkeycube/farwacube
	name = "farwa cube"
	monkey_type = /datum/species/monkey/tajaran

/obj/item/reagent_containers/food/snacks/monkeycube/wolpincube
	name = "wolpin cube"
	monkey_type = /datum/species/monkey/vulpkanin

/obj/item/reagent_containers/food/snacks/monkeycube/stokcube
	name = "stok cube"
	monkey_type = /datum/species/monkey/unathi

/obj/item/reagent_containers/food/snacks/monkeycube/neaeracube
	name = "neaera cube"
	monkey_type = /datum/species/monkey/skrell


//////////////////////
//		Eggs		//
//////////////////////

/obj/item/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "egg"
	filling_color = "#FDFFD1"
	list_reagents = list("protein" = 1, "egg" = 5)
	tastes = list("egg" = 1)

/obj/item/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom)
	..()
	var/turf/T = get_turf(hit_atom)
	new/obj/effect/decal/cleanable/egg_smudge(T)
	if(reagents)
		reagents.reaction(hit_atom, REAGENT_TOUCH)
	qdel(src)

/obj/item/reagent_containers/food/snacks/egg/attackby(obj/item/W, mob/user, params)
	if(istype( W, /obj/item/toy/crayon ))
		var/obj/item/toy/crayon/C = W
		var/clr = C.colourName

		if(!(clr in list("blue","green","mime","orange","purple","rainbow","red","yellow")))
			to_chat(usr, "<span class ='notice'>The egg refuses to take on this color!</span>")
			return

		to_chat(usr, "<span class ='notice'>You color \the [src] [clr]</span>")
		icon_state = "egg-[clr]"
		item_color = clr
	else
		..()

/obj/item/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"
	item_color = "blue"

/obj/item/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"
	item_color = "green"

/obj/item/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"
	item_color = "mime"

/obj/item/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"
	item_color = "orange"

/obj/item/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"
	item_color = "purple"

/obj/item/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"
	item_color = "rainbow"

/obj/item/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"
	item_color = "red"

/obj/item/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"
	item_color = "yellow"

/obj/item/reagent_containers/food/snacks/egg/gland
	desc = "An egg! It looks weird..."

/obj/item/reagent_containers/food/snacks/egg/gland/Initialize(mapload)
	. = ..()
	reagents.add_reagent(get_random_reagent_id(), 15)

	var/reagent_color = mix_color_from_reagents(reagents.reagent_list)
	color = reagent_color

/obj/item/reagent_containers/food/snacks/friedegg
	name = "fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "friedegg"
	filling_color = "#FFDF78"
	bitesize = 1
	list_reagents = list("nutriment" = 3, "egg" = 5)
	tastes = list("egg" = 1, "salt" = 1, "pepper" = 1)

/obj/item/reagent_containers/food/snacks/boiledegg
	name = "boiled egg"
	desc = "A hard boiled egg."
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "egg"
	filling_color = "#FFFFFF"
	list_reagents = list("nutriment" = 2, "egg" = 5, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/chocolateegg
	name = "chocolate egg"
	desc = "Such sweet, fattening food."
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "chocolateegg"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 4, "sugar" = 2, "cocoa" = 2)

/obj/item/reagent_containers/food/snacks/omelette
	name = "omelette du fromage"
	desc = "That's all you can say!"
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "omelette"
	trash = /obj/item/trash/plate
	filling_color = "#FFF9A8"
	list_reagents = list("nutriment" = 8, "vitamin" = 1)
	bitesize = 1
	tastes = list("egg" = 1, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/benedict
	name = "eggs benedict"
	desc = "There is only one egg on this, how rude."
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "benedict"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "egg" = 3, "vitamin" = 4)
	tastes = list("egg" = 1, "bacon" = 1, "bun" = 1)


//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Not made with actual dogs. Hopefully."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "hotdog"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "ketchup" = 3, "vitamin" = 3)
	tastes = list("bun" = 3, "meat" = 2)

/obj/item/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be dog."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meatbun"
	bitesize = 6
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	tastes = list("bun" = 3, "meat" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/turkey
	name = "turkey"
	desc = "A traditional turkey served with stuffing."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "turkey"
	slice_path = /obj/item/reagent_containers/food/snacks/turkeyslice
	slices_num = 6
	list_reagents = list("protein" = 24, "nutriment" = 18, "vitamin" = 5)
	tastes = list("turkey" = 2, "stuffing" = 2)

/obj/item/reagent_containers/food/snacks/turkeyslice
	name = "turkey serving"
	desc = "A serving of some tender and delicious turkey."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "turkeyslice"
	trash = /obj/item/trash/plate
	filling_color = "#B97A57"
	tastes = list("turkey" = 1)

/obj/item/reagent_containers/food/snacks/organ
	name = "organ"
	desc = "Technically qualifies as organic."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "appendix"
	filling_color = "#E00D34"
	bitesize = 3
	list_reagents = list("protein" = 4, "vitamin" = 4)

/obj/item/reagent_containers/food/snacks/appendix
//yes, this is the same as meat. I might do something different in future
	name = "appendix"
	desc = "An appendix which looks perfectly healthy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "appendix"
	filling_color = "#E00D34"
	bitesize = 3
	list_reagents = list("protein" = 3, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/appendix/inflamed
	name = "inflamed appendix"
	desc = "An appendix which appears to be inflamed."
	icon_state = "appendixinflamed"
	filling_color = "#E00D7A"

/obj/item/reagent_containers/food/snacks/bbqribs
	name = "BBQ ribs"
	desc = "Sweet, smokey, savory, and gets everywhere. Perfect for Grilling."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "bbqribs"
	list_reagents = list("nutriment" = 3, "protein" = 10, "bbqsauce" = 10)
	filling_color = "#FF1C1C"
	bitesize = 3
