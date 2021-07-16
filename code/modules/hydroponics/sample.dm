GLOBAL_LIST_INIT(chem_t1_reagents, list(
	/datum/reagent/hydrogen, /datum/reagent/oxygen, /datum/reagent/silicon,
	/datum/reagent/phosphorus, /datum/reagent/sulfur, /datum/reagent/carbon,
	/datum/reagent/nitrogen, /datum/reagent/water
))

GLOBAL_LIST_INIT(chem_t2_reagents, list(
	/datum/reagent/lithium, /datum/reagent/copper, /datum/reagent/mercury,
	/datum/reagent/sodium, /datum/reagent/iodine, /datum/reagent/bromine
)) // "sugar", "sacid" removed because they are already in roundstart plants

GLOBAL_LIST_INIT(chem_t3_reagents, list(
	/datum/reagent/consumable/ethanol, /datum/reagent/chlorine, /datum/reagent/potassium,
	/datum/reagent/aluminum, /datum/reagent/radium, /datum/reagent/fluorine,
	/datum/reagent/iron, /datum/reagent/fuel, /datum/reagent/silver,
	"stable_plasma"
))

GLOBAL_LIST_INIT(chem_t4_reagents, list(
	/datum/reagent/oil, /datum/reagent/ash, /datum/reagent/acetone,
	/datum/reagent/saltpetre, /datum/reagent/ammonia, /datum/reagent/diethylamine
))

/obj/item/seeds/sample
	name = "plant sample"
	icon_state = "sample-empty"
	potency = -1
	yield = -1
	var/sample_color = "#FFFFFF"

/obj/item/seeds/sample/New()
	..()
	if(sample_color)
		var/image/I = image(icon, icon_state = "sample-filling")
		I.color = sample_color
		overlays += I

/obj/item/seeds/sample/get_analyzer_text()
	return " The DNA of this sample is damaged beyond recovery, it can't support life on it's own.\n*---------*"

/obj/item/seeds/sample/alienweed
	name = "alien weed sample"
	icon_state = "alienweed"
	sample_color = null
