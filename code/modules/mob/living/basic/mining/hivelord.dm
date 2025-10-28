/mob/living/basic/mining/hivelord
	name = "hivelord"
	desc = "A levitating swarm of tiny creatures which act as a single individual. When threatened or hunting they rapidly replicate additional short-lived bodies."
	icon_state = "Hivelord"
	icon_living = "Hivelord"
	icon_aggro = "Hivelord_alert"
	icon_dead = "Hivelord_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	speed = 3
	maxHealth = 75
	health = 75
	harm_intent_damage = 5
	attack_verb_continuous = "lashes out at"
	attack_verb_simple = "lash out at"
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_blocked_message = "falls right through the strange body of the"
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	pass_flags = PASSTABLE
	butcher_results = list(/obj/item/organ/internal/regenerative_core = 1)
	ai_controller = /datum/ai_controller/basic_controller/hivelord
	var/brood_type = /mob/living/basic/mining/hivelordbrood
	contains_xeno_organ = TRUE
	surgery_container = /datum/xenobiology_surgery_container/hivelord

/mob/living/basic/mining/hivelord/spawn_crusher_loot()
	loot += crusher_loot // we don't butcher

/mob/living/basic/mining/hivelord/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	mouse_opacity = MOUSE_OPACITY_ICON

/mob/living/basic/mining/hivelord/space
	brood_type = /mob/living/basic/mining/hivelordbrood/space

/mob/living/basic/mining/hivelord/space/Process_Spacemove(movement_dir, continuous_move)
	return TRUE

// A fragile but rapidly produced creature
/mob/living/basic/mining/hivelordbrood
	name = "hivelord brood"
	desc = "A fragment of the original Hivelord, rallying behind its original. One isn't much of a threat, but..."
	icon_state = "Hivelordbrood"
	icon_living = "Hivelordbrood"
	icon_aggro = "Hivelordbrood"
	icon_dead = "Hivelordbrood"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	friendly_verb_continuous = "buzzes near"
	friendly_verb_simple = "buzz near"
	speed = -1
	maxHealth = 1
	health = 1
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_blocked_message = "falls right through the strange body of the"
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/hivelord_brood
	initial_traits = list(TRAIT_FLYING)
	///Are we an advanced legion skull used in hardmode legion? Ignore the attack rules.
	var/advanced_legion = FALSE

/mob/living/basic/mining/hivelordbrood/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(death)), 100)
	AddComponent(/datum/component/swarming)

/mob/living/basic/mining/hivelordbrood/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(target))
		return TRUE
	var/mob/living/living_target = target
	var/can_continue = FALSE
	var/datum/status_effect/hivelord_tracking/tracker = living_target.has_status_effect(STATUS_EFFECT_HIVELORD_TRACKING)
	if(tracker && advanced_legion)
		tracker.refresh()
		if(!(src.UID() in tracker.list_of_uids)) // Add in the UID so non advanced legion skulls in the fight are harder too.
			tracker.list_of_uids += UID()
		return TRUE
	if(tracker)
		tracker.refresh()
		if((UID() in tracker.list_of_uids) || length(tracker.list_of_uids) >= 3 || advanced_legion)
			can_continue = TRUE
	if(!tracker)
		tracker = living_target.apply_status_effect(STATUS_EFFECT_HIVELORD_TRACKING)
	if(!can_continue && !advanced_legion)
		tracker.list_of_uids += src.UID()
		return FALSE
	else
		return TRUE

/mob/living/basic/mining/hivelordbrood/space

/mob/living/basic/mining/hivelordbrood/space/Process_Spacemove(movement_dir, continuous_move)
	return TRUE

/mob/living/basic/mining/hivelordbrood/blood
	name = "blood brood"
	desc = "A living string of blood and alien materials."
	icon_state = "bloodbrood"
	icon_living = "bloodbrood"
	icon_aggro = "bloodbrood"
	attack_verb_continuous = "pierces"
	attack_verb_simple = "pierce"
	color = "#C80000"

