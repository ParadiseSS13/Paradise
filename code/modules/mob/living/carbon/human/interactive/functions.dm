/mob/living/carbon/human/interactive/proc/chatter(obj)
	var/verbs_use = pick_list(speak_file, "verbs_use")
	var/verbs_touch = pick_list(speak_file, "verbs_touch")
	var/verbs_move = pick_list(speak_file, "verbs_move")
	var/nouns_insult = pick_list(speak_file, "nouns_insult")
	var/nouns_generic = pick_list(speak_file, "nouns_generic")
	var/nouns_objects = pick_list(speak_file, "nouns_objects")
	var/nouns_body = pick_list(speak_file, "nouns_body")
	var/adjective_insult = pick_list(speak_file, "adjective_insult")
	var/adjective_objects = pick_list(speak_file, "adjective_objects")
	var/adjective_generic = pick_list(speak_file, "adjective_generic")
	var/curse_words = pick_list(speak_file, "curse_words")

	var/chatmsg = ""

	if(prob(10)) // 10% chance to broadcast it over the radio
		chatmsg = ";"

	if(prob(chattyness) || knownStrings.len < 10) // say a generic phrase, otherwise draw from our strings.
		if(doing & SNPC_INTERACTING)
			if(prob(chattyness))
				chatmsg += pick("This [nouns_objects] is a little [adjective_objects].",
				"Well [verbs_use] my [nouns_body], this [nouns_insult] is pretty [adjective_insult].",
				"[capitalize(curse_words)], what am I meant to do with this [adjective_insult] [nouns_objects].")
		else if(doing & SNPC_TRAVEL)
			if(prob(chattyness))
				chatmsg += pick("Oh [curse_words], [verbs_move]!",
				"Time to get my [adjective_generic] [adjective_insult] [nouns_body] elsewhere.",
				"I wonder if there is anything to [verbs_use] and [verbs_touch] somewhere else..")
		else if(doing & SNPC_FIGHTING)
			if(prob(chattyness))
				chatmsg += pick("I'm going to [verbs_use] you, you [adjective_insult] [nouns_insult]!",
				"Rend and [verbs_touch], Rend and [verbs_use]!",
				"You [nouns_insult], I'm going to [verbs_use] you right in the [nouns_body]. JUST YOU WAIT!")
		if(prob(chattyness/2))
			chatmsg = ";"
			var/what = pick(1,2,3,4,5)
			switch(what)
				if(1)
					chatmsg += "Well [curse_words], this is a [adjective_generic] situation."
				if(2)
					chatmsg += "Oh [curse_words], that [nouns_insult] was one hell of an [adjective_insult] [nouns_body]."
				if(3)
					chatmsg += "I want to [verbs_use] that [nouns_insult] when I find them."
				if(4)
					chatmsg += "[pick("Innocent","Guilty","Traitorous","Honk")] until proven [adjective_generic]!"
				if(5)
					var/toSay = ""
					for(var/i = 0; i < 5; i++)
						curse_words = pick_list(speak_file, "curse_words")
						toSay += "[curse_words] "
					chatmsg += "Hey [nouns_generic], why don't you go [copytext(toSay, 1, length(toSay))], you [nouns_insult]!"
	else if(prob(chattyness))
		chatmsg += pick(knownStrings)
		if(prob(25)) // cut out some phrases now and then to make sure we're fresh and new
			knownStrings -= pick(chatmsg)

	if(chatmsg != ";" && chatmsg != "")
		say(chatmsg)

/mob/living/carbon/human/interactive/proc/traitor(obj)

	if(traitorType == SNPC_PSYCHO && nearby.len)
		traitorTarget = pick(nearby)

	if(prob(traitorScale))
		if(!Adjacent(traitorTarget) && !(traitorType == SNPC_PSYCHO))
			tryWalk(get_turf(traitorTarget))
		else
			switch(traitorType)
				if(SNPC_BRUTE)
					retal = 1
					retal_target = traitorTarget
				if(SNPC_STEALTH)
					if(istype(traitorTarget,/mob)) // it's inside something, lets kick their shit in
						var/mob/M = traitorTarget
						if(!M.stat)
							retal = 1
							retal_target = traitorTarget
						else
							var/obj/item/I = traitorTarget
							I.loc = get_turf(traitorTarget) // pull it outta them
					else
						take_to_slot(traitorTarget)
				if(SNPC_MARTYR)
					custom_emote(1, "[src]'s chest opens up, revealing a large mass of explosives and tangled wires!")
					if(inactivity_period <= 0)
						inactivity_period = 9999 // technically infinite
						if(do_after(src, 60, target = traitorTarget))
							custom_emote(1, "A fire bursts from [src]'s eyes, igniting white hot and consuming [p_their()] body in a flaming explosion!")
							explosion(src, 6, 6, 6)
						else
							inactivity_period = 0
							custom_emote(1, "[src]'s chest closes, hiding [p_their()] insides.")
				if(SNPC_PSYCHO)
					var/choice = pick(typesof(/obj/item/grenade/chem_grenade) - /obj/item/grenade/chem_grenade)

					new choice(src)

					retal = 1
					retal_target = traitorTarget

