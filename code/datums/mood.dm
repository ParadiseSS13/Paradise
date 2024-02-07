#define MINOR_INSANITY_PEN 25
#define MAJOR_INSANITY_PEN 50
#define MOOD_CATEGORY_NUTRITION "nutrition"
#define MOOD_CATEGORY_AREA_BEAUTY "area_beauty"

/**
 * Mood datum
 *
 * Contains the logic for controlling a living mob's mood and sanity.
 */
/datum/mood
	/// The parent (living) mob
	var/mob/living/mob_parent

	/// The total combined value of all moodlets for the mob
	var/mood
	/// Current sanity of the mob (ranges from 0 - 150)
	var/sanity = SANITY_NEUTRAL
	/// the total combined value of all visible moodlets for the mob
	var/shown_mood
	/// Moodlet value modifier
	var/mood_modifier = 1
	/// Used to track what stage of moodies they're on (1-9)
	var/mood_level = MOOD_LEVEL_NEUTRAL
	/// To track what stage of sanity they're on (1-6)
	var/sanity_level = SANITY_LEVEL_NEUTRAL
	/// Is the owner being punished for low mood? if so, how much?
	var/insanity_effect = 0
	/// The screen object for the current mood level
	var/obj/screen/mood/mood_screen_object

	/// List of mood events currently active on this datum
	var/list/mood_events = list()

	/// Tracks the last mob stat, updates on change
	/// Used to stop processing SSmood
	var/last_stat = CONSCIOUS

