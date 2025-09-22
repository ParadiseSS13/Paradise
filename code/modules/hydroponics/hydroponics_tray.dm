/obj/machinery/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "hydrotray"
	density = TRUE
	anchored = TRUE
	pixel_y = 8
	rad_insulation_beta = RAD_MOB_INSULATION
	rad_insulation_gamma = RAD_MOB_INSULATION
	/// The amount of water in the tray (max 100)
	var/waterlevel = 100
	/// The maximum amount of water in the tray
	var/maxwater = 100
	/// The amount of nutrient in the tray (max 10)
	var/nutrilevel = 10
	/// The maximum nutrient of water in the tray
	var/maxnutri = 10
	/// The amount of pests in the tray (max 10)
	var/pestlevel = 0
	/// The amount of weeds in the tray (max 10)
	var/weedlevel = 0
	/// Nutrient in use
	var/datum/reagent/plantnutrient/nutrient = /datum/reagent/plantnutrient/eznutrient
	/// Nutrient's effect on yield
	var/yieldmod = 1
	/// The amount of mutagens (UM or radioactives) in the tray.
	var/mutagen = 0
	/// The maximum amount of mutagen in the tray.
	var/max_mutagen = 15
	/// Has the tray been hit by a mutation beam this harvest?
	var/mut_beamed = FALSE
	/// Has the tray been hit by a yield-increasing beam this harvest?
	var/yield_beamed = FALSE
	/// The typepath of the chemical (if any) the tray has been doped with to bias its mutations.
	var/datum/reagent/doping_chem = null
	/// Toxicity in the tray
	var/toxic = 0
	/// Current age
	var/age = 0
	/// Is it dead?
	var/dead = FALSE
	/// Its health
	var/plant_health
	/// Last time it was harvested
	var/lastproduce = 0
	/// Used for timing of cycles.
	var/lastcycle = 0
	/// Amount of time per plant cycle
	var/cycledelay = 20 SECONDS
	/// Ready to harvest?
	var/harvest = FALSE
	/// The currently planted seed
	var/obj/item/seeds/myseed = null
	var/rating = 1
	var/wrenchable = TRUE
	var/lid_closed = FALSE
	/// Have we been visited by a bee recently, so bees dont overpollinate one plant
	var/recent_bee_visit = FALSE
	/// If the tray is connected to other trays via irrigation hoses
	var/using_irrigation = FALSE
	/// Required total dose to make a self-sufficient hydro tray. 1:1 with earthsblood.
	var/self_sufficiency_req = 20
	var/self_sufficiency_progress = 0
	/// If the tray generates nutrients and water on its own
	var/self_sustaining = FALSE
	hud_possible = list (PLANT_NUTRIENT_HUD, PLANT_WATER_HUD, PLANT_STATUS_HUD, PLANT_HEALTH_HUD, PLANT_TOXIN_HUD, PLANT_PEST_HUD, PLANT_WEED_HUD)

	/// Maps doping chemicals to their affected stats.
	var/static/doping_effects = list(
		/datum/reagent/saltpetre = list("potency"),
		/datum/reagent/ammonia = list("yield"),
		/datum/reagent/diethylamine = list("production speed"),
		/datum/reagent/medicine/cryoxadone = list("endurance"),
		/datum/reagent/medicine/omnizine = list("lifespan"),
		/datum/reagent/medicine/salglu_solution = list("weed rate", "weed count"))
	/// What do we call the mutagen tank?
	var/mutagen_tank_name = "Mutagen tank"

	var/is_soil = FALSE

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
	create_reagents(300) // This should get cleared every time it is filled, barring admemery

/obj/machinery/hydroponics/constructable
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

/obj/machinery/hydroponics/constructable/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(default_deconstruction_screwdriver(user, "hydrotray3", "hydrotray3", used))
		return ITEM_INTERACT_COMPLETE

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

	while(length(processing_atoms))
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
		mut_beamed = TRUE
		return ..()
	else if(istype(Proj ,/obj/item/projectile/energy/florayield))
		yield_beamed = TRUE
		return ..()
	else
		return ..()

/obj/machinery/hydroponics/process()
	var/needs_update = 0 // Checks if the icon needs updating so we don't redraw empty trays every time

	if(myseed && (myseed.loc != src))
		myseed.forceMove(src)

	if(self_sustaining)
		// Always use Earthsblood (which is really just EZ with a fake moustache) for self-sustaining trays.
		// Want more mutations or increased yield? Take care of your trays.
		yieldmod = 1
		nutrient = /datum/reagent/plantnutrient/eznutrient

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
			if(age <= myseed.maturation)
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