/mob/living/carbon/human/interactive/proc/botany(obj)
	if(shouldModulePass())
		return

	if(enforceHome())
		return

	var/list/allContents = getAllContents()

	var/obj/item/reagent_containers/glass/beaker/bluespace/internalBeaker = locate(/obj/item/reagent_containers/glass/beaker/bluespace) in allContents
	var/obj/item/storage/bag/plants/internalBag = locate(/obj/item/storage/bag/plants) in allContents

	if(!internalBag)
		internalBag = new/obj/item/storage/bag/plants(src)
	if(!internalBeaker)
		internalBeaker = new/obj/item/reagent_containers/glass/beaker/bluespace(src)
		internalBeaker.name = "Grow-U-All Super Spray"

	if(internalBeaker && internalBag)
		var/obj/machinery/hydroponics/HP

		//consider the appropriate target
		var/list/considered = list()

		for(var/obj/machinery/hydroponics/tester in view(12,src))
			considered[tester] = 1

			if(!tester.myseed)
				considered[tester] += 50
			if(tester.weedlevel > 0)
				considered[tester] += 5
			if(tester.pestlevel > 0)
				considered[tester] += 5
			if(tester.nutrilevel <  tester.maxnutri)
				considered[tester] += 15
			if(tester.waterlevel < tester.maxwater)
				considered[tester] += 15
			if(tester.harvest || tester.dead)
				considered[tester] += 100
			considered[tester] = max(1, considered[tester] - get_dist(src,tester))

		var/index = 0
		for(var/A in considered)
			++index
			if(considered[A] > considered[HP] || !HP)
				HP = considered[index]

		if(HP)
			TARGET = HP
			if(!Adjacent(HP))
				tryWalk(get_turf(HP))
			else
				if(HP.harvest || HP.dead)
					HP.attack_hand(src)
				else if(!HP.myseed)
					var/obj/item/seeds/SEED = new /obj/item/seeds/random(src)
					custom_emote(1, "[pick("gibbers","drools","slobbers","claps wildly","spits")] towards [TARGET], producing a [SEED]!")
					HP.attackby(SEED, src)
				else
					var/change = 0
					if(HP.weedlevel > 0)
						change = 1
						if(!internalBeaker.reagents.has_reagent("atrazine", 10))
							internalBeaker.reagents.add_reagent("atrazine", 10)
					if(HP.pestlevel > 0)
						change = 1
						if(!internalBeaker.reagents.has_reagent("diethylamine", 10))
							internalBeaker.reagents.add_reagent("diethylamine", 10)
					if(HP.nutrilevel <  HP.maxnutri)
						change = 1
						if(!internalBeaker.reagents.has_reagent("eznutriment", 15))
							internalBeaker.reagents.add_reagent("eznutriment", 15)
						if(!internalBeaker.reagents.has_reagent("diethylamine", 15))
							internalBeaker.reagents.add_reagent("diethylamine", 15)
					if(HP.waterlevel < HP.maxwater)
						change = 1
						if(!internalBeaker.reagents.has_reagent("holywater", 50))
							internalBeaker.reagents.add_reagent("holywater", 50)
					if(change)
						HP.attackby(internalBeaker,src)

	var/obj/item/reagent_containers/food/snacks/grown/GF = locate(/obj/item/reagent_containers/food/snacks/grown) in view(12,src)
	if(GF)
		if(!Adjacent(GF))
			tryWalk(get_turf(GF))
		else
			GF.attackby(internalBag,src)

	if(internalBag.contents.len)
		var/obj/machinery/smartfridge/SF = locate(/obj/machinery/smartfridge) in range(12, src)
		if(!Adjacent(SF))
			tryWalk(get_turf(SF))
		else
			custom_emote(1, "[pick("gibbers","drools","slobbers","claps wildly","spits")], upending the [internalBag]'s contents all over the [SF]!")
			//smartfridges call updateUsrDialog when you call attackby, so we're going to have to cheese-magic-space this
			for(var/obj/toLoad in internalBag.contents)
				if(contents.len >= SF.max_n_of_items)
					break
				if(SF.accept_check(toLoad))
					SF.load(toLoad, src)
				else
					qdel(toLoad) // destroy everything we dont need

