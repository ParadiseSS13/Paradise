#define COGBAR_ANIMATION_TIME (0.5 SECONDS)

/**
 * # Cogbar
 * Represents that the user is busy doing something.
 *
 * The cogbar is a visual representation in the game that indicates to other players
 * that a user is currently busy with an action. This class handles the creation,
 * display, and removal of the cog animation.
 */
/datum/cogbar
	/// Who's doing the thing
	var/mob/user
	/// The user client
	var/client/user_client
	/// The visible element to other players
	var/obj/effect/overlay/vis/cog
	/// The blank image that overlaps the cog - hides it from the source user
	var/image/blank
	/// The offset of the icon
	var/offset_y

// Class constructor
/**
 * Initializes a new instance of the cogbar for the specified user.
 *
 * This constructor sets up the user and user client properties, adds the cog overlay
 * to the user, and registers a signal to handle user deletion.
 *
 * @param user - The user for whom the cogbar is created.
 */
/datum/cogbar/New(mob/user)
	src.user = user
	src.user_client = user.client

	var/list/icon_offsets = user.get_oversized_icon_offsets()
	offset_y = icon_offsets["y"]

	add_cog_to_user()

	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(on_user_delete))

// Destructor
/**
 * Cleans up the cogbar instance, removing overlays and images associated with the user.
 *
 * This method ensures that all visual elements are properly removed when the cogbar instance is destroyed
 */
/datum/cogbar/Destroy()
	if(user)
		SSvis_overlays.remove_vis_overlay(user, user.managed_vis_overlays)
		user_client?.images -= blank

	user = null
	user_client = null
	cog = null
	QDEL_NULL(blank)

	return ..()

/// Adds the cog to the user, visible by other players
/**
 * Adds the cog overlay to the user, making it visible to other players.
 *
 * This function creates the cog overlay with appropriate properties and
 * initiates the animation to fade it in. Additionally, a blank image is
 * added to the user's client to hide the cog from the user's own perspective.
 */
/datum/cogbar/proc/add_cog_to_user()
	cog = SSvis_overlays.add_vis_overlay(user,
		icon = 'icons/effects/progressbar.dmi',
		iconstate = "cog",
		plane = COGBAR_PLANE,
		add_appearance_flags = APPEARANCE_UI_IGNORE_ALPHA,
		unique = TRUE,
		alpha = 0,
	)

	cog.pixel_y = world.icon_size + offset_y
	animate(cog, alpha = 255, time = COGBAR_ANIMATION_TIME)

	if(isnull(user_client))
		return

	blank = image('icons/blanks/32x32.dmi', cog, "nothing")
	blank.plane = HUD_PLANE
	blank.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	blank.override = TRUE

	user_client.images += blank

/// Removes the cog from the user
/**
 * Initiates the removal process for the cog overlay.
 *
 * This function fades out the cog overlay and schedules the cogbar instance
 * for deletion after the animation completes.
 */
/datum/cogbar/proc/remove()
	if(isnull(cog))
		qdel(src)
		return

	animate(cog, alpha = 0, time = COGBAR_ANIMATION_TIME)

	QDEL_IN(src, COGBAR_ANIMATION_TIME)

/// When the user is deleted, remove the cog
/**
 * Handles the cleanup when the associated user is deleted.
 *
 * This function is triggered by a signal and ensures that the cogbar instance is properly destroyed
 */
/datum/cogbar/proc/on_user_delete(datum/source)
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING

	qdel(src)

#undef COGBAR_ANIMATION_TIME