//Weed overtaking////////////////////////////////////////////////////////
			if(weedlevel >= 10 && prob(50)) // At this point the plant is kind of fucked. Weeds can overtake the plant spot.
				if(!myseed.get_gene(/datum/plant_gene/trait/plant_type/weed_hardy) && !myseed.get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism)) // If a normal plant
					weedinvasion()
				needs_update = 1

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
			if(age > myseed.production && (age - lastproduce) >= myseed.production && (!harvest && !dead))
				if(myseed && myseed.yield != -1) // Unharvestable shouldn't be harvested
					harvest = TRUE
					plant_hud_set_status()
				else
					lastproduce = age
			if(prob(5))  // On each tick, there's a 5 percent chance the pest population will increase
				adjustPests(1 / rating)
		else
			if(weedlevel >= 10 && prob(50))
				weedinvasion() // Weed invasion into empty tray
				needs_update = 1
			if(waterlevel > 10 && nutrilevel > 0 && prob(10))  // If there's no plant, the percentage chance is 10%
				adjustWeeds(1 / rating)
		if(needs_update)
			update_state()
	return

/obj/machinery/hydroponics/proc/update_state()
	//Refreshes the icon and sets the luminosity
	if(self_sustaining)
		if(is_soil)
			color = rgb(255, 175, 0)
		set_light(3)
	else
		if(myseed && myseed.get_gene(/datum/plant_gene/trait/glow))
			var/datum/plant_gene/trait/glow/G = myseed.get_gene(/datum/plant_gene/trait/glow)
			set_light(G.glow_range(myseed), G.glow_power(myseed), G.glow_color)
		else
			set_light(0)

	update_icon()

/obj/machinery/hydroponics/extinguish_light(force)
	if(!force)
		return
	set_light(0)

/obj/machinery/hydroponics/update_overlays()
	. = ..()
	if(self_sustaining && !is_soil)
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
			. += "<span class='notice'>It has the <span class='name'>[myseed.variant]</span> variant of <span class='name'>[myseed.plantname]</span> planted.</span>"
		else
			. += "<span class='notice'>It has <span class='name'>[myseed.plantname]</span> planted.</span>"
		if(dead)
			. += "<span class='warning'>It's dead!</span>"
		else if(harvest)
			. += "<span class='notice'>It's ready to harvest.</span>"
		else if(plant_health <= (myseed.endurance / 2))
			. += "<span class='warning'>It looks unhealthy.</span>"
	else
		. += "<span class='notice'>[src] is empty.</span>"

	if(!self_sustaining)
		. += "<span class='notice'>Water: [waterlevel]/[maxwater]</span>"
		. += "<span class='notice'>Nutrient: [nutrilevel]/[maxnutri]</span>"
		if(self_sufficiency_progress > 0)
			var/percent_progress = round(self_sufficiency_progress * 100 / self_sufficiency_req)
			. += "<span class='notice'>Treatment for self-sustenance are [percent_progress]% complete.</span>"
	else
		. += "<span class='notice'>It doesn't require any water or nutrients.</span>"

	if(weedlevel >= 5)
		. += "<span class='warning'>[src] is filled with weeds!</span>"
	if(pestlevel >= 5)
		. += "<span class='warning'>[src] is filled with tiny worms!</span>"
	. += "" // Empty line for readability.


/obj/machinery/hydroponics/proc/weedinvasion() // If a weed growth is sufficient, this happens.
	dead = FALSE
	var/oldPlantName
	var/kudzu = FALSE
	if(myseed) // In case there's nothing in the tray beforehand
		if(istype(myseed, /obj/item/seeds/soya))
			kudzu = TRUE
		oldPlantName = myseed.plantname
		QDEL_NULL(myseed)
	else
		oldPlantName = "[name]"
	if(kudzu)
		myseed = new /obj/item/seeds/kudzu(src)
	else
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
	mut_beamed = FALSE
	yield_beamed = FALSE
	plant_hud_set_health()
	plant_hud_set_status()
	if(kudzu)
		visible_message("<span class='warning'>The [oldPlantName] cross-breeds with weeds and mutates into [myseed.plantname]!</span>")
	else
		visible_message("<span class='warning'>The [oldPlantName] is overtaken by some [myseed.plantname]!</span>")

/obj/machinery/hydroponics/proc/get_mutation_level()
	return nutrient.mutation_level + mutagen + (mut_beamed ? 5 : 0)

/obj/machinery/hydroponics/proc/get_mutation_focus()
	return doping_effects[doping_chem]

