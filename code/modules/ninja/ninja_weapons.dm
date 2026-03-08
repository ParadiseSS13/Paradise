/obj/item/katana/energy
	name = "energy katana"
	desc = "A plastitanium katana with a reinforced emitter edge. A ninja's most reliable tool."
	icon = 'icons/obj/weapons/energy_melee.dmi'
	icon_state = "energy_katana"
	force = 30
	embed_chance = 75
	throwforce = 20
	armor_penetration_percentage = 50
	armor_penetration_flat = 10
	origin_tech = "combat=6;syndicate=4"
	hitsound = 'sound/weapons/blade1.ogg'
	/// Is the weapon gripped or not?
	var/gripped = FALSE

/obj/item/katana/energy/activate_self(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return
	var/is_proper_modsuit = FALSE
	if(istype(user.gloves, /obj/item/clothing/gloves/mod))
		var/obj/item/mod/control/modsuit = user.get_item_by_slot(ITEM_SLOT_BACK)
		if(istype(modsuit) && istype(modsuit.theme, /datum/mod_theme/ninja))
			is_proper_modsuit = TRUE
	if(!istype(user.gloves, /obj/item/clothing/gloves/space_ninja) && !is_proper_modsuit)
		return
	if(!gripped)
		gripped = TRUE
		to_chat(user, SPAN_NOTICE("You tighten your grip on [src], ensuring you won't drop it."))
		set_nodrop(TRUE, user)
		return
	gripped = FALSE
	to_chat(user, SPAN_NOTICE("You relax your grip on [src]."))
	set_nodrop(FALSE, user)

/obj/item/katana/energy/dropped(mob/user, silent)
	. = ..()
	gripped = FALSE
	to_chat(user, SPAN_WARNING("Your grip on [src] is loosened!"))
	set_nodrop(FALSE, user)

/obj/item/katana/energy/equipped(mob/user, slot, initial)
	. = ..()
	if(gripped)
		gripped = FALSE
		to_chat(user, SPAN_NOTICE("You relax your grip on [src]."))
		set_nodrop(FALSE, user)

/obj/item/katana/energy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	if(!.) // they did not block the attack
		return
	if(isprojectile(hitby))
		var/obj/projectile/P = hitby
		if(P.reflectability == REFLECTABILITY_ENERGY)
			owner.visible_message(SPAN_DANGER("[owner] parries [attack_text] with [src]!"))
			add_attack_logs(P.firer, src, "hit by [P.type] but got parried by [src]")
			return -1
		owner.visible_message(SPAN_DANGER("[owner] blocks [attack_text] with [src]!"))
		playsound(src, 'sound/weapons/effects/ric3.ogg', 100, TRUE)
		return TRUE
	return TRUE

/obj/item/energy_shuriken
	name = "energy shuriken"
	desc = "An ancient weapon, redefined. The blade hums with an electric edge, using itself as fuel."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "energy-shuriken"
	inhand_icon_state = "eshield0"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	force = 5
	throwforce = 30 // This is never used on mobs since this has a 100% embed chance.
	throw_speed = 4
	embedded_pain_multiplier = 4
	w_class = WEIGHT_CLASS_SMALL
	embed_chance = 100
	embedded_fall_chance = 0
	sharp = TRUE
	resistance_flags = FIRE_PROOF

/obj/item/energy_shuriken/Initialize(mapload)
	. = ..()
	// Only lasts so long. Delete self after some time.
	addtimer(CALLBACK(src, PROC_REF(qdel), src), 30 SECONDS)

/obj/item/energy_shuriken/throw_impact(atom/target)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	H.apply_damage(60, STAMINA)

/obj/item/shuriken_printer
	name = "shuriken printer"
	desc = "An advanced, tiny autofabricator that slowly creates and stores energy shurikens."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "shuriken-pouch"
	inhand_icon_state = "eshield0"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	origin_tech = "combat=6;syndicate=5"
	force = 5
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF

	new_attack_chain = TRUE
	/// What is the maximum number of energy shurikens the printer can hold?
	var/maximum_stars = 4
	/// What is the current number of energy shurikens the printer is holding?
	var/current_stars = 2
	/// How long the cooldown is to print more shurikens
	var/printing_time = 30 SECONDS
	/// Timer used to print stars
	var/fabrication_timer

/obj/item/shuriken_printer/Initialize(mapload)
	. = ..()
	fabrication_timer = addtimer(CALLBACK(src, PROC_REF(print_star)), 30 SECONDS, TIMER_LOOP | TIMER_STOPPABLE)

/obj/item/shuriken_printer/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("Alt-click to draw an energy shuriken!")
	. += SPAN_NOTICE("It has [current_stars] stored.")

/obj/item/shuriken_printer/AltClick(mob/living/carbon/user, modifiers)
	if(!iscarbon(user))
		return ..()
	if(current_stars < 1)
		return ..()
	current_stars--
	var/obj/item/energy_shuriken/star = new /obj/item/energy_shuriken(get_turf(src), src)
	user.put_in_hands(star)
	to_chat(user, SPAN_NOTICE("You draw [star] from [src]."))
	user.throw_mode_on()

/obj/item/shuriken_printer/proc/print_star()
	if(current_stars < maximum_stars)
		current_stars++

/obj/item/gun/energy/kinetic_accelerator/energy_net
	name = "energy net projector"
	desc = "A non-lethal weapon favored by the Spider Clan. Targets stunned by this weapon will be trapped in an energy net for extraction."
	icon_state = "energy-net-gun"
	inhand_icon_state = "energy-net-gun"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=6;magnets=4;syndicate=4"
	suppressed = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/net)
	unique_rename = FALSE
	overheat_time = 3 SECONDS
	holds_charge = TRUE
	unique_frequency = TRUE
	can_flashlight = FALSE
	max_mod_capacity = 0
	empty_state = "energy-net-gun_empty"
	can_holster = TRUE

