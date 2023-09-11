/*
	Changeling Mutations! ~By Miauw (ALL OF IT :V)
	Contains:
		Arm Blade
		Space Suit
		Shield
		Armor
*/

/datum/action/changeling/weapon
	name = "Organic Weapon"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at coderbus"
	chemical_cost = 1000
	power_type = CHANGELING_UNOBTAINABLE_POWER
	var/silent = FALSE
	var/weapon_type
	var/weapon_name_simple

/datum/action/changeling/weapon/try_to_sting(mob/user, mob/target)
	if(istype(user.l_hand, weapon_type) || istype(user.r_hand, weapon_type))
		retract(user, TRUE)
		return
	..(user, target)

/datum/action/changeling/weapon/sting_action(mob/user)
	SEND_SIGNAL(user, COMSIG_MOB_WEAPON_APPEARS)
	if(!user.drop_item())
		to_chat(user, "[user.get_active_hand()] is stuck to your hand, you cannot grow a [weapon_name_simple] over it!")
		return FALSE
	var/obj/item/W = new weapon_type(user, silent, src)
	user.put_in_hands(W)
	RegisterSignal(user, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(retract), override = TRUE)
	RegisterSignal(user, COMSIG_MOB_WEAPON_APPEARS, PROC_REF(retract), override = TRUE)
	return W

/datum/action/changeling/weapon/proc/retract(atom/target, any_hand = FALSE)
	SIGNAL_HANDLER
	if(!ischangeling(owner))
		return
	if(!any_hand && !istype(owner.get_active_hand(), weapon_type))
		return
	var/done = FALSE
	if(istype(owner.l_hand, weapon_type))
		qdel(owner.l_hand)
		owner.update_inv_l_hand()
		done = TRUE
	if(istype(owner.r_hand, weapon_type))
		qdel(owner.r_hand)
		owner.update_inv_r_hand()
		done = TRUE
	if(done && !silent)
		owner.visible_message("<span class='warning'>With a sickening crunch, [owner] reforms [owner.p_their()] [weapon_name_simple] into an arm!</span>", "<span class='notice'>We assimilate the [weapon_name_simple] back into our body.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

//Parent to space suits and armor.
/datum/action/changeling/suit
	name = "Organic Suit"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at coderbus"
	chemical_cost = 1000
	power_type = CHANGELING_UNOBTAINABLE_POWER
	var/helmet_type = /obj/item
	var/suit_type = /obj/item
	var/suit_name_simple = "    "
	var/helmet_name_simple = "     "
	var/recharge_slowdown = 0
	var/blood_on_castoff = 0

/datum/action/changeling/suit/try_to_sting(mob/user, mob/target)
	if(!ishuman(user))
		return FALSE

	var/mob/living/carbon/human/H = user
	if(istype(H.wear_suit, suit_type) || istype(H.head, helmet_type))
		H.visible_message("<span class='warning'>[H] casts off [H.p_their()] [suit_name_simple]!</span>", "<span class='warning'>We cast off our [suit_name_simple].</span>", "<span class='warning'>You hear the organic matter ripping and tearing!</span>")
		qdel(H.wear_suit)
		qdel(H.head)
		H.update_inv_wear_suit()
		H.update_inv_head()
		H.update_hair()
		H.update_fhair()

		if(blood_on_castoff)
			H.add_splatter_floor()
			playsound(H.loc, 'sound/effects/splat.ogg', 50, 1) //So real sounds

		cling.chem_recharge_slowdown -= recharge_slowdown
		return FALSE
	..(H, target)

/datum/action/changeling/suit/sting_action(mob/living/carbon/human/user)
	if(!user.unEquip(user.wear_suit))
		to_chat(user, "\the [user.wear_suit] is stuck to your body, you cannot grow a [suit_name_simple] over it!")
		return FALSE
	if(!user.unEquip(user.head))
		to_chat(user, "\the [user.head] is stuck on your head, you cannot grow a [helmet_name_simple] over it!")
		return FALSE

	user.unEquip(user.head)
	user.unEquip(user.wear_suit)

	user.equip_to_slot_if_possible(new suit_type(user), slot_wear_suit, TRUE, TRUE)
	user.equip_to_slot_if_possible(new helmet_type(user), slot_head, TRUE, TRUE)

	cling.chem_recharge_slowdown += recharge_slowdown
	return TRUE


//fancy headers yo
/***************************************\
|***************ARM BLADE***************|
\***************************************/
/datum/action/changeling/weapon/arm_blade
	name = "Arm Blade"
	desc = "We reform one of our arms into a deadly blade. Costs 25 chemicals."
	helptext = "We may retract our armblade in the same manner as we form it. Cannot be used while in lesser form."
	button_icon_state = "armblade"
	chemical_cost = 25
	dna_cost = 2
	req_human = TRUE
	weapon_type = /obj/item/melee/arm_blade
	weapon_name_simple = "blade"
	power_type = CHANGELING_PURCHASABLE_POWER

/obj/item/melee/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made of bone and flesh that cleaves through people like a hot knife through butter."
	icon_state = "arm_blade"
	item_state = "arm_blade"
	flags = ABSTRACT | NODROP | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	sharp = TRUE
	force = 25
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0
	var/datum/action/changeling/weapon/parent_action

/obj/item/melee/arm_blade/Initialize(mapload, silent, new_parent_action)
	. = ..()
	parent_action = new_parent_action
	ADD_TRAIT(src, TRAIT_FORCES_OPEN_DOORS_ITEM, ROUNDSTART_TRAIT)

/obj/item/melee/arm_blade/Destroy()
	if(parent_action)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WILLINGLY_DROP)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WEAPON_APPEARS)
		parent_action = null
	return ..()

