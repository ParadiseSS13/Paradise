#define STANDARD_STACK_AMOUNT 5

////////////////////////////////
///// Construction datums //////
////////////////////////////////

/datum/construction/mecha/custom_action(step, atom/used_atom, mob/user)
	if(istype(used_atom, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = used_atom
		if(C.use(4))
			playsound(holder, C.usesound, 50, 1)
		else
			to_chat(user, ("There's not enough cable to finish the task."))
			return 0
	else if(istype(used_atom, /obj/item/stack))
		var/obj/item/stack/S = used_atom
		if(S.amount < STANDARD_STACK_AMOUNT)
			to_chat(user, ("There's not enough material in this stack."))
			return 0
		else
			S.use(STANDARD_STACK_AMOUNT)
	else
		return ..()

/datum/construction/mecha/spawn_result(name)
	SSblackbox.record_feedback("tally", "mechas_created", 1, "[name]")

/datum/construction/reversible/mecha/custom_action(index as num, diff as num, atom/used_atom, mob/user as mob)
	if(istype(used_atom, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = used_atom
		if(C.use(4))
			playsound(holder, C.usesound, 50, 1)
		else
			to_chat(user, ("There's not enough cable to finish the task."))
			return 0
	else if(istype(used_atom, /obj/item/stack))
		var/obj/item/stack/S = used_atom
		if(S.amount < STANDARD_STACK_AMOUNT)
			to_chat(user, ("There's not enough material in this stack."))
			return 0
		else
			S.use(STANDARD_STACK_AMOUNT)
	else if(isitem(used_atom))
		var/obj/item/I = used_atom
		if(I.tool_behaviour in CONSTRUCTION_TOOL_BEHAVIOURS)
			if(!I.use_tool(holder, user, 0, volume = I.tool_volume))
				return 0
	return 1


/datum/construction/mecha/ripley_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/ripley_torso),//1
					 list("key"=/obj/item/mecha_parts/part/ripley_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/ripley_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/ripley_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/ripley_right_leg)//5
					)

/datum/construction/mecha/ripley_chassis/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] has connected [used_atom] to the [holder].", "You connect [used_atom] to the [holder]")
	holder.overlays += used_atom.icon_state+"+o"
	qdel(used_atom)
	return 1

/datum/construction/mecha/ripley_chassis/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)

/datum/construction/mecha/ripley_chassis/spawn_result()
	..("Ripley")
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/ripley(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "ripley0"
	const_holder.density = 1
	const_holder.overlays.len = 0
	qdel(src)
	return


/datum/construction/reversible/mecha/ripley
	result = "/obj/mecha/working/ripley"
	taskpath = /datum/job_objective/make_ripley
	steps = list(
					//1
					list("key"=TOOL_WELDER,
							"backkey"=TOOL_WRENCH,
							"desc"="External armor is wrenched."),
					//2
					 list("key"=TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=TOOL_WELDER,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=TOOL_WELDER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="Internal armor is wrenched."),
					 //5
					 list("key"=TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Internal armor is installed."),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Peripherals control module is secured."),
					 //7
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Peripherals control module is installed."),
					 //8
					 list("key"=/obj/item/circuitboard/mecha/ripley/peripherals,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Central control module is secured."),
					 //9
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Central control module is installed."),
					 //10
					 list("key"=/obj/item/circuitboard/mecha/ripley/main,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is adjusted."),
					 //11
					 list("key"=/obj/item/wirecutters,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is added."),
					 //12
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The hydraulic systems are active."),
					 //13
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="The hydraulic systems are connected."),
					 //14
					 list("key"=TOOL_WRENCH,
					 		"desc"="The hydraulic systems are disconnected.")
					)

/datum/construction/reversible/mecha/ripley/action(atom/used_atom,mob/user as mob)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/ripley/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(14)
			user.visible_message("[user] connects the [holder] hydraulic systems", "You connect the [holder] hydraulic systems.")
			holder.icon_state = "ripley1"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] activates the [holder] hydraulic systems.", "You activate the [holder] hydraulic systems.")
				holder.icon_state = "ripley2"
			else
				user.visible_message("[user] disconnects the [holder] hydraulic systems", "You disconnect the [holder] hydraulic systems.")
				holder.icon_state = "ripley0"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to the [holder].", "You add the wiring to the [holder].")
				holder.icon_state = "ripley3"
			else
				user.visible_message("[user] deactivates the [holder] hydraulic systems.", "You deactivate the [holder] hydraulic systems.")
				holder.icon_state = "ripley1"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of the [holder].", "You adjust the wiring of the [holder].")
				holder.icon_state = "ripley4"
			else
				user.visible_message("[user] removes the wiring from the [holder].", "You remove the wiring from the [holder].")
				var/obj/item/stack/cable_coil/coil = new /obj/item/stack/cable_coil(get_turf(holder))
				coil.amount = 4
				holder.icon_state = "ripley2"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into the [holder].", "You install the central computer mainboard into the [holder].")
				qdel(used_atom)
				holder.icon_state = "ripley5"
			else
				user.visible_message("[user] disconnects the wiring of the [holder].", "You disconnect the wiring of the [holder].")
				holder.icon_state = "ripley3"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "ripley6"
			else
				user.visible_message("[user] removes the central control module from the [holder].", "You remove the central computer mainboard from the [holder].")
				new /obj/item/circuitboard/mecha/ripley/main(get_turf(holder))
				holder.icon_state = "ripley4"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into the [holder].", "You install the peripherals control module into the [holder].")
				qdel(used_atom)
				holder.icon_state = "ripley7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "ripley5"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "ripley8"
			else
				user.visible_message("[user] removes the peripherals control module from the [holder].", "You remove the peripherals control module from the [holder].")
				new /obj/item/circuitboard/mecha/ripley/peripherals(get_turf(holder))
				holder.icon_state = "ripley6"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to the [holder].", "You install the internal armor layer to the [holder].")
				holder.icon_state = "ripley9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "ripley7"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", "You secure the internal armor layer.")
				holder.icon_state = "ripley10"
			else
				user.visible_message("[user] pries internal armor layer from the [holder].", "You pry internal armor layer from the [holder].")
				var/obj/item/stack/sheet/metal/MS = new /obj/item/stack/sheet/metal(get_turf(holder))
				MS.amount = 5
				holder.icon_state = "ripley8"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to the [holder].", "You weld the internal armor layer to the [holder].")
				holder.icon_state = "ripley11"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "ripley9"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs the external reinforced armor layer to the [holder].", "You install the external reinforced armor layer to the [holder].")
				holder.icon_state = "ripley12"
			else
				user.visible_message("[user] cuts the internal armor layer from the [holder].", "You cut the internal armor layer from the [holder].")
				holder.icon_state = "ripley10"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures the external armor layer.", "You secure the external reinforced armor layer.")
				holder.icon_state = "ripley13"
			else
				user.visible_message("[user] pries external armor layer from the [holder].", "You pry external armor layer from the [holder].")
				var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
				MS.amount = 5
				holder.icon_state = "ripley11"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds the external armor layer to the [holder].", "You weld the external armor layer to the [holder].")
			else
				user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
				holder.icon_state = "ripley12"
	return 1

/datum/construction/mecha/gygax_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/gygax_torso),//1
					 list("key"=/obj/item/mecha_parts/part/gygax_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/gygax_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/gygax_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/gygax_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/gygax_head)
					)

