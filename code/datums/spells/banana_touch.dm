/datum/spell/touch/banana
	name = "Banana Touch"
	desc = "A spell popular at wizard birthday parties, this spell will put on a clown costume on the target, \
		stun them with a loud HONK, and mutate them to make them more entertaining! \
		Warning : Effects are permanent on non-wizards."
	hand_path = /obj/item/melee/touch_attack/banana

	base_cooldown = 30 SECONDS
	cooldown_min = 100 //50 deciseconds reduction per rank
	action_icon_state = "clown"

/obj/item/melee/touch_attack/banana
	name = "banana touch"
	desc = "It's time to start clowning around."
	catchphrase = "NWOLC YRGNA"
	on_use_sound = 'sound/items/AirHorn.ogg'
	icon_state = "banana_touch"
	var/is_apprentice_spell = FALSE

/datum/spell/touch/banana/apprentice
	hand_path = /obj/item/melee/touch_attack/banana/apprentice

/obj/item/melee/touch_attack/banana/apprentice
	is_apprentice_spell = TRUE

/obj/item/melee/touch_attack/banana/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(is_apprentice_spell && iswizard(target) && target != user)
		to_chat(user, "<span class='danger'>Seriously?! Honk THEM, not me!</span>")
		return
	if(!proximity_flag || target == user || blocked_by_antimagic || !ishuman(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	var/datum/effect_system/smoke_spread/s = new
	s.set_up(5, FALSE, target)
	s.start()

	to_chat(user, "<font color='red' size='6'>HONK</font>")
	var/mob/living/carbon/human/H = target
	H.bananatouched()
	handle_delete(user)

/mob/living/carbon/human/proc/bananatouched()
	to_chat(src, "<font color='red' size='6'>HONK</font>")
	Weaken(14 SECONDS)
	Stuttering(30 SECONDS)
	do_jitter_animation(30 SECONDS)

	if(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)) //Wizards get non-cursed clown robes and magical mask.
		drop_item_to_ground(shoes, force = TRUE)
		drop_item_to_ground(wear_mask, force = TRUE)
		drop_item_to_ground(head, force = TRUE)
		drop_item_to_ground(wear_suit, force = TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/head/wizard/clown, ITEM_SLOT_HEAD, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/suit/wizrobe/clown, ITEM_SLOT_OUTER_SUIT, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/shoes/clown_shoes/magical, ITEM_SLOT_SHOES, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/clownwiz, ITEM_SLOT_MASK, TRUE, TRUE)
	else
		qdel(shoes)
		qdel(wear_mask)
		qdel(w_uniform)
		equip_to_slot_if_possible(new /obj/item/clothing/under/rank/civilian/clown/nodrop, ITEM_SLOT_JUMPSUIT, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/shoes/clown_shoes/nodrop, ITEM_SLOT_SHOES, TRUE, TRUE)
		equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/clown_hat/nodrop, ITEM_SLOT_MASK, TRUE, TRUE)
	dna.SetSEState(GLOB.clumsyblock, TRUE, TRUE)
	dna.SetSEState(GLOB.comicblock, TRUE, TRUE)
	singlemutcheck(src, GLOB.clumsyblock, MUTCHK_FORCED)
	singlemutcheck(src, GLOB.comicblock, MUTCHK_FORCED)
	if(!(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE))) //Mutations are permanent on non-wizards. Can still be removed by genetics fuckery but not mutadone.
		dna.default_blocks.Add(GLOB.clumsyblock)
		dna.default_blocks.Add(GLOB.comicblock)

/// Like bananatouched, but intended to be used for funny one-off scenarios which aren't meant to permanently cripple someone's round.
/mob/living/carbon/human/proc/bananatouched_harmless()
	to_chat(src, "<font color='red' size='6'>HONK</font>")
	Weaken(14 SECONDS)
	Stuttering(30 SECONDS)
	do_jitter_animation(30 SECONDS)

	var/obj/item/tank/internal_tank = internal
	var/obj/item/clothing/mask/gas/clown_hat/clown_mask = new()
	var/obj/item/clothing/under/rank/civilian/clown/clown_suit = new()
	var/obj/item/clothing/shoes/clown_shoes/clown_shoes = new()
	clown_mask.flags |= DROPDEL
	clown_suit.flags |= DROPDEL
	clown_shoes.flags |= DROPDEL

	drop_item_to_ground(shoes, force = TRUE)
	drop_item_to_ground(wear_mask, force = TRUE)
	drop_item_to_ground(w_uniform, force = TRUE)
	if(isplasmaman(src))
		drop_item_to_ground(head, force = TRUE)
		var/obj/item/clothing/head/helmet/space/plasmaman/clown/clown_helmet = new()
		clown_suit = new /obj/item/clothing/under/plasmaman/clown
		clown_helmet.flags |= DROPDEL
		clown_suit.flags |= DROPDEL
		equip_to_slot_if_possible(clown_helmet, ITEM_SLOT_HEAD, TRUE, TRUE)
	equip_to_slot_if_possible(clown_suit, ITEM_SLOT_JUMPSUIT, TRUE, TRUE)
	equip_to_slot_if_possible(clown_shoes, ITEM_SLOT_SHOES, TRUE, TRUE)
	equip_to_slot_if_possible(clown_mask, ITEM_SLOT_MASK, TRUE, TRUE)

	// Re-equips the internal tank if present
	equip_to_appropriate_slot(internal_tank)
	internal = internal_tank

