/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/obj/target = null
	var/check_flags = 0
	var/obj/screen/movable/action_button/button = null
	var/button_icon = 'icons/mob/actions/actions.dmi'
	var/background_icon_state = "bg_default"
	var/buttontooltipstyle = ""
	var/icon_icon = 'icons/mob/actions/actions.dmi'
	var/button_icon_state = "default"
	var/mob/owner

/datum/action/New(var/Target)
	target = Target
	button = new
	button.linked_action = src
	button.name = name
	button.actiontooltipstyle = buttontooltipstyle
	if(desc)
		button.desc = desc

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	if(target)
		target = null
	QDEL_NULL(button)
	return ..()

/datum/action/proc/Grant(mob/M)
	if(owner)
		if(owner == M)
			return
		Remove(owner)
	owner = M
	M.actions += src
	if(M.client)
		M.client.screen += button
		button.locked = TRUE
	M.update_action_buttons()

/datum/action/proc/Remove(mob/M)
	owner = null
	if(!M)
		return
	if(M.client)
		M.client.screen -= button
	button.moved = FALSE //so the button appears in its normal position when given to another owner.
	button.locked = FALSE
	M.actions -= src
	M.update_action_buttons()

/datum/action/proc/Trigger()
	if(!IsAvailable())
		return FALSE
	return TRUE

/datum/action/proc/Process()
	return

/datum/action/proc/override_location() // Override to set coordinates manually
	return

/datum/action/proc/IsAvailable()// returns 1 if all checks pass
	if(!owner)
		return FALSE
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return FALSE
	if(check_flags & AB_CHECK_STUNNED)
		if(owner.stunned || owner.IsWeakened())
			return FALSE
	if(check_flags & AB_CHECK_LYING)
		if(owner.lying)
			return FALSE
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return FALSE
	if(check_flags & AB_CHECK_TURF)
		if(!isturf(owner.loc))
			return FALSE
	return TRUE

/datum/action/proc/IsMayActive()
	return FALSE

/datum/action/proc/UpdateButtonIcon()
	if(button)
		if(owner && owner.client && background_icon_state == "bg_default") // If it's a default action background, apply the custom HUD style
			button.alpha = owner.client.prefs.UI_style_alpha
			button.color = owner.client.prefs.UI_style_color
			button.icon = ui_style2icon(owner.client.prefs.UI_style)
			button.icon_state = "template"
		else
			button.icon = button_icon
			button.icon_state = background_icon_state
		button.name = name
		button.desc = desc

		ApplyIcon(button)

		if(IsMayActive())
			toggle_active_overlay()

		// If the action isn't available, darken the button
		if(!IsAvailable())
			apply_unavailable_effect()
		else
			return TRUE

/datum/action/proc/apply_unavailable_effect()
	var/image/img = image('icons/mob/screen_white.dmi', icon_state = "template")
	img.alpha = 200
	img.appearance_flags = RESET_COLOR | RESET_ALPHA
	img.color = "#000000"
	img.plane = FLOAT_PLANE + 1
	button.add_overlay(img)

/datum/action/proc/ApplyIcon(obj/screen/movable/action_button/current_button)
	current_button.cut_overlays()
	if(icon_icon && button_icon_state)
		var/image/img = image(icon_icon, current_button, button_icon_state)
		img.appearance_flags = RESET_COLOR | RESET_ALPHA
		img.pixel_x = 0
		img.pixel_y = 0
		current_button.add_overlay(img)

/datum/action/proc/toggle_active_overlay()
	return

//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	var/use_itemicon = TRUE
	var/action_initialisation_text = null	//Space ninja abilities only

/datum/action/item_action/New(Target, custom_icon, custom_icon_state)
	..()
	var/obj/item/I = target
	I.actions += src
	if(custom_icon && custom_icon_state)
		use_itemicon = FALSE
		icon_icon = custom_icon
		button_icon_state = custom_icon_state

