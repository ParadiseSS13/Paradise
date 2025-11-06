/*
 * Fireaxe
 */
/// DEM AXES MAN, marker -Agouri
/obj/item/fireaxe
	base_icon_state = "fireaxe"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	sharp = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	toolspeed = 0.25
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/crowbar.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF

	var/force_unwielded = 5
	var/force_wielded = 24

/obj/item/fireaxe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/forces_doors_open)
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = MELEE_ATTACK, _parry_cooldown = (10 / 3) SECONDS, _requires_two_hands = TRUE) // 2.3333 seconds of cooldown for 30% uptime
	AddComponent(/datum/component/two_handed, force_unwielded = force_unwielded, force_wielded = force_wielded, icon_wielded = "[base_icon_state]1")

/obj/item/fireaxe/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/fireaxe/afterattack__legacy__attackchain(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED)) //destroys windows and grilles in one hit
		if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille))
			var/obj/structure/W = A
			W.obj_destruction("fireaxe")

/// Blatant imitation of the fireaxe, but made out of bone.
/obj/item/fireaxe/boneaxe
	icon_state = "bone_axe0"
	base_icon_state = "bone_axe"
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."
	force_wielded = 23
	needs_permit = TRUE

/obj/item/fireaxe/energized
	desc = "Someone with a love for fire axes decided to turn this one into a high-powered energy weapon. Seems excessive."
	force_wielded = 35
	armor_penetration_flat = 10
	armor_penetration_percentage = 30
	var/charge = 20
	var/max_charge = 20

/obj/item/fireaxe/energized/Initialize(mapload)
	. = ..()
	// only update the new args
	AddComponent(/datum/component/two_handed, force_wielded = force_wielded, icon_wielded = "[base_icon_state]2")

/obj/item/fireaxe/energized/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/fireaxe/energized/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/fireaxe/energized/process()
	charge = min(charge + 1, max_charge)

/obj/item/fireaxe/energized/attack__legacy__attackchain(mob/M, mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_WIELDED) && charge == max_charge)
		if(isliving(M))
			var/mob/living/target = M
			charge = 0
			playsound(loc, 'sound/magic/lightningbolt.ogg', 5, 1)
			user.visible_message("<span class='danger'>[user] slams the charged axe into [M.name] with all [user.p_their()] might!</span>")
			do_sparks(1, 1, src)
			target.KnockDown(8 SECONDS)
			var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
			M.throw_at(throw_target, 5, 1)

/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/dualsaber
	name = "double-bladed energy sword"
	desc = "Handle with care."
	icon = 'icons/obj/weapons/energy_melee.dmi'
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	hitsound = "swing_hit"
	icon_state = "dualsaber0"
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY
	armor_penetration_flat = 10
	armor_penetration_percentage = 50
	origin_tech = "magnets=4;syndicate=5"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	light_power = 2
	needs_permit = TRUE
	var/hacked = FALSE
	var/blade_color
	var/brightness_on = 2
	var/colormap = list(red = LIGHT_COLOR_RED, blue = LIGHT_COLOR_LIGHTBLUE, green = LIGHT_COLOR_GREEN, purple = LIGHT_COLOR_PURPLE, rainbow = LIGHT_COLOR_WHITE)
	var/force_unwielded = 3
	var/force_wielded = 34
	var/wieldsound = 'sound/weapons/saberon.ogg'
	var/unwieldsound = 'sound/weapons/saberoff.ogg'

/obj/item/dualsaber/Initialize(mapload)
	. = ..()
	if(!blade_color)
		blade_color = pick("red", "blue", "green", "purple")
	AddComponent(/datum/component/parry, \
		_stamina_constant = 2, \
		_stamina_coefficient = 0.25, \
		_parryable_attack_types = ALL_ATTACK_TYPES, \
		_parry_cooldown = (4 / 3) SECONDS, /* 0.33 seconds of cooldown for 75% uptime */ \
		_requires_two_hands = TRUE)
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		force_unwielded = force_unwielded, \
		wieldsound = wieldsound, \
		unwieldsound = unwieldsound, \
		attacksound = 'sound/weapons/blade1.ogg', \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
		only_sharp_when_wielded = TRUE)