/datum/construction/mecha/gygax_chassis/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] has connected [used_atom] to the [holder].", "You connect [used_atom] to the [holder]")
	holder.overlays += used_atom.icon_state+"+o"
	qdel(used_atom)
	return 1

/datum/construction/mecha/gygax_chassis/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)

/datum/construction/mecha/gygax_chassis/spawn_result()
	..("Gygax")
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/gygax(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "gygax0"
	const_holder.density = 1
	qdel(src)
	return


/datum/construction/reversible/mecha/gygax
	result = "/obj/mecha/combat/gygax"
	steps = list(
					//1
					list("key"=TOOL_WELDER,
							"backkey"=TOOL_WRENCH,
							"desc"="External armor is wrenched."),
					 //2
					 list("key"=TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/mecha_parts/part/gygax_armour,
					 		"backkey"=TOOL_WELDER,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=TOOL_WELDER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="Internal armor is wrenched."),
					 //5
					 list("key"=TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Internal armor is installed."),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Advanced capacitor is secured."),
					 //7
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Advanced capacitor is installed."),
					 //8
					 list("key"=/obj/item/stock_parts/capacitor/adv,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Advanced scanner module is secured."),
					 //9
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Advanced scanner module is installed."),
					 //10
					 list("key"=/obj/item/stock_parts/scanning_module/adv,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Scanning module is secured."),
					 //11
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Scanning module is installed."),
					 //12
					 list("key"=/obj/item/circuitboard/mecha/gygax/targeting,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Peripherals control module is secured."),
					 //13
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Peripherals control module is installed."),
					 //14
					 list("key"=/obj/item/circuitboard/mecha/gygax/peripherals,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Central control module is secured."),
					 //15
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Central control module is installed."),
					 //16
					 list("key"=/obj/item/circuitboard/mecha/gygax/main,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is adjusted."),
					 //17
					 list("key"=/obj/item/wirecutters,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is added."),
					 //18
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The hydraulic systems are active."),
					 //19
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="The hydraulic systems are connected."),
					 //20
					 list("key"=TOOL_WRENCH,
					 		"desc"="The hydraulic systems are disconnected.")
					)

/datum/construction/reversible/mecha/gygax/action(atom/used_atom,mob/user as mob)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/gygax/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(20)
			user.visible_message("[user] connects the [holder] hydraulic systems", "You connect the [holder] hydraulic systems.")
			holder.icon_state = "gygax1"
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] activates the [holder] hydraulic systems.", "You activate the [holder] hydraulic systems.")
				holder.icon_state = "gygax2"
			else
				user.visible_message("[user] disconnects the [holder] hydraulic systems", "You disconnect the [holder] hydraulic systems.")
				holder.icon_state = "gygax0"
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to the [holder].", "You add the wiring to the [holder].")
				holder.icon_state = "gygax3"
			else
				user.visible_message("[user] deactivates the [holder] hydraulic systems.", "You deactivate the [holder] hydraulic systems.")
				holder.icon_state = "gygax1"
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of the [holder].", "You adjust the wiring of the [holder].")
				holder.icon_state = "gygax4"
			else
				user.visible_message("[user] removes the wiring from the [holder].", "You remove the wiring from the [holder].")
				var/obj/item/stack/cable_coil/coil = new /obj/item/stack/cable_coil(get_turf(holder))
				coil.amount = 4
				holder.icon_state = "gygax2"
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into the [holder].", "You install the central computer mainboard into the [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax5"
			else
				user.visible_message("[user] disconnects the wiring of the [holder].", "You disconnect the wiring of the [holder].")
				holder.icon_state = "gygax3"
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "gygax6"
			else
				user.visible_message("[user] removes the central control module from the [holder].", "You remove the central computer mainboard from the [holder].")
				new /obj/item/circuitboard/mecha/gygax/main(get_turf(holder))
				holder.icon_state = "gygax4"
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into the [holder].", "You install the peripherals control module into the [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "gygax5"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "gygax8"
			else
				user.visible_message("[user] removes the peripherals control module from the [holder].", "You remove the peripherals control module from the [holder].")
				new /obj/item/circuitboard/mecha/gygax/peripherals(get_turf(holder))
				holder.icon_state = "gygax6"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] installs the weapon control module into the [holder].", "You install the weapon control module into the [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "gygax7"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", "You secure the weapon control module.")
				holder.icon_state = "gygax10"
			else
				user.visible_message("[user] removes the weapon control module from the [holder].", "You remove the weapon control module from the [holder].")
				new /obj/item/circuitboard/mecha/gygax/targeting(get_turf(holder))
				holder.icon_state = "gygax8"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] installs advanced scanner module to the [holder].", "You install advanced scanner module to the [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax11"
			else
				user.visible_message("[user] unfastens the weapon control module.", "You unfasten the weapon control module.")
				holder.icon_state = "gygax9"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] secures the advanced scanner module.", "You secure the advanced scanner module.")
				holder.icon_state = "gygax12"
			else
				user.visible_message("[user] removes the advanced scanner module from the [holder].", "You remove the advanced scanner module from the [holder].")
				new /obj/item/stock_parts/scanning_module/adv(get_turf(holder))
				holder.icon_state = "gygax10"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] installs advanced capacitor to the [holder].", "You install advanced capacitor to the [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax13"
			else
				user.visible_message("[user] unfastens the advanced scanner module.", "You unfasten the advanced scanner module.")
				holder.icon_state = "gygax11"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] secures the advanced capacitor.", "You secure the advanced capacitor.")
				holder.icon_state = "gygax14"
			else
				user.visible_message("[user] removes the advanced capacitor from the [holder].", "You remove the advanced capacitor from the [holder].")
				new /obj/item/stock_parts/capacitor/adv(get_turf(holder))
				holder.icon_state = "gygax12"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to the [holder].", "You install the internal armor layer to the [holder].")
				holder.icon_state = "gygax15"
			else
				user.visible_message("[user] unfastens the advanced capacitor.", "You unfasten the advanced capacitor.")
				holder.icon_state = "gygax13"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", "You secure the internal armor layer.")
				holder.icon_state = "gygax16"
			else
				user.visible_message("[user] pries internal armor layer from the [holder].", "You pry internal armor layer from the [holder].")
				var/obj/item/stack/sheet/metal/MS = new /obj/item/stack/sheet/metal(get_turf(holder))
				MS.amount = 5
				holder.icon_state = "gygax14"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to the [holder].", "You weld the internal armor layer to the [holder].")
				holder.icon_state = "gygax17"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "gygax15"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs Gygax Armor Plates to the [holder].", "You install Gygax Armor Plates to the [holder].")
				qdel(used_atom)
				holder.icon_state = "gygax18"
			else
				user.visible_message("[user] cuts the internal armor layer from the [holder].", "You cut the internal armor layer from the [holder].")
				holder.icon_state = "gygax16"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures Gygax Armor Plates.", "You secure Gygax Armor Plates.")
				holder.icon_state = "gygax19"
			else
				user.visible_message("[user] pries Gygax Armor Plates from the [holder].", "You pry Gygax Armor Plates from the [holder].")
				new /obj/item/mecha_parts/part/gygax_armour(get_turf(holder))
				holder.icon_state = "gygax17"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds Gygax Armor Plates to the [holder].", "You weld Gygax Armor Plates to the [holder].")
			else
				user.visible_message("[user] unfastens Gygax Armor Plates.", "You unfasten Gygax Armor Plates.")
				holder.icon_state = "gygax18"
	return 1

/datum/construction/mecha/firefighter_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/ripley_torso),//1
					 list("key"=/obj/item/mecha_parts/part/ripley_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/ripley_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/ripley_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/ripley_right_leg),//5
					 list("key"=/obj/item/clothing/suit/fire)//6
					)

/datum/construction/mecha/firefighter_chassis/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] has connected [used_atom] to the [holder].", "You connect [used_atom] to the [holder]")
	holder.overlays += used_atom.icon_state+"+o"
	qdel(used_atom)
	return 1

/datum/construction/mecha/firefighter_chassis/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)

/datum/construction/mecha/firefighter_chassis/spawn_result()
	..("Firefighter Ripley")
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/firefighter(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "fireripley0"
	const_holder.density = 1
	qdel(src)
	return


/datum/construction/reversible/mecha/firefighter
	result = "/obj/mecha/working/ripley/firefighter"
	taskpath = /datum/job_objective/make_ripley
	steps = list(
					//1
					list("key"=TOOL_WELDER,
							"backkey"=TOOL_WRENCH,
							"desc"="External armor is wrenched."),
					//2
					 list("key"=TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="External armor is being installed."),
					 //4
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=TOOL_WELDER,
					 		"desc"="Internal armor is welded."),
					 //5
					 list("key"=TOOL_WELDER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="Internal armor is wrenched."),
					 //6
					 list("key"=TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Internal armor is installed."),

					 //7
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Peripherals control module is secured."),
					 //8
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Peripherals control module is installed."),
					 //9
					 list("key"=/obj/item/circuitboard/mecha/ripley/peripherals,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Central control module is secured."),
					 //10
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Central control module is installed."),
					 //11
					 list("key"=/obj/item/circuitboard/mecha/ripley/main,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is adjusted."),
					 //12
					 list("key"=/obj/item/wirecutters,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is added."),
					 //13
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The hydraulic systems are active."),
					 //14
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="The hydraulic systems are connected."),
					 //15
					 list("key"=TOOL_WRENCH,
					 		"desc"="The hydraulic systems are disconnected.")
					)

/datum/construction/reversible/mecha/firefighter/action(atom/used_atom,mob/user as mob)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/firefighter/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(15)
			user.visible_message("[user] connects the [holder] hydraulic systems", "You connect the [holder] hydraulic systems.")
			holder.icon_state = "fireripley1"
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] activates the [holder] hydraulic systems.", "You activate the [holder] hydraulic systems.")
				holder.icon_state = "fireripley2"
			else
				user.visible_message("[user] disconnects the [holder] hydraulic systems", "You disconnect the [holder] hydraulic systems.")
				holder.icon_state = "fireripley0"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to the [holder].", "You add the wiring to the [holder].")
				holder.icon_state = "fireripley3"
			else
				user.visible_message("[user] deactivates the [holder] hydraulic systems.", "You deactivate the [holder] hydraulic systems.")
				holder.icon_state = "fireripley1"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of the [holder].", "You adjust the wiring of the [holder].")
				holder.icon_state = "fireripley4"
			else
				user.visible_message("[user] removes the wiring from the [holder].", "You remove the wiring from the [holder].")
				var/obj/item/stack/cable_coil/coil = new /obj/item/stack/cable_coil(get_turf(holder))
				coil.amount = 4
				holder.icon_state = "fireripley2"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into the [holder].", "You install the central computer mainboard into the [holder].")
				qdel(used_atom)
				holder.icon_state = "fireripley5"
			else
				user.visible_message("[user] disconnects the wiring of the [holder].", "You disconnect the wiring of the [holder].")
				holder.icon_state = "fireripley3"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "fireripley6"
			else
				user.visible_message("[user] removes the central control module from the [holder].", "You remove the central computer mainboard from the [holder].")
				new /obj/item/circuitboard/mecha/ripley/main(get_turf(holder))
				holder.icon_state = "fireripley4"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into the [holder].", "You install the peripherals control module into the [holder].")
				qdel(used_atom)
				holder.icon_state = "fireripley7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "fireripley5"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "fireripley8"
			else
				user.visible_message("[user] removes the peripherals control module from the [holder].", "You remove the peripherals control module from the [holder].")
				new /obj/item/circuitboard/mecha/ripley/peripherals(get_turf(holder))
				holder.icon_state = "fireripley6"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to the [holder].", "You install the internal armor layer to the [holder].")
				holder.icon_state = "fireripley9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "fireripley7"

		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", "You secure the internal armor layer.")
				holder.icon_state = "fireripley10"
			else
				user.visible_message("[user] pries internal armor layer from the [holder].", "You pry internal armor layer from the [holder].")
				var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
				MS.amount = 5
				holder.icon_state = "fireripley8"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to the [holder].", "You weld the internal armor layer to the [holder].")
				holder.icon_state = "fireripley11"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "fireripley9"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] starts to install the external armor layer to the [holder].", "You start to install the external armor layer to the [holder].")
				holder.icon_state = "fireripley12"
			else
				user.visible_message("[user] cuts the internal armor layer from the [holder].", "You cut the internal armor layer from the [holder].")
				holder.icon_state = "fireripley10"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs the external reinforced armor layer to the [holder].", "You install the external reinforced armor layer to the [holder].")
				holder.icon_state = "fireripley13"
			else
				user.visible_message("[user] removes the external armor from the [holder].", "You remove the external armor from the [holder].")
				var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
				MS.amount = 5
				holder.icon_state = "fireripley11"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures the external armor layer.", "You secure the external reinforced armor layer.")
				holder.icon_state = "fireripley14"
			else
				user.visible_message("[user] pries external armor layer from the [holder].", "You pry external armor layer from the [holder].")
				var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
				MS.amount = 5
				holder.icon_state = "fireripley12"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds the external armor layer to the [holder].", "You weld the external armor layer to the [holder].")
			else
				user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
				holder.icon_state = "fireripley13"
	return 1

/datum/construction/mecha/honker_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/honker_torso),//1
					 list("key"=/obj/item/mecha_parts/part/honker_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/honker_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/honker_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/honker_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/honker_head)
					)