/datum/action/item_action/Destroy()
	var/obj/item/I = target
	I.actions -= src
	return ..()

/datum/action/item_action/Trigger(attack_self = TRUE) //Maybe we don't want to click the thing itself
	if(!..())
		return FALSE
	if(target && attack_self)
		var/obj/item/I = target
		I.ui_action_click(owner, type)
	return TRUE

/datum/action/item_action/ApplyIcon(obj/screen/movable/action_button/current_button)
	if(use_itemicon)
		if(target)
			var/obj/item/I = target
			var/old_layer = I.layer
			var/old_plane = I.plane
			var/old_appearance_flags = I.appearance_flags
			I.layer = FLOAT_LAYER //AAAH
			I.plane = FLOAT_PLANE //^ what that guy said
			I.appearance_flags |= RESET_COLOR | RESET_ALPHA
			if(I.outline_filter)
				I.filters -= I.outline_filter
			current_button.cut_overlays()
			current_button.add_overlay(I)
			I.layer = old_layer
			I.plane = old_plane
			I.appearance_flags = old_appearance_flags
			if(I.outline_filter)
				I.filters -= I.outline_filter
				I.filters += I.outline_filter
	else
		..()

/datum/action/item_action/toggle_light
	name = "Toggle Light"

/datum/action/item_action/toggle_hood
	name = "Toggle Hood"

/datum/action/item_action/toggle_firemode
	name = "Toggle Firemode"

/datum/action/item_action/startchainsaw
	name = "Pull The Starting Cord"

/datum/action/item_action/print_report
	name = "Print Report"

/datum/action/item_action/print_forensic_report
	name = "Print Report"
	button_icon_state = "scanner_print"
	use_itemicon = FALSE

/datum/action/item_action/clear_records
	name = "Clear Scanner Records"

/datum/action/item_action/toggle_gunlight
	name = "Toggle Gunlight"

/datum/action/item_action/toggle_mode
	name = "Toggle Mode"

/datum/action/item_action/toggle_barrier_spread
	name = "Toggle Barrier Spread"

/datum/action/item_action/equip_unequip_TED_Gun
	name = "Equip/Unequip TED Gun"

/datum/action/item_action/toggle_paddles
	name = "Toggle Paddles"

/datum/action/item_action/set_internals
	name = "Set Internals"

/datum/action/item_action/set_internals/UpdateButtonIcon()
	if(..()) //button available
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			if(target == C.internal)
				button.icon = 'icons/mob/actions/actions.dmi'
				button.icon_state = "bg_default_on"

/datum/action/item_action/set_internals_ninja
	name = "Set Internals"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"

/datum/action/item_action/set_internals_ninja/UpdateButtonIcon()
	if(..()) //button available
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			if(target == C.internal)
				button.icon_state = "[background_icon_state]_active"

/datum/action/item_action/toggle_mister
	name = "Toggle Mister"

/datum/action/item_action/toggle_helmet_light
	name = "Toggle Helmet Light"

/datum/action/item_action/toggle_welding_screen/plasmaman
	name = "Toggle Welding Screen"

/datum/action/item_action/toggle_welding_screen/plasmaman/Trigger()
	var/obj/item/clothing/head/helmet/space/plasmaman/H = target
	if(istype(H))
		H.toggle_welding_screen(owner)

/datum/action/item_action/toggle_helmet_mode
	name = "Toggle Helmet Mode"

/datum/action/item_action/toggle_hardsuit_mode
	name = "Toggle Hardsuit Mode"

/datum/action/item_action/toggle_unfriendly_fire
	name = "Toggle Friendly Fire \[ON\]"
	desc = "Toggles if the club's blasts cause friendly fire."
	button_icon_state = "vortex_ff_on"

/datum/action/item_action/toggle_unfriendly_fire/Trigger()
	if(..())
		UpdateButtonIcon()

