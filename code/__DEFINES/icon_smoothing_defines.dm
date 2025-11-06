/* smoothing_flags */
/// Smoothing system in where adjacencies are calculated and used to build an image by mounting each corner at runtime.
#define SMOOTH_CORNERS	(1<<0)
/// Smoothing system in where adjacencies are calculated and used to select a pre-baked icon_state, encoded by bitmasking.
#define SMOOTH_BITMASK		(1<<1)
/// Atom has diagonal corners, with underlays under them.
#define SMOOTH_DIAGONAL_CORNERS	(1<<2)
/// Atom will smooth with the borders of the map.
#define SMOOTH_BORDER	(1<<3)
/// Atom is currently queued to smooth.
#define SMOOTH_QUEUED	(1<<4)
/// Smooths with objects, and will thus need to scan turfs for contents.
#define SMOOTH_OBJ		(1<<5)

DEFINE_BITFIELD(smoothing_flags, list(
	"SMOOTH_CORNERS" = SMOOTH_CORNERS,
	"SMOOTH_BITMASK" = SMOOTH_BITMASK,
	"SMOOTH_DIAGONAL_CORNERS" = SMOOTH_DIAGONAL_CORNERS,
	"SMOOTH_BORDER" = SMOOTH_BORDER,
	"SMOOTH_QUEUED" = SMOOTH_QUEUED,
	"SMOOTH_OBJ" = SMOOTH_OBJ,
))

/*smoothing macros*/

#define QUEUE_SMOOTH(thing_to_queue) if((thing_to_queue.smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)) && thing_to_queue.z) {SSicon_smooth.add_to_queue(thing_to_queue)}

#define QUEUE_SMOOTH_NEIGHBORS(thing_to_queue) for(var/neighbor in orange(1, thing_to_queue)) {var/atom/atom_neighbor = neighbor; QUEUE_SMOOTH(atom_neighbor)}

#define REMOVE_FROM_SMOOTH_QUEUE(thing_to_remove) if(thing_to_remove.smoothing_flags & SMOOTH_QUEUED) {SSicon_smooth.remove_from_queues(thing_to_remove)}

/**SMOOTHING GROUPS
 * Groups of things to smooth with.
 * * Contained in the `list/smoothing_groups` variable.
 * * Matched with the `list/canSmoothWith` variable to check whether smoothing is possible or not.
 */

#define S_TURF(num) ((24 * 0) + num) //Not any different from the number itself, but kept this way in case someone wants to expand it by adding stuff before it.
/* /turf only */

#define SMOOTH_GROUP_TURF S_TURF(0)						///turf/simulated
#define SMOOTH_GROUP_TURF_CHASM S_TURF(1)				///turf/simulated/chasm, /turf/simulated/floor/fakepit
#define SMOOTH_GROUP_FLOOR_LAVA S_TURF(2)				///turf/simulated/floor/lava
#define SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS S_TURF(3)	///turf/simulated/transparent/glass

#define SMOOTH_GROUP_FLOOR S_TURF(4)					///turf/simulated/floor

#define SMOOTH_GROUP_FLOOR_GRASS S_TURF(5)				///turf/simulated/floor/plating/grass
#define SMOOTH_GROUP_FLOOR_ICE S_TURF(6)				///turf/simulated/floor/plating/ice
#define SMOOTH_GROUP_BEACH_WATER S_TURF(7)					///turf/simulated/floor/beach/away/water/
#define SMOOTH_GROUP_GLASS_FLOOR S_TURF(8)				///turf/simulated/floor/transparent/glass and subtypes
#define SMOOTH_GROUP_GLASS_FLOOR_TITANIUM S_TURF(9)		///turf/simulated/floor/transparent/glass/titanium and subtypes

#define SMOOTH_GROUP_CARPET S_TURF(10)					///turf/simulated/floor/carpet
#define SMOOTH_GROUP_CARPET_BLACK S_TURF(11)
#define SMOOTH_GROUP_CARPET_BLUE S_TURF(12)
#define SMOOTH_GROUP_CARPET_CYAN S_TURF(13)
#define SMOOTH_GROUP_CARPET_GREEN S_TURF(14)
#define SMOOTH_GROUP_CARPET_ROYALBLACK S_TURF(15)
#define SMOOTH_GROUP_CARPET_ROYALBLUE S_TURF(16)
#define SMOOTH_GROUP_CARPET_RED S_TURF(17)
#define SMOOTH_GROUP_CARPET_ORANGE S_TURF(18)
#define SMOOTH_GROUP_CARPET_PURPLE S_TURF(19)
#define SMOOTH_GROUP_CARPET_GRIMEY S_TURF(20)

