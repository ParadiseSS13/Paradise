/obj/effect/proc_holder/spell/targeted/touch/cluwne
	name = "Curse of the Cluwne"
	desc = "Turns the target into a fat and cursed monstrosity of a clown."
	hand_path = /obj/item/melee/touch_attack/cluwne

	school = "transmutation"

	charge_max = 600
	clothes_req = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	action_icon_state = "clown"

/mob/living/carbon/human/proc/makeCluwne()
	to_chat(src, "<span class='danger'>You feel funny.</span>")
	if(!get_int_organ(/obj/item/organ/internal/brain/cluwne))
		var/obj/item/organ/internal/brain/cluwne/idiot_brain = new
		idiot_brain.insert(src, make_cluwne = 0)
		idiot_brain.dna = dna.Clone()
	setBrainLoss(80, use_brain_mod = FALSE)
	set_nutrition(9000)
	overeatduration = 9000
	Confused(30)
	if(mind)
		mind.assigned_role = "Cluwne"

	var/obj/item/organ/internal/honktumor/cursed/tumor = new
	tumor.insert(src)
	mutations.Add(NERVOUS)
	dna.SetSEState(NERVOUSBLOCK, 1, 1)
	genemutcheck(src, NERVOUSBLOCK, null, MUTCHK_FORCED)
	rename_character(real_name, "cluwne")

	unEquip(w_uniform, 1)
	unEquip(shoes, 1)
	unEquip(gloves, 1)
	if(!istype(wear_mask, /obj/item/clothing/mask/cursedclown)) //Infinite loops otherwise
		unEquip(wear_mask, 1)
	equip_to_slot_if_possible(new /obj/item/clothing/under/cursedclown, slot_w_uniform, 1, 1, 1)
	equip_to_slot_if_possible(new /obj/item/clothing/gloves/cursedclown, slot_gloves, 1, 1, 1)
	equip_to_slot_if_possible(new /obj/item/clothing/mask/cursedclown, slot_wear_mask, 1, 1, 1)
	equip_to_slot_if_possible(new /obj/item/clothing/shoes/cursedclown, slot_shoes, 1, 1, 1)

/mob/living/carbon/human/proc/makeAntiCluwne()
	to_chat(src, "<span class='danger'>You don't feel very funny.</span>")
	adjustBrainLoss(-120)
	set_nutrition(NUTRITION_LEVEL_STARVING)
	overeatduration = 0
	SetConfused(0)
	SetJitter(0)
	if(mind)
		mind.assigned_role = "Lawyer"

	var/obj/item/organ/internal/honktumor/cursed/tumor = get_int_organ(/obj/item/organ/internal/honktumor/cursed)
	if(tumor)
		tumor.remove(src)
	else
		mutations.Remove(CLUMSY)
		mutations.Remove(COMICBLOCK)
		dna.SetSEState(CLUMSYBLOCK,0)
		dna.SetSEState(COMICBLOCK,0)
		genemutcheck(src, CLUMSYBLOCK, null, MUTCHK_FORCED)
		genemutcheck(src, COMICBLOCK, null, MUTCHK_FORCED)
	mutations.Remove(NERVOUS)
	dna.SetSEState(NERVOUSBLOCK, 0)
	genemutcheck(src, NERVOUSBLOCK, null, MUTCHK_FORCED)

	var/obj/item/clothing/under/U = w_uniform
	unEquip(w_uniform, 1)
	if(U)
		qdel(U)

	var/obj/item/clothing/shoes/S = shoes
	unEquip(shoes, 1)
	if(S)
		qdel(S)

	if(istype(wear_mask, /obj/item/clothing/mask/cursedclown))
		unEquip(wear_mask, 1)

	if(istype(gloves, /obj/item/clothing/gloves/cursedclown))
		var/obj/item/clothing/gloves/G = gloves
		unEquip(gloves, 1)
		qdel(G)

	equip_to_slot_if_possible(new /obj/item/clothing/under/lawyer/black, slot_w_uniform, 1, 1, 1)
	equip_to_slot_if_possible(new /obj/item/clothing/shoes/black, slot_shoes, 1, 1, 1)
