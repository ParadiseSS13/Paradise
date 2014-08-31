//Basic crafting components -- Using cheap easily found items to create components that can be used to make more complex objects

/datum/crafting_recipe/table/igniter
	name = "Igniter"
	result_path = /obj/item/device/assembly/igniter
	reqs = list(/obj/item/weapon/lighter = 1,
	/obj/item/stack/cable_coil = 1)
	time = 20

/datum/crafting_recipe/table/voice
	name = "Voice analyzer"
	result_path = /obj/item/device/assembly/voice
	reqs = list(/obj/item/device/taperecorder = 1,
	/obj/item/stack/cable_coil = 1)
	time = 20

/datum/crafting_recipe/table/infra
	name = "Infrared Emitter"
	result_path = /obj/item/device/assembly/infra
	reqs = list(/obj/item/device/laser_pointer = 1,
	/obj/item/stack/cable_coil = 1)
	time = 20

//Medium crafting

/datum/crafting_recipe/table/IED
	name = "IED"
	result_path = /obj/item/weapon/grenade/iedcasing
	reqs = list(/obj/item/stack/cable_coil = 1,
	/obj/item/device/assembly/igniter = 1,
	/obj/item/weapon/reagent_containers/food/drinks/cans = 1,
	/datum/reagent/fuel = 10)
	time = 80

/datum/crafting_recipe/table/stunprod
	name = "Stunprod"
	result_path = /obj/item/weapon/melee/baton/cattleprod
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
	/obj/item/stack/rods = 1,
	/obj/item/weapon/wirecutters = 1,
	/obj/item/weapon/cell = 1)
	time = 80
	parts = list(/obj/item/weapon/cell = 1)

/datum/crafting_recipe/table/flamethrower
	name = "Flamethrower"
	result_path = /obj/item/weapon/flamethrower
	reqs = list(/obj/item/weapon/weldingtool = 1,
	/obj/item/device/assembly/igniter = 1,
	/obj/item/stack/rods = 2)
	tools = list(/obj/item/weapon/screwdriver)
	time = 20


//Advanced crafting

/datum/crafting_recipe/table/ed209
	name = "ED209"
	result_path = /obj/machinery/bot/ed209
	reqs = list(/obj/item/robot_parts/robot_suit = 1,
	/obj/item/clothing/head/helmet = 1,
	/obj/item/clothing/suit/armor/vest = 1,
	/obj/item/robot_parts/l_leg = 1,
	/obj/item/robot_parts/r_leg = 1,
	/obj/item/stack/sheet/metal = 5,
	/obj/item/stack/cable_coil = 5,
	/obj/item/weapon/gun/energy/taser = 1,
	/obj/item/weapon/cell = 1,
	/obj/item/device/assembly/prox_sensor = 1,
	/obj/item/robot_parts/r_arm = 1)
	tools = list(/obj/item/weapon/weldingtool, /obj/item/weapon/screwdriver)
	time = 120

/datum/crafting_recipe/table/secbot
	name = "Secbot"
	result_path = /obj/machinery/bot/secbot
	reqs = list(/obj/item/device/assembly/signaler = 1,
	/obj/item/clothing/head/helmet = 1,
	/obj/item/weapon/melee/baton = 1,
	/obj/item/device/assembly/prox_sensor = 1,
	/obj/item/robot_parts/r_arm = 1)
	tools = list(/obj/item/weapon/weldingtool)
	time = 120

/datum/crafting_recipe/table/cleanbot
	name = "Cleanbot"
	result_path = /obj/machinery/bot/cleanbot
	reqs = list(/obj/item/weapon/reagent_containers/glass/bucket = 1,
	/obj/item/device/assembly/prox_sensor = 1,
	/obj/item/robot_parts/r_arm = 1)
	time = 80

/datum/crafting_recipe/table/floorbot
	name = "Floorbot"
	result_path = /obj/machinery/bot/floorbot
	reqs = list(/obj/item/weapon/storage/toolbox/mechanical = 1,
	/obj/item/stack/tile/plasteel = 1,
	/obj/item/device/assembly/prox_sensor = 1,
	/obj/item/robot_parts/r_arm = 1)
	time = 80

/datum/crafting_recipe/table/medbot
	name = "Medbot"
	result_path = /obj/machinery/bot/medbot
	reqs = list(/obj/item/device/healthanalyzer = 1,
	/obj/item/weapon/storage/firstaid = 1,
	/obj/item/device/assembly/prox_sensor = 1,
	/obj/item/robot_parts/r_arm = 1)
	time = 80


/////////////////////////////////////////////////////////