/**
  * # pAI Software
  *
  * Datum module for pAI software
  *
  * Very similar to the PDA app datum, this determines what UI sub-template to use,
  * as well as the RAM cost, and if it is toggle software (not a UI app)
  *
  */
/datum/pai_software
	/// Name for the software. This is used as the button text when buying or opening/toggling the software
	var/name = "pAI software module"
	/// RAM cost; pAIs start with 100 RAM, spending it on programs
	var/ram_cost = 0
	/// ID for the software. This must be unique
	var/id
	// Toggled software should override toggle() and is_active()
	// Non-toggled software should override get_app_data() and Topic()
	/// Whether this software is a toggle or not
	var/toggle_software = FALSE
	/// Do we have this software installed by default
	var/default = FALSE
	/// Template for the TGUI file
	var/template_file = "oops"
	/// Icon for inside the UI
	var/ui_icon = "file-code"
	/// pAI which holds this software
	var/mob/living/silicon/pai/pai_holder

/**
  * New handler
  *
  * Ensures that the pai_holder var is set to the pAI itself
  * Arguments:
  * * user - The pAI that this softawre is held by
  */
/datum/pai_software/New(mob/living/silicon/pai/user)
	pai_holder = user
	..()

/**
  * Handler for the app's UI data
  *
  * This returns the list of the current app's data for the UI
  * This will then be injected as a variable on the TGUI data called "app_data"
  *
  * Arguments:
  * * user - The pAI that is using this app
  */
/datum/pai_software/proc/get_app_data(mob/living/silicon/pai/user)
	return list()

/**
  * Handler for toggling toggle apps on and off
  *
  * This is invoked whenever you toggle a toggleable function
  * Put your toggleable work in here
  *
  * Arguments:
  * * user - The pAI that is using this toggle
  */
/datum/pai_software/proc/toggle(mob/living/silicon/pai/user)
	return

/**
  * Helper for checking if a toggle is enabled or not
  *
  * Returns TRUE if the toggle software is active, FALSE if not
  *
  * Its like this instead of a simple `is_toggled` var because some toggles override eachother and this is easier
  *
  * Arguments:
  * * user - The pAI that is using this app
  */
/datum/pai_software/proc/is_active(mob/living/silicon/pai/user)
	return FALSE
