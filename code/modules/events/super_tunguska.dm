#define ARRIVAL_MIN 210
#define ARRIVAL_MAX 300

/datum/event/super_tunguska
	nominal_severity = EVENT_LEVEL_MAJOR
	role_weights = list(ASSIGNMENT_ENGINEERING = 4)
	role_requirements = list(ASSIGNMENT_ENGINEERING = 5)
	/// The variant of super tunguska that is about to hit the station
	var/datum/super_tunguska_variant/variant
	/// When the super tunguska will spawn at the station Z level
	var/arrival_time

/datum/event/super_tunguska/setup()
	variant = subtypesof(variant.type) new()
	// 7 to 10 minutes
	arrival_time = rand(ARRIVAL_MIN, ARRIVAL_MAX)

/datum/event/super_tunguska/announce(false_alarm)
	variant.announce(arrival_time)

/datum/event/super_tunguska/tick()
	if(arrival_time > activefor)
		variant.launch()

#undef ARRIVAL_MIN
#undef ARRIVAL_MAX


/datum/super_tunguska_variant
	meteor_type = /obj/effect/meteor/super_tunguska
