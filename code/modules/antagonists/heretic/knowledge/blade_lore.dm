
/datum/heretic_knowledge_tree_column/main/blade
	neighbour_type_left = /datum/heretic_knowledge_tree_column/void_to_blade
	neighbour_type_right = /datum/heretic_knowledge_tree_column/blade_to_rust

	route = PATH_BLADE
	ui_bgr = "node_blade"

	start = /datum/heretic_knowledge/limited_amount/starting/base_blade
	grasp = /datum/heretic_knowledge/blade_grasp
	tier1 = /datum/heretic_knowledge/blade_dance
	mark = /datum/heretic_knowledge/mark/blade_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/blade
	unique_ability = /datum/heretic_knowledge/spell/realignment
	tier2 = /datum/heretic_knowledge/duel_stance
	blade = /datum/heretic_knowledge/blade_upgrade/blade
	tier3 =	 /datum/heretic_knowledge/spell/furious_steel
	ascension = /datum/heretic_knowledge/ultimate/blade_final

/datum/heretic_knowledge/limited_amount/starting/base_blade
	name = "The Cutting Edge"
	desc = "Opens up the Path of Blades to you. \
		Allows you to transmute a knife with one bar of silver or titanium to create a Sundered Blade. \
		You can create up to five at a time."
	gain_text = "Our great ancestors forged swords and practiced sparring on the eve of great battles."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		list(/obj/item/stack/sheet/mineral/silver, /obj/item/stack/sheet/mineral/titanium) = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/dark)
	limit = 5 // It's the blade path, it's a given
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"

/datum/heretic_knowledge/blade_grasp
	name = "Grasp of the Blade"
	desc = "Your Mansus Grasp will cause a short stun when used on someone lying down or facing away from you."
	gain_text = "The story of the footsoldier has been told since antiquity. It is one of blood and valor, \
		and is championed by sword, steel and silver."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_blade"

/datum/heretic_knowledge/blade_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/blade_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/blade_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!check_behind(source, target))
		return

	// We're officially behind them, apply effects
	target.Weaken(2 SECONDS)
	target.apply_damage(10, BRUTE)
	playsound(target, 'sound/weapons/guillotine.ogg', 100, TRUE)

/// The cooldown duration between triggers of blade dance
#define BLADE_DANCE_COOLDOWN (20 SECONDS)

/datum/heretic_knowledge/blade_dance
	name = "Dance of the Brand"
	desc = "Being attacked while wielding a Heretic Blade in either hand will deliver a riposte \
		towards your attacker. This effect can only trigger once every 20 seconds."
	gain_text = "The footsoldier was known to be a fearsome duelist. \
		Their general quickly appointed them as their personal Champion."
	cost = 1
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "shatter"
	/// Whether the counter-attack is ready or not.
	/// Used instead of cooldowns, so we can give feedback when it's ready again
	var/riposte_ready = TRUE

/datum/heretic_knowledge/blade_dance/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(on_shield_reaction))

/datum/heretic_knowledge/blade_dance/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS)

/datum/heretic_knowledge/blade_dance/proc/on_shield_reaction(
	mob/living/carbon/human/source,
	atom/movable/hitby,
	attack_text = "the attack",
	final_block_chance = 0,
	damage = 0,
	attack_type = MELEE_ATTACK,
	damage_type = BRUTE
)

	SIGNAL_HANDLER

	if(attack_type != MELEE_ATTACK && attack_type != UNARMED_ATTACK)
		return

	if(!riposte_ready)
		return

	if(HAS_TRAIT(source, TRAIT_HANDS_BLOCKED))
		return

	var/mob/living/attacker = hitby.loc
	if(!istype(attacker))
		attacker = hitby

	if(!istype(attacker))
		return

	if(!source.Adjacent(attacker))
		return

	// Let's check their held items to see if we can do a riposte
	var/obj/item/main_hand = source.l_hand
	var/obj/item/off_hand = source.r_hand
	// This is the item that ends up doing the "blocking" (flavor)
	var/obj/item/striking_with

	// First we'll check if the offhand is valid
	if(!QDELETED(off_hand) && istype(off_hand, /obj/item/melee/sickly_blade))
		striking_with = off_hand

	// Then we'll check the mainhand
	// We do mainhand second, because we want to prioritize it over the offhand
	if(!QDELETED(main_hand) && istype(main_hand, /obj/item/melee/sickly_blade))
		striking_with = main_hand

	// No valid item in either slot? No riposte
	if(!striking_with)
		return

	// If we made it here, deliver the strike
	INVOKE_ASYNC(src, PROC_REF(counter_attack), source, attacker, striking_with, attack_text)

	// And reset after a bit
	riposte_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(reset_riposte), source), BLADE_DANCE_COOLDOWN)
	return SHIELD_BLOCK

