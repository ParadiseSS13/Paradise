/obj/item/melee/energy
	var/active = FALSE
	var/force_on = 30 //force when active
	var/throwforce_on = 20
	var/force_off //Used to properly reset the force
	var/throwforce_off
	var/faction_bonus_force = 0 //Bonus force dealt against certain factions
	var/list/nemesis_factions //Any mob with a faction that exists in this list will take bonus damage/effects
	stealthy_audio = TRUE //Most of these are antag weps so we dont want them to be /too/ overt.
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY
	var/icon_state_on
	var/list/attack_verb_on = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/blade1.ogg' // Probably more appropriate than the previous hitsound. -- Dave
	usesound = 'sound/weapons/blade1.ogg'
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF
	toolspeed = 1
	light_power = 2
	var/brightness_on = 2
	var/colormap = list(red=LIGHT_COLOR_RED, blue=LIGHT_COLOR_LIGHTBLUE, green=LIGHT_COLOR_GREEN, purple=LIGHT_COLOR_PURPLE, rainbow=LIGHT_COLOR_WHITE)

/obj/item/melee/energy/Initialize(mapload)
	. = ..()
	force_off = initial(force) //We want to check this only when initializing, not when swapping, so sharpening works.
	throwforce_off = initial(throwforce)

/obj/item/melee/energy/attack(mob/living/target, mob/living/carbon/human/user)
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

/obj/item/melee/energy/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting [user.p_their()] stomach open with [src]! It looks like [user.p_theyre()] trying to commit seppuku.</span>", \
						"<span class='suicide'>[user] is falling on [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>"))
	return BRUTELOSS|FIRELOSS

/obj/item/melee/energy/attack_self(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='warning'>You accidentally cut yourself with [src], like a doofus!</span>")
		user.take_organ_damage(5,5)
	active = !active
	if(active)
		force = force_on
		throwforce = throwforce_on
		hitsound = 'sound/weapons/blade1.ogg'
		throw_speed = 4
		if(attack_verb_on.len)
			attack_verb = attack_verb_on
		if(icon_state_on)
			icon_state = icon_state_on
			set_light(brightness_on, l_color = item_color ? colormap[item_color] : null)
		else
			icon_state = "sword[item_color]"
			set_light(brightness_on, l_color=colormap[item_color])
		w_class = w_class_on
		playsound(user, 'sound/weapons/saberon.ogg', 35, 1) //changed it from 50% volume to 35% because deafness
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = force_off
		throwforce = throwforce_off
		hitsound = initial(hitsound)
		throw_speed = initial(throw_speed)
		if(attack_verb_on.len)
			attack_verb = list()
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)  //changed it from 50% volume to 35% because deafness
		set_light(0)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return

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
	armour_penetration_percentage = 100
	origin_tech = "combat=4;magnets=3"
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	attack_verb_on = list()
	sharp = TRUE
	light_color = LIGHT_COLOR_WHITE

/obj/item/melee/energy/axe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] swings [src] towards [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return BRUTELOSS|FIRELOSS

/obj/item/melee/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	hitsound = "swing_hit"
	embed_chance = 75
	embedded_impact_pain_multiplier = 10
	armour_penetration_percentage = 50
	armour_penetration_flat = 10
	origin_tech = "combat=3;magnets=4;syndicate=4"
	sharp = TRUE
	var/hacked = FALSE

/obj/item/melee/energy/sword/New()
	..()
	if(item_color == null)
		item_color = pick("red", "blue", "green", "purple")
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)

/obj/item/melee/energy/sword/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Can parry melee attacks and sometimes blocks ranged energy attacks. Use in hand to turn off and on.</span>"

/obj/item/melee/energy/sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/melee/energy/sword/cyborg
	var/hitcost = 50

/obj/item/melee/energy/sword/cyborg/attack(mob/M, mob/living/silicon/robot/R)
	if(R.cell)
		var/obj/item/stock_parts/cell/C = R.cell
		if(active && !(C.use(hitcost)))
			attack_self(R)
			to_chat(R, "<span class='notice'>It's out of charge!</span>")
			return
		..()
	return

/obj/item/melee/energy/sword/cyborg/saw //Used by medical Syndicate cyborgs
	name = "energy saw"
	desc = "For heavy duty cutting. It has a carbon-fiber blade in addition to a toggleable hard-light edge to dramatically increase sharpness."
	force_on = 30
	force = 18 //About as much as a spear
	sharp = TRUE
	hitsound = 'sound/weapons/circsawhit.ogg'
	icon = 'icons/obj/surgery.dmi'
	icon_state = "esaw_0"
	icon_state_on = "esaw_1"
	hitcost = 75 //Costs more than a standard cyborg esword
	item_color = null
	w_class = WEIGHT_CLASS_NORMAL
	light_color = LIGHT_COLOR_WHITE
	tool_behaviour = TOOL_SAW

/obj/item/melee/energy/sword/cyborg/saw/New()
	..()
	item_color = null

/obj/item/melee/energy/sword/cyborg/saw/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return 0

/obj/item/melee/energy/sword/saber

/obj/item/melee/energy/sword/saber/blue
	item_color = "blue"

/obj/item/melee/energy/sword/saber/purple
	item_color = "purple"

/obj/item/melee/energy/sword/saber/green
	item_color = "green"