#define SMOOTH_GROUP_BAMBOO S_TURF(21)					///turf/simulated/floor/bamboo

#define SMOOTH_GROUP_SIMULATED_TURFS S_TURF(22)			///turf/simulated
#define SMOOTH_GROUP_MATERIAL_WALLS S_TURF(23)			///turf/simulated/wall/material
#define SMOOTH_GROUP_SYNDICATE_WALLS S_TURF(24)			///turf/simulated/wall/r_wall/syndicate, /turf/simulated/indestructible/syndicate
#define SMOOTH_GROUP_HOTEL_WALLS S_TURF(25)				///turf/simulated/indestructible/hotelwall
#define SMOOTH_GROUP_MINERAL_WALLS S_TURF(26)			///turf/simulated/mineral, /obj/structure/falsewall/rock_ancient
#define SMOOTH_GROUP_BOSS_WALLS S_TURF(27)				///turf/simulated/indestructible/riveted/boss
#define SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS S_TURF(28)	///turf/simulated/wall/mineral/titanium/survival

#define SMOOTH_GROUP_GRASS S_TURF(29)					///turf/simulated/floor/grass
#define SMOOTH_GROUP_JUNGLE_GRASS S_TURF(30)			///turf/simulated/floor/grass/jungle

#define MAX_S_TURF SMOOTH_GROUP_JUNGLE_GRASS //Always match this value with the one above it.


#define S_OBJ(num) (MAX_S_TURF + 1 + num)
/* /obj included */

#define SMOOTH_GROUP_WALLS S_OBJ(0)						///turf/simulated/wall, /obj/structure/falsewall
#define SMOOTH_GROUP_URANIUM_WALLS S_OBJ(1)				///turf/simulated/wall/mineral/uranium, /obj/structure/falsewall/uranium
#define SMOOTH_GROUP_GOLD_WALLS S_OBJ(2)				///turf/simulated/wall/mineral/gold, /obj/structure/falsewall/gold
#define SMOOTH_GROUP_SILVER_WALLS S_OBJ(3)				///turf/simulated/wall/mineral/silver, /obj/structure/falsewall/silver
#define SMOOTH_GROUP_DIAMOND_WALLS S_OBJ(4)				///turf/simulated/wall/mineral/diamond, /obj/structure/falsewall/diamond
#define SMOOTH_GROUP_PLASMA_WALLS S_OBJ(5)				///turf/simulated/wall/mineral/plasma, /obj/structure/falsewall/plasma
#define SMOOTH_GROUP_BANANIUM_WALLS S_OBJ(6)			///turf/simulated/wall/mineral/bananium, /obj/structure/falsewall/bananium
#define SMOOTH_GROUP_SANDSTONE_WALLS S_OBJ(7)			///turf/simulated/wall/mineral/sandstone, /obj/structure/falsewall/sandstone
#define SMOOTH_GROUP_WOOD_WALLS S_OBJ(8)				///turf/simulated/wall/mineral/wood, /obj/structure/falsewall/wood
#define SMOOTH_GROUP_IRON_WALLS S_OBJ(9)				///turf/simulated/wall/mineral/iron, /obj/structure/falsewall/iron
#define SMOOTH_GROUP_ABDUCTOR_WALLS S_OBJ(10)			///turf/simulated/wall/mineral/abductor, /obj/structure/falsewall/abductor
#define SMOOTH_GROUP_TITANIUM_WALLS S_OBJ(11)			///turf/simulated/wall/mineral/titanium, /obj/structure/falsewall/titanium
#define SMOOTH_GROUP_ASTEROID_WALLS S_OBJ(12)			///turf/simulated/mineral, /obj/structure/falsewall/rock_ancient
#define SMOOTH_GROUP_PLASTITANIUM_WALLS S_OBJ(13)		///turf/simulated/wall/mineral/plastitanium, /obj/structure/falsewall/plastitanium
#define SMOOTH_GROUP_SURVIVAL_TIANIUM_POD S_OBJ(14)		///turf/simulated/wall/mineral/titanium/survival/pod, /obj/machinery/door/airlock/survival_pod, /obj/structure/window/shuttle/survival_pod
#define SMOOTH_GROUP_HIERO_WALL S_OBJ(15)				///obj/effect/temp_visual/elite_tumor_wall, /obj/effect/temp_visual/hierophant/wall
#define SMOOTH_GROUP_BRASS_WALL S_OBJ(16)				///turf/simulated/wall/mineral/brass, /obj/structure/falsewall/brass
#define SMOOTH_GROUP_REGULAR_WALLS S_OBJ(17)			///turf/simulated/wall, /obj/structure/falsewall
#define SMOOTH_GROUP_REINFORCED_WALLS S_OBJ(18)			///turf/simulated/wall/r_wall, /obj/structure/falsewall/reinforced
#define SMOOTH_GROUP_CULT_WALLS S_OBJ(19)				///turf/simulated/wall/cult
#define SMOOTH_GROUP_BACKROOMS_WALLS S_OBJ(20)			///turf/simulated/wall/backrooms, /obj/structure/falsewall/backrooms