/datum/construction/mecha/honker_chassis/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)

/datum/construction/mecha/honker_chassis/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] has connected [used_atom] to the [holder].", "You connect [used_atom] to the [holder]")
	holder.overlays += used_atom.icon_state+"+o"
	qdel(used_atom)
	return 1

/datum/construction/mecha/honker_chassis/spawn_result()
	..("Honker")
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/mecha/honker(const_holder)
	const_holder.density = 1
	qdel(src)
	return


/datum/construction/mecha/honker
	result = "/obj/mecha/combat/honker"
	steps = list(list("key"=/obj/item/bikehorn),//1
					 list("key"=/obj/item/clothing/shoes/clown_shoes),//2
					 list("key"=/obj/item/bikehorn),//3
					 list("key"=/obj/item/clothing/mask/gas/clown_hat),//4
					 list("key"=/obj/item/bikehorn),//5
					 list("key"=/obj/item/circuitboard/mecha/honker/targeting),//6
					 list("key"=/obj/item/bikehorn),//7
					 list("key"=/obj/item/circuitboard/mecha/honker/peripherals),//8
					 list("key"=/obj/item/bikehorn),//9
					 list("key"=/obj/item/circuitboard/mecha/honker/main),//10
					 list("key"=/obj/item/bikehorn),//11
					 )

