/*
	Changeling Mutations! ~By Miauw (ALL OF IT :V)
	Contains:
		Arm Blade
		Space Suit
		Shield
		Armor
*/

//Parent to shields and blades because muh copypasted code.
/datum/action/changeling/weapon
	name = "Organic Weapon"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at coderbus"
	power_type = CHANGELING_UNOBTAINABLE_POWER
	chemical_cost = 1000
	genetic_damage = 1000
	req_human = TRUE
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
	if(!user.can_unEquip(user.get_active_hand(), silent = TRUE))
		to_chat(user, "[user.get_active_hand()] is stuck to your hand, you cannot grow a [weapon_name_simple] over it!")
		return FALSE

	var/obj/item/weapon = new weapon_type(user, silent, src)
	user.put_in_hands(weapon)

	RegisterSignal(user, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(retract), override = TRUE)
	RegisterSignal(user, COMSIG_MOB_WEAPON_APPEARS, PROC_REF(retract), override = TRUE)

	return weapon


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

	if(istype(owner.l_hand, weapon_type))
		var/obj/item/hand_item = owner.l_hand
		owner.temporarily_remove_item_from_inventory(hand_item, force = TRUE)
		qdel(hand_item)
		done = TRUE

	if(istype(owner.r_hand, weapon_type))
		var/obj/item/hand_item = owner.r_hand
		owner.temporarily_remove_item_from_inventory(hand_item, force = TRUE)
		qdel(hand_item)
		done = TRUE

	if(done && !silent)
		owner.visible_message(span_warning("With a sickening crunch, [owner] reforms [owner.p_their()] [weapon_name_simple] into an arm!"), span_notice("We assimilate the [weapon_name_simple] back into our body."), span_warning("You hear organic matter ripping and tearing!"))


//Parent to space suits and armor.
/datum/action/changeling/suit
	name = "Organic Suit"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at coderbus"
	power_type = CHANGELING_UNOBTAINABLE_POWER
	chemical_cost = 1000
	req_human = TRUE
	var/helmet_type = /obj/item
	var/suit_type = /obj/item
	var/suit_name_simple = "    "
	var/helmet_name_simple = "     "
	var/recharge_slowdown = 0
	var/blood_on_castoff = FALSE


/datum/action/changeling/suit/try_to_sting(mob/living/carbon/human/user, mob/target)
	if(!istype(user))
		return FALSE

	if(istype(user.wear_suit, suit_type) || istype(user.head, helmet_type))
		user.visible_message(span_warning("[user] casts off [user.p_their()] [suit_name_simple]!"), span_warning("We cast off our [suit_name_simple][genetic_damage > 0 ? ", temporarily weakening our genomes." : "."]"), span_warning("You hear the organic matter ripping and tearing!"))
		qdel(user.wear_suit)
		qdel(user.head)
		user.update_inv_wear_suit()
		user.update_inv_head()
		user.update_hair()
		user.update_fhair()

		if(blood_on_castoff)
			user.add_splatter_floor()
			playsound(user.loc, 'sound/effects/splat.ogg', 50, TRUE) //So real sounds

		cling.chem_recharge_slowdown -= recharge_slowdown
		return FALSE
	..(user, target)


/datum/action/changeling/suit/sting_action(var/mob/living/carbon/human/user)
	if(!user.can_unEquip(user.wear_suit))
		to_chat(user, "\the [user.wear_suit] is stuck to your body, you cannot grow a [suit_name_simple] over it!")
		return FALSE

	if(!user.can_unEquip(user.head))
		to_chat(user, "\the [user.head] is stuck on your head, you cannot grow a [helmet_name_simple] over it!")
		return FALSE

	user.drop_item_ground(user.head)
	user.drop_item_ground(user.wear_suit)

	user.equip_to_slot_or_del(new suit_type(user), slot_wear_suit)
	user.equip_to_slot_or_del(new helmet_type(user), slot_head)

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
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 3
	chemical_cost = 25
	genetic_damage = 10
	max_genetic_damage = 20
	weapon_type = /obj/item/melee/arm_blade
	weapon_name_simple = "blade"