/datum/heretic_knowledge/blade_dance/proc/counter_attack(mob/living/carbon/human/source, mob/living/target, obj/item/melee/sickly_blade/weapon, attack_text)
	if(source == target) // no riposte of ourself
		return
	playsound(get_turf(source), 'sound/weapons/parry.ogg', 100, TRUE)
	source.visible_message(
		"<span class='warning'>[source] leans into [attack_text] and delivers a sudden riposte back at [target]!</span>",
		"<span class='warning'>You lean into [attack_text] and deliver a sudden riposte back at [target]!</span>",
		"<span class='hear'>You hear a clink, followed by a stab.</span>",
	)
	weapon.melee_attack_chain(source, target)

/datum/heretic_knowledge/blade_dance/proc/reset_riposte(mob/living/carbon/human/source)
	riposte_ready = TRUE
	to_chat(source, "<span class='hierophant'>Your riposte is ready.</span>")

#undef BLADE_DANCE_COOLDOWN

/datum/heretic_knowledge/mark/blade_mark
	name = "Mark of the Blade"
	desc = "Your Mansus Grasp now applies the Mark of the Blade. While marked, \
		the victim will be unable to leave their current room until it expires or is triggered. \
		Triggering the mark will summon a knife that will orbit you for a short time. \
		The knife will block any attack directed towards you, but is consumed on use."
	gain_text = "His general wished to end the war, but the Champion knew there could be no life without death. \
		He would slay the coward himself, and anyone who tried to run."
	mark_type = /datum/status_effect/eldritch/blade

/datum/heretic_knowledge/mark/blade_mark/create_mark(mob/living/source, mob/living/target)
	var/datum/status_effect/eldritch/blade/blade_mark = ..()
	if(istype(blade_mark))
		var/area/to_lock_to = get_area(target)
		blade_mark.locked_to = to_lock_to
		to_chat(target, "<span class='hierophant_warning'>An otherworldly force is compelling you to stay in [get_area_name(to_lock_to)]!</span>")
	return blade_mark

/datum/heretic_knowledge/mark/blade_mark/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return
	source.apply_status_effect(/datum/status_effect/protective_blades, 60 SECONDS, 1, 20, 0 SECONDS)

/datum/heretic_knowledge/knowledge_ritual/blade



/datum/heretic_knowledge/spell/realignment
	name = "Realignment"
	desc = "Grants you Realignment a spell that wil realign your body rapidly for a short period. \
		During this process, you will rapidly regenerate stamina and quickly recover from stuns, however, you will be unable to attack. \
		This spell can be cast in rapid succession, but doing so will increase the cooldown."
	gain_text = "In the flurry of death, he found peace within himself. Despite insurmountable odds, he forged on."
	action_to_add = /datum/spell/realignment
	cost = 1


/// The amount of blood flow reduced per level of severity of gained bleeding wounds for Stance of the Torn Champion.
#define BLOOD_FLOW_PER_SEVEIRTY -1

/datum/heretic_knowledge/duel_stance
	name = "Stance of the Torn Champion"
	desc = "Grants immunity to having your limbs dismembered. \
		Additionally, when damaged below 50% of your maximum health, \
		you gain resistance to batons."
	gain_text = "In time, it was he who stood alone among the bodies of his former comrades, awash in blood, none of it his own. \
		He was without rival, equal, or purpose."
	cost = 1
	research_tree_icon_path = 'icons/effects/blood.dmi'
	research_tree_icon_state = "u_madman"
	/// Whether we're currently in duelist stance, gaining certain buffs (low health)
	var/in_duelist_stance = FALSE

/datum/heretic_knowledge/duel_stance/on_gain(mob/living/carbon/human/user, datum/antagonist/heretic/our_heretic)
	for(var/obj/item/organ/external/current_organ in user.bodyparts)
		current_organ.limb_flags |= CANNOT_DISMEMBER //you can't chop of the limbs of a ghost, silly
	RegisterSignal(user, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(user, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_update))

	on_health_update(user) // Run this once, so if the knowledge is learned while hurt it activates properly

/datum/heretic_knowledge/duel_stance/on_lose(mob/living/carbon/human/user, datum/antagonist/heretic/our_heretic)
	for(var/obj/item/organ/external/current_organ in user.bodyparts)
		current_organ.limb_flags &= ~CANNOT_DISMEMBER //you can't chop of the limbs of a ghost, silly
	if(in_duelist_stance)
		REMOVE_TRAIT(user, TRAIT_BATON_RESISTANCE, type)

	UnregisterSignal(user, list(COMSIG_PARENT_EXAMINE, COMSIG_LIVING_HEALTH_UPDATE))