/mob/living/basic/mining/hivelordbrood/blood/death()
	if(can_die() && loc)
		// Splash the turf we are on with blood
		reagents.reaction(get_turf(src))
	return ..()

/mob/living/basic/mining/hivelordbrood/blood/Initialize(mapload)
	. = ..()
	create_reagents(30)

/mob/living/basic/mining/hivelordbrood/blood/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	..()
	if(iscarbon(target))
		transfer_reagents(target, 1)

/mob/living/basic/mining/hivelordbrood/blood/attack_hand(mob/living/carbon/human/M)
	if("\ref[M]" in faction)
		reabsorb_host(M)
	else
		return ..()

/mob/living/basic/mining/hivelordbrood/blood/attack_alien(mob/living/carbon/alien/humanoid/M)
	if("\ref[M]" in faction)
		reabsorb_host(M)
	else
		return ..()

/mob/living/basic/mining/hivelordbrood/blood/proc/reabsorb_host(mob/living/carbon/C)
	C.visible_message("<span class='notice'>[src] is reabsorbed by [C]'s body.</span>", \
								"<span class='notice'>[src] is reabsorbed by your body.</span>")
	transfer_reagents(C)
	death()

/mob/living/basic/mining/hivelordbrood/blood/proc/transfer_reagents(mob/living/carbon/C, volume = 30)
	if(!reagents.total_volume)
		return

	volume = min(volume, reagents.total_volume)

	var/fraction = min(volume/reagents.total_volume, 1)
	reagents.reaction(C, REAGENT_INGEST, fraction)
	reagents.trans_to(C, volume)

/mob/living/basic/mining/hivelordbrood/blood/proc/link_host(mob/living/carbon/C)
	faction = list("\ref[src]", "\ref[C]") // Hostile to everyone except the host.
	C.transfer_blood_to(src, 30)
	color = mix_color_from_reagents(reagents.reagent_list)

// Legion
/mob/living/basic/mining/hivelord/legion
	name = "legion"
	desc = "You can still see what was once a person under the shifting mass of corruption."
	icon_state = "legion"
	icon_living = "legion"
	icon_aggro = "legion"
	icon_dead = "legion"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	mouse_opacity = MOUSE_OPACITY_ICON
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	speak_emote = list("echoes")
	throw_blocked_message = "bounces harmlessly off of"
	crusher_loot = /obj/item/crusher_trophy/legion_skull
	loot = list(/obj/item/organ/internal/regenerative_core/legion)
	butcher_results = null
	brood_type = /mob/living/basic/mining/hivelordbrood/legion
	ai_controller = /datum/ai_controller/basic_controller/hivelord/legion
	basic_mob_flags = DEL_ON_DEATH
	var/dwarf_mob = FALSE
	var/mob/living/carbon/human/stored_mob

/mob/living/basic/mining/hivelord/legion/Initialize(mapload)
	. = ..()
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])

/mob/living/basic/mining/hivelord/legion/dwarf
	name = "dwarf legion"
	desc = "You can still see what was once a dwarf under the shifting mass of corruption."
	icon_state = "dwarf_legion"
	icon_living = "dwarf_legion"
	icon_aggro = "dwarf_legion"
	icon_dead = "dwarf_legion"
	maxHealth = 60
	health = 60
	speed = 2 // faster!
	crusher_drop_mod = 20
	dwarf_mob = TRUE

/mob/living/basic/mining/hivelord/legion/death(gibbed)
	visible_message("<span class='warning'>The skulls on [src] wail in anger as they flee from their dying host!</span>")
	var/turf/T = get_turf(src)
	if(T)
		if(stored_mob)
			stored_mob.forceMove(get_turf(src))
			stored_mob = null
		else if(HAS_TRAIT(src, TRAIT_FROM_TENDRIL))
			new /obj/effect/mob_spawn/human/corpse/charredskeleton(T)
		else if(dwarf_mob)
			new /obj/effect/mob_spawn/human/corpse/damaged/legioninfested/dwarf(T)
		else
			new /obj/effect/mob_spawn/human/corpse/damaged/legioninfested(T)
	..(gibbed)