/datum/action/item_action/toggle_unfriendly_fire/UpdateButtonIcon()
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/H = target
		if(H.friendly_fire_check)
			button_icon_state = "vortex_ff_off"
			name = "Toggle Friendly Fire \[OFF\]"
			button.name = name
		else
			button_icon_state = "vortex_ff_on"
			name = "Toggle Friendly Fire \[ON\]"
			button.name = name
	..()

/datum/action/item_action/vortex_recall
	name = "Vortex Recall"
	desc = "Recall yourself, and anyone nearby, to an attuned hierophant beacon at any time.<br>If the beacon is still attached, will detach it."
	button_icon_state = "vortex_recall"

/datum/action/item_action/vortex_recall/IsAvailable()
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/H = target
		if(H.teleporting)
			return FALSE
	return ..()

/datum/action/item_action/change_headphones_song
	name = "Change Headphones Song"

/datum/action/item_action/toggle

/datum/action/item_action/toggle/New(Target)
	..()
	name = "Toggle [target.name]"
	button.name = name

/datum/action/item_action/openclose

/datum/action/item_action/openclose/New(Target)
	..()
	name = "Open/Close [target.name]"
	button.name = name

/datum/action/item_action/button

/datum/action/item_action/button/New(Target)
	..()
	name = "Button/Unbutton [target.name]"
	button.name = name

/datum/action/item_action/zipper

/datum/action/item_action/zipper/New(Target)
	..()
	name = "Zip/Unzip [target.name]"
	button.name = name

/datum/action/item_action/activate

/datum/action/item_action/activate/New(Target)
	..()
	name = "Activate [target.name]"
	button.name = name

/datum/action/item_action/activate/enchant

/datum/action/item_action/activate/enchant/New(Target)
	..()
	UpdateButtonIcon()
/datum/action/item_action/halt
	name = "HALT!"

/datum/action/item_action/selectphrase
	name = "Change Phrase"

/datum/action/item_action/hoot
	name = "Hoot"

/datum/action/item_action/caw
	name = "Caw"

/datum/action/item_action/toggle_voice_box
	name = "Toggle Voice Box"

/datum/action/item_action/change
	name = "Change"

/datum/action/item_action/noir
	name = "Noir"

/datum/action/item_action/YEEEAAAAAHHHHHHHHHHHHH
	name = "YEAH!"

/datum/action/item_action/adjust

/datum/action/item_action/adjust/New(Target)
	..()
	name = "Adjust [target.name]"
	button.name = name

/datum/action/item_action/pontificate
	name = "Pontificate Evilly"

/datum/action/item_action/tip_fedora
	name = "Tip Fedora"

/datum/action/item_action/flip_cap
	name = "Flip Cap"

/datum/action/item_action/switch_hud
	name = "Switch HUD"

/datum/action/item_action/toggle_wings
	name = "Toggle Wings"

/datum/action/item_action/toggle_helmet
	name = "Toggle Helmet"

/datum/action/item_action/remove_tape
	name = "Remove Duct Tape"

/datum/action/item_action/remove_tape/Trigger(attack_self = FALSE)
	if(..())
		var/datum/component/ducttape/DT = target.GetComponent(/datum/component/ducttape)
		DT.remove_tape(target, usr)

/datum/action/item_action/toggle_jetpack
	name = "Toggle Jetpack"

/datum/action/item_action/jetpack_stabilization
	name = "Toggle Jetpack Stabilization"

/datum/action/item_action/jetpack_stabilization/IsAvailable()
	var/obj/item/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		return FALSE
	return ..()

/datum/action/item_action/toggle_jetpack/ninja
	name = "Toggle Jetpack"

/datum/action/item_action/toggle_jetpack/ninja/apply_unavailable_effect()
	return

/datum/action/item_action/toggle_jetpack/ninja/UpdateButtonIcon()
	. = ..()
	var/obj/item/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		button.icon_state = "[background_icon_state]"
	else
		button.icon_state = "[background_icon_state]_active"

/datum/action/item_action/jetpack_stabilization/ninja
	name = "Toggle Jetpack Stabilization"

