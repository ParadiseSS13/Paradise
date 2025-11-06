// TODO: remove the robot.mmi and robot.cell variables and completely rely on the robot component system

/datum/robot_component
	var/name = "Component"
	var/installed = FALSE
	var/powered = TRUE
	var/toggled = TRUE
	var/brute_damage = 0
	var/electronics_damage = 0
	var/max_damage = 30
	var/component_disabled = FALSE
	var/mob/living/silicon/robot/owner
	var/external_type = null // The actual device object that has to be installed for this.
	var/obj/item/wrapped = null // The wrapped device(e.g. radio), only set if external_type isn't null
	///How much a component is contributing to slowdown, set on New to be equal to min_slowdown_factor
	var/current_slowdown_factor
	///The max amount of slowness a component can contribute, set on New to be 1% of the max damage
	var/max_slowdown_factor
	///The minimum amount of speed modification a component can contribute. Currently just 0 for all.
	var/min_slowdown_factor = 0

/datum/robot_component/New(mob/living/silicon/robot/R)
	owner = R
	max_slowdown_factor = (max_damage / 100)
	current_slowdown_factor = min_slowdown_factor

// Should only ever be destroyed when a borg gets destroyed
/datum/robot_component/Destroy(force, ...)
	owner = null
	QDEL_NULL(wrapped)
	return ..()

/datum/robot_component/proc/install(obj/item/I, update_health = TRUE)
	wrapped = I
	installed = TRUE
	I.forceMove(owner)
	current_slowdown_factor = (brute_damage + electronics_damage) / 100
	go_online()
	if(update_health)
		owner.updatehealth("component '[src]' installed")

/datum/robot_component/proc/uninstall()
	wrapped = null
	installed = FALSE
	go_offline()
	owner.updatehealth("component '[src]' removed")

/datum/robot_component/proc/break_component()
	if(wrapped)
		qdel(wrapped)
	uninstall()
	wrapped = new/obj/item/broken_device

/datum/robot_component/proc/take_damage(brute, electronics, sharp, updating_health = TRUE)
	if(!installed)
		return

	if(owner && updating_health)
		owner.updatehealth("component '[src]' take damage")

	brute_damage += brute
	electronics_damage += electronics
	current_slowdown_factor = clamp((current_slowdown_factor + ((brute + electronics) / 100)), min_slowdown_factor, max_slowdown_factor)
	if(brute_damage + electronics_damage >= max_damage)
		break_component()

	SStgui.update_uis(owner.self_diagnosis)

/datum/robot_component/proc/heal_damage(brute, electronics, updating_health = TRUE)
	if(!installed)
		// If it's not installed, can't repair it.
		return 0

	if(owner && updating_health)
		owner.updatehealth("component '[src]' heal damage")
	var/burn_damage_healed = clamp(electronics, 0, electronics_damage)
	var/brute_damage_healed = clamp(brute, 0, brute_damage)
	current_slowdown_factor = clamp((current_slowdown_factor - ((burn_damage_healed + brute_damage_healed) / 100)), min_slowdown_factor, max_slowdown_factor)
	rounding_error_check()
	brute_damage -= brute_damage_healed
	electronics_damage -= burn_damage_healed
	SStgui.update_uis(owner.self_diagnosis)

///There tends to be some desync between slowdown and damage when being healed up slowly like through self-repair or upgraded rechargers.
/datum/robot_component/proc/rounding_error_check()
	if(current_slowdown_factor < (min_slowdown_factor) + 0.0001) //Within .0001 of the minimum, just set it to the minimum
		current_slowdown_factor = min_slowdown_factor

/datum/robot_component/proc/is_powered()
	return installed && (brute_damage + electronics_damage < max_damage) && (powered)

/datum/robot_component/proc/is_destroyed()
	return istype(wrapped, /obj/item/broken_device)


/datum/robot_component/proc/is_missing()
	return isnull(wrapped)

/datum/robot_component/proc/consume_power()
	if(!toggled)
		powered = FALSE
		return
	powered = TRUE

	SStgui.update_uis(owner.self_diagnosis)

/datum/robot_component/proc/disable()
	if(!component_disabled)
		go_offline()
		component_disabled = TRUE

/datum/robot_component/proc/enable()
	if(component_disabled)
		go_online()
		component_disabled = FALSE

/datum/robot_component/proc/toggle()
	toggled = !toggled
	if(toggled)
		go_online()
	else
		go_offline()

	SStgui.update_uis(owner.self_diagnosis)

/datum/robot_component/proc/go_online()
	return

/datum/robot_component/proc/go_offline()
	return

/datum/robot_component/proc/get_movement_delay()
	if(is_missing())
		return 0
	if(is_destroyed())
		return max_slowdown_factor
	return  current_slowdown_factor

/datum/robot_component/armour
	name = "armour plating"
	external_type = /obj/item/robot_parts/robot_component/armour
	max_damage = 100