/obj/item/melee/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter"
	icon_state = "arm_blade"
	item_state = "arm_blade"
	flags = ABSTRACT | NODROP | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	sharp = TRUE
	force = 25
	armour_penetration = 20
	block_chance = 50
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0
	gender = FEMALE
	ru_names = list(NOMINATIVE = "рука-клинок", GENITIVE = "руки-клинка", DATIVE = "руке-клинку", ACCUSATIVE = "руку-клинок", INSTRUMENTAL = "рукой-клинком", PREPOSITIONAL = "руке-клинке")
	var/datum/action/changeling/weapon/parent_action


/obj/item/melee/arm_blade/Initialize(mapload, silent, new_parent_action)
	. = ..()
	parent_action = new_parent_action


/obj/item/melee/arm_blade/Destroy()
	if(parent_action)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WEAPON_APPEARS)
		parent_action = null
	return ..()


/obj/item/melee/arm_blade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //only blocks melee
	return ..()


/obj/item/melee/arm_blade/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(istype(target, /obj/structure/table))
		var/obj/structure/table/table = target
		table.deconstruct(FALSE)

	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/computer = target
		if(computer.attack_generic(user, 60, BRUTE, "melee", 0))
			playsound(loc, 'sound/weapons/slash.ogg', 100, TRUE)

	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target

		if(!airlock.requiresID() || airlock.allowed(user)) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message.
			return

		if(airlock.locked)
			to_chat(user, span_notice("The airlock's bolts prevent it from being forced."))
			return

		if(airlock.arePowerSystemsOn())
			user.visible_message(span_warning("[user] jams [src] into the airlock and starts prying it open!"), \
								span_warning("We start forcing the airlock open."), \
								span_italics("You hear a metal screeching sound."))

			playsound(airlock, 'sound/machines/airlock_alien_prying.ogg', 150, TRUE)
			if(!do_after(user, 3 SECONDS, target = airlock ))
				return

		//user.say("Heeeeeeeeeerrre's Johnny!")
		user.visible_message(span_warning("[user] forces the airlock to open with [user.p_their()] [name]!"), \
							span_warning("We force the airlock to open."), \
							span_warning("You hear a metal screeching sound."))
		airlock.open(2)


/***************************************\
|***********COMBAT TENTACLES*************|
\***************************************/
/datum/action/changeling/weapon/tentacle
	name = "Tentacle"
	desc = "We ready a tentacle to grab items or victims with. Costs 10 chemicals."
	helptext = "We can use it once to retrieve a distant item. If used on living creatures, the effect depends on the intent: \
	Help will simply drag them closer, Disarm will grab whatever they are holding instead of them, Grab will put the victim in our hold after catching it, \
	and Harm will stun it, and stab it if we are also holding a sharp weapon. Cannot be used while in lesser form."
	button_icon_state = "tentacle"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 10
	genetic_damage = 5
	max_genetic_damage = 10
	weapon_type = /obj/item/gun/magic/tentacle
	weapon_name_simple = "tentacle"
	silent = TRUE


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
			loc.visible_message(span_warning("[loc.name]\'s arm starts stretching inhumanly!"), \
								span_warning("Our arm twists and mutates, transforming it into a tentacle."), \
								span_italics("You hear organic matter ripping and tearing!"))
		else
			to_chat(loc, span_notice("You prepare to extend a tentacle."))


/obj/item/gun/magic/tentacle/Destroy()
	if(parent_action)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WEAPON_APPEARS)
		parent_action = null
	return ..()


/obj/item/gun/magic/tentacle/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, span_warning("The [name] is not ready yet."))


/obj/item/gun/magic/tentacle/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] coils [src] tightly around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide."))
	return OXYLOSS


/obj/item/ammo_casing/magic/tentacle
	name = "tentacle"
	desc = "a tentacle."
	projectile_type = /obj/item/projectile/tentacle
	caliber = "tentacle"
	icon_state = "tentacle_end"
	muzzle_flash_effect = null
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
	armour_penetration = 0
	reflectability = REFLECTABILITY_NEVER //Let us not reflect this ever. It's not quite a bullet, and a cling should never wrap its tentacle around itself, it controls its body well
	var/intent = INTENT_HELP
	var/obj/item/ammo_casing/magic/tentacle/source //the item that shot it


