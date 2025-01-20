/// печень - вырабатывает глутамат натрия из нутриентов
/obj/item/organ/internal/liver/serpentid
	name = "chemical processor"
	icon = 'modular_ss220/species/serpentids/icons/organs.dmi'
	icon_state = "liver"
	desc = "A large looking liver with some storages."
	alcohol_intensity = 2
	var/serp_production = 1
	var/serp_consuption = 5

/obj/item/organ/internal/liver/serpentid/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/organ_decay, 0.04, BASIC_RECOVER_VALUE)
	AddComponent(/datum/component/organ_toxin_damage, 0.1)

/obj/item/organ/internal/liver/serpentid/on_life()
	. = ..()
	if(!owner)
		return
	for(var/datum/reagent/chemical in owner.reagents.reagent_list)
		if(!isnull(chemical))
			if(istype(chemical,/datum/reagent/cabbagilium) && owner.get_chemical_value(chemical.id) > serp_consuption)
				chemical.holder.remove_reagent(chemical.id, serp_consuption)
				owner.reagents.add_reagent("serpadrone", serp_production)

