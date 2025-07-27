/datum/spell/touch/cluwne
	name = "Curse of the Cluwne"
	desc = "Turns the target into a fat and cursed monstrosity of a clown."
	hand_path = /obj/item/melee/touch_attack/cluwne

	base_cooldown = 1 MINUTES
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "cluwne"

/mob/living/carbon/human/proc/makeCluwne()
	if(istype(back, /obj/item/mod/control)) // Check if the target is wearing a modsuit
		var/obj/item/mod/control/modsuit_control = back
		if(istype(wear_suit, /obj/item/clothing/suit/mod)) // Check if the modsuit is deployed
			modsuit_control.active = FALSE // Instantly deactivate the modsuit - if it was activated
			modsuit_control.quick_deploy(src) // The modsuit is no longer deployed
	to_chat(src, "<span class='danger'>You feel funny.</span>")
	if(!get_int_organ(/obj/item/organ/internal/brain/cluwne))
		var/obj/item/organ/internal/brain/cluwne/idiot_brain = new
		idiot_brain.insert(src, make_cluwne = 0)
		idiot_brain.dna = dna.Clone()
	setBrainLoss(80, use_brain_mod = FALSE)
	set_nutrition(9000)
	overeatduration = 9000
	Confused(60 SECONDS)
	if(mind)
		mind.assigned_role = "Cluwne"


	dna.SetSEState(GLOB.nervousblock, 1, 1)
	singlemutcheck(src, GLOB.nervousblock, MUTCHK_FORCED)
	rename_character(real_name, "cluwne")

	drop_item_to_ground(w_uniform, force = TRUE)
	drop_item_to_ground(shoes, force = TRUE)
	drop_item_to_ground(gloves, force = TRUE)
	var/obj/item/organ/internal/honktumor/cursed/tumor = new
	tumor.insert(src)
	if(!istype(wear_mask, /obj/item/clothing/mask/cursedclown)) //Infinite loops otherwise
		drop_item_to_ground(wear_mask, force = TRUE)
	equip_to_slot_if_possible(new /obj/item/clothing/under/cursedclown, ITEM_SLOT_JUMPSUIT, TRUE, TRUE)
	equip_to_slot_if_possible(new /obj/item/clothing/gloves/cursedclown, ITEM_SLOT_GLOVES, TRUE, TRUE)
	equip_to_slot_if_possible(new /obj/item/clothing/mask/cursedclown, ITEM_SLOT_MASK, TRUE, TRUE)
	equip_to_slot_if_possible(new /obj/item/clothing/shoes/cursedclown, ITEM_SLOT_SHOES, TRUE, TRUE)

/mob/living/carbon/human/proc/makeAntiCluwne()
	to_chat(src, "<span class='danger'>You don't feel very funny.</span>")
	adjustBrainLoss(-120)
	set_nutrition(NUTRITION_LEVEL_STARVING)
	overeatduration = 0
	SetConfused(0)
	SetJitter(0)
	if(mind)
		mind.assigned_role = "Internal Affairs Agent"

	var/obj/item/organ/internal/honktumor/cursed/tumor = get_int_organ(/obj/item/organ/internal/honktumor/cursed)
	if(tumor)
		tumor.remove(src)
	else
		dna.SetSEState(GLOB.clumsyblock, FALSE)
		dna.SetSEState(GLOB.comicblock, FALSE)
		singlemutcheck(src, GLOB.clumsyblock, MUTCHK_FORCED)
		singlemutcheck(src, GLOB.comicblock, MUTCHK_FORCED)
	dna.SetSEState(GLOB.nervousblock, FALSE)
	singlemutcheck(src, GLOB.nervousblock, MUTCHK_FORCED)

	qdel(w_uniform)
	qdel(shoes)

	if(istype(wear_mask, /obj/item/clothing/mask/cursedclown))
		qdel(wear_mask)

	if(istype(gloves, /obj/item/clothing/gloves/cursedclown))
		qdel(gloves)

	equip_to_slot_if_possible(new /obj/item/clothing/under/rank/procedure/iaa/formal/black, ITEM_SLOT_JUMPSUIT, TRUE, TRUE)
	equip_to_slot_if_possible(new /obj/item/clothing/shoes/black, ITEM_SLOT_SHOES, TRUE, TRUE)