// Legion skull
/mob/living/basic/mining/hivelordbrood/legion
	name = "legion"
	desc = "One of many."
	icon_state = "legion_head"
	icon_living = "legion_head"
	icon_aggro = "legion_head"
	icon_dead = "legion_head"
	maxHealth = 5
	health = 5
	melee_damage_lower = 12
	melee_damage_upper = 12
	attack_verb_continuous = "bites"
	attack_verb_simple = "bites"
	speak_emote = list("echoes")
	throw_blocked_message = "is shrugged off by"
	var/can_infest_dead = FALSE

/mob/living/basic/mining/hivelordbrood/legion/melee_attack(mob/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!ishuman(target))
		return
	if((target.stat == DEAD && can_infest_dead) || target.stat == UNCONSCIOUS)
		infest(target)

/mob/living/basic/mining/hivelordbrood/legion/proc/infest(mob/living/carbon/human/H)
	if(H?.dna?.species && !H.dna.species.can_be_legion_infested())
		return
	visible_message("<span class='warning'>[name] burrows into the flesh of [H]!</span>")
	var/mob/living/basic/mining/hivelord/legion/L
	if(HAS_TRAIT(H, TRAIT_DWARF)) // dwarf legions aren't just fluff!
		L = new /mob/living/basic/mining/hivelord/legion/dwarf(H.loc)
	else
		L = new(H.loc)
	visible_message("<span class='warning'>[L] staggers to [L.p_their()] feet!</span>")
	H.death()
	H.adjustBruteLoss(1000)
	L.stored_mob = H
	H.forceMove(L)
	ai_controller?.set_blackboard_key(BB_LEGION_CORPSE, H)
	qdel(src)

// Advanced Legion is slightly tougher to kill and can raise corpses (revive other legions)
/mob/living/basic/mining/hivelord/legion/advanced
	maxHealth = 120
	health = 120
	ai_controller = /datum/ai_controller/basic_controller/hivelord/legion/advanced
	brood_type = /mob/living/basic/mining/hivelordbrood/legion/advanced
	icon_state = "dwarf_legion"
	icon_living = "dwarf_legion"
	icon_aggro = "dwarf_legion"
	icon_dead = "dwarf_legion"

/mob/living/basic/mining/hivelordbrood/legion/advanced
	ai_controller = /datum/ai_controller/basic_controller/hivelord_brood/advanced_legion
	can_infest_dead = TRUE
	advanced_legion = TRUE

// Big legion (billy)
/mob/living/basic/mining/big_legion
	name = "big legion"
	desc = "This monstrosity has clearly been corrupting for centuries, and is looking for a fight. Rumours claim it is capable of throwing the strongest of miners and his name is Billy."
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "legion"
	icon_living = "legion"
	icon_dead = "legion-dead"
	health = 350
	maxHealth = 350
	melee_damage_lower = 30
	melee_damage_upper = 30
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	sentience_type = SENTIENCE_BOSS
	attack_sound = 'sound/misc/demon_attack1.ogg'
	speed = 0
	butcher_results = list(/obj/item/regen_mesh)
	ai_controller = /datum/ai_controller/basic_controller/big_legion

/mob/living/basic/mining/big_legion/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(!isliving(target))
		return ..()
	var/mob/living/L = target
	var/datum/status_effect/stacking/ground_pound/G = L.has_status_effect(STATUS_EFFECT_GROUNDPOUND)
	if(!G)
		L.apply_status_effect(STATUS_EFFECT_GROUNDPOUND, 1, src)
		return ..()
	if(G.add_stacks(stacks_added = 1, attacker = src))
		return ..()