/obj/machinery/hydroponics/proc/mutateweed() // If the weeds gets the mutagent instead. Mind you, this pretty much destroys the old plant
	if(weedlevel > 5)
		QDEL_NULL(myseed)
		var/newWeed = pick(/obj/item/seeds/liberty, /obj/item/seeds/angel, /obj/item/seeds/nettle/death, /obj/item/seeds/kudzu)
		myseed = new newWeed
		dead = FALSE
		myseed.mutate(20)
		age = 0
		plant_health = myseed.endurance
		lastcycle = world.time
		harvest = FALSE
		mut_beamed = FALSE
		yield_beamed = FALSE
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
	mut_beamed = FALSE
	yield_beamed = FALSE
	plant_hud_set_health()
	plant_hud_set_status()

/obj/machinery/hydroponics/proc/mutatepest(mob/user)
	if(pestlevel > 5)
		message_admins("[ADMIN_LOOKUPFLW(user)] caused spiderling pests to spawn in a hydro tray")
		log_game("[key_name(user)] caused spiderling pests to spawn in a hydro tray")
		visible_message("<span class='warning'>The pests seem to behave oddly...</span>")
		for(var/i in 1 to 3)
			var/obj/structure/spider/spiderling/S = new(get_turf(src))
			S.grow_as = /mob/living/basic/giant_spider/hunter
	else
		to_chat(user, "<span class='warning'>The pests seem to behave oddly, but quickly settle down...</span>")

