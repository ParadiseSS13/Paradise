/obj/item/dissector
	name = "\improper Dissection Manager"
	desc = "An advanced handheld device that assists with the preparation and removal of non-standard alien organs."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "dissector"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_DISSECTOR

/obj/item/dissector/upgraded
	name = "\improper Improved Dissection Manager"
	desc = "An advanced handheld device that assists with the preparation and removal of non-standard alien organs. This one has had several improvements applied to it."
	icon_state = "dissector_upgrade"
	toolspeed = 0.6

// allows for perfect pristine organ extraction. Only available from non-lavaland abductor tech
/obj/item/dissector/alien
	name = "\improper Alien Dissection Manager"
	desc = "A tool of alien origin, capable of near impossible levels of precision during dissections."
	icon_state = "dissector_alien"
	origin_tech = "abductor=3"
	toolspeed = 0.2

/obj/item/dissector/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SURGICAL, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_SURGICAL_CANNOT_FAIL, ROUNDSTART_TRAIT)
	AddComponent(/datum/component/surgery_initiator)
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))

/datum/surgery_step/generic/dissect
	name = "dissect"
	allowed_tools = list(
		/obj/item/dissector/alien = 100,
		/obj/item/dissector/upgraded = 70,
		/obj/item/organ_extractor = 60,
		TOOL_DISSECTOR = 40,
		/obj/item/scalpel/laser/manager = 10,
		/obj/item/scalpel = 5,
		/obj/item/wirecutters = 2,
		/obj/item/kitchen/utensil/fork = 1,
	)
	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	failure_sound = 'sound/effects/bone_break_1.ogg'
	time = 1.5 SECONDS

/datum/surgery_step/generic/dissect/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(surgery, /datum/surgery/dissect))
		to_chat(user, "[target.surgery_container.dissection_text[surgery.step_number]]")
	return ..()

/datum/surgery_step/generic/dissect/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(surgery, /datum/surgery/dissect))
		to_chat(user, "[target.surgery_container.dissection_success_text[surgery.step_number]]")
		if(length(surgery.steps) <= surgery.step_number) // only procs if its the finishing step
			if(isalien(target)) // xenos are special snowflakes
				var/picked = pick_organ(target)
				var/obj/item/organ/internal/alien/xeno = new picked(target.loc)
				xeno.organ_quality = pick_quality(tool, surgery.get_surgery_step())
				SSblackbox.record_feedback("nested tally", "xeno_organ_type", 1, list("[picked]", xeno.organ_quality))
				target.surgery_container.xeno_specialized_organs -= picked
				for(var/obj/item/organ/internal/alien/A in target.internal_organs)
					if(A.type == xeno)
						A.remove()
				if(istype(tool, /obj/item/organ_extractor))
					var/obj/item/organ_extractor/I = tool
					I.insert_internal_organ_in_extractor(xeno)
			else
				if(istype(tool, /obj/item/organ_extractor)) // lets directly insert it into an organ extractor
					var/obj/item/organ_extractor/I = tool
					var/organ_type = pick_organ(target)
					var/obj/item/organ/internal/organ = new organ_type(target.loc)
					organ.organ_quality = pick_quality(tool, surgery.get_surgery_step())
					SSblackbox.record_feedback("nested tally", "xeno_organ_type", 1, list("[organ.type]", organ.organ_quality))
					I.insert_internal_organ_in_extractor(organ)
					return SURGERY_STEP_CONTINUE
				var/obj/item/xeno_organ/new_organ = new /obj/item/xeno_organ(target.loc)
				if(length(target.surgery_container.custom_organ_states))
					new_organ.icon_state = pick(target.surgery_container.custom_organ_states)
				new_organ.true_organ_type = pick_organ(target)
				new_organ.unknown_quality = pick_quality(tool, surgery.get_surgery_step())
				user.put_in_inactive_hand(new_organ)
				SSblackbox.record_feedback("nested tally", "xeno_organ_type", 1, list("[new_organ.true_organ_type]", new_organ.unknown_quality))
			if(!isalien(target))
				target.contains_xeno_organ = FALSE
			else if(!length(target.surgery_container.xeno_specialized_organs))
				target.contains_xeno_organ = FALSE

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/dissect/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(surgery, /datum/surgery/dissect))
		to_chat(user, "[target.surgery_container.dissection_failure_text[surgery.step_number]]")
	return SURGERY_STEP_RETRY