/mob/living/carbon/human/interactive/proc/bartend(obj)
	if(shouldModulePass())
		return

	if(enforceHome())
		return

	var/list/rangeCheck = oview(6,src)
	var/obj/structure/table/RT

	var/mob/living/carbon/human/serveTarget

	for(var/mob/living/carbon/human/H in rangeCheck)
		if(!locate(/obj/item/reagent_containers/food/drinks) in orange(1, H))
			serveTarget = H


	if(serveTarget)
		RT = locate(/obj/structure/table) in orange(1, serveTarget)

	if(RT && serveTarget)
		if(!Adjacent(RT))
			tryWalk(get_turf(RT))
		else
			var/drinkChoice = pick(typesof(/obj/item/reagent_containers/food/drinks) - /obj/item/reagent_containers/food/drinks)
			if(drinkChoice)
				var/obj/item/reagent_containers/food/drinks/D = new drinkChoice(get_turf(src))
				RT.attackby(D,src)
				say("[pick("Something to wet your whistle!","Down the hatch, a tasty beverage!","One drink, coming right up!","Tasty liquid for your oral intake!","Enjoy!")]")
				custom_emote(2, "[pick("gibbers","drools","slobbers","claps wildly","spits")], serving up a [D]!")

/mob/living/carbon/human/interactive/proc/shitcurity(obj)
	var/list/allContents = getAllContents()

	if(retal && TARGET)
		if(Adjacent(TARGET))
			var/obj/item/restraints/R = locate() in allContents
			if(R)
				R.attack(TARGET, src) // go go bluespace restraint launcher!
		else if(TARGET in oview(7, src))
			var/obj/item/gun/G = locate() in allContents
			if(G)
				G.afterattack(TARGET, src)

/mob/living/carbon/human/interactive/proc/clowning(obj)
	if(shouldModulePass())
		return
	var/list/allContents = getAllContents()
	var/list/rangeCheck = oview(12, src)

	var/mob/living/carbon/human/clownTarget
	var/list/clownPriority = list()

	var/obj/item/reagent_containers/spray/S
	if(!locate(/obj/item/reagent_containers/spray) in allContents)
		new/obj/item/reagent_containers/spray(src)
	else
		S = locate(/obj/item/reagent_containers/spray) in allContents

	for(var/mob/living/carbon/human/C in rangeCheck)
		var/pranksNearby = 100
		for(var/turf/simulated/T in orange(1, C))
			for(var/obj/item/A in T)
				if(istype(A,/obj/item/soap) || istype(A,/obj/item/reagent_containers/food/snacks/grown/banana) || istype(A,/obj/item/grown/bananapeel))
					pranksNearby--
			if(T.wet)
				pranksNearby -= 10
		clownPriority[C] = pranksNearby

	for(var/A in clownPriority)
		if(!clownTarget)
			clownTarget = A
		else
			if(clownPriority[A] > clownPriority[clownTarget])
				clownTarget = clownPriority[A]

	if(clownTarget)
		if(!Adjacent(clownTarget))
			tryWalk(clownTarget)
		else
			var/hasPranked = 0
			for(var/A in allContents)
				if(prob(smartness/2) && !hasPranked)
					if(istype(A,/obj/item/soap))
						npcDrop(A)
						hasPranked = 1
					if(istype(A,/obj/item/reagent_containers/food/snacks/grown/banana))
						var/obj/item/reagent_containers/food/snacks/B = A
						B.attack(src, src)
					if(istype(A,/obj/item/grown/bananapeel))
						npcDrop(A)
						hasPranked = 1
			if(!hasPranked)
				if(S.reagents.total_volume <= 5)
					S.reagents.add_reagent("water", 25)
				S.afterattack(get_turf(pick(orange(1, clownTarget))),src)