/obj/item/melee/arm_blade/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/structure/table))
		var/obj/structure/table/T = target
		T.deconstruct(FALSE)
		return

	if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/C = target
		C.attack_alien(user) //muh copypasta

/***************************************\
|***********COMBAT TENTACLES*************|
\***************************************/

/datum/action/changeling/weapon/tentacle
	name = "Tentacle"
	desc = "We ready a tentacle to grab items or victims with. Costs 10 chemicals."
	helptext = "We can use it once to retrieve a distant item. If used on living creatures, the effect depends on the intent: \
	Help will drag the target closer and shake them up. \
	Disarm will grab whatever the target is holding, and knock them down if they are not holding anything. \
	Grab will immobilize the target and wrap a tentacle around them. \
	Harm will drag the target closer and hit them with the object in our other hand. \
	Cannot be used while in our lesser form."
	button_icon_state = "tentacle"
	chemical_cost = 10
	dna_cost = 2
	req_human = TRUE
	weapon_type = /obj/item/gun/magic/tentacle
	weapon_name_simple = "tentacle"
	silent = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER

/obj/item/gun/magic/tentacle
	name = "tentacle"
	desc = "A fleshy tentacle that can stretch out and grab things or people."
	icon = 'icons/obj/items.dmi'
	icon_state = "tentacle"
	item_state = "tentacle"
	flags = ABSTRACT | NODROP | NOBLUDGEON | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = /obj/item/ammo_casing/magic/tentacle
	fire_sound = 'sound/effects/splat.ogg'
	force = 0
	max_charges = 1
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0
	var/datum/action/changeling/weapon/parent_action

/obj/item/gun/magic/tentacle/Initialize(mapload, silent, new_parent_action)
	. = ..()
	parent_action = new_parent_action
	if(ismob(loc))
		if(!silent)
			loc.visible_message("<span class='warning'>[loc.name]\'s arm starts stretching inhumanly!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a tentacle.</span>", "<span class='italics'>You hear organic matter ripping and tearing!</span>")
		else
			to_chat(loc, "<span class='notice'>You prepare to extend a tentacle.</span>")

/obj/item/gun/magic/tentacle/Destroy()
	if(parent_action)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WILLINGLY_DROP)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WEAPON_APPEARS)
		parent_action = null
	return ..()

/obj/item/gun/magic/tentacle/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, "<span class='warning'>[src] is not ready yet.</span>")

/obj/item/gun/magic/tentacle/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] coils [src] tightly around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return OXYLOSS

/obj/item/ammo_casing/magic/tentacle
	name = "tentacle"
	desc = "a tentacle."
	projectile_type = /obj/item/projectile/tentacle
	caliber = "tentacle"
	icon_state = "tentacle_end"
	muzzle_flash_effect = null
	muzzle_flash_color = null
	var/obj/item/gun/magic/tentacle/gun //the item that shot it

/obj/item/ammo_casing/magic/tentacle/New(obj/item/gun/magic/tentacle/tentacle_gun)
	gun = tentacle_gun
	..()

/obj/item/ammo_casing/magic/tentacle/Destroy()
	gun = null
	return ..()

