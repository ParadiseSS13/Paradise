//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS
	button_icon_state = null

/datum/action/item_action/New(Target)
	..()
	var/obj/item/I = target
	I.actions += src
	// If our button state is null, use the target's icon instead
	if(target && isnull(button_icon_state))
		AddComponent(/datum/component/action_item_overlay, target)

/datum/action/item_action/Destroy()
	var/obj/item/I = target
	if(islist(I?.actions))
		I.actions -= src
	return ..()

/datum/action/item_action/Trigger(left_click = TRUE, attack_self = TRUE) //Maybe we don't want to click the thing itself
	if(!..())
		return FALSE
	if(target && attack_self)
		var/obj/item/I = target
		I.ui_action_click(owner, type, left_click)
	return TRUE

/datum/action/item_action/toggle_light
	name = "Toggle Light"

/datum/action/item_action/toggle_hood
	name = "Toggle Hood"

/datum/action/item_action/toggle_firemode
	name = "Toggle Firemode"

/datum/action/item_action/print_report
	name = "Print Report"

/datum/action/item_action/print_forensic_report
	name = "Print Report"
	button_icon_state = "scanner_print"

/datum/action/item_action/clear_records
	name = "Clear Scanner Records"
	button_icon_state = "scanner_clear"

/datum/action/item_action/toggle_gunlight
	name = "Toggle Gunlight"

/datum/action/item_action/toggle_mode
	name = "Toggle Mode"

/datum/action/item_action/toggle_barrier_spread
	name = "Toggle Barrier Spread"

/datum/action/item_action/equip_unequip_ted_gun
	name = "Equip/Unequip TED Gun"

/datum/action/item_action/toggle_paddles
	name = "Toggle Paddles"

/datum/action/item_action/set_internals
	name = "Set Internals"

/datum/action/item_action/set_internals/is_action_active(atom/movable/screen/movable/action_button/button)
	var/mob/living/carbon/carbon_owner = owner
	return istype(carbon_owner) && target == carbon_owner.internal

/datum/action/item_action/toggle_mister
	name = "Toggle Mister"

/datum/action/item_action/toggle_music_notes
	name = "Toggle Music Notes"

/datum/action/item_action/toggle_helmet_light
	name = "Toggle Helmet Light"

/datum/action/item_action/toggle_welding_screen/plasmaman
	name = "Toggle Welding Screen"

/datum/action/item_action/toggle_welding_screen/plasmaman/Trigger(left_click)
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

/datum/action/item_action/toggle_unfriendly_fire/Trigger(left_click)
	if(..())
		build_all_button_icons()

/datum/action/item_action/toggle_unfriendly_fire/build_all_button_icons(update_flags, force)
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/H = target
		if(H.friendly_fire_check)
			button_icon_state = "vortex_ff_off"
			name = "Toggle Friendly Fire \[OFF\]"
		else
			button_icon_state = "vortex_ff_on"
			name = "Toggle Friendly Fire \[ON\]"
	..()

/datum/action/item_action/vortex_recall
	name = "Vortex Recall"
	desc = "Recall yourself, and anyone nearby, to an attuned hierophant beacon at any time.<br>If the beacon is still attached, will detach it."
	button_icon_state = "vortex_recall"

/datum/action/item_action/vortex_recall/IsAvailable(show_message = TRUE)
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

/datum/action/item_action/openclose

/datum/action/item_action/openclose/New(Target)
	..()
	name = "Open/Close [target.name]"

/datum/action/item_action/button

/datum/action/item_action/button/New(Target)
	..()
	name = "Button/Unbutton [target.name]"

/datum/action/item_action/zipper

/datum/action/item_action/zipper/New(Target)
	..()
	name = "Zip/Unzip [target.name]"

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

/datum/action/item_action/yeeeaaaaahhhhhhhhhhhhh
	name = "YEAH!"

/datum/action/item_action/laugh_track
	name = "Laugh Track"

/datum/action/item_action/whistle
	name = "Whistle"

/datum/action/item_action/floor_buffer
	name = "Toggle Floor Buffer"
	desc = "Movement speed is decreased while active."

/datum/action/item_action/adjust

/datum/action/item_action/adjust/New(Target)
	..()
	name = "Adjust [target.name]"

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

/datum/action/item_action/remove_tape/Trigger(left_click, attack_self = FALSE)
	if(..())
		var/datum/component/ducttape/DT = target.GetComponent(/datum/component/ducttape)
		DT.remove_tape(target, usr)

/datum/action/item_action/toggle_jetpack
	name = "Toggle Jetpack"

/datum/action/item_action/jetpack_stabilization
	name = "Toggle Jetpack Stabilization"