/mob/living/carbon/human/interactive/proc/healpeople(obj)
	var/shouldTryHeal = 0
	var/obj/item/stack/medical/M

	var/list/allContents = getAllContents()

	for(var/A in allContents)
		if(istype(A,/obj/item/stack/medical))
			shouldTryHeal = 1
			M = A

	var/obj/item/reagent_containers/hypospray/HPS

	if(!locate(/obj/item/reagent_containers/hypospray) in allContents)
		new/obj/item/reagent_containers/hypospray(src)
	else
		HPS = locate(/obj/item/reagent_containers/hypospray) in allContents
		if(!shouldTryHeal)
			shouldTryHeal = 2 // we have no stackables to use, lets use our internal hypospray instead

	if(shouldTryHeal == 1)
		for(var/mob/living/carbon/human/C in nearby)
			if(istype(C,/mob/living/carbon/human)) //I haven't the foggiest clue why this is turning up non-carbons but sure here whatever
				if(C.health <= 75)
					if(get_dist(src,C) <= 2)
						src.say("Wait, [C], let me heal you!")
						M.attack(C,src)
						sleep(25)
					else
						tryWalk(get_turf(C))
	else if(shouldTryHeal == 2)
		if(HPS)
			if(HPS.reagents.total_volume <= 0)
				HPS.reagents.add_reagent("omnizine",30)
			for(var/mob/living/carbon/human/C in nearby)
				if(istype(C,/mob/living/carbon/human))
					if(C.health <= 75 && C.reagents.get_reagent_amount("omnizine") <= 0) // make sure they wont be overdosing
						if(get_dist(src,C) <= 2)
							src.say("Wait, [C], let me heal you!")
							HPS.attack(C,src)
							sleep(25)
						else
							tryWalk(get_turf(C))


/mob/living/carbon/human/interactive/proc/dojanitor(obj)
	if(shouldModulePass())
		return
	var/list/allContents = getAllContents()
	//now with bluespace magic!
	var/obj/item/reagent_containers/spray/SP = locate() in allContents
	if(!SP)
		SP = new /obj/item/reagent_containers/spray(src)
	var/obj/item/soap/SO = locate() in allContents
	if(!SO)
		SO = new /obj/item/soap(src)

	if(SP.reagents.total_volume <= 5)
		SP.reagents.add_reagent("cleaner", 25) // bluespess water delivery for AI

	var/obj/effect/decal/cleanable/TC
	TC = locate(/obj/effect/decal/cleanable) in view(6, src)

	if(TC)
		if(!Adjacent(TC))
			tryWalk(TC)
		else
			var/turf/T = get_turf(TC)
			if(T && !T.density)
				SP.afterattack(TC, src, 1)
			else
				SO.afterattack(TC, src, 1)
				qdel(TC)

// START COOKING MODULE
/mob/living/carbon/human/interactive/proc/refundrecipe(list/ingredients)
	for(var/obj/I in ingredients)
		I.loc = contents

// Ingredients may be in the rangeCheck or inside the chef's inventory.
// As they are checked off, they are moved to a seperate list as to not be counted twice
// If the recipe fails (eg somebody else took an ingredient before it was picked up) the ingredients are dumped back to inventory
// That way, the chef has a better chance of making a recipe next ptick, if he has more stuff on him
/mob/living/carbon/human/interactive/proc/makerecipe(datum/recipe/R, allContents, rangeCheck)
	set background = 1

	var/list/ingredients[0]

	for(var/P in R.items)
		var/obj/item/I = locate(P) in allContents
		if(I)
			ingredients += I
			I.forceMove(null)
			continue

		I = locate(P) in rangeCheck
		TARGET = I
		if(I && !Adjacent(I))
			tryWalk(get_turf(I))
			sleep(get_dist(src, I))
		if(!I || !(I in rangeCheck))
			refundrecipe(ingredients)
			return 0
		custom_emote(1, "[pick("gibbers","drools","slobbers","claps wildly","spits")], picking up [I].")
		ingredients += I
		I.forceMove(null)

	// cheaply cook the ingredients into result
	sleep(R.time)
	for(var/obj/I in ingredients)
		qdel(I)
	ingredients.Cut()
	var/result = new R.result(get_turf(src))
	custom_emote(1, "[pick("gibbers","drools","slobbers","claps wildly","spits")] and, with a bang, \a [result] is cooked!")
	return 1