/obj/machinery/hydroponics/proc/apply_chemicals(mob/user)
	if(myseed)
		myseed.on_chem_reaction(reagents) //In case seeds have some special interactions with special chems, currently only used by vines

	// Radioactives and mutagen contribute to the mutation level of the tray.
	if(reagents.has_reagent("mutagen") || reagents.has_reagent("radium") || reagents.has_reagent("uranium"))
		if(mutagen < max_mutagen)
			mutagen += reagents.get_reagent_amount("uranium")
			mutagen += reagents.get_reagent_amount("radium")
			mutagen += reagents.get_reagent_amount("mutagen")
			to_chat(user, "<span class='notice'>You think the plants in [src] will mutate more now.</span>")
		mutagen = min(max_mutagen, mutagen)
		if(mutagen == max_mutagen)
			to_chat(user, "<span class='notice'>That seems like enough mutating chemicals.</span>")

	// After handling the mutating, we now handle the damage from adding crude radioactives...
	if(reagents.has_reagent("uranium", 1))
		adjustHealth(-round(reagents.get_reagent_amount("uranium") * 1))
		adjustToxic(round(reagents.get_reagent_amount("uranium") * 2))
	if(reagents.has_reagent("radium", 1))
		adjustHealth(-round(reagents.get_reagent_amount("radium") * 1))
		adjustToxic(round(reagents.get_reagent_amount("radium") * 3)) // Radium is harsher (OOC: also easier to produce)

	// Nutrients
	if(reagents.has_reagent("eznutrient", 1))
		nutrient = /datum/reagent/plantnutrient/eznutrient
		yieldmod = 1
		adjustNutri(round(reagents.get_reagent_amount("eznutrient") * 1))

	if(reagents.has_reagent("mutrient", 1))
		nutrient = /datum/reagent/plantnutrient/mut
		yieldmod = 1
		adjustNutri(round(reagents.get_reagent_amount("mutrient") * 1))

	if(reagents.has_reagent("left4zednutrient", 1))
		nutrient = /datum/reagent/plantnutrient/left4zednutrient
		yieldmod = 0
		adjustNutri(round(reagents.get_reagent_amount("left4zednutrient") * 1))

	if(reagents.has_reagent("robustharvestnutrient", 1))
		nutrient = /datum/reagent/plantnutrient/robustharvestnutrient
		yieldmod = 1.3
		adjustNutri(round(reagents.get_reagent_amount("robustharvestnutrient") *1 ))


	//Fish Water is both an excellent fertilizer and waters
	if(reagents.has_reagent("fishwater", 1))
		adjustNutri(round(reagents.get_reagent_amount("fishwater") * 0.75))
		adjustWater(round(reagents.get_reagent_amount("fishwater") * 1))

	// Ambrosia Gaia produces earthsblood.
	if(reagents.has_reagent("earthsblood"))
		self_sufficiency_progress += reagents.get_reagent_amount("earthsblood")
		if(self_sufficiency_progress >= self_sufficiency_req)
			become_self_sufficient()
		else if(!self_sustaining)
			to_chat(user, "<span class='notice'>[src] warms as it might on a spring day under a genuine Sun.</span>")

	// Antitoxin binds shit pretty well. So the tox goes significantly down
	if(reagents.has_reagent("charcoal", 1))
		adjustToxic(-round(reagents.get_reagent_amount("charcoal") * 2))
		if(doping_chem)
			to_chat(user, "<span class='notice'>The charcoal soaks up and neutralizes \the [initial(doping_chem.name)].</span>")
			doping_chem = null

	// BRO, YOU JUST WENT ON FULL STUPID.
	if(reagents.has_reagent("toxin", 1))
		adjustToxic(round(reagents.get_reagent_amount("toxin") * 2))

	// Milk is good for humans, but bad for plants. The sugars canot be used by plants, and the milk fat fucks up growth. Not shrooms though. I can't deal with this now...
	if(reagents.has_reagent("milk", 1))
		adjustNutri(round(reagents.get_reagent_amount("milk") * 0.1))
		adjustWater(round(reagents.get_reagent_amount("milk") * 0.9))

	// Beer is a chemical composition of alcohol and various other things. It's a shitty nutrient but hey, it's still one. Also alcohol is bad, mmmkay?
	if(reagents.has_reagent("beer", 1))
		adjustHealth(-round(reagents.get_reagent_amount("beer") * 0.05))
		adjustNutri(round(reagents.get_reagent_amount("beer") * 0.25))
		adjustWater(round(reagents.get_reagent_amount("beer") * 0.7))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(reagents.has_reagent("fluorine", 1))
		adjustHealth(-round(reagents.get_reagent_amount("fluorine") * 2))
		adjustToxic(round(reagents.get_reagent_amount("fluorine") * 2.5))
		adjustWater(-round(reagents.get_reagent_amount("fluorine") * 0.5))
		adjustWeeds(-rand(1,4))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(reagents.has_reagent("chlorine", 1))
		adjustHealth(-round(reagents.get_reagent_amount("chlorine") * 1))
		adjustToxic(round(reagents.get_reagent_amount("chlorine") * 1.5))
		adjustWater(-round(reagents.get_reagent_amount("chlorine") * 0.5))
		adjustWeeds(-rand(1,3))

	// White Phosphorous + water -> phosphoric acid. That's not a good thing really.
	// Phosphoric salts are beneficial though. And even if the plant suffers, in the long run the tray gets some nutrients. The benefit isn't worth that much.
	if(reagents.has_reagent("phosphorus", 1))
		adjustHealth(-round(reagents.get_reagent_amount("phosphorus") * 0.75))
		adjustNutri(round(reagents.get_reagent_amount("phosphorus") * 0.1))
		adjustWater(-round(reagents.get_reagent_amount("phosphorus") * 0.5))
		adjustWeeds(-rand(1,2))

	// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...
	if(reagents.has_reagent("sugar", 1))
		adjustWeeds(rand(1,2))
		adjustPests(rand(1,2))
		adjustNutri(round(reagents.get_reagent_amount("sugar") * 0.1))

	// It is water!
	if(reagents.has_reagent("water", 1))
		adjustWater(round(reagents.get_reagent_amount("water") * 1))

	// Holy water. Mostly the same as water, it also heals the plant a little with the power of the spirits~
	if(reagents.has_reagent("holywater", 1))
		adjustWater(round(reagents.get_reagent_amount("holywater") * 1))
		adjustHealth(round(reagents.get_reagent_amount("holywater") * 0.1))

	// A variety of nutrients are dissolved in club soda, without sugar.
	// These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
	if(reagents.has_reagent("sodawater", 1))
		adjustWater(round(reagents.get_reagent_amount("sodawater") * 1))
		adjustHealth(round(reagents.get_reagent_amount("sodawater") * 0.1))
		adjustNutri(round(reagents.get_reagent_amount("sodawater") * 0.1))

	// Man, you guys are daft
	if(reagents.has_reagent("sacid", 1))
		adjustHealth(-round(reagents.get_reagent_amount("sacid") * 1))
		adjustToxic(round(reagents.get_reagent_amount("sacid") * 1.5))
		adjustWeeds(-rand(1,2))

	// SERIOUSLY
	if(reagents.has_reagent("facid", 1))
		adjustHealth(-round(reagents.get_reagent_amount("facid") * 2))
		adjustToxic(round(reagents.get_reagent_amount("facid") * 3))
		adjustWeeds(-rand(1,4))

	// Glyphosate is just as bad
	if(reagents.has_reagent("glyphosate", 1))
		adjustHealth(-round(reagents.get_reagent_amount("glyphosate") * 5))
		adjustToxic(round(reagents.get_reagent_amount("glyphosate") * 6))
		adjustWeeds(-rand(4,8))

	// why, just why
	if(reagents.has_reagent("napalm", 1))
		if(!(myseed.resistance_flags & FIRE_PROOF))
			adjustHealth(-round(reagents.get_reagent_amount("napalm") * 6))
			adjustToxic(round(reagents.get_reagent_amount("napalm") * 7))
		adjustWeeds(-rand(5, 9)) //At least give them a small reward if they bother

	//Weed Spray
	if(reagents.has_reagent("atrazine", 1))
		adjustToxic(round(reagents.get_reagent_amount("atrazine") * 0.5))
		//old toxicity was 4, each spray is default 10 (minimal of 5) so 5 and 2.5 are the new ammounts
		adjustWeeds(-rand(1,2))

	//Pest Spray
	if(reagents.has_reagent("pestkiller", 1))
		adjustToxic(round(reagents.get_reagent_amount("pestkiller") * 0.5))
		adjustPests(-rand(1,2))

	// Healing
	if(reagents.has_reagent("cryoxadone", 1))
		adjustHealth(round(reagents.get_reagent_amount("cryoxadone") * 3))
		adjustToxic(-round(reagents.get_reagent_amount("cryoxadone") * 3))
		replace_doping(/datum/reagent/medicine/cryoxadone, user)

	// Healing
	if(reagents.has_reagent("omnizine", 1))
		adjustHealth(round(reagents.get_reagent_amount("omnizine") * 3))
		adjustToxic(-round(reagents.get_reagent_amount("omnizine") * 3))
		replace_doping(/datum/reagent/medicine/omnizine, user)

	// Mild healing
	if(reagents.has_reagent("salglu_solution", 1))
		adjustHealth(round(reagents.get_reagent_amount("salglu_solution") * 0.1))
		adjustToxic(-round(reagents.get_reagent_amount("salglu_solution") * 0.1))
		replace_doping(/datum/reagent/medicine/salglu_solution, user)

	// Ammonia heals and feeds plants
	if(reagents.has_reagent("ammonia", 1))
		adjustHealth(round(reagents.get_reagent_amount("ammonia") * 0.5))
		adjustNutri(round(reagents.get_reagent_amount("ammonia") * 1))
		replace_doping(/datum/reagent/ammonia, user)

	// Saltpetre is used for gardening IRL, but for us, it's just another
	// way to heal plants
	if(reagents.has_reagent("saltpetre", 1))
		var/salt = reagents.get_reagent_amount("saltpetre")
		adjustHealth(round(salt * 0.25))
		replace_doping(/datum/reagent/saltpetre, user)

	// Ash is also used IRL in gardening, as a fertilizer enhancer and weed killer
	if(reagents.has_reagent("ash", 1))
		adjustHealth(round(reagents.get_reagent_amount("ash") * 0.25))
		adjustNutri(round(reagents.get_reagent_amount("ash") * 0.5))
		adjustWeeds(-1)

	// This is more bad ass, and pests get hurt by the corrosive nature of it, not the plant.
	if(reagents.has_reagent("diethylamine", 1))
		adjustHealth(round(reagents.get_reagent_amount("diethylamine") * 1))
		adjustNutri(round(reagents.get_reagent_amount("diethylamine") * 2))
		adjustPests(-rand(1,2))
		replace_doping(/datum/reagent/diethylamine, user)

	// Compost, effectively
	if(reagents.has_reagent("nutriment", 1))
		adjustHealth(round(reagents.get_reagent_amount("nutriment") * 0.5))
		adjustNutri(round(reagents.get_reagent_amount("nutriment") * 1))

	if(reagents.has_reagent("plantmatter", 1))
		adjustHealth(round(reagents.get_reagent_amount("plantmatter") * 0.5))
		adjustNutri(round(reagents.get_reagent_amount("plantmatter") * 1))

	// Compost for EVERYTHING
	if(reagents.has_reagent("virusfood", 1))
		adjustNutri(round(reagents.get_reagent_amount("virusfood") * 0.5))
		adjustHealth(-round(reagents.get_reagent_amount("virusfood") * 0.5))

	// FEED ME
	if(reagents.has_reagent("blood", 1))
		adjustNutri(round(reagents.get_reagent_amount("blood") * 1))
		adjustPests(rand(2,4))

	// FEED ME SEYMOUR
	if(reagents.has_reagent("lazarus_reagent", 1))
		spawnplant()

	// Begone, mutagen!
	if(reagents.has_reagent("potass_iodide", 1))
		if(mutagen)
			to_chat(user, "<span class='notice'>The potassium iodide neutralizes the mutating agents in [src].</span>")
			mutagen = 0
	if(reagents.has_reagent("pen_acid", 1))
		if(mutagen)
			to_chat(user, "<span class='notice'>The pentetic acid neutralizes the mutating agents in [src].</span>")
			mutagen = 0

	// The best stuff there is. For testing/debugging.
	if(reagents.has_reagent("adminordrazine", 1))
		adjustWater(round(reagents.get_reagent_amount("adminordrazine") * 1))
		adjustHealth(round(reagents.get_reagent_amount("adminordrazine") * 1))
		adjustNutri(round(reagents.get_reagent_amount("adminordrazine") * 1))
		adjustPests(-rand(1,5))
		adjustWeeds(-rand(1,5))
	reagents.clear_reagents()

