/datum/spell/zombie_claws
	name = "Zombie Claws"
	desc = "Toggle your claws, allowing you to slash and infect other people."
	action_icon_state = "vampire_claws"
	action_background_icon_state = "bg_vampire"
	human_req = TRUE
	clothes_req = FALSE
	antimagic_flags = NONE
	base_cooldown = 0 SECONDS
	var/list/our_claws = list()
	var/infection_stage = 1 // mostly for adminbus and testing
	var/disease

/datum/spell/zombie_claws/Destroy()
	QDEL_LIST_CONTENTS(our_claws)
	return ..()

/datum/spell/zombie_claws/cast(mob/user)
	if(dispel())
		return

	var/obj/item/zombie_claw/claws
	if(HAS_TRAIT(user, TRAIT_PLAGUE_ZOMBIE))
		claws = new /obj/item/zombie_claw/plague_claw(user.loc, src, disease)
	else
		claws = new /obj/item/zombie_claw(user.loc, src)
		claws.infection_stage = infection_stage

	if(user.put_in_hands(claws))
		our_claws += claws
	else
		qdel(claws)
		to_chat(user, "<span class='warning zombie'>We have no claws...</span>")

/datum/spell/zombie_claws/proc/dispel()
	var/mob/living/carbon/human/user = action.owner
	var/obj/item/zombie_claw/claw = user.get_active_hand()
	if(istype(claw, /obj/item/zombie_claw) || istype(claw, /obj/item/zombie_claw/plague_claw))
		qdel(claw)
		return TRUE

/datum/spell/zombie_claws/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	if(!L.get_active_hand() && !user.is_holding_item_of_type(/obj/item/zombie_claw/))
		return TRUE

/datum/spell/zombie_claws/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/item/zombie_claw
	name = "claws"
	desc = "Claws extending from your rotting hands, perfect for ripping skulls open for the brains inside."
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "vamp_claws"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	flags = ABSTRACT | NODROP | DROPDEL
	gender = PLURAL
	force = 21 // allows them to break down doors aka NOT FUCKING AROUND
	armor_penetration_percentage = -20
	attack_effect_override = ATTACK_EFFECT_CLAW
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "sliced", "torn", "ripped", "mauled", "cut", "savaged", "clawed")
	sprite_sheets_inhand = list("Vox" = 'icons/mob/clothing/species/vox/held.dmi', "Drask" = 'icons/mob/clothing/species/drask/held.dmi')
	var/datum/spell/zombie_claws/parent_spell
	var/force_weak = 10
	var/infection_stage = 1
	var/claw_disease

	new_attack_chain = TRUE


/obj/item/zombie_claw/Initialize(mapload, new_parent_spell)
	. = ..()
	if(new_parent_spell)
		parent_spell = new_parent_spell
		RegisterSignal(parent_spell.action.owner, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(dispel))

/obj/item/zombie_claw/proc/dispel(mob/user)
	if(user && user.get_active_hand() == src)
		qdel(src)

/obj/item/zombie_claw/Destroy()
	if(parent_spell)
		UnregisterSignal(parent_spell.action.owner, COMSIG_MOB_WILLINGLY_DROP)
		if(parent_spell)
			parent_spell.our_claws -= src
			parent_spell = null
	return ..()

/obj/item/zombie_claw/customised_abstract_text(mob/living/carbon/owner)
	return "<span class='warning'>[owner.p_they(TRUE)] [owner.p_have(FALSE)] dull claws extending from [owner.p_their(FALSE)] [owner.l_hand == src ? "left hand" : "right hand"].</span>"

/obj/item/zombie_claw/pre_attack(atom/target, mob/living/user, params)
	. = ..()
	if(!HAS_TRAIT(user, TRAIT_PLAGUE_ZOMBIE))
		if(user.reagents.has_reagent("zombiecure2"))
			force = force_weak
		else
			force = initial(force)

/obj/item/zombie_claw/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(!ishuman(target) || ismachineperson(target))
		return
	var/mob/living/carbon/human/attack_target = target

	if(HAS_TRAIT(user, TRAIT_PLAGUE_ZOMBIE))
		try_virus_infect(attack_target, user, claw_disease)
		return
	else
		try_infect(attack_target, user)

	var/obj/item/organ/internal/brain/eat_brain = attack_target.get_organ_slot("brain")
	if(!eat_brain)
		return
	var/obj/item/organ/external/brain_holder = attack_target.get_limb_by_name(eat_brain.parent_organ)
	if(!brain_holder || brain_holder.open || brain_holder.limb_name != user.zone_selected)
		return

	// Max damage - 5
	if(brain_holder.brute_dam + brain_holder.burn_dam <= brain_holder.max_damage - 5) // Deal more damage
		return

	if(attack_target.getarmor(brain_holder, MELEE) > 0) // dont count negative armor
		to_chat(user, "<span class='warning zombie'>[target]'s brains are blocked.</span>")
		return // Armor blocks zombies trying to eat your brains!

	to_chat(target, "<span class='userdanger'>[user]'s claws dig into your [brain_holder.encased]!</span>")
	user.visible_message("<span class='danger'>[user] digs their claws into [target]'s [brain_holder.name]!</span>", "<span class='danger zombie'>We dig into [target]'s [brain_holder.encased ? brain_holder.encased : brain_holder]...</span>")
	playsound(user, 'sound/weapons/armblade.ogg', 50, TRUE)
	if(!do_mob(user, target, 3 SECONDS))
		return FALSE

	playsound(user.loc, 'sound/misc/moist_impact.ogg', 50, TRUE)
	brain_holder.fracture()
	brain_holder.broken_description = "split open"
	brain_holder.open = ORGAN_ORGANIC_VIOLENT_OPEN
	to_chat(target, "<span class='userdanger'>Your [brain_holder.name] is violently cracked open!</span>")
	user.visible_message("<span class='danger'>[user] violently splits apart [target]'s [brain_holder.name]!</span>", "<span class='danger zombie'>We crack apart [target]'s [brain_holder.name]!</span>")
	return TRUE