/datum/heretic_knowledge/duel_stance/proc/on_examine(mob/living/carbon/human/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/obj/item/held_item = source.get_active_hand()
	if(in_duelist_stance)
		examine_list += "<span class='warning'>[source] looks unnaturally poised[held_item?.force >= 15 ? " and ready to strike out":""].</span>"

/datum/heretic_knowledge/duel_stance/proc/on_health_update(mob/living/source)
	SIGNAL_HANDLER

	if(in_duelist_stance && source.health > source.maxHealth * 0.5)
		in_duelist_stance = FALSE
		REMOVE_TRAIT(source, TRAIT_BATON_RESISTANCE, type)
		return

	if(!in_duelist_stance && source.health <= source.maxHealth * 0.5)
		in_duelist_stance = TRUE
		ADD_TRAIT(source, TRAIT_BATON_RESISTANCE, type)
		SEND_SIGNAL(source, COMSIG_LIVING_CLEAR_STUNS)
		return

#undef BLOOD_FLOW_PER_SEVEIRTY

/datum/heretic_knowledge/blade_upgrade/blade
	name = "Empowered Blades"
	desc = "Attacking someone with a Sundered Blade in both hands \
		will now deliver a blow with both at once, dealing two attacks in rapid succession. \
		The second blow will be slightly weaker. \
		You are able to infuse your mansus grasp directly into your blades."
	gain_text = "I found him cleaved in twain, halves locked in a duel without end; \
		a flurry of blades, neither hitting their mark, for the Champion was indomitable."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_blade"
	/// How much force do we apply to the offhand?
	var/offand_force_decrement = 0
	/// How much force was the last weapon we offhanded with? If it's different, we need to re-calculate the decrement
	var/last_weapon_force = -1

/datum/heretic_knowledge/blade_upgrade/blade/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST, PROC_REF(on_grasp_cast))

/datum/heretic_knowledge/blade_upgrade/blade/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, list(COMSIG_TOUCH_HANDLESS_CAST, COMSIG_HERETIC_BLADE_ATTACK))

///Tries to infuse our held blade with our mansus grasp
/datum/heretic_knowledge/blade_upgrade/blade/proc/on_grasp_cast(mob/living/carbon/cast_on)
	SIGNAL_HANDLER

	var/held_item = cast_on.get_active_hand()
	if(!istype(held_item, /obj/item/melee/sickly_blade/dark))
		return NONE
	var/obj/item/melee/sickly_blade/dark/held_blade = held_item
	if(held_blade.infused)
		return NONE
	held_blade.infused = TRUE
	held_blade.update_appearance(UPDATE_ICON)

	//Infuse our off-hand blade just so it's nicer visually
	var/obj/item/melee/sickly_blade/dark/off_hand_blade = cast_on.get_inactive_hand()
	if(istype(off_hand_blade, /obj/item/melee/sickly_blade/dark))
		off_hand_blade.infused = TRUE
		off_hand_blade.update_appearance(UPDATE_ICON)

	return COMPONENT_CAST_HANDLESS

/datum/heretic_knowledge/blade_upgrade/blade/do_melee_effects(mob/living/carbon/human/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(target == source)
		return

	var/obj/item/off_hand = source.get_inactive_hand()
	if(QDELETED(off_hand) || !istype(off_hand, /obj/item/melee/sickly_blade))
		return
	// If our off-hand is the blade that's attacking,
	// quit out now to avoid an infinite stab combo
	if(off_hand == blade)
		return

	// Give it a short delay (for style, also lets people dodge it I guess)
	addtimer(CALLBACK(src, PROC_REF(follow_up_attack), source, target, off_hand), 0.25 SECONDS)

/datum/heretic_knowledge/blade_upgrade/blade/proc/follow_up_attack(mob/living/carbon/human/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(QDELETED(source) || QDELETED(target) || QDELETED(blade))
		return
	// Sanity to ensure that the blade we're delivering an offhand attack with is ACTUALLY our offhand
	if(blade != source.get_inactive_hand())
		return
	// And we easily could've moved away
	if(!source.Adjacent(target))
		return

	// Check if we need to recaclulate our offhand force
	// This is just so we don't run this block every attack, that's wasteful
	if(last_weapon_force != blade.force)
		offand_force_decrement = 0
		// We want to make sure that the offhand blade increases their hits to crit by one, just about
		// So, let's do some quick math. Yes this'll be inaccurate if their mainhand blade is modified (whetstone), no I don't care
		// Find how much force we need to detract from the second blade
		var/hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2))
		while(hits_to_crit_on_average <= 3) // 3 hits and beyond is a bit too absurd
			if(offand_force_decrement + 2 > blade.force * 0.5) // But also cutting the force beyond half is absurd
				break

			offand_force_decrement += 2
			hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2 - offand_force_decrement))

	// Save the force as our last weapon force
	last_weapon_force = blade.force
	// Subtract the decrement, but only if the target is living
	if(isliving(target))
		blade.force -= offand_force_decrement
	// Perform the offhand attack
	blade.melee_attack_chain(source, target)
	// Restore the force.
	blade.force = last_weapon_force