/datum/construction/mecha/honker/action(atom/used_atom,mob/user as mob)
	return check_step(used_atom,user)

/datum/construction/mecha/honker/custom_action(step, atom/used_atom, mob/user)
	if(!..())
		return 0

	if(istype(used_atom, /obj/item/bikehorn))
		playsound(holder, 'sound/items/bikehorn.ogg', 50, 1)
		user.visible_message("HONK!")

	//TODO: better messages.
	switch(step)
		if(10)
			user.visible_message("[user] installs the central control module into the [holder].", "You install the central control module into the [holder].")
			qdel(used_atom)
		if(8)
			user.visible_message("[user] installs the peripherals control module into the [holder].", "You install the peripherals control module into the [holder].")
			qdel(used_atom)
		if(6)
			user.visible_message("[user] installs the weapon control module into the [holder].", "You install the weapon control module into the [holder].")
			qdel(used_atom)
		if(4)
			user.visible_message("[user] puts clown wig and mask on the [holder].", "You put clown wig and mask on the [holder].")
			qdel(used_atom)
		if(2)
			user.visible_message("[user] puts clown boots on the [holder].", "You put clown boots on the [holder].")
			qdel(used_atom)
	return 1

/datum/construction/mecha/reticence_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/reticence_torso),//1
					 list("key"=/obj/item/mecha_parts/part/reticence_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/reticence_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/reticence_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/reticence_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/reticence_head)
					)

/datum/construction/mecha/reticence_chassis/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)

/datum/construction/mecha/reticence_chassis/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] has connected [used_atom] to the [holder].", "You connect [used_atom] to the [holder]")
	holder.overlays += used_atom.icon_state + "+o"
	qdel(used_atom)
	return 1

/datum/construction/mecha/reticence_chassis/spawn_result()
	..("Reticence")
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/mecha/reticence(const_holder)
	const_holder.density = 1
	qdel(src)
	return

/datum/construction/mecha/reticence
	result = "/obj/mecha/combat/reticence"
	steps = list(list("key"=/obj/effect/dummy/mecha_emote_step),//1
					 list("key"=/obj/item/clothing/suit/suspenders),//2
					 list("key"=/obj/effect/dummy/mecha_emote_step),//3
					 list("key"=/obj/item/clothing/mask/gas/mime),//4
					 list("key"=/obj/effect/dummy/mecha_emote_step),//5
					 list("key"=/obj/item/clothing/head/beret),//6
					 list("key"=/obj/item/circuitboard/mecha/reticence/targeting),//7
					 list("key"=/obj/item/circuitboard/mecha/reticence/peripherals),//8
					 list("key"=/obj/item/circuitboard/mecha/reticence/main),//9
					 )