/obj/item/projectile/tentacle/New(obj/item/ammo_casing/magic/tentacle/tentacle_casing)
	source = tentacle_casing
	..()


/obj/item/projectile/tentacle/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "tentacle", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1)
		intent = firer.a_intent
		if(intent == INTENT_DISARM)
			armour_penetration = 100   //ignore block_chance
	..()


/obj/item/projectile/tentacle/proc/reset_throw(mob/living/carbon/human/user)
	if(!user)
		return
	if(user.in_throw_mode)
		user.throw_mode_off() //Don't annoy the changeling if he doesn't catch the item


/obj/item/projectile/tentacle/proc/tentacle_disarm(obj/item/thrown_item)
	reset_throw(firer)
	if(!thrown_item || !firer)
		return

	if(thrown_item in firer.contents)
		return

	if(firer.get_active_hand())
		return

	if(istype(thrown_item, /obj/item/twohanded))
		if(firer.get_inactive_hand())
			return

	firer.put_in_active_hand(thrown_item)


/obj/item/projectile/tentacle/proc/tentacle_grab(mob/living/carbon/target)
	if(!firer || !target)
		return

	if(!firer.Adjacent(target))
		return

	var/obj/item/grab/grab = target.grabbedby(firer, 1)
	if(istype(grab))
		grab.state = GRAB_PASSIVE
		target.Weaken(4 SECONDS)


/obj/item/projectile/tentacle/proc/tentacle_stab(mob/living/carbon/target)
	if(!firer || !target)
		return

	if(!firer.Adjacent(target))
		return

	var/obj/item/offarm_item = firer.r_hand
	if(!is_sharp(offarm_item))
		offarm_item = firer.l_hand

	if(!is_sharp(offarm_item))
		return

	target.visible_message(span_danger("[firer] impales [target] with [offarm_item]!"), \
							span_danger("[firer] impales you with [offarm_item]!"))
	add_attack_logs(firer, target, "[firer] pulled [target] with a tentacle, attacking them with [offarm_item]") //Attack log is here so we can fetch the item they're stabbing with.

	target.apply_damage(offarm_item.force, BRUTE, "chest")
	do_item_attack_animation(target, used_item = offarm_item)
	add_blood(target)
	playsound(get_turf(firer), offarm_item.hitsound, 75, TRUE)