/obj/item/dualsaber/update_icon_state()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		icon_state = "dualsaber[blade_color]1"
		set_light(brightness_on, l_color=colormap[blade_color])
	else
		icon_state = "dualsaber0"
		set_light(0)

/obj/item/dualsaber/attack__legacy__attackchain(mob/target, mob/living/user)
	if(cigarette_lighter_act(user, target))
		return

	if(HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, "<span class='warning'>You grip the blade too hard and accidentally drop it!</span>")
		if(HAS_TRAIT(src, TRAIT_WIELDED))
			user.drop_item_to_ground(src)
			return
	..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && HAS_TRAIT(src, TRAIT_WIELDED) && prob(40) && force)
		to_chat(user, "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on [src].</span>")
		user.take_organ_damage(20, 25)
		return
	if((HAS_TRAIT(src, TRAIT_WIELDED)) && prob(50))
		INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)

/obj/item/dualsaber/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, "<span class='warning'>You need to activate [src] before you can light anything with it!</span>")
		return TRUE

	if(target == user)
		user.visible_message(
			"<span class='danger'>[user] flips through the air and spins [src] wildly! It brushes against [user.p_their()] [cig] and sets it alight!</span>",
			"<span class='notice'>You flip through the air and twist [src] so it brushes against [cig], lighting it with the blade.</span>",
			"<span class='danger'>You hear an energy blade slashing something!</span>"
		)
	else
		user.visible_message(
			"<span class='danger'>[user] flips through the air and slashes at [user] with [src]! The blade barely misses, brushing against [user.p_their()] [cig] and setting it alight!</span>",
			"<span class='notice'>You flip through the air and slash [src] at [cig], lighting it for [target].</span>",
			"<span class='danger'>You hear an energy blade slashing something!</span>"
		)
	user.do_attack_animation(target)
	playsound(user.loc, hitsound, 50, TRUE)
	cig.light(user, target)
	INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)
	return TRUE

/obj/item/dualsaber/proc/jedi_spin(mob/living/user)
	for(var/i in list(NORTH, SOUTH, EAST, WEST, EAST, SOUTH, NORTH, SOUTH, EAST, WEST, EAST, SOUTH))
		user.setDir(i)
		if(i == WEST)
			user.SpinAnimation(7, 1)
		sleep(1)

/obj/item/dualsaber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return FALSE
	. = ..()
	if(!.) // they did not block the attack
		return

	if(attack_type == THROWN_PROJECTILE_ATTACK)
		if(!isitem(hitby))
			return TRUE
		var/obj/item/TT = hitby
		addtimer(CALLBACK(TT, TYPE_PROC_REF(/atom/movable, throw_at), locateUID(TT.thrownby), 10, 4, owner), 0.2 SECONDS) //Timer set to 0.2 seconds to ensure item finshes the throwing to prevent double embeds
		return TRUE
	if(isitem(hitby))
		melee_attack_chain(owner, hitby.loc)
	else
		melee_attack_chain(owner, hitby)
	return TRUE

/obj/item/dualsaber/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)  //In case thats just so happens that it is still activated on the groud, prevents hulk from picking it up
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, "<span class='warning'>You can't pick up such a dangerous item with your meaty hands without losing fingers, better not to!</span>")
		return TRUE

/obj/item/dualsaber/green
	blade_color = "green"

/obj/item/dualsaber/red
	blade_color = "red"

/obj/item/dualsaber/purple
	blade_color = "purple"

/obj/item/dualsaber/blue
	blade_color = "blue"

/obj/item/dualsaber/proc/on_wield(obj/item/source, mob/living/carbon/user)
	if(user && HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, "<span class='warning'>You lack the grace to wield this!</span>")
		return COMPONENT_TWOHANDED_BLOCK_WIELD
	w_class = w_class_on

/obj/item/dualsaber/proc/on_unwield()
	w_class = initial(w_class)

/obj/item/dualsaber/IsReflect()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return TRUE

/obj/item/dualsaber/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!hacked)
		hacked = TRUE
		to_chat(user, "<span class='warning'>2XRNBW_ENGAGE</span>")
		blade_color = "rainbow"
		update_icon()
	else
		to_chat(user, "<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")

