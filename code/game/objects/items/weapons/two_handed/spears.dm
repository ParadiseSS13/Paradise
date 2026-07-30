/// Spears.
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
	new_attack_chain = TRUE

/obj/item/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, \
		_stamina_constant = 2, \
		_stamina_coefficient = 0.7, \
		_parryable_attack_types = MELEE_ATTACK, \
		_parry_cooldown = (10 / 3) SECONDS, \
		_requires_two_hands = TRUE) // 2.3333 seconds of parry cooldown for 30% uptime.
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		force_unwielded = force_unwielded, \
		icon_wielded = "[base_icon_state]1")

/obj/item/spear/update_icon_state()
	icon_state = "[base_icon_state]0"

/obj/item/spear/proc/add_plasmaglass()
	// Re-add the component to reset the stats.
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
		// Re-add the component to reset the stats.
		add_plasmaglass()

	update_icon()
	qdel(tip)
	..()

/obj/item/spear/after_attack(mob/living/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return FINISH_ATTACK
	if(explosive && HAS_TRAIT(src, TRAIT_WIELDED))
		explosive.forceMove(target)
		explosive.prime()
		qdel(src)
		return FINISH_ATTACK
	return ..()

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
	force_wielded = 20					// I have no idea how to balance.
	throwforce = 22
	armor_penetration_percentage = 15				// Enhanced armor piercing.

// Blatant imitation of spear, but all natural. Also not valid for explosive modification.
/obj/item/spear/bamboo
	name = "bamboo spear"
	desc = "A haphazardly-constructed bamboo stick with a sharpened tip, ready to poke holes into unsuspecting people."
	base_icon_state = "bamboo_spear"
	icon_state = "bamboo_spear0"
	throwforce = 22

// GREY TIDE.
/obj/item/spear/grey_tide
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	force_unwielded = 15
	force_wielded = 25
	attack_verb = list("gored")

/obj/item/spear/grey_tide/after_attack(mob/living/target, mob/living/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return FINISH_ATTACK
	user.faction |= "greytide(\ref[user])"
	if(!isliving(target))
		return ..()
	if(istype (target, /mob/living/simple_animal/hostile/illusion))
		return FINISH_ATTACK
	if(!target.stat && prob(50))
		var/mob/living/simple_animal/hostile/illusion/M = new(user.loc)
		M.faction = user.faction.Copy()
		M.attack_sound = hitsound
		M.Copy_Parent(user, 100, user.health/2.5, 12, 30)
		M.GiveTarget(target)
		return FINISH_ATTACK

// Putting heads on spears.
/obj/item/spear/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/organ/external/head))
		return ..()

	if(!(user.unequip(src) && user.drop_item()))
		to_chat(user, SPAN_WARNING("You can't attach [src] to [used] when one is stuck to your hand!"))
		return ITEM_INTERACT_COMPLETE

	to_chat(user, SPAN_NOTICE("You stick [used] onto the spear and stand it upright on the ground."))
	var/obj/structure/headspear/head_spear = new /obj/structure/headspear(get_turf(src))
	var/matrix/transform_matrix = matrix()
	used.transform = transform_matrix
	var/image/spear_overlays = image(used.icon, used.icon_state)
	spear_overlays.overlays = used.overlays.Copy()
	head_spear.overlays += spear_overlays
	used.forceMove(head_spear)
	head_spear.mounted_head = used
	forceMove(head_spear)
	head_spear.contained_spear = src
	return ITEM_INTERACT_COMPLETE

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
	user.visible_message(
		SPAN_WARNING("[user] kicks over [src]!"),
		SPAN_DANGER("You kick down [src]!"),
		SPAN_HEAR("You hear a sharp kick and a head rolling!")
	)
	playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
	var/turf/T = get_turf(src)
	if(contained_spear)
		contained_spear.forceMove(T)
		contained_spear = null
	if(mounted_head)
		mounted_head.forceMove(T)
		mounted_head = null
	qdel(src)

/// Supermatter Halberd, used by Oblivion Enforcers.
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
	new_attack_chain = TRUE

