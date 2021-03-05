//Crew has to create dna vault
// Cargo can order DNA samplers + DNA vault boards
// DNA vault requires x animals ,y plants, z human dna
// DNA vaults require high tier stock parts and cold
// After completion each crewmember can receive single upgrade chosen out of 2 for the mob.
#define VAULT_TOXIN "Toxin Adaptation"
#define VAULT_NOBREATH "Lung Enhancement"
#define VAULT_FIREPROOF "Thermal Regulation"
#define VAULT_STUNTIME "Neural Repathing"
#define VAULT_ARMOUR "Hardened Skin"
#define VAULT_SPEED "Leg Muscle Stimulus"
#define VAULT_QUICK "Arm Muscle Stimulus"

/datum/station_goal/dna_vault
	name = "DNA Vault"
	var/animal_count
	var/human_count
	var/plant_count

/datum/station_goal/dna_vault/New()
	..()
	animal_count = rand(15, 20) //might be too few given ~15 roundstart stationside ones
	human_count = rand(round(0.75 * SSticker.mode.num_players_started()), SSticker.mode.num_players_started()) // 75%+ roundstart population.
	var/non_standard_plants = non_standard_plants_count()
	plant_count = rand(round(0.5 * non_standard_plants),round(0.7 * non_standard_plants))

/datum/station_goal/dna_vault/proc/non_standard_plants_count()
	. = 0
	for(var/T in subtypesof(/obj/item/seeds)) //put a cache if it's used anywhere else
		var/obj/item/seeds/S = T
		if(initial(S.rarity) > 0)
			.++

/datum/station_goal/dna_vault/get_report()
	return {"<b>DNA Vault construction</b><br>
	Our long term prediction systems say there's 99% chance of system-wide cataclysm in near future. As such, we need you to construct a DNA Vault aboard your station.
	<br><br>
	The DNA Vault needs to contain samples of:
	<ul style='margin-top: 10px; margin-bottom: 10px;'>
	 <li>[animal_count] unique animal data.</li>
	 <li>[plant_count] unique non-standard plant data.</li>
	 <li>[human_count] unique sapient humanoid DNA data.</li>
	</ul>
	The base vault parts should be available for shipping by your cargo shuttle."}

/datum/station_goal/dna_vault/on_report()
	var/datum/supply_packs/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/dna_vault]"]
	P.special_enabled = TRUE

	P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/dna_probes]"]
	P.special_enabled = TRUE

/datum/station_goal/dna_vault/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/dna_vault/V in GLOB.machines)
		if(V.animals.len >= animal_count && V.plants.len >= plant_count && V.dna.len >= human_count && is_station_contact(V.z))
			return TRUE
	return FALSE

/obj/item/dna_probe
	name = "DNA Sampler"
	desc = "Can be used to take chemical and genetic samples of pretty much anything."
	icon = 'icons/obj/hypo.dmi'
	item_state = "sampler_hypo"
	icon_state = "sampler_hypo"
	flags = NOBLUDGEON
	var/list/animals = list()
	var/list/plants = list()
	var/list/dna = list()

/obj/item/dna_probe/proc/clear_data()
	animals = list()
	plants = list()
	dna = list()

GLOBAL_LIST_INIT(non_simple_animals, typecacheof(list(/mob/living/carbon/human/monkey,/mob/living/carbon/alien)))

