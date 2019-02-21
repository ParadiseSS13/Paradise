/obj/effect/proc_holder/spell/targeted/touch/banana
	name = "Banana Touch"
	desc = "A spell popular at wizard birthday parties, this spell will put on a clown costume on the target, \
		stun them with a loud HONK, and mutate them to make them more entertaining!"
	hand_path = /obj/item/melee/touch_attack/banana
	school = "transmutation"

	charge_max = 300
	clothes_req = 1
	cooldown_min = 100 //50 deciseconds reduction per rank
	action_icon_state = "clown"

/obj/item/melee/touch_attack/banana
	name = "banana touch"
	desc = "It's time to start clowning around."
	catchphrase = "NWOLC EGNEVER"
	on_use_sound = 'sound/items/AirHorn.ogg'
	icon_state = "banana_touch"
	item_state = "banana_touch"

/obj/item/melee/touch_attack/banana/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ishuman(target) || !iscarbon(user) || user.lying || user.handcuffed) //clowning around after touching yourself would unsurprisingly, be bad
		return

	var/datum/effect_system/smoke_spread/s = new
	s.set_up(5, 0, target)
	s.start()

	var/mob/living/carbon/human/H = target
	H.bananatouched()
	..()

/mob/living/carbon/human/proc/bananatouched()
	to_chat(src, "<font color='red' size='6'>HONK</font>")
	Weaken(7)
	Stun(7)
	Stuttering(15)
	do_jitter_animation(15)
	unEquip(shoes, TRUE)
	unEquip(wear_mask, TRUE)
	if(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE))
		unEquip(head, TRUE)
		unEquip(wear_suit, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/head/wizard/clown, slot_head, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/suit/wizrobe/clown, slot_wear_suit, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/shoes/clown_shoes/magical, slot_shoes, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/clownwiz, slot_wear_mask, TRUE, TRUE)
	else
		unEquip(w_uniform, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/under/rank/clown, slot_w_uniform, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/shoes/clown_shoes, slot_shoes, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/clown_hat, slot_wear_mask, TRUE, TRUE)
	mutations.Add(CLUMSY)
	mutations.Add(COMIC)
	dna.SetSEState(CLUMSYBLOCK, TRUE, TRUE)
	dna.SetSEState(COMICBLOCK, TRUE, TRUE)
	genemutcheck(src, CLUMSYBLOCK, null, MUTCHK_FORCED)
	genemutcheck(src, COMICBLOCK, null, MUTCHK_FORCED)