/datum/construction/mecha/reticence/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/mecha/reticence/custom_action(step, atom/used_atom, mob/user)
	if(!..())
		return 0

	if(istype(used_atom, /obj/effect/dummy/mecha_emote_step))
		var/obj/effect/dummy/mecha_emote_step/E = used_atom
		holder.visible_message("<span class='game say'><span class='name'>[holder]</span> likewise [E.emote]</span>")
		qdel(used_atom)

	//TODO: better messages.
	switch(step)
		if(9)
			user.visible_message("[user] installs the central control module into the [holder].", "<span class='notice'>You install the central control module into the [holder].</span>")
			qdel(used_atom)
		if(8)
			user.visible_message("[user] installs the peripherals control module into the [holder].", "<span class='notice'>You install the peripherals control module into the [holder].</span>")
			qdel(used_atom)
		if(7)
			user.visible_message("[user] installs the weapon control module into the [holder].", "<span class='notice'>You install the weapon control module into the [holder].</span>")
			qdel(used_atom)
		if(6)
			user.visible_message("[user] puts beret on the [holder].", "<span class='notice'>You put beret on the [holder].</span>")
			qdel(used_atom)
		if(4)
			user.visible_message("[user] puts mime mask on the [holder].", "<span class='notice'>You put mime mask on the [holder].</span>")
			qdel(used_atom)
		if(2)
			user.visible_message("[user] puts suspenders on the [holder].", "<span class='notice'>You put suspenders on the [holder].</span>")
			qdel(used_atom)
	return 1


/datum/construction/mecha/durand_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/durand_torso),//1
					 list("key"=/obj/item/mecha_parts/part/durand_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/durand_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/durand_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/durand_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/durand_head)
					)

/datum/construction/mecha/durand_chassis/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] has connected [used_atom] to the [holder].", "You connect [used_atom] to the [holder]")
	holder.overlays += used_atom.icon_state+"+o"
	qdel(used_atom)
	return 1

/datum/construction/mecha/durand_chassis/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)

/datum/construction/mecha/durand_chassis/spawn_result()
	..("Durand")
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/durand(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "durand0"
	const_holder.density = 1
	qdel(src)
	return

/datum/construction/reversible/mecha/durand
	result = "/obj/mecha/combat/durand"
	steps = list(
					//1
					list("key"=TOOL_WELDER,
							"backkey"=TOOL_WRENCH,
							"desc"="External armor is wrenched."),
					 //2
					 list("key"=TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/mecha_parts/part/durand_armor,
					 		"backkey"=TOOL_WELDER,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=TOOL_WELDER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="Internal armor is wrenched."),
					 //5
					 list("key"=TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Internal armor is installed."),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Super capacitor is secured."),
					 //7
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Super capacitor is installed."),
					 //8
					 list("key"=/obj/item/stock_parts/capacitor/super,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Phasic scanner module is secured."),
					 //9
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Phasic scanner module is installed."),
					 //10
					 list("key"=/obj/item/stock_parts/scanning_module/phasic,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Scanning module is secured."),
					 //11
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Scanning module is installed."),
					 //12
					 list("key"=/obj/item/circuitboard/mecha/durand/targeting,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Peripherals control module is secured."),
					 //13
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Peripherals control module is installed."),
					 //14
					 list("key"=/obj/item/circuitboard/mecha/durand/peripherals,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Central control module is secured."),
					 //15
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Central control module is installed."),
					 //16
					 list("key"=/obj/item/circuitboard/mecha/durand/main,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is adjusted."),
					 //17
					 list("key"=/obj/item/wirecutters,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is added."),
					 //18
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The hydraulic systems are active."),
					 //19
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="The hydraulic systems are connected."),
					 //20
					 list("key"=TOOL_WRENCH,
					 		"desc"="The hydraulic systems are disconnected.")
					)


/datum/construction/reversible/mecha/durand/action(atom/used_atom,mob/user as mob)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/durand/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(20)
			user.visible_message("[user] connects the [holder] hydraulic systems", "You connect the [holder] hydraulic systems.")
			holder.icon_state = "durand1"
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] activates the [holder] hydraulic systems.", "You activate the [holder] hydraulic systems.")
				holder.icon_state = "durand2"
			else
				user.visible_message("[user] disconnects the [holder] hydraulic systems", "You disconnect the [holder] hydraulic systems.")
				holder.icon_state = "durand0"
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to the [holder].", "You add the wiring to the [holder].")
				holder.icon_state = "durand3"
			else
				user.visible_message("[user] deactivates the [holder] hydraulic systems.", "You deactivate the [holder] hydraulic systems.")
				holder.icon_state = "durand1"
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of the [holder].", "You adjust the wiring of the [holder].")
				holder.icon_state = "durand4"
			else
				user.visible_message("[user] removes the wiring from the [holder].", "You remove the wiring from the [holder].")
				var/obj/item/stack/cable_coil/coil = new /obj/item/stack/cable_coil(get_turf(holder))
				coil.amount = 4
				holder.icon_state = "durand2"
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into the [holder].", "You install the central computer mainboard into the [holder].")
				qdel(used_atom)
				holder.icon_state = "durand5"
			else
				user.visible_message("[user] disconnects the wiring of the [holder].", "You disconnect the wiring of the [holder].")
				holder.icon_state = "durand3"
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "durand6"
			else
				user.visible_message("[user] removes the central control module from the [holder].", "You remove the central computer mainboard from the [holder].")
				new /obj/item/circuitboard/mecha/durand/main(get_turf(holder))
				holder.icon_state = "durand4"
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into the [holder].", "You install the peripherals control module into the [holder].")
				qdel(used_atom)
				holder.icon_state = "durand7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "durand5"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "durand8"
			else
				user.visible_message("[user] removes the peripherals control module from the [holder].", "You remove the peripherals control module from the [holder].")
				new /obj/item/circuitboard/mecha/durand/peripherals(get_turf(holder))
				holder.icon_state = "durand6"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] installs the weapon control module into the [holder].", "You install the weapon control module into the [holder].")
				qdel(used_atom)
				holder.icon_state = "durand9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "durand7"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", "You secure the weapon control module.")
				holder.icon_state = "durand10"
			else
				user.visible_message("[user] removes the weapon control module from the [holder].", "You remove the weapon control module from the [holder].")
				new /obj/item/circuitboard/mecha/durand/targeting(get_turf(holder))
				holder.icon_state = "durand8"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] installs phasic scanner module to the [holder].", "You install phasic scanner module to the [holder].")
				qdel(used_atom)
				holder.icon_state = "durand11"
			else
				user.visible_message("[user] unfastens the weapon control module.", "You unfasten the weapon control module.")
				holder.icon_state = "durand9"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] secures the phasic scanner module.", "You secure the phasic scanner module.")
				holder.icon_state = "durand12"
			else
				user.visible_message("[user] removes the phasic scanner module from the [holder].", "You remove the phasic scanner module from the [holder].")
				new /obj/item/stock_parts/scanning_module/phasic(get_turf(holder))
				holder.icon_state = "durand10"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] installs super capacitor to the [holder].", "You install super capacitor to the [holder].")
				qdel(used_atom)
				holder.icon_state = "durand13"
			else
				user.visible_message("[user] unfastens the phasic scanner module.", "You unfasten the phasic scanner module.")
				holder.icon_state = "durand11"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] secures the super capacitor.", "You secure the super capacitor.")
				holder.icon_state = "durand14"
			else
				user.visible_message("[user] removes the super capacitor from the [holder].", "You remove the super capacitor from the [holder].")
				new /obj/item/stock_parts/capacitor/super(get_turf(holder))
				holder.icon_state = "durand12"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to the [holder].", "You install the internal armor layer to the [holder].")
				holder.icon_state = "durand15"
			else
				user.visible_message("[user] unfastens the super capacitor.", "You unfasten the super capacitor.")
				holder.icon_state = "durand13"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", "You secure the internal armor layer.")
				holder.icon_state = "durand16"
			else
				user.visible_message("[user] pries internal armor layer from the [holder].", "You pry internal armor layer from the [holder].")
				var/obj/item/stack/sheet/metal/MS = new /obj/item/stack/sheet/metal(get_turf(holder))
				MS.amount = 5
				holder.icon_state = "durand14"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to the [holder].", "You weld the internal armor layer to the [holder].")
				holder.icon_state = "durand17"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "durand15"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs Durand Armor Plates to the [holder].", "You install Durand Armor Plates to the [holder].")
				qdel(used_atom)
				holder.icon_state = "durand18"
			else
				user.visible_message("[user] cuts the internal armor layer from the [holder].", "You cut the internal armor layer from the [holder].")
				holder.icon_state = "durand16"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures Durand Armor Plates.", "You secure Durand Armor Plates.")
				holder.icon_state = "durand19"
			else
				user.visible_message("[user] pries Durand Armor Plates from the [holder].", "You pry Durand Armor Plates from the [holder].")
				new /obj/item/mecha_parts/part/durand_armor(get_turf(holder))
				holder.icon_state = "durand17"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds Durand Armor Plates to the [holder].", "You weld Durand Armor Plates to the [holder].")
			else
				user.visible_message("[user] unfastens Durand Armor Plates.", "You unfasten Durand Armor Plates.")
				holder.icon_state = "durand18"
	return 1

