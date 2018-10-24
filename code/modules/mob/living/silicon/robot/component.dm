// TODO: remove the robot.mmi and robot.cell variables and completely rely on the robot component system

/datum/robot_component
	var/name = "Component"
	var/installed = 0
	var/powered = 1
	var/toggled = 1
	var/brute_damage = 0
	var/electronics_damage = 0
	var/max_damage = 30
	var/component_disabled = 0
	var/mob/living/silicon/robot/owner

// The actual device object that has to be installed for this.
/datum/robot_component/var/external_type = null

// The wrapped device(e.g. radio), only set if external_type isn't null
/datum/robot_component/var/obj/item/wrapped = null

/datum/robot_component/New(mob/living/silicon/robot/R)
	src.owner = R

/datum/robot_component/proc/install()
	go_online()
/datum/robot_component/proc/uninstall()
	go_offline()

/datum/robot_component/proc/destroy()
	if(wrapped)
		qdel(wrapped)


	wrapped = new/obj/item/broken_device

	// The thing itself isn't there anymore, but some fried remains are.
	installed = -1
	uninstall()

/datum/robot_component/proc/take_damage(brute, electronics, sharp, updating_health = TRUE)
	if(installed != 1)
		return

	if(owner && updating_health)
		owner.updatehealth("component '[src]' take damage")

	brute_damage += brute
	electronics_damage += electronics

	if(brute_damage + electronics_damage >= max_damage)
		destroy()

/datum/robot_component/proc/heal_damage(brute, electronics, updating_health = TRUE)
	if(installed != 1)
		// If it's not installed, can't repair it.
		return 0

	if(owner && updating_health)
		owner.updatehealth("component '[src]' heal damage")

	brute_damage = max(0, brute_damage - brute)
	electronics_damage = max(0, electronics_damage - electronics)

/datum/robot_component/proc/is_powered()
	return (installed == 1) && (brute_damage + electronics_damage < max_damage) && (powered)

/datum/robot_component/proc/consume_power()
	if(toggled == 0)
		powered = 0
		return
	powered = 1

/datum/robot_component/proc/disable()
	if(!component_disabled)
		go_offline()
	component_disabled++

/datum/robot_component/proc/enable()
	component_disabled--
	if(!component_disabled)
		go_online()

/datum/robot_component/proc/toggle()
	toggled = !toggled
	if(toggled)
		go_online()
	else
		go_offline()

/datum/robot_component/proc/go_online()
	return

/datum/robot_component/proc/go_offline()
	return

/datum/robot_component/armour
	name = "armour plating"
	external_type = /obj/item/robot_parts/robot_component/armour
	max_damage = 100

/datum/robot_component/actuator
	name = "actuator"
	external_type = /obj/item/robot_parts/robot_component/actuator
	max_damage = 50

/datum/robot_component/actuator/go_online()
	owner.update_stat()

/datum/robot_component/actuator/go_offline()
	owner.update_stat()

/datum/robot_component/cell
	name = "power cell"
	max_damage = 50

/datum/robot_component/cell/is_powered()
	return ..() && owner.cell

/datum/robot_component/cell/go_online()
	owner.update_stat()

/datum/robot_component/cell/go_offline()
	owner.update_stat()

/datum/robot_component/cell/destroy()
	..()
	owner.cell = null

/datum/robot_component/radio
	name = "radio"
	external_type = /obj/item/robot_parts/robot_component/radio
	max_damage = 40

/datum/robot_component/binary_communication
	name = "binary communication device"
	external_type = /obj/item/robot_parts/robot_component/binary_communication_device
	max_damage = 30

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
	max_damage = 30

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
	return C && C.installed == 1 && C.toggled && C.is_powered() && !C.component_disabled

/mob/living/silicon/robot/proc/disable_component(module_name, duration)
	var/datum/robot_component/D = get_component(module_name)
	D.disable()
	spawn(duration)
		D.enable()

// Returns component by it's string name
/mob/living/silicon/robot/proc/get_component(var/component_name)
	var/datum/robot_component/C = components[component_name]
	return C

/obj/item/broken_device
	name = "broken component"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "broken"

/obj/item/robot_parts/robot_component
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "working"
	var/brute = 0
	var/burn = 0


/obj/item/robot_parts/robot_component/binary_communication_device
	name = "binary communication device"
	icon_state = "binary_translator"

/obj/item/robot_parts/robot_component/actuator
	name = "actuator"
	icon_state = "actuator"

/obj/item/robot_parts/robot_component/armour
	name = "armour plating"
	icon_state = "armor_plating"

