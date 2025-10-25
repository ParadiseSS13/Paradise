/* CONTENTS:
* 1. GENERIC ENERGY BLADE
* 2. ENERGY AXE
* 3. ENERGY SWORD
* 4. ENERGY SAW
* 5. ENERGY CUTLASS
* 6. HARDLIGHT BLADE
* 7. CLEAVING SAW
*/
//////////////////////////////
// MARK: GENERIC ENERGY BLADE
//////////////////////////////
/obj/item/melee/energy
	name = "generic energy blade"
	desc = "If you can see this and didn't spawn it in as an admin, make an issue report on GitHub."
	icon = 'icons/obj/weapons/energy_melee.dmi'
	/// Damage done when active. Does not stack with force_off.
	var/force_on = 30
	/// Damage done when thrown while active. Does not stack with throwforce_off.
	var/throwforce_on = 20
	/// Used to properly reset the force.
	var/force_off
	/// Used to properly reset the force.
	var/throwforce_off
	/// Bonus damage dealt to any mob belonging to specified factions.
	var/faction_bonus_force = 0
	/// Any mob with a faction that exists in this list will take bonus damage/effects.
	var/list/nemesis_factions
	// Most of these are antag weps so we dont want them to be /too/ overt...
	stealthy_audio = TRUE
	w_class = WEIGHT_CLASS_SMALL
	/// Size when active, used to stop you from pocketing it when active. That would be silly.
	var/w_class_on = WEIGHT_CLASS_BULKY
	/// Alternative appearance when active.
	var/icon_state_on
	/// What flavour of shanking you perform when the blade is active.
	var/list/attack_verb_on = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/blade1.ogg' // Probably more appropriate than the previous hitsound. -- Dave
	usesound = 'sound/weapons/blade1.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF
	light_power = 2
	var/brightness_on = 2
	/// Blade color to adjust icon_state/inhand_icon_state
	var/blade_color
	/// Translates blade_color into RGB color for lighting system
	var/colormap = list(
		"red" = LIGHT_COLOR_RED,
		"blue" = LIGHT_COLOR_LIGHTBLUE,
		"green" = LIGHT_COLOR_GREEN,
		"purple" = LIGHT_COLOR_PURPLE,
		"rainbow" = LIGHT_COLOR_WHITE
	)
	/// Used to mark the item as a cleaving saw so that cigarette_lighter_act() will perform an early return.
	var/is_a_cleaving_saw = FALSE

/obj/item/melee/energy/Initialize(mapload)
	. = ..()
	force_off = initial(force) //We want to check this only when initializing, not when swapping, so sharpening works.
	throwforce_off = initial(throwforce)
	RegisterSignal(src, COMSIG_ITEM_SHARPEN_ACT, PROC_REF(try_sharpen))

/obj/item/melee/energy/Destroy()
	UnregisterSignal(src, COMSIG_ITEM_SHARPEN_ACT)
	return ..()

/obj/item/melee/energy/attack__legacy__attackchain(mob/living/target, mob/living/user)
	if(cigarette_lighter_act(user, target))
		return

	var/nemesis_faction = FALSE
	if(LAZYLEN(nemesis_factions))
		for(var/F in target.faction)
			if(F in nemesis_factions)
				nemesis_faction = TRUE
				force += faction_bonus_force
				nemesis_effects(user, target)
				break
	. = ..()
	if(nemesis_faction)
		force -= faction_bonus_force