/datum/action/item_action/jetpack_stabilization/ninja/UpdateButtonIcon()
	. = ..()
	var/obj/item/tank/jetpack/J = target
	if(!istype(J) || !J.stabilizers)
		button.icon_state = "[background_icon_state]"
	else
		button.icon_state = "[background_icon_state]_active"


/datum/action/item_action/hands_free
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/hands_free/activate
	name = "Activate"

/datum/action/item_action/toggle_research_scanner
	name = "Toggle Research Scanner"
	button_icon_state = "scan_mode"

/datum/action/item_action/toggle_research_scanner/Trigger()
	if(IsAvailable())
		owner.research_scanner = !owner.research_scanner
		to_chat(owner, "<span class='notice'>Research analyzer is now [owner.research_scanner ? "active" : "deactivated"].</span>")
		return TRUE

/datum/action/item_action/toggle_research_scanner/Remove(mob/living/L)
	if(owner)
		owner.research_scanner = 0
	..()

/datum/action/item_action/toggle_research_scanner/ApplyIcon(obj/screen/movable/action_button/current_button)
	current_button.cut_overlays()
	if(button_icon && button_icon_state)
		var/image/img = image(button_icon, current_button, "scan_mode")
		img.appearance_flags = RESET_COLOR | RESET_ALPHA
		current_button.overlays += img

/datum/action/item_action/instrument
	name = "Use Instrument"
	desc = "Use the instrument specified"

/datum/action/item_action/instrument/Trigger()
	if(istype(target, /obj/item/instrument))
		var/obj/item/instrument/I = target
		I.interact(usr)
		return
	return ..()


/datum/action/item_action/remove_badge
	name = "Remove Holobadge"

// Jump boots
/datum/action/item_action/bhop
	name = "Activate Jump Boots"
	desc = "Activates the jump boot's internal propulsion system, allowing the user to dash over 4-wide gaps."
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "jetboot"

///prset for organ actions
/datum/action/item_action/organ_action
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/IsAvailable()
	var/obj/item/organ/internal/I = target
	if(!I.owner)
		return FALSE
	return ..()

/datum/action/item_action/organ_action/toggle

/datum/action/item_action/organ_action/toggle/New(Target)
	..()
	name = "Toggle [target.name]"
	button.name = name

/datum/action/item_action/organ_action/use/New(Target)
	..()
	name = "Use [target.name]"
	button.name = name

/datum/action/item_action/voice_changer/toggle
	name = "Toggle Voice Changer"

/datum/action/item_action/voice_changer/voice
	name = "Set Voice"

/datum/action/item_action/voice_changer/voice/Trigger()
	if(!IsAvailable())
		return FALSE

	var/obj/item/voice_changer/V = target
	V.set_voice(usr)

// for clothing accessories like holsters
/datum/action/item_action/accessory
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS

/datum/action/item_action/accessory/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(target.loc == owner)
		return TRUE
	if(istype(target.loc, /obj/item/clothing/under) && target.loc.loc == owner)
		return TRUE
	return FALSE

/datum/action/item_action/accessory/holster
	name = "Holster"

/datum/action/item_action/accessory/holobadge
	name = "Holobadge"

/datum/action/item_action/accessory/storage
	name = "View Storage"

/datum/action/item_action/accessory/petcollar
	name = "Remove ID"

//Preset for spells
/datum/action/spell_action
	check_flags = 0
	background_icon_state = "bg_spell"
	var/recharge_text_color = "#FFFFFF"

/datum/action/spell_action/New(Target)
	..()
	var/obj/effect/proc_holder/spell/S = target
	S.action = src
	name = S.name
	desc = S.desc
	button_icon = S.action_icon
	button_icon_state = S.action_icon_state
	background_icon_state = S.action_background_icon_state
	button.name = name

/datum/action/spell_action/Destroy()
	var/obj/effect/proc_holder/spell/S = target
	S.action = null
	return ..()