/datum/surgery_step/generic/dissect/proc/pick_organ(mob/living/target)
	var/chosen_organ_type
	if(!target.ignore_generic_organs && (prob(75) || !target.surgery_container.xeno_specialized_organs)) //if it has no specialized organs always roll generic
		chosen_organ_type = pick(target.surgery_container.xeno_generic_organs)
	else
		chosen_organ_type = pick(target.surgery_container.xeno_specialized_organs)
	return chosen_organ_type

/// Decides the quality of the new organ based off tool efficiency and tool bit mods
/datum/surgery_step/generic/dissect/proc/pick_quality(obj/item/I, datum/surgery_step/current_step)
	if(istype(I, /obj/item/dissector/alien))
		return ORGAN_PRISTINE
	var/quality_chance
	for(var/key in current_step.allowed_tools)
		if(ispath(key) && istype(I, key))
			quality_chance = allowed_tools[key]
			break
		else if(I.tool_behaviour == key)
			quality_chance = allowed_tools[key]
			break

	var/inverted_chance = 100 - quality_chance
	quality_chance += ((inverted_chance * 0.66) * -(I.bit_efficiency_mod - 1))
	if(prob(quality_chance / 2)) // at best, ~50% chance
		return ORGAN_PRISTINE
	if(prob(quality_chance))
		return ORGAN_NORMAL
	return ORGAN_DAMAGED

// Dissections should always end in he dissect step for organ quality sake
/datum/surgery/dissect
	name = "experimental dissection"
	requires_bodypart = FALSE  // most simplemobs wont have limbs
	possible_locs = list(BODY_ZONE_CHEST)
	target_mobtypes = list(/mob/living)
	requires_organic_bodypart = FALSE
	lying_required = FALSE
	steps = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/dissect,
	)

/datum/surgery/dissect/can_start(mob/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(target.stat == DEAD && target.contains_xeno_organ)
		return TRUE
	return FALSE

/datum/surgery_step/fake_robotics
	name = "fake robotics operations - do not use this parent object"
	allowed_tools = list()
	time = 10 SECONDS

/datum/surgery_step/fake_robotics/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(surgery, /datum/surgery/dissect))
		to_chat(user, "[target.surgery_container.dissection_text[surgery.step_number]]")
	if(tool && tool.tool_behaviour)
		tool.play_tool_sound(user, 30)
	return ..()

/datum/surgery_step/fake_robotics/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(surgery, /datum/surgery/dissect))
		to_chat(user, "[target.surgery_container.dissection_success_text[surgery.step_number]]")
	if(tool && tool.tool_behaviour)
		tool.play_tool_sound(user, 30)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/fake_robotics/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(surgery, /datum/surgery/dissect))
		to_chat(user, "[target.surgery_container.dissection_failure_text[surgery.step_number]]")
	if(tool && tool.tool_behaviour)
		tool.play_tool_sound(user, 30)
	return SURGERY_STEP_RETRY

/datum/surgery_step/fake_robotics/unscrew_hatch
	name = "unscrew hatch"
	allowed_tools = list(
		TOOL_SCREWDRIVER = 100,
		/obj/item/coin = 50,
		/obj/item/kitchen/knife = 50
	)

	time = 1.6 SECONDS

/datum/surgery_step/fake_robotics/open_hatch
	name = "open hatch"
	allowed_tools = list(
		TOOL_RETRACTOR = 100,
		TOOL_CROWBAR = 100,
		/obj/item/kitchen/utensil = 50
	)

	time = 2.4 SECONDS

/datum/surgery_step/fake_robotics/amputate
	name = "remove component"

	allowed_tools = list(
		TOOL_MULTITOOL = 100
	)

	time = 5 SECONDS

