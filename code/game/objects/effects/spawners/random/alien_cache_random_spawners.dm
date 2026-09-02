// Canister
#define COMPRESSED_GAS_AMOUNT 300000
#define AGENT_B_AMOUNT 100000
#define NAME_O2 "O2"
#define NAME_CO2 "CO2"
#define NAME_N2 "N2"
#define NAME_N2O "N2O"
#define NAME_TOX "Plasma"
#define NAME_AGENT_B "Agent B"
// Lazarus Capsule
#define MOB_TYPE (1 << 0)
#define MOB_PROTOTYPE (1 << 1)

// MARK: Random Spanwers

/obj/effect/spawner/random/alien_cache
	name = "alien cache loot spawner"

// Random alien tools
/obj/effect/spawner/random/alien_cache/alien_tool
	name = "alien tool spawner"
	loot = list(
				/obj/item/screwdriver/abductor,
				/obj/item/wrench/abductor,
				/obj/item/multitool/abductor,
				/obj/item/wirecutters/abductor,
				/obj/item/crowbar/abductor,

				)

// Random alien surgical tools
/obj/effect/spawner/random/alien_cache/alien_surgical_tool
	name = "alien surgical tool spawner"
	loot = list(
				/obj/item/bonegel/alien,
				/obj/item/scalpel/laser/alien,
				/obj/item/bonesetter/alien,
				/obj/item/circular_saw/alien,
				/obj/item/hemostat/alien,
				/obj/item/fix_o_vein/alien,
				/obj/item/retractor/alien,
				)

// Random alien tool implant
/obj/effect/spawner/random/alien_cache/alien_tool_implant
	name = "alien tool implant spawner"
	loot = list(
				/obj/item/organ/internal/cyberimp/arm/toolset_abductor,
				/obj/item/organ/internal/cyberimp/arm/toolset_abductor/l,
				/obj/item/organ/internal/cyberimp/arm/janitorial_abductor,
				/obj/item/organ/internal/cyberimp/arm/janitorial_abductor/l,
				/obj/item/organ/internal/cyberimp/arm/surgical_abductor,
				/obj/item/organ/internal/cyberimp/arm/surgical_abductor/l,
				)

// Random alien tool borg upgrade
/obj/effect/spawner/random/alien_cache/alien_tool_borg
	name = "alien borg tool upgrade"
	loot = list(
				/obj/item/borg/upgrade/abductor_engi,
				/obj/item/borg/upgrade/abductor_medi,
				/obj/item/borg/upgrade/abductor_jani,
				)

//MARK: Canister Spawners

// Gas canister with random gas
/obj/effect/spawner/alien_cache/gas_canister
	name = "random gas canister spawner"
	var/list/gasses = list(
							NAME_O2 = COMPRESSED_GAS_AMOUNT,
							NAME_N2 = COMPRESSED_GAS_AMOUNT,
							NAME_CO2 = COMPRESSED_GAS_AMOUNT,
							NAME_TOX = COMPRESSED_GAS_AMOUNT,
							NAME_N2O = COMPRESSED_GAS_AMOUNT)

// Agent B canister
/obj/effect/spawner/alien_cache/gas_canister/agent_b
	name = "agent b canister spawner"
	gasses = list(NAME_AGENT_B  = AGENT_B_AMOUNT)

/obj/effect/spawner/alien_cache/gas_canister/proc/add_gas(obj/machinery/atmospherics/portable/canister/spawned)
	var/picked = pick(gasses)
	switch(picked)
		if(NAME_O2)
			spawned.air_contents.set_oxygen(gasses["[picked]"])
		if(NAME_N2)
			spawned.air_contents.set_nitrogen(gasses["[picked]"])
		if(NAME_N2O)
			spawned.air_contents.set_sleeping_agent(gasses["[picked]"])
		if(NAME_CO2)
			spawned.air_contents.set_carbon_dioxide(gasses["[picked]"])
		if(NAME_TOX)
			spawned.air_contents.set_toxins(gasses["[picked]"])
		if(NAME_AGENT_B)
			spawned.air_contents.set_agent_b(gasses["[picked]"])

/obj/effect/spawner/alien_cache/gas_canister/Initialize(mapload)
	. = ..()
	var/obj/machinery/atmospherics/portable/canister/spawned = new(get_turf(src))
	add_gas(spawned)
	update_icon()
	qdel(src)

// MARK: Lazarus Spawners
// Lazarus Capsule with a mob inside
/obj/effect/spawner/alien_cache/mob_capsule
	var/list/mob_types = list()

// Lazarus Capsule with a megafauna inside
/obj/effect/spawner/alien_cache/mob_capsule/megafauna
	mob_types = list(/mob/living/simple_animal/hostile/megafauna = MOB_PROTOTYPE)

/obj/effect/spawner/alien_cache/mob_capsule/Initialize(mapload)
	. = ..()
	var/obj/item/mobcapsule/capsule = new(get_turf(src))
	var/type
	if(length(mob_types))
		var/list/pool = list()
		for(var/mob_type in mob_types)
			if(mob_types[mob_type] & MOB_TYPE)
				pool += mob_type
			if(mob_types[mob_type] & MOB_PROTOTYPE)
				pool += subtypesof(mob_type)
		type = pick(pool)
	else
		type = pick(subtypesof(/mob/living/simple_animal))
	var/mob/living/simple_animal/my_mob = new type(loc)
	my_mob.faction = list("neutral")
	capsule.captured = my_mob
	my_mob.forceMove(capsule)

// TEG crate for the cache
/obj/structure/closet/crate/teg

/obj/structure/closet/crate/teg/populate_contents()
	new /obj/machinery/power/teg(src)
	new /obj/item/pipe/circulator(src)
	new /obj/item/pipe/circulator(src)

#undef COMPRESSED_GAS_AMOUNT
#undef AGENT_B_AMOUNT
#undef NAME_O2
#undef NAME_CO2
#undef NAME_N2
#undef NAME_N2O
#undef NAME_TOX
#undef NAME_AGENT_B
#undef MOB_TYPE
#undef MOB_PROTOTYPE