/obj/item/zombie_claw/proc/try_infect(mob/living/carbon/human/target, mob/living/user)
	if(!ishuman(target) || HAS_TRAIT(user, TRAIT_NON_INFECTIOUS_ZOMBIE))
		return
	if(!(user.zone_selected in list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)))
		to_chat(user, "<span class='warning zombie'>Our infection cannot spread without their head or chest.</span>")
		return
	if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
		return FALSE
	if(target.reagents.has_reagent("zombiecure1") || target.reagents.has_reagent("spaceacillin"))
		return
	var/obj/item/organ/external/affecting = target.get_organ(user.zone_selected) // Head, or Chest.
	if(affecting.is_robotic())
		return // We don't want people to be infected via zombie claws if they're augmented or have robotic limbs. Bites are handled differently.
	if(prob(3 * target.getarmor(user.zone_selected, MELEE)) || prob(50)) // more than 33.34 melee armor will always protect you! Or just get lucky B)
		return // Armor blocks zombies trying to eat your brains!

	// already have the disease, or have contracted it. Good for feedback when being attacked while wearing a biosuit
	if(target.HasDisease(/datum/disease/zombie) || target.ContractDisease(new /datum/disease/zombie, SPREAD_BLOOD))
		playsound(user.loc, 'sound/misc/moist_impact.ogg', 50, TRUE)
		target.bleed_rate = max(5, target.bleed_rate + 1) // it transfers via blood, you know. It had to get in somehow.
		for(var/datum/disease/zombie/zomb in target.viruses)
			zomb.stage = max(zomb.stage, infection_stage)

/obj/item/zombie_claw/activate_self(mob/user)
	. = ..()
	qdel(src)


//wizard plague zombie claws
/datum/spell/zombie_claws/plague_claws
	name = "Plague Claws"
	desc = "Toggle your claws, allowing you to slash and infect people with deadly diseases."

/obj/item/zombie_claw/plague_claw
	name = "Plague Claws"
	desc = "Claws extend from your rotting hands, oozing a putrid ichor. Perfect for rending bone and flesh for your master."
	armor_penetration_flat = 15
	force = 13

/obj/item/zombie_claw/plague_claw/Initialize(mapload, new_parent_spell, disease)
	. = ..()
	claw_disease = disease

/obj/item/zombie_claw/plague_claw/customised_abstract_text(mob/living/carbon/owner)
	return "<span class='warning'>[owner.p_they(TRUE)] [owner.p_have(FALSE)] sharp, ichor-laden claws extending from [owner.p_their(FALSE)] [owner.l_hand == src ? "left hand" : "right hand"].</span>"

/obj/item/zombie_claw/plague_claw/activate_self(mob/user)
	if(..())
		return
	qdel(src) // drops if "used" in hand

/obj/item/zombie_claw/proc/try_virus_infect(mob/living/carbon/human/target, mob/living/user)
	if(!target.HasDisease(claw_disease))
		var/datum/disease/plague = new claw_disease
		target.ContractDisease(plague)
	else if(prob(40)) // 40% chance to advance the disease
		for(var/datum/disease/D in target.viruses)
			if(D.type == claw_disease && D.stage < D.max_stages)
				D.stage += 1
	target.bleed_rate = max(5, target.bleed_rate + 1) // Very sharp, ouch!

/datum/spell/zombie_leap
	name = "Frenzied Leap"
	desc = "Momentarily remove the limiters on your muscles to leap a great distance towards your targe."
	action_icon_state = "mutate"
	action_background_icon_state = "bg_vampire"
	human_req = TRUE
	clothes_req = FALSE
	antimagic_flags = NONE
	base_cooldown = 60 SECONDS

/datum/spell/zombie_leap/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/datum/spell/zombie_leap/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	if(IS_HORIZONTAL(L))
		return FALSE
	return ..()

/datum/spell/zombie_leap/cast(list/targets, mob/user)
	var/target = targets[1]
	if(isliving(user))
		playsound(user, 'sound/voice/zombie_leap.ogg', 80, FALSE)
		var/mob/living/L = user
		L.apply_status_effect(STATUS_EFFECT_CHARGING)
		L.throw_at(target, 5, 1, L, FALSE, callback = CALLBACK(L, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_CHARGING))