/datum/xenobiology_surgery_container
	/// Does this organ have custom icon states it should be choosing from
	var/list/custom_organ_states = list()

	/// Contains the results for any specialized organs this creature should have
	var/list/xeno_specialized_organs = list()

	/// Holds the list of all generic non-specific organs
	var/static/list/xeno_generic_organs = list(
		/obj/item/organ/internal/liver/xenobiology/toxic,
		/obj/item/organ/internal/liver/xenobiology/detox,
		/obj/item/organ/internal/heart/xenobiology/vestigial,
		/obj/item/organ/internal/heart/xenobiology/incompatible,
		/obj/item/organ/internal/appendix/xenobiology/feverish,
		/obj/item/organ/internal/appendix/xenobiology/freezing,
		/obj/item/organ/internal/kidneys/xenobiology/lethargic,
		/obj/item/organ/internal/ears/xenobiology/colorful,
	)

	/// Contains the list for which paths are needed at each dissection step.
	var/list/dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/dissect,
	)

	/// Contains specialty text for each dissection step.
	var/list/dissection_text = list(
	"<span class='notice'>You begin prepping the subject for dissection...</span>",
	"<span class='notice'>You begin to make a careful incision into the subject's corpse.</span>",
	"<span class='notice'>You begin clamping any cavities leaking fluids into the surgical site.</span>",
	"<span class='notice'>You begin forcing the dissection cavity open.</span>",
	"<span class='notice'>You begin removing an unidentifiable mass out of the subject!</span>",
	)
	/// Contains specialty text for dissection success steps
	var/list/dissection_success_text = list(
	"<span class='notice'>You successfully set up a dissection site.</span>",
	"<span class='notice'>You successfully make an incision into the dissection site.</span>",
	"<span class='notice'>You successfully clamp any leaking cavities.</span>",
	"<span class='notice'>You successfully force the dissection cavity open.</span>",
	"<span class='notice'>You remove some kind of unidentifiable mass from the subject!</span>",
	)
	/// Contains specialty text for dissection step failures
	var/list/dissection_failure_text = list(
	"<span class='warning'>The tool fails to get a grip on the corpse's surface!</span>",
	"<span class='warning'>Your hand slips, slicing open the corpse in a wrong spot with the tool!</span>",
	"<span class='warning'>Your hand slips, tearing some of the flesh from the subject and worsening the leakage!</span>",
	"<span class='warning'>Your hand slips, tearing the edges of incision!</span>",
	"<span class='warning'>The tool fails to remove the organ from the surrounding flesh!</span>",
	)

/datum/xenobiology_surgery_container/goliath
	xeno_specialized_organs = list(/obj/item/organ/internal/appendix/xenobiology/tendril)

/datum/xenobiology_surgery_container/megacarp
	xeno_specialized_organs = list(/obj/item/organ/internal/heart/xenobiology/megacarp)

/datum/xenobiology_surgery_container/morph
	xeno_specialized_organs = list(/obj/item/organ/internal/liver/xenobiology/hungry)

/datum/xenobiology_surgery_container/hound
	xeno_specialized_organs = list(/obj/item/organ/internal/liver/xenobiology/sharp)

/datum/xenobiology_surgery_container/sweating
	xeno_specialized_organs = list(/obj/item/organ/internal/kidneys/xenobiology/sweating)

/datum/xenobiology_surgery_container/watcher
	xeno_specialized_organs = list(/obj/item/organ/internal/kidneys/xenobiology/sinew)

/datum/xenobiology_surgery_container/migo
	xeno_specialized_organs = list(/obj/item/organ/internal/appendix/xenobiology/noisemaker)

/datum/xenobiology_surgery_container/spider
	xeno_specialized_organs = list(/obj/item/organ/internal/appendix/xenobiology/toxin_stinger)

/datum/xenobiology_surgery_container/hivelord
	xeno_specialized_organs = list(/obj/item/organ/internal/heart/xenobiology/hyperactive)

/datum/xenobiology_surgery_container/goldgrub
	xeno_specialized_organs = list(/obj/item/organ/internal/kidneys/xenobiology/metallic)

/datum/xenobiology_surgery_container/tomato
	xeno_specialized_organs = list(/obj/item/organ/internal/liver/xenobiology/soupy)

/datum/xenobiology_surgery_container/herald
	xeno_specialized_organs = list(/obj/item/organ/internal/lungs/xenobiology/mirror)

/datum/xenobiology_surgery_container/clown
	xeno_specialized_organs = list(
		/obj/item/organ/internal/heart/xenobiology/bananium,
		/obj/item/organ/internal/heart/xenobiology/cursed_bananium,
	)

