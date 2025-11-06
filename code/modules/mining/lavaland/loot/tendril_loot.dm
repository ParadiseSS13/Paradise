//Shared Bag

//Internal
/obj/item/storage/backpack/shared
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	max_combined_w_class = 60
	var/obj/item/shared_storage/red
	var/obj/item/shared_storage/blue

/obj/item/storage/backpack/shared/Adjacent(atom/neighbor, recurse = 1)
	return red?.Adjacent(neighbor, recurse) || blue?.Adjacent(neighbor, recurse)

//External
/obj/item/shared_storage
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	icon = 'icons/obj/storage.dmi'
	icon_state = "cultpack"
	inhand_icon_state = "backpack"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = INDESTRUCTIBLE
	var/obj/item/storage/backpack/shared/bag

/obj/item/shared_storage/Moved(atom/oldloc, dir, forced = FALSE)
	. = ..()
	bag?.update_viewers()

/obj/item/shared_storage/red

/obj/item/shared_storage/red/New()
	..()
	if(!bag)
		var/obj/item/storage/backpack/shared/S = new(src)
		var/obj/item/shared_storage/blue = new(loc)

		bag = S
		blue.bag = S
		bag.red = src
		bag.blue = blue

/obj/item/shared_storage/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADJACENCY_TRANSPARENT, ROUNDSTART_TRAIT)

/obj/item/shared_storage/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	bag?.attackby__legacy__attackchain(W, user, params)

/obj/item/shared_storage/attack_ghost(mob/user)
	if(isobserver(user))
		// Revenants don't get to play with the toys.
		bag?.show_to(user)
	return ..()

/obj/item/shared_storage/attack_self__legacy__attackchain(mob/living/carbon/user)
	if(!iscarbon(user))
		return
	if(user.is_holding(src))
		bag?.open(user)
	else
		..()

/obj/item/shared_storage/attack_hand(mob/living/carbon/user)
	if(!iscarbon(user))
		return
	if(loc == user && user.back && user.back == src)
		bag?.open(user)
	else
		..()

/obj/item/shared_storage/AltClick(mob/user)
	if(ishuman(user) && Adjacent(user) && !user.incapacitated(FALSE, TRUE))
		bag?.open(user)
		add_fingerprint(user)
	else if(isobserver(user))
		bag?.show_to(user)

/obj/item/shared_storage/MouseDrop(atom/over_object)
	if(iscarbon(usr))
		var/mob/M = usr

		if(!over_object)
			return

		if(ismecha(M.loc))
			return

		if(!M.restrained() && !M.stat)
			playsound(loc, "rustle", 50, TRUE, -5)

			if(istype(over_object, /atom/movable/screen/inventory/hand))
				if(!M.unequip(src))
					return
				M.put_in_active_hand(src)
			else
				bag?.open(usr)

			add_fingerprint(M)

//Book of Babel

/obj/item/book_of_babel
	name = "Book of Babel"
	desc = "An ancient tome written in countless tongues."
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	w_class = 2

/obj/item/book_of_babel/attack_self__legacy__attackchain(mob/user)
	to_chat(user, "You flip through the pages of the book, quickly and conveniently learning every language in existence. Somewhat less conveniently, the aging book crumbles to dust in the process. Whoops.")
	user.grant_all_babel_languages()
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)

//Boat

/obj/vehicle/lavaboat
	name = "lava boat"
	desc = "A boat used for traversing lava."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	held_key_type = /obj/item/oar
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	/// The last time we told the user that they can't drive on land, so we don't spam them
	var/last_message_time = 0

/obj/vehicle/lavaboat/relaymove(mob/user, direction)
	var/turf/next = get_step(src, direction)
	var/turf/current = get_turf(src)

	if(istype(next, /turf/simulated/floor/lava) || istype(current, /turf/simulated/floor/lava)) //We can move from land to lava, or lava to land, but not from land to land
		..()
	else
		if(last_message_time + 1 SECONDS < world.time)
			to_chat(user, "<span class='warning'>Boats don't go on land!</span>")
			last_message_time = world.time
		return FALSE

/obj/vehicle/lavaboat/Destroy()
	for(var/mob/living/M in buckled_mobs)
		M.weather_immunities -= "lava"
	return ..()

/obj/vehicle/lavaboat/user_buckle_mob(mob/living/M, mob/user)
	M.weather_immunities |= "lava"
	return ..()

/obj/vehicle/lavaboat/unbuckle_mob(mob/living/buckled_mob, force)
	. = ..()
	buckled_mob.weather_immunities -= "lava"

/obj/item/oar
	name = "oar"
	desc = "Not to be confused with the kind Research hassles you for."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "oar"
	inhand_icon_state = "rods"
	force = 12
	resistance_flags = LAVA_PROOF | FIRE_PROOF

