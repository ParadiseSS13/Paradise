#define SERPENTID_EARS_SENSE_TIME 5 SECONDS

//Уши серпентидов позволяют постоянно сканировать окружение в поисках существ в зависимости от их состояния
/obj/item/organ/internal/ears/serpentid
	name = "acoustic sensor"
	icon = 'modular_ss220/species/serpentids/icons/organs.dmi'
	icon_state = "ears"
	desc = "An organ that can sense vibrations."
	actions_types = 		list(/datum/action/item_action/organ_action/toggle/serpentid)
	action_icon = 			list(/datum/action/item_action/organ_action/toggle/serpentid = 'modular_ss220/species/serpentids/icons/organs.dmi')
	action_icon_state = 	list(/datum/action/item_action/organ_action/toggle/serpentid = "serpentid_abilities")
	var/chemical_consuption = SERPENTID_ORGAN_HUNGER_EARS
	var/active = FALSE
	radial_action_state = "serpentid_hear"
	radial_action_icon = 'modular_ss220/species/serpentids/icons/organs.dmi'

/obj/item/organ/internal/ears/serpentid/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/organ_decay, 0.05, BASIC_RECOVER_VALUE)
	AddComponent(/datum/component/organ_toxin_damage, 0.05)
	AddComponent(/datum/component/hunger_organ)
	AddComponent(/datum/component/organ_action, radial_action_state, radial_action_icon)

/obj/item/organ/internal/ears/serpentid/on_life()
	. = ..()
	if(chemical_consuption <= owner?.nutrition && active)
		if(prob(((max_damage - damage)/max_damage) * 100))
			sense_creatures()

/obj/item/organ/internal/ears/serpentid/switch_mode(force_off = FALSE)
	. = ..()
	if(!force_off && owner?.nutrition >= NUTRITION_LEVEL_HYPOGLYCEMIA && !(status & ORGAN_DEAD) && !active)
		active = TRUE
		chemical_consuption = initial(chemical_consuption)
		owner.visible_message(span_warning("Тело [owner] слегка колышется."))
	else
		active = FALSE
		chemical_consuption = 0
		owner.visible_message(span_notice("Тело [owner] перестает колыхаться."))
	SEND_SIGNAL(src, COMSIG_ORGAN_CHANGE_CHEM_CONSUPTION, chemical_consuption)

/obj/item/organ/internal/ears/serpentid/proc/sense_creatures()
	for(var/mob/living/creature in range(9, owner))
		var/last_movement_timer = world.time - creature.l_move_time
		if(creature == owner || creature.stat == DEAD || last_movement_timer > SERPENTID_EARS_SENSE_TIME)
			continue
		new /obj/effect/temp_visual/sonar_ping(owner.loc, owner, creature)

#undef SERPENTID_EARS_SENSE_TIME
