/obj/mecha/combat/executioner
	name = "mk. V \"The Executioner\""
	desc = "Дредноут Ордена Палача, тяжелая конфигурация огневой поддержки, созданная для уничтожения зла и еретиков. Чрезвычайно хорош в ближнем бою."
	icon = 'modular_ss220/new_mecha_executioner/icons/mecha.dmi'
	icon_state = "executioner"
	initial_icon = "executioner"
	max_temperature = 65000
	step_in = 4
	max_integrity = 350
	deflect_chance = 15
	force = 40
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 70, "bullet" = 15, "laser" = 5, "energy" = 30, "bomb" = 20, "bio" = 0, "rad" = 100, "fire" = 100, "acid" = 100)
	max_equip = 3
	wreckage = /obj/structure/mecha_wreckage/executioner

/obj/mecha/combat/executioner/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	flash_action.Grant(user, src)

/obj/mecha/combat/executioner/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	flash_action.Remove(user)
