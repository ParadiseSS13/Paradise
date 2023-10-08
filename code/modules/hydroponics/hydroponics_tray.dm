/obj/machinery/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "hydrotray"
	density = TRUE
	anchored = TRUE
	pixel_y = 8
	var/waterlevel = 100	//The amount of water in the tray (max 100)
	var/maxwater = 100		//The maximum amount of water in the tray
	var/nutrilevel = 10		//The amount of nutrient in the tray (max 10)
	var/maxnutri = 10		//The maximum nutrient of water in the tray
	var/pestlevel = 0		//The amount of pests in the tray (max 10)
	var/weedlevel = 0		//The amount of weeds in the tray (max 10)
	var/yieldmod = 1		//Nutriment's effect on yield
	var/mutmod = 1			//Nutriment's effect on mutations
	var/toxic = 0			//Toxicity in the tray?
	var/age = 0				//Current age
	var/dead = FALSE		//Is it dead?
	var/plant_health		//Its health
	var/lastproduce = 0		//Last time it was harvested
	var/lastcycle = 0		//Used for timing of cycles.
	var/cycledelay = 200	//About 10 seconds / cycle
	var/harvest = FALSE		//Ready to harvest?
	var/obj/item/seeds/myseed = null	//The currently planted seed
	var/rating = 1
	var/wrenchable = TRUE
	var/lid_closed = FALSE
	var/recent_bee_visit = FALSE //Have we been visited by a bee recently, so bees dont overpollinate one plant
	var/using_irrigation = FALSE //If the tray is connected to other trays via irrigation hoses
	var/self_sufficiency_req = 20 //Required total dose to make a self-sufficient hydro tray. 1:1 with earthsblood.
	var/self_sufficiency_progress = 0
	var/self_sustaining = FALSE //If the tray generates nutrients and water on its own
	hud_possible = list (PLANT_NUTRIENT_HUD, PLANT_WATER_HUD, PLANT_STATUS_HUD, PLANT_HEALTH_HUD, PLANT_TOXIN_HUD, PLANT_PEST_HUD, PLANT_WEED_HUD)

/obj/machinery/hydroponics/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/data/hydroponic/hydro_hud = GLOB.huds[DATA_HUD_HYDROPONIC]
	prepare_huds()
	hydro_hud.add_to_hud(src)
	plant_hud_set_nutrient()
	plant_hud_set_water()
	plant_hud_set_status()
	plant_hud_set_health()
	plant_hud_set_toxin()
	plant_hud_set_pest()
	plant_hud_set_weed()

/obj/machinery/hydroponics/constructable
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "hydrotray3"

/obj/machinery/hydroponics/constructable/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/hydroponics(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/hydroponics/constructable/RefreshParts()
	var/tmp_capacity = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		tmp_capacity += M.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating = M.rating
	maxwater = tmp_capacity * 50 // Up to 300
	maxnutri = tmp_capacity * 5 // Up to 30
	waterlevel = maxwater
	nutrilevel = 3
	plant_hud_set_nutrient()
	plant_hud_set_water()

/obj/machinery/hydroponics/Destroy()
	remove_from_all_data_huds()
	QDEL_NULL(myseed)
	return ..()

/obj/machinery/hydroponics/constructable/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "hydrotray3", "hydrotray3", I))
		return

	if(exchange_parts(user, I))
		return

	else
		return ..()

/obj/machinery/hydroponics/constructable/crowbar_act(mob/user, obj/item/I)

	if(using_irrigation)
		to_chat(user, "<span class='warning'>Disconnect the hoses first!</span>")
		return TRUE
	if(default_deconstruction_crowbar(user, I, 1))
		return TRUE

/obj/machinery/hydroponics/proc/FindConnected()
	var/list/connected = list()
	var/list/processing_atoms = list(src)

	while(processing_atoms.len)
		var/atom/a = processing_atoms[1]
		for(var/step_dir in GLOB.cardinal)
			var/obj/machinery/hydroponics/h = locate() in get_step(a, step_dir)
			// Soil plots aren't dense
			if(h && h.using_irrigation && h.density && !(h in connected) && !(h in processing_atoms))
				processing_atoms += h

		processing_atoms -= a
		connected += a

	return connected

/obj/machinery/hydroponics/AltClick()
	if(wrenchable && !HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) && Adjacent(usr))
		toggle_lid(usr)
		return
	return ..()

/obj/machinery/hydroponics/proc/toggle_lid(mob/living/user)
	if(!user || user.stat || user.restrained())
		return

	lid_closed = !lid_closed
	to_chat(user, "<span class='notice'>You [lid_closed ? "close" : "open"] the tray's lid.</span>")
	update_state()


/obj/machinery/hydroponics/bullet_act(obj/item/projectile/Proj) //Works with the Somatoray to modify plant variables.
	if(!myseed)
		return ..()
	if(istype(Proj ,/obj/item/projectile/energy/floramut))
		mutate()
	else if(istype(Proj ,/obj/item/projectile/energy/florayield))
		return myseed.bullet_act(Proj)
	else
		return ..()

/obj/machinery/hydroponics/process()
	var/needs_update = 0 // Checks if the icon needs updating so we don't redraw empty trays every time

	if(myseed && (myseed.loc != src))
		myseed.forceMove(src)

	if(self_sustaining)
		adjustNutri(1)
		adjustWater(rand(3,5))
		adjustWeeds(-2)
		adjustPests(-2)
		adjustToxic(-2)

	if(world.time > (lastcycle + cycledelay))
		lastcycle = world.time
		if(myseed && !dead)
			// Advance age
			age++
			if(age < myseed.maturation)
				lastproduce = age

			needs_update = 1