//spears
/obj/item/spear
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	icon = 'icons/obj/weapons/spears.dmi'
	base_icon_state = "spearglass"
	icon_state = "spearglass0"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	var/force_unwielded = 10
	var/force_wielded = 18
	throwforce = 20
	throw_speed = 4
	armor_penetration_flat = 5
	materials = list(MAT_METAL = 1150, MAT_GLASS = 2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharp = TRUE
	no_spin_thrown = TRUE
	var/obj/item/grenade/explosive = null
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	needs_permit = TRUE

/obj/item/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = MELEE_ATTACK, _parry_cooldown = (10 / 3) SECONDS, _requires_two_hands = TRUE) // 2.3333 seconds of cooldown for 30% uptime
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		force_unwielded = force_unwielded, \
		icon_wielded = "[base_icon_state]1")

/obj/item/spear/update_icon_state()
	icon_state = "[base_icon_state]0"

/obj/item/spear/proc/add_plasmaglass()
	// re-add the component to reset the stats
	force_wielded = 19
	force_unwielded = 11
	throwforce = 21
	base_icon_state = "spearplasma"
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		force_unwielded = force_unwielded, \
		icon_wielded = "[base_icon_state]1")

	update_icon()

/obj/item/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in parts_list
	if(istype(tip, /obj/item/shard/plasma))
		// re-add the component to reset the stats
		add_plasmaglass()

	update_icon()
	qdel(tip)
	..()


/obj/item/spear/afterattack__legacy__attackchain(atom/movable/AM, mob/user, proximity)
	if(!proximity)
		return
	if(isturf(AM)) //So you can actually melee with it
		return
	if(explosive && HAS_TRAIT(src, TRAIT_WIELDED))
		explosive.forceMove(AM)
		explosive.prime()
		qdel(src)

/obj/item/spear/throw_impact(atom/target)
	. = ..()
	if(explosive)
		explosive.prime()
		qdel(src)

/// Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
/obj/item/spear/bonespear
	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."
	base_icon_state = "bone_spear"
	icon_state = "bone_spear0"
	force = 11
	force_unwielded = 11
	force_wielded = 20					//I have no idea how to balance
	throwforce = 22
	armor_penetration_percentage = 15				//Enhanced armor piercing

//Blatant imitation of spear, but all natural. Also not valid for explosive modification.
/obj/item/spear/bamboo
	name = "bamboo spear"
	desc = "A haphazardly-constructed bamboo stick with a sharpened tip, ready to poke holes into unsuspecting people."
	base_icon_state = "bamboo_spear"
	icon_state = "bamboo_spear0"
	throwforce = 22

//GREY TIDE
/obj/item/spear/grey_tide
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	force_unwielded = 15
	force_wielded = 25
	attack_verb = list("gored")

/obj/item/spear/grey_tide/afterattack__legacy__attackchain(atom/movable/AM, mob/living/user, proximity)
	..()
	if(!proximity)
		return
	user.faction |= "greytide(\ref[user])"
	if(isliving(AM))
		var/mob/living/L = AM
		if(istype (L, /mob/living/simple_animal/hostile/illusion))
			return
		if(!L.stat && prob(50))
			var/mob/living/simple_animal/hostile/illusion/M = new(user.loc)
			M.faction = user.faction.Copy()
			M.attack_sound = hitsound
			M.Copy_Parent(user, 100, user.health/2.5, 12, 30)
			M.GiveTarget(L)

//Putting heads on spears
/obj/item/spear/attackby__legacy__attackchain(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/organ/external/head))
		if(user.unequip(src) && user.drop_item())
			to_chat(user, "<span class='notice'>You stick [I] onto the spear and stand it upright on the ground.</span>")
			var/obj/structure/headspear/HS = new /obj/structure/headspear(get_turf(src))
			var/matrix/M = matrix()
			I.transform = M
			var/image/IM = image(I.icon, I.icon_state)
			IM.overlays = I.overlays.Copy()
			HS.overlays += IM
			I.forceMove(HS)
			HS.mounted_head = I
			forceMove(HS)
			HS.contained_spear = src
	else
		return ..()

/obj/structure/headspear
	name = "head on a spear"
	desc = "How barbaric."
	icon_state = "headspear"
	anchored = TRUE
	var/obj/item/organ/external/head/mounted_head = null
	var/obj/item/spear/contained_spear = null

