/datum/construction/mecha/executioner_chassis
	steps = list(
		list("key"=/obj/item/mecha_parts/part/executioner_torso),//1
		list("key"=/obj/item/mecha_parts/part/executioner_left_arm),//2
		list("key"=/obj/item/mecha_parts/part/executioner_right_arm),//3
		list("key"=/obj/item/mecha_parts/part/executioner_left_leg),//4
		list("key"=/obj/item/mecha_parts/part/executioner_right_leg),//5
		list("key"=/obj/item/mecha_parts/part/executioner_head)
	)

/datum/construction/mecha/executioner_chassis/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] прикрепил [used_atom] к [holder].", "вы прикрепили [used_atom] к [holder]")
	holder.overlays += used_atom.icon_state+"+o"
	qdel(used_atom)
	return 1

/datum/construction/mecha/executioner_chassis/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)

/datum/construction/mecha/executioner_chassis/spawn_result()
	..("mk. V \"The Executioner\"")
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/executioner(const_holder)
	const_holder.icon = 'modular_ss220/new_mecha_executioner/icons/mech_construction.dmi'
	const_holder.icon_state = "executioner0"
	const_holder.density = TRUE
	qdel(src)
	return

/datum/construction/reversible/mecha/executioner
	result = /obj/mecha/combat/executioner
	steps = list(
		//1
		list(
			"key"=/obj/item/soulstone/anybody/purified,
			"backkey"=null, //Cannot remove soulstone once it's in
			"desc"="камень души помещен в хранилище."),
		//2
		list(
		"key" = /obj/item/mecha_parts/core,
			"backkey" = TOOL_SCREWDRIVER,
			"desc" = "Внешняя броня заварена."),
		//3
		list(
			"key"=TOOL_WELDER,
			"backkey"=TOOL_WRENCH,
			"desc"="Внешняя броня закручена."),
		//4
		list(
			"key"=TOOL_WRENCH,
			"backkey"=TOOL_CROWBAR,
			"desc"="Внешняя броня установлена."),
		//5
		list(
			"key"=/obj/item/mecha_parts/part/executioner_armor,
			"backkey"=TOOL_WELDER,
			"desc"="святой крест заварен."),
		//6
		list(
			"key"=TOOL_WELDER,
			"backkey"=TOOL_WRENCH,
			"desc"="святой крест зкручен."),
		//7
		list("key"=TOOL_WRENCH,
				"backkey"=TOOL_CROWBAR,
				"desc"="святой крест устоновлен."),
		//8
		list(
			"key"=/obj/item/stack/sheet/mineral/silver,
			"backkey"=TOOL_SCREWDRIVER,
			"desc"="святой шлем благословлен."),
		//9
		list(
			"key"=/obj/item/storage/bible,
			"backkey"=TOOL_CROWBAR,
			"desc"="святой шлем устоновлен."),
		//10
		list(
			"key"=/obj/item/clothing/head/helmet/riot/knight/templar,
			"backkey"=TOOL_SCREWDRIVER,
			"desc"="святая броня благословлена."),
		//11
		list(
			"key"=/obj/item/storage/bible,
			"backkey"=TOOL_CROWBAR,
			"desc"="святая броня устоновлена."),
		//12
		list(
			"key"=/obj/item/clothing/suit/armor/riot/knight/templar,
			"backkey"=TOOL_SCREWDRIVER,
			"desc"="сканирующей модуль благословлен."),
		 //13
		list(
			"key"=/obj/item/storage/bible,
			"backkey"=TOOL_CROWBAR,
			"desc"="сканирующей модуль устоновлен."),
		//14
		list(
			"key"=/obj/item/circuitboard/mecha/executioner/targeting,
			"backkey"=TOOL_SCREWDRIVER,
			"desc"="периферийный контрольный модуль благословлен."),
		//15
		list(
			"key"=/obj/item/storage/bible,
			"backkey"=TOOL_CROWBAR,
			"desc"="периферийный контрольный модуль устоновлен."),
		//16
		list(
			"key"=/obj/item/circuitboard/mecha/executioner/peripherals,
			"backkey"=TOOL_SCREWDRIVER,
			"desc"="центральный контрольный модуль благословлен."),
		//17
		list(
			"key"=/obj/item/storage/bible,
			"backkey"=TOOL_CROWBAR,
			"desc"="центральный контрольный модуль устоновлен."),
		//18
		list(
			"key"=/obj/item/circuitboard/mecha/executioner/main,
			"backkey"=TOOL_SCREWDRIVER,
			"desc"="проводка устоновлена."),
		//19
		list(
			"key"=/obj/item/wirecutters,
			"backkey"=TOOL_SCREWDRIVER,
			"desc"="проводка добавлена."),
		//20
		list(
			"key"=/obj/item/stack/cable_coil,
			"backkey"=TOOL_SCREWDRIVER,
			"desc"="гидравлические системы активны."),
		//21
		list(
			"key"=TOOL_SCREWDRIVER,
			"backkey"=TOOL_WRENCH,
			"desc"="гидравлические системы устоновлены."),
		//22
		list(
			"key"=TOOL_WRENCH,
			"desc"="Гидравлические системы отключены.")
		)