/datum/action/spell_action/Trigger()
	if(!..())
		return FALSE
	if(target)
		var/obj/effect/proc_holder/spell = target
		spell.Click()
		return TRUE

/datum/action/spell_action/IsAvailable()
	if(!target)
		return FALSE
	var/obj/effect/proc_holder/spell/spell = target

	if(spell.special_availability_check)
		return TRUE

	if(owner)
		return spell.can_cast(owner)
	return FALSE

/datum/action/spell_action/IsMayActive()
	if(!target)
		return FALSE
	var/obj/effect/proc_holder/spell/targeted/click/S = target
	if(!istype(S))
		return ..()
	return TRUE

/datum/action/spell_action/toggle_active_overlay()
	var/obj/effect/proc_holder/spell/targeted/click/S = target
	var/image/I = image('icons/mob/screen_gen.dmi', icon_state = "selector")
	I.plane = FLOAT_PLANE + 1.1
	I.layer = FLOAT_LAYER
	if(S.active)
		button.overlays += I
	else
		button.overlays -= I

/datum/action/spell_action/apply_unavailable_effect()
	var/obj/effect/proc_holder/spell/S = target
	if(!istype(S))
		return ..()
	var/progress = S.get_availability_percentage()
	if(progress == 1)
		return ..() // This means that the spell is charged but unavailable due to something else

	var/alpha = 220 - 140 * progress

	var/image/img = image('icons/mob/screen_white.dmi', icon_state = "template")
	img.alpha = alpha
	img.appearance_flags = RESET_COLOR | RESET_ALPHA
	img.color = "#000000"
	img.plane = FLOAT_PLANE + 1
	button.add_overlay(img)
	// Make a holder for the charge text
	var/image/count_down_holder = image('icons/effects/effects.dmi', icon_state = "nothing")
	count_down_holder.plane = FLOAT_PLANE + 1.1
	count_down_holder.maptext = "<div style=\"font-size:6pt;color:[recharge_text_color];font:'Small Fonts';text-align:center;\" valign=\"bottom\">[round_down(progress * 100)]%</div>"
	button.add_overlay(count_down_holder)

/*
/datum/action/spell_action/alien

/datum/action/spell_action/alien/IsAvailable()
	if(!target)
		return 0
	var/obj/effect/proc_holder/alien/ab = target

	if(owner)
		return ab.cost_check(ab.check_turf, owner, 1)
	return 0
*/

//Preset for general and toggled actions
/datum/action/innate
	check_flags = 0
	var/active = FALSE

/datum/action/innate/Trigger()
	if(!..())
		return FALSE
	if(!active)
		Activate()
	else
		Deactivate()
	return TRUE

/datum/action/innate/proc/Activate()
	return

/datum/action/innate/proc/Deactivate()
	return

/datum/action/innate/research_scanner
	name = "Toggle Research Scanner"
	button_icon_state = "scan_mode"

/datum/action/innate/research_scanner/Trigger()
	if(IsAvailable())
		owner.research_scanner = !owner.research_scanner
		to_chat(owner, "<span class='notice'>Research analyzer is now [owner.research_scanner ? "active" : "deactivated"].</span>")
		return TRUE

/datum/action/innate/research_scanner/Remove(mob/living/L)
	if(owner)
		owner.research_scanner = 0
	..()

/datum/action/innate/research_scanner/ApplyIcon(obj/screen/movable/action_button/current_button)
	current_button.cut_overlays()
	if(button_icon && button_icon_state)
		var/image/img = image(button_icon, current_button, "scan_mode")
		img.appearance_flags = RESET_COLOR | RESET_ALPHA
		current_button.overlays += img

//Preset for action that call specific procs (consider innate)
/datum/action/generic
	check_flags = 0
	var/procname

/datum/action/generic/Trigger()
	if(!..())
		return FALSE
	if(target && procname)
		call(target,procname)(usr)
	return TRUE