/datum/xenobiology_surgery_container/revenant
	xeno_specialized_organs = list(/obj/item/organ/internal/appendix/xenobiology/electro_strands)

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin prepping the subject for dissection...</span>",
		"<span class='notice'>You begin to easily open up a surgical site from the ashen mound.</span>",
		"<span class='notice'>You begin removing an unidentifiable mass out of the subject!</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You successfully force the dissection cavity open.</span>",
		"<span class='notice'>You remove some kind of unidentifiable mass from the subject!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>The tool fails to get a grip on the nearly ashen pile!</span>",
		"<span class='warning'>You struggle to get the surgical site open as ash crumples back in on itself!</span>",
		"<span class='warning'>The tool fails to remove the organ from the surrounding flesh!</span>",
	)

/datum/xenobiology_surgery_container/colossus
	xeno_specialized_organs = list(/obj/item/organ/internal/cyberimp/mouth/xenobiology/vocal_remnants)

	custom_organ_states = list("colossus1", "colossus2", "colossus3", "colossus4")

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You make a careful incision into the subject's corpse.</span>",
		"<span class='notice'>You clamp any cavities leaking fluids into the surgical site.</span>",
		"<span class='notice'>You force the dissection cavity open.</span>",
		"<span class='notice'>You carefully begin severing the metal sections from the surrounding flesh.</span>",
		"<span class='notice'>You begin removing an unidentifiable mass out of the subject!</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You successfully make an incision into the dissection site.</span>",
		"<span class='notice'>You successfully clamp any leaking cavities.</span>",
		"<span class='notice'>You successfully force the dissection cavity open.</span>",
		"<span class='notice'>You manage to cut away and seperate the metal from flesh.</span>",
		"<span class='notice'>You remove some kind of unidentifiable mass from the subject!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>The tool fails to get a grip on the corpse's surface!</span>",
		"<span class='warning'>Your hand slips, slicing open the corpse in a wrong spot with the tool!</span>",
		"<span class='warning'>Your hand slips, tearing some of the flesh from the subject and worsening the leakage!</span>",
		"<span class='warning'>Your hand slips, tearing the edges of incision!</span>",
		"<span class='warning'>The mixture of metal and flesh seems impossible to distinguish in some places!</span>",
		"<span class='warning'>The tool fails to remove the organ from the surrounding flesh!</span>",
	)

/datum/xenobiology_surgery_container/pandora
	xeno_specialized_organs = list(/obj/item/organ/internal/heart/xenobiology/paradox)

	custom_organ_states = list("hiero1", "hiero2")

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/fake_robotics/unscrew_hatch,
		/datum/surgery_step/fake_robotics/open_hatch,
		/datum/surgery_step/fake_robotics/amputate,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You begin to unscrew the coverings.</span>",
		"<span class='notice'>You begin prying open the loose panel from the machine.</span>",
		"<span class='notice'>You carefully begin to disconnect the core from the surrounding power network.</span>",
		"<span class='notice'>You begin removing the core from the metal housing surrounding it.</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You successfully remove any screws keeping the panel shut.</span>",
		"<span class='notice'>You pry open the loose panels to expose the core within.</span>",
		"<span class='notice'>You successfully disconnect the core from the power connectors.</span>",
		"<span class='notice'>You remove the core from the metal housing!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>You begin to prep the subject for dissection...</span>",
		"<span class='warning'>You cant get enough torque to unscrew the rusted fastenings off!</span>",
		"<span class='warning'>You fail to find enough leverage to get the panel off!</span>",
		"<span class='warning'>You cant find how to safely remove the core from its attached wiring!</span>",
		"<span class='warning'>The tool fails to remove the core from the metal housing!</span>",
	)

/datum/xenobiology_surgery_container/legionnaire
	xeno_specialized_organs = list(/obj/item/organ/internal/ears/xenobiology/sinister)

	custom_organ_states = list("legion1", "legion2")

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/amputate,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You begin sawing through the dense bone obstructions.</span>",
		"<span class='notice'>With a sickening crunch, you begin forcing the dissection cavity open.</span>",
		"<span class='notice'>You begin removing an unidentifiable mass out of the subject!</span>"
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You manage to detach the bones away from the dissection cavity.</span>",
		"<span class='notice'>You successfully force the dissection cavity open.</span>",
		"<span class='notice'>You remove some kind of unidentifiable mass from the subject!</span>"
	)
	dissection_failure_text = list(
		"<span class='notice'>The tool fails to get a grip on the corpse's surface!</span>",
		"<span class='notice'>Your saw fails to find purchase against the hardened bone!</span>",
		"<span class='notice'>The surrounding bone refuses to budge!</span>",
		"<span class='notice'>The tool fails to remove the organ from the surrounding skeletal structure!</span>"
	)