/mob/living/basic/mining/big_legion/proc/throw_mobs()
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)
	for(var/mob/living/L in range(3, src))
		if(faction_check(faction, L.faction, FALSE))
			continue

		L.visible_message("<span class='danger'>[L] was thrown by [src]!</span>",
		"<span class='userdanger'>You feel a strong force throwing you!</span>",
		"<span class='danger'>You hear a thud.</span>")
		var/atom/throw_target = get_edge_target_turf(L, get_dir(src, get_step_away(L, src)))
		L.throw_at(throw_target, 4, 4)
		var/limb_to_hit = L.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
		var/armor = L.run_armor_check(def_zone = limb_to_hit, armor_type = MELEE, armor_penetration_percentage = 50)
		L.apply_damage(40, BRUTE, limb_to_hit, armor)

// Tendril-spawned Legion remains, the charred skeletons of those whose bodies sank into laval or fell into chasms.
/obj/effect/mob_spawn/human/corpse/charredskeleton
	name = "charred skeletal remains"
	burn_damage = 1000
	mob_name = "ashen skeleton"
	mob_gender = NEUTER
	husk = FALSE
	mob_species = /datum/species/skeleton/brittle
	mob_color = "#454545"

// Legion infested mobs

/obj/effect/mob_spawn/human/corpse/damaged/legioninfested/dwarf/equip(mob/living/carbon/human/H)
	. = ..()
	H.dna.SetSEState(GLOB.smallsizeblock, TRUE, TRUE)
	singlemutcheck(H, GLOB.smallsizeblock, MUTCHK_FORCED)
	H.update_mutations()