// This item actions have their own charges/cooldown system like spell procholders, but without all the unnecessary magic stuff
/datum/action/item_action/advanced
	check_flags = 0
	var/recharge_text_color = "#FFFFFF"
	var/charge_type = ADV_ACTION_TYPE_RECHARGE //can be recharge, toggle, toggle_recharge or charges, see description in the defines file
	var/charge_max = 100 //recharge time in deciseconds if charge_type = "recharge" or "toggle_recharge", alternatively counts as starting charges if charge_type = "charges"
	var/charge_counter = 0 //can only use if it equals "recharge" or "toggle_recharge", ++ each decisecond if charge_type = "recharge" or -- each cast if charge_type = "charges"
	var/starts_charged = TRUE //Does this action start ready to go?
	var/still_recharging_msg = "<span class='notice'> action is still recharging.</span>"
	//toggle and toggle_recharge stuff
	var/action_ready = TRUE //Only for toggle and toggle_recharge charge_type. Toggle it via code yourself. Haha 'toggle', get it?
	var/icon_state_active = "bg_default_on"	//What icon_state we switch to when we toggle action active in "toggle" actions
	var/icon_state_disabled = "bg_default"	//Old icon_state we switch to when we toggle action back in "toggle" actions
	//cooldown overlay stuff
	var/coold_overlay_icon = 'icons/mob/screen_white.dmi'
	var/coold_overlay_icon_state = "template"
	var/no_count = FALSE  // This means that the action is charged but unavailable due to something else

/datum/action/item_action/advanced/New()
	. = ..()
	still_recharging_msg = "<span class='notice'>[name] is still recharging.</span>"
	icon_state_disabled = background_icon_state
	if(charge_type == ADV_ACTION_TYPE_CHARGES)
		UpdateButtonIcon()
		add_charges_overlay()
	if(starts_charged)
		charge_counter = charge_max
	else
		start_recharge()

/datum/action/item_action/advanced/proc/start_recharge()
	UpdateButtonIcon()
	START_PROCESSING(SSfastprocess, src)

/datum/action/item_action/advanced/process()
	charge_counter += 2
	UpdateButtonIcon()
	if(charge_counter < charge_max)
		return
	STOP_PROCESSING(SSfastprocess, src)
	action_ready = TRUE
	charge_counter = charge_max

/datum/action/item_action/advanced/proc/recharge_action() //resets charge_counter or readds one charge
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			charge_counter = charge_max
		if(ADV_ACTION_TYPE_TOGGLE)	//this type doesn't use those var's, but why not
			charge_counter = charge_max
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			charge_counter = charge_max
		if(ADV_ACTION_TYPE_CHARGES)
			charge_counter++
			UpdateButtonIcon()
			add_charges_overlay()

/datum/action/item_action/advanced/proc/use_action()
	if(!IsAvailable(show_message = TRUE))
		return
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			charge_counter = 0
			start_recharge()
		if(ADV_ACTION_TYPE_TOGGLE)
			toggle_button_on_off()
			action_ready = !action_ready
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			charge_counter = 0
			start_recharge()
		if(ADV_ACTION_TYPE_CHARGES)
			charge_counter--
			UpdateButtonIcon()
			add_charges_overlay()

/* Basic availability checks in this proc.
 * Arguments:
 * show_message - Do we show recharging message to the caller?
 * ignore_ready - Are we ignoring the "action_ready" flag? Usefull when u call this check indirrectly.
 */
/datum/action/item_action/advanced/IsAvailable(show_message = FALSE, ignore_ready = FALSE)
	. = ..()
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			if(charge_counter < charge_max)
				if(show_message)
					to_chat(owner, still_recharging_msg)
				return FALSE
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			if(charge_counter < charge_max)
				if(action_ready && !ignore_ready)
					return TRUE
				if(show_message)
					to_chat(owner, still_recharging_msg)
				return FALSE
		if(ADV_ACTION_TYPE_CHARGES)
			if(!charge_counter)
				if(show_message)
					to_chat(owner, "<span class='notice'>[name] has no charges left.</span>")
				return FALSE
	return TRUE