/datum/construction/reversible/mecha/executioner/action(atom/used_atom,mob/user as mob)
	return check_step(used_atom,user)

/datum/construction/reversible/mecha/executioner/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	//TODO: better messages.
	switch(index)
		if(21)
			user.visible_message("[user] connects the [holder] hydraulic systems", "You connect the [holder] hydraulic systems.")
			holder.icon_state = "executioner1"
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] activates the [holder] hydraulic systems.", "You activate the [holder] hydraulic systems.")
				holder.icon_state = "executioner2"
			else
				user.visible_message("[user] disconnects the [holder] hydraulic systems", "You disconnect the [holder] hydraulic systems.")
				holder.icon_state = "executioner0"
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to the [holder].", "You add the wiring to the [holder].")
				holder.icon_state = "executioner3"
			else
				user.visible_message("[user] deactivates the [holder] hydraulic systems.", "You deactivate the [holder] hydraulic systems.")
				holder.icon_state = "executioner1"
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of the [holder].", "You adjust the wiring of the [holder].")
				holder.icon_state = "executioner4"
			else
				user.visible_message("[user] removes the wiring from the [holder].", "You remove the wiring from the [holder].")
				var/obj/item/stack/cable_coil/coil = new /obj/item/stack/cable_coil(get_turf(holder))
				coil.amount = 4
				holder.icon_state = "executioner2"
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into the [holder].", "You install the central computer mainboard into the [holder].")
				qdel(used_atom)
				holder.icon_state = "executioner5"
			else
				user.visible_message("[user] disconnects the wiring of the [holder].", "You disconnect the wiring of the [holder].")
				holder.icon_state = "executioner3"
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] blessed the mainboard.", "You bless the mainboard.")
				holder.icon_state = "executioner6"
			else
				user.visible_message("[user] removes the central control module from the [holder].", "You remove the central computer mainboard from the [holder].")
				new /obj/item/circuitboard/mecha/executioner/main(get_turf(holder))
				holder.icon_state = "executioner4"
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into the [holder].", "You install the peripherals control module into the [holder].")
				qdel(used_atom)
				holder.icon_state = "executioner7"
			else
				user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
				holder.icon_state = "executioner5"
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] blessed the peripherals control module.", "You bless the peripherals control module.")
				holder.icon_state = "executioner8"
			else
				user.visible_message("[user] removes the peripherals control module from the [holder].", "You remove the peripherals control module from the [holder].")
				new /obj/item/circuitboard/mecha/executioner/peripherals(get_turf(holder))
				holder.icon_state = "executioner6"
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs the weapon control module into the [holder].", "You install the weapon control module into the [holder].")
				qdel(used_atom)
				holder.icon_state = "executioner9"
			else
				user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
				holder.icon_state = "executioner7"
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] blessed the weapon control module.", "You bless the weapon control module.")
				holder.icon_state = "executioner10"
			else
				user.visible_message("[user] removes the weapon control module from the [holder].", "You remove the weapon control module from the [holder].")
				new /obj/item/circuitboard/mecha/executioner/targeting(get_turf(holder))
				holder.icon_state = "executioner8"
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs the holy armour to the [holder].", "You install the holy armour to the [holder].")
				qdel(used_atom)
				holder.icon_state = "executioner11"
			else
				user.visible_message("[user] unfastens the weapon control module.", "You unfasten the weapon control module.")
				holder.icon_state = "executioner9"
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] blessed the holy armour.", "You bless the holy armour.")
				holder.icon_state = "executioner12"
			else
				user.visible_message("[user] removes the holy armour from the [holder].", "You remove the holy armour from the [holder].")
				new /obj/item/clothing/suit/armor/riot/knight/templar(get_turf(holder))
				holder.icon_state = "executioner10"
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs the holy helmet to the [holder].", "You install holy helmet to the [holder].")
				qdel(used_atom)
				holder.icon_state = "executioner13"
			else
				user.visible_message("[user] unfastens the phasic scanner module.", "You unfasten the phasic scanner module.")
				holder.icon_state = "executioner11"
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] blessed the holy helmet.", "You bless the holy helmet.")
				holder.icon_state = "executioner14"
			else
				user.visible_message("[user] removes the holy helmet from the [holder].", "You remove the holy helmet from the [holder].")
				new /obj/item/clothing/head/helmet/riot/knight/templar(get_turf(holder))
				holder.icon_state = "executioner12"
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs the holy cross to the [holder].", "You install the holy cross to the [holder].")
				holder.icon_state = "executioner15"
			else
				user.visible_message("[user] unfastens the holy helmet.", "You unfasten the holy helmet.")
				holder.icon_state = "executioner13"
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the holy cross.", "You secure the holy cross.")
				holder.icon_state = "executioner16"
			else
				user.visible_message("[user] pries holy cross from the [holder].", "You pry holy cross from the [holder].")
				var/obj/item/stack/sheet/metal/MS = new /obj/item/stack/sheet/mineral/silver(get_turf(holder))
				MS.amount = 5
				holder.icon_state = "executioner14"
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] welds the holy cross to the [holder].", "You weld holy cross to the [holder].")
				holder.icon_state = "executioner17"
			else
				user.visible_message("[user] unfastens the holy cross.", "You unfasten the holy cross.")
				holder.icon_state = "executioner15"
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] installs the Executioner Armor Plates to the [holder].", "You install Executioner Armor Plates to the [holder].")
				qdel(used_atom)
				holder.icon_state = "executioner18"
			else
				user.visible_message("[user] cuts the holy cross from the [holder].", "You cut the holy cross from the [holder].")
				holder.icon_state = "executioner16"
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] secures Executioner Armor Plates.", "You secure Executioner Armor Plates.")
				holder.icon_state = "executioner19"
			else
				user.visible_message("[user] pries Executioner Armor Plates from the [holder].", "You pry Executioner Armor Plates from the [holder].")
				new /obj/item/mecha_parts/part/durand_armor(get_turf(holder))
				holder.icon_state = "executioner17"
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] welds Executioner Armor Plates to the [holder].", "You weld Executioner Armor Plates to the [holder].")
			else
				user.visible_message("[user] unfastens Executioner Armor Plates.", "You unfasten Executioner Armor Plates.")
				holder.icon_state = "executioner18"
		if(1)
			if(diff==FORWARD)
				user.visible_message("[user] put soulstone to the [holder]'s locket. Exosuit seems awaken now.", "You put soulstone to the [holder]'s locket. Exosuit seems awaken now.")
				qdel(used_atom)
	return 1