/obj/item/melee/energy/sword/saber/red
	item_color = "red"

/obj/item/melee/energy/sword/saber/attackby(obj/item/W, mob/living/user, params)
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
				newSaber.item_color = "rainbow"
			user.unEquip(W)
			user.unEquip(src)
			qdel(W)
			qdel(src)
			user.put_in_hands(newSaber)
	else if(istype(W, /obj/item/multitool))
		if(!hacked)
			hacked = TRUE
			item_color = "rainbow"
			to_chat(user, "<span class='warning'>RNBW_ENGAGE</span>")

			if(active)
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
	if(!active)
		return FALSE
	. = ..()
	if(!.) // they did not block the attack
		return
	if(istype(hitby, /obj/item/projectile))
		var/obj/item/projectile/P = hitby
		if(P.reflectability == REFLECTABILITY_NEVER) //only 1 magic spell does this, but hey, needed
			owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
			playsound(src, 'sound/weapons/effects/ric3.ogg', 100, TRUE)
			return TRUE
		owner.visible_message("<span class='danger'>[owner] parries [attack_text] with [src]!</span>")
		add_attack_logs(P.firer, src, "hit by [P.type] but got parried by [src]")
		return -1
	return TRUE

/obj/item/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	icon_state_on = "cutlass1"
	light_color = LIGHT_COLOR_RED

/obj/item/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	force = 30	//Normal attacks deal esword damage
	hitsound = 'sound/weapons/blade1.ogg'
	active = TRUE
	throwforce = 1//Throwing or dropping the item deletes it.
	throw_speed = 3
	throw_range = 1
	w_class = WEIGHT_CLASS_BULKY //So you can't hide it in your pocket or some such.
	sharp = TRUE

/obj/item/melee/energy/blade/attack_self(mob/user)
	return

/obj/item/melee/energy/blade/hardlight
	name = "hardlight blade"
	desc = "An extremely sharp blade made out of hard light. Packs quite a punch."
	icon_state = "lightblade"
	item_state = "lightblade"

/obj/item/melee/energy/proc/nemesis_effects(mob/living/user, mob/living/target)
	return

/obj/item/melee/energy/cleaving_saw
	name = "cleaving saw"
	desc = "This saw, effective at drawing the blood of beasts, transforms into a long cleaver that makes use of centrifugal force."
	force = 12
	force_on = 20 //force when active
	throwforce = 20
	throwforce_on = 20
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	icon_state = "cleaving_saw"
	icon_state_on = "cleaving_saw_open"
	slot_flags = SLOT_BELT
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
		if(!active) //This isn't in the above if-check so that the else doesn't care about active
			target.apply_status_effect(STATUS_EFFECT_SAWBLEED)
	else
		B.add_bleed(B.bleed_buildup)

/obj/item/melee/energy/cleaving_saw/attack_self(mob/living/carbon/user)
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
	active = !active
	if(active)
		force = force_on
		throwforce = throwforce_on
		hitsound = 'sound/weapons/bladeslice.ogg'
		throw_speed = 4
		if(attack_verb_on.len)
			attack_verb = attack_verb_on
		if(icon_state_on)
			icon_state = icon_state_on
			set_light(brightness_on, l_color = item_color ? colormap[item_color] : null)
		else
			icon_state = "sword[item_color]"
			set_light(brightness_on, l_color=colormap[item_color])
		w_class = w_class_on
		playsound(user, 'sound/magic/fellowship_armory.ogg', 35, TRUE, frequency = 90000 - (active * 30000))
		to_chat(user, "<span class='notice'>You open [src]. It will now cleave enemies in a wide arc and deal additional damage to fauna.</span>")
	else
		force = force_off
		throwforce = throwforce_off
		hitsound = initial(hitsound)
		throw_speed = initial(throw_speed)
		if(attack_verb_on.len)
			attack_verb = list()
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		playsound(user, 'sound/magic/fellowship_armory.ogg', 35, 1)  //changed it from 50% volume to 35% because deafness
		set_light(0)
		to_chat(user, "<span class='notice'>You close [src]. It will now attack rapidly and cause fauna to bleed.</span>")

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()

	add_fingerprint(user)

/obj/item/melee/energy/cleaving_saw/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is [active ? "open, will cleave enemies in a wide arc and deal additional damage to fauna":"closed, and can be used for rapid consecutive attacks that cause fauna to bleed"].<br>\
	Both modes will build up existing bleed effects, doing a burst of high damage if the bleed is built up high enough.<br>\
	Transforming it immediately after an attack causes the next attack to come out faster.</span>"

/obj/item/melee/energy/cleaving_saw/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is [active ? "closing [src] on [user.p_their()] neck" : "opening [src] into [user.p_their()] chest"]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	transform_cooldown = 0
	transform_weapon(user, TRUE)
	return BRUTELOSS

/obj/item/melee/energy/cleaving_saw/melee_attack_chain(mob/user, atom/target, params)
	..()
	if(!active)
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //when closed, it attacks very rapidly

/obj/item/melee/energy/cleaving_saw/attack(mob/living/target, mob/living/carbon/human/user)
	if(!active || swiping || !target.density || get_turf(target) == get_turf(user))
		if(!active)
			faction_bonus_force = 0
		..()
		if(!active)
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