/obj/item/dna_probe/afterattack(atom/target, mob/user, proximity)
	..()
	if(!proximity || !target)
		return
	//tray plants
	if(istype(target,/obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/H = target
		if(!H.myseed)
			return
		if(!H.harvest)// So it's bit harder.
			to_chat(user, "<span clas='warning'>Plants needs to be ready to harvest to perform full data scan.</span>") //Because space dna is actually magic
			return
		if(plants[H.myseed.type])
			to_chat(user, "<span class='notice'>Plant data already present in local storage.</span>")
			return
		plants[H.myseed.type] = 1
		to_chat(user, "<span class='notice'>Plant data added to local storage.</span>")

	//animals
	if(isanimal(target) || is_type_in_typecache(target, GLOB.non_simple_animals))
		if(isanimal(target))
			var/mob/living/simple_animal/A = target
			if(!A.healable)//simple approximation of being animal not a robot or similar
				to_chat(user, "<span class='warning'>No compatible DNA detected</span>")
				return
		if(animals[target.type])
			to_chat(user, "<span class='notice'>Animal data already present in local storage.</span>")
			return
		animals[target.type] = 1
		to_chat(user, "<span class='notice'>Animal data added to local storage.</span>")

	//humans
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(HAS_TRAIT(H, TRAIT_GENELESS))
			to_chat(user, "<span class='notice'>This humanoid doesn't have DNA.</span>")
			return
		if(dna[H.dna.uni_identity])
			to_chat(user, "<span class='notice'>Humanoid data already present in local storage.</span>")
			return
		dna[H.dna.uni_identity] = 1
		to_chat(user, "<span class='notice'>Humanoid data added to local storage.</span>")


/obj/item/circuitboard/machine/dna_vault
	name = "DNA Vault (Machine Board)"
	build_path = /obj/machinery/dna_vault
	origin_tech = "engineering=2;combat=2;bluespace=2" //No freebies!
	req_components = list(
							/obj/item/stock_parts/capacitor/super = 5,
							/obj/item/stock_parts/manipulator/pico = 5,
							/obj/item/stack/cable_coil = 2)

/obj/structure/filler
	name = "big machinery part"
	density = 1
	anchored = 1
	invisibility = 101
	var/obj/machinery/parent

/obj/structure/filler/Destroy()
	parent = null
	return ..()

/obj/structure/filler/ex_act()
	return

/obj/machinery/dna_vault
	name = "DNA Vault"
	desc = "Break glass in case of apocalypse."
	icon = 'icons/obj/machines/dna_vault.dmi'
	icon_state = "vault"
	density = 1
	anchored = 1
	idle_power_usage = 5000
	pixel_x = -32
	pixel_y = -64
	luminosity = 1

	//High defaults so it's not completed automatically if there's no station goal
	var/animals_max = 100
	var/plants_max = 100
	var/dna_max = 100
	var/list/animals = list()
	var/list/plants = list()
	var/list/dna = list()

	var/completed = FALSE
	var/static/list/power_lottery = list()

	var/list/obj/structure/fillers = list()

/obj/machinery/dna_vault/New()
	//TODO: Replace this,bsa and gravgen with some big machinery datum
	var/list/occupied = list()
	for(var/direct in list(EAST,WEST,SOUTHEAST,SOUTHWEST))
		occupied += get_step(src,direct)
	occupied += locate(x+1,y-2,z)
	occupied += locate(x-1,y-2,z)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F

	if(SSticker.mode)
		for(var/datum/station_goal/dna_vault/G in SSticker.mode.station_goals)
			animals_max = G.animal_count
			plants_max = G.plant_count
			dna_max = G.human_count
			break

	..()

/obj/machinery/dna_vault/update_icon()
	..()
	if(stat & NOPOWER)
		icon_state = "vaultoff"
		return
	icon_state = "vault"

/obj/machinery/dna_vault/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	update_icon()


/obj/machinery/dna_vault/Destroy()
	QDEL_LIST(fillers)
	return ..()

/obj/machinery/dna_vault/attack_ghost(mob/user)
	if(stat & (BROKEN|MAINT))
		return
	return ui_interact(user)

/obj/machinery/dna_vault/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/dna_vault/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		roll_powers(user)
		ui = new(user, src, ui_key, "DnaVault", name, 350, 400, master_ui, state)
		ui.open()

/obj/machinery/dna_vault/proc/roll_powers(mob/user)
	if(user in power_lottery)
		return
	var/list/L = list()
	var/list/possible_powers = list(VAULT_TOXIN, VAULT_NOBREATH, VAULT_FIREPROOF, VAULT_STUNTIME, VAULT_ARMOUR, VAULT_SPEED, VAULT_QUICK)
	L += pick_n_take(possible_powers)
	L += pick_n_take(possible_powers)
	power_lottery[user] = L

/obj/machinery/dna_vault/ui_data(mob/user)
	var/list/data = list(
		"plants" = length(plants),
		"plants_max" = plants_max,
		"animals" = length(animals),
		"animals_max" = animals_max,
		"dna" = length(dna),
		"dna_max" = dna_max,
		"completed" = completed,
		"used" = TRUE,
		"choiceA" = "",
		"choiceB" = ""
	)
	if(user && completed)
		var/list/L = power_lottery[user]
		if(length(L))
			data["used"] = FALSE
			data["choiceA"] = L[1]
			data["choiceB"] = L[2]
		else if(L)
			data["used"] = TRUE
	return data

/obj/machinery/dna_vault/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("gene")
			upgrade(usr, params["choice"])
			return TRUE

/obj/machinery/dna_vault/proc/check_goal()
	if(plants.len >= plants_max && animals.len >= animals_max && dna.len >= dna_max)
		completed = TRUE

/obj/machinery/dna_vault/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/dna_probe))
		var/obj/item/dna_probe/P = I
		var/uploaded = 0
		for(var/plant in P.plants)
			if(!plants[plant])
				uploaded++
				plants[plant] = 1
		for(var/animal in P.animals)
			if(!animals[animal])
				uploaded++
				animals[animal] = 1
		for(var/ui in P.dna)
			if(!dna[ui])
				uploaded++
				dna[ui] = 1
		check_goal()
		to_chat(user, "<span class='notice'>[uploaded] new datapoints uploaded.</span>")
	else
		return ..()