/datum/action/item_action/advanced/proc/get_availability_percentage()
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			if(charge_counter == 0)
				return 0
			if(charge_max == 0)
				return 1
			return charge_counter / charge_max
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			if(action_ready)
				return 1
			if(charge_counter == 0)
				return 0
			if(charge_max == 0)
				return 1
			return charge_counter / charge_max
		if(ADV_ACTION_TYPE_CHARGES)
			if(charge_counter)
				return 1
			return 0

/datum/action/item_action/advanced/apply_unavailable_effect()
	var/progress = get_availability_percentage()
	if(progress == 1)
		no_count = TRUE
	var/alpha = no_count ? 80 : 220 - 140 * progress
	var/image/img = image(coold_overlay_icon, icon_state = coold_overlay_icon_state)
	img.alpha = alpha
	img.appearance_flags = RESET_COLOR | RESET_ALPHA
	img.color = "#000000"
	img.plane = FLOAT_PLANE + 1
	button.add_overlay(img)
	if(!no_count && charge_type != ADV_ACTION_TYPE_CHARGES)
		add_percentage_overlay(progress)
	else if(charge_type == ADV_ACTION_TYPE_CHARGES)
		add_charges_overlay()
	no_count = FALSE //reset

/datum/action/item_action/advanced/proc/add_percentage_overlay(progress)
	// Make a holder for the charge text
	var/image/count_down_holder = image('icons/effects/effects.dmi', icon_state = "nothing")
	count_down_holder.plane = FLOAT_PLANE + 1.1
	count_down_holder.maptext = "<div style=\"font-size:6pt;color:[recharge_text_color];font:'Small Fonts';text-align:center;\" valign=\"bottom\">[round_down(progress * 100)]%</div>"
	button.add_overlay(count_down_holder)

/datum/action/item_action/advanced/proc/add_charges_overlay()
	// Make a holder for the charge text
	var/image/charges_holder = image('icons/effects/effects.dmi', icon_state = "nothing")
	charges_holder.plane = FLOAT_PLANE + 1.1
	charges_holder.maptext = "<div style=\"font-size:6pt;color:#ffffff;font:'Small Fonts';text-align:center;\" valign=\"bottom\">[charge_counter]/[charge_max]</div>"
	button.add_overlay(charges_holder)

	//visuals only
/datum/action/item_action/advanced/proc/toggle_button_on_off()
	if(!action_ready)
		icon_state_disabled = background_icon_state
		background_icon_state = "[background_icon_state]_on"
	else
		background_icon_state = icon_state_disabled
	UpdateButtonIcon()

//Ninja action type
/datum/action/item_action/advanced/ninja
	coold_overlay_icon = 'icons/mob/actions/actions_ninja.dmi'
	coold_overlay_icon_state = "background_green"
	icon_state_active = "background_green_active"
	icon_state_disabled = "background_green"

/datum/action/item_action/advanced/ninja/New(Target)
	. = ..()
	var/obj/item/clothing/suit/space/space_ninja/ninja_suit = target
	if(istype(ninja_suit))
		recharge_text_color = ninja_suit.color_choice
		coold_overlay_icon_state = "background_[ninja_suit.color_choice]"

/datum/action/item_action/advanced/ninja/IsAvailable(show_message = FALSE, ignore_ready = FALSE)
	if(!target && !istype(target, /obj/item/clothing/suit/space/space_ninja))
		return FALSE
	return ..()

/datum/action/item_action/advanced/ninja/apply_unavailable_effect()
	var/obj/item/clothing/suit/space/space_ninja/ninja_suit = target
	if(!istype(ninja_suit))
		no_count = TRUE
	. = ..()

/datum/action/item_action/advanced/ninja/toggle_button_on_off()
	if(action_ready)
		background_icon_state = icon_state_active
	else
		background_icon_state = icon_state_disabled
	UpdateButtonIcon()
