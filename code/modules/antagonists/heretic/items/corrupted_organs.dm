/// Renders you unable to see people who were heretics at the time that this organ is gained
/obj/item/organ/internal/eyes/corrupt
	name = "corrupt orbs"
	desc = "These eyes have seen something they shouldn't have."
	status = parent_type::status | ORGAN_HAZARDOUS
	/// The override images we are applying
	var/list/hallucinations

/obj/item/organ/internal/eyes/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)
	AddElement(/datum/element/noticable_organ, "Their eyes have wide dilated pupils, and no iris. Something is moving in the darkness.", BODY_ZONE_PRECISE_EYES)

/obj/item/organ/internal/eyes/corrupt/insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(!owner.client)
		return

	var/list/human_mobs = GLOB.human_list.Copy()
	human_mobs -= owner
	for(var/mob/living/carbon/human/check_human as anything in human_mobs)
		if(!IS_HERETIC(check_human) && !prob(5)) // Throw in some false positives
			continue
		var/image/invisible_man = image('icons/blanks/32x32.dmi', check_human, "nothing")
		invisible_man.override = TRUE
		LAZYADD(hallucinations, invisible_man)

	if(LAZYLEN(hallucinations))
		owner.client.images |= hallucinations

/obj/item/organ/internal/eyes/corrupt/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(!LAZYLEN(hallucinations))
		return
	owner.client?.images -= hallucinations
	QDEL_NULL(hallucinations)


/// Randomly secretes alcohol or hallucinogens
/obj/item/organ/internal/liver/corrupt
	name = "corrupt liver"
	desc = "After what you've seen you could really go for a drink."
	status = parent_type::status | ORGAN_HAZARDOUS
	/// How much extra ingredients to add?
	var/amount_added = 5
	/// What extra ingredients can we add?
	var/time_between_injections = 5 MINUTES
	var/list/extra_ingredients = list(
		/datum/reagent/consumable/ethanol/demonsblood,
		/datum/reagent/consumable/ethanol/rum,
		/datum/reagent/consumable/ethanol/thirteenloko,
		/datum/reagent/consumable/ethanol/vodka,
		/datum/reagent/consumable/ethanol/singulo,
		/datum/reagent/consumable/ethanol/hippies_delight,
		/datum/reagent/bath_salts,
		/datum/reagent/happiness,
		/datum/reagent/lsd,
	)
	COOLDOWN_DECLARE(secrete_alcohol)


/obj/item/organ/internal/liver/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)

/obj/item/organ/internal/liver/corrupt/on_life()
	. = ..()
	if(COOLDOWN_FINISHED(src, secrete_alcohol) && prob(1))
		COOLDOWN_START(src, secrete_alcohol, time_between_injections)
		owner.reagents.add_reagent(pick(extra_ingredients, amount_added))

/// Occasionally bombards you with spooky hands and lets everyone hear your pulse.
/obj/item/organ/internal/heart/corrupt
	name = "corrupt heart"
	desc = "What corruption is this spreading along with the blood?"
	status = parent_type::status | ORGAN_HAZARDOUS
	/// How long until the next heart?
	COOLDOWN_DECLARE(hand_cooldown)

/obj/item/organ/internal/heart/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)

/obj/item/organ/internal/heart/corrupt/on_life()
	. = ..()
	if(!COOLDOWN_FINISHED(src, hand_cooldown) || IS_IN_MANSUS(owner) || owner.reagents?.has_reagent("holywater"))
		return
	fire_curse_hand(owner)
	COOLDOWN_START(src, hand_cooldown, rand(6 SECONDS, 30 SECONDS)) // Wide variance to put you off guard


/// Sometimes begin to suffocate
/obj/item/organ/internal/lungs/corrupt
	name = "corrupt lungs"
	desc = "Some things SHOULD be drowned in tar."
	status = parent_type::status | ORGAN_HAZARDOUS
	var/time_between_breaths = 2 MINUTES
	COOLDOWN_DECLARE(time_to_breathe)

/obj/item/organ/internal/lungs/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)

/obj/item/organ/internal/lungs/corrupt/on_life()
	. = ..()
	if(COOLDOWN_FINISHED(src, time_to_breathe))
		COOLDOWN_START(src, time_to_breathe, time_between_breaths)
		owner.AdjustLoseBreath(45 SECONDS, 45 SECONDS, 2 MINUTES)

/// It's full of worms
/obj/item/organ/internal/appendix/corrupt
	name = "corrupt appendix"
	desc = "What kind of dark, cosmic force is even going to bother to corrupt an appendix?"
	status = parent_type::status | ORGAN_HAZARDOUS
	/// How likely are we to spawn worms?
	var/worm_chance = 3

/obj/item/organ/internal/appendix/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)
	AddElement(/datum/element/noticable_organ, "Their abdomen is distended... and wiggling.", BODY_ZONE_PRECISE_GROIN)

/obj/item/organ/internal/appendix/corrupt/on_life()
	. = ..()
	if(owner.stat != CONSCIOUS || owner.reagents?.has_reagent("holywater") || IS_IN_MANSUS(owner)  || !prob(worm_chance))
		return
	owner.vomit(lost_nutrition = 10, blood = 0, should_confuse = TRUE, distance = 0, message = 1, vomit_type_overide = /obj/effect/decal/cleanable/vomit/nebula/worms)
	owner.KnockDown(5 SECONDS)
