
//Grey
/datum/chemical_reaction/slimespawn
	name = "Slime Spawn"
	id = "m_spawn"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = TRUE

/datum/chemical_reaction/slimespawn/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/mob/living/simple_animal/slime/S = new(get_turf(holder.my_atom), "grey")
	S.visible_message("<span class='danger'>Infused with plasma, the core begins to quiver and grow, and a new baby slime emerges from it!</span>")

/datum/chemical_reaction/slimeinaprov
	name = "Slime epinephrine"
	id = "m_inaprov"
	result = "epinephrine"
	required_reagents = list("water" = 5)
	result_amount = 3
	required_other = TRUE
	required_container = /obj/item/slime_extract/grey

/datum/chemical_reaction/slimeinaprov/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)

/datum/chemical_reaction/slimemonkey
	name = "Slime Monkey"
	id = "m_monkey"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = TRUE

/datum/chemical_reaction/slimemonkey/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	for(var/i = 1, i <= 3, i++)
		var/obj/item/food/monkeycube/M = new /obj/item/food/monkeycube
		M.forceMove(get_turf(holder.my_atom))

//Green
/datum/chemical_reaction/slimemutate
	name = "Mutation Toxin"
	id = "mutationtoxin"
	result = "mutationtoxin"
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_other = TRUE
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slimemutate/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)

//Metal
/datum/chemical_reaction/slimemetal
	name = "Slime Metal"
	id = "m_metal"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = TRUE

/datum/chemical_reaction/slimemetal/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/plasteel (location, 5)
	new /obj/item/stack/sheet/metal (location, 15)

/datum/chemical_reaction/slimeglass
	name = "Slime Glass"
	id = "m_glass"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = TRUE

/datum/chemical_reaction/slimeglass/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/rglass (location, 5)
	new /obj/item/stack/sheet/glass (location, 15)

//Gold
/datum/chemical_reaction/slimemobspawn
	name = "Slime Crit"
	id = "m_tele"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/gold
	required_other = TRUE

/datum/chemical_reaction/slimemobspawn/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/turf/T = get_turf(holder.my_atom)
	summon_mobs(holder, T)

/datum/chemical_reaction/slimemobspawn/proc/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate violently!</span>")
	if(SSmobs.xenobiology_mobs < MAX_GOLD_CORE_MOBS)
		addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 5, "Gold Slime", HOSTILE_SPAWN, "chemicalsummon", TRUE, TRUE), 50)
		SSmobs.xenobiology_mobs += 5
	else
		T.visible_message("<span class='danger'>The slime extract sputters out, there's too many mobs to make any more!</span>")

/datum/chemical_reaction/slimemobspawn/lesser
	name = "Slime Crit Lesser"
	id = "m_tele3"
	required_reagents = list("blood" = 1)

/datum/chemical_reaction/slimemobspawn/lesser/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate violently!</span>")
	if(SSmobs.xenobiology_mobs < MAX_GOLD_CORE_MOBS)
		addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 3, "Lesser Gold Slime", HOSTILE_SPAWN, "neutral", TRUE, TRUE), 50)
		SSmobs.xenobiology_mobs += 3
	else
		T.visible_message("<span class='danger'>The slime extract sputters out, there's too many mobs to make any more!</span>")

/datum/chemical_reaction/slimemobspawn/friendly
	name = "Slime Crit Friendly"
	id = "m_tele5"
	required_reagents = list("water" = 1)

/datum/chemical_reaction/slimemobspawn/friendly/summon_mobs(datum/reagents/holder, turf/T)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate adorably!</span>")
	if(SSmobs.xenobiology_mobs < MAX_GOLD_CORE_MOBS)
		addtimer(CALLBACK(src, PROC_REF(chemical_mob_spawn), holder, 1, "Friendly Gold Slime", FRIENDLY_SPAWN, "neutral", TRUE, TRUE), 50)
		SSmobs.xenobiology_mobs += 1
	else
		T.visible_message("<span class='danger'>The slime extract sputters out, there's too many mobs to make any more!</span>")

//Silver
/datum/chemical_reaction/slimebork
	name = "Slime Bork"
	id = "m_tele2"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = TRUE