//PHAZON

/datum/construction/mecha/phazon_chassis
	result = "/obj/mecha/combat/phazon"
	steps = list(list("key"=/obj/item/mecha_parts/part/phazon_torso),//1
					 list("key"=/obj/item/mecha_parts/part/phazon_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/phazon_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/phazon_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/phazon_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/phazon_head)
					)

/datum/construction/mecha/phazon_chassis/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] has connected [used_atom] to the [holder].", "You connect [used_atom] to the [holder]")
	holder.overlays += used_atom.icon_state+"+o"
	qdel(used_atom)
	return 1

/datum/construction/mecha/phazon_chassis/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)

/datum/construction/mecha/phazon_chassis/spawn_result()
	..("Phazon")
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/phazon(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "phazon0"
	const_holder.density = 1
	qdel(src)
	return

/datum/construction/reversible/mecha/phazon
	result = "/obj/mecha/combat/phazon"
	steps = list(
 					//1
					list("key" = /obj/item/assembly/signaler/anomaly/bluespace,
						 "backkey"=null, //Cannot remove the anomaly core once it's in
						 "desc"="Anomaly core socket is open and awaiting connection."),
					//2
					list("key" = TOOL_WELDER,
							"backkey"=TOOL_WRENCH,
							"desc"="External armor is wrenched."),
					 //3
					 list("key" = TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="External armor is installed."),
					 //4
					 list("key" = /obj/item/mecha_parts/part/phazon_armor,
					 		"backkey"=TOOL_WELDER,
					 		"desc"="Phase armor is welded."),
					 //5
					 list("key" = TOOL_WELDER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="Phase armor is wrenched."),
					 //6
					 list("key" = TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Phase armor is installed."),
					 //7
					 list("key" = /obj/item/stack/sheet/plasteel,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The bluespace crystal is engaged."),
					 //8
					 list("key" = TOOL_SCREWDRIVER,
					 		"backkey"=/obj/item/wirecutters,
					 		"desc"="The bluespace crystal is connected."),
					 //9
					 list("key" = /obj/item/stack/cable_coil,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="The bluespace crystal is installed."),
					 //10
					 list("key" = /obj/item/stack/ore/bluespace_crystal,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Super capacitor is secured."),
					 //11
					 list("key" = TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Super capacitor is installed."),
					 //12
					 list("key" = /obj/item/stock_parts/capacitor/super,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Phasic scanner module is secured."),
					 //13
					 list("key" = TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Phasic scanner module is installed."),
					 //14
					 list("key" = /obj/item/stock_parts/scanning_module/phasic,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Scanning module is secured."),
					 //15
					 list("key" = TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Scanning module is installed."),
					 //16
					 list("key" = /obj/item/circuitboard/mecha/phazon/targeting,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Peripherals control module is secured."),
					 //17
					 list("key" = TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Peripherals control module is installed"),
					 //18
					 list("key" = /obj/item/circuitboard/mecha/phazon/peripherals,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Central control module is secured."),
					 //19
					 list("key" = TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Central control module is installed."),
					 //20
					 list("key" = /obj/item/circuitboard/mecha/phazon/main,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is adjusted."),
					 //21
					 list("key" = /obj/item/wirecutters,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is added."),
					 //22
					 list("key" = /obj/item/stack/cable_coil,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The hydraulic systems are active."),
					 //23
					 list("key" = TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="The hydraulic systems are connected."),
					 //24
					 list("key" = TOOL_WRENCH,
					 		"desc"="The hydraulic systems are disconnected.")
					)


/datum/construction/reversible/mecha/phazon/action(atom/used_atom,mob/user as mob)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/phazon/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(24)
			user.visible_message("[user] connects the [holder] hydraulic systems", "You connect the [holder] hydraulic systems.")
			holder.icon_state = "phazon1"
		if(23)
			if(diff==FORWARD)
				user.visible_message("[user] activates the [holder] hydraulic systems.", "You activate the [holder] hydraulic systems.")
				holder.icon_state = "phazon2"
			else
				user.visible_message("[user] disconnects the [holder] hydraulic systems", "You disconnect the [holder] hydraulic systems.")
				holder.icon_state = "phazon0"
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to the [holder].", "You add the wiring to the [holder].")
				holder.icon_state = "phazon3"
			else
				user.visible_message("[user] deactivates the [holder] hydraulic systems.", "You deactivate the [holder] hydraulic systems.")
				holder.icon_state = "phazon1"
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of the [holder].", "You adjust the wiring of the [holder].")
				holder.icon_state = "phazon4"
			else
				user.visible_message("[user] removes the wiring from the [holder].", "You remove the wiring from the [holder].")
				var/obj/item/stack/cable_coil/coil = new /obj/item/stack/cable_coil(get_turf(holder))
				coil.amount = 4
				holder.icon_state = "phazon2"
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into the [holder].", "You install the central computer mainboard into the [holder].")
				qdel(used_atom)
				holder.icon_state = "phazon5"
			else
				user.visible_message("[user] disconnects the wiring of the [holder].", "You disconnect the wiring of the [holder].")
				holder.icon_state = "phazon3"
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "phazon6"
			else
				user.visible_message("[user] removes the central control module from the [holder].", "You remove the central computer mainboard from the [holder].")
				new /obj/item/circuitboard/mecha/phazon/main(get_turf(holder))
				holder.icon_state = "phazon4"
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into the [holder].", "You install the peripherals control module into the [holder].")
				qdel(used_atom)
				holder.icon_state = "phazon7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "phazon5"
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "phazon8"
			else
				user.visible_message("[user] removes the peripherals control module from the [holder].", "You remove the peripherals control module from the [holder].")
				new /obj/item/circuitboard/mecha/phazon/peripherals(get_turf(holder))
				holder.icon_state = "phazon6"
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] installs the weapon control module into the [holder].", "You install the weapon control module into the [holder].")
				qdel(used_atom)
				holder.icon_state = "phazon9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "phazon7"
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", "You secure the weapon control module.")
				holder.icon_state = "phazon10"
			else
				user.visible_message("[user] removes the weapon control module from the [holder].", "You remove the weapon control module from the [holder].")
				new /obj/item/circuitboard/mecha/phazon/targeting(get_turf(holder))
				holder.icon_state = "phazon8"
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] installs phasic scanner module to the [holder].", "You install phasic scanner module to the [holder].")
				qdel(used_atom)
				holder.icon_state = "phazon11"
			else
				user.visible_message("[user] unfastens the weapon control module.", "You unfasten the weapon control module.")
				holder.icon_state = "phazon9"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] secures the phasic scanner module.", "You secure the phasic scanner module.")
				holder.icon_state = "phazon12"
			else
				user.visible_message("[user] removes the phasic scanner module from the [holder].", "You remove the phasic scanner module from the [holder].")
				new /obj/item/stock_parts/scanning_module/phasic(get_turf(holder))
				holder.icon_state = "phazon10"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] installs super capacitor to the [holder].", "You install super capacitor to the [holder].")
				qdel(used_atom)
				holder.icon_state = "phazon13"
			else
				user.visible_message("[user] unfastens the phasic scanner module.", "You unfasten the phasic scanner module.")
				holder.icon_state = "phazon11"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] secures the super capacitor.", "You secure the super capacitor.")
				holder.icon_state = "phazon14"
			else
				user.visible_message("[user] removes the super capacitor from the [holder].", "You remove the super capacitor from the [holder].")
				new /obj/item/stock_parts/capacitor/super(get_turf(holder))
				holder.icon_state = "phazon12"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] installs the bluespace crystal.", "You install the bluespace crystals.")
				holder.icon_state = "phazon15"
			else
				user.visible_message("[user] unsecures the super capacitor from the [holder].", "You unsecure the super capacitor from the [holder].")
				holder.icon_state = "phazon13"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] connects the bluespace crystal.", "You connect the bluespace crystals.")
				holder.icon_state = "phazon16"
			else
				user.visible_message("[user] removes the bluespace crystal from the [holder].", "You remove the bluespace crystal from the [holder].")
				new /obj/item/stack/ore/bluespace_crystal(get_turf(holder), new_amount = 5)
				holder.icon_state = "phazon14"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] engages the bluespace crystal.", "You engage the bluespace crystals.")
				holder.icon_state = "phazon17"
			else
				user.visible_message("[user] disconnects the bluespace crystal from the [holder].", "You disconnect the bluespace crystal from the [holder].")
				holder.icon_state = "phazon15"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs the phase armor layer to the [holder].", "You install the phase armor layer to the [holder].")
				holder.icon_state = "phazon18"
			else
				user.visible_message("[user] disengages the bluespace crystal.", "You disengage the bluespace crystals.")
				holder.icon_state = "phazon16"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the phase armor layer.", "You secure the phase armor layer.")
				holder.icon_state = "phazon19"
			else
				user.visible_message("[user] pries the phase armor layer from the [holder].", "You pry the phase armor layer from the [holder].")
				var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
				MS.amount = 5
				holder.icon_state = "phazon17"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] welds the phase armor layer to the [holder].", "You weld the phase armor layer to the [holder].")
				holder.icon_state = "phazon20"
			else
				user.visible_message("[user] unfastens the phase armor layer.", "You unfasten the phase armor layer.")
				holder.icon_state = "phazon18"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] installs Phazon Armor Plates to the [holder].", "You install Phazon Armor Plates to the [holder].")
				qdel(used_atom)
				holder.icon_state = "phazon21"
			else
				user.visible_message("[user] cuts phase armor layer from the [holder].", "You cut the phase armor layer from the [holder].")
				holder.icon_state = "phazon19"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] secures Phazon Armor Plates.", "You secure Phazon Armor Plates.")
				holder.icon_state = "phazon22"
			else
				user.visible_message("[user] pries Phazon Armor Plates from the [holder].", "You pry Phazon Armor Plates from the [holder].")
				new /obj/item/mecha_parts/part/phazon_armor(get_turf(holder))
				holder.icon_state = "phazon20"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] welds Phazon Armor Plates to the [holder].", "You weld Phazon Armor Plates to the [holder].")
			else
				user.visible_message("[user] unfastens Phazon Armor Plates.", "You unfasten Phazon Armor Plates.")
				holder.icon_state = "phazon21"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] carefully inserts the anomaly core into \the [holder] and secures it.", "You slowly place the anomaly core into its socket and close its chamber.")
				qdel(used_atom)
	return 1

//ODYSSEUS

/datum/construction/mecha/odysseus_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/odysseus_torso),//1
					 list("key"=/obj/item/mecha_parts/part/odysseus_head),//2
					 list("key"=/obj/item/mecha_parts/part/odysseus_left_arm),//3
					 list("key"=/obj/item/mecha_parts/part/odysseus_right_arm),//4
					 list("key"=/obj/item/mecha_parts/part/odysseus_left_leg),//5
					 list("key"=/obj/item/mecha_parts/part/odysseus_right_leg)//6
					)

/datum/construction/mecha/odysseus_chassis/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] has connected [used_atom] to the [holder].", "You connect [used_atom] to the [holder]")
	holder.overlays += used_atom.icon_state+"+o"
	qdel(used_atom)
	return 1