/obj/machinery/hydroponics/proc/replace_doping(datum/reagent/new_chem, mob/user)
	if(new_chem == doping_chem)
		to_chat(user, "<span class='notice'>[src] already contains [initial(new_chem.name)], adding more won't help.</span>")
		return
	var/list/message = list()
	message += "<span class='notice'>You add [initial(new_chem.name)] to [src]"
	if(doping_chem)
		message += ", replacing \the [initial(doping_chem.name)]."
	else
		message += "."
	if(get_mutation_level())
		message += " This should have interesting effects on the plant's seeds."
	else
		message += " You don't think this will help without a source of mutations."
	message += "</span>"
	to_chat(user, message.Join(""))
	doping_chem = new_chem

/obj/machinery/hydroponics/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	//Called when mob user "attacks" it with object `used`
	if(istype(used, /obj/item/reagent_containers))  // Syringe stuff (and other reagent containers now too)
		var/obj/item/reagent_containers/reagent_source = used
		var/target = myseed ? myseed.plantname : src

		if(istype(reagent_source, /obj/item/reagent_containers/syringe))
			var/obj/item/reagent_containers/syringe/syr = reagent_source
			if(syr.mode != SYRINGE_INJECT)
				to_chat(user, "<span class='warning'>You can't get any extract out of this plant.</span>")		//That. Gives me an idea...
				return ITEM_INTERACT_COMPLETE

		if(!reagent_source.reagents.total_volume)
			to_chat(user, "<span class='notice'>[reagent_source] is empty.</span>")
			return ITEM_INTERACT_COMPLETE

		if(reagent_source.has_lid && !reagent_source.is_drainable()) //if theres a LID then cannot transfer reagents.
			to_chat(user, "<span class='warning'>You need to open [used] first!</span>")
			return ITEM_INTERACT_COMPLETE

		var/visi_msg = ""
		var/transfer_amount = reagent_source.amount_per_transfer_from_this
		var/irrigate = FALSE

		if(istype(reagent_source, /obj/item/reagent_containers/syringe))
			var/obj/item/reagent_containers/syringe/syr = reagent_source
			visi_msg = "[user] injects [target] with [syr]"
			if(syr.reagents.total_volume <= syr.amount_per_transfer_from_this)
				syr.mode = SYRINGE_DRAW

		else if(istype(reagent_source, /obj/item/reagent_containers/spray))
			visi_msg = "[user] sprays [target] with [reagent_source]"
			playsound(loc, 'sound/effects/spray3.ogg', 50, TRUE, -6)
			irrigate = TRUE

		else if(transfer_amount) // Droppers, cans, beakers, what have you.
			visi_msg = "[user] uses [reagent_source] on [target]"
			irrigate = TRUE

		// Beakers, bottles, buckets, etc.
		if(reagent_source.is_drainable())
			playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)

		add_compost(reagent_source, user, transfer_amount, visi_msg, irrigate)
		return ITEM_INTERACT_COMPLETE

	else if(isfood(used) || istype(used, /obj/item/grown))
		var/target = myseed ? myseed.plantname : src
		var/transfer = used.reagents.total_volume
		var/message = "[user] composts [used], spreading it through [target]"
		add_compost(used, user, transfer, message)
		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/unsorted_seeds))
		to_chat(user, "<span class='warning'>You need to sort [used] first!</span>")
		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/seeds) && !istype(used, /obj/item/seeds/sample))
		if(!myseed)
			if(istype(used, /obj/item/seeds/kudzu))
				investigate_log("had Kudzu planted in it by [key_name(user)] at ([x],[y],[z])","kudzu")
			user.unequip(used)
			to_chat(user, "<span class='notice'>You plant [used].</span>")
			dead = FALSE
			myseed = used
			age = 1
			plant_health = myseed.endurance
			plant_hud_set_health()
			plant_hud_set_status()
			lastcycle = world.time
			used.forceMove(src)
			update_state()
		else
			to_chat(user, "<span class='warning'>[src] already has seeds in it!</span>")

		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/plant_analyzer))
		send_plant_details(user)
		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/cultivator))
		if(weedlevel > 0)
			user.visible_message("[user] uproots the weeds.", "<span class='notice'>You remove the weeds from [src].</span>")
			adjustWeeds(-10)
			update_state()
		else
			to_chat(user, "<span class='warning'>This plot is completely devoid of weeds! It doesn't need uprooting.</span>")
		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/storage/bag/plants))
		if(!harvest)
			attack_hand(user)
			return ITEM_INTERACT_COMPLETE

		myseed.harvest(user, used)

		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/shovel/spade))
		if(!myseed && !weedlevel)
			to_chat(user, "<span class='warning'>[src] doesn't have any plants or weeds!</span>")
			return ITEM_INTERACT_COMPLETE
		user.visible_message("<span class='notice'>[user] starts digging out [src]'s plants...</span>", "<span class='notice'>You start digging out [src]'s plants...</span>")
		playsound(src, used.usesound, 50, 1)
		if(!do_after(user, 25 * used.toolspeed, target = src) || (!myseed && !weedlevel))
			return ITEM_INTERACT_COMPLETE
		user.visible_message("<span class='notice'>[user] digs out the plants in [src]!</span>", "<span class='notice'>You dig out all of [src]'s plants!</span>")
		playsound(src, used.usesound, 50, 1)
		if(myseed) //Could be that they're just using it as a de-weeder
			age = 0
			plant_health = 0
			if(harvest)
				harvest = FALSE //To make sure they can't just put in another seed and insta-harvest it
			qdel(myseed)
			myseed = null
			mut_beamed = FALSE
			yield_beamed = FALSE
			plant_hud_set_health()
			plant_hud_set_status()
		adjustWeeds(-10) //Has a side effect of cleaning up those nasty weeds
		update_state()
		return ITEM_INTERACT_COMPLETE
	else if(is_pen(used) && myseed)
		myseed.variant_prompt(user, src)
		return ITEM_INTERACT_COMPLETE
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
		default_unfasten_wrench(user, I)

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
	else if(user.mind && HAS_TRAIT(user.mind, TRAIT_GREEN_THUMB) && weedlevel > 0)
		user.visible_message("[user] uproots the weeds.", "<span class='notice'>You pluck the weeds from [src] with your hands.</span>")
		adjustWeeds(-10)
		update_state()
	else
		examine(user)

