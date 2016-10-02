//Analyzer, pestkillers, weedkillers, nutrients, hatchets, cutters, Rapid-Seed-Producer (RSP), corn cob.

/obj/item/weapon/wirecutters/clippers
	name = "plant clippers"
	desc = "A tool used to take samples from plants."

/obj/item/device/analyzer/plant_analyzer
	name = "plant analyzer"
	desc = "A scanner used to evaluate a plant's various areas of growth."
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	item_state = "analyzer"
	origin_tech = "magnets=1;biotech=1"
	var/form_title
	var/last_data

/obj/item/device/analyzer/plant_analyzer/proc/print_report_verb()
	set name = "Print Plant Report"
	set category = "Object"
	set src = usr

	if(usr.stat || usr.restrained() || usr.lying)
		return
	print_report(usr)

/obj/item/device/analyzer/plant_analyzer/Topic(href, href_list)
	if(..())
		return
	if(href_list["print"])
		print_report(usr)

/obj/item/device/analyzer/plant_analyzer/proc/print_report(var/mob/living/user)
	if(!last_data)
		to_chat(user, "There is no scan data to print.")
		return
	playsound(loc, "sound/goonstation/machines/printer_thermal.ogg", 50, 1)
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
	P.name = "paper - [form_title]"
	P.info = "[last_data]"
	if(istype(user,/mob/living/carbon/human) && !(user.l_hand && user.r_hand))
		user.put_in_hands(P)
	user.visible_message("\The [src] spits out a piece of paper.")
	return

/obj/item/device/analyzer/plant_analyzer/attack_self(mob/user as mob)
	print_report(user)
	return 0