/datum/xenobiology_surgery_container/bubblegum
	xeno_specialized_organs = list(/obj/item/organ/internal/heart/xenobiology/bloody_sack)

	custom_organ_states = list("bubblegum1", "bubblegum2", "bubblegum3", "bubblegum4")

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the corpse for dissection... If you can even call it that at this point</span>",
		"<span class='notice'>You begin removing shards and chunks of bone, clearing a spot to safely cut deeper.</span>",
		"<span class='notice'>You slowly cut your way into the pile, looking for anything other than formless flesh and bone...</span>",
		"<span class='notice'>You begin clamping the mass amount of leaking arteries in the surgical site.</span>",
		"<span class='notice'>You begin forcing the dissection cavity open.</span>",
		"<span class='notice'>You finally find something, and begin to remove a unidentifiable mass out of the mass!</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You manage to clear out the dissection site of obstructive bone.</span>",
		"<span class='notice'>You manage to cut deep enough until something of signifigance seems to reveal.</span>",
		"<span class='notice'>You successfully clamp any leaking cavities.</span>",
		"<span class='notice'>You successfully force the dissection cavity open.</span>",
		"<span class='notice'>You remove some kind of unidentifiable mass from the subject!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>The tool fails to get a grip on the corpse's surface!</span>",
		"<span class='warning'>You begin removing shards and chunks of bone, clearing a spot to safely cut deeper.</span>",
		"<span class='warning'>You slowly cut your way into the pile, looking for anything other than formless flesh and bone..</span>",
		"<span class='warning'>You clamp the mass amount of leaking arteries in the surgical site.</span>",
		"<span class='warning'>You force the dissection cavity open.</span>",
		"<span class='warning'>The tool fails to remove the organ from the surrounding flesh!</span>",
	)

/datum/xenobiology_surgery_container/alien
	xeno_specialized_organs = list(/obj/item/organ/internal/alien/hivenode)

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/saw_carapace,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You begin sawing through the chitinous outer layer.</span>",
		"<span class='notice'>You begin clamping any cavities leaking fluids into the surgical site.</span>",
		"<span class='notice'>You begin forcing the dissection cavity open.</span>",
		"<span class='notice'>You begin removing an unidentifiable mass out of the subject!</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You manage to saw through the armored exoskeleton.</span>",
		"<span class='notice'>You successfully clamp any leaking cavities.</span>",
		"<span class='notice'>You successfully force the dissection cavity open.</span>",
		"<span class='notice'>You remove some kind of unidentifiable mass from the subject!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>The tool fails to get a grip on the corpse's surface!</span>",
		"<span class='warning'>You fail to get through the armored outer layer!</span>",
		"<span class='warning'>Your hand slips, tearing some of the flesh from the subject and worsening the leakage!</span>",
		"<span class='warning'>Your hand slips, tearing the edges of incision!</span>",
		"<span class='warning'>The tool fails to remove the organ from the surrounding flesh!</span>",
	)

/datum/xenobiology_surgery_container/alien/sentinel
	xeno_specialized_organs = list(
		/obj/item/organ/internal/alien/plasmavessel,
		/obj/item/organ/internal/alien/acidgland,
		/obj/item/organ/internal/alien/neurotoxin,
		/obj/item/organ/internal/alien/hivenode,
	)

/datum/xenobiology_surgery_container/alien/larva
	xeno_specialized_organs = list(
		/obj/item/organ/internal/alien/plasmavessel/larva,
		/obj/item/organ/internal/alien/acidgland,
		/obj/item/organ/internal/alien/neurotoxin,
		/obj/item/organ/internal/alien/hivenode,
	)

/datum/xenobiology_surgery_container/alien/queen
	xeno_specialized_organs = list(
		/obj/item/organ/internal/alien/plasmavessel/queen,
		/obj/item/organ/internal/alien/acidgland,
		/obj/item/organ/internal/alien/eggsac,
		/obj/item/organ/internal/alien/neurotoxin,
		/obj/item/organ/internal/alien/resinspinner,
	)

/datum/xenobiology_surgery_container/alien/drone
	xeno_specialized_organs = list(
		/obj/item/organ/internal/alien/plasmavessel/drone,
		/obj/item/organ/internal/alien/acidgland,
		/obj/item/organ/internal/alien/resinspinner,
		/obj/item/organ/internal/alien/hivenode,
	)