/obj/structure/headspear/Destroy()
	QDEL_NULL(mounted_head)
	QDEL_NULL(contained_spear)
	return ..()

/obj/structure/headspear/attack_hand(mob/living/user)
	user.visible_message("<span class='warning'>[user] kicks over [src]!</span>", "<span class='danger'>You kick down [src]!</span>")
	playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
	var/turf/T = get_turf(src)
	if(contained_spear)
		contained_spear.forceMove(T)
		contained_spear = null
	if(mounted_head)
		mounted_head.forceMove(T)
		mounted_head = null
	qdel(src)

// SINGULOHAMMER
/obj/item/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "singulohammer0"
	base_icon_state = "singulohammer"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 50, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/charged = 2
	origin_tech = "combat=4;bluespace=4;plasmatech=7"

/obj/item/singularityhammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.25, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (4 / 3) SECONDS, _requires_two_hands = TRUE) // 0.3333 seconds of cooldown for 75% uptime
	AddComponent(/datum/component/two_handed, \
		force_wielded = 40, \
		force_unwielded = force, \
		icon_wielded = "[base_icon_state]1")
	START_PROCESSING(SSobj, src)

/obj/item/singularityhammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/singularityhammer/process()
	if(charged < 2)
		charged++

/obj/item/singularityhammer/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "singulohammer0"

/obj/item/singularityhammer/proc/vortex(turf/pull, mob/wielder)
	for(var/atom/movable/X in range(5, pull))
		if(X.move_resist == INFINITY)
			continue
		if(X == wielder)
			continue
		if((X) && (!X.anchored) && (!ishuman(X)))
			step_towards(X, pull)
			step_towards(X, pull)
			step_towards(X, pull)
		else if(ishuman(X))
			var/mob/living/carbon/human/H = X
			if(HAS_TRAIT(H, TRAIT_MAGPULSE))
				continue
			H.Weaken(4 SECONDS)
			step_towards(H, pull)
			step_towards(H, pull)
			step_towards(H, pull)

/obj/item/singularityhammer/afterattack__legacy__attackchain(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		if(charged == 2)
			charged = 0
			if(isliving(A))
				var/mob/living/Z = A
				Z.take_organ_damage(20, 0)
			playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			var/turf/target = get_turf(A)
			vortex(target, user)

/obj/item/mjollnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "mjollnir0"
	base_icon_state = "mjollnir"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 30
	w_class = WEIGHT_CLASS_HUGE
	origin_tech = "combat=4;powerstorage=7"

/obj/item/mjollnir/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.25, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (4 / 3) SECONDS, _requires_two_hands = TRUE) // 0.3333 seconds of cooldown for 75% uptime
	AddComponent(/datum/component/two_handed, \
		force_wielded = 25, \
		force_unwielded = force, \
		icon_wielded = "[base_icon_state]1")

/obj/item/mjollnir/proc/shock(mob/living/target)
	do_sparks(5, 1, target.loc)
	target.visible_message("<span class='danger'>[target] was shocked by [src]!</span>",
		"<span class='userdanger'>You feel a powerful shock course through your body sending you flying!</span>",
		"<span class='danger'>You hear a heavy electrical crack!</span>")
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 200, 4)

/obj/item/mjollnir/attack__legacy__attackchain(mob/living/M, mob/user)
	..()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		M.Stun(6 SECONDS)
		shock(M)

/obj/item/mjollnir/throw_impact(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.Stun(6 SECONDS)
		shock(L)

/obj/item/mjollnir/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir0"

/obj/item/knighthammer
	name = "singuloth knight's hammer"
	desc = "A hammer made of sturdy metal with a golden skull adorned with wings on either side of the head. <br>This weapon causes devastating damage to those it hits due to a power field sustained by a mini-singularity inside of the hammer."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "knighthammer0"
	base_icon_state = "knighthammer"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	var/charged = 5
	origin_tech = "combat=5;bluespace=4"

/obj/item/knighthammer/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.25, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (4 / 3) SECONDS, _requires_two_hands = TRUE) // 0.3333 seconds of cooldown for 75% uptime
	AddComponent(/datum/component/two_handed, \
		force_wielded = 30, \
		force_unwielded = force, \
		icon_wielded = "[base_icon_state]1")

