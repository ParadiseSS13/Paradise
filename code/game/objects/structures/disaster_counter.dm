/**
  * # Disaster counter.
  *
  * Tracks how many shifts it has been since the counter with that ID was exploded.
  */
/obj/structure/disaster_counter
	name = "disaster counter"
	desc = "This magical device will count up how many shifts it has been since a major disaster in this area."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	maptext_y = 10 // Offset by 10 so it renders properly
	/// ID of the counter. Must be overriden
	var/counter_id
	/// Current count number
	var/current_count = 0

/obj/structure/disaster_counter/examine(mob/user)
	. = ..()
	. += "The display reads 'Currently [current_count] shifts without an accident!'"

/obj/structure/disaster_counter/Initialize(mapload)
	. = ..()
	if(!counter_id)
		stack_trace("Disaster counter at [x],[y],[z] does not have a counter_id set. Deleting...")
		return INITIALIZE_HINT_QDEL

	// If we still exist, put ourselves in
	SSpersistent_data.register(src)

/obj/structure/disaster_counter/ex_act(severity)
	if(severity < 2)
		current_count = -1
		persistent_save()
	. = ..()

/obj/structure/disaster_counter/Destroy()
	if(counter_id)
		SSpersistent_data.registered_atoms -= src // Take us out the list
	return ..()

/obj/structure/disaster_counter/persistent_load()
	// Just incase some bad actor sets the counter ID to "../../../../Windows/System32"
	// Yes I am that paranoid
	if(counter_id != paranoid_sanitize(counter_id))
		stack_trace("Counter ID did not pass sanitization for disaster counter at [x],[y],[z]. Potential attempt at filesystem manipulation.")
		qdel(src)

	var/savefile/S = new /savefile("data/disaster_counters/[counter_id].sav")
	S["count"] >> current_count

	if(isnull(current_count))
		current_count = 0
	else
		current_count++ // Increase by 1 since this is the next shift without a disaster (yet)
	log_debug("Persistent data for [src] loaded (current_count: [current_count])")
	maptext = "<span class='maptext' style='text-align: center'>[current_count]</span>"

/obj/structure/disaster_counter/persistent_save()
	if(counter_id != paranoid_sanitize(counter_id))
		stack_trace("Counter ID did not pass sanitization for disaster counter at [x],[y],[z]. Potential attempt at filesystem manipulation.")
		qdel(src)

	var/savefile/S = new /savefile("data/disaster_counters/[counter_id].sav")

	S["count"] << current_count
	log_debug("Persistent data for [src] saved (current_count: [current_count])")

// Prefab definitions to make mapping easier
/obj/structure/disaster_counter/supermatter
	name = "supermatter disaster counter"
	counter_id = "supermatter"

/obj/structure/disaster_counter/chemistry
	name = "chemistry disaster counter"
	counter_id = "chemistry"
