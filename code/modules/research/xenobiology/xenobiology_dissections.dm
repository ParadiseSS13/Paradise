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

/obj/item/dissector/upgraded
	name = "Improved Dissection Manager"
	desc = "An advanced handheld device that assists with the preparation and removal of non-standard alien organs. This one has had several improvements applied to it."
	icon_state = "dissector_upgrade"

/obj/item/dissector/alien
	name = "Alien Dissection Manager"
	desc = "A tool of alien origin, capable of near impossible levels of precision during dissections."
	icon_state = "dissector"

/datum/surgery_step/generic/dissect
	name = "dissect"
	allowed_tools = list(
		/obj/item/dissector/alien = 100,
		/obj/item/dissector/upgraded = 70,
		TOOL_DISSECTOR = 40,
		/obj/item/scalpel/laser/manager = 10,
		/obj/item/wirecutters = 5,
		/obj/item/kitchen/utensil/fork = 1
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
	//What quality will be hidden from us?
	var/unknown_quality = ORGAN_NORMAL

/obj/item/xeno_organ/Initialize(mapload)
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
	has_ongoing_effect = TRUE

/obj/item/organ/internal/liver/xenobiology/toxic/pristine
	name = "Pristine Toxic Glands"
	organ_quality = ORGAN_PRISTINE

/obj/item/organ/internal/liver/xenobiology/toxic/trigger()
	log_debug("triggering toxic liver!")
	if(!(owner.mob_biotypes & MOB_ORGANIC))
		return
	to_chat(owner, "<span class='notice'>You feel nausious as your insides feel like they're disintegrating!</span>")
	switch(organ_quality)
		if(ORGAN_DAMAGED)
			owner.adjustToxLoss(1)
		if(ORGAN_NORMAL)
			owner.adjustToxLoss(2)
		if(ORGAN_PRISTINE)
			owner.adjustToxLoss(5)
			if(prob(5))
				owner.add_vomit_floor(toxvomit = TRUE)
				owner.AdjustConfused(rand(4 SECONDS, 6 SECONDS))

/obj/item/organ/internal/liver/xenobiology/detox
	name = "Chemical Neutralizers"
	desc = "These glands seem to absorb any liquid they come in contact with, neutralizing any unnatural substances."
	analyzer_price = 25
	has_ongoing_effect = TRUE

/obj/item/organ/internal/liver/xenobiology/detox/pristine
	name = "Pristine Chemical Neutralizers"
	organ_quality = ORGAN_PRISTINE

/obj/item/organ/internal/liver/xenobiology/detox/trigger()
	if(!(owner.mob_biotypes & MOB_ORGANIC))
		return
	switch(organ_quality)
		if(ORGAN_DAMAGED)
			owner.adjustToxLoss(-1)
		if(ORGAN_NORMAL)
			owner.adjustToxLoss(-2)
		if(ORGAN_PRISTINE) // careful, it removes good shit too
			owner.adjustToxLoss(-3)
			for(var/datum/reagent/R in owner.reagents.reagent_list)
				if(R != src)
					owner.reagents.remove_reagent(R.id,4)

/obj/item/organ/internal/heart/xenobiology/vestigial
	name = "Vestigial Organ"
	desc = "Whether this has ever had any function is a mystery. It certainly doesnt work in its current state."
	has_ongoing_effect = TRUE

/obj/item/organ/internal/heart/xenobiology/vestigial/trigger()
	if(!owner.undergoing_cardiac_arrest())
		owner.set_heartattack(TRUE) // what did you expect?


