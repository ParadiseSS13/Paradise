#define AB_CHECK_RESTRAINED		(1<<0)
#define AB_CHECK_STUNNED		(1<<1)
#define AB_CHECK_LYING			(1<<2)
#define AB_CHECK_CONSCIOUS		(1<<3)
#define AB_CHECK_TURF			(1<<4)
#define AB_CHECK_HANDS_BLOCKED	(1<<5)
#define AB_CHECK_IMMOBILE		(1<<6)


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

/datum/action/New(Target)
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
	if((check_flags & AB_CHECK_HANDS_BLOCKED) && HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		return FALSE
	if((check_flags & AB_CHECK_IMMOBILE) && HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return FALSE
	if(check_flags & AB_CHECK_STUNNED)
		if(isliving(owner))
			var/mob/living/L = owner
			if(L.IsStunned() || L.IsWeakened())
				return FALSE
	if(check_flags & AB_CHECK_LYING)
		if(isliving(owner))
			var/mob/living/L = owner
			if(IS_HORIZONTAL(L))
				return FALSE
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return FALSE
	if(check_flags & AB_CHECK_TURF)
		if(!isturf(owner.loc))
			return FALSE
	return TRUE

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
		button.desc = desc

		ApplyIcon(button)
		var/obj/effect/proc_holder/spell/S = target
		if(istype(S) && S.cooldown_handler.should_draw_cooldown() || !IsAvailable())
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

//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	var/use_itemicon = TRUE

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
			current_button.cut_overlays()
			current_button.add_overlay(I)
			I.layer = old_layer
			I.plane = old_plane
			I.appearance_flags = old_appearance_flags
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

/datum/action/item_action/toggle_mister
	name = "Toggle Mister"

/datum/action/item_action/toggle_music_notes
	name = "Toggle Music Notes"

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

/datum/action/item_action/laugh_track
	name = "Laugh Track"

/datum/action/item_action/floor_buffer
	name = "Toggle Floor Buffer"
	desc = "Movement speed is decreased while active."

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

/datum/action/item_action/toggle_geiger_counter
	name = "Toggle Geiger Counter"

/datum/action/item_action/toggle_geiger_counter/Trigger()
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

/datum/action/item_action/toggle_research_scanner/Trigger()
	if(IsAvailable())
		owner.research_scanner = !owner.research_scanner
		to_chat(owner, "<span class='notice'>Research analyzer is now [owner.research_scanner ? "active" : "deactivated"].</span>")
		return TRUE

/datum/action/item_action/toggle_research_scanner/Remove(mob/living/L)
	if(owner)
		owner.research_scanner = FALSE
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
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "jetboot"
	use_itemicon = FALSE


/datum/action/item_action/gravity_jump
	name = "Gravity jump"
	desc = "Directs a pulse of gravity in front of the user, pulling them forward rapidly."

/datum/action/item_action/gravity_jump/Trigger()
	if(!IsAvailable())
		return FALSE

	var/obj/item/clothing/shoes/magboots/gravity/G = target
	G.dash(usr)


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

/datum/action/item_action/organ_action/use/eyesofgod/New(target)
	..()
	name = "See with the Eyes of the Gods"
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

/datum/action/item_action/accessory/storage
	name = "View Storage"


/datum/action/item_action/accessory/herald
	name = "Mirror Walk"
	desc = "Use near a mirror to enter it"

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

	if(owner)
		return spell.can_cast(owner)
	return FALSE

/datum/action/spell_action/apply_unavailable_effect()
	var/obj/effect/proc_holder/spell/S = target
	if(!istype(S))
		return ..()

	var/alpha = S.cooldown_handler.get_cooldown_alpha()

	var/image/img = image('icons/mob/screen_white.dmi', icon_state = "template")
	img.alpha = alpha
	img.appearance_flags = RESET_COLOR | RESET_ALPHA
	img.color = "#000000"
	img.plane = FLOAT_PLANE + 1
	button.add_overlay(img)
	// Make a holder for the charge text
	var/image/count_down_holder = image('icons/effects/effects.dmi', icon_state = "nothing")
	count_down_holder.plane = FLOAT_PLANE + 1.1
	var/text = S.cooldown_handler.statpanel_info()
	count_down_holder.maptext = "<div style=\"font-size:6pt;color:[recharge_text_color];font:'Small Fonts';text-align:center;\" valign=\"bottom\">[text]</div>"
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
