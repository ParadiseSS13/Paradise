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
	var/button_icon = 'icons/mob/actions/actions.dmi'
	var/background_icon_state = "bg_default"

	var/icon_icon = 'icons/mob/actions/actions.dmi'
	var/button_icon_state = "default"
	var/mob/owner

/datum/action/New(var/Target)
	target = Target
	button = new
	button.linked_action = src
	button.name = name
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
		if(owner.stunned || owner.IsWeakened())
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
		button.desc = desc

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
		return 0
	if(target && attack_self)
		var/obj/item/I = target
		I.ui_action_click(owner, type)
	return 1

/datum/action/item_action/ApplyIcon(obj/screen/movable/action_button/current_button)
	if(use_itemicon)
		current_button.overlays.Cut()
		if(target)
			var/obj/item/I = target
			var/old_layer = I.layer
			var/old_plane = I.plane
			I.layer = FLOAT_LAYER //AAAH
			I.plane = FLOAT_PLANE //^ what that guy said
			current_button.cut_overlays()
			current_button.add_overlay(I)
			I.layer = old_layer
			I.plane = old_plane
	else
		..()
/datum/action/item_action/toggle_light
	name = "Alternar Luz"

/datum/action/item_action/toggle_hood
	name = "Alternar Capucha"

/datum/action/item_action/toggle_firemode
	name = "Alternar Modo de Fuego"

/datum/action/item_action/startchainsaw
	name = "Pull The Starting Cord"

/datum/action/item_action/print_report
	name = "Imprimir Reporte"

/datum/action/item_action/toggle_gunlight
	name = "Alternar Luz del Arma"

/datum/action/item_action/toggle_mode
	name = "Alternar Modo"

/datum/action/item_action/toggle_barrier_spread
	name = "Toggle Barrier Spread"

/datum/action/item_action/equip_unequip_TED_Gun
	name = "Equip/Unequip TED Gun"

/datum/action/item_action/toggle_paddles
	name = "Alternar Paletas"

/datum/action/item_action/set_internals
	name = "Alternar Internals"

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

/datum/action/item_action/toggle_welding_screen/plasmaman
	name = "Toggle Welding Screen"

/datum/action/item_action/toggle_welding_screen/plasmaman/Trigger()
	var/obj/item/clothing/head/helmet/space/plasmaman/H = target
	if(istype(H))
		H.toggle_welding_screen(owner)

/datum/action/item_action/toggle_helmet_mode
	name = "Alternar Modo Casco"

/datum/action/item_action/toggle_hardsuit_mode
	name = "Alternar Modo Hardsuit"

/datum/action/item_action/toggle_unfriendly_fire
	name = "Alternar Fuego Amigo \[ON\]"
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
			name = "Alternar Fuego Amigo \[OFF\]"
			button.name = name
		else
			button_icon_state = "vortex_ff_on"
			name = "Alternar Fuego Amigo \[ON\]"
			button.name = name
	..()

/datum/action/item_action/synthswitch
	name = "Cambiar Instrumento del Sintetizador"
	desc = "Cambio el tipo de instrumento que reproduce tu sintetizador."

/datum/action/item_action/synthswitch/Trigger()
	if(istype(target, /obj/item/instrument/piano_synth))
		var/obj/item/instrument/piano_synth/synth = target
		var/chosen = input("Elige el tipo de instrumento que quieres usar", "Seleccion de instrumento", "piano") as null|anything in synth.insTypes
		if(!synth.insTypes[chosen])
			return
		return synth.changeInstrument(chosen)
	return ..()

/datum/action/item_action/vortex_recall
	name = "Vortex Recall"
	desc = "Recall yourself, and anyone nearby, to an attuned hierophant beacon at any time.<br>If the beacon is still attached, will detach it."
	button_icon_state = "vortex_recall"

/datum/action/item_action/vortex_recall/IsAvailable()
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/H = target
		if(H.teleporting)
			return 0
	return ..()

