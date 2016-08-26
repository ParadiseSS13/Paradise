/* Different misc types of tiles
 * Contains:
 *		Grass
 *		Wood
 *		Carpet
 *		Plasteel
 *		Light
 *		Fakespace
 *		High-traction
 \\ If you don't update the contains list, I'm going to shank you
 */
/obj/item/stack/tile
	name = "broken tile"
	singular_name = "broken tile"
	desc = "A broken tile. This should not exist."
	icon = 'icons/obj/items.dmi'
	icon_state = "tile"
	item_state = "tile"
	w_class = 3
	force = 1
	throwforce = 1
	throw_speed = 5
	throw_range = 20
	max_amount = 60
	flags = CONDUCT
	var/turf_type = null
	var/mineralType = null

/*
 * Grass
 */
/obj/item/stack/tile/grass
	name = "grass tiles"
	gender = PLURAL
	singular_name = "grass floor tile"
	desc = "A patch of grass like they often use on golf courses"
	icon_state = "tile_grass"
	origin_tech = "biotech=1"
	turf_type = /turf/simulated/floor/grass
	burn_state = FLAMMABLE

/*
 * Wood
 */
/obj/item/stack/tile/wood
	name = "wood floor tiles"
	gender = PLURAL
	singular_name = "wood floor tile"
	desc = "an easy to fit wood floor tile"
	icon_state = "tile-wood"
	turf_type = /turf/simulated/floor/wood
	burn_state = FLAMMABLE

/*
 * Carpets
 */
/obj/item/stack/tile/carpet
	name = "carpet"
	singular_name = "carpet"
	desc = "A piece of carpet. It is the same size as a floor tile"
	icon_state = "tile-carpet"
	turf_type = /turf/simulated/floor/carpet
	burn_state = FLAMMABLE

/*
 * Plasteel
 */
/obj/item/stack/tile/plasteel
	name = "floor tiles"
	gender = PLURAL
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon."
	icon_state = "tile"
	force = 6
	materials = list(MAT_METAL=500)
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	turf_type = /turf/simulated/floor/plasteel
	mineralType = "metal"

/*
 * Light
 */
/obj/item/stack/tile/light
	name = "light tiles"
	gender = PLURAL
	singular_name = "light floor tile"
	desc = "A floor tile, made out off glass. Use a multitool on it to change its color."
	icon_state = "tile_light blue"
	force = 3
	throwforce = 5
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	turf_type = /turf/simulated/floor/light

/*
 * Fakespace
 */
/obj/item/stack/tile/fakespace
	name = "astral carpet"
	singular_name = "astral carpet"
	desc = "A piece of carpet with a convincing star pattern."
	icon_state = "tile_space"
	turf_type = /turf/simulated/floor/fakespace
	burn_state = FLAMMABLE

/obj/item/stack/tile/fakespace/loaded
	amount = 30

//High-traction
/obj/item/stack/tile/noslip
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip"
	turf_type = /turf/simulated/floor/noslip
	origin_tech = "materials=3"

/obj/item/stack/tile/noslip/loaded
	amount = 20

/obj/item/stack/tile/silent
	name = "silent tile"
	singular_name = "silent floor tile"
	desc = "A tile made out of tranquillite, SHHHHHHHHH!"
	icon_state = "tile-silent"
	origin_tech = "materials=1"
	turf_type = /turf/simulated/floor/silent
	mineralType = "tranquillite"
	materials = list(MAT_TRANQUILLITE=500)

//Pod floor
/obj/item/stack/tile/pod
	name = "pod floor tile"
	singular_name = "pod floor tile"
	desc = "A grooved floor tile."
	icon_state = "tile_pod"
	turf_type = /turf/simulated/floor/pod