//Nutrients//////////////////////////////////////////////////////////////
			// Nutrients deplete slowly
			if(prob(50))
				adjustNutri(-1 / rating)

			// Lack of nutrients hurts non-weeds
			if(nutrilevel <= 0 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
				adjustHealth(-rand(1,3))

//Photosynthesis/////////////////////////////////////////////////////////
			// Lack of light hurts non-mushrooms
			if(isturf(loc))
				var/turf/currentTurf = loc
				var/lightAmt = currentTurf.get_lumcount() * 10
				if(myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
					if(lightAmt < 2)
						adjustHealth(-1 / rating)
				else // Non-mushroom
					if(lightAmt < 4)
						adjustHealth(-2 / rating)

//Water//////////////////////////////////////////////////////////////////
			// Drink random amount of water
			adjustWater(-rand(1,6) / rating)

			// If the plant is dry, it loses health pretty fast, unless mushroom
			if(waterlevel <= 10 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
				adjustHealth(-rand(0,1) / rating)
				if(waterlevel <= 0)
					adjustHealth(-rand(0,2) / rating)

			// Sufficient water level and nutrient level = plant healthy but also spawns weeds
			else if(waterlevel > 10 && nutrilevel > 0)
				adjustHealth(rand(1,2) / rating)
				if(myseed && prob(myseed.weed_chance))
					adjustWeeds(myseed.weed_rate)
				else if(prob(5))  //5 percent chance the weed population will increase
					adjustWeeds(1 / rating)

//Toxins/////////////////////////////////////////////////////////////////

			// Too much toxins cause harm, but when the plant drinks the contaiminated water, the toxins disappear slowly
			if(toxic >= 40 && toxic < 80)
				adjustHealth(-1 / rating)
				adjustToxic(-rand(1,10) / rating)
			else if(toxic >= 80) // I don't think it ever gets here tbh unless above is commented out
				adjustHealth(-3)
				adjustToxic(-rand(1,10) / rating)

//Pests & Weeds//////////////////////////////////////////////////////////

			else if(pestlevel >= 5)
				adjustHealth(-1 / rating)

			// If it's a weed, it doesn't stunt the growth
			if(weedlevel >= 5 && !myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
				adjustHealth(-1 / rating)

//Health & Age///////////////////////////////////////////////////////////

			// Plant dies if plant_health <= 0
			if(plant_health <= 0)
				plantdies()
				adjustWeeds(1 / rating) // Weeds flourish

			// If the plant is too old, lose health fast
			if(age > myseed.lifespan)
				adjustHealth(-rand(1,5) / rating)

			// Harvest code
			if(age > myseed.production && (age - lastproduce) > myseed.production && (!harvest && !dead))
				nutrimentMutation()
				if(myseed && myseed.yield != -1) // Unharvestable shouldn't be harvested
					harvest = TRUE
					plant_hud_set_status()
				else
					lastproduce = age
			if(prob(5))  // On each tick, there's a 5 percent chance the pest population will increase
				adjustPests(1 / rating)
		else
			if(waterlevel > 10 && nutrilevel > 0 && prob(10))  // If there's no plant, the percentage chance is 10%
				adjustWeeds(1 / rating)

		// Weeeeeeeeeeeeeeedddssss
		if(weedlevel >= 10 && prob(50)) // At this point the plant is kind of fucked. Weeds can overtake the plant spot.
			if(myseed)
				if(!myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy) && !myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism)) // If a normal plant
					weedinvasion()
			else
				weedinvasion() // Weed invasion into empty tray
			needs_update = 1
		if(needs_update)
			update_state()
	return

/obj/machinery/hydroponics/proc/nutrimentMutation()
	if(mutmod == 0)
		return
	if(mutmod == 1)
		if(prob(80))		//80%
			mutate()
		else if(prob(75))	//15%
			hardmutate()
		return
	if(mutmod == 2)
		if(prob(50))		//50%
			mutate()
		else if(prob(50))	//25%
			hardmutate()
		else if(prob(50))	//12.5%
			mutatespecie()
		return
	return

/obj/machinery/hydroponics/proc/update_state()
	//Refreshes the icon and sets the luminosity
	if(self_sustaining)
		if(istype(src, /obj/machinery/hydroponics/soil))
			color = rgb(255, 175, 0)
		set_light(3)
	else
		if(myseed && myseed.get_gene(/datum/plant_gene/trait/glow))
			var/datum/plant_gene/trait/glow/G = myseed.get_gene(/datum/plant_gene/trait/glow)
			set_light(G.glow_range(myseed), G.glow_power(myseed), G.glow_color)
		else
			set_light(0)

	update_icon()

/obj/machinery/hydroponics/update_overlays()
	. = ..()
	if(self_sustaining && !istype(src, /obj/machinery/hydroponics/soil))
		. += "gaia_blessing"

	if(lid_closed)
		. += "hydrocover"

	if(myseed)
		. += update_icon_plant()
		. += update_icon_lights()

/obj/machinery/hydroponics/update_icon_state()
	var/n = 0
	for(var/Dir in GLOB.cardinal)
		var/obj/machinery/hydroponics/t = locate() in get_step(src,Dir)
		if(t && t.using_irrigation && using_irrigation)
			n += Dir

	icon_state = "hoses-[n]"

/obj/machinery/hydroponics/proc/update_icon_plant()
	var/image/I
	if(dead)
		I = image(icon = myseed.growing_icon, icon_state = myseed.icon_dead)
	else if(harvest)
		if(!myseed.icon_harvest)
			I = image(icon = myseed.growing_icon, icon_state = "[myseed.icon_grow][myseed.growthstages]")
		else
			I = image(icon = myseed.growing_icon, icon_state = myseed.icon_harvest)
	else
		var/t_growthstate = clamp(round((age / myseed.maturation) * myseed.growthstages), 1, myseed.growthstages)
		I = image(icon = myseed.growing_icon, icon_state = "[myseed.icon_grow][t_growthstate]")
	I.layer = OBJ_LAYER + 0.01
	return I

/obj/machinery/hydroponics/proc/update_icon_lights()
	. = list()
	if(waterlevel <= 10)
		. += "over_lowwater3"
	if(nutrilevel <= 2)
		. += "over_lownutri3"
	if(plant_health <= (myseed.endurance / 2))
		. += "over_lowhealth3"
	if(weedlevel >= 5 || pestlevel >= 5 || toxic >= 40)
		. += "over_alert3"
	if(harvest)
		. += "over_harvest3"


/obj/machinery/hydroponics/examine(user)
	. = ..()
	if(myseed)
		if(myseed.variant)
			. += "<span class='info'>It has the <span class='name'>[myseed.variant]</span> variant of <span class='name'>[myseed.plantname]</span> planted.</span>"
		else
			. += "<span class='info'>It has <span class='name'>[myseed.plantname]</span> planted.</span>"
		if(dead)
			. += "<span class='warning'>It's dead!</span>"
		else if(harvest)
			. += "<span class='info'>It's ready to harvest.</span>"
		else if(plant_health <= (myseed.endurance / 2))
			. += "<span class='warning'>It looks unhealthy.</span>"
	else
		. += "<span class='info'>[src] is empty.</span>"

	if(!self_sustaining)
		. += "<span class='info'>Water: [waterlevel]/[maxwater]</span>"
		. += "<span class='info'>Nutrient: [nutrilevel]/[maxnutri]</span>"
		if(self_sufficiency_progress > 0)
			var/percent_progress = round(self_sufficiency_progress * 100 / self_sufficiency_req)
			. += "<span class='info'>Treatment for self-sustenance are [percent_progress]% complete.</span>"
	else
		. += "<span class='info'>It doesn't require any water or nutrients.</span>"

	if(weedlevel >= 5)
		. += "<span class='warning'>[src] is filled with weeds!</span>"
	if(pestlevel >= 5)
		. += "<span class='warning'>[src] is filled with tiny worms!</span>"
	. += "" // Empty line for readability.


/obj/machinery/hydroponics/proc/weedinvasion() // If a weed growth is sufficient, this happens.
	dead = FALSE
	var/oldPlantName
	if(myseed) // In case there's nothing in the tray beforehand
		oldPlantName = myseed.plantname
		QDEL_NULL(myseed)
	else
		oldPlantName = "[name]"
	switch(rand(1,18))		// randomly pick predominative weed
		if(16 to 18)
			myseed = new /obj/item/seeds/reishi(src)
		if(14 to 15)
			myseed = new /obj/item/seeds/nettle(src)
		if(12 to 13)
			myseed = new /obj/item/seeds/harebell(src)
		if(10 to 11)
			myseed = new /obj/item/seeds/amanita(src)
		if(8 to 9)
			myseed = new /obj/item/seeds/chanter(src)
		if(6 to 7)
			myseed = new /obj/item/seeds/tower(src)
		if(4 to 5)
			myseed = new /obj/item/seeds/plump(src)
		else
			myseed = new /obj/item/seeds/starthistle(src)
	age = 0
	plant_health = myseed.endurance
	lastcycle = world.time
	harvest = FALSE
	adjustWeeds(-10) // Reset
	adjustPests(-10) // Reset
	update_state()
	plant_hud_set_health()
	plant_hud_set_status()
	visible_message("<span class='warning'>The [oldPlantName] is overtaken by some [myseed.plantname]!</span>")


/obj/machinery/hydroponics/proc/mutate(lifemut = 2, endmut = 5, productmut = 1, yieldmut = 2, potmut = 25, wrmut = 2, wcmut = 5, traitmut = 0) // Mutates the current seed
	if(!myseed)
		return
	myseed.mutate(lifemut, endmut, productmut, yieldmut, potmut, wrmut, wcmut, traitmut)

/obj/machinery/hydroponics/proc/hardmutate()
	mutate(4, 10, 2, 4, 50, 4, 10, 3)


/obj/machinery/hydroponics/proc/mutatespecie() // Mutagent produced a new plant!
	if(!myseed || dead)
		return

	var/oldPlantName = myseed.plantname
	if(myseed.mutatelist.len > 0)
		var/mutantseed = pick(myseed.mutatelist)
		QDEL_NULL(myseed)
		myseed = new mutantseed
	else
		return

	hardmutate()
	age = 0
	plant_health = myseed.endurance
	lastcycle = world.time
	harvest = FALSE
	plant_hud_set_health()
	plant_hud_set_status()
	adjustWeeds(-10) // Reset

	sleep(5) // Wait a while
	update_state()
	visible_message("<span class='warning'>[oldPlantName] suddenly mutates into [myseed.plantname]!</span>")


/obj/machinery/hydroponics/proc/mutateweed() // If the weeds gets the mutagent instead. Mind you, this pretty much destroys the old plant
	if(weedlevel > 5)
		QDEL_NULL(myseed)
		var/newWeed = pick(/obj/item/seeds/liberty, /obj/item/seeds/angel, /obj/item/seeds/nettle/death, /obj/item/seeds/kudzu)
		myseed = new newWeed
		dead = FALSE
		hardmutate()
		age = 0
		plant_health = myseed.endurance
		lastcycle = world.time
		harvest = FALSE
		plant_hud_set_health()
		plant_hud_set_status()
		adjustWeeds(-10) // Reset

		sleep(5) // Wait a while
		update_state()
		visible_message("<span class='warning'>The mutated weeds in [src] spawn some [myseed.plantname]!</span>")
	else
		to_chat(usr, "<span class='warning'>The few weeds in [src] seem to react, but only for a moment...</span>")


/obj/machinery/hydroponics/proc/plantdies() // OH NOES!!!!! I put this all in one function to make things easier
	plant_health = 0
	harvest = FALSE
	adjustPests(-10) // Pests die
	if(!dead)
		update_state()
		dead = TRUE
	plant_hud_set_health()
	plant_hud_set_status()



/obj/machinery/hydroponics/proc/mutatepest(mob/user)
	if(pestlevel > 5)
		message_admins("[ADMIN_LOOKUPFLW(user)] caused spiderling pests to spawn in a hydro tray")
		log_game("[key_name(user)] caused spiderling pests to spawn in a hydro tray")
		visible_message("<span class='warning'>The pests seem to behave oddly...</span>")
		for(var/i in 1 to 3)
			var/obj/structure/spider/spiderling/S = new(get_turf(src))
			S.grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/hunter
	else
		to_chat(user, "<span class='warning'>The pests seem to behave oddly, but quickly settle down...</span>")

/obj/machinery/hydroponics/proc/applyChemicals(datum/reagents/S, mob/user)
	if(myseed)
		myseed.on_chem_reaction(S) //In case seeds have some special interactions with special chems, currently only used by vines

	// Requires 5 mutagen to possibly change species.// Poor man's mutagen.
	if(S.has_reagent("mutagen", 5) || S.has_reagent("radium", 10) || S.has_reagent("uranium", 10))
		switch(rand(100))
			if(91 to 100)
				adjustHealth(-10)
				to_chat(user, "<span class='warning'>The plant shrivels and burns.</span>")
			if(81 to 90)
				mutatespecie()
			if(66 to 80)
				hardmutate()
			if(41 to 65)
				mutate()
			if(21 to 41)
				to_chat(user, "<span class='notice'>The plants don't seem to react...</span>")
			if(11 to 20)
				mutateweed()
			if(1 to 10)
				mutatepest(user)
			else
				to_chat(user, "<span class='notice'>Nothing happens...</span>")

	// 2 or 1 units is enough to change the yield and other stats.// Can change the yield and other stats, but requires more than mutagen
	else if(S.has_reagent("mutagen", 2) || S.has_reagent("radium", 5) || S.has_reagent("uranium", 5))
		hardmutate()
	else if(S.has_reagent("mutagen", 1) || S.has_reagent("radium", 2) || S.has_reagent("uranium", 2))
		mutate()

	// After handling the mutating, we now handle the damage from adding crude radioactives...
	if(S.has_reagent("uranium", 1))
		adjustHealth(-round(S.get_reagent_amount("uranium") * 1))
		adjustToxic(round(S.get_reagent_amount("uranium") * 2))
	if(S.has_reagent("radium", 1))
		adjustHealth(-round(S.get_reagent_amount("radium") * 1))
		adjustToxic(round(S.get_reagent_amount("radium") * 3)) // Radium is harsher (OOC: also easier to produce)

	// Nutriments
	if(S.has_reagent("eznutriment", 1))
		yieldmod = 1
		mutmod = 1
		adjustNutri(round(S.get_reagent_amount("eznutriment") * 1))

	if(S.has_reagent("left4zednutriment", 1))
		yieldmod = 0
		mutmod = 2
		adjustNutri(round(S.get_reagent_amount("left4zednutriment") * 1))

	if(S.has_reagent("robustharvestnutriment", 1))
		yieldmod = 1.3
		mutmod = 0
		adjustNutri(round(S.get_reagent_amount("robustharvestnutriment") *1 ))


	//Fish Water is both an excellent fertilizer and waters
	if(S.has_reagent("fishwater", 1))
		adjustNutri(round(S.get_reagent_amount("fishwater") * 0.75))
		adjustWater(round(S.get_reagent_amount("fishwater") * 1))

	// Ambrosia Gaia produces earthsblood.
	if(S.has_reagent("earthsblood"))
		self_sufficiency_progress += S.get_reagent_amount("earthsblood")
		if(self_sufficiency_progress >= self_sufficiency_req)
			become_self_sufficient()
		else if(!self_sustaining)
			to_chat(user, "<span class='notice'>[src] warms as it might on a spring day under a genuine Sun.</span>")

	// Antitoxin binds shit pretty well. So the tox goes significantly down
	if(S.has_reagent("charcoal", 1))
		adjustToxic(-round(S.get_reagent_amount("charcoal") * 2))

	// BRO, YOU JUST WENT ON FULL STUPID.
	if(S.has_reagent("toxin", 1))
		adjustToxic(round(S.get_reagent_amount("toxin") * 2))

	// Milk is good for humans, but bad for plants. The sugars canot be used by plants, and the milk fat fucks up growth. Not shrooms though. I can't deal with this now...
	if(S.has_reagent("milk", 1))
		adjustNutri(round(S.get_reagent_amount("milk") * 0.1))
		adjustWater(round(S.get_reagent_amount("milk") * 0.9))

	// Beer is a chemical composition of alcohol and various other things. It's a shitty nutrient but hey, it's still one. Also alcohol is bad, mmmkay?
	if(S.has_reagent("beer", 1))
		adjustHealth(-round(S.get_reagent_amount("beer") * 0.05))
		adjustNutri(round(S.get_reagent_amount("beer") * 0.25))
		adjustWater(round(S.get_reagent_amount("beer") * 0.7))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(S.has_reagent("fluorine", 1))
		adjustHealth(-round(S.get_reagent_amount("fluorine") * 2))
		adjustToxic(round(S.get_reagent_amount("fluorine") * 2.5))
		adjustWater(-round(S.get_reagent_amount("fluorine") * 0.5))
		adjustWeeds(-rand(1,4))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(S.has_reagent("chlorine", 1))
		adjustHealth(-round(S.get_reagent_amount("chlorine") * 1))
		adjustToxic(round(S.get_reagent_amount("chlorine") * 1.5))
		adjustWater(-round(S.get_reagent_amount("chlorine") * 0.5))
		adjustWeeds(-rand(1,3))

	// White Phosphorous + water -> phosphoric acid. That's not a good thing really.
	// Phosphoric salts are beneficial though. And even if the plant suffers, in the long run the tray gets some nutrients. The benefit isn't worth that much.
	if(S.has_reagent("phosphorus", 1))
		adjustHealth(-round(S.get_reagent_amount("phosphorus") * 0.75))
		adjustNutri(round(S.get_reagent_amount("phosphorus") * 0.1))
		adjustWater(-round(S.get_reagent_amount("phosphorus") * 0.5))
		adjustWeeds(-rand(1,2))

	// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...
	if(S.has_reagent("sugar", 1))
		adjustWeeds(rand(1,2))
		adjustPests(rand(1,2))
		adjustNutri(round(S.get_reagent_amount("sugar") * 0.1))

	// It is water!
	if(S.has_reagent("water", 1))
		adjustWater(round(S.get_reagent_amount("water") * 1))

	// Holy water. Mostly the same as water, it also heals the plant a little with the power of the spirits~
	if(S.has_reagent("holywater", 1))
		adjustWater(round(S.get_reagent_amount("holywater") * 1))
		adjustHealth(round(S.get_reagent_amount("holywater") * 0.1))

	// A variety of nutrients are dissolved in club soda, without sugar.
	// These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
	if(S.has_reagent("sodawater", 1))
		adjustWater(round(S.get_reagent_amount("sodawater") * 1))
		adjustHealth(round(S.get_reagent_amount("sodawater") * 0.1))
		adjustNutri(round(S.get_reagent_amount("sodawater") * 0.1))

	// Man, you guys are daft
	if(S.has_reagent("sacid", 1))
		adjustHealth(-round(S.get_reagent_amount("sacid") * 1))
		adjustToxic(round(S.get_reagent_amount("sacid") * 1.5))
		adjustWeeds(-rand(1,2))

	// SERIOUSLY
	if(S.has_reagent("facid", 1))
		adjustHealth(-round(S.get_reagent_amount("facid") * 2))
		adjustToxic(round(S.get_reagent_amount("facid") * 3))
		adjustWeeds(-rand(1,4))

	// Glyphosate is just as bad
	if(S.has_reagent("glyphosate", 1))
		adjustHealth(-round(S.get_reagent_amount("glyphosate") * 5))
		adjustToxic(round(S.get_reagent_amount("glyphosate") * 6))
		adjustWeeds(-rand(4,8))

	// why, just why
	if(S.has_reagent("napalm", 1))
		if(!(myseed.resistance_flags & FIRE_PROOF))
			adjustHealth(-round(S.get_reagent_amount("napalm") * 6))
			adjustToxic(round(S.get_reagent_amount("napalm") * 7))
		adjustWeeds(-rand(5, 9)) //At least give them a small reward if they bother

	//Weed Spray
	if(S.has_reagent("atrazine", 1))
		adjustToxic(round(S.get_reagent_amount("atrazine") * 0.5))
		//old toxicity was 4, each spray is default 10 (minimal of 5) so 5 and 2.5 are the new ammounts
		adjustWeeds(-rand(1,2))

	//Pest Spray
	if(S.has_reagent("pestkiller", 1))
		adjustToxic(round(S.get_reagent_amount("pestkiller") * 0.5))
		adjustPests(-rand(1,2))

	// Healing
	if(S.has_reagent("cryoxadone", 1))
		adjustHealth(round(S.get_reagent_amount("cryoxadone") * 3))
		adjustToxic(-round(S.get_reagent_amount("cryoxadone") * 3))

	// Ammonia is bad ass.
	if(S.has_reagent("ammonia", 1))
		adjustHealth(round(S.get_reagent_amount("ammonia") * 0.5))
		adjustNutri(round(S.get_reagent_amount("ammonia") * 1))
		if(myseed)
			myseed.adjust_yield(round(S.get_reagent_amount("ammonia") * 0.01))

	// Saltpetre is used for gardening IRL, to simplify highly, it speeds up growth and strengthens plants
	if(S.has_reagent("saltpetre", 1))
		var/salt = S.get_reagent_amount("saltpetre")
		adjustHealth(round(salt * 0.25))
		if(myseed)
			myseed.adjust_production(-round(salt/100)-prob(salt%100))
			myseed.adjust_potency(round(salt*0.50))
	// Ash is also used IRL in gardening, as a fertilizer enhancer and weed killer
	if(S.has_reagent("ash", 1))
		adjustHealth(round(S.get_reagent_amount("ash") * 0.25))
		adjustNutri(round(S.get_reagent_amount("ash") * 0.5))
		adjustWeeds(-1)

	// This is more bad ass, and pests get hurt by the corrosive nature of it, not the plant.
	if(S.has_reagent("diethylamine", 1))
		adjustHealth(round(S.get_reagent_amount("diethylamine") * 1))
		adjustNutri(round(S.get_reagent_amount("diethylamine") * 2))
		if(myseed)
			myseed.adjust_yield(round(S.get_reagent_amount("diethylamine") * 0.02))
		adjustPests(-rand(1,2))

	// Compost, effectively
	if(S.has_reagent("nutriment", 1))
		adjustHealth(round(S.get_reagent_amount("nutriment") * 0.5))
		adjustNutri(round(S.get_reagent_amount("nutriment") * 1))

	if(S.has_reagent("plantmatter", 1))
		adjustHealth(round(S.get_reagent_amount("plantmatter") * 0.5))
		adjustNutri(round(S.get_reagent_amount("plantmatter") * 1))

	// Compost for EVERYTHING
	if(S.has_reagent("virusfood", 1))
		adjustNutri(round(S.get_reagent_amount("virusfood") * 0.5))
		adjustHealth(-round(S.get_reagent_amount("virusfood") * 0.5))

	// FEED ME
	if(S.has_reagent("blood", 1))
		adjustNutri(round(S.get_reagent_amount("blood") * 1))
		adjustPests(rand(2,4))

	// FEED ME SEYMOUR
	if(S.has_reagent("lazarus_reagent", 1))
		spawnplant()

	// The best stuff there is. For testing/debugging.
	if(S.has_reagent("adminordrazine", 1))
		adjustWater(round(S.get_reagent_amount("adminordrazine") * 1))
		adjustHealth(round(S.get_reagent_amount("adminordrazine") * 1))
		adjustNutri(round(S.get_reagent_amount("adminordrazine") * 1))
		adjustPests(-rand(1,5))
		adjustWeeds(-rand(1,5))
	if(S.has_reagent("adminordrazine", 5))
		switch(rand(100))
			if(66  to 100)
				mutatespecie()
			if(33	to 65)
				mutateweed()
			if(1   to 32)
				mutatepest(user)
			else
				to_chat(user, "<span class='warning'>Nothing happens...</span>")

/obj/machinery/hydroponics/attackby(obj/item/O, mob/user, params)
	//Called when mob user "attacks" it with object O
	if(istype(O, /obj/item/reagent_containers))  // Syringe stuff (and other reagent containers now too)
		var/obj/item/reagent_containers/reagent_source = O

		if(istype(reagent_source, /obj/item/reagent_containers/syringe))
			var/obj/item/reagent_containers/syringe/syr = reagent_source
			if(syr.mode != 1)
				to_chat(user, "<span class='warning'>You can't get any extract out of this plant.</span>")		//That. Gives me an idea...
				return

		if(!reagent_source.reagents.total_volume)
			to_chat(user, "<span class='notice'>[reagent_source] is empty.</span>")
			return 1

		if(reagent_source.has_lid && !reagent_source.is_drainable()) //if theres a LID then cannot transfer reagents.
			to_chat(user, "<span class='warning'>You need to open [O] first!</span>")
			return TRUE

		var/list/trays = list(src)//makes the list just this in cases of syringes and compost etc
		var/target = myseed ? myseed.plantname : src
		var/visi_msg = ""
		var/irrigate = 0	//How am I supposed to irrigate pill contents?
		var/transfer_amount

		if(istype(reagent_source, /obj/item/reagent_containers/food/snacks) || ispill(reagent_source))
			visi_msg="[user] composts [reagent_source], spreading it through [target]"
			transfer_amount = reagent_source.reagents.total_volume
		else
			transfer_amount = reagent_source.amount_per_transfer_from_this
			if(istype(reagent_source, /obj/item/reagent_containers/syringe/))
				var/obj/item/reagent_containers/syringe/syr = reagent_source
				visi_msg="[user] injects [target] with [syr]"
				if(syr.reagents.total_volume <= syr.amount_per_transfer_from_this)
					syr.mode = 0
			else if(istype(reagent_source, /obj/item/reagent_containers/spray/))
				visi_msg="[user] sprays [target] with [reagent_source]"
				playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
				irrigate = 1
			else if(transfer_amount) // Droppers, cans, beakers, what have you.
				visi_msg="[user] uses [reagent_source] on [target]"
				irrigate = 1
			// Beakers, bottles, buckets, etc.
			if(reagent_source.is_drainable())
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

		if(irrigate && transfer_amount > 30 && reagent_source.reagents.total_volume >= 30 && using_irrigation)
			trays = FindConnected()
			if(trays.len > 1)
				visi_msg += ", setting off the irrigation system"

		if(visi_msg)
			visible_message("<span class='notice'>[visi_msg].</span>")

		var/split = round(transfer_amount/trays.len)

		for(var/obj/machinery/hydroponics/H in trays)
		//cause I don't want to feel like im juggling 15 tamagotchis and I can get to my real work of ripping flooring apart in hopes of validating my life choices of becoming a space-gardener

			var/datum/reagents/S = new /datum/reagents() //This is a strange way, but I don't know of a better one so I can't fix it at the moment...
			S.my_atom = H

			reagent_source.reagents.trans_to(S,split)
			if(istype(reagent_source, /obj/item/reagent_containers/food/snacks) || ispill(reagent_source))
				qdel(reagent_source)

			H.applyChemicals(S, user)

			S.clear_reagents()
			qdel(S)
			H.update_state()
		if(reagent_source) // If the source wasn't composted and destroyed
			reagent_source.update_icon()
		return 1

	else if(istype(O, /obj/item/seeds) && !istype(O, /obj/item/seeds/sample))
		if(!myseed)
			if(istype(O, /obj/item/seeds/kudzu))
				investigate_log("had Kudzu planted in it by [key_name(user)] at ([x],[y],[z])","kudzu")
			user.unEquip(O)
			to_chat(user, "<span class='notice'>You plant [O].</span>")
			dead = FALSE
			myseed = O
			age = 1
			plant_health = myseed.endurance
			plant_hud_set_health()
			plant_hud_set_status()
			lastcycle = world.time
			O.forceMove(src)
			update_state()
		else
			to_chat(user, "<span class='warning'>[src] already has seeds in it!</span>")

	else if(istype(O, /obj/item/plant_analyzer))
		if(myseed)
			to_chat(user, "*** <B>[myseed.plantname]</B> ***") //Carn: now reports the plants growing, not the seeds.
			to_chat(user, "- Plant Age: <span class='notice'>[age]</span>")
			var/list/text_string = myseed.get_analyzer_text()
			if(text_string)
				to_chat(user, text_string)
		else
			to_chat(user, "<B>No plant found.</B>")
		to_chat(user, "- Weed level: <span class='notice'>[weedlevel] / 10</span>")
		to_chat(user, "- Pest level: <span class='notice'>[pestlevel] / 10</span>")
		to_chat(user, "- Toxicity level: <span class='notice'>[toxic] / 100</span>")
		to_chat(user, "- Water level: <span class='notice'>[waterlevel] / [maxwater]</span>")
		to_chat(user, "- Nutrition level: <span class='notice'>[nutrilevel] / [maxnutri]</span>")
		to_chat(user, "")

	else if(istype(O, /obj/item/cultivator))
		if(weedlevel > 0)
			user.visible_message("[user] uproots the weeds.", "<span class='notice'>You remove the weeds from [src].</span>")
			adjustWeeds(-10)
			update_state()
		else
			to_chat(user, "<span class='warning'>This plot is completely devoid of weeds! It doesn't need uprooting.</span>")

	else if(istype(O, /obj/item/storage/bag/plants))
		attack_hand(user)
		var/obj/item/storage/bag/plants/S = O
		for(var/obj/item/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
			if(!S.can_be_inserted(G))
				return
			S.handle_item_insertion(G, 1)

	else if(istype(O, /obj/item/shovel/spade))
		if(!myseed && !weedlevel)
			to_chat(user, "<span class='warning'>[src] doesn't have any plants or weeds!</span>")
			return
		user.visible_message("<span class='notice'>[user] starts digging out [src]'s plants...</span>", "<span class='notice'>You start digging out [src]'s plants...</span>")
		playsound(src, O.usesound, 50, 1)
		if(!do_after(user, 25 * O.toolspeed, target = src) || (!myseed && !weedlevel))
			return
		user.visible_message("<span class='notice'>[user] digs out the plants in [src]!</span>", "<span class='notice'>You dig out all of [src]'s plants!</span>")
		playsound(src, O.usesound, 50, 1)
		if(myseed) //Could be that they're just using it as a de-weeder
			age = 0
			plant_health = 0
			if(harvest)
				harvest = FALSE //To make sure they can't just put in another seed and insta-harvest it
			qdel(myseed)
			myseed = null
			plant_hud_set_health()
			plant_hud_set_status()
		adjustWeeds(-10) //Has a side effect of cleaning up those nasty weeds
		update_state()
	else if(is_pen(O) && myseed)
		myseed.variant_prompt(user, src)
	else
		return ..()

/obj/machinery/hydroponics/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	else if(wrenchable)
		using_irrigation = !using_irrigation
		user.visible_message("<span class='notice'>[user] [using_irrigation ? "" : "dis"]connects [src]'s irrigation hoses.</span>", \
		"<span class='notice'>You [using_irrigation ? "" : "dis"]connect [src]'s irrigation hoses.</span>")
		for(var/obj/machinery/hydroponics/h in range(1,src))
			h.update_state()

/obj/machinery/hydroponics/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(wrenchable)
		if(using_irrigation)
			to_chat(user, "<span class='warning'>Disconnect the hoses first!</span>")
			return

		if(!anchored && !isinspace())
			user.visible_message("[user] begins to wrench [src] into place.", "<span class='notice'>You begin to wrench [src] in place...</span>")
			if(I.use_tool(src, user, 20, volume = I.tool_volume))
				if(anchored)
					return
				anchored = TRUE
				user.visible_message("[user] wrenches [src] into place.", \
									"<span class='notice'>You wrench [src] in place.</span>")
		else if(anchored)
			user.visible_message("[user] begins to unwrench [src].", \
								"<span class='notice'>You begin to unwrench [src]...</span>")
			if(I.use_tool(src, user, 20, volume = I.tool_volume))
				if(!anchored)
					return
				anchored = FALSE
				user.visible_message("[user] unwrenches [src].", \
									"<span class='notice'>You unwrench [src].</span>")

/obj/machinery/hydroponics/attack_hand(mob/user)
	if(issilicon(user)) //How does AI know what plant is?
		return
	if(lid_closed)
		to_chat(user, "<span class='warning'>You can't reach the plant through the cover.</span>")
		return
	if(harvest)
		myseed.harvest(user)
	else if(dead)
		dead = FALSE
		to_chat(user, "<span class='notice'>You remove the dead plant from [src].</span>")
		QDEL_NULL(myseed)
		update_state()
		plant_hud_set_status()
		plant_hud_set_health()
	else
		examine(user)

/obj/machinery/hydroponics/proc/update_tray(mob/user = usr)
	harvest = FALSE
	lastproduce = age
	if(istype(myseed,/obj/item/seeds/replicapod))
		to_chat(user, "<span class='notice'>You harvest from the [myseed.plantname].</span>")
	else if(myseed.getYield() <= 0)
		to_chat(user, "<span class='warning'>You fail to harvest anything useful!</span>")
	else
		to_chat(user, "<span class='notice'>You harvest [myseed.getYield()] items from the [myseed.plantname].</span>")
	if(!myseed.get_gene(/datum/plant_gene/trait/repeated_harvest))
		QDEL_NULL(myseed)
		dead = FALSE
	plant_hud_set_status()
	plant_hud_set_health()
	update_state()

/// Tray Setters - The following procs adjust the tray or plants variables, and make sure that the stat doesn't go out of bounds.///
/obj/machinery/hydroponics/proc/adjustNutri(adjustamt)
	nutrilevel = clamp(nutrilevel + adjustamt, 0, maxnutri)
	plant_hud_set_nutrient()

/obj/machinery/hydroponics/proc/adjustWater(adjustamt)
	waterlevel = clamp(waterlevel + adjustamt, 0, maxwater)
	plant_hud_set_water()
	if(adjustamt>0)
		adjustToxic(-round(adjustamt/4))//Toxicity dilutation code. The more water you put in, the lesser the toxin concentration.

/obj/machinery/hydroponics/proc/adjustHealth(adjustamt)
	if(myseed && !dead)
		plant_health = clamp(plant_health + adjustamt, 0, myseed.endurance)
		plant_hud_set_health()

/obj/machinery/hydroponics/proc/adjustToxic(adjustamt)
	toxic = clamp(toxic + adjustamt, 0, 100)
	plant_hud_set_toxin()

/obj/machinery/hydroponics/proc/adjustPests(adjustamt)
	pestlevel = clamp(pestlevel + adjustamt, 0, 10)
	plant_hud_set_pest()

/obj/machinery/hydroponics/proc/adjustWeeds(adjustamt)
	weedlevel = clamp(weedlevel + adjustamt, 0, 10)
	plant_hud_set_weed()

/obj/machinery/hydroponics/proc/spawnplant() // why would you put Lazarus Reagent in a hydro tray you monster I bet you also feed them blood
	var/list/livingplants = list(/mob/living/simple_animal/hostile/tree, /mob/living/simple_animal/hostile/killertomato)
	var/chosen = pick(livingplants)
	var/mob/living/simple_animal/hostile/C = new chosen(get_turf(src))
	C.faction = list("plants")

/obj/machinery/hydroponics/proc/become_self_sufficient() // Ambrosia Gaia effect
	visible_message("<span class='boldnotice'>[src] begins to glow with a beautiful light!</span>")
	self_sustaining = TRUE
	update_state()

///Diona Nymph Related Procs///
/obj/machinery/hydroponics/CanPass(atom/movable/mover, turf/target, height=0) //So nymphs can climb over top of trays.
	if(height==0)
		return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return ..()

/obj/machinery/hydroponics/attack_animal(mob/living/user)
	if(isnymph(user))
		if(weedlevel > 0)
			user.adjust_nutrition(weedlevel * 15)
			adjustWeeds(-10)
			update_state()
			visible_message("<span class='danger'>[user] begins rooting through [src], ripping out weeds and eating them noisily.</span>","<span class='danger'>You begin rooting through [src], ripping out weeds and eating them noisily.</span>")
		else if(nutrilevel < 10)
			user.adjust_nutrition(-((10 - nutrilevel) * 5))
			adjustNutri(10)
			update_state()
			visible_message("<span class='danger'>[user] secretes a trickle of green liquid from its tail, refilling [src]'s nutrient tray.</span>","<span class='danger'>You secrete a trickle of green liquid from your tail, refilling [src]'s nutrient tray.</span>")
	else
		return ..()

///////////////////////////////////////////////////////////////////////////////
/obj/machinery/hydroponics/soil //Not actually hydroponics at all! Honk!
	name = "soil"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "soil"
	density = FALSE
	power_state = NO_POWER_USE
	wrenchable = FALSE

/obj/machinery/hydroponics/soil/update_icon_state()
	return // Has no hoses

/obj/machinery/hydroponics/soil/update_icon_lights()
	return // Has no lights

/obj/machinery/hydroponics/soil/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/shovel) && !istype(O, /obj/item/shovel/spade)) //Doesn't include spades because of uprooting plants
		to_chat(user, "<span class='notice'>You clear up [src]!</span>")
		qdel(src)
	else
		return ..()