/datum/construction/mecha/odysseus_chassis/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)

/datum/construction/mecha/odysseus_chassis/spawn_result()
	..("Odysseus")
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/odysseus(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "odysseus0"
	const_holder.density = 1
	qdel(src)
	return


/datum/construction/reversible/mecha/odysseus
	result = "/obj/mecha/medical/odysseus"
	steps = list(
					//1
					list("key"=TOOL_WELDER,
							"backkey"=TOOL_WRENCH,
							"desc"="External armor is wrenched."),
					//2
					 list("key"=TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=TOOL_WELDER,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=TOOL_WELDER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="Internal armor is wrenched."),
					 //5
					 list("key"=TOOL_WRENCH,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Internal armor is installed."),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Peripherals control module is secured."),
					 //7
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Peripherals control module is installed."),
					 //8
					 list("key"=/obj/item/circuitboard/mecha/odysseus/peripherals,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="Central control module is secured."),
					 //9
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_CROWBAR,
					 		"desc"="Central control module is installed."),
					 //10
					 list("key"=/obj/item/circuitboard/mecha/odysseus/main,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is adjusted."),
					 //11
					 list("key"=/obj/item/wirecutters,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The wiring is added."),
					 //12
					 list("key"=/obj/item/stack/cable_coil,
					 		"backkey"=TOOL_SCREWDRIVER,
					 		"desc"="The hydraulic systems are active."),
					 //13
					 list("key"=TOOL_SCREWDRIVER,
					 		"backkey"=TOOL_WRENCH,
					 		"desc"="The hydraulic systems are connected."),
					 //14
					 list("key"=TOOL_WRENCH,
					 		"desc"="The hydraulic systems are disconnected.")
					)

/datum/construction/reversible/mecha/odysseus/action(atom/used_atom,mob/user as mob)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/odysseus/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(14)
			user.visible_message("[user] connects the [holder] hydraulic systems", "You connect the [holder] hydraulic systems.")
			holder.icon_state = "odysseus1"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] activates the [holder] hydraulic systems.", "You activate the [holder] hydraulic systems.")
				holder.icon_state = "odysseus2"
			else
				user.visible_message("[user] disconnects the [holder] hydraulic systems", "You disconnect the [holder] hydraulic systems.")
				holder.icon_state = "odysseus0"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to the [holder].", "You add the wiring to the [holder].")
				holder.icon_state = "odysseus3"
			else
				user.visible_message("[user] deactivates the [holder] hydraulic systems.", "You deactivate the [holder] hydraulic systems.")
				holder.icon_state = "odysseus1"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of the [holder].", "You adjust the wiring of the [holder].")
				holder.icon_state = "odysseus4"
			else
				user.visible_message("[user] removes the wiring from the [holder].", "You remove the wiring from the [holder].")
				var/obj/item/stack/cable_coil/coil = new /obj/item/stack/cable_coil(get_turf(holder))
				coil.amount = 4
				holder.icon_state = "odysseus2"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into the [holder].", "You install the central computer mainboard into the [holder].")
				qdel(used_atom)
				holder.icon_state = "odysseus5"
			else
				user.visible_message("[user] disconnects the wiring of the [holder].", "You disconnect the wiring of the [holder].")
				holder.icon_state = "odysseus3"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				holder.icon_state = "odysseus6"
			else
				user.visible_message("[user] removes the central control module from the [holder].", "You remove the central computer mainboard from the [holder].")
				new /obj/item/circuitboard/mecha/odysseus/main(get_turf(holder))
				holder.icon_state = "odysseus4"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into the [holder].", "You install the peripherals control module into the [holder].")
				qdel(used_atom)
				holder.icon_state = "odysseus7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "odysseus5"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				holder.icon_state = "odysseus8"
			else
				user.visible_message("[user] removes the peripherals control module from the [holder].", "You remove the peripherals control module from the [holder].")
				new /obj/item/circuitboard/mecha/odysseus/peripherals(get_turf(holder))
				holder.icon_state = "odysseus6"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to the [holder].", "You install the internal armor layer to the [holder].")
				holder.icon_state = "odysseus9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "odysseus7"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", "You secure the internal armor layer.")
				holder.icon_state = "odysseus10"
			else
				user.visible_message("[user] pries internal armor layer from the [holder].", "You pry internal armor layer from the [holder].")
				var/obj/item/stack/sheet/metal/MS = new /obj/item/stack/sheet/metal(get_turf(holder))
				MS.amount = 5
				holder.icon_state = "odysseus8"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to the [holder].", "You weld the internal armor layer to the [holder].")
				holder.icon_state = "odysseus11"
			else
				user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
				holder.icon_state = "odysseus9"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] installs [used_atom] layer to the [holder].", "You install the external reinforced armor layer to the [holder].")

				holder.icon_state = "odysseus12"
			else
				user.visible_message("[user] cuts the internal armor layer from the [holder].", "You cut the internal armor layer from the [holder].")
				holder.icon_state = "odysseus10"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] secures the external armor layer.", "You secure the external reinforced armor layer.")
				holder.icon_state = "odysseus13"
			else
				var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
				MS.amount = 5
				user.visible_message("[user] pries [MS] from the [holder].", "You pry [MS] from the [holder].")
				holder.icon_state = "odysseus11"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] welds the external armor layer to the [holder].", "You weld the external armor layer to the [holder].")
				holder.icon_state = "odysseus14"
			else
				user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
				holder.icon_state = "odysseus12"
	return 1