/datum/chemical_reaction/slimebork/on_reaction(datum/reagents/holder)

	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)

	var/list/blocked = list(
		/obj/item/food,
		/obj/item/food/burger, // abstract burger
		/obj/item/food/sliced/bread,
		/obj/item/food/sliceable,
		/obj/item/food/sliceable/pizza,
		/obj/item/food/sliced/margherita_pizza,
		/obj/item/food/sliced/meat_pizza,
		/obj/item/food/sliced/mushroom_pizza,
		/obj/item/food/sliced/vegetable_pizza,
		/obj/item/food/sliced/cheese_pizza,
		/obj/item/food/sliced/garlic_pizza,
		/obj/item/food/sliced/donk_pocket_pizza,
		/obj/item/food/sliced/dank_pizza,
		/obj/item/food/sliced/mac_pizza,
		/obj/item/food/sliced/fire_cracker_pizza,
		/obj/item/food/sliced/pesto_pizza,
		/obj/item/food/sliced/pepperoni_pizza,
		/obj/item/food/meat,
		/obj/item/food/meat/slab,
		/obj/item/food/grown,
		/obj/item/food/grown/shell,
		/obj/item/food/grown/mushroom,
		/obj/item/food/chinese,
		/obj/item/food/human,
		/obj/item/food/monstermeat,
		/obj/item/food/meatsteak/stimulating,
		/obj/item/food/egg/watcher,
		/obj/item/food/supermatter_sandwich,
		)
	blocked |= typesof(/obj/item/food/customizable)

	var/list/borks = typesof(/obj/item/food) - blocked
	// BORK BORK BORK

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
		C.flash_eyes()

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.forceMove(get_turf(holder.my_atom))
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))


/datum/chemical_reaction/slimebork2
	name = "Slime Bork 2"
	id = "m_tele4"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = TRUE

/datum/chemical_reaction/slimebork2/on_reaction(datum/reagents/holder)

	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/list/borks = subtypesof(/obj/item/reagent_containers/drinks)
	var/list/blocked = list(/obj/item/reagent_containers/drinks/cans/adminbooze,
							/obj/item/reagent_containers/drinks/cans/madminmalt,
							/obj/item/reagent_containers/drinks/shaker,
							/obj/item/reagent_containers/drinks/britcup,
							/obj/item/reagent_containers/drinks/sillycup,
							/obj/item/reagent_containers/drinks/cans,
							/obj/item/reagent_containers/drinks/drinkingglass/shotglass,
							/obj/item/reagent_containers/drinks/drinkingglass,
							/obj/item/reagent_containers/drinks/bottle,
							/obj/item/reagent_containers/drinks/everfull,
							/obj/item/reagent_containers/drinks/bottle/dragonsbreath,
							/obj/item/reagent_containers/drinks/bottle/immortality,
							/obj/item/reagent_containers/drinks/mushroom_bowl
							)
	blocked += typesof(/obj/item/reagent_containers/drinks/flask)
	blocked += typesof(/obj/item/reagent_containers/drinks/trophy)
	blocked += typesof(/obj/item/reagent_containers/drinks/cans/bottler)
	borks -= blocked
	// BORK BORK BORK

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/carbon/M in viewers(get_turf(holder.my_atom), null))
		M.flash_eyes()

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.forceMove(get_turf(holder.my_atom))
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))


//Blue
/datum/chemical_reaction/slimefrost
	name = "Slime Frost Oil"
	id = "m_frostoil"
	result = "frostoil"
	required_reagents = list("plasma_dust" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/blue
	required_other = TRUE

/datum/chemical_reaction/slimefrost/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)

/datum/chemical_reaction/slimestabilizer
	name = "Slime Stabilizer"
	id = "m_slimestabilizer"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/blue
	required_other = TRUE

/datum/chemical_reaction/slimestabilizer/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/slimepotion/slime/stabilizer/P = new /obj/item/slimepotion/slime/stabilizer
	P.forceMove(get_turf(holder.my_atom))

//Dark Blue
/datum/chemical_reaction/slimefreeze
	name = "Slime Freeze"
	id = "m_freeze"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkblue
	required_other = TRUE