/obj/item/projectile/tentacle
	name = "tentacle"
	icon_state = "tentacle_end"
	pass_flags = PASSTABLE
	damage = 0
	damage_type = BRUTE
	range = 8
	hitsound = 'sound/weapons/thudswoosh.ogg'
	reflectability = REFLECTABILITY_NEVER //Let us not reflect this ever. It's not quite a bullet, and a cling should never wrap its tentacle around itself, it controls its body well
	var/obj/item/ammo_casing/magic/tentacle/source //the item that shot it

/obj/item/projectile/tentacle/New(obj/item/ammo_casing/magic/tentacle/tentacle_casing)
	source = tentacle_casing
	..()

/obj/item/projectile/tentacle/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "tentacle", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1)
	..()

/mob/proc/tentacle_stab(mob/living/carbon/C)
	if(Adjacent(C))
		var/obj/item/I = r_hand
		if(!I || istype(I, /obj/item/gun/magic/tentacle))
			I = l_hand
		if(!I || istype(I, /obj/item/gun/magic/tentacle))
			return
		add_attack_logs(src, C, "[src] pulled [C] with a tentacle, attacking them with [I]")
		I.melee_attack_chain(src, C)//Hits the victim with whatever they are holding that is no the zero force tentacle


/obj/item/projectile/tentacle/on_hit(atom/target, blocked = 0)
	qdel(source.gun) //one tentacle only unless you miss
	if(blocked >= 100)
		return 0
	var/mob/living/carbon/human/H = firer
	if(isitem(target))
		var/obj/item/I = target
		if(!I.anchored)
			to_chat(firer, "<span class='notice'>You grab [I] with your tentacle.</span>")
			add_attack_logs(H, I, "[src] grabs [I] with a tentacle")
			I.forceMove(H.loc)
			I.attack_hand(H)//The tentacle takes the item back with them and makes them pick it up. No silly throw mode.
			. = 1

	else if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored && !L.throwing)//avoid double hits
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				switch(firer.a_intent)
					if(INTENT_HELP)
						C.visible_message("<span class='danger'>[L] is pulled to their feet towards [H]!</span>","<span class='userdanger'>A tentacle grabs you and pulls you up towards [H]!</span>")
						add_attack_logs(H, L, "[H] pulled [L] towards them with a tentacle")
						C.throw_at(get_step_towards(H,C), 8, 2)
						C.AdjustParalysis(-2 SECONDS)
						C.AdjustStunned(-4 SECONDS)
						C.AdjustWeakened(-4 SECONDS)
						C.AdjustKnockDown(-4 SECONDS)
						C.adjustStaminaLoss(-25)
						return TRUE

					if(INTENT_DISARM)
						var/obj/item/I = C.get_active_hand()
						if(I)
							if(C.drop_item())
								C.visible_message("<span class='danger'>[I] is yanked out of [C]'s hand by [src]!</span>","<span class='userdanger'>A tentacle pulls [I] away from you!</span>")
								add_attack_logs(H, C, "[H] has grabbed [I] out of [C]'s hand with a tentacle")
								on_hit(I) //grab the item as if you had hit it directly with the tentacle
								return TRUE
							to_chat(firer, "<span class='danger'>You can't seem to pry [I] out of [C]'s hands!</span>")
							add_attack_logs(H, C, "[H] tried to grab [I] out of their hand with a tentacle, but failed")
						C.visible_message("<span class='danger'>[C] is knocked over by [src]!</span>", "<span class='userdanger'>A tentacle hits you in the chest and knocks you over!</span>")
						add_attack_logs(H, C, "[H] knocked over with a tentacle")
						C.KnockDown(2 SECONDS) //Not useless with antidrop.
						return TRUE

					if(INTENT_GRAB)
						C.visible_message("<span class='danger'>[L] is entangled by [H]'s tentacle!</span>", "<span class='userdanger'>A tentacle grabs you and wraps around your legs!</span>")
						add_attack_logs(H, C, "imobilised with a changeling tentacle")
						if(!iscarbon(H))
							return TRUE
						var/obj/item/restraints/legcuffs/beartrap/changeling/B = new(H.loc)
						B.Crossed(C)
						return TRUE

					if(INTENT_HARM)
						C.visible_message("<span class='danger'>[L] is thrown towards [H] by a tentacle!</span>","<span class='userdanger'>A tentacle grabs you and throws you towards [H]!</span>")
						C.throw_at(get_step_towards(H,C), 8, 2, callback=CALLBACK(H, TYPE_PROC_REF(/mob, tentacle_stab), C))
						return TRUE
			else
				L.visible_message("<span class='danger'>[L] is pulled by [H]'s tentacle!</span>","<span class='userdanger'>A tentacle grabs you and pulls you towards [H]!</span>")
				L.throw_at(get_step_towards(H,L), 8, 2)
				. = TRUE

