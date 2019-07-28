#define RARITY_COMMON 0
#define RARITY_UNCOMMON 1
#define RARITY_RARE 2
#define RARITY_VERYRARE 3

//////////////////////////////TECH PRIZE DEFINITIONS////////////////////////////////
// Re-implements the old strange object code in order to finish the proof of concept.
//
//

/obj/item/discovered_tech
	name = "Discovered Technology"
	desc = "A strange device. Its function is not immediately apparent."
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	var/techProc = "nothing"
	var/list/iconlist = list("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
	var/cooldownMax = 60
	var/cooldown = FALSE
	var/stability = 0
	var/potency = 0
	var/raritylevel = 0
	var/base_name = "Unknown"

/obj/item/discovered_tech/attack_self(mob/user)
	if(cooldown)
		to_chat(user, "<span class='warning'>The [src] does not react!</span>")
		return
	else if(src.loc == user)
		cooldown = TRUE
		call(src,techProc)(user)
		spawn(cooldownMax)
			cooldown = FALSE

// Define the stats, function and name of the object based on the rarity level.
/obj/item/discovered_tech/proc/define(var/stability_in, var/potency_in, var/base_name, var/rare_level)
	stability = stability_in
	potency = potency_in
	raritylevel = rare_level
	icon_state = pick(iconlist)
	var/list/second_name = new/list
	switch(rare_level)
		if(RARITY_COMMON)
			techProc = pick("rapiddupe")
			second_name.Add("Electric ", "Elastic ", "Fluidic ", "Cellular ", "Superficial ", "Stringy ", "Simple ", "Flexible ", "Basic ", "Voltaic ", "Thermal ", "Deformed ")
		if(RARITY_UNCOMMON)
			techProc = pick("teleport", "rapiddupe")
			second_name.Add("Spun ", "Gradiated ", "Neutron ", "Force-", "Kepler ", "Ionic ", "Flux ", "Magnetic ", "Vacuum ", "Meson ", "Edison ", "Pulse ", "Elementary ", "Focused ")
		if(RARITY_RARE)
			techProc = pick("clean", "teleport", "rapiddupe")
			second_name.Add("Harmonic ", "Tesla ", "Quantum ", "Massive ", "Lunar ", "Gravitic ", "Schottky ", "Alpha-", "Beta-", "Gamma-", "Fusion ", "Dynamic ", "Plasma ")
		if(RARITY_VERYRARE)
			techProc = pick("flash", "teleport", "clean")
			second_name.Add("Singulo-", "Bluespace ", "Omega-", "Stellar ", "Cosmic ", "Euler ", "Dark ", "Entropy ", "Hydron ")
	// Name format: "Prototype Descartes Shuffler". First word is the type of "box" it came from. Second is chosen based on rarity. Third is chosed based on function.
	name = "[base_name] " + pick(second_name) + choosethirdname()
	cooldownMax = choosecooldown()

#undef RARITY_COMMON
#undef RARITY_UNCOMMON
#undef RARITY_RARE
#undef RARITY_VERYRARE

// Split off from define to keep it simple-ish once more functions are added. Give each possible item at least 3 names.
// Giving the same name to multiple devices is welcomed and encouraged.
/obj/item/discovered_tech/proc/choosethirdname()
	switch(techProc)
		if("rapiddupe")
			return pick("Splitter", "Multitron", "Fast-Breeder")
		if("teleport")
			return pick("Zanziptomizer", "Teletron", "Dimensional Porta-Potty")
		if("clean")
			return pick("Janitron", "Scourer", "Obliterator")
		if("flash")
			return pick("Mesmertron", "Photon Channeller", "Eye-Melter")

// Choose the cooldown timer for the device. Add multipliers here.
/obj/item/discovered_tech/proc/choosecooldown()
	switch(techProc)
		if("rapiddupe")
			//			|Base CD	|Rarity Multiplier	 |Stability Multiplier
			return round(rand(10,30)*(1.4-0.2*raritylevel)*(1.4-0.2*(stability/20)),1)
		if("teleport")
			return round(rand(30,60)*(1.4-0.2*raritylevel)*(1.4-0.2*(stability/20)),1)
		if("clean")
			return round(rand(20,60)*(1.4-0.2*raritylevel)*(1.4-0.2*(stability/20)),1)
		if("flash")
			return round(rand(10,40)*(1.4-0.2*raritylevel)*(1.4-0.2*(stability/20)),1)

///////////////////////////////DEVICE FUNCTION PROCS/////////////////////////////////////////////
// Mostly borrowed from the old relics for testing purposes.
/obj/item/discovered_tech/proc/nothing(mob/user)
	to_chat(user, "<span class='notice'>The [src] does nothing of note.</span>")

/obj/item/discovered_tech/proc/clean(mob/user)
	playsound(src.loc, "sparks", rand(25,50), 1)
	var/obj/item/grenade/chem_grenade/cleaner/CL = new/obj/item/grenade/chem_grenade/cleaner(get_turf(user))
	CL.prime()

/obj/item/discovered_tech/proc/flash(mob/user)
	playsound(src.loc, "sparks", rand(25,50), 1)
	var/obj/item/grenade/flashbang/CB = new/obj/item/grenade/flashbang(get_turf(user))
	CB.prime()

/obj/item/discovered_tech/proc/rapiddupe(mob/user)
	audible_message("[src] emits a loud pop!")
	var/list/dupes = list()
	var/counter
	var/max = rand(potency/10, potency/5)
	for(counter = 1; counter < max; counter++)
		var/obj/item/discovered_tech/R = new src.type(get_turf(src))
		R.icon_state = icon_state
		R.name = name
		R.desc = desc
		dupes |= R
		spawn()
			R.throw_at(pick(oview(2+potency/20,get_turf(src))),10,1)
	counter = 0
	spawn(rand(stability/10,stability))
		for(counter = 1; counter <= dupes.len; counter++)
			var/obj/item/discovered_tech/R = dupes[counter]
			qdel(R)

/obj/item/discovered_tech/proc/teleport(mob/user)
	to_chat(user, "<span class='notice'>The [src] begins to vibrate!</span>")
	spawn(rand(10,30))
		var/turf/userturf = get_turf(user)
		if(src.loc == user && is_teleport_allowed(userturf.z))
			visible_message("<span class='notice'>The [src] twists and bends, relocating itself!</span>")
			do_teleport(user, userturf, 8, asoundin = 'sound/effects/phasein.ogg')