/mob/living/carbon/human/interactive/proc/souschef(obj)
	if(shouldModulePass() || enforceHome() || prob(SNPC_FUZZY_CHANCE_HIGH) || prob(SNPC_FUZZY_CHANCE_HIGH))
		return

	if(doing & SNPC_SPECIAL)
		return
	doing |= SNPC_SPECIAL

	var/static/list/customableTypes = list(/obj/item/reagent_containers/food/snacks/customizable,/obj/item/reagent_containers/food/snacks/breadslice,/obj/item/reagent_containers/food/snacks/bun,/obj/item/reagent_containers/food/snacks/sliceable/flatdough,/obj/item/reagent_containers/food/snacks/boiledspaghetti,/obj/item/trash/plate,/obj/item/trash/bowl)

	var/static/list/rawtypes = list(/obj/item/reagent_containers/food/snacks/grown, /obj/item/reagent_containers/food/snacks/rawcutlet, /obj/item/reagent_containers/food/snacks/rawsticks, /obj/item/reagent_containers/food/snacks/salmonmeat, /obj/item/reagent_containers/food/snacks/carpmeat, /obj/item/reagent_containers/food/snacks/catfishmeat, /obj/item/reagent_containers/food/snacks/spaghetti, /obj/item/reagent_containers/food/snacks/dough, /obj/item/reagent_containers/food/snacks/sliceable/flatdough, /obj/item/reagent_containers/food/snacks/doughslice, /obj/item/reagent_containers/food/snacks/meat, /obj/item/reagent_containers/food/snacks/boiledrice, /obj/item/reagent_containers/food/snacks/cheesewedge, /obj/item/reagent_containers/food/snacks/raw_bacon)

	try
		var/list/allContents = getAllContents()
		var/list/rangeCheck = view(6, src)

		//Bluespace in some inbuilt tools
		var/obj/item/kitchen/rollingpin/RP = locate() in allContents
		if(!RP)
			RP = new /obj/item/kitchen/rollingpin(src)

		var/obj/item/kitchen/knife/KK = locate() in allContents
		if(!KK)
			KK = new /obj/item/kitchen/knife(src)

		var/global/list/available_recipes
		if(!available_recipes)
			available_recipes = list()
			for(var/type in subtypesof(/datum/recipe))
				var/datum/recipe/recipe = new type
				if(recipe.result) // Ignore recipe subtypes that lack a result
					available_recipes += recipe
				else
					qdel(recipe)

		var/foundCookable = 0

		//Make some basic custom food
		var/foundCustom
		for(var/customType in customableTypes)
			var/A = locate(customType) in rangeCheck
			var/obj/item/reagent_containers/food/snacks/customizable/I = A
			if(A && (!istype(I) || I.ingredients.len <= 3))
				foundCustom = A // this will eventually wittle down to 0
				break

		var/obj/machinery/smartfridge/SF = locate(/obj/machinery/smartfridge) in rangeCheck
		if(SF)
			if(SF.contents.len > 0)
				if(!Adjacent(SF))
					tryWalk(get_turf(SF))
				else
					custom_emote(2, "[pick("gibbers","drools","slobbers","claps wildly","spits")], grabbing various foodstuffs from [SF] and sticking them in its mouth!")
					for(var/obj/item/A in SF.contents)
						if(prob(smartness/2))
							var/count = SF.item_quants[A.name]
							if(count)
								SF.item_quants[A.name] = count - 1
							A.forceMove(src)

		if(foundCustom)
			var/obj/item/reagent_containers/food/snacks/FC = foundCustom
			for(var/obj/item/reagent_containers/food/snacks/toMake in allContents)
				if(prob(smartness))
					if(FC.reagents)
						if(toMake.reagents)
							var/raw = 0
							for(var/type in rawtypes)
								if(istype(toMake, type))
									raw = 1
									break
							if(!raw)
								npcDrop(toMake)
								FC.attackby(toMake, src)
								allContents -= toMake
								break
					else
						qdel(FC) // this food is usless, toss it

		// Process tool-based ingredients
		var/obj/item/reagent_containers/food/snacks/dough/D = locate() in rangeCheck
		var/obj/item/reagent_containers/food/snacks/sliceable/flatdough/FD = locate() in rangeCheck
		var/obj/item/reagent_containers/food/snacks/rawcutlet/RC = locate() in rangeCheck
		var/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel/CW = locate() in rangeCheck
		var/obj/item/reagent_containers/food/snacks/grown/potato/PO = locate() in rangeCheck
		var/obj/item/reagent_containers/food/snacks/meat/ME = locate() in rangeCheck
		var/obj/item/reagent_containers/food/snacks/raw_bacon/RB = locate() in rangeCheck

		if(D)
			TARGET = D
			if(prob(50))
				tryWalk(get_turf(D))
				sleep(get_dist(src, D))
				D.attackby(RP, src)
			foundCookable = 1
		else if(FD)
			TARGET = FD
			if(prob(50))
				tryWalk(get_turf(FD))
				sleep(get_dist(src, FD))
				FD.attackby(KK, src)
			foundCookable = 1
		else if(RC)
			TARGET = RC
			if(prob(50))
				tryWalk(get_turf(RC))
				sleep(get_dist(src, RC))
				RC.attackby(KK, src)
			foundCookable = 1
		else if(CW)
			TARGET = CW
			if(prob(50))
				tryWalk(get_turf(CW))
				sleep(get_dist(src, CW))
				CW.attackby(KK, src)
			foundCookable = 1
		else if(PO)
			TARGET = PO
			if(prob(50))
				tryWalk(get_turf(PO))
				sleep(get_dist(src, PO))
				PO.attackby(KK, src)
			foundCookable = 1
		else if(ME)
			TARGET = ME
			if(prob(50))
				tryWalk(get_turf(ME))
				sleep(get_dist(src, ME))
				ME.attackby(KK, src)
			foundCookable = 1
		else if(RB)
			TARGET = RB
			if(prob(50))
				tryWalk(get_turf(RB))
				sleep(get_dist(src, RB))
				RB.attackby(KK, src)
			foundCookable = 1

		// refresh
		allContents = getAllContents()
		rangeCheck = view(6, src)

		// Find most complex recipe we can cook
		var/ingredientZone = rangeCheck + allContents
		var/highest_count = 0
		var/datum/recipe/winner = null
		for(var/datum/recipe/R in available_recipes)
			if(R.check_items(ingredientZone) >= 0)
				var/count = (R.items ? R.items.len : 0)
				if(count > highest_count)
					highest_count = count
					winner = R

		// make winner
		if(winner)
			if(makerecipe(winner, allContents, rangeCheck))
				foundCookable = 1

		// refresh
		allContents = getAllContents()
		rangeCheck = view(6, src)

		// dont display our ingredients
		var/list/finishedList = list()
		for(var/obj/item/reagent_containers/food/snacks/toDisplay in allContents)
			var/raw = 0
			for(var/type in rawtypes)
				if(istype(toDisplay, type))
					raw = 1
					break
			if(!raw)
				finishedList += toDisplay

		for(var/obj/item/reagent_containers/food/snacks/toGrab in rangeCheck)
			if(!(locate(/obj/structure/table/reinforced) in get_turf(toGrab))) //it's not being displayed
				var/raw = 0
				for(var/type in rawtypes)
					if(istype(toGrab, type))
						raw = 1
						break
				if(!raw)
					foundCookable = 1
					if(!Adjacent(toGrab))
						tryWalk(toGrab)
					else
						finishedList += toGrab
						toGrab.forceMove(src)

		if(finishedList.len)
			var/obj/structure/table/reinforced/RT

			for(var/obj/structure/table/reinforced/toCheck in rangeCheck)
				var/counted = 0
				for(var/obj/item/reagent_containers/food/snacks/S in get_turf(toCheck))
					++counted
				if(counted < 12) // make sure theres not too much food here
					RT = toCheck
					break

			if(RT)
				foundCookable = 1
				if(!Adjacent(RT))
					tryWalk(get_turf(RT))
				else
					for(var/obj/item/reagent_containers/food/snacks/toPlop in finishedList)
						RT.attackby(toPlop,src)

		if(!foundCookable)
			var/chosenType = pick(rawtypes)

			var/obj/item/reagent_containers/food/snacks/newSnack = new chosenType(get_turf(src))
			TARGET = newSnack
			newSnack.reagents.remove_any((newSnack.reagents.total_volume/2)-1)
			newSnack.name = "synthetic [newSnack.name]"
			custom_emote(2, "[pick("gibbers","drools","slobbers","claps wildly","spits")] as [p_they()] vomit[p_s()] [newSnack] from [p_their()] mouth!")
	catch(var/exception/e)
		log_runtime(e, src, "Caught in SNPC cooking module")
	doing &= ~SNPC_SPECIAL