/obj/item/knighthammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/knighthammer/process()
	if(charged < 5)
		charged++

/obj/item/knighthammer/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	icon_state = "knighthammer0"

/obj/item/knighthammer/afterattack__legacy__attackchain(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(charged == 5)
		charged = 0
		if(isliving(A))
			var/mob/living/Z = A
			if(Z.health >= 1)
				Z.visible_message("<span class='danger'>[Z.name] was sent flying by a blow from [src]!</span>",
					"<span class='userdanger'>You feel a powerful blow connect with your body and send you flying!</span>",
					"<span class='danger'>You hear something heavy impact flesh!.</span>")
				var/atom/throw_target = get_edge_target_turf(Z, get_dir(src, get_step_away(Z, src)))
				Z.throw_at(throw_target, 200, 4)
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			else if(HAS_TRAIT(src, TRAIT_WIELDED) && Z.health < 1)
				Z.visible_message("<span class='danger'>[Z.name] was blown to pieces by the power of [src]!</span>",
					"<span class='userdanger'>You feel a powerful blow rip you apart!</span>",
					"<span class='danger'>You hear a heavy impact and the sound of ripping flesh!.</span>")
				Z.gib()
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
		if(HAS_TRAIT(src, TRAIT_WIELDED))
			if(iswallturf(A))
				var/turf/simulated/wall/Z = A
				Z.ex_act(EXPLODE_HEAVY)
				charged = 3
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			else if(isstructure(A) || ismecha(A))
				var/obj/Z = A
				Z.ex_act(EXPLODE_HEAVY)
				charged = 3
				playsound(user, 'sound/weapons/marauder.ogg', 50, 1)

// PYRO CLAWS
/obj/item/pyro_claws
	name = "hardplasma energy claws"
	desc = "The power of the sun, in the claws of your hand."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/energy_melee.dmi'
	icon_state = "pyro_claws"
	flags = ABSTRACT | NODROP | DROPDEL
	force = 22
	damtype = BURN
	armor_penetration_percentage = 50
	sharp = TRUE
	attack_effect_override = ATTACK_EFFECT_CLAW
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut", "savaged", "clawed")
	sprite_sheets_inhand = list("Vox" = 'icons/mob/clothing/species/vox/held.dmi', "Drask" = 'icons/mob/clothing/species/drask/held.dmi')
	toolspeed = 0.5
	var/lifetime = 60 SECONDS
	var/next_spark_time

/obj/item/pyro_claws/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/pyro_claws/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/pyro_claws/customised_abstract_text(mob/living/carbon/owner)
	return "<span class='warning'>[owner.p_they(TRUE)] [owner.p_have(FALSE)] energy claws extending [owner.p_their(FALSE)] wrists.</span>"

/obj/item/pyro_claws/process()
	lifetime -= 2 SECONDS
	if(lifetime <= 0)
		visible_message("<span class='warning'>[src] slides back into the depths of [loc]'s wrists.</span>")
		do_sparks(rand(1,6), 1, loc)
		qdel(src)
		return
	if(prob(15))
		do_sparks(rand(1,6), 1, loc)

/obj/item/pyro_claws/afterattack__legacy__attackchain(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(prob(60) && world.time > next_spark_time)
		do_sparks(rand(1,6), 1, loc)
		next_spark_time = world.time + 0.8 SECONDS
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if(!A.requiresID() || A.allowed(user))
			return

		if(A.locked)
			to_chat(user, "<span class='notice'>The airlock's bolts prevent it from being forced.</span>")
			return

		if(A.arePowerSystemsOn())
			user.visible_message("<span class='warning'>[user] jams [user.p_their()] [name] into the airlock and starts prying it open!</span>", "<span class='warning'>You start forcing the airlock open.</span>", "<span class='warning'>You hear a metal screeching sound.</span>")
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 150, 1)
			if(!do_after(user, 25, target = A))
				return

		user.visible_message("<span class='warning'>[user] forces the airlock open with [user.p_their()] [name]!</span>", "<span class='warning'>You force open the airlock.</span>", "<span class='warning'>You hear a metal screeching sound.</span>")
		A.open(2)

/obj/item/clothing/gloves/color/black/pyro_claws
	name = "Fusion gauntlets"
	desc = "A pair of heavy combat gauntlets that project lethal energy claws via the power of a captive pyroclastic anomaly core."
	icon_state = "pyro"
	inhand_icon_state = null
	worn_icon_state = null
	can_be_cut = FALSE
	actions_types = list(/datum/action/item_action/toggle)
	dyeable = FALSE
	var/on_cooldown = FALSE
	var/obj/item/assembly/signaler/anomaly/pyro/core
	var/next_spark_time

/obj/item/clothing/gloves/color/black/pyro_claws/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/clothing/gloves/color/black/pyro_claws/examine(mob/user)
	. = ..()
	if(core)
		. += "<span class='notice'>[src] are fully operational!</span>"
	else
		. += "<span class='warning'>It is missing a pyroclastic anomaly core.</span>"

/obj/item/clothing/gloves/color/black/pyro_claws/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_GLOVES)
		return TRUE