/obj/effect/mob_spawn/human/corpse/damaged/legioninfested/Initialize(mapload)
	var/type = pickweight(list("Miner" = 66, "Ashwalker" = 10, "Golem" = 10,"Clown" = 10, pick("Shadow", "YeOlde", "Cultist") = 4))
	switch(type)
		if("Miner")
			mob_species = pickweight(list(/datum/species/human = 72, /datum/species/unathi = 28))
			uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
			if(prob(4))
				belt = pickweight(list(/obj/item/storage/belt/mining = 2, /obj/item/storage/belt/mining/alt = 2))
			else if(prob(10))
				belt = pickweight(list(/obj/item/pickaxe = 8, /obj/item/pickaxe/mini = 4, /obj/item/pickaxe/silver = 2, /obj/item/pickaxe/diamond = 1))
			else
				belt = /obj/item/tank/internals/emergency_oxygen/engi
			if(mob_species != /datum/species/unathi)
				shoes = /obj/item/clothing/shoes/workboots/mining
			gloves = /obj/item/clothing/gloves/color/black
			mask = /obj/item/clothing/mask/gas/explorer
			if(prob(20))
				suit = pickweight(list(/obj/item/clothing/suit/hooded/explorer = 18, /obj/item/clothing/suit/hooded/goliath = 2))
			if(prob(30))
				r_pocket = pickweight(list(/obj/item/stack/marker_beacon = 20, /obj/item/stack/spacecash/c200 = 7, /obj/item/reagent_containers/hypospray/autoinjector/survival = 2, /obj/item/borg/upgrade/modkit/damage = 1 ))
			if(prob(10))
				l_pocket = pickweight(list(/obj/item/stack/spacecash/c200 = 7, /obj/item/reagent_containers/hypospray/autoinjector/survival = 2, /obj/item/borg/upgrade/modkit/cooldown = 1 ))
		if("Ashwalker")
			mob_species = /datum/species/unathi/ashwalker
			uniform = /obj/item/clothing/under/costume/gladiator/ash_walker
			if(prob(95))
				head = /obj/item/clothing/head/helmet/gladiator
			else
				head = /obj/item/clothing/head/helmet/skull
				suit = /obj/item/clothing/suit/armor/bone
				gloves = /obj/item/clothing/gloves/bracer
			if(prob(5))
				back = pickweight(list(/obj/item/spear/bonespear = 3, /obj/item/fireaxe/boneaxe = 2))
			if(prob(10))
				belt = /obj/item/storage/belt/mining/primitive
			if(prob(30))
				r_pocket = /obj/item/kitchen/knife/combat/survival/bone
			if(prob(30))
				l_pocket = /obj/item/kitchen/knife/combat/survival/bone
		if("Clown")
			name = pick(GLOB.clown_names)
			outfit = /datum/outfit/job/clown
			belt = null
			backpack_contents = list()
			if(prob(70))
				backpack_contents += pick(/obj/item/stamp/clown, /obj/item/reagent_containers/spray/waterflower, /obj/item/food/grown/banana, /obj/item/megaphone)
			if(prob(30))
				backpack_contents += list(/obj/item/stack/sheet/mineral/bananium = pickweight(list(1 = 3, 2 = 2, 3 = 1)))
			if(prob(10))
				l_pocket = pickweight(list(/obj/item/bikehorn/golden = 3, /obj/item/bikehorn/airhorn= 1 ))
			if(prob(10))
				r_pocket = /obj/item/bio_chip_implanter/sad_trombone
		if("Golem")
			mob_species = pick(/datum/species/golem/adamantine, /datum/species/golem/plasma, /datum/species/golem/diamond, /datum/species/golem/gold, /datum/species/golem/silver, /datum/species/golem/plasteel, /datum/species/golem/titanium, /datum/species/golem/plastitanium)
			if(prob(30))
				glasses = pickweight(list(/obj/item/clothing/glasses/meson = 2, /obj/item/clothing/glasses/hud/health = 2, /obj/item/clothing/glasses/hud/diagnostic =2, /obj/item/clothing/glasses/science = 2, /obj/item/clothing/glasses/welding = 2, /obj/item/clothing/glasses/night = 1))
			if(prob(10))
				belt = pick(/obj/item/storage/belt/mining/vendor, /obj/item/storage/belt/utility/full)
			if(prob(50))
				neck = /obj/item/bedsheet/rd/royal_cape
			if(prob(10))
				l_pocket = pick(/obj/item/crowbar/power, /obj/item/wrench/power, /obj/item/weldingtool/experimental)
		if("YeOlde")
			mob_gender = FEMALE
			uniform = /obj/item/clothing/under/costume/maid
			gloves = /obj/item/clothing/gloves/color/white
			shoes = /obj/item/clothing/shoes/laceup
			head = /obj/item/clothing/head/helmet/riot/knight
			suit = /obj/item/clothing/suit/armor/riot/knight
			back = /obj/item/shield/riot/buckler
			belt = /obj/item/nullrod/claymore
			r_pocket = /obj/item/tank/internals/emergency_oxygen
			mask = /obj/item/clothing/mask/breath
		if("Shadow")
			mob_species = /datum/species/shadow
			uniform = /obj/item/clothing/under/color/black
			shoes = /obj/item/clothing/shoes/black
			suit = /obj/item/clothing/suit/storage/labcoat
			glasses = /obj/item/clothing/glasses/sunglasses/blindfold
			back = /obj/item/tank/internals/oxygen
			mask = /obj/item/clothing/mask/breath
		if("Cultist")
			uniform = /obj/item/clothing/under/color/black
			back = /obj/item/storage/backpack/cultpack
			suit = /obj/item/clothing/suit/hooded/cultrobes/alt
			if(prob(40))
				suit_store = /obj/item/melee/cultblade
			l_pocket = /obj/item/melee/cultblade/dagger
			if(prob(60))
				r_pocket = /obj/item/reagent_containers/drinks/bottle/unholywater
			backpack_contents = list(/obj/item/tome = 1, /obj/item/restraints/legcuffs/bola/cult = 1, /obj/item/stack/sheet/runed_metal = 15)
	. = ..()
