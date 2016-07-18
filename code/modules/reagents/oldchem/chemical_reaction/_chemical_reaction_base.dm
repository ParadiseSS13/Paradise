///////////////////////////////////////////////////////////////////////////////////
/datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	var/list/required_reagents = list()
	var/list/required_catalysts = list()

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/atom/required_container = null // the container required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/result_amount = 0
	var/secondary = 0 // set to nonzero if secondary reaction
	var/list/secondary_results = list()		//additional reagents produced by the reaction
	var/min_temp = 0		//Minimum temperature required for the reaction to occur (heat to/above this). min_temp = 0 means no requirement
	var/max_temp = 9999		//Maximum temperature allowed for the reaction to occur (cool to/below this).
	var/mix_message = "The solution begins to bubble."
	var/mix_sound = 'sound/effects/bubbles.ogg'
	var/no_message = 0

/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return