/obj/item/device/analyzer/plant_analyzer/afterattack(obj/target, mob/user, flag)
	if(!flag) return

	var/datum/seed/grown_seed
	var/datum/reagents/grown_reagents

	//--FalseIncarnate
	var/IS_TRAY = 0			//used to track if the target is a hydroponics tray or soil. 1 if true, otherwise 0
	var/tray_age			//age of the plant in the tray
	var/tray_weed_level		//weed level of tray
	var/tray_pest_level		//pest level of tray
	var/tray_toxins			//toxicity of the tray
	var/tray_yield_mod		//yield modifier of the tray
	var/tray_mutation_mod	//mutation modifier of the tray
	//--FalseIncarnate

	if(istype(target,/obj/structure/table))
		return ..()
	else if(istype(target,/obj/item/weapon/reagent_containers/food/snacks/grown))

		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = target
		grown_seed = plant_controller.seeds[G.plantname]
		grown_reagents = G.reagents

	else if(istype(target,/obj/item/weapon/grown))

		var/obj/item/weapon/grown/G = target
		grown_seed = plant_controller.seeds[G.plantname]
		grown_reagents = G.reagents

	else if(istype(target,/obj/item/seeds))

		var/obj/item/seeds/S = target
		grown_seed = S.seed

	else if(istype(target,/obj/machinery/portable_atmospherics/hydroponics))

		var/obj/machinery/portable_atmospherics/hydroponics/H = target

		//--FalseIncarnate
		//Flag the target as a tray for showing tray-specific stats
		IS_TRAY = 1
		//Save tray data to matching variables
		tray_age			= H.age
		tray_weed_level		= H.weedlevel
		tray_pest_level		= H.pestlevel
		tray_toxins			= H.toxins
		tray_yield_mod		= H.yield_mod
		tray_mutation_mod	= H.mutation_mod
		//--FalseIncarnate

		grown_seed = H.seed
		grown_reagents = H.reagents

	if(!grown_seed)
		to_chat(user, "<span class='danger'>[src] can tell you nothing about \the [target].</span>")
		return

	form_title = "[grown_seed.seed_name] (#[grown_seed.uid])"
	var/dat = "<h3>Plant data for [form_title]</h3>"
	user.visible_message("<span class='notice'>[user] runs the scanner over \the [target].</span>")

	dat += "<h2>General Data</h2>"

	dat += "<table>"
	dat += "<tr><td><b>Endurance</b></td><td>[grown_seed.get_trait(TRAIT_ENDURANCE)]</td></tr>"
	dat += "<tr><td><b>Yield</b></td><td>[grown_seed.get_trait(TRAIT_YIELD)]</td></tr>"
	dat += "<tr><td><b>Maturation time</b></td><td>[grown_seed.get_trait(TRAIT_MATURATION)]</td></tr>"
	dat += "<tr><td><b>Production time</b></td><td>[grown_seed.get_trait(TRAIT_PRODUCTION)]</td></tr>"
	dat += "<tr><td><b>Potency</b></td><td>[grown_seed.get_trait(TRAIT_POTENCY)]</td></tr>"
	dat += "<tr><td><b>Species Discovery Value</b></td><td>[grown_seed.get_trait(TRAIT_RARITY)]</td></tr>"

	//--FalseIncarnate
	//Tray-specific stats like Age and Mutation Modifier, not shown if target was not a hydroponics tray or soil
	if(IS_TRAY == 1)
		dat += "<tr><td></td></tr>"
		dat += "<tr><td><b>Age</b></td><td>[tray_age]</td></tr>"
		dat += "<tr><td><b>Weed Level</b></td><td>[tray_weed_level]</td></tr>"
		dat += "<tr><td><b>Pest Level</b></td><td>[tray_pest_level]</td></tr>"
		dat += "<tr><td><b>Toxins</b></td><td>[tray_toxins]</td></tr>"
		dat += "<tr><td><b>Yield Modifier</b></td><td>[tray_yield_mod]</td></tr>"
		dat += "<tr><td><b>Mutation Modifier</b></td><td>[tray_mutation_mod]</td></tr>"
	//--FalseIncarnate

	dat += "</table>"

	if(grown_reagents && grown_reagents.reagent_list && grown_reagents.reagent_list.len)
		dat += "<h2>Reagent Data</h2>"

		dat += "<br>This sample contains: "
		for(var/datum/reagent/R in grown_reagents.reagent_list)
			dat += "<br>- [R.id], [grown_reagents.get_reagent_amount(R.id)] unit(s)"

	dat += "<h2>Other Data</h2>"

	if(grown_seed.get_trait(TRAIT_HARVEST_REPEAT))
		dat += "This plant can be harvested repeatedly.<br>"

	if(grown_seed.get_trait(TRAIT_IMMUTABLE) == -1)
		dat += "This plant is highly mutable.<br>"
	else if(grown_seed.get_trait(TRAIT_IMMUTABLE) > 0)
		dat += "This plant does not possess genetics that are alterable.<br>"

	if(grown_seed.get_trait(TRAIT_REQUIRES_NUTRIENTS))
		if(grown_seed.get_trait(TRAIT_NUTRIENT_CONSUMPTION) < 0.05)
			dat += "It consumes a small amount of nutrient fluid.<br>"
		else if(grown_seed.get_trait(TRAIT_NUTRIENT_CONSUMPTION) > 0.2)
			dat += "It requires a heavy supply of nutrient fluid.<br>"
		else
			dat += "It requires a supply of nutrient fluid.<br>"

	if(grown_seed.get_trait(TRAIT_REQUIRES_WATER))
		if(grown_seed.get_trait(TRAIT_WATER_CONSUMPTION) < 1)
			dat += "It requires very little water.<br>"
		else if(grown_seed.get_trait(TRAIT_WATER_CONSUMPTION) > 5)
			dat += "It requires a large amount of water.<br>"
		else
			dat += "It requires a stable supply of water.<br>"

	if(grown_seed.mutants && grown_seed.mutants.len)
		dat += "It exhibits a high degree of potential subspecies shift.<br>"

	dat += "It thrives in a temperature of [grown_seed.get_trait(TRAIT_IDEAL_HEAT)] Kelvin."

	if(grown_seed.consume_gasses && grown_seed.consume_gasses.len)
		for(var/gas in grown_seed.consume_gasses)
			if(gas == "carbon_dioxide")	gas = "carbon dioxide"
			if(gas == "toxins")	gas = "plasma"
			dat += "<br>It requires an environment rich in [gas] gas to thrive."

	if(grown_seed.exude_gasses && grown_seed.exude_gasses.len)
		for(var/gas in grown_seed.exude_gasses)
			if(gas == "carbon_dioxide")	gas = "carbon dioxide"
			if(gas == "toxins")	gas = "plasma"
			dat += "<br>It releases [gas] gas as a byproduct of it's growth."

	if(grown_seed.get_trait(TRAIT_LOWKPA_TOLERANCE) < 20)
		dat += "<br>It is well adapted to low pressure levels."
	if(grown_seed.get_trait(TRAIT_HIGHKPA_TOLERANCE) > 220)
		dat += "<br>It is well adapted to high pressure levels."

	if(grown_seed.get_trait(TRAIT_HEAT_TOLERANCE) > 30)
		dat += "<br>It is well adapted to a range of temperatures."
	else if(grown_seed.get_trait(TRAIT_HEAT_TOLERANCE) < 10)
		dat += "<br>It is very sensitive to temperature shifts."

	dat += "<br>It thrives in a light level of [grown_seed.get_trait(TRAIT_IDEAL_LIGHT)] lumen[grown_seed.get_trait(TRAIT_IDEAL_LIGHT) == 1 ? "" : "s"]."

	if(grown_seed.get_trait(TRAIT_LIGHT_TOLERANCE) > 10)
		dat += "<br>It is well adapted to a range of light levels."
	else if(grown_seed.get_trait(TRAIT_LIGHT_TOLERANCE) < 3)
		dat += "<br>It is very sensitive to light level shifts."

	if(grown_seed.get_trait(TRAIT_TOXINS_TOLERANCE) < 3)
		dat += "<br>It is highly sensitive to toxins."
	else if(grown_seed.get_trait(TRAIT_TOXINS_TOLERANCE) > 6)
		dat += "<br>It is remarkably resistant to toxins."

	if(grown_seed.get_trait(TRAIT_PEST_TOLERANCE) < 3)
		dat += "<br>It is highly sensitive to pests."
	else if(grown_seed.get_trait(TRAIT_PEST_TOLERANCE) > 6)
		dat += "<br>It is remarkably resistant to pests."

	if(grown_seed.get_trait(TRAIT_WEED_TOLERANCE) < 3)
		dat += "<br>It is highly sensitive to weeds."
	else if(grown_seed.get_trait(TRAIT_WEED_TOLERANCE) > 6)
		dat += "<br>It is remarkably resistant to weeds."

	switch(grown_seed.get_trait(TRAIT_SPREAD))
		if(1)
			dat += "<br>It is able to be planted outside of a tray."
		if(2)
			dat += "<br>It is a robust and vigorous vine that will spread rapidly."

	switch(grown_seed.get_trait(TRAIT_CARNIVOROUS))
		if(1)
			dat += "<br>It is carniovorous and will eat tray pests for sustenance."
		if(2)
			dat	+= "<br>It is carnivorous and poses a significant threat to living things around it."

	if(grown_seed.get_trait(TRAIT_PARASITE))
		dat += "<br>It is capable of parisitizing and gaining sustenance from tray weeds."
	if(grown_seed.get_trait(TRAIT_ALTER_TEMP))
		dat += "<br>It will periodically alter the local temperature by [grown_seed.get_trait(TRAIT_ALTER_TEMP)] Kelvin."

	if(grown_seed.get_trait(TRAIT_BIOLUM))
		dat += "<br>It is [grown_seed.get_trait(TRAIT_BIOLUM_COLOUR)  ? "<font color='[grown_seed.get_trait(TRAIT_BIOLUM_COLOUR)]'>bio-luminescent</font>" : "bio-luminescent"]."

	if(grown_seed.get_trait(TRAIT_PRODUCES_POWER))
		dat += "<br>The fruit will function as a battery if prepared appropriately."

	if(grown_seed.get_trait(TRAIT_BATTERY_RECHARGE))
		dat += "<br>The fruit hums with an odd electrical energy."

	if(grown_seed.get_trait(TRAIT_STINGS))
		dat += "<br>The fruit is covered in stinging spines."

	if(grown_seed.get_trait(TRAIT_JUICY) == 1)
		dat += "<br>The fruit is soft-skinned and juicy."
	else if(grown_seed.get_trait(TRAIT_JUICY) == 2)
		dat += "<br>The fruit is excessively juicy."

	if(grown_seed.get_trait(TRAIT_EXPLOSIVE))
		dat += "<br>The fruit is internally unstable."

	if(grown_seed.get_trait(TRAIT_TELEPORTING))
		dat += "<br>The fruit is temporal/spatially unstable."

	if(dat)
		last_data = dat
		dat += "<br><br>\[<a href='?src=[UID()];print=1'>print report</a>\]"
		user << browse(dat,"window=plant_analyzer")

	return