#define SMOOTH_GROUP_WINDOW_FULLTILE S_OBJ(21)			///turf/simulated/indestructible/fakeglass, /obj/structure/window/full/basic, /obj/structure/window/full/plasmabasic, /obj/structure/window/full/plasmareinforced, /obj/structure/window/full/reinforced
#define SMOOTH_GROUP_WINDOW_FULLTILE_BRASS S_OBJ(22)	///obj/structure/window/brass/fulltile
#define SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM S_OBJ(23)	///turf/simulated/indestructible/opsglass, /obj/structure/window/plasma/reinforced/plastitanium
#define SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE S_OBJ(24)	///obj/structure/window/shuttle

#define SMOOTH_GROUP_LATTICE  S_OBJ(30)					///obj/structure/lattice

#define SMOOTH_GROUP_AIRLOCK S_OBJ(40)					///obj/machinery/door/airlock

#define SMOOTH_GROUP_TABLES S_OBJ(50)					///obj/structure/table
#define SMOOTH_GROUP_WOOD_TABLES S_OBJ(51)				///obj/structure/table/wood
#define SMOOTH_GROUP_FANCY_WOOD_TABLES S_OBJ(52)		///obj/structure/table/wood/fancy
#define SMOOTH_GROUP_BRASS_TABLES S_OBJ(53)				///obj/structure/table/brass
#define SMOOTH_GROUP_ABDUCTOR_TABLES S_OBJ(54)			///obj/structure/table/abductor
#define SMOOTH_GROUP_GLASS_TABLES S_OBJ(55)				///obj/structure/table/glass
#define SMOOTH_GROUP_REINFORCED_TABLES S_OBJ(56)		///obj/structure/table/reinforced, /obj/structure/table/glass/reinforced
#define SMOOTH_GROUP_CULT_TABLES S_OBJ(57)				///obj/structire/table/reinforced/cult

#define SMOOTH_GROUP_ALIEN_RESIN S_OBJ(60)				///obj/structure/alien/resin
#define SMOOTH_GROUP_ALIEN_WALLS S_OBJ(61)				///obj/structure/alien/resin/wall,
#define SMOOTH_GROUP_ALIEN_WEEDS S_OBJ(62)				///obj/structure/alien/weeds

#define SMOOTH_GROUP_SECURITY_BARRICADE S_OBJ(63)		///obj/structure/barricade/security
#define SMOOTH_GROUP_SANDBAGS S_OBJ(64)					///obj/structure/barricade/sandbags

#define SMOOTH_GROUP_SHUTTLE_PARTS S_OBJ(66)			///obj/structure/window/shuttle, /obj/structure/window/plasma/reinforced/plastitanium, /turf/simulated/indestructible/opsglass, /obj/structure/shuttle

#define SMOOTH_GROUP_CLEANABLE_DIRT	S_OBJ(67)			///obj/effect/decal/cleanable/dirt

#define SMOOTH_GROUP_RIPPLE	S_OBJ(68)					///obj/effect/temp_visual/ripple

#define SMOOTH_GROUP_CATWALK S_OBJ(69)					///obj/structure/lattice/catwalk