/datum/heretic_knowledge/spell/furious_steel
	name = "Furious Steel"
	desc = "Grants you Furious Steel, a targeted spell. Using it will summon three \
		orbiting blades around you. These blades will protect you from all attacks, \
		but are consumed on use. Additionally, you can click to fire the blades \
		at a target, dealing damage and causing bleeding."
	gain_text = "Without thinking, I took the knife of a fallen soldier and threw with all my might. My aim was true! \
		The Torn Champion smiled at their first taste of agony, and with a nod, their blades became my own."
	action_to_add = /datum/spell/fireball/furious_steel
	cost = 1

/datum/heretic_knowledge/ultimate/blade_final
	name = "Maelstrom of Silver"
	desc = "The ascension ritual of the Path of Blades. \
		Bring 3 corpses with no head to a transmutation rune to complete the ritual. \
		When completed, you will be surrounded in a constant, regenerating orbit of blades. \
		These blades will protect you from all attacks, but are consumed on use. \
		Your Furious Steel spell will also have a shorter cooldown. \
		Additionally, you become a master of combat, gaining full wound immunity and the ability to shrug off short stuns. \
		Your Sundered Blades deal bonus damage and heal you on attack for a portion of the damage dealt."
	gain_text = "The Torn Champion is freed! I will become the blade reunited, and with my greater ambition, \
		I AM UNMATCHED! A STORM OF STEEL AND SILVER IS UPON US! WITNESS MY ASCENSION!"

	announcement_text = "%SPOOKY% Master of blades, the Torn Champion's disciple, %NAME% has ascended! Their steel is that which will cut reality in a maelstom of silver! %SPOOKY%"
	announcement_sound = 'sound/ambience/antag/heretic/ascend_blade.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "bladeascend"

/datum/heretic_knowledge/ultimate/blade_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/head/head = sacrifice.get_organ("head")
	if(!head)
		return TRUE
	return FALSE

/datum/heretic_knowledge/ultimate/blade_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade_final), TRUE)
	user.apply_status_effect(/datum/status_effect/protective_blades/recharging, null, 8, 30, 0.25 SECONDS, /obj/effect/floating_blade, 1 MINUTES)
	user.add_stun_absorption(
		key = name,
		duration = INFINITY,
		message = "<span class='warning'>%EFFECT_OWNER throws off the stun!</span>",
		self_message = "<span class='warning'>You throw off the stun!</span>",
		examine_message = "<span class='hierophant_warning'>%EFFECT_OWNER_THEYRE standing stalwartly.</span>",
	)
	var/datum/spell/fireball/furious_steel/steel_spell = locate() in user.mob_spell_list
	steel_spell?.cooldown_handler.recharge_duration *= 0.5

	var/mob/living/carbon/human/heretic = user
	ADD_TRAIT(heretic, TRAIT_NO_BONES, name)
	ADD_TRAIT(heretic, TRAIT_STURDY_LIMBS, name)
	ADD_TRAIT(heretic, TRAIT_BURN_WOUND_IMMUNE, name)
	ADD_TRAIT(heretic, TRAIT_IB_IMMUNE, name)
	for(var/obj/item/organ/external/limb in heretic.bodyparts)
		limb.add_limb_flags() // Otherwise knockdowns would probably overpower the stun absorption effect.

/datum/heretic_knowledge/ultimate/blade_final/proc/on_eldritch_blade_final(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	if(target == source)
		return

	// Turns your heretic blades into eswords, pretty much.
	var/bonus_damage = clamp(30 - blade.force, 0, 12)

	target.apply_damage(
		damage = bonus_damage,
		damagetype = BRUTE,
		spread_damage = TRUE,
		sharp = TRUE,
	)

	if(target.stat != DEAD)
		// And! Get some free healing for a portion of the bonus damage dealt.
		source.heal_overall_damage(bonus_damage / 2, bonus_damage / 2)