/obj/item/clothing/gloves/color/black/pyro_claws/ui_action_click(mob/user)
	if(!core)
		to_chat(user, "<span class='notice'>[src] has no core to power it!</span>")
		return
	if(on_cooldown)
		to_chat(user, "<span class='notice'>[src] is on cooldown!</span>")
		return
	if((user.l_hand && !user.drop_l_hand()) || (user.r_hand && !user.drop_r_hand()))
		to_chat(user, "<span class='notice'>[src] are unable to deploy the blades with the items in your hands!</span>")
		return
	var/obj/item/W = new /obj/item/pyro_claws
	user.visible_message("<span class='warning'>[user] deploys [W] from [user.p_their()] wrists in a shower of sparks!</span>", "<span class='notice'>You deploy [W] from your wrists!</span>", "<span class='warning'>You hear the shower of sparks!</span>")
	user.put_in_hands(W)
	on_cooldown = TRUE
	set_nodrop(TRUE, user)
	addtimer(CALLBACK(src, PROC_REF(reboot)), 2 MINUTES)
	if(world.time > next_spark_time)
		do_sparks(rand(1,6), 1, loc)
		next_spark_time = world.time + 0.8 SECONDS

/obj/item/clothing/gloves/color/black/pyro_claws/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/assembly/signaler/anomaly/pyro))
		if(core)
			to_chat(user, "<span class='notice'>[src] already has a [I]!</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src], and [src] starts to warm up.</span>")
		I.forceMove(src)
		core = I
	else
		return ..()

/obj/item/clothing/gloves/color/black/pyro_claws/proc/reboot()
	on_cooldown = FALSE
	set_nodrop(FALSE, loc)
	atom_say("Internal plasma canisters recharged. Gloves sufficiently cooled")

/// Max number of atoms a broom can sweep at once
#define BROOM_PUSH_LIMIT 20

/obj/item/push_broom
	name = "push broom"
	desc = "This is my BROOMSTICK! It can be used manually or braced with two hands to sweep items as you move. It has a telescopic handle for compact storage."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "broom0"
	base_icon_state = "broom"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 8
	throwforce = 10
	throw_speed = 3
	attack_verb = list("swept", "brushed off", "bludgeoned", "whacked")
	resistance_flags = FLAMMABLE

/obj/item/push_broom/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.75, _parryable_attack_types = MELEE_ATTACK, _parry_cooldown = (7 / 3) SECONDS, _requires_two_hands = TRUE)
	AddComponent(/datum/component/two_handed, \
		force_wielded = 12, \
		force_unwielded = force, \
		icon_wielded = "[base_icon_state]1", \
		wield_callback = CALLBACK(src, PROC_REF(wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(unwield)))

/obj/item/push_broom/update_icon_state()
	icon_state = "broom0"

/obj/item/push_broom/proc/wield(obj/item/source, mob/user)
	to_chat(user, "<span class='notice'>You brace [src] against the ground in a firm sweeping stance.</span>")
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(sweep))