// END COOKING MODULE

/mob/living/carbon/human/interactive/proc/combat(obj)
	set background = 1
	enforce_hands()
	if(canmove)
		if((graytide || (TRAITS & TRAIT_MEAN)) || retal)
			interest += targetInterestShift
			a_intent = INTENT_HARM
			zone_sel.selecting = pick("chest","r_leg","l_leg","r_arm","l_arm","head")
			doing |= SNPC_FIGHTING
			if(retal)
				TARGET = retal_target
			else
				var/mob/living/M = locate(/mob/living) in oview(7, src)
				if(!M)
					doing = doing & ~SNPC_FIGHTING
				else if(M != src && !compareFaction(M.faction))
					TARGET = M

	//no infighting
	if(retal)
		if(retal_target)
			if(compareFaction(retal_target.faction))
				retal = 0
				retal_target = null
				TARGET = null
				doing = 0

	//ensure we're using the best object possible

	var/obj/item/best
	var/foundFav = 0
	var/list/allContents = getAllContents()
	for(var/test in allContents)
		for(var/a in favoured_types)
			if(ispath(test,a) && !(doing & SNPC_FIGHTING)) // if we're not in combat and we find our favourite things, use them (for people like janitor and doctors)
				best = test
				foundFav = 1
				return
		if(!foundFav)
			if(istype(test,/obj/item))
				var/obj/item/R = test
				if(R.force > 2) // make sure we don't equip any non-weaponlike items, ie bags and stuff
					if(!best)
						best = R
					else
						if(best.force < R.force)
							best = R
					if(istype(R, /obj/item/gun))
						var/obj/item/gun/G = R
						if(G.can_shoot())
							best = R
							break // gun with ammo? screw the rest
	if(best && best != main_hand)
		take_to_slot(best,1)

	if(TARGET && (doing & SNPC_FIGHTING)) // this is a redundancy check
		var/mob/living/M = TARGET
		if(istype(M,/mob/living))
			if(M.health > 1 && (M in oview(src, 6)))
				//THROWING OBJECTS
				for(var/A in allContents)
					if(istype(A,/obj/item/gun))	// guns are for shooting, not throwing.
						continue
					if(prob(robustness))
						if(istype(A,/obj/item))
							var/obj/item/W = A
							if(W.throwforce > 19) // Only throw worthwile stuff, no more lobbing wrenches at wenches
								npcDrop(W, 1)
								throw_item(TARGET)
						if(istype(A,/obj/item/grenade)) // Allahu ackbar! ALLAHU ACKBARR!!
							var/obj/item/grenade/G = A
							G.attack_self(src)
							if(prob(smartness))
								npcDrop(G, 1)
								sleep(15)
								throw_item(TARGET)

				if(!main_hand && other_hand)
					swap_hands()
				if(main_hand)
					if(main_hand.force != 0)
						if(istype(main_hand,/obj/item/gun))
							var/obj/item/gun/G = main_hand
							if(G.can_trigger_gun(src))
								var/shouldFire = 1
								if(istype(main_hand, /obj/item/gun/energy))
									var/obj/item/gun/energy/P = main_hand
									var/stunning = 0
									for(var/A in P.ammo_type)
										if(ispath(A,/obj/item/ammo_casing/energy/electrode))
											stunning = 1
									var/mob/stunCheck = TARGET
									if(stunning && stunCheck.stunned)
										shouldFire = 0
								if(shouldFire)
									if(!G.can_shoot())
										G.shoot_with_empty_chamber(src)
										npcDrop(G, 1)
									else
										G.process_fire(TARGET, src)
								else
									if(get_dist(src,TARGET) > 6)
										if(!walk2derpless(TARGET))
											timeout++
									else
										var/obj/item/W = main_hand
										W.attack(TARGET, src)
							else
								npcDrop(G, 1)
				else
					if(targetRange(TARGET) > 2)
						tryWalk(TARGET)
					else
						if(Adjacent(TARGET))
							a_intent = pick(INTENT_DISARM, INTENT_HARM)
							M.attack_hand(src)
			timeout++
		else if(timeout >= 10 || !(targetRange(M) > 14))
			doing = doing & ~SNPC_FIGHTING
			timeout = 0
			TARGET = null
			retal = 0
			retal_target = null
		else
			timeout++