/obj/item/projectile/tentacle/Destroy()
	qdel(chain)
	source = null
	return ..()

/obj/item/restraints/legcuffs/beartrap/changeling
	name = "tentacle mass"
	desc = "A disgusting mass of flesh wrapped around some poor persons legs."
	icon_state = "fleshtrap" //Never on ground, only on examine, so doesn't need to be super detaled
	trap_damage = 5
	armed = TRUE
	anchored = TRUE
	silent_arming = TRUE
	breakouttime = 5 SECONDS
	cuffed_state = "fleshlegcuff"
	flags = DROPDEL

/obj/item/restraints/legcuffs/beartrap/changeling/Crossed(AM, oldloc)
	if(!iscarbon(AM) || !armed)
		return
	var/mob/living/carbon/C = AM
	C.apply_status_effect(STATUS_EFFECT_CLINGTENTACLE)

	..()

	if(!iscarbon(loc)) // if it fails to latch onto someone for whatever reason, delete itself, we don't want unarmed ones lying around.
		qdel(src)

/***************************************\
|****************SHIELD*****************|
\***************************************/
/datum/action/changeling/weapon/shield
	name = "Organic Shield"
	desc = "We reform one of our arms into a hard shield. Costs 20 chemicals."
	helptext = "Organic tissue cannot resist damage forever. The shield will break after it is hit too much. The more DNA we collect, the stronger it is. Cannot be used while in lesser form."
	button_icon_state = "organic_shield"
	chemical_cost = 20
	dna_cost = 1
	req_human = TRUE
	weapon_type = /obj/item/shield/changeling
	weapon_name_simple = "shield"
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/weapon/shield/sting_action(mob/user)
	var/obj/item/shield/changeling/S = ..(user)
	if(!S)
		return FALSE
	S.remaining_uses = round(cling.absorbed_count * 3)
	return TRUE

/obj/item/shield/changeling
	name = "shield-like mass"
	desc = "A mass of tough, boney tissue. You can still see the fingers as a twisted pattern in the shield."
	flags = NODROP | DROPDEL
	icon_state = "ling_shield"

	var/remaining_uses //Set by the changeling ability.

/obj/item/shield/changeling/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)
	if(ismob(loc))
		loc.visible_message("<span class='warning'>The end of [loc.name]\'s hand inflates rapidly, forming a huge shield-like mass!</span>", "<span class='warning'>We inflate our hand into a strong shield.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

/obj/item/shield/changeling/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(remaining_uses < 1)
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.visible_message("<span class='warning'>With a sickening crunch, [H] reforms [H.p_their()] shield into an arm!</span>", "<span class='notice'>We assimilate our shield into our body</span>", "<span class='italics>You hear organic matter ripping and tearing!</span>")
			H.unEquip(src, 1)
		qdel(src)
		return 0
	else
		remaining_uses--
		return ..()

/***************************************\
|*********SPACE SUIT + HELMET***********|
\***************************************/
/datum/action/changeling/suit/organic_space_suit
	name = "Organic Space Suit"
	desc = "We grow an organic suit to protect ourselves from space exposure. Costs 20 chemicals."
	helptext = "We must constantly repair our form to make it space proof, reducing chemical production while we are protected. Cannot be used in lesser form."
	button_icon_state = "organic_suit"
	chemical_cost = 20
	dna_cost = 2
	req_human = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER
	suit_type = /obj/item/clothing/suit/space/changeling
	helmet_type = /obj/item/clothing/head/helmet/space/changeling
	suit_name_simple = "flesh shell"
	helmet_name_simple = "space helmet"
	recharge_slowdown = 0.5
	blood_on_castoff = 1

/obj/item/clothing/suit/space/changeling
	name = "flesh mass"
	icon_state = "lingspacesuit"
	desc = "A huge, bulky mass of pressure and temperature-resistant organic tissue, evolved to facilitate space travel."
	flags = STOPSPRESSUREDMAGE | NODROP | DROPDEL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 90, ACID = 90) //No armor at all

