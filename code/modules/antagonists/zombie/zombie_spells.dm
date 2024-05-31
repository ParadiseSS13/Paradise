/datum/spell/zombie_claws
	name = "Zombie Claws"
	desc = "Toggle your claws, allowing you to slash and infect other people."
	action_icon_state = "vampire_claws"
	action_background_icon_state = "bg_vampire"
	human_req = TRUE
	clothes_req = FALSE
	base_cooldown = 0 SECONDS
	var/list/our_claws = list()
	var/infection_stage = 1 // mostly for adminbus and testing

/datum/spell/zombie_claws/Destroy()
	QDEL_LIST_CONTENTS(our_claws)
	return ..()

/datum/spell/zombie_claws/cast(mob/user)
	if(dispel())
		return

	var/obj/item/zombie_claw/claws = new /obj/item/zombie_claw(user.loc, src)
	claws.infection_stage = infection_stage
	if(user.put_in_hands(claws))
		our_claws += claws
	else
		qdel(claws)
		to_chat(user, "<span class='warning zombie'>We have no claws...</span>")

/datum/spell/zombie_claws/proc/dispel()
	var/mob/living/carbon/human/user = action.owner
	var/obj/item/zombie_claw/claw = user.get_active_hand()
	if(istype(claw, /obj/item/zombie_claw))
		qdel(claw)
		return TRUE

/datum/spell/zombie_claws/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	if(!L.get_active_hand() || istype(L.get_active_hand(), /obj/item/zombie_claw))
		return ..()

/datum/spell/zombie_claws/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/item/zombie_claw
	name = "claws"
	desc = "Claws extending from your rotting hands, perfect for ripping open brain_holders for brains."
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "vamp_claws"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	flags = ABSTRACT | NODROP | DROPDEL
	gender = PLURAL
	force = 21 // allows them to break down doors aka NOT FUCKING AROUND
	armour_penetration_percentage = -20
	attack_effect_override = ATTACK_EFFECT_CLAW
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "sliced", "torn", "ripped", "mauled", "cut", "savaged", "clawed")
	sprite_sheets_inhand = list("Vox" = 'icons/mob/clothing/species/vox/held.dmi', "Drask" = 'icons/mob/clothing/species/drask/held.dmi')
	var/datum/spell/zombie_claws/parent_spell
	var/force_weak = 10
	var/infection_stage = 1

/obj/item/zombie_claw/Initialize(mapload, new_parent_spell)
	. = ..()
	parent_spell = new_parent_spell
	RegisterSignal(parent_spell.action.owner, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(dispel))

/obj/item/zombie_claw/proc/dispel(mob/user)
	if(user && user.get_active_hand() == src)
		qdel(src)

/obj/item/zombie_claw/Destroy()
	UnregisterSignal(parent_spell.action.owner, COMSIG_MOB_WILLINGLY_DROP)
	if(parent_spell)
		parent_spell.our_claws -= src
		parent_spell = null
	return ..()

/obj/item/zombie_claw/customised_abstract_text(mob/living/carbon/owner)
	return "<span class='warning'>[owner.p_they(TRUE)] [owner.p_have(FALSE)] dull claws extending from [owner.p_their(FALSE)] [owner.l_hand == src ? "left hand" : "right hand"].</span>"

/obj/item/zombie_claw/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	if(user.reagents.has_reagent("zombiecure2"))
		force = force_weak
	else
		force = initial(force)

/obj/item/zombie_claw/afterattack(atom/atom_target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(!ishuman(atom_target) || ismachineperson(atom_target))
		return
	var/mob/living/carbon/human/target = atom_target
	try_infect(target, user)

	var/obj/item/organ/internal/brain/eat_brain = target.get_organ_slot("brain")
	if(!eat_brain)
		return
	var/obj/item/organ/external/brain_holder = target.get_limb_by_name(eat_brain.parent_organ)
	if(!brain_holder || brain_holder.open || brain_holder.limb_name != user.zone_selected)
		return

	// Max damage - 5
	if(brain_holder.brute_dam + brain_holder.burn_dam <= brain_holder.max_damage - 5) // Deal more damage
		return

	if(target.getarmor(brain_holder, MELEE) > 0) // dont count negative armor
		to_chat(user, "<span class='warning zombie'>[target]'s brains are blocked.</span>")
		return // Armor blocks zombies trying to eat your brains!

	to_chat(target, "<span class='userdanger'[user]'s claws dig into your [brain_holder.encased]!</span>")
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
	if(!ishuman(target))
		return
	if(!(user.zone_selected in list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)))
		to_chat(user, "<span class='warning zombie'>Our infection cannot spread without their head or chest.</span>")
		return
	if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
		return FALSE
	if(target.reagents.has_reagent("zombiecure1") || target.reagents.has_reagent("spaceacillin"))
		return
	if(prob(3 * target.getarmor(user.zone_selected, MELEE)) || prob(50)) // more than 33.34 melee armor will always protect you! Or just get lucky B)
		return // Armor blocks zombies trying to eat your brains!

	// already have the disease, or have contracted it. Good for feedback when being attacked while wearing a biosuit
	if(target.HasDisease(/datum/disease/zombie) || target.ContractDisease(new /datum/disease/zombie))
		playsound(user.loc, 'sound/misc/moist_impact.ogg', 50, TRUE)
		target.bleed_rate = max(5, target.bleed_rate + 1) // it transfers via blood, you know. It had to get in somehow.
		for(var/datum/disease/zombie/zomb in target.viruses)
			zomb.stage = max(zomb.stage, infection_stage)

/obj/item/zombie_claw/attack_self(mob/user)
	. = ..()
	qdel(src)