/mob/living/carbon/human/interactive/proc/past_verb(word)
	if(copytext(word, length(word)) == "e")
		return "[word]d"
	else
		return "[word]ed"

/mob/living/carbon/human/interactive/proc/ing_verb(word)
	if(copytext(word, length(word)) == "e")
		return "[copytext(word, 1, length(word))]ing"
	else
		return "[word]ing"

/mob/living/carbon/human/interactive/proc/paperwork_sentence()
	var/verbs_use = pick_list(speak_file, "verbs_use")
	var/verbs_touch = pick_list(speak_file, "verbs_touch")
	var/verbs_move = pick_list(speak_file, "verbs_move")
	var/nouns_insult = pick_list(speak_file, "nouns_insult")
	var/nouns_generic = pick_list(speak_file, "nouns_generic")
	var/nouns_objects = pick_list(speak_file, "nouns_objects")
	var/nouns_body = pick_list(speak_file, "nouns_body")
	var/adjective_insult = pick_list(speak_file, "adjective_insult")
	var/adjective_objects = pick_list(speak_file, "adjective_objects")
	var/adjective_generic = pick_list(speak_file, "adjective_generic")
	var/curse_words = pick_list(speak_file, "curse_words")
	var/result = pick("fired", "promoted", "demoted", "terminated", "incinerated", "sent to CentCom", "borged")

	return pick(
		"The [adjective_insult] [pick(command_positions)] [past_verb(verbs_touch)] the [adjective_objects] [nouns_objects] and was [result].",
		"The [adjective_generic] [pick(engineering_positions)] [past_verb(verbs_touch)] the [adjective_insult] [nouns_objects]. [capitalize(curse_words)], the [nouns_insult] was [result].",
		"The [adjective_insult] [pick(security_positions)] [past_verb(verbs_touch)] the [adjective_generic] [nouns_insult] [pick(support_positions)]'s [nouns_body] and had to be [result].",
		"Medical had to [verbs_use] the [adjective_generic] [pick(command_positions)]'s [adjective_objects] [nouns_body] after the incident.",
		"I demand that [nouns_generic] respond with a [adjective_generic] update ASAP.",
		"Would like an update from [nouns_generic] regarding the [adjective_insult] [pick(command_positions)] being [result].",
		"The [pick(medical_positions)] needs to [verbs_move] faster when the crew's [adjective_objects] [nouns_body]s are injured, or they will be [result].",
		"[capitalize(curse_words)] [adjective_insult] [curse_words].",
		"<br><br>")