/obj/machinery/hydroponics/proc/update_tray(mob/user = usr, harvested = 0)
	harvest = FALSE
	lastproduce = age
	if(istype(myseed,/obj/item/seeds/replicapod))
		to_chat(user, "<span class='notice'>You harvest from the [myseed.plantname].</span>")
	else if(harvested <= 0)
		to_chat(user, "<span class='warning'>You fail to harvest anything useful!</span>")
	else
		to_chat(user, "<span class='notice'>You harvest [harvested] items from the [myseed.plantname].</span>")
	if(!myseed.get_gene(/datum/plant_gene/trait/repeated_harvest))
		QDEL_NULL(myseed)
		dead = FALSE
	mutagen = max(0, mutagen - 1)
	mut_beamed = FALSE
	yield_beamed = FALSE
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
	var/list/livingplants = list(/mob/living/basic/tree, /mob/living/basic/killertomato)
	var/chosen = pick(livingplants)
	var/mob/living/simple_animal/hostile/C = new chosen(get_turf(src))
	C.faction = list("plants")

/obj/machinery/hydroponics/proc/become_self_sufficient() // Ambrosia Gaia effect
	visible_message("<span class='boldnotice'>[src] begins to glow with a beautiful light!</span>")
	self_sustaining = TRUE
	update_state()

