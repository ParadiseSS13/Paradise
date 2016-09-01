#define AB_CHECK_RESTRAINED 1
#define AB_CHECK_STUNNED 2
#define AB_CHECK_LYING 4
#define AB_CHECK_CONSCIOUS 8


/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/obj/target = null
	var/check_flags = 0
	var/processing = 0
	var/obj/screen/movable/action_button/button = null
	var/button_icon = 'icons/mob/actions.dmi'
	var/background_icon_state = "bg_default"

	var/icon_icon = 'icons/mob/actions.dmi'
	var/button_icon_state = "default"
	var/mob/owner

/datum/action/New(var/Target)
	target = Target
	button = new
	button.linked_action = src
	button.name = name

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	if(target)
		target = null
	qdel(button)
	button = null
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
	M.update_action_buttons()

/datum/action/proc/Remove(mob/M)
	if(M.client)
		M.client.screen -= button
	button.moved = FALSE //so the button appears in its normal position when given to another owner.
	M.actions -= src
	M.update_action_buttons()
	owner = null

/datum/action/proc/Trigger()
	if(!IsAvailable())
		return 0
	return 1

/datum/action/proc/Process()
	return

/datum/action/proc/IsAvailable()// returns 1 if all checks pass
	if(!owner)
		return 0
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return 0
	if(check_flags & AB_CHECK_STUNNED)
		if(owner.stunned || owner.weakened)
			return 0
	if(check_flags & AB_CHECK_LYING)
		if(owner.lying)
			return 0
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return 0
	return 1

/datum/action/proc/UpdateButtonIcon()
	if(button)
		button.icon = button_icon
		button.icon_state = background_icon_state

		ApplyIcon(button)

		if(!IsAvailable())
			button.color = rgb(128,0,0,128)
		else
			button.color = rgb(255,255,255,255)
			return 1

/datum/action/proc/ApplyIcon(obj/screen/movable/action_button/current_button)
	current_button.overlays.Cut()
	if(icon_icon && button_icon_state)
		var/image/img
		img = image(icon_icon, current_button, button_icon_state)
		img.pixel_x = 0
		img.pixel_y = 0
		current_button.overlays += img

//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS

/datum/action/item_action/New(Target)
	..()
	var/obj/item/I = target
	I.actions += src

/datum/action/item_action/Destroy()
	var/obj/item/I = target
	I.actions -= src
	return ..()

/datum/action/item_action/Trigger()
	if(!..())
		return 0
	if(target)
		var/obj/item/I = target
		I.ui_action_click(owner, type)
	return 1

/datum/action/item_action/ApplyIcon(obj/screen/movable/action_button/current_button)
	current_button.overlays.Cut()
	if(target)
		var/obj/item/I = target
		var/old_layer = I.layer
		var/old_plane = I.plane
		I.layer = 21
		I.plane = HUD_PLANE
		current_button.overlays += I
		I.layer = old_layer
		I.plane = old_plane

/datum/action/item_action/toggle_light
	name = "Toggle Light"

/datum/action/item_action/toggle_hood
	name = "Toggle Hood"

/datum/action/item_action/toggle_firemode
	name = "Toggle Firemode"

/datum/action/item_action/startchainsaw
	name = "Pull The Starting Cord"

/datum/action/item_action/print_report
	name = "Print Forensic Report"

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
				button.icon_state = "bg_default_on"

/datum/action/item_action/toggle_mister
	name = "Toggle Mister"

/datum/action/item_action/toggle_headphones
	name = "Toggle Headphones"

/datum/action/item_action/toggle_helmet_light
	name = "Toggle Helmet Light"

/datum/action/item_action/toggle_helmet_mode
	name = "Toggle Helmet Mode"

/datum/action/item_action/toggle_hardsuit_mode
	name = "Toggle Hardsuit Mode"

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

/datum/action/item_action/toggle_jetpack
	name = "Toggle Jetpack"

/datum/action/item_action/jetpack_stabilization
	name = "Toggle Jetpack Stabilization"

/datum/action/item_action/jetpack_stabilization/IsAvailable()
	var/obj/item/weapon/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		return 0
	return ..()

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
		return 1

/datum/action/item_action/toggle_research_scanner/Remove(mob/living/L)
	if(owner)
		owner.research_scanner = 0
	..()

/datum/action/item_action/toggle_research_scanner/ApplyIcon(obj/screen/movable/action_button/current_button)
	current_button.overlays.Cut()
	if(button_icon && button_icon_state)
		var/image/img = image(button_icon, current_button, "scan_mode")
		current_button.overlays += img

/datum/action/item_action/remove_badge
	name = "Remove Holobadge"

///prset for organ actions
/datum/action/item_action/organ_action
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/IsAvailable()
	var/obj/item/organ/internal/I = target
	if(!I.owner)
		return 0
	return ..()

/datum/action/item_action/organ_action/toggle

/datum/action/item_action/organ_action/toggle/New(Target)
	..()
	name = "Toggle [target.name]"
	button.name = name

// for clothing accessories like holsters
/datum/action/item_action/accessory
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS

/datum/action/item_action/accessory/IsAvailable()
	. = ..()
	if(!.)
		return 0
	if(target.loc == owner)
		return 1
	if(istype(target.loc, /obj/item/clothing/under) && target.loc.loc == owner)
		return 1
	return 0

/datum/action/item_action/accessory/holster
	name = "Holster"

/datum/action/item_action/accessory/storage
	name = "View Storage"


//Preset for spells
/datum/action/spell_action
	check_flags = 0
	background_icon_state = "bg_spell"

/datum/action/spell_action/New(Target)
	..()
	var/obj/effect/proc_holder/spell/S = target
	S.action = src
	name = S.name
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
		return 0
	if(target)
		var/obj/effect/proc_holder/spell = target
		spell.Click()
		return 1

/datum/action/spell_action/IsAvailable()
	if(!target)
		return 0
	var/obj/effect/proc_holder/spell/spell = target

	if(owner)
		return spell.can_cast(owner)
	return 0

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
	var/active = 0

/datum/action/innate/Trigger()
	if(!..())
		return 0
	if(!active)
		Activate()
	else
		Deactivate()
	return 1

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
		return 0
	if(target && procname)
		call(target,procname)(usr)
	return 1