/datum/action/item_action/jetpack_stabilization/IsAvailable(show_message = TRUE)
	var/obj/item/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		return FALSE
	return ..()

/datum/action/item_action/toggle_geiger_counter
	name = "Toggle Geiger Counter"

/datum/action/item_action/toggle_geiger_counter/Trigger(left_click)
	var/obj/item/clothing/head/helmet/space/hardsuit/H = target
	if(istype(H))
		H.toggle_geiger_counter()

/datum/action/item_action/toggle_radio_jammer
	name = "Toggle Radio Jammer"
	desc = "Turns your jammer on or off. Hush, you."

/datum/action/item_action/hands_free
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/hands_free/activate
	name = "Activate"

/datum/action/item_action/hands_free/activate/always
	check_flags = null

/datum/action/item_action/toggle_research_scanner
	name = "Toggle Research Scanner"
	button_icon_state = "scan_mode"

/datum/action/item_action/toggle_research_scanner/Trigger(left_click)
	if(IsAvailable())
		owner.research_scanner = !owner.research_scanner
		to_chat(owner, "<span class='notice'>Research analyzer is now [owner.research_scanner ? "active" : "deactivated"].</span>")
		return TRUE

/datum/action/item_action/toggle_research_scanner/Remove(mob/living/L)
	if(owner)
		owner.research_scanner = FALSE
	..()

/datum/action/item_action/toggle_research_scanner/apply_button_overlay(atom/movable/screen/movable/action_button/current_button)
	current_button.cut_overlays()
	if(button_icon && button_icon_state)
		var/image/img = image(button_icon, current_button, "scan_mode")
		img.appearance_flags = RESET_COLOR | RESET_ALPHA
		current_button.overlays += img

/datum/action/item_action/instrument
	name = "Use Instrument"
	desc = "Use the instrument specified."

/datum/action/item_action/instrument/Trigger(left_click)
	if(istype(target, /obj/item/instrument))
		var/obj/item/instrument/I = target
		I.interact(usr)
		return
	return ..()


/datum/action/item_action/remove_badge
	name = "Remove Holobadge"

/datum/action/item_action/drop_gripped_item
	name = "Drop gripped item"

// Clown Acrobat Shoes
/datum/action/item_action/slipping
	name = "Tactical Slip"
	desc = "Activates the clown shoes' ankle-stimulating module, allowing the user to do a short slip forward going under anyone."
	button_icon_state = "clown"

// Jump boots
/datum/action/item_action/bhop
	name = "Activate Jump Boots"
	desc = "Activates the jump boot's internal propulsion system, allowing the user to dash over 4-wide gaps."
	button_icon_state = "jetboot"

/datum/action/item_action/gravity_jump
	name = "Gravity jump"
	desc = "Directs a pulse of gravity in front of the user, pulling them forward rapidly."

/datum/action/item_action/gravity_jump/Trigger(left_click)
	if(!IsAvailable())
		return FALSE

	var/obj/item/clothing/shoes/magboots/gravity/G = target
	G.dash(usr)

/datum/action/item_action/toogle_camera_flash
	name = "Toggle camera flash"
	desc = "Toggles the camera's flash, which will fully light up the photo. Turn this off if you want the ambient light."

///prset for organ actions
/datum/action/item_action/organ_action
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/IsAvailable(show_message = TRUE)
	var/obj/item/organ/internal/I = target
	if(!I.owner)
		return FALSE
	return ..()

/datum/action/item_action/organ_action/toggle

/datum/action/item_action/organ_action/toggle/New(Target)
	..()
	name = "Toggle [target.name]"

/datum/action/item_action/organ_action/use/New(Target)
	..()
	name = "Use [target.name]"

/datum/action/item_action/organ_action/use/eyesofgod/New(target)
	..()
	name = "See with the Eyes of the Gods"

/datum/action/item_action/voice_changer/toggle
	name = "Toggle Voice Changer"

/datum/action/item_action/voice_changer/voice
	name = "Set Voice"

/datum/action/item_action/voice_changer/voice/Trigger(left_click)
	if(!IsAvailable())
		return FALSE

	var/obj/item/voice_changer/V = target
	V.set_voice(usr)

/datum/action/item_action/herald
	name = "Mirror Walk"
	desc = "Use near a mirror to enter it."

// for clothing accessories like holsters
/datum/action/item_action/accessory
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS

/datum/action/item_action/accessory/IsAvailable(show_message = TRUE)
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

/datum/action/item_action/accessory/storage
	name = "View Storage"

/datum/action/item_action/call_link
	name = "Call MODlink"