///Diona Nymph Related Procs///
/obj/machinery/hydroponics/CanPass(atom/movable/mover, border_dir) //So nymphs can climb over top of trays.
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
/// Not actually hydroponics at all! Honk!
/obj/machinery/hydroponics/soil
	name = "soil"
	icon_state = "soil"
	density = FALSE
	power_state = NO_POWER_USE
	wrenchable = FALSE
	mutagen_tank_name = "Mutagen pool"
	is_soil = TRUE

/obj/machinery/hydroponics/soil/update_icon_state()
	return // Has no hoses

/obj/machinery/hydroponics/soil/update_icon_lights()
	return // Has no lights

/obj/machinery/hydroponics/soil/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/shovel) && !istype(used, /obj/item/shovel/spade)) //Doesn't include spades because of uprooting plants
		to_chat(user, "<span class='notice'>You clear up [src]!</span>")
		qdel(src)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/hydroponics/proc/add_compost(obj/item/reagent_source, mob/user, transfer_amount, visi_msg, irrigate = FALSE)
	var/list/trays = list(src)//makes the list just this in cases of syringes and compost etc

	if(irrigate && (transfer_amount > 30) && (reagent_source.reagents.total_volume >= 30) && using_irrigation)
		trays = FindConnected()

	if(length(trays) > 1)
		visi_msg += ", setting off the irrigation system"

	if(visi_msg)
		visible_message("<span class='notice'>[visi_msg].</span>")

	var/split = round(transfer_amount / length(trays))
	for(var/obj/machinery/hydroponics/H as anything in trays)//cause I don't want to feel like im juggling 15 tamagotchis and I can get to my real work of ripping flooring apart in hopes of validating my life choices of becoming a space-gardener
		reagent_source.reagents.trans_to(H, split)
		H.apply_chemicals(user)
		H.update_state()

	if(isfood(reagent_source) || ispill(reagent_source) || istype(reagent_source, /obj/item/grown))
		qdel(reagent_source)

	if(reagent_source) // If the source wasn't composted and destroyed
		reagent_source.update_icon()


