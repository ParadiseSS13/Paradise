// Atoms
#define isatom(A) istype(A, /atom)
#define ismovableatom(A) istype(A, /atom/movable)

// Mobs
#define ismegafauna(A) istype(A, /mob/living/simple_animal/hostile/megafauna)

//Simple animals
#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define isconstruct(A) (istype(A, /mob/living/simple_animal/hostile/construct))

//Objects
#define isitem(A) (istype(A, /obj/item))

#define ismecha(A) (istype(A, /obj/mecha))

#define is_cleanable(A) (istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/rune)) //if something is cleanable

#define is_pen(W) (istype(W, /obj/item/pen))

var/list/static/global/pointed_types = typecacheof(list(
	/obj/item/pen,
	/obj/item/screwdriver,
	/obj/item/reagent_containers/syringe,
	/obj/item/kitchen/utensil/fork))

#define is_pointed(W) (is_type_in_typecache(W, pointed_types))

GLOBAL_LIST_INIT(glass_sheet_types, typecacheof(list(
	/obj/item/stack/sheet/glass,
	/obj/item/stack/sheet/rglass,
	/obj/item/stack/sheet/plasmaglass,
	/obj/item/stack/sheet/plasmarglass,
	/obj/item/stack/sheet/titaniumglass,
	/obj/item/stack/sheet/plastitaniumglass)))

#define is_glass_sheet(O) (is_type_in_typecache(O, GLOB.glass_sheet_types))

//Turfs
#define issimulatedturf(A) istype(A, /turf/simulated)

#define isspaceturf(A) istype(A, /turf/space)

#define isfloorturf(A) istype(A, /turf/simulated/floor)

#define isunsimulatedturf(A) istype(A, /turf/unsimulated)

#define iswallturf(A) istype(A, /turf/simulated/wall)

#define isreinforcedwallturf(A) istype(A, /turf/simulated/wall/r_wall)

#define ismineralturf(A) istype(A, /turf/simulated/mineral)

//Mobs
#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/carbon/brain))

//Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

//more carbon mobs
#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid))

#define isalienhunter(A) (istype(A, /mob/living/carbon/alien/humanoid/hunter))

#define isaliensentinel(A) (istype(A, /mob/living/carbon/alien/humanoid/sentinel))

#define isslime(A)		(istype((A), /mob/living/carbon/slime))

//Structures
#define isstructure(A)	(istype((A), /obj/structure))

// Misc
#define isclient(A) istype(A, /client)
#define isradio(A) istype(A, /obj/item/radio)
#define ispill(A) istype(A, /obj/item/reagent_containers/food/pill)

