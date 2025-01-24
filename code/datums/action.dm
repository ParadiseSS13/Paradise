
/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/obj/target = null
	var/check_flags = 0
	/// Icon that our button screen object overlay and background
	var/button_overlay_icon = 'icons/mob/actions/actions.dmi'
	/// Icon state of screen object overlay
	var/button_overlay_icon_state = ACTION_BUTTON_DEFAULT_OVERLAY
	/// Icon that our button screen object background will have
	var/button_background_icon = 'icons/mob/actions/actions.dmi'
	/// Icon state of screen object background
	var/button_background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
	var/buttontooltipstyle = ""
	var/transparent_when_unavailable = TRUE
	var/mob/owner
	/// Where any buttons we create should be by default. Accepts screen_loc and location defines
	var/default_button_position = SCRN_OBJ_IN_LIST
	/// Map of huds viewing a button with our action -> their button
	var/list/viewers = list()
	/// Whether or not this will be shown to observers
	var/show_to_observers = TRUE


/datum/action/New(Target)
	target = Target

/datum/action/proc/should_draw_cooldown()
	return !IsAvailable()

/datum/action/proc/clear_ref(datum/ref)
	SIGNAL_HANDLER
	if(ref == owner)
		Remove(owner)
	if(ref == target)
		qdel(src)

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	if(target)
		target = null
	QDEL_LIST_ASSOC_VAL(viewers) // Qdel the buttons in the viewers list **NOT THE HUDS**
	return ..()

/datum/action/proc/Grant(mob/M)
	if(!M)
		Remove(owner)
		return
	if(owner)
		if(owner == M)
			return
		Remove(owner)
	owner = M
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref), override = TRUE)
	SEND_SIGNAL(src, COMSIG_ACTION_GRANTED, owner)
	SEND_SIGNAL(owner, COMSIG_MOB_GRANTED_ACTION, src)
	GiveAction(M)

/datum/action/proc/Remove(mob/remove_from)
	for(var/datum/hud/hud in viewers)
		if(!hud.mymob)
			continue
		HideFrom(hud.mymob)

	remove_from?.actions -= src // We aren't always properly inserted into the viewers list, gotta make sure that action's cleared
	viewers = list()
	// owner = null

	if(isnull(owner))
		return

	SEND_SIGNAL(src, COMSIG_ACTION_REMOVED, owner)
	SEND_SIGNAL(owner, COMSIG_MOB_REMOVED_ACTION, src)

	if(target == owner)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref), override = TRUE)
	if(owner == remove_from)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
		owner = null

/datum/action/proc/UpdateButtons(status_only, force)
	for(var/datum/hud/hud in viewers)
		var/atom/movable/screen/movable/button = viewers[hud]
		UpdateButton(button, status_only, force)

/datum/action/proc/Trigger(left_click = TRUE)
	if(!IsAvailable())
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	return TRUE

/datum/action/proc/AltTrigger()
	Trigger()
	return FALSE

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

/datum/action/proc/UpdateButton(atom/movable/screen/movable/action_button/button, status_only = FALSE, force = FALSE)
	if(!button)
		return
	if(!status_only)
		button.name = name
		if(desc)
			button.desc = "[desc] [initial(button.desc)]"
		if(owner?.hud_used && button_background_icon_state == ACTION_BUTTON_DEFAULT_BACKGROUND)
			var/list/settings = owner.hud_used.get_action_buttons_icons()
			if(button.icon != settings["bg_icon"])
				button.icon = settings["bg_icon"]
			if(button.icon_state != settings["bg_state"])
				button.icon_state = settings["bg_state"]
		else
			if(button.icon != button_background_icon)
				button.icon = button_background_icon
			if(button.icon_state != button_background_icon_state)
				button.icon_state = button_background_icon_state

		apply_button_overlay(button, force)

	if(should_draw_cooldown())
		apply_unavailable_effect(button)
	else
		return TRUE