/obj/item/push_broom/proc/unwield(obj/item/source, mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/obj/item/push_broom/afterattack__legacy__attackchain(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	sweep(user, A, FALSE)

/obj/item/push_broom/proc/sweep(mob/user, atom/A, moving = TRUE)
	SIGNAL_HANDLER
	var/turf/current_item_loc = moving ? user.loc : (isturf(A) ? A : A.loc)
	if(!isturf(current_item_loc))
		return
	var/turf/new_item_loc = get_step(current_item_loc, user.dir)
	var/obj/machinery/disposal/target_bin = locate(/obj/machinery/disposal) in new_item_loc.contents
	var/obj/structure/janitorialcart/jani_cart = locate(/obj/structure/janitorialcart) in new_item_loc.contents
	var/obj/vehicle/janicart/jani_vehicle = locate(/obj/vehicle/janicart) in new_item_loc.contents
	var/trash_amount = 1
	for(var/obj/item/garbage in current_item_loc.contents)
		if(garbage.anchored)
			continue
		var/obj/item/storage/bag/trash/bag = jani_vehicle?.mybag || jani_cart?.my_bag
		var/obj/trashed_into
		if(bag?.can_be_inserted(garbage, TRUE))
			bag.handle_item_insertion(garbage, user, TRUE)
			trashed_into = bag
		else if(target_bin)
			move_into_storage(user, target_bin, garbage)
			trashed_into = target_bin
		else
			garbage.Move(new_item_loc, user.dir)
		if(trashed_into)
			to_chat(user, "<span class='notice'>You sweep the pile of garbage into [trashed_into].</span>")
		trash_amount++
		if(trash_amount > BROOM_PUSH_LIMIT)
			break
	if(trash_amount > 1)
		playsound(loc, 'sound/weapons/sweeping.ogg', 70, TRUE, -1)

/obj/item/push_broom/proc/move_into_storage(mob/user, obj/storage, obj/trash)
	trash.forceMove(storage)
	storage.update_icon()

/obj/item/push_broom/traitor
	name = "titanium push broom"
	desc = "This is my BROOMSTICK! All of the functionality of a normal broom, but at least half again more robust."
	attack_verb = list("smashed", "slammed", "whacked", "thwacked", "swept")
	force = 10

/obj/item/push_broom/traitor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.25, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (4 / 3) SECONDS, _requires_two_hands = TRUE) // 0.3333 seconds of cooldown for 75% uptime
	// parent component handles this
	AddComponent(/datum/component/two_handed, force_wielded = 25, force_unwielded = force)

/obj/item/push_broom/traitor/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += "<span class='warning'>When wielded, the broom has different effects depending on your intent, similar to a martial art. \
			Help intent will sweep foes away from you, disarm intent sweeps their legs from under them, grab intent confuses \
			and minorly fatigues them, and harm intent hits them normally.</span>"

/obj/item/push_broom/traitor/attack__legacy__attackchain(mob/target, mob/living/user)
	if(!HAS_TRAIT(src, TRAIT_WIELDED) || !ishuman(target))
		return ..()

	var/mob/living/carbon/human/H = target

	switch(user.a_intent)
		if(INTENT_HELP)
			H.visible_message("<span class='danger'>[user] sweeps [H] away!</span>", \
							"<span class='userdanger'>[user] sweeps you away!</span>", \
							"<span class='italics'>You hear sweeping.</span>")
			playsound(loc, 'sound/weapons/sweeping.ogg', 70, TRUE, -1)

			var/atom/throw_target = get_edge_target_turf(H, get_dir(src, get_step_away(H, src)))
			H.throw_at(throw_target, 3, 1)

			add_attack_logs(user, H, "Swept away with titanium push broom", ATKLOG_ALL)

		if(INTENT_DISARM)
			if(H.stat || IS_HORIZONTAL(H))
				return ..()

			H.visible_message("<span class='danger'>[user] sweeps [H]'s legs out from under [H.p_them()]!</span>", \
							"<span class='userdanger'>[user] sweeps your legs out from under you!</span>", \
							"<span class='italics'>You hear sweeping.</span>")

			user.do_attack_animation(H, ATTACK_EFFECT_KICK)
			playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
			H.apply_damage(5, BRUTE)
			H.KnockDown(4 SECONDS)

			add_attack_logs(user, H, "Leg swept with titanium push broom", ATKLOG_ALL)

		if(INTENT_GRAB)
			H.visible_message("<span class='danger'>[user] smacks [H] with the brush of [user.p_their()] broom!</span>", \
							"<span class='userdanger'>[user] smacks you with the brush of [user.p_their()] broom!</span>", \
							"<span class='italics'>You hear a smacking noise.</span>")

			user.do_attack_animation(H, ATTACK_EFFECT_DISARM)
			playsound(get_turf(user), 'sound/effects/woodhit.ogg', 50, TRUE, -1)
			H.AdjustConfused(4 SECONDS, 0, 4 SECONDS) //no stacking infinitely
			H.apply_damage(15, STAMINA)

			add_attack_logs(user, H, "Swept with the brush of the titanium push broom", ATKLOG_ALL)

		if(INTENT_HARM)
			return ..()

#undef BROOM_PUSH_LIMIT

/// Supermatter Halberd, used by Oblivion Enforcers
/obj/item/supermatter_halberd
	name = "supermatter halberd"
	desc = "The revered weapon of Oblivion Enforcers, used to enforce the Order's will."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "smhalberd0"
	base_icon_state = "smhalberd"
	force = 5
	sharp = TRUE
	damtype = BURN
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 15
	toolspeed = 0.25
	attack_verb = list("enlightened", "enforced", "cleaved", "stabbed", "whacked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	resistance_flags = FIRE_PROOF
	var/static/list/obliteration_targets = list(/turf/simulated/wall, /obj/machinery/door/airlock)
	/// Whether we'll knockdown on hit
	var/charged = TRUE

/obj/item/supermatter_halberd/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SUPERMATTER_IMMUNE, ROUNDSTART_TRAIT) //so it can't be dusted by the SM
	AddComponent(/datum/component/forces_doors_open)
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.25, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (4 / 3) SECONDS, _requires_two_hands = TRUE) // 0.3333 seconds of cooldown for 75% uptime
	AddComponent(/datum/component/two_handed, force_wielded = 40, force_unwielded = force, icon_wielded = "[base_icon_state]1")

