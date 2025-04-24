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

/obj/item/organ/internal/liver/xenobiology/toxic/pristine
	name = "Pristine Toxic Glands"
	organ_quality = ORGAN_PRISTINE

/obj/item/organ/internal/liver/xenobiology/toxic/on_life()
	. = ..()
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

/obj/item/organ/internal/liver/xenobiology/detox/pristine
	name = "Pristine Chemical Neutralizers"
	organ_quality = ORGAN_PRISTINE

/obj/item/organ/internal/liver/xenobiology/detox/on_life()
	. = ..()
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

/obj/item/organ/internal/heart/xenobiology/vestigial/on_life()
	. = ..()
	if(!owner.undergoing_cardiac_arrest())
		owner.set_heartattack(TRUE) // what did you expect?

/obj/item/organ/internal/heart/xenobiology/incompatible
	name = "Incompatable Organ"
	desc = "This organ is largely incompatable with humanoid physiology. It will probablywork, but will cause a host of other issues."

/obj/item/organ/internal/heart/xenobiology/incompatible/on_life()
	if(!next_activation || next_activation <= world.time)
		if(prob(1))
			if(!owner.undergoing_cardiac_arrest())
				owner.set_heartattack(TRUE) // yeah probably shouldnt use this
		owner.AdjustConfused(5 SECONDS)
		owner.vomit(20)
		next_activation = world.time + 20 SECONDS

/obj/item/organ/internal/lungs/xenobiology/flame_sack
	name = "Flame Sack"
	desc = "An unusual set of aerosolizing glands capable of starting light fires."

/obj/item/organ/internal/lungs/xenobiology/flame_sack/pristine
	name = "Pristine Flame Sack"
	organ_quality = ORGAN_PRISTINE

/obj/item/organ/internal/lungs/xenobiology/flame_sack/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()
	if(!isunathi(M))
		var/datum/action/innate/unathi_ignite/fire = new()
		fire.Grant(M)
	if(organ_quality == ORGAN_PRISTINE) // grants a 3-range ash drake breath
		M.AddSpell(new /datum/spell/drake_breath)

/obj/item/organ/internal/lungs/xenobiology/flame_sack/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(!isunathi(M))
		for(var/datum/action/innate/unathi_ignite/fire in M.actions)
			fire.Remove(M)
	M.RemoveSpell(/datum/spell/drake_breath)

/datum/spell/drake_breath
	name = "Drake Breath"
	desc = "Draw from special glands in your body to produce a small, but dazzling flame!"
	base_cooldown = 3 MINUTES
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	invocation_type = "none"
	action_icon_state = "fireball0"
	sound = 'sound/magic/fireball.ogg'
	active = FALSE

	selection_activated_message = "<span class='notice'>You take in a deep bread, readying to breathe fire!</span>"
	selection_deactivated_message = "<span class='notice'>You relax your breaths as you decide not to breathe fire.</span>"

/datum/spell/drake_breath/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/external/C = new()
	C.range = 20
	return C

/datum/spell/drake_breath/update_spell_icon()
	if(!action)
		return
	action.button_overlay_icon_state = "fireball[active]"
	action.UpdateButtons()

/datum/spell/drake_breath/cast(list/targets, mob/living/user)
	. = ..()
	var/target = targets[1] //There is only ever one target
	var/turfs = line_target(0, 3, target, user)
	dragon_fire_line(user, turfs)

/datum/spell/drake_breath/proc/line_target(offset, range, atom/at, mob/living/user)
	if(!at)
		return
	var/angle = ATAN2(at.x - user.x, at.y - user.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user.x + cos(angle) * i, user.y + sin(angle) * i, user.z)
		if(!check)
			break
		T = check
	return (get_line(user, T) - get_turf(user))

/obj/item/organ/internal/kidneys/xenobiology/sinew
	name = "Sinewous Bands"
	desc = "Long, strands of durable fibers that seem to grow at astonishing speeds."

/obj/item/organ/internal/lungs/xenobiology/flame_sack/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
	. = ..()


/obj/item/organ/internal/lungs/xenobiology/flame_sack/remove(mob/living/carbon/M, special = 0)
	. = ..()










