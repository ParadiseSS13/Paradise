/obj/effect/proc_holder/spell/targeted/touch/banana
	name = "Banana Touch"
	desc = "A spell popular at wizard birthday parties, this spell will put on a clown costume on the target, \
		stun them with a loud HONK, and mutate them to make them more entertaining! \
		Warning : Effects are permanent on non-wizards."
	hand_path = /obj/item/melee/touch_attack/banana
	school = "transmutation"

	charge_max = 300
	clothes_req = 1
	cooldown_min = 100 //50 deciseconds reduction per rank
	action_icon_state = "clown"

/obj/item/melee/touch_attack/banana
	name = "banana touch"
	desc = "It's time to start clowning around."
	catchphrase = "NWOLC YRGNA"
	on_use_sound = 'sound/items/AirHorn.ogg'
	icon_state = "banana_touch"
	item_state = "banana_touch"

/obj/item/melee/touch_attack/banana/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ishuman(target) || !iscarbon(user) || user.lying || user.handcuffed)
		return

	var/datum/effect_system/smoke_spread/s = new
	s.set_up(5, 0, target)
	s.start()

	to_chat(user, "<font color='red' size='6'>HONK</font>")
	var/mob/living/carbon/human/H = target
	H.bananatouched()
	..()

/mob/living/carbon/human/proc/bananatouched()
	to_chat(src, "<font color='red' size='6'>HONK</font>")
	Weaken(7)
	Stun(7)
	Stuttering(15)
	do_jitter_animation(15)

	if(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)) //Wizards get non-cursed clown robes and magical mask.
		unEquip(shoes, TRUE)
		unEquip(wear_mask, TRUE)
		unEquip(head, TRUE)
		unEquip(wear_suit, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/head/wizard/clown, slot_head, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/suit/wizrobe/clown, slot_wear_suit, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/shoes/clown_shoes/magical, slot_shoes, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/clownwiz, slot_wear_mask, TRUE, TRUE)
	else
		qdel(shoes)
		qdel(wear_mask)
		qdel(w_uniform)
		equip_to_slot_if_possible(new /obj/item/clothing/under/rank/clown/nodrop, slot_w_uniform, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/shoes/clown_shoes/nodrop, slot_shoes, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/clown_hat/nodrop, slot_wear_mask, TRUE, TRUE)
	dna.SetSEState(CLUMSYBLOCK, TRUE, TRUE)
	dna.SetSEState(COMICBLOCK, TRUE, TRUE)
	genemutcheck(src, CLUMSYBLOCK, null, MUTCHK_FORCED)
	genemutcheck(src, COMICBLOCK, null, MUTCHK_FORCED)
	if(!(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE))) //Mutations are permanent on non-wizards. Can still be removed by genetics fuckery but not mutadone.
		dna.default_blocks.Add(CLUMSYBLOCK)
		dna.default_blocks.Add(COMICBLOCK)