/datum/crafting_recipe/oar
	name = "goliath bone oar"
	result = list(/obj/item/oar)
	reqs = list(/obj/item/stack/sheet/bone = 2)
	time = 15
	category = CAT_PRIMAL

/datum/crafting_recipe/boat
	name = "goliath hide boat"
	result = list(/obj/vehicle/lavaboat)
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	time = 50
	category = CAT_PRIMAL

//Dragon Boat

/obj/item/ship_in_a_bottle
	name = "ship in a bottle"
	desc = "A tiny ship inside a bottle."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "ship_bottle"

/obj/item/ship_in_a_bottle/attack_self__legacy__attackchain(mob/user)
	to_chat(user, "You're not sure how they get the ships in these things, but you're pretty sure you know how to get it out.")
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
	new /obj/vehicle/lavaboat/dragon(get_turf(src))
	qdel(src)

/obj/vehicle/lavaboat/dragon
	name = "mysterious boat"
	desc = "This boat moves where you will it, without the need for an oar."
	held_key_type = null
	icon_state = "dragon_boat"
	generic_pixel_y = 2
	generic_pixel_x = 1
	vehicle_move_delay = 1

//Wisp Lantern
/obj/item/wisp_lantern
	name = "spooky lantern"
	desc = "This lantern gives off no light, but is home to a friendly wisp."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lantern-blue"
	inhand_icon_state = "lantern"
	light_range = 7
	var/obj/effect/wisp/wisp
	var/sight_flags = SEE_MOBS
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/wisp_lantern/attack_self__legacy__attackchain(mob/user)
	if(!wisp)
		to_chat(user, "<span class='warning'>The wisp has gone missing!</span>")
		icon_state = "lantern"
		return

	if(wisp.loc == src)
		RegisterSignal(user, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(update_user_sight))

		to_chat(user, "<span class='notice'>You release the wisp. It begins to bob around your head.</span>")
		icon_state = "lantern"
		wisp.orbit(user, 20, lock_in_orbit = TRUE)
		set_light(0)

		user.update_sight()
		to_chat(user, "<span class='notice'>The wisp enhances your vision.</span>")

		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Freed") // freed
	else
		UnregisterSignal(user, COMSIG_MOB_UPDATE_SIGHT)

		to_chat(user, "<span class='notice'>You return the wisp to the lantern.</span>")
		wisp.stop_orbit()
		wisp.forceMove(src)
		set_light(initial(light_range))

		user.update_sight()
		to_chat(user, "<span class='notice'>Your vision returns to normal.</span>")

		icon_state = "lantern-blue"
		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Returned") // returned

/obj/item/wisp_lantern/Initialize(mapload)
	. = ..()
	wisp = new(src)

/obj/item/wisp_lantern/Destroy()
	if(wisp)
		if(wisp.loc == src)
			qdel(wisp)
		else
			wisp.visible_message("<span class='notice'>[wisp] has a sad feeling for a moment, then it passes.</span>")
	return ..()

/obj/item/wisp_lantern/proc/update_user_sight(mob/user)
	user.sight |= sight_flags
	if(!isnull(lighting_alpha))
		user.lighting_alpha = min(user.lighting_alpha, lighting_alpha)

/obj/effect/wisp
	name = "friendly wisp"
	desc = "Happy to light your way."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "orb"
	light_range = 7
	layer = ABOVE_ALL_MOB_LAYER

//Red/Blue Cubes
/obj/item/warp_cube
	name = "blue cube"
	desc = "A mysterious blue cube."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "blue_cube"
	var/obj/item/warp_cube/linked
	var/cooldown = FALSE

/obj/item/warp_cube/Destroy()
	if(linked)
		linked.linked = null
		linked = null
	return ..()

/obj/item/warp_cube/attack_self__legacy__attackchain(mob/user)
	if(!linked)
		to_chat(user, "[src] fizzles uselessly.")
		return

	if(is_in_teleport_proof_area(user) || is_in_teleport_proof_area(linked))
		to_chat(user, "<span class='warning'>[src] sparks and fizzles.</span>")
		return
	if(cooldown)
		to_chat(user, "<span class='warning'>[src] sparks and fizzles.</span>")
		return
	if(SEND_SIGNAL(user, COMSIG_MOVABLE_TELEPORTING, get_turf(linked)) & COMPONENT_BLOCK_TELEPORT)
		return FALSE
	if(is_station_level(user.z) && !iswizard(user)) // specifically not station (instead of lavaland) so it works for explorers potentially
		user.visible_message("<span class='warning'>[user] begins to channel [src]!</span>", "<span class='warning'>You begin channeling [src], cutting through the interference of the station!</span>")
		if(!do_after_once(user, 4 SECONDS, TRUE, src, allow_moving = TRUE, must_be_held = TRUE))
			return
	user.visible_message("<span class='warning'>[user] disappears in a puff of smoke!</span>")

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, FALSE, user)
	smoke.start()

	user.forceMove(get_turf(linked))
	SSblackbox.record_feedback("tally", "warp_cube", 1, type)

	var/datum/effect_system/smoke_spread/smoke2 = new
	smoke2.set_up(1, FALSE, user)
	smoke2.start()
	cooldown = TRUE
	linked.cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset)), 20 SECONDS)

