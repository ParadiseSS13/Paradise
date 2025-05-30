
GLOBAL_LIST_INIT(body_accessory_by_name, list("None" = null))
GLOBAL_LIST_EMPTY(body_accessory_by_species)

/proc/initialize_body_accessory_by_species()
	for(var/B in GLOB.body_accessory_by_name)
		var/datum/body_accessory/accessory = GLOB.body_accessory_by_name[B]
		if(!istype(accessory))	continue

		for(var/species in accessory.allowed_species)
			if(!GLOB.body_accessory_by_species["[species]"])
				GLOB.body_accessory_by_species["[species]"] = list()
			GLOB.body_accessory_by_species["[species]"]["[accessory.name]"] = accessory

	if(length(GLOB.body_accessory_by_species))
		return TRUE
	return FALSE

/proc/__init_body_accessory(ba_path)
	if(ispath(ba_path))
		var/_added_counter = 0

		for(var/A in subtypesof(ba_path))
			var/datum/body_accessory/B = new A
			if(istype(B))
				GLOB.body_accessory_by_name[B.name] += B
				++_added_counter

		if(_added_counter)
			return TRUE
	return FALSE

/datum/body_accessory
	var/name = "default"

	var/icon = null
	var/icon_state = ""

	var/animated_icon = null
	var/animated_icon_state = ""

	var/blend_mode = null

	var/pixel_x_offset = 0
	var/pixel_y_offset = 0

	var/list/allowed_species = list()

	/// If true, adds an underlay (in addition to the regular overlay!) to the character sprite, with the state "[icon_state]_BEHIND".
	var/has_behind = FALSE

/datum/body_accessory/proc/try_restrictions(mob/living/carbon/human/H)
	return (H.dna.species.name in allowed_species)

/datum/body_accessory/proc/get_animated_icon() //return animated if it has it, return static if it does not.
	if(animated_icon)
		return animated_icon

	else	return icon

/datum/body_accessory/proc/get_animated_icon_state()
	if(animated_icon_state)
		return animated_icon_state

	else	return icon_state


//Bodies
/datum/body_accessory/body
	blend_mode = ICON_MULTIPLY

//Tails
/datum/body_accessory/tail
	icon = 'icons/mob/body_accessory.dmi'
	animated_icon = 'icons/mob/body_accessory.dmi'
	blend_mode = ICON_ADD
	icon_state = "null"
	animated_icon_state = "null"

/datum/body_accessory/tail/try_restrictions(mob/living/carbon/human/H)
	if(H.wear_suit && (H.wear_suit.flags_inv & HIDETAIL))
		return FALSE
	return ..()

//Tajaran
/// Jay wingler fluff tail
/datum/body_accessory/tail/wingler_tail
	name = "Striped Tail"
	icon_state = "winglertail"
	animated_icon_state = "winglertail_a"
	allowed_species = list("Tajaran")

/// Pretty ambiguous as to what species it belongs to, tail could've been injured or docked.
/datum/body_accessory/tail/tiny
	name = "Tiny Tail"
	icon_state = "tiny"
	animated_icon_state = "tiny_a"
	allowed_species = list("Vulpkanin", "Tajaran")

/// Same as above.
/datum/body_accessory/tail/short
	name = "Short Tail"
	icon_state = "short"
	animated_icon_state = "short_a"
	allowed_species = list("Vulpkanin", "Tajaran")

//Vulpkanin
/datum/body_accessory/tail/bushy
	name = "Bushy Tail"
	icon_state = "bushy"
	animated_icon_state = "bushy_a"
	allowed_species = list("Vulpkanin")

/datum/body_accessory/tail/straight
	name = "Straight Tail"
	icon_state = "straight"
	animated_icon_state = "straight_a"
	allowed_species = list("Vulpkanin")

/datum/body_accessory/tail/straight_bushy
	name = "Straight Bushy Tail"
	icon_state = "straightbushy"
	animated_icon_state = "straightbushy_a"
	allowed_species = list("Vulpkanin")

// Skrell
/datum/body_accessory/tail/skrell_short
	name = "Short Skrell Tail"
	icon_state = "skrell_tail_short"
	allowed_species = list("Skrell")

