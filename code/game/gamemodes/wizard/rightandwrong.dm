//In this file: Summon Magic/Summon Guns/Summon Events

// 1 in 50 chance of getting something really special.
#define SPECIALIST_MAGIC_PROB 2

GLOBAL_LIST_INIT(summoned_guns, list(
	/obj/item/gun/energy/disabler,
	/obj/item/gun/energy/gun,
	/obj/item/gun/energy/gun/advtaser,
	/obj/item/gun/energy/laser,
	/obj/item/gun/projectile/revolver,
	/obj/item/gun/projectile/revolver/detective,
	/obj/item/gun/projectile/automatic/pistol/deagle/camo,
	/obj/item/gun/projectile/automatic/gyropistol,
	/obj/item/gun/energy/pulse,
	/obj/item/gun/projectile/automatic/pistol,
	/obj/item/gun/projectile/revolver/doublebarrel,
	/obj/item/gun/projectile/shotgun,
	/obj/item/gun/projectile/shotgun/automatic/combat,
	/obj/item/gun/projectile/automatic/ar,
	/obj/item/gun/projectile/revolver/mateba,
	/obj/item/gun/projectile/shotgun/boltaction,
	/obj/item/gun/projectile/automatic/mini_uzi,
	/obj/item/gun/energy/lasercannon,
	/obj/item/gun/energy/kinetic_accelerator/crossbow/large,
	/obj/item/gun/energy/gun/nuclear,
	/obj/item/gun/projectile/automatic/proto,
	/obj/item/gun/projectile/automatic/c20r,
	/obj/item/gun/projectile/automatic/l6_saw,
	/obj/item/gun/projectile/automatic/m90,
	/obj/item/gun/energy/alien,
	/obj/item/gun/energy/gun/turret,
	/obj/item/gun/energy/pulse/carbine,
	/obj/item/gun/energy/decloner,
	/obj/item/gun/energy/mindflayer,
	/obj/item/gun/energy/kinetic_accelerator,
	/obj/item/gun/energy/plasmacutter/adv,
	/obj/item/gun/energy/wormhole_projector,
	/obj/item/gun/projectile/automatic/wt550,
	/obj/item/gun/projectile/automatic/shotgun/bulldog,
	/obj/item/gun/projectile/revolver/grenadelauncher,
	/obj/item/gun/projectile/revolver/golden,
	/obj/item/gun/projectile/automatic/sniper_rifle,
	/obj/item/gun/medbeam,
	/obj/item/gun/energy/laser/scatter))

//if you add anything that isn't covered by the typepaths below, add it to summon_magic_objective_types
GLOBAL_LIST_INIT(summoned_magic, list(
	/obj/item/spellbook/oneuse/fireball,
	/obj/item/spellbook/oneuse/smoke,
	/obj/item/spellbook/oneuse/blind,
	/obj/item/spellbook/oneuse/mindswap,
	/obj/item/spellbook/oneuse/forcewall,
	/obj/item/spellbook/oneuse/knock,
	/obj/item/spellbook/oneuse/horsemask,
	/obj/item/spellbook/oneuse/charge,
	/obj/item/spellbook/oneuse/summonitem,
	/obj/item/gun/magic/wand,
	/obj/item/gun/magic/wand/death,
	/obj/item/gun/magic/wand/resurrection,
	/obj/item/gun/magic/wand/polymorph,
	/obj/item/gun/magic/wand/teleport,
	/obj/item/gun/magic/wand/door,
	/obj/item/gun/magic/wand/fireball,
	/obj/item/gun/magic/staff/healing,
	/obj/item/gun/magic/staff/door,
	/obj/item/scrying,
	/obj/item/voodoo,
	/obj/item/clothing/suit/space/hardsuit/shielded/wizard,
	/obj/item/immortality_talisman,
	/obj/item/melee/ghost_sword))