/datum/xenobiology_surgery_container/alien/hunter
	xeno_specialized_organs = list(
		/obj/item/organ/internal/alien/plasmavessel/hunter,
		/obj/item/organ/internal/alien/hivenode,
		/obj/item/organ/internal/alien/resinspinner,
	)

/datum/xenobiology_surgery_container/hierophant
	xeno_specialized_organs = list(/obj/item/organ/internal/eyes/cybernetic/xenobiology/glowing)

	custom_organ_states = list("hiero1", "hiero2")

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/fake_robotics/unscrew_hatch,
		/datum/surgery_step/fake_robotics/open_hatch,
		/datum/surgery_step/fake_robotics/amputate,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You begin to unscrew the coverings.</span>",
		"<span class='notice'>You begin prying open the loose panel from the machine.</span>",
		"<span class='notice'>You carefully begin to disconnect the core from the surrounding power network.</span>",
		"<span class='notice'>You begin removing the core from the metal housing surrounding it.</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You successfully remove any screws keeping the panel shut.</span>",
		"<span class='notice'>You pry open the loose panels to expose the core within.</span>",
		"<span class='notice'>You successfully disconnect the core from the power connectors.</span>",
		"<span class='notice'>You remove the core from the metal housing!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>The tool fails to get a grip on the corpse's surface!</span>",
		"<span class='warning'>You cant get enough torque to unscrew the rusted fastenings off!</span>",
		"<span class='warning'>You fail to find enough leverage to get the panel off!</span>",
		"<span class='warning'>You cant find how to safely remove the core from its attached wiring!</span>",
		"<span class='warning'>The tool fails to remove the core from the metal housing!</span>",
	)

/datum/xenobiology_surgery_container/blobbernaut
	xeno_specialized_organs = list(/obj/item/organ/internal/eyes/xenobiology/receptors)

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You begin forcing the dissection cavity open.</span>",
		"<span class='notice'>You begin closing off one of the many leaking fluid sacks in the corpse.</span>",
		"<span class='notice'>Your work area closed filled back in. You begin to re-open it.</span>",
		"<span class='notice'>You begin closing off more leaking sacks and fluid veins.</span>",
		"<span class='notice'>This damned dissection site <b>WON'T STOP CLOSING!</b></span>",
		"<span class='notice'>You begin once again closing off more fluid sacks and leaking cavities....</span>",
		"<span class='notice'>You at last begin to remove something from the cadaver...</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You easily pry apart the semi-liquid corpse.</span>",
		"<span class='notice'>You close off one numerous leaking cavities.</span>",
		"<span class='notice'>You manage to get the dissection site back open</span>",
		"<span class='notice'>You close off more leaking sacks and fluid veins.</span>",
		"<span class='notice'>You manage to get the dissection site back open... again.</span>",
		"<span class='notice'>You finally get the leaking under control.</span>",
		"<span class='notice'>You remove some kind of unidentifiable mass from the subject!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>The tool fails to get a grip on the corpse's surface!</span>",
		"<span class='warning'>The you fail to open the incision site, it simply closes back up!</span>",
		"<span class='warning'>The leakage is too intense, you cant get it under control!</span>",
		"<span class='warning'>The you fail to open the incision site, it simply closes back up!</span>",
		"<span class='warning'>The leakage is too intense, you cant get it under control!</span>",
		"<span class='warning'>The you fail to open the incision site, it simply closes back up!</span>",
		"<span class='warning'>The leakage is too intense, you cant get it under control!</span>",
		"<span class='warning'>The tool fails to remove the organ from the goopy flesh!</span>",
	)

/datum/xenobiology_surgery_container/terror_spider
	xeno_specialized_organs = list(/obj/item/organ/internal/appendix/xenobiology/toxin_stinger/terror)

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/amputate,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You begin sawing through the chitinout outer layer.</span>",
		"<span class='notice'>You begin clamping any cavities leaking fluids into the surgical site.</span>",
		"<span class='notice'>You begin forcing the dissection cavity open.</span>",
		"<span class='notice'>You begin removing an unidentifiable mass out of the subject!</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You manage to saw through the hardened exoskeleton.</span>",
		"<span class='notice'>You clamp any cavities leaking fluids into the surgical site.</span>",
		"<span class='notice'>You force the dissection cavity open.</span>",
		"<span class='notice'>You remove some kind of unidentifiable mass from the subject!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>You begin to prep the subject for dissection...</span>",
		"<span class='warning'>Your saw fails to find purchase against the reinforced exoskeleton!</span>",
		"<span class='warning'>Your hand slips, tearing some of the flesh from the subject and worsening the leakage!</span>",
		"<span class='warning'>Your hand slips, tearing the edges of incision!</span>",
		"<span class='warning'>The tool fails to remove the organ from the surrounding flesh!</span>",
	)