/obj/item/projectile/tentacle/on_hit(atom/target, blocked = 0)
	qdel(source.gun) //one tentacle only unless you miss
	if(blocked >= 100)
		return FALSE

	var/mob/living/carbon/human/user = firer
	if(istype(target, /obj/item))
		var/obj/item/item = target
		if(!item.anchored)
			to_chat(firer, "<span class='notice'>You pull [item] towards yourself.</span>")
			add_attack_logs(src, item, "[src] pulled [item] towards them with a tentacle")
			user.throw_mode_on()
			item.throw_at(user, 10, 2, callback = CALLBACK(src, PROC_REF(tentacle_disarm), item))
			. = TRUE

	else if(isliving(target))
		var/mob/living/l_target = target
		if(!l_target.anchored && !l_target.throwing)//avoid double hits
			if(iscarbon(l_target))
				var/mob/living/carbon/c_target = l_target
				switch(intent)
					if(INTENT_HELP)
						c_target.visible_message(span_danger("[c_target] is pulled by [user]'s tentacle!"), \
												span_userdanger("A tentacle grabs you and pulls you towards [user]!"))

						add_attack_logs(user, c_target, "[user] pulled [c_target] towards them with a tentacle")
						c_target.client?.move_delay = world.time + 1 SECONDS
						c_target.throw_at(get_step_towards(user, c_target), 8, 2)
						return TRUE

					if(INTENT_DISARM)
						var/obj/item/hand_item = c_target.l_hand
						if(!istype(hand_item, /obj/item/shield))  //shield is priotity target
							hand_item = c_target.r_hand
							if(!istype(hand_item, /obj/item/shield))
								hand_item = c_target.get_active_hand()
								if(!hand_item)
									hand_item = c_target.get_inactive_hand()

						if(hand_item)
							if(c_target.drop_item_ground(hand_item))
								c_target.visible_message(span_danger("[hand_item] is yanked out of [c_target]'s hand by [src]!"), \
														span_userdanger("A tentacle pulls [hand_item] away from you!"))
								add_attack_logs(src, c_target, "[src] has grabbed [hand_item] out of [c_target]'s hand with a tentacle")
								on_hit(hand_item) //grab the item as if you had hit it directly with the tentacle
								return TRUE

							else
								to_chat(firer, span_danger("You can't seem to pry [hand_item] out of [c_target]'s hands!"))
								add_attack_logs(src, c_target, "[src] tried to grab [hand_item] out of [c_target]'s hand with a tentacle, but failed")
								return FALSE

						else
							to_chat(firer, span_danger("[c_target] has nothing in hand to disarm!"))
							return FALSE

					if(INTENT_GRAB)
						c_target.visible_message(span_danger("[c_target] is grabbed by [user]'s tentacle!"), \
												span_userdanger("A tentacle grabs you and pulls you towards [user]!"))
						add_attack_logs(user, c_target, "[user] grabbed [c_target] with a changeling tentacle")
						c_target.client?.move_delay = world.time + 1 SECONDS
						c_target.throw_at(get_step_towards(user, c_target), 8, 2, callback = CALLBACK(src, PROC_REF(tentacle_grab), c_target))
						return TRUE

					if(INTENT_HARM)
						c_target.visible_message(span_danger("[c_target] is thrown towards [user] by a tentacle!"), \
												span_userdanger("A tentacle grabs you and throws you towards [user]!"))
						c_target.client?.move_delay = world.time + 1 SECONDS
						c_target.throw_at(get_step_towards(user, c_target), 8, 2, callback = CALLBACK(src, PROC_REF(tentacle_stab), c_target))
						return TRUE

			else
				l_target.visible_message(span_danger("[l_target] is pulled by [user]'s tentacle!"), \
										span_userdanger("A tentacle grabs you and pulls you towards [user]!"))
				l_target.throw_at(get_step_towards(user, l_target), 8, 2)
				. = TRUE


/obj/item/projectile/tentacle/Destroy()
	qdel(chain)
	source = null
	return ..()


/***************************************\
|****************SHIELD*****************|
\***************************************/
/datum/action/changeling/weapon/shield
	name = "Organic Shield"
	desc = "We reform one of our arms into a hard shield. Costs 20 chemicals."
	helptext = "Organic tissue cannot resist damage forever. The shield will break after it is hit too much. The more genomes we absorb, the stronger it is. Cannot be used while in lesser form."
	button_icon_state = "organic_shield"
	power_type = CHANGELING_PURCHASABLE_POWER
	chemical_cost = 20
	dna_cost = 1
	genetic_damage = 12
	max_genetic_damage = 20
	weapon_type = /obj/item/shield/changeling
	weapon_name_simple = "shield"


/datum/action/changeling/weapon/shield/sting_action(mob/user)
	var/obj/item/shield/changeling/shield = ..(user)
	if(!shield)
		return FALSE

	shield.remaining_uses = round(cling.absorbed_count * 3)
	return TRUE


/obj/item/shield/changeling
	name = "shield-like mass"
	desc = "A mass of tough, boney tissue. You can still see the fingers as a twisted pattern in the shield."
	flags = NODROP | DROPDEL
	icon_state = "ling_shield"
	block_chance = 50
	var/remaining_uses //Set by the changeling ability.


/obj/item/shield/changeling/New()
	..()
	if(ismob(loc))
		loc.visible_message(span_warning("The end of [loc.name]\'s hand inflates rapidly, forming a huge shield-like mass!"), \
							span_warning("We inflate our hand into a strong shield."), \
							span_italics("You hear organic matter ripping and tearing!"))