/obj/item/warp_cube/proc/reset()
	cooldown = FALSE
	linked.cooldown = FALSE

/obj/item/warp_cube/red
	name = "red cube"
	desc = "A mysterious red cube."
	icon_state = "red_cube"

/obj/item/warp_cube/red/New()
	..()
	if(!linked)
		var/obj/item/warp_cube/blue = new(src.loc)
		linked = blue
		blue.linked = src

//Meat Hook

/obj/item/gun/magic/hook
	name = "meat hook"
	desc = "Mid or feed."
	icon_state = "hook"
	inhand_icon_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	ammo_type = /obj/item/ammo_casing/magic/hook
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	flags = NOBLUDGEON
	force = 18
	antimagic_flags = NONE

/obj/item/ammo_casing/magic/hook
	name = "hook"
	desc = "a hook."
	projectile_type = /obj/item/projectile/hook
	caliber = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "hook"
	muzzle_flash_effect = null

/obj/item/projectile/hook
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	damage = 25
	armor_penetration_percentage = 100
	hitsound = 'sound/effects/splat.ogg'
	weaken = 1 SECONDS
	knockdown = 6 SECONDS

/obj/item/projectile/hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "chain", time = INFINITY, maxdistance = INFINITY)
	..()
	//TODO: root the firer until the chain returns

/obj/item/projectile/hook/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored)
			L.visible_message("<span class='danger'>[L] is snagged by [firer]'s hook!</span>")
			var/old_density = L.density
			L.density = FALSE // Ensures the hook does not hit the target multiple times
			L.forceMove(get_turf(firer))
			L.density = old_density

/obj/item/projectile/hook/Destroy()
	QDEL_NULL(chain)
	return ..()

//Immortality Talisman

/obj/item/immortality_talisman
	name = "\improper Immortality Talisman"
	desc = "A dread talisman that can render you completely invulnerable."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "talisman"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/immortality)
	var/cooldown = 0

/obj/item/immortality_talisman/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, ALL)

/obj/item/immortality_talisman/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_IN_BACKPACK)
		var/user_UID = user.UID()
		ADD_TRAIT(user, TRAIT_ANTIMAGIC_NO_SELFBLOCK, user_UID)

/obj/item/immortality_talisman/dropped(mob/user, silent)
	. = ..()
	var/user_UID = user.UID()
	REMOVE_TRAIT(user, TRAIT_ANTIMAGIC_NO_SELFBLOCK, user_UID)

/datum/action/item_action/immortality
	name = "Immortality"

/obj/item/immortality_talisman/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/item/immortality_talisman/attack_self__legacy__attackchain(mob/user)
	if(cooldown < world.time)
		SSblackbox.record_feedback("amount", "immortality_talisman_uses", 1) // usage
		cooldown = world.time + 600
		user.visible_message("<span class='danger'>[user] vanishes from reality, leaving a hole in [user.p_their()] place!</span>")
		var/obj/effect/immortality_talisman/Z = new(get_turf(src.loc))
		Z.name = "hole in reality"
		Z.desc = "It's shaped an awful lot like [user.name]."
		Z.setDir(user.dir)
		user.forceMove(Z)
		user.notransform = TRUE
		user.status_flags |= GODMODE
		spawn(100)
			user.status_flags &= ~GODMODE
			user.notransform = FALSE
			user.forceMove(get_turf(Z))
			user.visible_message("<span class='danger'>[user] pops back into reality!</span>")
			Z.can_destroy = TRUE
			qdel(Z)
	else
		to_chat(user, "<span class='warning'>[src] is still recharging.</span>")

/obj/effect/immortality_talisman
	icon_state = "blank"
	var/can_destroy = FALSE

/obj/effect/immortality_talisman/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_EFFECT_CAN_TELEPORT, ROUNDSTART_TRAIT)

/obj/effect/immortality_talisman/ex_act()
	return

/obj/effect/immortality_talisman/singularity_act()
	return

/obj/effect/immortality_talisman/singularity_pull()
	return 0

/obj/effect/immortality_talisman/Destroy(force)
	if(!can_destroy && !force)
		return QDEL_HINT_LETMELIVE
	else
		. = ..()