/datum/xenobiology_surgery_container/vetus
	xeno_specialized_organs = list(/obj/item/organ/internal/cell/xenobiology/supercharged)

	custom_organ_states = list("vetus1", "vetus2")

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/fake_robotics/unscrew_hatch,
		/datum/surgery_step/fake_robotics/open_hatch,
		/datum/surgery_step/fake_robotics/amputate,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You begin to unscrew the coverings.</span>",
		"<span class='notice'>You begin prying open the loose panel from the machine.</span>",
		"<span class='notice'>You carefully begin to disconnect the core from the machinery without setting off any secondary explosions.</span>",
		"<span class='notice'>You begin removing the core from the metal housing surrounding it.</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You successfully remove any screws keeping the panel shut.</span>",
		"<span class='notice'>You pry open the loose panels to expose the core within.</span>",
		"<span class='notice'>You successfully disconnect the core from the power connectors.</span>",
		"<span class='notice'>You remove the core from the metal housing!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>You begin to prep the subject for dissection...</span>",
		"<span class='warning'>You cant get enough torque to unscrew the rusted fastenings off!</span>",
		"<span class='warning'>You fail to find enough leverage to get the panel off!</span>",
		"<span class='warning'>You cant find how to safely remove the core from its attached wiring!</span>",
		"<span class='warning'>The tool fails to remove the core from the metal housing!</span>",
	)

/datum/xenobiology_surgery_container/drake
	xeno_specialized_organs = list(/obj/item/organ/internal/lungs/xenobiology/flame_sack)

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/amputate,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You begin sawing through the hardened scales of the drake.</span>",
		"<span class='notice'>You carefully begin removing the scales from the corpse</span>",
		"<span class='notice'>You begin to make a careful incision into the subject's corpse.</span>",
		"<span class='notice'>You begin clamping any cavities leaking fluids into the surgical site.</span>",
		"<span class='notice'>You begin forcing the dissection cavity open.</span>",
		"<span class='notice'>You begin removing an unidentifiable mass out of the subject!</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You feel the resistance of the hardened scales give away to the saw.</span>",
		"<span class='notice'>You pluck away the remaining scales from around the dissection site.</span>",
		"<span class='notice'>You successfully make an incision into the dissection site.</span>",
		"<span class='notice'>You successfully clamp any leaking cavities.</span>",
		"<span class='notice'>You force the dissection cavity open.</span>",
		"<span class='notice'>You remove some kind of unidentifiable mass from the subject!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>The tool fails to get a grip on the corpse's surface!</span>",
		"<span class='warning'>You fail to find enough leverage to saw through the thick scales!</span>",
		"<span class='warning'>You cant get a good enough grip on the loosened scales to pluck them off!</span>",
		"<span class='warning'>Your hand slips, slicing open the corpse in a wrong spot with the tool!</span>",
		"<span class='warning'>Your hand slips, tearing some of the flesh from the subject and worsening the leakage!</span>",
		"<span class='warning'>Your hand slips, tearing the edges of incision!</span>",
		"<span class='warning'>The tool fails to remove the organ from the surrounding flesh!</span>",
	)

/datum/xenobiology_surgery_container/headslug
	xeno_specialized_organs = list(/obj/item/organ/internal/heart/xenobiology/contortion)

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You carefully begin making a tiny incision in the diminutive creature.</span>",
		"<span class='notice'>You begin removing an unidentifiable mass out of the subject!</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You successfully make an incision into the tiny creature.</span>",
		"<span class='notice'>You remove some kind of unidentifiable mass from the subject!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>The tool fails to get a grip on the corpse's surface!</span>",
		"<span class='warning'>Your hand slips, slicing open the corpse in a wrong spot with the tool!</span>",
		"<span class='warning'>The tool fails to remove the organ from the surrounding flesh!</span>",
	)