/obj/item/shield/changeling/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(remaining_uses < 1)
		if(ishuman(loc))
			var/mob/living/carbon/human/user = loc
			user.visible_message(span_warning("With a sickening crunch, [user] reforms [user.p_their()] shield into an arm!"), \
								span_notice("We assimilate our shield into our body."), \
								span_italics("You hear organic matter ripping and tearing!"))
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
		qdel(src)
		return FALSE
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
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 20
	genetic_damage = 8
	max_genetic_damage = 20
	suit_type = /obj/item/clothing/suit/space/changeling
	helmet_type = /obj/item/clothing/head/helmet/space/changeling
	suit_name_simple = "flesh shell"
	helmet_name_simple = "space helmet"
	recharge_slowdown = 0.5
	blood_on_castoff = TRUE


/obj/item/clothing/suit/space/changeling
	name = "flesh mass"
	icon_state = "lingspacesuit"
	desc = "A huge, bulky mass of pressure and temperature-resistant organic tissue, evolved to facilitate space travel."
	flags = STOPSPRESSUREDMAGE | NODROP | DROPDEL | HIDETAIL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 90) //No armor at all
	species_restricted = null
	sprite_sheets = list(
		"Unathi" = 'icons/mob/species/unathi/suit.dmi'
		)


/obj/item/clothing/suit/space/changeling/New()
	..()
	if(ismob(loc))
		loc.visible_message(span_warning("[loc.name]\'s flesh rapidly inflates, forming a bloated mass around [loc.p_their()] body!"), \
							span_warning("We inflate our flesh, creating a spaceproof suit!"), \
							span_italics("You hear organic matter ripping and tearing!"))
	START_PROCESSING(SSobj, src)


/obj/item/clothing/suit/space/changeling/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		user.reagents.add_reagent("perfluorodecalin", REAGENTS_METABOLISM)


/obj/item/clothing/head/helmet/space/changeling
	name = "flesh mass"
	icon_state = "lingspacehelmet"
	desc = "A covering of pressure and temperature-resistant organic tissue with a glass-like chitin front."
	flags = BLOCKHAIR | STOPSPRESSUREDMAGE | NODROP | DROPDEL
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 90)
	species_restricted = null
	sprite_sheets = list(
		"Unathi" = 'icons/mob/species/unathi/helmet.dmi'
		)


/***************************************\
|*****************ARMOR*****************|
\***************************************/
/datum/action/changeling/suit/armor
	name = "Chitinous Armor"
	desc = "We turn our skin into tough chitin to protect us from damage. Costs 25 chemicals."
	helptext = "Upkeep of the armor requires a low expenditure of chemicals. The armor is strong against brute force, but does not provide much protection from lasers. Cannot be used in lesser form."
	button_icon_state = "chitinous_armor"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 25
	genetic_damage = 11
	max_genetic_damage = 20
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
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 20, "bomb" = 10, "bio" = 4, "rad" = 0, "fire" = 90, "acid" = 90)
	flags_inv = HIDEJUMPSUIT
	cold_protection = 0
	heat_protection = 0
	hide_tail_by_species = list("Vulpkanin", "Unathi")
	sprite_sheets = list(
		"Vulpkanin" = 'icons/mob/species/vulpkanin/suit.dmi',
		"Unathi" = 'icons/mob/species/unathi/suit.dmi'
		)


/obj/item/clothing/suit/armor/changeling/New()
	..()
	if(ismob(loc))
		loc.visible_message(span_warning("[loc.name]\'s flesh turns black, quickly transforming into a hard, chitinous mass!"), \
							span_warning("We harden our flesh, creating a suit of armor!"), \
							span_italics("You hear organic matter ripping and tearing!"))


/obj/item/clothing/head/helmet/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin with transparent chitin in front."
	icon_state = "lingarmorhelmet"
	flags = BLOCKHAIR | NODROP | DROPDEL
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 20, "bomb" = 10, "bio" = 4, "rad" = 0, "fire" = 90, "acid" = 90)
	flags_inv = HIDEHEADSETS
	flags_cover = MASKCOVERSEYES|MASKCOVERSMOUTH