/obj/item/weapon/minihoe // -- Numbers
	name = "mini hoe"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hoe"
	item_state = "hoe"
	flags = CONDUCT | NOBLUDGEON
	force = 5
	throwforce = 7
	w_class = 2
	materials = list(MAT_METAL=50)
	attack_verb = list("slashed", "sliced", "cut", "clawed")
	hitsound = 'sound/weapons/bladeslice.ogg'

//Hatchets and things to kill kudzu
/obj/item/weapon/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hatchet"
	flags = CONDUCT
	force = 12
	sharp = 1
	edge = 1
	w_class = 2
	throwforce = 15
	throw_speed = 4
	throw_range = 4
	materials = list(MAT_METAL=15000)
	origin_tech = "materials=2;combat=1"
	attack_verb = list("chopped", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/hatchet/unathiknife
	name = "duelling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "unathiknife"
	attack_verb = list("ripped", "torn", "cut")

/obj/item/weapon/scythe
	icon_state = "scythe0"
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	force = 13
	throwforce = 5
	sharp = 1
	edge = 1
	throw_speed = 2
	throw_range = 3
	w_class = 4
	var/extend = 1
	flags = CONDUCT
	armour_penetration = 20
	slot_flags = SLOT_BACK
	origin_tech = "materials=2;combat=2"
	attack_verb = list("chopped", "sliced", "cut", "reaped")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/scythe/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(A, /obj/effect/plant) && extend == 1)
		for(var/obj/effect/plant/B in orange(A,1))
			if(prob(80))
				B.die_off(1)
			qdel(A)