/datum/action/item_action/toggle

/datum/action/item_action/toggle/New(Target)
	..()
	name = "Alternar [target.name]"
	button.name = name

/datum/action/item_action/openclose

/datum/action/item_action/openclose/New(Target)
	..()
	name = "Abrir/Cerrar [target.name]"
	button.name = name

/datum/action/item_action/button

/datum/action/item_action/button/New(Target)
	..()
	name = "Botonar/Desbotonar [target.name]"
	button.name = name

/datum/action/item_action/zipper

/datum/action/item_action/zipper/New(Target)
	..()
	name = "Zip/Unzip [target.name]"
	button.name = name

/datum/action/item_action/halt
	name = "HALT!"

/datum/action/item_action/selectphrase
	name = "Cambiar Frase"

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
	name = "Ajustar [target.name]"
	button.name = name

/datum/action/item_action/pontificate
	name = "Pontificate Evilly"

/datum/action/item_action/tip_fedora
	name = "Tocar Fedora"

/datum/action/item_action/flip_cap
	name = "Girar Gorra"

/datum/action/item_action/switch_hud
	name = "Cambiar HUD"

/datum/action/item_action/toggle_wings
	name = "Alternar Alas"

/datum/action/item_action/toggle_helmet
	name = "Alternar Casco"

/datum/action/item_action/remove_tape
	name = "Remover Cinta"

/datum/action/item_action/remove_tape/Trigger(attack_self = FALSE)
	if(..())
		GET_COMPONENT_FROM(DT, /datum/component/ducttape, target)
		DT.remove_tape(target, usr)

/datum/action/item_action/toggle_jetpack
	name = "Alternar Jetpack"

/datum/action/item_action/jetpack_stabilization
	name = "Alternar Estabilizacion de Jetpack"

/datum/action/item_action/jetpack_stabilization/IsAvailable()
	var/obj/item/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		return 0
	return ..()

/datum/action/item_action/hands_free
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/hands_free/activate
	name = "Activar"

/datum/action/item_action/toggle_research_scanner
	name = "Alternar Escaner de Investigacion"
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

/datum/action/item_action/instrument
	name = "Usar Instrumento"
	desc = "Usar el instrumento especificado"

/datum/action/item_action/instrument/Trigger()
	if(istype(target, /obj/item/instrument))
		var/obj/item/instrument/I = target
		I.interact(usr)
		return
	return ..()


/datum/action/item_action/remove_badge
	name = "Remover Holo Insignia"

// Jump boots
/datum/action/item_action/bhop
	name = "Activar botas de salto"
	desc = "Activa el sistema de propulsion interno de la bota de salto, Permitiendo al usuario atravesar 4 tiles de ancho."
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "jetboot"

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
	name = "Alternar [target.name]"
	button.name = name

/datum/action/item_action/organ_action/use/New(Target)
	..()
	name = "Usar [target.name]"
	button.name = name

/datum/action/item_action/voice_changer/toggle
	name = "Alternar Cambiador de Voz"

/datum/action/item_action/voice_changer/voice
	name = "Establecer voz"

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
		return 0
	if(target.loc == owner)
		return 1
	if(istype(target.loc, /obj/item/clothing/under) && target.loc.loc == owner)
		return 1
	return 0

/datum/action/item_action/accessory/holster
	name = "Funda"

/datum/action/item_action/accessory/storage
	name = "Ver Almacenamiento"


//Preset for spells
/datum/action/spell_action
	check_flags = 0
	background_icon_state = "bg_spell"

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
		return 0
	if(target)
		var/obj/effect/proc_holder/spell = target
		spell.Click()
		return 1

/datum/action/spell_action/IsAvailable()
	if(!target)
		return 0
	var/obj/effect/proc_holder/spell/spell = target

	if(spell.special_availability_check)
		return 1

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
