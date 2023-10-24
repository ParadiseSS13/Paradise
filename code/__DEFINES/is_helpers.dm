// Datums
#define isdatum(thing) (istype(thing, /datum))

// Atoms
#define isatom(A) (isloc(A))

// Mobs

//#define ismob(A, B, C...) BYOND proc, can test multiple arguments and only return TRUE if all are mobs

#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/carbon/brain))

// Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid))

#define isalienhunter(A) (istype(A, /mob/living/carbon/alien/humanoid/hunter))

#define isaliensentinel(A) (istype(A, /mob/living/carbon/alien/humanoid/sentinel))

// Simple animals

#define issimple_animal(A) (istype(A, /mob/living/simple_animal))

#define ismegafauna(A) istype(A, /mob/living/simple_animal/hostile/megafauna)

#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define isconstruct(A) (istype(A, /mob/living/simple_animal/hostile/construct))

#define isslime(A) (istype((A), /mob/living/simple_animal/slime))

#define ispulsedemon(A) (istype(A, /mob/living/simple_animal/demon/pulse_demon))

// Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define ismachinery(A) (istype(A, /obj/machinery))

#define isapc(A) (istype(A, /obj/machinery/power/apc))

#define ismecha(A) (istype(A, /obj/mecha))

#define iseffect(A) (istype(A, /obj/effect))

#define isclothing(A) (istype(A, /obj/item/clothing))

#define is_pen(W) (istype(W, /obj/item/pen) || istype(W, /obj/item/flashlight/pen))

#define is_pda(W) (istype(W, /obj/item/pda))

#define isspacecash(W) (istype(W, /obj/item/stack/spacecash))

#define isstorage(A) (istype(A, /obj/item/storage))

#define isstack(I) (istype(I, /obj/item/stack))

GLOBAL_LIST_INIT(pointed_types, typecacheof(list(
	/obj/item/pen,
	/obj/item/screwdriver,
	/obj/item/reagent_containers/syringe,
	/obj/item/kitchen/utensil/fork)))

#define is_pointed(W) (is_type_in_typecache(W, GLOB.pointed_types))

GLOBAL_LIST_INIT(glass_sheet_types, typecacheof(list(
	/obj/item/stack/sheet/glass,
	/obj/item/stack/sheet/rglass,
	/obj/item/stack/sheet/plasmaglass,
	/obj/item/stack/sheet/plasmarglass,
	/obj/item/stack/sheet/titaniumglass,
	/obj/item/stack/sheet/plastitaniumglass)))

#define is_glass_sheet(O) (is_type_in_typecache(O, GLOB.glass_sheet_types))

// Turfs

//#define isturf(A, B, C...) BYOND proc, can test multiple arguments and only return TRUE if all are turfs

#define issimulatedturf(A) istype(A, /turf/simulated)

#define isspaceturf(A) istype(A, /turf/space)

#define istransparentturf(A) istype(A, /turf/simulated/floor/transparent)

#define isfloorturf(A) istype(A, /turf/simulated/floor)

#define iswallturf(A) istype(A, /turf/simulated/wall)

#define isreinforcedwallturf(A) istype(A, /turf/simulated/wall/r_wall)

#define ismineralturf(A) istype(A, /turf/simulated/mineral)

#define islava(A) (istype(A, /turf/simulated/floor/plating/lava))

#define ischasm(A) (istype(A, /turf/simulated/floor/chasm))

#define is_ancient_rock(A) (istype(A, /turf/simulated/mineral/ancient))

// Areas
//#define isarea(A, B, C...) BYOND proc, can test multiple arguments and only return TRUE if all are areas

// Structures
#define isstructure(A)	(istype((A), /obj/structure))

// Misc
#define isclient(A) istype(A, /client)
#define isradio(A) istype(A, /obj/item/radio)
#define ispill(A) istype(A, /obj/item/reagent_containers/food/pill)

// Modsuits
#define ismodcontrol(A) istype(A, /obj/item/mod/control)

// Meteors
GLOBAL_LIST_INIT(turfs_pass_meteor, typecacheof(list(
	/turf/simulated/floor/plating/asteroid,
	/turf/space
)))

#define ispassmeteorturf(A) (is_type_in_typecache(A, GLOB.turfs_pass_meteor))