/obj/machinery/dna_vault/proc/upgrade(mob/living/carbon/human/H, upgrade_type)
	if(!(upgrade_type in power_lottery[H]))
		return
	if(!completed)
		return
	var/datum/species/S = H.dna.species
	if(HAS_TRAIT(H, TRAIT_GENELESS))
		to_chat(H, "<span class='warning'>Error, no DNA detected.</span>")
		return
	switch(upgrade_type)
		if(VAULT_TOXIN)
			to_chat(H, "<span class='notice'>You feel resistant to airborne toxins.</span>")
			var/obj/item/organ/internal/lungs/L = H.get_int_organ(/obj/item/organ/internal/lungs)
			if(L)
				L.tox_breath_dam_min = 0
				L.tox_breath_dam_max = 0
			ADD_TRAIT(H, TRAIT_VIRUSIMMUNE, "dna_vault")
		if(VAULT_NOBREATH)
			to_chat(H, "<span class='notice'>Your lungs feel great.</span>")
			ADD_TRAIT(H, TRAIT_NOBREATH, "dna_vault")
		if(VAULT_FIREPROOF)
			to_chat(H, "<span class='notice'>You feel fireproof.</span>")
			S.burn_mod *= 0.5
			ADD_TRAIT(H, TRAIT_RESISTHEAT, "dna_vault")
		if(VAULT_STUNTIME)
			to_chat(H, "<span class='notice'>Nothing can keep you down for long.</span>")
			S.stun_mod *= 0.5
		if(VAULT_ARMOUR)
			to_chat(H, "<span class='notice'>You feel tough.</span>")
			S.armor = 30
			ADD_TRAIT(H, TRAIT_PIERCEIMMUNE, "dna_vault")
		if(VAULT_SPEED)
			to_chat(H, "<span class='notice'>You feel very fast and agile.</span>")
			S.speed_mod = -1
		if(VAULT_QUICK)
			to_chat(H, "<span class='notice'>Your arms move as fast as lightning.</span>")
			H.next_move_modifier = 0.5
	power_lottery[H] = list()

#undef VAULT_TOXIN
#undef VAULT_NOBREATH
#undef VAULT_FIREPROOF
#undef VAULT_STUNTIME
#undef VAULT_ARMOUR
#undef VAULT_SPEED
#undef VAULT_QUICK
