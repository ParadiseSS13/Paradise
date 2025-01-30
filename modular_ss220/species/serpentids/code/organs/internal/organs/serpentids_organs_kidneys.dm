/// почки - базовые c добавлением дикея, вырабатывают энзимы, которые позволяют ГБС скрываться
/obj/item/organ/internal/kidneys/serpentid
	name = "secreting organ"
	icon = 'modular_ss220/species/serpentids/icons/organs.dmi'
	icon_state = "kidneys"
	desc = "A large looking organ, that can inject chemicals."
	actions_types = 		list(/datum/action/item_action/organ_action/toggle/serpentid)
	action_icon = 			list(/datum/action/item_action/organ_action/toggle/serpentid = 'modular_ss220/species/serpentids/icons/organs.dmi')
	action_icon_state = 	list(/datum/action/item_action/organ_action/toggle/serpentid = "serpentid_abilities")
	var/chemical_consuption = SERPENTID_ORGAN_HUNGER_KIDNEYS
	var/cloak_engaged = FALSE
	radial_action_state = "serpentid_stealth"
	radial_action_icon = 'modular_ss220/species/serpentids/icons/organs.dmi'

/obj/item/organ/internal/kidneys/serpentid/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/organ_decay, 0.03, BASIC_RECOVER_VALUE)
	AddComponent(/datum/component/organ_toxin_damage, 0.15)
	AddComponent(/datum/component/hunger_organ)
	AddComponent(/datum/component/organ_action, radial_action_state, radial_action_icon)

/obj/item/organ/internal/kidneys/serpentid/on_life()
	. = .. ()
	if((owner.m_intent != MOVE_INTENT_RUN || owner.body_position == LYING_DOWN || (world.time - owner.last_movement) >= 5) && (!owner.stat && (owner.mobility_flags & MOBILITY_STAND) && !owner.restrained() && cloak_engaged))
		if(owner.invisibility != INVISIBILITY_LEVEL_TWO)
			owner.alpha -= 51
	else
		if(owner.invisibility != INVISIBILITY_OBSERVER)
			owner.reset_visibility()
			owner.alpha = 255
	if(owner.alpha == 0)
		owner.make_invisible()

/obj/item/organ/internal/kidneys/serpentid/switch_mode(force_off = FALSE)
	. = ..()
	if(!force_off && owner?.nutrition >= NUTRITION_LEVEL_HYPOGLYCEMIA && !cloak_engaged && !(status & ORGAN_DEAD))
		cloak_engaged = TRUE
		chemical_consuption = initial(chemical_consuption)
		owner.visible_message(span_warning("Тело [owner] начинает покрываться пятнами и преломлять свет!"))
	else
		cloak_engaged = FALSE
		chemical_consuption = 0
		owner.visible_message(span_notice("Тело [owner] перестает преломлять свет."))
	SEND_SIGNAL(src, COMSIG_ORGAN_CHANGE_CHEM_CONSUPTION, chemical_consuption)