/datum/body_accessory/tail/skrell
	name = "Skrell Tail"
	icon_state = "skrell_tail"
	allowed_species = list("Skrell")

/datum/body_accessory/tail/skrell_long
	name = "Long Skrell Tail"
	icon_state = "skrell_tail_long"
	allowed_species = list("Skrell")

/datum/body_accessory/tail/skrell_xlong
	name = "Extra Long Skrell Tail"
	icon_state = "skrell_tail_xlong"
	allowed_species = list("Skrell")

/datum/body_accessory/tail/skrell_short_fringed
	name = "Short Fringed Skrell Tail"
	icon_state = "skrell_fringetail_short"
	allowed_species = list("Skrell")

/datum/body_accessory/tail/skrell_fringed
	name = "Fringed Skrell Tail"
	icon_state = "skrell_fringetail"
	allowed_species = list("Skrell")

/datum/body_accessory/tail/skrell_long_fringed
	name = "Long Fringed Skrell Tail"
	icon_state = "skrell_fringetail_long"
	allowed_species = list("Skrell")

/datum/body_accessory/tail/skrell_xlong_fringed
	name = "Extra Long Fringed Skrell Tail"
	icon_state = "skrell_fringetail_xlong"
	allowed_species = list("Skrell")

//Moth wings
/datum/body_accessory/wing
	icon = 'icons/mob/sprite_accessories/moth/moth_wings.dmi'
	animated_icon = null
	name = "Plain Wings"
	icon_state = "plain"
	allowed_species = list("Nian")
	has_behind = TRUE

/datum/body_accessory/wing/plain

/datum/body_accessory/wing/monarch
	name = "Monarch Wings"
	icon_state = "monarch"

/datum/body_accessory/wing/luna
	name = "Luna Wings"
	icon_state = "luna"

/datum/body_accessory/wing/atlas
	name = "Atlas Wings"
	icon_state = "atlas"

/datum/body_accessory/wing/reddish
	name = "Reddish Wings"
	icon_state = "redish"

/datum/body_accessory/wing/royal
	name = "Royal Wings"
	icon_state = "royal"

/datum/body_accessory/wing/gothic
	name = "Gothic Wings"
	icon_state = "gothic"

/datum/body_accessory/wing/lovers
	name = "Lovers Wings"
	icon_state = "lovers"

/datum/body_accessory/wing/whitefly
	name = "White Fly Wings"
	icon_state = "whitefly"

/datum/body_accessory/wing/burnt_off
	name = "Burnt Off Wings"
	icon_state = "burnt_off"

/datum/body_accessory/wing/firewatch
	name = "Firewatch Wings"
	icon_state = "firewatch"

/datum/body_accessory/wing/deathhead
	name = "Deathshead Wings"
	icon_state = "deathhead"

/datum/body_accessory/wing/poison
	name = "Poison Wings"
	icon_state = "poison"

/datum/body_accessory/wing/ragged
	name = "Ragged Wings"
	icon_state = "ragged"

/datum/body_accessory/wing/moonfly
	name = "Moon Fly Wings"
	icon_state = "moonfly"

/datum/body_accessory/wing/snow
	name = "Snow Wings"
	icon_state = "snow"

/datum/body_accessory/wing/oakworm
	name = "Oak Worm Wings"
	icon_state = "oakworm"

/datum/body_accessory/wing/jungle
	name = "Jungle Wings"
	icon_state = "jungle"

/datum/body_accessory/wing/witchwing
	name = "Witch Wing Wings"
	icon_state = "witchwing"

/datum/body_accessory/wing/lightbearer
	name = "Lightbearer Wings"
	icon_state = "lightbearer"

/datum/body_accessory/wing/rosy
	name = "Rosy Wings"
	icon_state = "rosy"

/datum/body_accessory/wing/feathery
	name = "Feathery Wings"
	icon_state = "feathery"

/datum/body_accessory/wing/brown
	name = "Brown Wings"
	icon_state = "brown"

/datum/body_accessory/wing/plasmafire
	name = "Plasmafire Wings"
	icon_state = "plasmafire"

/datum/body_accessory/wing/mothra
	name = "Mothra Wings"
	icon_state = "mothra"

/datum/body_accessory/wing/bluespace
	name = "Bluespace Wings"
	icon_state = "bluespace"
