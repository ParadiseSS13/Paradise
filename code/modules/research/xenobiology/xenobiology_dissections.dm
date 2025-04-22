/obj/item/dissector
	name = "Dissection Manager"
	desc = "An advanced handheld device that assists with the preparation and removal of non-standard alien organs."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "dissector"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_DISSECTOR

/datum/surgery_step/generic/dissect
	name = "dissect"
	allowed_tools = list(
		TOOL_DISSECTOR = 100,
		/obj/item/scalpel/laser/manager = 60,
		/obj/item/wirecutters = 15,
		/obj/item/kitchen/utensil/fork = 10
	)

	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	failure_sound = 'sound/effects/bone_break_1.ogg'
	time = 1.6 SECONDS

// We dont want to keep the unidentified organ as an implantable version to skip the research phase
/obj/item/xeno_organ
	name = "Unidentified Mass"
	desc = "This unusual clump of flesh, though now still, holds great potential. It will require revitalization via slime therapy to get any use out of."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	origin_tech = null
	// What does this object turn into when analyzed?
	var/true_organ = /obj/item/organ/internal/liver/xenobiology/toxic

	var/unknown_quality = ORGAN_NORMAL

/obj/item/xeno_organ/Initialize()
	. = ..()
	icon_state = "organ[rand(1, 18)]"

// A list of parent objects, to inherent the functions of where they are placed.
/obj/item/organ/internal/liver/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/heart/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/lungs/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/kidneys/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/appendix/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/cyberimp/arm/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/cyberimp/chest/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/cyberimp/brain/xenobiology
	name = "Unidentified Mass"
	desc = "This is a parent object and should not appear. Contact a developer."
	icon = 'icons/obj/xeno_organs.dmi'
	icon_state = "organ4"
	dead_icon = null
	origin_tech = null
	tough = TRUE

/obj/item/organ/internal/liver/xenobiology/toxic
	name = "Toxic Glands"
	desc = "These fleshy glands' alien chemistry are incompatable with most humanoid life."
	hidden_origin_tech = TECH_TOXINS
	hidden_tech_level = 6

/obj/item/organ/internal/liver/xenobiology/toxic/trigger()
	if(!(owner.mob_biotypes & MOB_ORGANIC))
		return
	to_chat(owner, "<span class='notice'>You feel nausious as your insides feel like they're disintegrating!</span>")
	owner.adjustToxLoss(5)
	log_debug("injecting someone with toxin")
