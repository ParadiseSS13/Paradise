/datum/map_template/ruin
	//name = "A Chest of Doubloons"
	name = null
	var/id = null // For blacklisting purposes, all ruins need an id
	var/description = "In the middle of a clearing in the rockface, there's a \
		chest filled with gold coins with Spanish engravings. How is there a \
		wooden container filled with 18th century coinage in the middle of a \
		lavawracked hellscape? It is clearly a mystery."

	/// Prevents megafauna spawning within a certain range of ruins.
	var/megafauna_safe_range = FALSE
	var/unpickable = FALSE 	 //If TRUE these won't be placed automatically (can still be forced or loaded with another ruin)
	var/always_place = FALSE //Will skip the whole weighting process and just plop this down, ideally you want the ruins of this kind to have no cost.
	var/placement_weight = 1 //How often should this ruin appear
	var/allow_duplicates = TRUE
	var/list/never_spawn_with = null //If this ruin is spawned these will not eg list(/datum/map_template/ruin/base_alternate)

	/// If a ruin ID is in this list, this ruin will not spawn on the same level as that ruin.
	var/list/never_spawn_on_the_same_level = list()

	var/prefix = null
	var/suffix = null

/datum/map_template/ruin/New()
	if(!name && id)
		name = id

	mappath = prefix + suffix
	..(path = mappath)

/// The cost of a ruin is the square root of the product of its dimensions.
/// This encodes the size of the ruin relative to each other without the
/// numbers getting ridiculous.
/datum/map_template/ruin/proc/get_cost()
	if(!width || !height)
		CRASH("cost of [name]/[suffix] requested before loaded size")

	return floor(sqrt(width * height))