/mob/living/carbon/human/interactive/proc/pickStamp(allContents)
	var/list/stamps[0]
	for(var/obj/item/stamp/S in allContents)
		stamps += S
	if(stamps.len)
		return pick(stamps)

	// just make one, maybe
	if(prob(SNPC_FUZZY_CHANCE_LOW / 2))
		for(var/p in favoured_types)
			if(ispath(p, /obj/item/stamp))
				return new p(src)
	return null

/mob/living/carbon/human/interactive/proc/paperwork(obj)
	set background = 1

	if(shouldModulePass() || !prob(SNPC_FUZZY_CHANCE_LOW / 4))
		return

	var/list/allContents = getAllContents()

	var/obj/item/paper/P = locate() in allContents
	var/obj/item/stamp/S = pickStamp(allContents)
	var/mob/living/carbon/human/H = locate() in nearby

	if(!P)
		P = new /obj/item/paper(src)

	if(P && S && H)
		if(!P.stamped || !P.stamped.len)
			// generate form
			P.name = pick("Inspection Report", "Re: Crew", "Complaint", "To: CentCom")
			P.info = {"<center><img src=ntlogo.png><br><b><font size="1">[paperwork_sentence()]</font></b></center>"}
			for(var/I in 1 to rand(10, 20))
				P.info += "[paperwork_sentence()] "
			P.info += {"<br><br>[pick("Signed", "Sincerely", "Regards")], <font face="Times New Roman"><i>[real_name]</i></font>"}
			P.update_icon()
			P.stamp(S)
			custom_emote(2, "[pick("gibbers","drools","slobbers","claps wildly","spits")] and throws [P] on the ground!")
		npcDrop(P)
		P.throw_at(H, P.throw_range, P.throw_speed, src)

/mob/living/carbon/human/interactive/proc/stamping(obj)
	if(shouldModulePass())
		return

	var/list/allContents = getAllContents()
	var/list/rangeCheck = view(7, src)

	var/obj/item/stamp/S = pickStamp(allContents)
	if(!S)
		return

	// stamp a paper we're holding, and drop it
	var/obj/item/paper/P = locate() in allContents
	if(P)
		if(!P.stamped || !P.stamped.len)
			P.stamp(S)
			custom_emote(2, "[pick("gibbers","drools","slobbers","claps wildly","spits")] as they stamp \the [P] with \a [S]!")
		npcDrop(P, 1)
		return

	// stamp a paper in the world
	for(var/obj/item/paper/A in rangeCheck)
		if(!A.stamped || !A.stamped.len)
			if(!Adjacent(A))
				tryWalk(A)
			else
				A.stamp(S)
				custom_emote(2, "[pick("gibbers","drools","slobbers","claps wildly","spits")] as they stamp \the [A] with \a [S]!")
			return