/obj/item/melee/energy/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	if(is_a_cleaving_saw)
		return FALSE

	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
		to_chat(user, "<span class='warning'>You must activate [src] before you can light [cig] with it!</span>")
		return TRUE

	if(target == user)
		user.visible_message(
			"<span class='warning'>[user] makes a violent slashing motion, barely missing [user.p_their()] nose as light flashes! \
			[user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [cig] with [src] in the process.</span>",
			"<span class='notice'>You casually slash [src] at [cig], lighting it with the blade.</span>",
			"<span class='danger'>You hear an energy blade slashing something!</span>"
		)
	else
		user.visible_message(
			"<span class='danger'>[user] makes a violent slashing motion, barely missing the nose of [target] as light flashes! \
			[user.p_they(TRUE)] light[user.p_s()] [cig] in the mouth of [target] with [src] in the process.</span>",
			"<span class='notice'>You casually slash [src] at [cig] in the mouth of [target], lighting it with the blade.</span>",
			"<span class='danger'>You hear an energy blade slashing something!</span>"
		)
	user.do_attack_animation(target)
	playsound(user.loc, hitsound, 50, TRUE)
	cig.light(user, target)
	return TRUE

/obj/item/melee/energy/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting [user.p_their()] stomach open with [src]! It looks like [user.p_theyre()] trying to commit seppuku!</span>", \
						"<span class='suicide'>[user] is falling on [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>"))
	return BRUTELOSS|FIRELOSS

/obj/item/melee/energy/attack_self__legacy__attackchain(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='warning'>You accidentally cut yourself with [src], like a doofus!</span>")
		user.take_organ_damage(5,5)
	if(HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
		REMOVE_TRAIT(src, TRAIT_ITEM_ACTIVE, TRAIT_GENERIC)
		force = force_off
		throwforce = throwforce_off
		hitsound = initial(hitsound)
		throw_speed = initial(throw_speed)
		if(length(attack_verb_on))
			attack_verb = list()
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)  //changed it from 50% volume to 35% because deafness
		set_light(0)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	else
		ADD_TRAIT(src, TRAIT_ITEM_ACTIVE, TRAIT_GENERIC)
		force = force_on
		throwforce = throwforce_on
		hitsound = 'sound/weapons/blade1.ogg'
		throw_speed = 4
		if(length(attack_verb_on))
			attack_verb = attack_verb_on
		if(icon_state_on)
			icon_state = icon_state_on
			set_light(brightness_on, l_color = colormap[blade_color])
		else
			icon_state = "sword[blade_color]"
			set_light(brightness_on, l_color = colormap[blade_color])
		w_class = w_class_on
		playsound(user, 'sound/weapons/saberon.ogg', 35, 1) //changed it from 50% volume to 35% because deafness
		to_chat(user, "<span class='notice'>[src] is now active.</span>")

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return

/obj/item/melee/energy/get_heat()
	if(HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
		return 3500
	return 0

/obj/item/melee/energy/proc/try_sharpen(obj/item/item, amount, max_amount)
	SIGNAL_HANDLER // COMSIG_ITEM_SHARPEN_ACT
	if(force_on > initial(force_on) || force_on >= max_amount)
		return COMPONENT_BLOCK_SHARPEN_MAXED
	throwforce_on = clamp(throwforce_on + amount, 0, max_amount)
	throwforce_off = clamp(throwforce_off + amount, 0, max_amount)
	force_on = clamp(force_on + amount, 0, max_amount)
	force_off = clamp(force_off + amount, 0, max_amount)

//////////////////////////////
// MARK: AXE
//////////////////////////////
/obj/item/melee/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	icon_state_on = "axe1"
	force = 40
	force_on = 150
	throwforce = 25
	throwforce_on = 30
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	w_class_on = WEIGHT_CLASS_HUGE
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags = CONDUCT
	armor_penetration_percentage = 100
	origin_tech = "combat=4;magnets=3"
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	attack_verb_on = list()
	sharp = TRUE
	light_color = LIGHT_COLOR_WHITE

/obj/item/melee/energy/axe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] swings [src] towards [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS|FIRELOSS

//////////////////////////////
// MARK: SWORD
//////////////////////////////
// Base variant.
/obj/item/melee/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword"
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	hitsound = "swing_hit"
	embed_chance = 75
	embedded_impact_pain_multiplier = 10
	armor_penetration_percentage = 50
	armor_penetration_flat = 10
	origin_tech = "combat=3;magnets=4;syndicate=4"
	sharp = TRUE
	var/hacked = FALSE

/obj/item/melee/energy/sword/Initialize(mapload)
	. = ..()
	if(!blade_color)
		blade_color = pick("red", "blue", "green", "purple")
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES, _requires_activation = TRUE)

/obj/item/melee/energy/sword/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Can parry melee attacks and sometimes blocks ranged energy attacks. Use in hand to turn off and on.</span>"

/obj/item/melee/energy/sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
		return ..()
	return FALSE

// Borg variant.
/obj/item/melee/energy/sword/cyborg
	var/hitcost = 50

/obj/item/melee/energy/sword/cyborg/attack__legacy__attackchain(mob/M, mob/living/silicon/robot/R)
	if(R.cell)
		var/obj/item/stock_parts/cell/C = R.cell
		if(HAS_TRAIT(src, TRAIT_ITEM_ACTIVE) && !(C.use(hitcost)))
			attack_self__legacy__attackchain(R)
			to_chat(R, "<span class='notice'>It's out of charge!</span>")
			return
		..()
	return

/obj/item/melee/energy/sword/cyborg/saw/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return FALSE

// Syndicate energy sword.
/obj/item/melee/energy/sword/saber

/obj/item/melee/energy/sword/saber/blue
	blade_color = "blue"

/obj/item/melee/energy/sword/saber/purple
	blade_color = "purple"

/obj/item/melee/energy/sword/saber/green
	blade_color = "green"

/obj/item/melee/energy/sword/saber/red
	blade_color = "red"

/obj/item/melee/energy/sword/saber/attackby__legacy__attackchain(obj/item/W, mob/living/user, params)
	..()
	if(istype(W, /obj/item/melee/energy/sword/saber))
		if(W == src)
			to_chat(user, "<span class='notice'>You try to attach the end of the energy sword to... itself. You're not very smart, are you?</span>")
			if(ishuman(user))
				user.adjustBrainLoss(10)
		else
			to_chat(user, "<span class='notice'>You attach the ends of the two energy swords, making a single double-bladed weapon! You're cool.</span>")
			var/obj/item/dualsaber/newSaber = new /obj/item/dualsaber(user.loc)
			if(src.hacked) // That's right, we'll only check the "original" esword.
				newSaber.hacked = TRUE
				newSaber.blade_color = "rainbow"
			qdel(W)
			qdel(src)
			user.put_in_hands(newSaber)
	else if(istype(W, /obj/item/multitool))
		if(!hacked)
			hacked = TRUE
			blade_color = "rainbow"
			to_chat(user, "<span class='warning'>RNBW_ENGAGE</span>")

			if(HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
				icon_state = "swordrainbow"
				// Updating overlays, copied from welder code.
				// I tried calling attack_self twice, which looked cool, except it somehow didn't update the overlays!!
				if(user.r_hand == src)
					user.update_inv_r_hand()
				else if(user.l_hand == src)
					user.update_inv_l_hand()

		else
			to_chat(user, "<span class='warning'>It's already fabulous!</span>")


/obj/item/melee/energy/sword/saber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
		return FALSE
	. = ..()
	if(!.) // they did not block the attack
		return
	if(isprojectile(hitby))
		var/obj/item/projectile/P = hitby
		if(P.reflectability == REFLECTABILITY_ENERGY)
			owner.visible_message("<span class='danger'>[owner] parries [attack_text] with [src]!</span>")
			add_attack_logs(P.firer, src, "hit by [P.type] but got parried by [src]")
			return -1
		owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
		playsound(src, 'sound/weapons/effects/ric3.ogg', 100, TRUE)
		return TRUE

	return TRUE

//////////////////////////////
// MARK: SAW
//////////////////////////////
/// Used by medical Syndicate cyborgs
/obj/item/melee/energy/sword/cyborg/saw
	name = "energy saw"
	desc = "For heavy duty cutting. It has a carbon-fiber blade in addition to a toggleable hard-light edge to dramatically increase sharpness."
	force = 18 //About as much as a spear
	hitsound = 'sound/weapons/circsawhit.ogg'
	icon = 'icons/obj/surgery.dmi'
	icon_state = "esaw_0"
	icon_state_on = "esaw_1"
	hitcost = 75 //Costs more than a standard cyborg esword
	w_class = WEIGHT_CLASS_NORMAL
	light_color = LIGHT_COLOR_WHITE
	tool_behaviour = TOOL_SAW
	blade_color = "red"

//////////////////////////////
// MARK: CUTLASS
//////////////////////////////
/obj/item/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "A crude copy of syndicate technology. Favored among space pirates for its small form factor while inactive. Arrrr, matey!"
	force_on = 20
	throwforce_on = 10 // No PvP shenanigans, this is main weapon in PvE explorer gameplay and can be obtained very easy
	embed_chance = 45
	embedded_impact_pain_multiplier = 4
	armor_penetration_percentage = 0
	armor_penetration_flat = 0
	icon_state = "cutlass0"
	icon_state_on = "cutlass1"
	light_color = LIGHT_COLOR_RED
	origin_tech = "combat=3;magnets=4"
	blade_color = "red"

//////////////////////////////
// MARK: HARDLIGHT BLADE
//////////////////////////////
/obj/item/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	force = 30	//Normal attacks deal esword damage
	throwforce = 1//Throwing or dropping the item deletes it.
	throw_speed = 3
	throw_range = 1
	w_class = WEIGHT_CLASS_BULKY //So you can't hide it in your pocket or some such.
	sharp = TRUE

/obj/item/melee/energy/blade/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ITEM_ACTIVE, ROUNDSTART_TRAIT)

/obj/item/melee/energy/blade/attack_self__legacy__attackchain(mob/user)
	return

/obj/item/melee/energy/blade/hardlight
	name = "hardlight blade"
	desc = "An extremely sharp blade made out of hard light. Packs quite a punch."
	icon_state = "lightblade"

/obj/item/melee/energy/proc/nemesis_effects(mob/living/user, mob/living/target)
	return

//////////////////////////////
// MARK: CLEAVING SAW
//////////////////////////////
/obj/item/melee/energy/cleaving_saw
	name = "cleaving saw"
	desc = "This saw, effective at drawing the blood of beasts, transforms into a long cleaver that makes use of centrifugal force."
	force = 12
	force_on = 20 //force when active
	throwforce = 20
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	icon_state = "cleaving_saw"
	icon_state_on = "cleaving_saw_open"
	slot_flags = ITEM_SLOT_BELT
	is_a_cleaving_saw = TRUE
	var/attack_verb_off = list("attacked", "sawed", "sliced", "torn", "ripped", "diced", "cut")
	attack_verb_on = list("cleaved", "swiped", "slashed", "chopped")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY
	sharp = TRUE
	faction_bonus_force = 30
	nemesis_factions = list("mining", "boss")
	var/transform_cooldown
	var/swiping = FALSE

/obj/item/melee/energy/cleaving_saw/nemesis_effects(mob/living/user, mob/living/target)
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite)) // you get the bonus damage, but the bleed buildup is too much.
		return
	var/datum/status_effect/saw_bleed/B = target.has_status_effect(STATUS_EFFECT_SAWBLEED)
	if(!B)
		if(!HAS_TRAIT(src, TRAIT_ITEM_ACTIVE)) //This isn't in the above if-check so that the else doesn't care about active
			target.apply_status_effect(STATUS_EFFECT_SAWBLEED)
	else
		B.add_bleed(B.bleed_buildup)