/datum/robot_component/actuator
	name = "actuator"
	external_type = /obj/item/robot_parts/robot_component/actuator
	max_damage = 50

/datum/robot_component/cell
	name = "power cell"
	max_damage = 50

/datum/robot_component/cell/install(obj/item/stock_parts/cell/C)
	external_type = C.type // Update the cell component's `external_type` to the path of new cell
	owner.cell = C
	..()

/datum/robot_component/cell/uninstall()
	..()
	owner.cell = null

/datum/robot_component/cell/is_powered()
	return ..() && owner.cell?.charge

/datum/robot_component/cell/Destroy(force, ...)
	owner.cell = null
	return ..()

/datum/robot_component/cell/break_component()
	..()
	owner.cell = null

/datum/robot_component/cell/disable() //This can't be manually disabled, and shouldn't be accidentally disabled
	return

/datum/robot_component/radio
	name = "radio"
	external_type = /obj/item/robot_parts/robot_component/radio
	max_damage = 40

/datum/robot_component/binary_communication
	name = "binary communication device"
	external_type = /obj/item/robot_parts/robot_component/binary_communication_device

/datum/robot_component/camera
	name = "camera"
	external_type = /obj/item/robot_parts/robot_component/camera
	max_damage = 40

/datum/robot_component/camera/go_online()
	owner.update_blind_effects()
	owner.update_sight()

/datum/robot_component/camera/go_offline()
	owner.update_blind_effects()
	owner.update_sight()

/datum/robot_component/diagnosis_unit
	name = "self-diagnosis unit"
	external_type = /obj/item/robot_parts/robot_component/diagnosis_unit

/mob/living/silicon/robot/proc/initialize_components()
	// This only initializes the components, it doesn't set them to installed.

	components["actuator"] = new/datum/robot_component/actuator(src)
	components["radio"] = new/datum/robot_component/radio(src)
	components["power cell"] = new/datum/robot_component/cell(src)
	components["diagnosis unit"] = new/datum/robot_component/diagnosis_unit(src)
	components["camera"] = new/datum/robot_component/camera(src)
	components["comms"] = new/datum/robot_component/binary_communication(src)
	components["armour"] = new/datum/robot_component/armour(src)

/mob/living/silicon/robot/proc/is_component_functioning(module_name)
	var/datum/robot_component/C = components[module_name]
	return C && C.installed && C.toggled && C.is_powered() && !C.component_disabled

///Disables a random component for the duration, or until manually turned back on.
/mob/living/silicon/robot/proc/disable_random_component(number_disabled, duration)
	var/list/random_components = pick_multiple_unique(components, number_disabled)
	for(var/component in random_components)
		disable_component(component, duration)

/mob/living/silicon/robot/proc/disable_component(module_name, duration)
	var/datum/robot_component/D = get_component(module_name)
	D.disable()
	addtimer(CALLBACK(src, PROC_REF(reenable_component), D), duration)

/mob/living/silicon/robot/proc/reenable_component(datum/robot_component/to_enable)
	to_enable.enable()

// Returns component by it's string name
/mob/living/silicon/robot/proc/get_component(component_name)
	var/datum/robot_component/C = components[component_name]
	return C

/obj/item/broken_device
	name = "broken component"
	desc = "A component of a robot, broken to the point of being unidentifiable."
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "broken"

/obj/item/robot_parts/robot_component
	icon = 'icons/obj/robot_component.dmi'
	desc = "One of the numerous parts required to make a robot work."
	icon_state = "working"
	var/brute = 0
	var/burn = 0


/obj/item/robot_parts/robot_component/binary_communication_device
	name = "binary communication device"
	desc = "A module used for binary communications over encrypted frequencies, commonly used by synthetic robots."
	icon_state = "binary_translator"

/obj/item/robot_parts/robot_component/actuator
	name = "actuator"
	desc = "A modular, hydraulic actuator used by robots for movement and manipulation."
	icon_state = "actuator"

/obj/item/robot_parts/robot_component/armour
	name = "armour plating"
	desc = "A pair of flexible, adaptable armor plates, used to protect the internals of robots."
	icon_state = "armor_plating"

/obj/item/robot_parts/robot_component/camera
	name = "camera"
	desc = "A modified camera module used as a visual receptor for robots and exosuits, also serving as a relay for wireless video feed."
	icon_state = "camera"

/obj/item/robot_parts/robot_component/diagnosis_unit
	name = "diagnosis unit"
	desc = "An internal computer and sensors used by robots and exosuits to accurately diagnose any system discrepancies on their components."
	icon_state = "diagnosis_unit"

/obj/item/robot_parts/robot_component/radio
	name = "radio"
	desc = "A modular, multi-frequency radio used by robots and exosuits to enable communication systems. Comes with built-in subspace receivers."
	icon_state = "radio"
