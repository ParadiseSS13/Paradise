/obj/effect/proc_holder/spell/touch/banana
	name = "Banana Touch"
	desc = "A spell popular at wizard birthday parties, this spell will put on a clown costume on the target, \
		stun them with a loud HONK, and mutate them to make them more entertaining! \
		Warning : Effects are permanent on non-wizards."
	hand_path = /obj/item/melee/touch_attack/banana
	school = "transmutation"

	base_cooldown = 30 SECONDS
	clothes_req = TRUE
	cooldown_min = 10 SECONDS //50 deciseconds reduction per rank
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

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(5, FALSE, target)
	smoke.start()

	to_chat(user, "<font color='red' size='6'>HONK</font>")
	var/mob/living/carbon/human/h_target = target
	h_target.bananatouched()
	..()


/mob/living/carbon/human/proc/bananatouched()
	to_chat(src, "<font color='red' size='6'>HONK</font>")
	Weaken(14 SECONDS)
	Stuttering(30 SECONDS)
	do_jitter_animation(15)

	if(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)) //Wizards get non-cursed clown robes and magical mask.
		drop_item_ground(shoes, force = TRUE)
		drop_item_ground(wear_mask, force = TRUE)
		drop_item_ground(head, force = TRUE)
		drop_item_ground(wear_suit, force = TRUE)
		equip_to_slot_or_del(new /obj/item/clothing/head/wizard/clown, slot_head)
		equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/clown, slot_wear_suit)
		equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes/magical)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clownwiz, slot_wear_mask)
	else
		qdel(shoes)
		qdel(wear_mask)
		qdel(w_uniform)
		equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown/nodrop, slot_w_uniform)
		equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes/nodrop, slot_shoes)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat/nodrop, slot_wear_mask)
	dna.SetSEState(GLOB.clumsyblock, TRUE, TRUE)
	dna.SetSEState(GLOB.comicblock, TRUE, TRUE)
	genemutcheck(src, GLOB.clumsyblock, null, MUTCHK_FORCED)
	genemutcheck(src, GLOB.comicblock, null, MUTCHK_FORCED)
	if(!(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE))) //Mutations are permanent on non-wizards. Can still be removed by genetics fuckery but not mutadone.
		dna.default_blocks.Add(GLOB.clumsyblock)
		dna.default_blocks.Add(GLOB.comicblock)