/obj/item/supermatter_halberd/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SUPERMATTER_IMMUNE, ROUNDSTART_TRAIT) // So it can't be dusted by the SM.
	AddComponent(/datum/component/forces_doors_open)
	AddComponent(/datum/component/parry, \
		_stamina_constant = 2, \
		_stamina_coefficient = 0.25, \
		_parryable_attack_types = ALL_ATTACK_TYPES, \
		_parry_cooldown = (4 / 3) SECONDS, \
		_requires_two_hands = TRUE) // 0.3333 seconds of parry cooldown for 75% uptime.
	AddComponent(/datum/component/two_handed, \
		force_wielded = 40, \
		force_unwielded = force, \
		icon_wielded = "[base_icon_state]1")

/obj/item/supermatter_halberd/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/supermatter_halberd/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()

	// Dusting dead people.
	if(isliving(target))
		var/mob/living/living_target = target
		if(!living_target.stat == DEAD)
			return ..() // Attack as normal.

		visible_message(SPAN_DANGER("[user] raises [src] high, ready to bring it down on [living_target]!"))
		if(!do_after(user, 1 SECONDS, TRUE, living_target))
			to_chat(user, SPAN_NOTICE("You lower [src]. There'll be time to obliterate them later..."))
			return ITEM_INTERACT_COMPLETE

		visible_message(
			SPAN_DANGER("[user] brings down [src], obliterating [living_target] with a heavy blow!"),
			SPAN_DANGER("A deafening resonance fills the air, followed by silence...")
		)
		user.do_attack_animation(living_target)
		playsound(loc, 'sound/effects/supermatter.ogg', 50, TRUE)
		living_target.dust()
		return ITEM_INTERACT_COMPLETE

	// Walls and airlock obliteration logic.
	if(!is_type_in_list(target, obliteration_targets))
		return ..()

	if(istype(target, /turf/simulated/wall/indestructible))
		return ..()

	user.visible_message(
		SPAN_DANGER("[user] embeds [src] into [target] and starts to obliterate it!"),
		SPAN_NOTICE("You embed [src] into [target] and start to obliterate it."),
		SPAN_DANGER("You hear something being struck by a weapon!") // Default deaf message.
	)
	user.do_attack_animation(target)
	playsound(loc, hitsound, 50, TRUE)

	var/obj/effect/temp_visual/obliteration_rays/rays = new(get_turf(target))

	if(!do_after(user, 5 SECONDS * toolspeed, target = target))
		user.visible_message(
			SPAN_NOTICE("[user] removes [src] from [target]."),
			SPAN_NOTICE("You remove [src] from [target]. There'll be time to obliterate it later...")
		)
		qdel(rays)
		return ITEM_INTERACT_COMPLETE

	user.visible_message(
		SPAN_DANGER("[user] obliterates [target]!"),
		SPAN_NOTICE("You obliterate [target]."),
		SPAN_DANGER("A deafening resonance fills the air, followed by silence...")
	)
	new /obj/effect/temp_visual/obliteration(target, target)
	playsound(loc, 'sound/effects/supermatter.ogg', 25, TRUE)

	if(iswallturf(target))
		var/turf/target_turf = target
		target_turf.ChangeTurf(/turf/simulated/floor/plating)
		return ITEM_INTERACT_COMPLETE

	if(istype(target, /obj/machinery/door/airlock))
		qdel(target)
		return ITEM_INTERACT_COMPLETE

	qdel(rays)
	return ITEM_INTERACT_COMPLETE

/obj/item/supermatter_halberd/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return FINISH_ATTACK

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()

	if(isliving(target) && charged)
		var/mob/living/living_target = target
		playsound(loc, 'sound/magic/lightningbolt.ogg', 5, TRUE)
		living_target.visible_message(
			SPAN_DANGER("[src] flares with energy and shocks [living_target]!"),
			SPAN_USERDANGER("You're shocked by [src]!"),
			SPAN_HEAR("You hear shocking!")
		)
		living_target.KnockDown(4 SECONDS)
		do_sparks(3, FALSE, src)
		charged = FALSE
		addtimer(CALLBACK(src, PROC_REF(recharge)), 4 SECONDS)
		return FINISH_ATTACK

	// Same behavior as a fireaxe for windows.
	if(istype(target, /obj/structure/window) || istype(target, /obj/structure/grille))
		var/obj/structure/target_structure = target
		target_structure.obj_destruction("fireaxe")
		return FINISH_ATTACK

/obj/item/supermatter_halberd/proc/recharge()
	charged = TRUE
	playsound(loc, 'sound/machines/sm/accent/normal/1.ogg', 25, TRUE)