/obj/machinery/hydroponics/proc/send_plant_details(mob/user)
	if(myseed)
		to_chat(user, "*** <b>[myseed.plantname]</b> ***")
		to_chat(user, "- Plant Age: <span class='notice'>[age]</span>")
		var/next_harvest = (age <= myseed.maturation ? myseed.maturation : lastproduce) + myseed.production
		to_chat(user, "- Next Harvest At: <span class='notice'>[next_harvest]</span>")
		var/list/text_string = myseed.get_analyzer_text()
		if(text_string)
			to_chat(user, text_string)
	else
		to_chat(user, "<b>No plant found.</b>")
	to_chat(user, "- Weed level: <span class='notice'>[weedlevel] / 10</span>")
	to_chat(user, "- Pest level: <span class='notice'>[pestlevel] / 10</span>")
	to_chat(user, "- Toxicity level: <span class='notice'>[toxic] / 100</span>")
	to_chat(user, "- Water level: <span class='notice'>[waterlevel] / [maxwater]</span>")
	to_chat(user, "- Nutrition level: <span class='notice'>[nutrilevel] / [maxnutri]</span>")
	if(self_sustaining)
		to_chat(user, "&nbsp;&nbsp;Nutrient: <span class='notice'>Earthsblood<br>&nbsp;&nbsp;This [src.name] has been treated with Earthsblood and constantly produces its own fertilizer. Like E-Z-Nutrient, Earthsblood fertilizer has no particular attributes, it just keeps plants fed.</span>")
	else
		to_chat(user, "&nbsp;&nbsp;Nutrient: <span class='notice'>[initial(nutrient.name)]<br>&nbsp;&nbsp;[initial(nutrient.description)]</span>")
	to_chat(user, "- [mutagen_tank_name]: <span class='notice'>[mutagen] / [max_mutagen]</span>")

	var/can_mutate_species = myseed && length(myseed.mutatelist)
	var/mutation_level = get_mutation_level()
	var/mutation_comment = ""
	if(mutation_level >= 30 && can_mutate_species)
		mutation_comment = " (will change species)"
	else if(mutation_level > 20 && can_mutate_species)
		mutation_comment = " (may add traits or change species)"
	else if(mutation_level > 20)
		mutation_comment = " (may add traits)"
	else if(mutation_level > 10 && can_mutate_species)
		mutation_comment = " (may change species)"
	to_chat(user, "- Mutation level: <span class='notice'>[get_mutation_level()][mutation_comment]</span>")

	to_chat(user, "- Doping chemical: <span class='notice'>[doping_chem ? initial(doping_chem.name) : "None"]</span>")
	if(doping_chem)
		to_chat(user, "&nbsp;&nbsp;<span class='notice'>Causes mutations to be focused on [english_list(doping_effects[doping_chem])].</span>")

/obj/machinery/hydroponics/attack_ghost(mob/dead/observer/user)
	if(!istype(user)) // Make sure user is actually an observer. Revenents also use attack_ghost, but do not have the toggle plant analyzer var.
		return
	if(user.ghost_flags & GHOST_PLANT_ANALYZER)
		send_plant_details(user)

/obj/machinery/hydroponics/rad_act(atom/source, amount, emission_type)
	if(!myseed)
		return
	// adjust radiation value according to type
	switch(emission_type)
		if(GAMMA_RAD)
			amount /= ((1 - rad_insulation_gamma) / 2)
		if(BETA_RAD)
			amount /= (1 - rad_insulation_beta)
		if(ALPHA_RAD)
			amount /= 2

	var/top_range = 100 * amount / (amount + 50)
	var/roll = rand(0, top_range)

	// Do the rad stuff
	if(prob(roll / 20))
		adjustHealth(-roll / 20)
	if(prob(roll / 7))
		myseed.mutate(roll / 2, get_mutation_focus())
	if(top_range > 30 && prob(roll / 10))
		mut_beamed = TRUE