/obj/item/weapon/scythe/tele
	icon_state = "tscythe0"
	name = "telescopic scythe"
	desc = "A sharp and curved blade on a collapsable fibremetal handle, this tool is the pinnacle of covert reaping technology."
	force = 3.0
	sharp = 0
	edge = 0
	throw_speed = 2
	throw_range = 3
	w_class = 2
	extend = 0
	armour_penetration = 20
	slot_flags = SLOT_BELT
	origin_tech = "materials=3;combat=3"
	attack_verb = list("chopped", "sliced", "cut", "reaped")
	hitsound = "swing_hit"

/obj/item/weapon/scythe/tele/attack_self(mob/user as mob)
	extend = !extend
	if(extend)
		to_chat(user, "<span class ='warning'>With a flick of the wrist, you extend the scythe. It's reaping time!</span>")
		icon_state = "tscythe1"
		item_state = "scythe0"
		slot_flags &= ~SLOT_BELT
		w_class = 4 //doesnt fit in backpack when its on for balance
		force = 13 //normal scythe damage
		attack_verb = list("chopped", "sliced", "cut", "reaped")
		hitsound = 'sound/weapons/bladeslice.ogg'
		//Extend sound (blade unsheath)
		playsound(src.loc, 'sound/weapons/blade_unsheath.ogg', 50, 1)	//Sound credit to Qat of Freesound.org
	else
		to_chat(user, "<span class ='notice'>You collapse the scythe, folding it for easy storage.</span>")
		icon_state = "tscythe0"
		item_state = "tscythe0" //no sprite in other words
		slot_flags |= SLOT_BELT
		w_class = 2
		force = 3 //not so robust now
		attack_verb = list("hit", "poked")
		hitsound = "swing_hit"
		//Collapse sound (blade sheath)
		playsound(src.loc, 'sound/weapons/blade_sheath.ogg', 50, 1)		//Sound credit to Q.K. of Freesound.org
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	if(!blood_DNA) return
	if(blood_overlay && (blood_DNA.len >= 1)) //updates blood overlay, if any
		overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

		var/icon/I = new /icon(src.icon, src.icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
		blood_overlay = I

		overlays += blood_overlay

	return

/obj/item/weapon/rsp
	name = "\improper Rapid-Seed-Producer (RSP)"
	desc = "A device used to rapidly deploy seeds."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/mode = 1
	w_class = 3

/obj/item/weapon/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 1
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = 1
	throwforce = 0
	throw_speed = 4
	throw_range = 20