/obj/item/gun/energy/kinetic_accelerator/energy_net/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SILENT_INSERTION, ROUNDSTART_TRAIT)

/obj/item/ammo_casing/energy/net
	projectile_type = /obj/projectile/energy/net
	muzzle_flash_color = null
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	select_name = "energy net"
	e_cost = 500
	fire_sound = 'sound/weapons/bolathrow.ogg'

/obj/projectile/energy/net
	name = "energy net"
	icon_state = "net-end"
	nodamage = 1
	stamina = 60
	knockdown = 4 SECONDS
	speed = 1.5

/obj/projectile/energy/net/fire(setAngle)
	if(firer)
		firer.Beam(src, icon_state = "net-beam", time = INFINITY, maxdistance = INFINITY, beam_type = /obj/effect/ebeam/floor)
	return ..()

/obj/projectile/energy/net/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(!firer)
		return
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(!H.stam_paralyzed)
		return
	var/obj/item/restraints/handcuffs/cable/green/cuff = new()
	cuff.apply_cuffs(H, firer, FALSE)
	var/obj/structure/bed/energy_net/net = new(H.loc)
	net.buckle_mob(H, TRUE)

/obj/structure/bed/energy_net
	name = "energy net"
	desc = "A pulsing array of green energy that can securely hold a victim in place."
	icon = 'icons/effects/effects.dmi'
	icon_state = "e-net"

/obj/structure/bed/energy_net/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(!has_buckled_mobs())
		Destroy() // We don't exist if nothing is being held
	for(var/buck in buckled_mobs) // No net, no buckles
		var/mob/living/M = buck
		if(M != user)
			if(!do_after(user, 10 SECONDS, target = src))
				if(M && M.buckled)
					to_chat(user, SPAN_WARNING("You fail to release [M] from \the [src]!"))
				return
			M.visible_message(SPAN_NOTICE("[user.name] pulls [M.name] free from the energy net!"),\
				SPAN_NOTICE("[user.name] pulls you free from the energy net."),\
				SPAN_ITALICS("You hear a small zap..."))
			unbuckle_mob(M)
			Destroy()
		if(!M.buckled)
			return
		M.visible_message(SPAN_WARNING("[M.name] breaks free from the energy net!"),\
			SPAN_NOTICE("You break free from the energy net!"),\
			SPAN_ITALICS("You hear a small zap..."))
		unbuckle_mob(M)
	Destroy()
