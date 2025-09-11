/datum/robolimb/etaminindustry
	company = "Etamin Industry Gold On Black"
	desc = "Модель протезированной конечности от Этамин Индастрис."
	icon = 'modular_ss220/robolimbs/icons/etaminindustry_main.dmi'
	has_subtypes = 1

/datum/robolimb/etaminindustry/etaminindustry_alt1
	company = "Etamin Industry Elite Series"
	icon = 'modular_ss220/robolimbs/icons/etaminindustry_alt1.dmi'
	parts = list("head")
	selectable = 0
	has_subtypes = null

/datum/robolimb/etaminindustry/etaminindustry_alt2
	company = "Etamin Industry SharpShooter Series"
	icon = 'modular_ss220/robolimbs/icons/etaminindustry_alt2.dmi'
	parts = list("head")
	selectable = 0
	has_subtypes = null

/datum/robolimb/etaminindustry/etaminindustry_alt3
	company = "Etamin Industry King Series"
	icon = 'modular_ss220/robolimbs/icons/etaminindustry_alt3.dmi'
	parts = list("head")
	selectable = 0
	has_subtypes = null

/datum/sprite_accessory/body_markings/head/optics/etamin
	icon = 'modular_ss220/robolimbs/icons/ei_optic.dmi'
	name = "EI Optics"
	species_allowed = list("Machine")
	icon_state = "ei_standart"
	models_allowed = list("Etamin Industry King Series")

/datum/sprite_accessory/body_markings/head/optics/etamin/alt1
	name = "EI Optics Alt"
	icon_state = "ei_alt1"

/datum/sprite_accessory/body_markings/head/optics/etamin/alt2
	name = "EI Optics Alt 2"
	icon_state = "ei_alt2"