/obj/item/melee/energy/cleaving_saw/attack_self__legacy__attackchain(mob/living/carbon/user)
	transform_weapon(user)

/obj/item/melee/energy/cleaving_saw/proc/transform_weapon(mob/living/user, supress_message_text)
	if(transform_cooldown > world.time)
		return FALSE

	transform_cooldown = world.time + (CLICK_CD_MELEE * 0.5)
	user.changeNext_move(CLICK_CD_MELEE * 0.25)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(HAS_TRAIT(H, TRAIT_CLUMSY) && prob(50))
			to_chat(H, "<span class='warning'>You accidentally cut yourself with [src], like a doofus!</span>")
			H.take_organ_damage(10,10)
	if(HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
		REMOVE_TRAIT(src, TRAIT_ITEM_ACTIVE, TRAIT_GENERIC)
		force = force_off
		throwforce = throwforce_off
		hitsound = initial(hitsound)
		throw_speed = initial(throw_speed)
		if(length(attack_verb_on))
			attack_verb = list()
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		playsound(user, 'sound/magic/fellowship_armory.ogg', 35, 1)  //changed it from 50% volume to 35% because deafness
		set_light(0)
		to_chat(user, "<span class='notice'>You close [src]. It will now attack rapidly and cause fauna to bleed.</span>")
	else
		ADD_TRAIT(src, TRAIT_ITEM_ACTIVE, TRAIT_GENERIC)
		force = force_on
		throwforce = throwforce_on
		hitsound = 'sound/weapons/bladeslice.ogg'
		throw_speed = 4
		if(length(attack_verb_on))
			attack_verb = attack_verb_on
		if(icon_state_on)
			icon_state = icon_state_on
			set_light(brightness_on, l_color = colormap[blade_color])
		else
			icon_state = "sword[blade_color]"
			set_light(brightness_on, l_color = colormap[blade_color])
		w_class = w_class_on
		playsound(user, 'sound/magic/fellowship_armory.ogg', 35, TRUE, frequency = 90000 - (HAS_TRAIT(src, TRAIT_ITEM_ACTIVE) * 30000))
		to_chat(user, "<span class='notice'>You open [src]. It will now cleave enemies in a wide arc and deal additional damage to fauna.</span>")

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()

	add_fingerprint(user)

/obj/item/melee/energy/cleaving_saw/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is [HAS_TRAIT(src, TRAIT_ITEM_ACTIVE) ? "open, will cleave enemies in a wide arc and deal additional damage to fauna":"closed, and can be used for rapid consecutive attacks that cause fauna to bleed"].<br>\
	Both modes will build up existing bleed effects, doing a burst of high damage if the bleed is built up high enough.<br>\
	Transforming it immediately after an attack causes the next attack to come out faster.</span>"

/obj/item/melee/energy/cleaving_saw/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is [HAS_TRAIT(src, TRAIT_ITEM_ACTIVE) ? "closing [src] on [user.p_their()] neck" : "opening [src] into [user.p_their()] chest"]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	transform_cooldown = 0
	transform_weapon(user, TRUE)
	return BRUTELOSS

/obj/item/melee/energy/cleaving_saw/melee_attack_chain(mob/user, atom/target, params)
	..()
	if(!HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //when closed, it attacks very rapidly

/obj/item/melee/energy/cleaving_saw/attack__legacy__attackchain(mob/living/target, mob/living/carbon/human/user)
	if(!HAS_TRAIT(src, TRAIT_ITEM_ACTIVE) || swiping || !target.density || get_turf(target) == get_turf(user))
		if(!HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
			faction_bonus_force = 0
		..()
		if(!HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
			faction_bonus_force = initial(faction_bonus_force)
	else
		var/turf/user_turf = get_turf(user)
		var/dir_to_target = get_dir(user_turf, get_turf(target))
		swiping = TRUE
		var/static/list/cleaving_saw_cleave_angles = list(0, -45, 45) //so that the animation animates towards the target clicked and not towards a side target
		for(var/i in cleaving_saw_cleave_angles)
			var/turf/T = get_step(user_turf, turn(dir_to_target, i))
			for(var/mob/living/L in T)
				if(user.Adjacent(L) && L.density)
					melee_attack_chain(user, L)
		swiping = FALSE
