#define PROGRESSBAR_HEIGHT 6

/**
  * # Progress Bar
  *
  * Use to give feedback on the progress of an action that takes time.
  * Can use a custom theme which alters the visuals of the bar.
  *
  * How does it work visually?
  * There are 3 images comprising the progress bar:
  * - [theme]_backdrop - The bar's background.
  * - [theme]_mask - The mask, which hides the fill and decreases in size, exposing more of the fill as the bar progresses.
  * - [theme]_fill - The bar's fill, ideally white so it can be coloured.
  * The result is there is no longer a need to create states for every 5% - the filling is instead interpolated and colored accordingly.
  */
/datum/progress_bar
	// Settings
	/// The goal value to reach. When [/datum/progress_bar/proc/update] is called, a fraction is calculated with the goal.
	var/goal = 100
	/// The icon file to use for the visual element.
	var/icon_path = 'icons/effects/progressbar.dmi'
	/// The progress bar visual theme.
	var/theme = "default"
	/// The total height in pixels of the theme's progress bar.
	var/height = 7
	/// The width in pixels of the theme's fill sprite.
	var/fill_width = 22
	// Variables
	/// The target to display the progress bar on.
	var/atom/target
	/// The main visual element holding everything up.
	var/image/holder
	/// The backdrop visual element. Contains the fill and mask as overlays.
	var/image/backdrop
	/// The fill visual element.
	var/image/fill
	/// The mob currently owning the progress bar, used to calculate the bar's vertical position.
	var/mob/user
	/// The client currently owning the progress bar for display.
	var/client/client
	/// The bar's index number within the owning mob's active progress bar list.
	var/list_index

/datum/progress_bar/New(mob/user, goal, atom/target)
	. = ..()
	if(!istype(target))
		EXCEPTION("Invalid target given")

	init_images(target)
	src.target = target
	src.user = user
	src.goal = goal

	if(user)
		client = user.client
		client?.images |= holder

		LAZYINITLIST(user.progressbars)
		LAZYINITLIST(user.progressbars[target])
		var/list/bars = user.progressbars[target]
		bars += src
		list_index = length(bars)
		animate(holder, pixel_y = world.icon_size + (height * (list_index - 1)), alpha = 255, time = 0.5 SECONDS, easing = SINE_EASING | EASE_OUT)
	else
		animate(holder, alpha = 255, time = 0.5 SECONDS, easing = SINE_EASING | EASE_OUT)

/datum/progress_bar/Destroy()
	if(user?.progressbars[target])
		var/list/bars = user.progressbars[target]
		for(var/I in (bars - src))
			var/datum/progress_bar/P = I
			if(P.list_index > list_index)
				P.shift_down()

		bars -= src
		if(!length(bars))
			LAZYREMOVE(user.progressbars, target)

	animate(holder, alpha = 0, time = 0.5 SECONDS)
	spawn(5)
		client?.images -= holder
		QDEL_NULL(holder)
		QDEL_NULL(backdrop)
		QDEL_NULL(fill)
	return ..()

/**
  * Initializes the visual elements.
  *
  * Arguments:
  * * target - The atom to parent the images to.
  */
/datum/progress_bar/proc/init_images(target)
	holder = image('icons/effects/effects.dmi', target, "nothing", HUD_LAYER)
	holder.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	holder.alpha = 0
	holder.plane = HUD_PLANE
	holder.appearance_flags = KEEP_TOGETHER | APPEARANCE_UI_IGNORE_ALPHA

	backdrop = image(icon_path, target, "[theme]_backdrop")

	fill = image(icon_path, target, "[theme]_fill")
	fill.filters = filter(type = "alpha", icon = icon(icon_path, "[theme]_mask"), x = -fill_width)

	holder.overlays += backdrop
	holder.overlays += fill

/**
  * Call periodically to update the progress bar's progress.
  *
  * Arguments:
  * * progress - The new value, divided with the given goal on creation to calculate the fraction.
  */
/datum/progress_bar/proc/update(progress)
	if(QDELETED(target))
		qdel(src)
		return
	if(user?.client != client)
		client?.images -= holder
		if(user.client)
			client = user.client
			client.images += holder

	. = clamp(progress / goal, 0, 1)
	if(fill)
		holder.overlays -= fill
		update_fill(.)
		holder.overlays += fill

/**
  * Updates the fill. Do your visual changes here.
  *
  * Arguments:
  * * fraction - The new (value / goal) fraction.
  */
/datum/progress_bar/proc/update_fill(fraction)
	var/F = fill.filters[1]
	F?:x = -fill_width * (1 - fraction) // I know what you're thinking. I should be shot, but dreamchecker doesn't know this type for some reason yet

/**
  * Shifts the progress bar down.
  */
/datum/progress_bar/proc/shift_down()
	--list_index
	var/shift_height = holder.pixel_y - height
	animate(holder, pixel_y = shift_height, time = 0.5 SECONDS, easing = SINE_EASING | EASE_OUT)

/datum/progress_bar/default/update_fill(fraction)
	. = ..()
	fill.color = gradient(0, COLOR_RED, 0.25, COLOR_ORANGE, 0.5, COLOR_GREEN, 0.75, COLOR_SKY_BLUE, fraction)

/**
  * An example progress bar that stays yellow then blinks red every now and then.
  */
/datum/progress_bar/warning
	theme = "warning"

/datum/progress_bar/warning/update_fill(fraction)
	. = ..()
	if(fraction <= 0.5)
		fill.color = COLOR_YELLOW
	else
		fill.color = gradient(0.5, COLOR_YELLOW, 0.5, COLOR_RED, "loop", fraction * 10)

/**
  * Creates a new progress bar datum with the given theme.
  *
  * Arguments:
  * * user - The mob seeing the progress bar.
  * * goal - The goal number.
  * * target - The atom to display the bar on.
  * * theme - The progress bar's theme.
  */
/proc/create_progress_bar(mob/user, goal, atom/target, theme = "default")
	var/type = /datum/progress_bar
	switch(theme)
		if("default")
			type = /datum/progress_bar/default
		if("warning")
			type = /datum/progress_bar/warning

	return new type(user, goal, target)