//Give our action button to the player
/datum/action/proc/GiveAction(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	if(viewers[our_hud]) // Already have a copy of us? go away
		return
	viewer.actions |= src // Move this in
	ShowTo(viewer)

//Adds our action button to the screen of a player
/datum/action/proc/ShowTo(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	if(!our_hud || viewers[our_hud]) // There's no point in this if you have no hud in the first place
		return


	var/atom/movable/screen/movable/action_button/button = CreateButton()
	SetId(button, viewer)

	button.our_hud = our_hud
	viewers[our_hud] = button
	if(viewer.client)
		viewer.client.screen += button

	button.load_position(viewer)
	viewer.update_action_buttons()


//Removes our action button from the screen of a player
/datum/action/proc/HideFrom(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	var/atom/movable/screen/movable/action_button/button = viewers[our_hud]
	viewer.actions -= src
	if(button)
		button.clean_up_keybinds(viewer)
		qdel(button)


/datum/action/proc/CreateButton()
	var/atom/movable/screen/movable/action_button/button = new()
	button.linked_action = src
	button.name = name
	button.actiontooltipstyle = buttontooltipstyle
	var/list/our_description = list()
	our_description += desc
	our_description += button.desc
	button.desc = our_description.Join(" ")
	return button


/datum/action/proc/SetId(atom/movable/screen/movable/action_button/our_button, mob/owner)
	//button id generation
	var/bitfield = 0
	for(var/datum/action/action in owner.actions)
		if(action == src) // This could be us, which is dumb
			continue
		var/atom/movable/screen/movable/action_button/button = action.viewers[owner.hud_used]
		if(action.name == name && button?.id)
			bitfield |= button.id

	bitfield = ~bitfield // Flip our possible ids, so we can check if we've found a unique one
	for(var/i in 0 to 23) // We get 24 possible bitflags in dm
		var/bitflag = 1 << i // Shift us over one
		if(bitfield & bitflag)
			our_button.id = bitflag
			return

/datum/action/proc/apply_unavailable_effect(atom/movable/screen/movable/action_button/B)
	var/image/img = image('icons/mob/screen_white.dmi', icon_state = "template")
	img.alpha = 200
	img.appearance_flags = RESET_COLOR | RESET_ALPHA
	img.color = "#000000"
	img.plane = FLOAT_PLANE + 1
	B.add_overlay(img)


/datum/action/proc/apply_button_overlay(atom/movable/screen/movable/action_button/current_button)
	current_button.cut_overlays()
	if(button_overlay_icon && button_overlay_icon_state)
		var/image/img = image(button_overlay_icon, current_button, button_overlay_icon_state)
		img.appearance_flags = RESET_COLOR | RESET_ALPHA
		img.pixel_x = 0
		img.pixel_y = 0
		current_button.add_overlay(img)

//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS
	var/use_itemicon = TRUE

/datum/action/item_action/New(Target, custom_icon, custom_icon_state)
	..()
	var/obj/item/I = target
	I.actions += src
	if(custom_icon && custom_icon_state)
		use_itemicon = FALSE
		button_overlay_icon = custom_icon
		button_overlay_icon_state = custom_icon_state
	UpdateButtons()

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

/datum/action/item_action/apply_button_overlay(atom/movable/screen/movable/action_button/current_button)
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
	button_overlay_icon_state = "scanner_print"
	use_itemicon = FALSE

/datum/action/item_action/clear_records
	name = "Clear Scanner Records"

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

/datum/action/item_action/set_internals/UpdateButton(atom/movable/screen/movable/action_button/button, status_only = FALSE, force)
	if(!..()) // no button available
		return
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner
	if(target == C.internal)
		button.icon_state = "template_active"

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
	button_overlay_icon_state = "vortex_ff_on"

/datum/action/item_action/toggle_unfriendly_fire/Trigger(left_click)
	if(..())
		UpdateButtons()

/datum/action/item_action/toggle_unfriendly_fire/UpdateButtons()
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/H = target
		if(H.friendly_fire_check)
			button_overlay_icon_state = "vortex_ff_off"
			name = "Toggle Friendly Fire \[OFF\]"
		else
			button_overlay_icon_state = "vortex_ff_on"
			name = "Toggle Friendly Fire \[ON\]"
	..()

/datum/action/item_action/vortex_recall
	name = "Vortex Recall"
	desc = "Recall yourself, and anyone nearby, to an attuned hierophant beacon at any time.<br>If the beacon is still attached, will detach it."
	button_overlay_icon_state = "vortex_recall"

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

/datum/action/item_action/jetpack_stabilization/IsAvailable()
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
	button_overlay_icon_state = "scan_mode"

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
	if(button_overlay_icon && button_overlay_icon_state)
		var/image/img = image(button_overlay_icon, current_button, "scan_mode")
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
	button_overlay_icon_state = "clown"

// Jump boots
/datum/action/item_action/bhop
	name = "Activate Jump Boots"
	desc = "Activates the jump boot's internal propulsion system, allowing the user to dash over 4-wide gaps."
	button_overlay_icon = 'icons/mob/actions/actions.dmi'
	button_overlay_icon_state = "jetboot"
	use_itemicon = FALSE


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

/datum/action/item_action/organ_action/IsAvailable()
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



//Preset for spells
/datum/action/spell_action
	check_flags = 0
	button_background_icon_state = "bg_spell"
	var/recharge_text_color = "#FFFFFF"

/datum/action/spell_action/New(Target)
	..()
	var/datum/spell/S = target
	S.action = src
	name = S.name
	desc = S.desc
	button_overlay_icon = S.action_icon
	button_background_icon = S.action_background_icon
	button_overlay_icon_state = S.action_icon_state
	button_background_icon_state = S.action_background_icon_state
	UpdateButtons()


/datum/action/spell_action/Destroy()
	var/datum/spell/S = target
	S.action = null
	return ..()

/datum/action/spell_action/should_draw_cooldown()
	var/datum/spell/S = target
	return S.cooldown_handler.should_draw_cooldown()

/datum/action/spell_action/Trigger(left_click)
	if(!..())
		return FALSE
	if(target)
		var/datum/spell/spell = target
		spell.Click()
		return TRUE

/datum/action/spell_action/AltTrigger()
	if(target)
		var/datum/spell/spell = target
		spell.AltClick(usr)
		return TRUE

/datum/action/spell_action/IsAvailable()
	if(!target)
		return FALSE
	var/datum/spell/spell = target

	if(owner)
		return spell.can_cast(owner, show_message = TRUE)
	return FALSE

/datum/action/spell_action/apply_unavailable_effect(atom/movable/screen/movable/action_button/button)
	var/datum/spell/S = target
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
	var/text = S.cooldown_handler.cooldown_info()
	count_down_holder.maptext = "<div style=\"font-size:6pt;color:[recharge_text_color];font:'Small Fonts';text-align:center;\" valign=\"bottom\">[text]</div>"
	button.add_overlay(count_down_holder)

//Preset for general and toggled actions
/datum/action/innate
	check_flags = 0
	var/active = FALSE

/datum/action/innate/Trigger(left_click)
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

/datum/action/generic/Trigger(left_click)
	if(!..())
		return FALSE
	if(target && procname)
		call(target,procname)(usr)
	return TRUE
