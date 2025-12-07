// Security Hud //
/datum/pai_software/sec_hud
	name = "Security HUD"
	ram_cost = 20
	id = "sec_hud"
	ui_icon = "exclamation-triangle"
	toggle_software = TRUE

/datum/pai_software/sec_hud/toggle(mob/living/silicon/pai/user)
	user.secHUD = !user.secHUD
	user.medHUD = FALSE
	user.dHUD = FALSE
	user.remove_med_sec_hud()
	if(user.secHUD)
		user.add_sec_hud()

/datum/pai_software/sec_hud/is_active(mob/living/silicon/pai/user)
	return user.secHUD

// Medical Hud //
/datum/pai_software/med_hud
	name = "Medical HUD"
	ram_cost = 20
	id = "med_hud"
	ui_icon = "first-aid"
	toggle_software = TRUE

/datum/pai_software/med_hud/toggle(mob/living/silicon/pai/user)
	user.medHUD = !user.medHUD
	user.secHUD = FALSE
	user.dHUD = FALSE
	user.remove_med_sec_hud()
	if(user.medHUD)
		user.add_med_hud()

/datum/pai_software/med_hud/is_active(mob/living/silicon/pai/user)
	return user.medHUD

/datum/pai_software/d_hud
	name = "Diagnostic HUD"
	ram_cost = 20
	id = "d_hud"
	ui_icon = "bolt"
	toggle_software = TRUE

/datum/pai_software/d_hud/toggle(mob/living/silicon/pai/user)
	user.dHUD = !user.dHUD
	user.secHUD = FALSE
	user.medHUD = FALSE
	user.remove_med_sec_hud()
	if(user.dHUD)
		user.add_diag_hud()

/datum/pai_software/d_hud/is_active(mob/living/silicon/pai/user)
	return user.dHUD

// Universal Translator //
/datum/pai_software/translator
	name = "Universal Translator"
	ram_cost = 35
	id = "translator"
	ui_icon = "language"
	toggle_software = TRUE

/datum/pai_software/translator/toggle(mob/living/silicon/pai/user)
	// 	Galactic Common, Sol Common, Tradeband, Gutter and Trinary are added with New() and are therefore the current default, always active languages
	user.translator_on = !user.translator_on
	if(user.translator_on)
		user.add_language("Sinta'unathi")
		user.add_language("Siik'tajr")
		user.add_language("Canilunzt")
		user.add_language("Qurvolious")
		user.add_language("Vox-pidgin")
		user.add_language("Rootspeak")
		user.add_language("Chittin")
		user.add_language("Bubblish")
		user.add_language("Orluum")
		user.add_language("Clownish")
		user.add_language("Cygni Standard")
		user.add_language("Tkachi")
	else
		user.remove_language("Sinta'unathi")
		user.remove_language("Siik'tajr")
		user.remove_language("Canilunzt")
		user.remove_language("Qurvolious")
		user.remove_language("Vox-pidgin")
		user.remove_language("Rootspeak")
		user.remove_language("Chittin")
		user.remove_language("Bubblish")
		user.remove_language("Orluum")
		user.remove_language("Clownish")
		user.remove_language("Cygni Standard")
		user.remove_language("Tkachi")

/datum/pai_software/translator/is_active(mob/living/silicon/pai/user)
	return user.translator_on

// FLashlight //
/datum/pai_software/flashlight
	name = "Flashlight"
	ram_cost = 5
	id = "flashlight"
	ui_icon = "lightbulb"
	toggle_software = TRUE

/datum/pai_software/flashlight/toggle(mob/living/silicon/pai/user)
	var/atom/movable/actual_location = istype(user.loc, /obj/item/paicard) ? user.loc : user
	if(!user.flashlight_on)
		actual_location.set_light(2)
		user.card.set_light(2)
	else
		actual_location.set_light(0)
		user.card.set_light(0)

	user.flashlight_on = !user.flashlight_on

/datum/pai_software/flashlight/is_active(mob/living/silicon/pai/user)
	return user.flashlight_on

