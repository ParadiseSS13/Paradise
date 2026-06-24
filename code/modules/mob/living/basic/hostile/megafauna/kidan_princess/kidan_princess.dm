#define KIDAN_BOSS_STORAGE "KIDAN_BOSS_STORAGE"

/mob/living/basic/megafauna/kidan_princess
	name = "Princess Zrexx"
	desc = "One of the claimants to the throne of the shattered Kidan empire, Princess Zrexx is one of the more extreme in keeping loyal to the ways of old."
	health = 1500
	maxHealth = 1500
	gender = FEMALE
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "kidan_princess"
	icon_living = "kidan_princess"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG | MOB_EPIC
	speak_emote = list("clacks")
	death_sound = 'sound/voice/scream_kidan.ogg'
	melee_attack_cooldown_min = 0.75 SECONDS
	damage_coeff = list(BRUTE = 0.7, BURN = 0.9, TOX = 1.5, STAMINA = 0, OXY = 1)
	melee_damage_lower = 30
	melee_damage_upper = 40
	obj_damage = 80
	attack_verb_simple = "stab"
	attack_verb_continuous = "stabs"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	response_help_continuous = "hugs"
	response_help_continuous = "hug"
	response_harm_continuous = "attacks"
	response_harm_simple = "attack"
	move_force = MOVE_FORCE_NORMAL
	see_in_dark = 20 // I see you
	step_type = FOOTSTEP_MOB_SHOE
	initial_traits = list(TRAIT_NOFIRE)
	blood_color = "#FB9800"
	loot = list(
		/obj/item/kidan_princess_halberd,
		/obj/effect/decal/remains/human,
		/obj/effect/decal/cleanable/ash)
	enraged_loot = /obj/item/clothing/accessory/medal/plasma/princess
	faction = list("kidan_royalty")
	ai_controller = /datum/ai_controller/basic_controller/kidan_princess
	internal_gps = /obj/item/gps/internal/kidan_princess
	medal_type = BOSS_MEDAL_PRINCESS
	score_type = PRINCESS_SCORE
	basic_mob_flags = DEL_ON_DEATH
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/kidan_princess/summon_mobs = BB_KIDAN_PRINCESS_SUMMON_MOBS_ACTION,
		/datum/action/cooldown/mob_cooldown/kidan_princess/charge = BB_KIDAN_PRINCESS_CHARGE_ACTION,
		/datum/action/cooldown/mob_cooldown/kidan_princess/stomp = BB_KIDAN_PRINCESS_STOMP_ACTION,
		/datum/action/cooldown/mob_cooldown/kidan_princess/martial_rush = BB_KIDAN_PRINCESS_RUSH_ACTION)
	/// Is our martial rush active
	var/martial_rushing = FALSE
	/// Is this mob associated with a ruin
	var/ruin_boss = FALSE

/obj/item/gps/internal/kidan_princess
	icon_state = null
	gpstag = "Royal Invitation"
	desc = "You've been invited aboard the Ragnarok. Will you accept?"

/mob/living/basic/megafauna/kidan_princess/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aggro_emote, aggro_sound = 'sound/effects/Kidanclack.ogg', emote_chance = 100, say_list = list("You seek to challenge me? Very well! Show me your strength!"))
	add_language("Galactic Common")
	add_language("Chittin")
	set_default_language(GLOB.all_languages["Galactic Common"])
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(retaliate_callback)))

/mob/living/basic/megafauna/kidan_princess/update_icon_state()
	. = ..()
	if(martial_rushing)
		icon_state = "kidan_princess_unarmed"
		icon_living = "kidan_princess_unarmed"
		return
	icon_state = "kidan_princess"
	icon_living = "kidan_princess"

/mob/living/basic/megafauna/kidan_princess/Process_Spacemove(movement_dir, continuous_move)
	return TRUE

/mob/living/basic/megafauna/kidan_princess/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(ismob(target) && martial_rushing)
		var/mob/victim = target
		var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
		victim.throw_at(throw_target, 1, 2)

/mob/living/basic/megafauna/kidan_princess/proc/retaliate_callback(mob/living/attacker)
	if(!istype(attacker))
		return
	GLOB.kidan_shitlist += attacker
	ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, attacker)
	if(!prob(10))
		return
	var/taunt = pick(list(
		"Is that all you can do?",
		"Yes, show me more!",
		"Show me your power!",
		"My blood spilled, bravo! Bravo!",
		"That one actually hurt a bit! Haha!",
		"Come then, strike again!",
		"Not enough! More effort! More!",
		"If I am to be a queen, then I must grow stronger!",
		"Strike me down! Prove yourself strong, so that I may grow ever stronger!",
		"Fight me!",
		"Are you worthy, or are you going to hide?",
		"Show some guts and hit me again!",
		"We fight like the ways of old! This is wonderful!"
	))
	say(taunt)

/mob/living/basic/megafauna/kidan_princess/devour(mob/living/L)
	if(!L)
		return FALSE
	visible_message(
		"<span class='danger'>[src] brings down her halberd, obliterating [L] with a heavy blow!</span>",
		"<span class='userdanger'>You bring down your halberd, obliterating [L] with a heavy blow!</span>")
	playsound(loc, 'sound/effects/supermatter.ogg', 50, TRUE)
	L.dust()
	return TRUE

/mob/living/basic/megafauna/kidan_princess/death(gibbed)
	if(can_die() && ruin_boss)
		unlock_blast_doors(KIDAN_BOSS_STORAGE)
		src.visible_message(SPAN_NOTICE("Somewhere, a heavy door has opened."))
	return ..(gibbed)

/mob/living/basic/megafauna/kidan_princess/proc/unlock_blast_doors(target_id_tag)
	for(var/obj/machinery/door/poddoor/P in GLOB.airlocks)
		if(P.density && P.id_tag == target_id_tag && P.z == z && !P.operating)
			P.open()

/mob/living/basic/megafauna/kidan_princess/ruin
	ruin_boss = TRUE

/mob/living/basic/megafauna/kidan_princess/enrage()
	. = ..()
	say("You DARE sully my form with such filth?!")
	melee_attack_cooldown_max = 1.25 SECONDS

/// Special Halberd loot
/obj/item/kidan_princess_halberd
	name = "Zrexx's modified supermatter halberd"
	desc = "The personal weapon of the kidan princess Zrexx. Damaged in the fight, it no longer can dust, but the edge remains incredibly sharp."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "smhalberd0"
	base_icon_state = "smhalberd"
	force = 5
	sharp = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 15
	toolspeed = 0.25
	attack_verb = list("cleaved", "stabbed", "whacked", "slashed", "stabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	resistance_flags = FIRE_PROOF

/obj/item/kidan_princess_halberd/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SUPERMATTER_IMMUNE, ROUNDSTART_TRAIT) // so it can't be dusted by the SM
	AddComponent(/datum/component/forces_doors_open)
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.25, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (4 / 3) SECONDS, _requires_two_hands = TRUE) // 0.3333 seconds of cooldown for 75% uptime
	AddComponent(/datum/component/two_handed, force_wielded = 30, force_unwielded = force, icon_wielded = "[base_icon_state]1")

/obj/item/kidan_princess_halberd/update_icon_state()
	icon_state = "[base_icon_state]0"

#undef KIDAN_BOSS_STORAGE