/datum/mood/New(mob/living/mob_to_make_moody)
	if (!istype(mob_to_make_moody))
		stack_trace("Tried to apply mood to a non-living atom!")
		qdel(src)
		return

	START_PROCESSING(SSmood, src)

	mob_parent = mob_to_make_moody

	RegisterSignal(mob_to_make_moody, COMSIG_MOB_HUD_CREATED, PROC_REF(modify_hud))
	RegisterSignal(mob_to_make_moody, COMSIG_AREA_ENTERED, PROC_REF(check_area_mood))
	RegisterSignal(mob_to_make_moody, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	RegisterSignal(mob_to_make_moody, COMSIG_MOB_STATCHANGE, PROC_REF(handle_mob_death))
	RegisterSignal(mob_to_make_moody, COMSIG_PARENT_QDELETING, PROC_REF(clear_parent_ref))

	if(mob_to_make_moody.hud_used)
		modify_hud()
		var/datum/hud/hud = mob_to_make_moody.hud_used
		hud.show_hud(hud.hud_version)

/datum/mood/proc/clear_parent_ref()
	SIGNAL_HANDLER

	unmodify_hud()
	UnregisterSignal(mob_parent, list(COMSIG_MOB_HUD_CREATED, COMSIG_AREA_ENTERED, COMSIG_LIVING_REVIVE, COMSIG_MOB_STATCHANGE, COMSIG_PARENT_QDELETING))

	mob_parent = null

/datum/mood/Destroy(force)
	STOP_PROCESSING(SSmood, src)
	QDEL_LIST_ASSOC_VAL(mood_events)
	return ..()

/datum/mood/process(seconds_per_tick)
	switch(mood_level)
		if(MOOD_LEVEL_SAD4)
			set_sanity(sanity - 0.3 * seconds_per_tick, SANITY_INSANE)
		if(MOOD_LEVEL_SAD3)
			set_sanity(sanity - 0.15 * seconds_per_tick, SANITY_INSANE)
		if(MOOD_LEVEL_SAD2)
			set_sanity(sanity - 0.1 * seconds_per_tick, SANITY_CRAZY)
		if(MOOD_LEVEL_SAD1)
			set_sanity(sanity - 0.05 * seconds_per_tick, SANITY_UNSTABLE)
		if(MOOD_LEVEL_NEUTRAL)
			set_sanity(sanity, SANITY_UNSTABLE) //This makes sure that mood gets increased should you be below the minimum.
		if(MOOD_LEVEL_HAPPY1)
			set_sanity(sanity + 0.2 * seconds_per_tick, SANITY_UNSTABLE)
		if(MOOD_LEVEL_HAPPY2)
			set_sanity(sanity + 0.3 * seconds_per_tick, SANITY_UNSTABLE)
		if(MOOD_LEVEL_HAPPY3)
			set_sanity(sanity + 0.4 * seconds_per_tick, SANITY_NEUTRAL, SANITY_MAXIMUM)
		if(MOOD_LEVEL_HAPPY4)
			set_sanity(sanity + 0.6 * seconds_per_tick, SANITY_NEUTRAL, SANITY_MAXIMUM)
	handle_nutrition()

/datum/mood/proc/handle_mob_death(datum/source)
	SIGNAL_HANDLER

	if(last_stat == DEAD && mob_parent.stat != DEAD)
		START_PROCESSING(SSmood, src)
	else if(last_stat != DEAD && mob_parent.stat == DEAD)
		STOP_PROCESSING(SSmood, src)
	last_stat = mob_parent.stat

/// Handles mood given by nutrition
/datum/mood/proc/handle_nutrition()
	if (HAS_TRAIT(mob_parent, TRAIT_NOHUNGER))
		clear_mood_event(MOOD_CATEGORY_NUTRITION)  // if you happen to switch species while hungry youre no longer hungy
		return FALSE // no moods for nutrition
	switch(mob_parent.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			add_mood_event(MOOD_CATEGORY_NUTRITION, /datum/mood_event/fat)
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			add_mood_event(MOOD_CATEGORY_NUTRITION, /datum/mood_event/wellfed)
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			add_mood_event(MOOD_CATEGORY_NUTRITION, /datum/mood_event/fed)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			clear_mood_event(MOOD_CATEGORY_NUTRITION)
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			add_mood_event(MOOD_CATEGORY_NUTRITION, /datum/mood_event/hungry)
		if(0 to NUTRITION_LEVEL_STARVING)
			add_mood_event(MOOD_CATEGORY_NUTRITION, /datum/mood_event/starving)

/**
 * Adds a mood event to the mob
 *
 * Arguments:
 * * category - (text) category of the mood event - see /datum/mood_event for category explanation
 * * type - (path) any /datum/mood_event
 */
/datum/mood/proc/add_mood_event(category, type, ...)
	// we may be passed an instantiated mood datum with a modified timeout
	// it is to be used as a vehicle to copy data from and then cleaned up afterwards.
	// why do it this way? because the params list may contain numbers, and we may not necessarily want those to be interpreted as a timeout modifier.
	// this is only used by the food quality system currently
	var/datum/mood_event/mood_to_copy_from
	if (istype(type, /datum/mood_event))
		mood_to_copy_from = type
		type = mood_to_copy_from.type
	if (!ispath(type, /datum/mood_event))
		CRASH("A non path ([type]), was used to add a mood event. This shouldn't be happening.")
	if (!istext(category))
		category = "\ref[category]"

	var/datum/mood_event/the_event
	if (mood_events[category])
		the_event = mood_events[category]
		if (the_event.type != type)
			clear_mood_event(category)
		else
			if (the_event.timeout)
				if (!isnull(mood_to_copy_from))
					the_event.timeout = mood_to_copy_from.timeout
				addtimer(CALLBACK(src, PROC_REF(clear_mood_event), category), the_event.timeout, (TIMER_UNIQUE|TIMER_OVERRIDE))
			qdel(mood_to_copy_from)
			return // Don't need to update the event.
	var/list/params = args.Copy(3)

	params.Insert(1, mob_parent)
	the_event = new type(arglist(params))
	if (QDELETED(the_event)) // the mood event has been deleted for whatever reason (requires a job, etc)
		return

	the_event.category = category
	if(!isnull(mood_to_copy_from))
		the_event.timeout = mood_to_copy_from.timeout
	qdel(mood_to_copy_from)
	mood_events[category] = the_event
	update_mood()

	if(the_event.timeout)
		addtimer(CALLBACK(src, PROC_REF(clear_mood_event), category), the_event.timeout, (TIMER_UNIQUE|TIMER_OVERRIDE))

/**
 * Removes a mood event from the mob
 *
 * Arguments:
 * * category - (Text) Removes the mood event with the given category
 */
/datum/mood/proc/clear_mood_event(category)
	if(!istext(category))
		category = "\ref[category]"

	var/datum/mood_event/event = mood_events[category]
	if (!event)
		return

	mood_events -= category
	qdel(event)
	update_mood()

/// Updates the mobs mood.
/// Called after mood events have been added/removed.
/datum/mood/proc/update_mood()
	if(QDELETED(mob_parent)) //don't bother updating their mood if they're about to be salty anyway. (in other words, we're about to be destroyed too anyway.)
		return
	mood = 0
	shown_mood = 0

	SEND_SIGNAL(mob_parent, COMSIG_CARBON_MOOD_UPDATE)

	for(var/category in mood_events)
		var/datum/mood_event/the_event = mood_events[category]
		mood += the_event.mood_change
		if (!the_event.hidden)
			shown_mood += the_event.mood_change
	mood *= mood_modifier
	shown_mood *= mood_modifier

	switch(mood)
		if (-INFINITY to MOOD_SAD4)
			mood_level = MOOD_LEVEL_SAD4
		if (MOOD_SAD4 to MOOD_SAD3)
			mood_level = MOOD_LEVEL_SAD3
		if (MOOD_SAD3 to MOOD_SAD2)
			mood_level = MOOD_LEVEL_SAD2
		if (MOOD_SAD2 to MOOD_SAD1)
			mood_level = MOOD_LEVEL_SAD1
		if (MOOD_SAD1 to MOOD_HAPPY1)
			mood_level = MOOD_LEVEL_NEUTRAL
		if (MOOD_HAPPY1 to MOOD_HAPPY2)
			mood_level = MOOD_LEVEL_HAPPY1
		if (MOOD_HAPPY2 to MOOD_HAPPY3)
			mood_level = MOOD_LEVEL_HAPPY2
		if (MOOD_HAPPY3 to MOOD_HAPPY4)
			mood_level = MOOD_LEVEL_HAPPY3
		if (MOOD_HAPPY4 to INFINITY)
			mood_level = MOOD_LEVEL_HAPPY4

	update_mood_icon()

/// Updates the mob's mood icon
/datum/mood/proc/update_mood_icon()
	if (!(mob_parent.client || mob_parent.hud_used))
		return
	if(isnull(mood_screen_object))
		return
	mood_screen_object.cut_overlays()
	mood_screen_object.color = initial(mood_screen_object.color)

	// lets see if we have an special icons to show instead of the normal mood levels
	var/list/conflicting_moodies = list()
	var/highest_absolute_mood = 0
	for (var/category in mood_events)
		var/datum/mood_event/the_event = mood_events[category]
		if (!the_event.special_screen_obj)
			continue
		if (!the_event.special_screen_replace)
			mood_screen_object.add_overlay(the_event.special_screen_obj)
		else
			conflicting_moodies += the_event
			var/absmood = abs(the_event.mood_change)
			highest_absolute_mood = absmood > highest_absolute_mood ? absmood : highest_absolute_mood

	switch(sanity_level)
		if (SANITY_LEVEL_GREAT)
			mood_screen_object.color = "#2eeb9a"
		if (SANITY_LEVEL_NEUTRAL)
			mood_screen_object.color = "#86d656"
		if (SANITY_LEVEL_DISTURBED)
			mood_screen_object.color = "#4b96c4"
		if (SANITY_LEVEL_UNSTABLE)
			mood_screen_object.color = "#dfa65b"
		if (SANITY_LEVEL_CRAZY)
			mood_screen_object.color = "#f38943"
		if (SANITY_LEVEL_INSANE)
			mood_screen_object.color = "#f15d36"

	if (!conflicting_moodies.len) // theres no special icons, use the normal icon states
		mood_screen_object.icon_state = "mood[mood_level]"
		return

	for (var/datum/mood_event/conflicting_event as anything in conflicting_moodies)
		if (abs(conflicting_event.mood_change) == highest_absolute_mood)
			mood_screen_object.icon_state = "[conflicting_event.special_screen_obj]"
			break

/// Sets up the mood HUD object
/datum/mood/proc/modify_hud(datum/source)
	SIGNAL_HANDLER

	var/datum/hud/hud = mob_parent.hud_used
	mood_screen_object = new
	mood_screen_object.color = "#4b96c4"
	hud.infodisplay += mood_screen_object
	RegisterSignal(hud, COMSIG_PARENT_QDELETING, PROC_REF(unmodify_hud))
	RegisterSignal(mood_screen_object, COMSIG_CLICK, PROC_REF(hud_click))

/// Removes the mood HUD object
/datum/mood/proc/unmodify_hud(datum/source)
	SIGNAL_HANDLER

	if(!mood_screen_object)
		return
	var/datum/hud/hud = mob_parent.hud_used
	if(hud?.infodisplay)
		hud.infodisplay -= mood_screen_object
	QDEL_NULL(mood_screen_object)

/// Handles clicking on the mood HUD object
/datum/mood/proc/hud_click(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER

	if(user != mob_parent)
		return
	print_mood(user)

/// Prints the users mood, sanity, and moodies to chat
/datum/mood/proc/print_mood(mob/user)
	var/list/msg = list()
	msg += "<span class='info'><EM>My current mental status:</EM></span>"
	msg += "<span class='notice'>My current sanity:</span>" //Long term
	switch(sanity)
		if(SANITY_GREAT to INFINITY)
			msg += "<span class='green'>My mind feels like a temple!</span>"
		if(SANITY_NEUTRAL to SANITY_GREAT)
			msg += "<span class='nicegreen'>I have been feeling great lately!</span>"
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			msg += "<span class='nicegreen'>I have felt quite decent lately.</span>"
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			msg += "<span class='warning'>I'm feeling a little bit unhinged...</span>"
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			msg += "<span class='warning'>I'm freaking out!!</span>"
		if(SANITY_INSANE to SANITY_CRAZY)
			msg += "<span class='boldwarning'>AHAHAHAHAHAHAHAHAHAH!!</span>"

	msg += "<span class='notice'>My current mood:</span>" //Short term
	switch(mood_level)
		if(MOOD_LEVEL_SAD4)
			msg += "<span class='boldwarning'>I wish I was dead!</span>"
		if(MOOD_LEVEL_SAD3)
			msg += "<span class='boldwarning'>I feel terrible...</span>"
		if(MOOD_LEVEL_SAD2)
			msg += "<span class='boldwarning'>I feel very upset.</span>"
		if(MOOD_LEVEL_SAD1)
			msg += "<span class='warning'>I'm a bit sad.</span>"
		if(MOOD_LEVEL_NEUTRAL)
			msg += "<span class='gray'>I'm alright.</span>"
		if(MOOD_LEVEL_HAPPY1)
			msg += "<span class='nicegreen'>I feel pretty okay.</span>"
		if(MOOD_LEVEL_HAPPY2)
			msg += "<span class='boldnicegreen'>I feel pretty good.</span>"
		if(MOOD_LEVEL_HAPPY3)
			msg += "<span class='boldnicegreen'>I feel amazing!</span>"
		if(MOOD_LEVEL_HAPPY4)
			msg += "<span class='boldnicegreen'>I love life!</span>"

	msg += "<span class='notice'>Moodlets:</span>"//All moodlets
	if(mood_events.len)
		for(var/category in mood_events)
			var/datum/mood_event/event = mood_events[category]
			switch(event.mood_change)
				if(-INFINITY to MOOD_SAD2)
					msg += "<span class='boldwarning'>[event.description]</span>"
				if(MOOD_SAD2 to MOOD_SAD1)
					msg += "<span class='warning'>[event.description]</span>"
				if(MOOD_SAD1 to MOOD_NEUTRAL)
					msg += "<span class='gray'>[event.description]</span>"
				if(MOOD_NEUTRAL to MOOD_HAPPY1)
					msg += "<span class='green>[event.description]</span>"
				if(MOOD_HAPPY1 to MOOD_HAPPY2)
					msg += "<span class='nicegreen'>[event.description]</span>"
				if(MOOD_HAPPY2 to INFINITY)
					msg += "<span class='boldnicegreen'>[event.description]</span>"
	else
		msg += "<span class='green>I don't have much of a reaction to anything right now.</span>"
	to_chat(user, chat_box_green(msg.Join("<br>")))

/// Updates the mob's moodies, if the area provides a mood bonus
/datum/mood/proc/check_area_mood(datum/source, area/new_area)
	SIGNAL_HANDLER

	update_beauty(new_area)
	if (new_area.mood_bonus && (!new_area.mood_trait || HAS_TRAIT(source, new_area.mood_trait)))
		add_mood_event("area", /datum/mood_event/area, new_area.mood_bonus, new_area.mood_message)
	else
		clear_mood_event("area")

/// Updates the mob's given beauty moodie, based on the area
/datum/mood/proc/update_beauty(area/area_to_beautify)
	if (area_to_beautify.outdoors) // if we're outside, we don't care
		clear_mood_event(MOOD_CATEGORY_AREA_BEAUTY)
		return

	switch(area_to_beautify.beauty)
		if(-INFINITY to BEAUTY_LEVEL_HORRID)
			if(is_species(mob_parent, /datum/species/vulpkanin))
				add_mood_event(MOOD_CATEGORY_AREA_BEAUTY, /datum/mood_event/vulpkanin_badroom)
				return
			switch(is_species(mob_parent, /datum/species/tajaran))
				if(1)
					add_mood_event(MOOD_CATEGORY_AREA_BEAUTY, /datum/mood_event/tajaran_horridroom)
				if(0)
					add_mood_event(MOOD_CATEGORY_AREA_BEAUTY, /datum/mood_event/horridroom)
		if(BEAUTY_LEVEL_BAD to BEAUTY_LEVEL_DECENT)
			if(is_species(mob_parent, /datum/species/vulpkanin))
				add_mood_event(MOOD_CATEGORY_AREA_BEAUTY, /datum/mood_event/vulpkanin_badroom)
				return
			else
				add_mood_event(MOOD_CATEGORY_AREA_BEAUTY, /datum/mood_event/badroom)
		if(BEAUTY_LEVEL_DECENT to BEAUTY_LEVEL_GOOD)
			add_mood_event(MOOD_CATEGORY_AREA_BEAUTY, /datum/mood_event/decentroom)
		if(BEAUTY_LEVEL_GOOD to BEAUTY_LEVEL_GREAT)
			if(is_species(mob_parent, /datum/species/vulpkanin))
				add_mood_event(MOOD_CATEGORY_AREA_BEAUTY, /datum/mood_event/decentroom)
				return
			else
				add_mood_event(MOOD_CATEGORY_AREA_BEAUTY, /datum/mood_event/goodroom)
		if(BEAUTY_LEVEL_GREAT to INFINITY)
			if(is_species(mob_parent, /datum/species/vulpkanin))
				add_mood_event(MOOD_CATEGORY_AREA_BEAUTY, /datum/mood_event/decentroom)
				return
			switch(is_species(mob_parent, /datum/species/tajaran))
				if(1)
					add_mood_event(MOOD_CATEGORY_AREA_BEAUTY, /datum/mood_event/tajaran_greatroom)
				if(0)
					add_mood_event(MOOD_CATEGORY_AREA_BEAUTY, /datum/mood_event/greatroom)

/// Called when parent is ahealed.
/datum/mood/proc/on_revive(datum/source, full_heal)
	SIGNAL_HANDLER

	if (!full_heal)
		return
	remove_temp_moods()
	set_sanity(initial(sanity), override = TRUE)

/// Sets sanity to the specified amount and applies effects.
/datum/mood/proc/set_sanity(amount, minimum = SANITY_INSANE, maximum = SANITY_GREAT, override = FALSE)
	// If we're out of the acceptable minimum-maximum range move back towards it in steps of 0.7
	// If the new amount would move towards the acceptable range faster then use it instead
	if(amount < minimum)
		amount += clamp(minimum - amount, 0, 0.7)
	if(amount == sanity) //Prevents stuff from flicking around.
		return
	sanity = min(amount, maximum)
	SEND_SIGNAL(mob_parent, COMSIG_CARBON_SANITY_UPDATE, amount)
	switch(sanity)
		if(SANITY_INSANE to SANITY_CRAZY)
			set_insanity_effect(MAJOR_INSANITY_PEN)
			ADD_TRAIT(mob_parent, TRAIT_MOOD_INSANE, "sanity_insane")
			REMOVE_TRAIT(mob_parent, TRAIT_MOOD_CRAZY, "sanity_crazy")
			sanity_level = SANITY_LEVEL_INSANE
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			set_insanity_effect(MINOR_INSANITY_PEN)
			REMOVE_TRAIT(mob_parent, TRAIT_MOOD_INSANE, "sanity_insane")
			ADD_TRAIT(mob_parent, TRAIT_MOOD_CRAZY, "sanity_crazy")
			REMOVE_TRAIT(mob_parent, TRAIT_MOOD_UNSTABLE, "sanity_unstable")
			sanity_level = SANITY_LEVEL_CRAZY
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			set_insanity_effect(0)
			REMOVE_TRAIT(mob_parent, TRAIT_MOOD_CRAZY, "sanity_crazy")
			ADD_TRAIT(mob_parent, TRAIT_MOOD_UNSTABLE, "sanity_unstable")
			REMOVE_TRAIT(mob_parent, TRAIT_MOOD_DISTURBED, "sanity_disturbed")
			sanity_level = SANITY_LEVEL_UNSTABLE
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			set_insanity_effect(0)
			REMOVE_TRAIT(mob_parent, TRAIT_MOOD_UNSTABLE, "sanity_unstable")
			ADD_TRAIT(mob_parent, TRAIT_MOOD_DISTURBED, "sanity_disturbed")
			REMOVE_TRAIT(mob_parent, TRAIT_MOOD_NEUTRAL, "sanity_neutral")
			sanity_level = SANITY_LEVEL_DISTURBED
		if(SANITY_NEUTRAL+1 to SANITY_GREAT+1) //shitty hack but +1 to prevent it from responding to super small differences
			set_insanity_effect(0)
			REMOVE_TRAIT(mob_parent, TRAIT_MOOD_DISTURBED, "sanity_disturbed")
			ADD_TRAIT(mob_parent, TRAIT_MOOD_NEUTRAL, "sanity_neutral")
			REMOVE_TRAIT(mob_parent, TRAIT_MOOD_GREAT, "sanity_great")
			sanity_level = SANITY_LEVEL_NEUTRAL
		if(SANITY_GREAT+1 to INFINITY)
			set_insanity_effect(0)
			REMOVE_TRAIT(mob_parent, TRAIT_MOOD_NEUTRAL, "sanity_neutral")
			ADD_TRAIT(mob_parent, TRAIT_MOOD_GREAT, "sanity_great")
			sanity_level = SANITY_LEVEL_GREAT

	update_mood_icon()

/// Sets the insanity effect on the mob
/datum/mood/proc/set_insanity_effect(newval)
	if (newval == insanity_effect)
		return
	mob_parent.maxHealth = (mob_parent.maxHealth - insanity_effect) + newval
	mob_parent.health = min(mob_parent.health, mob_parent.maxHealth)
	insanity_effect = newval

/// Removes all temporary moods
/datum/mood/proc/remove_temp_moods()
	for (var/category in mood_events)
		var/datum/mood_event/moodlet = mood_events[category]
		if (!moodlet || !moodlet.timeout)
			continue
		mood_events -= moodlet.category
		qdel(moodlet)
	update_mood()

/// Helper to forcefully drain sanity
/datum/mood/proc/direct_sanity_drain(amount)
	set_sanity(sanity + amount, override = TRUE)

/**
 * Returns true if you already have a mood from a provided category.
 * You may think to yourself, why am I trying to get a boolean from a component? Well, this system probably should not be a component.
 *
 * Arguments
 * * category - Mood category to validate against.
 */
/datum/mood/proc/has_mood_of_category(category)
	for(var/i in mood_events)
		var/datum/mood_event/moodlet = mood_events[i]
		if (moodlet.category == category)
			return TRUE
	return FALSE

#undef MINOR_INSANITY_PEN
#undef MAJOR_INSANITY_PEN
#undef MOOD_CATEGORY_NUTRITION
#undef MOOD_CATEGORY_AREA_BEAUTY