/obj/item/supermatter_halberd/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/supermatter_halberd/afterattack__legacy__attackchain(atom/A, mob/user, proximity)
	if(!proximity)
		return

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return

	if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille)) //same behavior as a fireaxe for windows
		var/obj/structure/W = A
		W.obj_destruction("fireaxe")

	//dusting dead people + knocking down people
	if(isliving(A))
		var/mob/living/target = A
		if(target.stat == DEAD)
			visible_message("<span class='danger'>[user] raises [src] high, ready to bring it down on [target]!</span>")
			if(do_after(user, 1 SECONDS, TRUE, target))
				visible_message("<span class='danger'>[user] brings down [src], obliterating [target] with a heavy blow!</span>")
				playsound(loc, 'sound/effects/supermatter.ogg', 50, TRUE)
				target.dust()
				return
			to_chat(user, "<span class='notice'>You lower [src]. There'll be time to obliterate them later...</span>")
			return

		if(charged)
			playsound(loc, 'sound/magic/lightningbolt.ogg', 5, TRUE)
			target.visible_message("<span class='danger'>[src] flares with energy and shocks [target]!</span>", \
									"<span class='userdanger'>You're shocked by [src]!</span>", \
									"<span class='warning'>You hear shocking.</span>")
			target.KnockDown(4 SECONDS)
			do_sparks(3, FALSE, src)
			charged = FALSE
			addtimer(CALLBACK(src, PROC_REF(recharge)), 4 SECONDS)

	//walls and airlock obliteration logic
	if(!is_type_in_list(A, obliteration_targets))
		return

	if(istype(A, /turf/simulated/wall/indestructible))
		return

	to_chat(user, "<span class='notice'>You start to obliterate [A].</span>")
	playsound(loc, hitsound, 50, TRUE)

	var/obj/effect/temp_visual/obliteration_rays/rays = new(get_turf(A))

	if(do_after(user, 5 SECONDS * toolspeed, target = A))
		new /obj/effect/temp_visual/obliteration(A, A)
		playsound(loc, 'sound/effects/supermatter.ogg', 25, TRUE)

		if(iswallturf(A))
			var/turf/AT = A
			AT.ChangeTurf(/turf/simulated/floor/plating)
			return

		if(istype(A, /obj/machinery/door/airlock))
			qdel(A)
			return

		qdel(rays)
		return

/obj/item/supermatter_halberd/proc/recharge()
	charged = TRUE
	playsound(loc, 'sound/machines/sm/accent/normal/1.ogg', 25, TRUE)
