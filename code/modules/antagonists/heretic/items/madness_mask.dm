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

/obj/item/clothing/mask/madness_mask/Destroy()
	local_user = null
	return ..()

/obj/item/clothing/mask/madness_mask/examine(mob/user)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(user))
		. += "<span class='notice'>Actively drains the sanity and stamina of nearby non-heretics when worn.</span>"
		. += "<span class='notice'>If forced onto the face of a non-heretic, they will be unable to remove it willingly.</span>"
	else
		. += "<span class='danger'>The eyes fill you with dread... You best avoid it.</span>"

/obj/item/clothing/mask/madness_mask/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_MASK))
		return
	if(!ishuman(user) || !user.mind)
		return

	local_user = user
	START_PROCESSING(SSobj, src)

	if(IS_HERETIC_OR_MONSTER(user))
		return

	flags |= NODROP
	to_chat(user, "<span class='userdanger'>[src] clamps tightly to your face as you feel your soul draining away!</span>")

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

	for(var/mob/living/carbon/human/human_in_range in view(local_user))
		if(IS_HERETIC_OR_MONSTER(human_in_range) || HAS_TRAIT(human_in_range, TRAIT_BLIND))
			continue

		if(human_in_range.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
			continue


		if(prob(60))
			human_in_range.SetHallucinate(30 SECONDS)

		if(prob(40))
			human_in_range.AdjustJitter(10 SECONDS)

		if(human_in_range.getStaminaLoss() <= 85 && prob(30))
			human_in_range.emote(pick("giggle", "laugh"))
			human_in_range.adjustStaminaLoss(10)

		if(prob(25))
			human_in_range.AdjustDizzy(10 SECONDS)
