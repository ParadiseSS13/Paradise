/* Different misc types of tiles
 * Contains:
 *		Grass
 *		Wood
 *		Carpet
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

/*
 * Carpets
 */
/obj/item/stack/tile/carpet
	name = "carpet"
	singular_name = "carpet"
	desc = "A piece of carpet. It is the same size as a floor tile"
	icon_state = "tile-carpet"
	turf_type = /turf/simulated/floor/carpet

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