GLOBAL_LIST_INIT(summoned_special_magic, list(
	/obj/item/gun/magic/staff/change,
	/obj/item/gun/magic/staff/animate,
	/obj/item/storage/belt/wands/full,
	/obj/item/contract,
	/obj/item/gun/magic/staff/chaos,
	/obj/item/necromantic_stone,
	/obj/item/blood_contract))

//everything above except for single use spellbooks, because they are counted separately (and are for basic bitches anyways)
GLOBAL_LIST_INIT(summoned_magic_objectives, list(
	/obj/item/contract,
	/obj/item/blood_contract,
	/obj/item/clothing/suit/space/hardsuit/shielded/wizard,
	/obj/item/gun/magic,
	/obj/item/immortality_talisman,
	/obj/item/melee/ghost_sword,
	/obj/item/necromantic_stone,
	/obj/item/scrying,
	/obj/item/spellbook,
	/obj/item/storage/belt/wands/full,
	/obj/item/voodoo))

// If true, it's the probability of triggering "survivor" antag.
GLOBAL_VAR_INIT(summon_guns_triggered, FALSE)
GLOBAL_VAR_INIT(summon_magic_triggered, FALSE)

/proc/give_guns(mob/living/carbon/human/H)
	if(H.stat == DEAD || !(H.client))
		return
	if(H.mind)
		if(iswizard(H))
			return

	if(prob(GLOB.summon_guns_triggered) && !(H.mind in SSticker.mode.traitors))
		SSticker.mode.traitors += H.mind

		H.mind.add_antag_datum(/datum/antagonist/survivalist/guns)
		H.create_attack_log("<font color='red'>was made into a survivalist, and trusts no one!</font>")

	var/gun_type = pick(GLOB.summoned_guns)
	var/obj/item/gun/G = new gun_type(get_turf(H))
	playsound(get_turf(H),'sound/magic/summon_guns.ogg', 50, TRUE)

	var/in_hand = H.put_in_hands(G) // not always successful

	to_chat(H, "<span class='warning'>\A [G] appears [in_hand ? "in your hand" : "at your feet"]!</span>")

/proc/give_magic(mob/living/carbon/human/H)
	if(H.stat == DEAD || !(H.client))
		return
	if(H.mind)
		if(iswizard(H))
			return

	if(prob(GLOB.summon_magic_triggered) && !(H.mind in SSticker.mode.traitors))
		SSticker.mode.traitors += H.mind

		H.mind.add_antag_datum(/datum/antagonist/survivalist/magic)
		H.create_attack_log("<font color='red'>was made into a survivalist, and trusts no one!</font>")

	var/magic_type = pick(GLOB.summoned_magic)
	var/lucky = FALSE
	if(prob(SPECIALIST_MAGIC_PROB))
		magic_type = pick(GLOB.summoned_special_magic)
		lucky = TRUE

	var/obj/item/M = new magic_type(get_turf(H))
	playsound(get_turf(H),'sound/magic/summon_magic.ogg', 50, TRUE)

	var/in_hand = H.put_in_hands(M)

	to_chat(H, "<span class='warning'>\A [M] appears [in_hand ? "in your hand" : "at your feet"]!</span>")
	if(lucky)
		to_chat(H, "<span class='notice'>You feel incredibly lucky.</span>")

/proc/rightandwrong(summon_type, mob/user, survivor_probability)
	if(user) //in this case either someone holding a spellbook or a badmin
		to_chat(user, "<span class='warning'>You summoned [summon_type]!</span>")
		message_admins("[ADMIN_LOOKUPFLW(user)] summoned [summon_type]!")
		log_game("[key_name(user)] summoned [summon_type]!")

	if(summon_type == SUMMON_MAGIC)
		GLOB.summon_magic_triggered = survivor_probability
	else if(summon_type == SUMMON_GUNS)
		GLOB.summon_guns_triggered = survivor_probability
	else
		CRASH("Bad summon_type given: [summon_type]")

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		var/turf/T = get_turf(H)
		if(T && is_away_level(T.z))
			continue
		if(summon_type == SUMMON_MAGIC)
			give_magic(H)
		else
			give_guns(H)