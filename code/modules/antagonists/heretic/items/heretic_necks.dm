/obj/item/clothing/neck/heretic_focus
	name = "amber focus"
	desc = "An amber focusing glass that provides a link to the world beyond. The necklace seems to twitch, but only when you look at it from the corner of your eye."
	icon_state = "eldritch_necklace"
	resistance_flags = FIRE_PROOF
	new_attack_chain = TRUE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/neck.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/neck.dmi',
		"Grey" = 'icons/mob/clothing/species/drask/neck.dmi',
	)

/obj/item/clothing/neck/heretic_focus/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/obj/item/clothing/neck/heretic_focus/crimson_medallion
	name = "crimson medallion"
	desc = "A blood-red focusing glass that provides a link to the world beyond, and worse. Its eye is constantly twitching and gazing in all directions. It almost seems to be silently screaming..."
	icon_state = "crimson_medallion"
	/// The aura healing component. Used to delete it when taken off.
	var/datum/component/component
	/// If active or not, used to add and remove its cult and heretic buffs.
	var/active = FALSE

/obj/item/clothing/neck/heretic_focus/crimson_medallion/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK))
		return
	var/team_color = COLOR_PINK
	if(IS_CULTIST(user))
		var/datum/action/innate/cult/blood_magic/magic_holder = locate() in user.actions
		magic_holder.magic_enhanced = TRUE
		team_color = COLOR_PURPLE //I was going to keep it cult red, then remebered the red cross exists
	else if(IS_HERETIC_OR_MONSTER(user) && !active)
		for(var/datum/spell/spell_action in user.mob_spell_list)
			spell_action.cooldown_handler.recharge_duration *= 0.5
			active = TRUE
			team_color = COLOR_GREEN
	else
		team_color = pick(COLOR_PURPLE, COLOR_GREEN)

	ADD_TRAIT(user, TRAIT_MANSUS_TOUCHED, UID())
	to_chat(user, SPAN_ALERT("Your heart takes on a strange yet soothing irregular rhythm, and your blood feels significantly less viscous than it used to be. You're not sure if that's a good thing."))
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.physiology.bleed_mod *= 3
	component = user.AddComponent( \
		/datum/component/aura_healing, \
		range = 3, \
		brute_heal = 0.4, \
		burn_heal = 0.4, \
		blood_heal = 0.2, \
		suffocation_heal = 1, \
		simple_heal = 0.3, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_MANSUS_TOUCHED, \
		healing_color = team_color, \
	)

/obj/item/clothing/neck/heretic_focus/crimson_medallion/dropped(mob/living/user)
	. = ..()

	if(!istype(user))
		return

	if(HAS_TRAIT_FROM(user, TRAIT_MANSUS_TOUCHED, UID()))
		to_chat(user, SPAN_NOTICE("Your heart and blood return to their regular old rhythm and flow."))

	if(IS_HERETIC_OR_MONSTER(user) && active)
		for(var/datum/spell/spell_action in user.mob_spell_list)
			spell_action.cooldown_handler.recharge_duration *= 2
			active = FALSE
	QDEL_NULL(component)
	REMOVE_TRAIT(user, TRAIT_MANSUS_TOUCHED, UID())
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.physiology.bleed_mod /= 3

	// If boosted enable is set, to prevent false dropped() calls from repeatedly nuking the max spells.
	var/datum/action/innate/cult/blood_magic/magic_holder = locate() in user.actions
	// Remove the last spell if over new limit, as we will reduce our max spell amount. Done beforehand as it causes a index out of bounds runtime otherwise.
	if(magic_holder?.magic_enhanced)
		QDEL_NULL(magic_holder.spells[ENHANCED_BLOODCHARGE])
	magic_holder?.magic_enhanced = FALSE