/datum/xenobiology_surgery_container/basilisk
	xeno_specialized_organs = list(/obj/item/organ/internal/kidneys/xenobiology/sweating)

	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/drill,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You begin drilling into the crystals to weakent he structure.</span>",
		"<span class='notice'>You begin breaking apart the crystals preventing access to the subject.</span>",
		"<span class='notice'>You begin removing the remaining pieces of obstructive material.</span>",
		"<span class='notice'>You begin to make a careful incision into the subject's corpse.</span>",
		"<span class='notice'>You begin clamping any cavities leaking fluids into the surgical site.</span>",
		"<span class='notice'>You begin forcing the dissection cavity open.</span>",
		"<span class='notice'>You begin removing an unidentifiable mass out of the subject!</span>",
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You drill a series of holes into the crystalline carapace.</span>",
		"<span class='notice'>You crack open the crystalline lattice into many pieces.</span>",
		"<span class='notice'>You colelct and remove the myriad of loose crystals.</span>",
		"<span class='notice'>You successfully make an incision into the dissection site.</span>",
		"<span class='notice'>You successfully clamp any leaking cavities.</span>",
		"<span class='notice'>You successfully force the dissection cavity open.</span>",
		"<span class='notice'>You remove some kind of unidentifiable mass from the subject!</span>",
	)
	dissection_failure_text = list(
		"<span class='warning'>The tool fails to get a grip on the corpse's surface!</span>",
		"<span class='warning'>You fail to drill through the hardened crystals!</span>",
		"<span class='warning'>You fail to get enough leverage to break apart the crystal lattice!</span>",
		"<span class='warning'>You cant seem to get a good grip on the irregular chunks of material!</span>",
		"<span class='warning'>Your hand slips, slicing open the corpse in a wrong spot with the tool!</span>",
		"<span class='warning'>Your hand slips, tearing some of the flesh from the subject and worsening the leakage!</span>",
		"<span class='warning'>Your hand slips, tearing the edges of incision!</span>",
		"<span class='warning'>The tool fails to remove the organ from the surrounding flesh!</span>",
	)

/datum/xenobiology_surgery_container/legion
	xeno_specialized_organs = list(/obj/item/organ/internal/heart/xenobiology/squirming)
	custom_organ_states = list("legion1", "legion2")
	dissection_tool_step = list(
		/datum/surgery_step/generic/dissect,
		/datum/surgery_step/generic/amputate,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/dissect,
	)

	dissection_text = list(
		"<span class='notice'>You begin to prep the subject for dissection...</span>",
		"<span class='notice'>You begin to saw through the thick skull plating.</span>",
		"<span class='notice'>You make a careful incision into the subject's corpse.</span>",
		"<span class='notice'>You begin cutting away at the small skulls continuing to bud up from the corpse.</span>",
		"<span class='notice'>You begin forcing the dissection cavity open.</span>",
		"<span class='notice'>You once again cut away at the budding skulls attempting to seal up the surgical site.</span>",
		"<span class='notice'>You begin removing an unidentifiable mass out of the subject!</span>"
	)
	dissection_success_text = list(
		"<span class='notice'>You successfully set up a dissection site.</span>",
		"<span class='notice'>You manage to crack through the thick skull plating.</span>",
		"<span class='notice'>You successfully make an incision into the dissection site</span>",
		"<span class='notice'>You manage to cut away and control the growing buds.</span>",
		"<span class='notice'>You force the dissection cavity open.</span>",
		"<span class='notice'>You again manage to cut away and control the growing buds.</span>",
		"<span class='notice'>You remove an unidentifiable mass out of the subject!</span>"
	)
	dissection_failure_text = list(
		"<span class='warning'>The tool fails to get a grip on the corpse's surface!</span>",
		"<span class='warning'>You cant get enough leverage to saw through the thick skull plating!</span>",
		"<span class='warning'>Your hand slips, slicing open the corpse in a wrong spot with the tool!</span>",
		"<span class='warning'>You fail to cut the buds away faster than they're regrowing!</span>",
		"<span class='warning'>Your hand slips, tearing the edges of incision!</span>",
		"<span class='warning'>You fail to cut the buds away faster than they're regrowing!</span>",
		"<span class='warning'>The tool fails to remove the organ from the surrounding flesh!</span>"
	)