/datum/chemical_reaction/slimefreeze/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime extract begins to vibrate adorably !</span>")
	spawn(50)
		if(holder && holder.my_atom)
			playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)
			for(var/mob/living/M in range (get_turf(holder.my_atom), 7))
				M.bodytemperature -= 240
				to_chat(M, "<span class='notice'>You feel a chill!</span>")


/datum/chemical_reaction/slimefireproof
	name = "Slime Fireproof"
	id = "m_fireproof"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkblue
	required_other = TRUE

/datum/chemical_reaction/slimefireproof/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/slimepotion/fireproof/P = new /obj/item/slimepotion/fireproof
	P.forceMove(get_turf(holder.my_atom))

//Orange
/datum/chemical_reaction/slimecasp
	name = "Slime Capsaicin Oil"
	id = "m_capsaicinoil"
	result = "capsaicin"
	required_reagents = list("blood" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/orange
	required_other = TRUE

/datum/chemical_reaction/slimecasp/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)

/datum/chemical_reaction/slimefire
	name = "Slime fire"
	id = "m_fire"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/orange
	required_other = TRUE

/datum/chemical_reaction/slimefire/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/turf/TU = get_turf(holder.my_atom)
	TU.visible_message("<span class='danger'>The slime extract begins to vibrate adorably !</span>")
	spawn(50)
		if(holder && holder.my_atom)
			var/turf/simulated/T = get_turf(holder.my_atom)
			if(istype(T))
				var/datum/gas_mixture/air = new()
				air.set_temperature(1000)
				air.set_toxins(20)
				T.blind_release_air(air)

//Yellow

/datum/chemical_reaction/slimeoverload
	name = "Slime EMP"
	id = "m_emp"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = TRUE

/datum/chemical_reaction/slimeoverload/on_reaction(datum/reagents/holder, created_volume)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	empulse(get_turf(holder.my_atom), 3, 7, 1)


/datum/chemical_reaction/slimecell
	name = "Slime Powercell"
	id = "m_cell"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = TRUE

/datum/chemical_reaction/slimecell/on_reaction(datum/reagents/holder, created_volume)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/stock_parts/cell/high/slime/P = new /obj/item/stock_parts/cell/high/slime
	P.forceMove(get_turf(holder.my_atom))

/datum/chemical_reaction/slimeglow
	name = "Slime Glow"
	id = "m_glow"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = TRUE

/datum/chemical_reaction/slimeglow/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='danger'>The slime begins to emit a soft light. Squeezing it will cause it to grow brightly.</span>")
	var/obj/item/flashlight/slime/F = new /obj/item/flashlight/slime
	F.forceMove(get_turf(holder.my_atom))

//Purple

/datum/chemical_reaction/slimepsteroid
	name = "Slime Steroid"
	id = "m_steroid"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/purple
	required_other = TRUE

/datum/chemical_reaction/slimepsteroid/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/slimepotion/slime/steroid/P = new /obj/item/slimepotion/slime/steroid
	P.forceMove(get_turf(holder.my_atom))

/datum/chemical_reaction/slimejam
	name = "Slime Jam"
	id = "m_jam"
	result = "slimejelly"
	required_reagents = list("sugar" = 1)
	result_amount = 10
	required_container = /obj/item/slime_extract/purple
	required_other = TRUE

/datum/chemical_reaction/slimejam/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)


//Dark Purple
/datum/chemical_reaction/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkpurple
	required_other = TRUE

/datum/chemical_reaction/slimeplasma/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/turf/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/mineral/plasma (location, 3)

//Red
/datum/chemical_reaction/slimemutator
	name = "Slime Mutator"
	id = "m_slimemutator"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = TRUE

/datum/chemical_reaction/slimemutator/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/slimepotion/slime/mutator/P = new /obj/item/slimepotion/slime/mutator
	P.forceMove(get_turf(holder.my_atom))

/datum/chemical_reaction/slimebloodlust
	name = "Bloodlust"
	id = "m_bloodlust"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = TRUE

/datum/chemical_reaction/slimebloodlust/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	for(var/mob/living/simple_animal/slime/slime in viewers(get_turf(holder.my_atom), null))
		if(slime.docile) //Undoes docility, but doesn't make rabid.
			slime.visible_message("<span class='danger'>[slime] forgets its training, becoming wild once again!</span>")
			slime.docile = FALSE
			slime.update_appearance(UPDATE_NAME)
			continue
		slime.rabid = TRUE
		slime.visible_message("<span class='danger'>[slime] is driven into a frenzy!</span>")


