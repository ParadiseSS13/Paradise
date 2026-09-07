// The spooky "void" / "abyssal" / "madness" mask for heretics.
/obj/item/clothing/mask/madness_mask
	name = "abyssal mask"
	desc = "A mask created from suffering. When you look into its eyes, it looks back."
	icon_state = "mad_mask"
	inhand_icon_state = null
	flags = AIRTIGHT
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES
	///Who is wearing this
	var/mob/living/carbon/human/local_user
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
	)
	var/time_to_insanity = 15 SECONDS
	COOLDOWN_DECLARE(insanity_gain)

/obj/item/clothing/mask/madness_mask/Destroy()
	local_user = null
	return ..()

/obj/item/clothing/mask/madness_mask/examine(mob/user)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(user))
		. += SPAN_NOTICE("Actively drains the sanity and stamina of nearby non-heretics when worn.")
		. += SPAN_NOTICE("If forced onto the face of a non-heretic, they will be unable to remove it willingly.")
	else
		. += SPAN_DANGER("The eyes fill you with dread... You best avoid it.")

/obj/item/clothing/mask/madness_mask/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_MASK))
		return
	if(!ishuman(user) || !user.mind)
		return

	local_user = user
	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, insanity_gain, time_to_insanity)

	if(IS_HERETIC_OR_MONSTER(user))
		return

	flags |= NODROP
	to_chat(user, SPAN_USERDANGER("[src] clamps tightly to your face as you feel your soul draining away!"))

/obj/item/clothing/mask/madness_mask/dropped(mob/M)
	local_user = null
	STOP_PROCESSING(SSobj, src)
	flags &= ~NODROP
	return ..()

/obj/item/clothing/mask/madness_mask/process()
	if(!local_user)
		return PROCESS_KILL

	if(IS_HERETIC_OR_MONSTER(local_user) && (flags & NODROP))
		flags &= ~NODROP

	local_user.AdjustJitter(10 SECONDS, 10 SECONDS, 30 SECONDS)

	if(!IS_HERETIC_OR_MONSTER(local_user))
		if(COOLDOWN_FINISHED(src, insanity_gain))
			COOLDOWN_START(src, insanity_gain, time_to_insanity)
			local_user.apply_status_effect(/datum/status_effect/stacking/heretic_insanity)
		if(prob(1))
			local_user.AdjustDizzy(30 SECONDS)
			local_user.Paralyse(5 SECONDS)
			local_user.AdjustJitter(2000 SECONDS)
			local_user.adjustStaminaLoss(60)
			local_user.emote("laugh")
			local_user.visible_message("[local_user] falls to the ground and cackles uncontrollably!")
			addtimer(CALLBACK(src, PROC_REF(undo_jitter)), 5 SECONDS)

	for(var/mob/living/carbon/human/human_in_range in view(local_user))
		if(IS_HERETIC_OR_MONSTER(human_in_range) || HAS_TRAIT(human_in_range, TRAIT_BLIND))
			continue

		if(human_in_range.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
			continue

		if(human_in_range == local_user)
			continue

		if(prob(60))
			human_in_range.SetHallucinate(30 SECONDS)

		if(prob(40))
			human_in_range.AdjustJitter(10 SECONDS, 10 SECONDS, 1 MINUTES)

		if(human_in_range.getStaminaLoss() <= 85 && prob(30))
			human_in_range.emote(pick("giggle", "laugh"))
			human_in_range.adjustStaminaLoss(10)

		if(prob(25))
			human_in_range.AdjustDizzy(10 SECONDS)

/obj/item/clothing/mask/madness_mask/proc/undo_jitter()
	local_user.SetJitter(1 MINUTES)
