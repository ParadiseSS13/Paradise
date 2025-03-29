/obj/item/borg/upgrade/storageincreaser
	name = "storage increaser"
	desc = "Improves cyborg storage with bluespace technology to store more medicines"
	icon_state = "cyborg_upgrade2"
	origin_tech = "bluespace=4;materials=5;engineering=3"
	require_module = TRUE
	var/max_energy_multiplication = 3
	var/recharge_rate_multiplication = 2

/obj/item/borg/upgrade/storageincreaser/do_install(mob/living/silicon/robot/R)
	for(var/obj/item/borg/upgrade/storageincreaser/U in R.contents)
		to_chat(R, span_notice("A [name] unit is already installed!"))
		to_chat(usr, span_notice("There's no room for another [name] unit!"))
		return FALSE

	for(var/datum/robot_storage/energy/ES in R.module.storages)
		// ОФФы решили не делать деактиватор, поэтому против абуза сбрасываем.
		ES.max_amount = initial(ES.max_amount)
		ES.recharge_rate = initial(ES.recharge_rate)
		ES.amount = initial(ES.max_amount)

		// Modifier
		ES.max_amount *= max_energy_multiplication
		ES.recharge_rate *= recharge_rate_multiplication
		ES.amount = ES.max_amount

	return TRUE

/obj/item/borg/upgrade/hypospray
	name = "cyborg hypospray upgrade"
	desc = "Adds and replaces some reagents with better ones"
	icon_state = "cyborg_upgrade2"
	origin_tech = "biotech=6;materials=5"
	require_module = TRUE
	module_type = /obj/item/robot_module/medical
	items_to_replace = list(
		/obj/item/reagent_containers/borghypo/basic = /obj/item/reagent_containers/borghypo/basic/upgraded
	)