/datum/chemical_reaction/slimespeed
	name = "Slime Speed"
	id = "m_speed"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = TRUE

/datum/chemical_reaction/slimespeed/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/slimepotion/speed/P = new /obj/item/slimepotion/speed
	P.forceMove(get_turf(holder.my_atom))


//Pink
/datum/chemical_reaction/docility
	name = "Docility Potion"
	id = "m_potion"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/pink
	required_other = TRUE

/datum/chemical_reaction/docility/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/slimepotion/slime/docility/P = new /obj/item/slimepotion/slime/docility
	P.forceMove(get_turf(holder.my_atom))


//Black
/datum/chemical_reaction/slimemutate2
	name = "Advanced Mutation Toxin"
	id = "mutationtoxin2"
	result = "amutationtoxin"
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_other = TRUE
	required_container = /obj/item/slime_extract/black

/datum/chemical_reaction/slimemutate2/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)

/datum/chemical_reaction/viral_gene_extraction
	name = "Virus Gene Extraction"
	id = "virus_gene_extraction"
	result = "virus_genes"
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_other = TRUE
	required_container = /obj/item/slime_extract/black

/datum/chemical_reaction/viral_gene_extraction/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/reagent_containers/glass/bottle/result_bottle = new(get_turf(holder.my_atom))
	holder.trans_to(result_bottle, holder.total_volume)
	var/datum/reagent/virus_genes/result_genes = locate() in result_bottle.reagents.reagent_list
	var/list/strains = list("slime" = list())
	if(result_genes.data && result_genes.data["viruses"])
		for(var/datum/disease/advance/advanced_virus in result_genes.data["viruses"])
			strains["slime"] += list(advanced_virus.strain)
			result_bottle.name = "[advanced_virus.strain] Strain Viral Genetic Matter"
			break
	result_genes.data = strains

//Oil
/datum/chemical_reaction/slime_explosion
	name = "Slime Explosion"
	id = "m_explosion"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/oil
	required_other = TRUE

/datum/chemical_reaction/slime_explosion/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/slime_extract/oil/extract = holder.my_atom
	extract.visible_message("<span class='danger'>The slime extract begins to vibrate violently!</span>")
	addtimer(CALLBACK(src, PROC_REF(explode), extract), 5 SECONDS)

/datum/chemical_reaction/slime_explosion/proc/explode(obj/item/slime_extract/oil/extract)
	if(QDELETED(extract))
		return
	var/who = extract.injector_mob ? "[key_name_admin(extract.injector_mob)]" : "Unknown"
	var/turf/extract_turf = get_turf(extract)
	message_admins("[who] triggered an oil slime explosion at [COORD(extract_turf)].")
	log_game("[who] triggered an oil slime explosion at [COORD(extract_turf)].")
	explosion(extract_turf, 1, 3, 6, cause = "Oil Slime explosion")

/datum/chemical_reaction/oil_slick
	name = "Oil Potion"
	id = "O_potion"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/oil
	required_other = TRUE

/datum/chemical_reaction/oil_slick/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/slimepotion/oil_slick/P = new /obj/item/slimepotion/oil_slick
	P.forceMove(get_turf(holder.my_atom))

//Light Pink
/datum/chemical_reaction/slimepotion2
	name = "Slime Potion 2"
	id = "m_potion2"
	result = null
	result_amount = 1
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list("plasma_dust" = 1)
	required_other = TRUE

/datum/chemical_reaction/slimepotion2/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/slimepotion/sentience/P = new /obj/item/slimepotion/sentience
	P.forceMove(get_turf(holder.my_atom))

//Adamantine
/datum/chemical_reaction/slimegolem
	name = "Slime Golem"
	id = "m_golem"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/adamantine
	required_other = TRUE

/datum/chemical_reaction/slimegolem/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	new /obj/item/stack/sheet/mineral/adamantine(get_turf(holder.my_atom))

//Bluespace
/datum/chemical_reaction/slimefloor2
	name = "Bluespace Floor"
	id = "m_floor2"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/bluespace
	required_other = TRUE

