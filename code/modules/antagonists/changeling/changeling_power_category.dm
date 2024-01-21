/datum/changeling_power_category
	/// The name of the category
	var/name = "common"
	/// The number used to determine category position in changeling evolution menu UI
	var/priority = 0

/datum/changeling_power_category/offence
	name = "Offence"
	priority = 1

/datum/changeling_power_category/defence
	name = "Defence"
	priority = 2

/datum/changeling_power_category/utility
	name = "Utility"
	priority = 3

/datum/changeling_power_category/stings
	name = "Stings"
	priority = 4