/obj/item/robot_parts/robot_component/camera
	name = "camera"
	icon_state = "camera"



/obj/item/robot_parts/robot_component/diagnosis_unit
	name = "diagnosis unit"
	icon_state = "diagnosis_unit"

/obj/item/robot_parts/robot_component/radio
	name = "radio"
	icon_state = "radio"

//
//Robotic Component Analyzer, basically a health analyzer for robots
//
/obj/item/robotanalyzer
	name = "cyborg analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "robotanalyzer"
	item_state = "analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 5
	throw_range = 10
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1;

/obj/item/robotanalyzer/attack(mob/living/M as mob, mob/living/user as mob)
	if(( (CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
		user.visible_message("<span class='warning'>[user] has analyzed the floor's vitals!</span>", "<span class='warning'>You try to analyze the floor's vitals!</span>")
		to_chat(user, "<span class='notice'>Analyzing Results for The floor:\n\t Overall Status: Healthy</span>")
		to_chat(user, "<span class='notice'>\t Damage Specifics: [0]-[0]-[0]-[0]</span>")
		to_chat(user, "<span class='notice'>Key: Suffocation/Toxin/Burns/Brute</span>")
		to_chat(user, "<span class='notice'>Body Temperature: ???</span>")
		return

	var/scan_type
	if(istype(M, /mob/living/silicon/robot))
		scan_type = "robot"
	else if(istype(M, /mob/living/carbon/human))
		scan_type = "prosthetics"
	else
		to_chat(user, "<span class='warning'>You can't analyze non-robotic things!</span>")
		return

	user.visible_message("<span class='notice'>[user] has analyzed [M]'s components.</span>","<span class='notice'>You have analyzed [M]'s components.</span>")
	switch(scan_type)
		if("robot")
			var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
			var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
			to_chat(user, "<span class='notice'>Analyzing Results for [M]:\n\t Overall Status: [M.stat > 1 ? "fully disabled" : "[M.health]% functional"]</span>")
			to_chat(user, "\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>")
			to_chat(user, "\t Damage Specifics: <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>")
			if(M.timeofdeath && M.stat == DEAD)
				to_chat(user, "<span class='notice'>Time of Disable: [station_time_timestamp("hh:mm:ss", M.timeofdeath)]</span>")
			var/mob/living/silicon/robot/H = M
			var/list/damaged = H.get_damaged_components(1,1,1)
			to_chat(user, "<span class='notice'>Localized Damage:</span>")
			if(length(damaged)>0)
				for(var/datum/robot_component/org in damaged)
					user.show_message(text("<span class='notice'>\t []: [][] - [] - [] - []</span>",	\
					capitalize(org.name),					\
					(org.installed == -1)	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
					(org.electronics_damage > 0)	?	"<font color='#FFA500'>[org.electronics_damage]</font>"	:0,	\
					(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
					(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
					(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>"),1)
			else
				to_chat(user, "<span class='notice'>\t Components are OK.</span>")
			if(H.emagged && prob(5))
				to_chat(user, "<span class='warning'>\t ERROR: INTERNAL SYSTEMS COMPROMISED</span>")

		if("prosthetics")
			var/mob/living/carbon/human/H = M
			to_chat(user, "<span class='notice'>Analyzing Results for \the [H]:</span>")
			to_chat(user, "Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>")

			to_chat(user, "<span class='notice'>External prosthetics:</span>")
			var/organ_found
			if(H.internal_organs.len)
				for(var/obj/item/organ/external/E in H.bodyparts)
					if(!E.is_robotic())
						continue
					organ_found = 1
					to_chat(user, "[E.name]: <font color='red'>[E.brute_dam]</font> <font color='#FFA500'>[E.burn_dam]</font>")
			if(!organ_found)
				to_chat(user, "<span class='warning'>No prosthetics located.</span>")
			to_chat(user, "<hr>")
			to_chat(user, "<span class='notice'>Internal prosthetics:</span>")
			organ_found = null
			if(H.internal_organs.len)
				for(var/obj/item/organ/internal/O in H.internal_organs)
					if(!O.is_robotic())
						continue
					organ_found = 1
					to_chat(user, "[capitalize(O.name)]: <font color='red'>[O.damage]</font>")
			if(!organ_found)
				to_chat(user, "<span class='warning'>No prosthetics located.</span>")

			if(H.isSynthetic())
				to_chat(user, "<span class='notice'>Internal Fluid Level:[H.blood_volume]/[H.max_blood]</span>")
				if(H.bleed_rate)
					to_chat(user, "<span class='warning'>Warning:External component leak detected!</span>")

	src.add_fingerprint(user)