/datum/chemical_reaction/slimefloor2/on_reaction(datum/reagents/holder, created_volume)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/stack/tile/bluespace/P = new /obj/item/stack/tile/bluespace
	P.amount = 25
	P.forceMove(get_turf(holder.my_atom))


/datum/chemical_reaction/slimecrystal
	name = "Slime Crystal"
	id = "m_crystal"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/bluespace
	required_other = TRUE

/datum/chemical_reaction/slimecrystal/on_reaction(datum/reagents/holder, created_volume)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	if(holder.my_atom)
		var/obj/item/stack/ore/bluespace_crystal/BC = new(get_turf(holder.my_atom))
		BC.visible_message("<span class='notice'>[BC] appears out of thin air!</span>")

//Cerulean
/datum/chemical_reaction/slimepsteroid2
	name = "Slime Steroid 2"
	id = "m_steroid2"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/cerulean
	required_other = TRUE

/datum/chemical_reaction/slimepsteroid2/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/slimepotion/enhancer/P = new /obj/item/slimepotion/enhancer
	P.forceMove(get_turf(holder.my_atom))



/datum/chemical_reaction/slime_territory
	name = "Slime Territory"
	id = "s_territory"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/cerulean
	required_other = TRUE

/datum/chemical_reaction/slime_territory/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/areaeditor/blueprints/slime/P = new /obj/item/areaeditor/blueprints/slime
	P.forceMove(get_turf(holder.my_atom))

//Sepia
/datum/chemical_reaction/slimestop
	name = "Slime Stop"
	id = "m_stop"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = TRUE

/datum/chemical_reaction/slimestop/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/mob/mob = get_mob_by_key(holder.my_atom.fingerprintslast)
	var/obj/effect/timestop/T = new /obj/effect/timestop
	T.forceMove(get_turf(holder.my_atom))
	T.immune += mob
	T.timestop()


/datum/chemical_reaction/slimecamera
	name = "Slime Camera"
	id = "m_camera"
	result = null
	required_reagents = list("water" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = TRUE

/datum/chemical_reaction/slimecamera/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/camera/P = new /obj/item/camera
	P.forceMove(get_turf(holder.my_atom))
	var/obj/item/camera_film/Z = new /obj/item/camera_film
	Z.forceMove(get_turf(holder.my_atom))

/datum/chemical_reaction/slimefloor
	name = "Sepia Floor"
	id = "m_floor"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = TRUE

/datum/chemical_reaction/slimefloor/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/stack/tile/sepia/P = new /obj/item/stack/tile/sepia
	P.amount = 25
	P.forceMove(get_turf(holder.my_atom))


//Pyrite


/datum/chemical_reaction/slimepaint
	name = "Slime Paint"
	id = "s_paint"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_container = /obj/item/slime_extract/pyrite
	required_other = TRUE

/datum/chemical_reaction/slimepaint/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/list/paints = subtypesof(/obj/item/reagent_containers/glass/paint)
	var/chosen = pick(paints)
	var/obj/P = new chosen
	if(P)
		P.forceMove(get_turf(holder.my_atom))

//Rainbow :o)
/datum/chemical_reaction/slime_rng
	name = "Random Core"
	id = "slimerng"
	result = null
	required_reagents = list("plasma_dust" = 1)
	result_amount = 1
	required_other = TRUE
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime_rng/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/mob/living/simple_animal/slime/random/S = new (get_turf(holder.my_atom))
	S.visible_message("<span class='danger'>Infused with plasma, the core begins to quiver and grow, and a new baby slime emerges from it!</span>")

/datum/chemical_reaction/slime_transfer
	name = "Transfer Potion"
	id = "slimetransfer"
	result = null
	required_reagents = list("blood" = 1)
	result_amount = 1
	required_other = TRUE
	required_container = /obj/item/slime_extract/rainbow

/datum/chemical_reaction/slime_transfer/on_reaction(datum/reagents/holder)
	SSblackbox.record_feedback("tally", "slime_cores_used", 1, type)
	var/obj/item/slimepotion/transference/P = new /obj/item/slimepotion/transference
	P.forceMove(get_turf(holder.my_atom))
