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


/// Randomly secretes alcohol or hallucinogens when you're drinking something
/obj/item/organ/internal/liver/corrupt
	name = "corrupt liver"
	desc = "After what you've seen you could really go for a drink."
	status = parent_type::status | ORGAN_HAZARDOUS
	/// How much extra ingredients to add?
	var/amount_added = 5
	/// What extra ingredients can we add?
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

/obj/item/organ/internal/liver/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)

/obj/item/organ/internal/liver/corrupt/insert(mob/living/carbon/M, special = 0)
	. = ..()
	RegisterSignal(owner, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_drank))

/obj/item/organ/internal/liver/corrupt/remove(mob/living/carbon/M, special = 0)
	. = ..()
	UnregisterSignal(owner, COMSIG_ATOM_EXPOSE_REAGENTS)

/// If we drank something, add a little extra
/obj/item/organ/internal/liver/corrupt/proc/on_drank(atom/source, list/reagents, datum/reagents/source_reagents, methods)
	SIGNAL_HANDLER
//	if(!(methods & INGEST))
//		return
	var/datum/reagents/extra_reagents = new()
	extra_reagents.add_reagent(pick(extra_ingredients), amount_added)
//	extra_reagents.trans_to(source, amount_added, transferred_by = src, methods = INJECT)
	if(prob(20))
		to_chat(source, "<span class='warning'>As you take a sip, you feel something bubbling in your stomach...</span>")
		// qwertodo: confirm consumption is by drinking


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
	COOLDOWN_START(src, hand_cooldown, rand(6 SECONDS, 45 SECONDS)) // Wide variance to put you off guard


/// Sometimes cough out some kind of dangerous gas
/obj/item/organ/internal/lungs/corrupt
	name = "corrupt lungs"
	desc = "Some things SHOULD be drowned in tar."
	status = parent_type::status | ORGAN_HAZARDOUS

/obj/item/organ/internal/lungs/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)

///obj/item/organ/internal/lungs/corrupt/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/breather)
//	. = ..()
//	if(!. || IS_IN_MANSUS(owner) || breather.reagents?.has_reagent("holywater") || !prob(cough_chance))
//		return
// Qwertodo: tweak this to not be plasma everywhere


/// It's full of worms
/obj/item/organ/internal/appendix/corrupt
	name = "corrupt appendix"
	desc = "What kind of dark, cosmic force is even going to bother to corrupt an appendix?"
	status = parent_type::status | ORGAN_HAZARDOUS
	/// How likely are we to spawn worms?
	var/worm_chance = 2

/obj/item/organ/internal/appendix/corrupt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/corrupted_organ)
	AddElement(/datum/element/noticable_organ, "Their abdomen is distended... and wiggling.", BODY_ZONE_PRECISE_GROIN)

/obj/item/organ/internal/appendix/corrupt/on_life()
	. = ..()
	if(owner.stat != CONSCIOUS || owner.reagents?.has_reagent("holywater") || IS_IN_MANSUS(owner))
		return
//	owner.vomit(MOB_VOMIT_MESSAGE | MOB_VOMIT_HARM, vomit_type = /obj/effect/decal/cleanable/vomit/nebula/worms, distance = 0)
	owner.KnockDown(0.5 SECONDS)