/obj/item/clothing/suit/space/changeling/Initialize(mapload)
	. = ..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>[loc.name]\'s flesh rapidly inflates, forming a bloated mass around [loc.p_their()] body!</span>", "<span class='warning'>We inflate our flesh, creating a spaceproof suit!</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/changeling/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.reagents.add_reagent("perfluorodecalin", 0.2)

/obj/item/clothing/head/helmet/space/changeling
	name = "flesh mass"
	icon_state = "lingspacehelmet"
	desc = "A covering of pressure and temperature-resistant organic tissue with a glass-like chitin front."
	flags = BLOCKHAIR | STOPSPRESSUREDMAGE | NODROP | DROPDEL
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 90, ACID = 90)


/***************************************\
|*****************ARMOR*****************|
\***************************************/
/datum/action/changeling/suit/armor
	name = "Chitinous Armor"
	desc = "We turn our skin into tough chitin to protect us from damage. Costs 25 chemicals."
	helptext = "Upkeep of the armor requires a low expenditure of chemicals. The armor is strong against brute force, but does not provide much protection from lasers. Cannot be used in lesser form."
	button_icon_state = "chitinous_armor"
	chemical_cost = 25
	dna_cost = 2
	req_human = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER
	suit_type = /obj/item/clothing/suit/armor/changeling
	helmet_type = /obj/item/clothing/head/helmet/changeling
	suit_name_simple = "armor"
	helmet_name_simple = "helmet"
	recharge_slowdown = 0.25

/obj/item/clothing/suit/armor/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin."
	icon_state = "lingarmor"
	flags = NODROP | DROPDEL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 20, BOMB = 10, RAD = 0, FIRE = 90, ACID = 90)
	flags_inv = HIDEJUMPSUIT
	cold_protection = 0
	heat_protection = 0
	sprite_sheets = null

/obj/item/clothing/suit/armor/changeling/Initialize(mapload)
	. = ..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>[loc.name]\'s flesh turns black, quickly transforming into a hard, chitinous mass!</span>", "<span class='warning'>We harden our flesh, creating a suit of armor!</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

/obj/item/clothing/suit/armor/changeling/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage)
	. = ..()

	if(!IS_HORIZONTAL(owner))
		return

	var/obj/item/I = hitby

	if(!isliving(I.loc))
		// Maybe it's on the ground? Maybe it's being used telekinetically? IDK
		return

	// The user who's wielding the tool
	var/mob/living/user = I.loc

	// snowflake checks my beloved
	// this will become tooltype checks I swear
	if(!istype(I, /obj/item/circular_saw) && !istype(I, /obj/item/chainsaw) && !istype(I, /obj/item/butcher_chainsaw))
		return

	user.visible_message(
		"<span class='notice'>[user] starts to saw through [owner]'s [name].</span>",
		"<span class='notice'>You start to saw through [owner]'s [name].</span>",
		"<span class='notice'>You hear a loud grinding noise.</span>"
	)

	if(!do_after(user, 15 SECONDS, target = owner))
		user.visible_message(
			"<span class='warning'>[user] fails to cut through [owner]'s [name].</span>",
			"<span class='warning'>You fail to cut through [owner]'s [name].</span>",
			"<span class='notice'>You hear the grinding stop.</span>"
		)
		return FALSE

	// check again after the do_after to make sure they haven't gotten up
	if(!IS_HORIZONTAL(owner))
		return FALSE

	user.visible_message(
		"<span class='warning'>\The [name] turns to shreds as [user] cleaves through it!</span>",
		"<span class='warning'>\The [name] turns to shreds as you cleave through it!</span>",
		"<span class='notice'>You hear something fall as the grinding ends.</span>"
	)

	playsound(I, I.hitsound, 50)
	// you've torn it up, get rid of it.
	new /obj/effect/decal/cleanable/shreds(owner.loc)
	// just unequip them since they qdel on drop
	owner.unEquip(src, TRUE, TRUE)
	if(istype(owner.head, /obj/item/clothing/head/helmet/changeling))
		owner.unEquip(owner.head, TRUE, TRUE)

	return TRUE

/obj/item/clothing/head/helmet/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin with transparent chitin in front."
	icon_state = "lingarmorhelmet"
	flags = BLOCKHAIR | NODROP | DROPDEL
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 20, BOMB = 10, RAD = 0, FIRE = 90, ACID = 90)
	flags_inv = HIDEEARS