/obj/item/clothing/neck/heretic_focus/crimson_medallion/activate_self(mob/user)
	if(..() || !isliving(user))
		return
	var/mob/living/our_user = user
	to_chat(our_user, SPAN_DANGER("You start tightly squeezing [src]..."))
	if(!do_after(user, 1.25 SECONDS, src))
		return
	to_chat(our_user, SPAN_DANGER("[src] explodes into a shower of gore and blood, drenching your arm. You can feel the blood seeping into your skin. You inmediately feel better, but soon, the feeling turns hollow as your veins itch."))
	new /obj/effect/gibspawner/generic(get_turf(src))
	var/heal_amt = our_user.adjustBruteLoss(-50)
	our_user.adjustFireLoss( -(50 - abs(heal_amt)) ) // no double dipping

	our_user.reagents?.add_reagent("unholywater", rand(6, 10))
	our_user.reagents?.add_reagent("eldritch", rand(6, 10))
	qdel(src)

/obj/item/clothing/neck/heretic_focus/crimson_medallion/examine(mob/user)
	. = ..()

	var/magic_dude
	if(IS_CULTIST(user))
		. += SPAN_CULT("This focus will allow you to store one extra spell and halve the empowering time, alongside providing a small regenerative effect.")
		magic_dude = TRUE
	if(IS_HERETIC_OR_MONSTER(user))
		. += SPAN_NOTICE("This focus will halve your spell cooldowns, alongside granting a small regenerative effect to any nearby heretics or monsters, including you.")
		magic_dude = TRUE

	if(magic_dude)
		. += SPAN_CULT("You can also squeeze it to recover a large amount of health quickly, at a cost...")

/obj/item/clothing/neck/eldritch_amulet
	name = "warm eldritch medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the world around you melts away. You see your own beating heart, and the pulsing of a thousand others."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "eye_medalion"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// A secondary clothing trait only applied to heretics.
	var/heretic_only_trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK))
		return
	if(!ishuman(user) || !IS_HERETIC_OR_MONSTER(user))
		return

	ADD_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT]_[UID()]")
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT]_[UID()]")
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "piercing eldritch medallion"
	desc = "A strange medallion. Peering through the crystalline surface, the light refracts into new and terrifying spectrums of color. You see yourself, reflected off cascading mirrors, warped into impossible shapes."
	heretic_only_trait = TRAIT_XRAY_VISION

// Cosmetic-only version
/obj/item/clothing/neck/fake_heretic_amulet
	name = "religious icon"
	desc = "A strange plastic medallion, which makes its wearer look like they're part of some cult."
	icon_state = "eldritch_necklace"


// The amulet conversion tool used by moon heretics
/obj/item/clothing/neck/heretic_focus/moon_amulet
	name = "moonlight amulet"
	desc = "A piece of the mind, the soul and the moon. Gazing into it makes your head spin and hear whispers of laughter and joy."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "moon_amulette"

/obj/item/clothing/neck/heretic_focus/moon_amulet/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return
	. += SPAN_INFORMATION("Using this amulet on the ignorant will cause them to slowly lose their minds.")
	. += SPAN_INFORMATION("Using this amulent on one who has lost their mind will cause them to go berserk.")

/obj/item/clothing/neck/heretic_focus/moon_amulet/attack(mob/living/target, mob/living/user, params)
	if(!ishuman(target))
		return . = ..()
	var/mob/living/carbon/human/hit = target
	if(!IS_HERETIC_OR_MONSTER(user))
		to_chat(user, SPAN_DANGER("You feel a presence watching you!"))
		user.apply_status_effect(/datum/status_effect/stacking/heretic_insanity)
		return
	if(hit.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
		return
	var/datum/antagonist/heretic/heretic = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/status_effect/stacking/insanity = hit.has_status_effect(/datum/status_effect/stacking/heretic_insanity)
	if(!insanity || insanity.stacks < 14 || target == user)
		hit.apply_status_effect(/datum/status_effect/stacking/heretic_insanity)
	else
		if(target.mind)
			if(length(heretic.mindslaves) < heretic.mindslave_limit)
				to_chat(user, SPAN_HIEROPHANT_WARNING("Their mind has bent to see the truth!"))
				hit.apply_status_effect(/datum/status_effect/moon_converted)
				add_attack_logs(user, target, "[target] was driven insane by [user]([src])")
				log_game("[target] was driven insane by [user]")
			else
				to_chat(user, SPAN_HIEROPHANT_WARNING("We do not have the power to drive more beings mad!"))
		else
			to_chat(user, SPAN_HIEROPHANT_WARNING("This one cannot go mad."))
	return ..()
