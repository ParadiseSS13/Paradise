// Datums
#define isdatum(thing) (istype(thing, /datum))

#define isspell(A) (istype(A, /datum/spell))

// Atoms
#define isatom(A) (isloc(A))

// Mobs

//#define ismob(A, B, C...) BYOND proc, can test multiple arguments and only return TRUE if all are mobs

#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/brain))

// Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid))

#define isalienhunter(A) (istype(A, /mob/living/carbon/alien/humanoid/hunter))

#define isaliensentinel(A) (istype(A, /mob/living/carbon/alien/humanoid/sentinel))

#define isalienqueen(A) (istype(A, /mob/living/carbon/alien/humanoid/queen))

// Simple animals

#define isanimal(A) (istype(A, /mob/living/simple_animal))

#define ismegafauna(A) istype(A, /mob/living/simple_animal/hostile/megafauna)

#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define isconstruct(A) (istype(A, /mob/living/simple_animal/hostile/construct))

#define isslime(A) (istype((A), /mob/living/simple_animal/slime))

#define ispulsedemon(A) (istype(A, /mob/living/simple_animal/demon/pulse_demon))

#define isshadowdemon(A) (istype(A, /mob/living/simple_animal/demon/shadow))

// Basic mobs

#define isbasicmob(A) (istype(A, /mob/living/basic))

// Simple animal -> basic mob migration helpers

#define isanimal_or_basicmob(A) (isanimal(A) || isbasicmob(A))

// Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define ismachinery(A) (istype(A, /obj/machinery))

#define isairlock(A) (istype(A, /obj/machinery/door))

#define isapc(A) (istype(A, /obj/machinery/power/apc))

#define ismecha(A) (istype(A, /obj/mecha))

#define isclowncar(A) (istype(A, /obj/tgvehicle/sealed/car/clowncar))

#define iseffect(A) (istype(A, /obj/effect))

#define isclothing(A) (istype(A, /obj/item/clothing))

#define ismask(A) (istype(A, /obj/item/clothing/mask))

#define isprojectile(A) (istype(A, /obj/item/projectile))

#define isgun(A) (istype(A, /obj/item/gun))

#define is_pen(W) (istype(W, /obj/item/pen) || istype(W, /obj/item/flashlight/pen))

#define is_pda(W) (istype(W, /obj/item/pda))

#define isspacecash(W) (istype(W, /obj/item/stack/spacecash))

#define isstorage(A) (istype(A, /obj/item/storage))

#define isstack(I) (istype(I, /obj/item/stack))

#define istable(S) (istype(S, /obj/structure/table))

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

#define islava(A) (istype(A, /turf/simulated/floor/lava))

#define ischasm(A) (istype(A, /turf/simulated/floor/chasm))

#define is_ancient_rock(A) (istype(A, /turf/simulated/mineral/ancient))

// Areas
//#define isarea(A, B, C...) BYOND proc, can test multiple arguments and only return TRUE if all are areas

#define isspacearea(A)	(istype(A, /area/space))

// Structures
#define isstructure(A)	(istype((A), /obj/structure))

// Vehicles
#define isvehicle(A) istype(A, /obj/vehicle)
#define istgvehicle(A) istype(A, /obj/tgvehicle)

// Misc
#define isclient(A) istype(A, /client)
#define isradio(A) istype(A, /obj/item/radio)
#define ispill(A) istype(A, /obj/item/reagent_containers/pill)
#define ispatch(A) istype(A, /obj/item/reagent_containers/patch)
#define isfood(A) istype(A, /obj/item/food)
#define is_color_text(thing) (istext(thing) && GLOB.regex_rgb_text.Find(thing))

// Modsuits
#define ismodcontrol(A) istype(A, /obj/item/mod/control)

#define is_screen_atom(A) istype(A, /atom/movable/screen)

#define is_multi_tile_object(atom) (atom?.bound_width > world.icon_size || atom?.bound_height > world.icon_size)
