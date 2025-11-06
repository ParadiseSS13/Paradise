/*
CONTENTS:
1. Wand of Nothing
2. Wand of Death
3. Wand of Healing
4. Wand of Polymorph
5. Wand of Teleportation
6. Wand of Door Creation
7. Wand of Fireball
8. Wand of Slipping
9. Wand of Chaos
*/

/obj/item/gun/magic/wand
	name = "wand of nothing"
	desc = "It's not just a stick, it's a MAGIC stick!"
	icon_state = "nothingwand"
	inhand_icon_state = "wand"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	belt_icon = "wand_nothing"
	ammo_type = /obj/item/ammo_casing/magic
	w_class = WEIGHT_CLASS_SMALL
	can_charge = FALSE
	max_charges = 100 //100, 50, 50, 34 (max charge distribution by 25%ths)
	var/variable_charges = TRUE
	execution_speed = 3 SECONDS

/obj/item/gun/magic/wand/Initialize(mapload)
	. = ..()
	if(prob(75) && variable_charges) //25% chance of listed max charges, 50% chance of 1/2 max charges, 25% chance of 1/3 max charges
		if(prob(33))
			max_charges = CEILING(max_charges / 3, 1)
			charges = max_charges
		else
			max_charges = CEILING(max_charges / 2, 1)
			charges = max_charges

/obj/item/gun/magic/wand/examine(mob/user)
	. = ..()
	. += "Has [charges] charge\s remaining."

/obj/item/gun/magic/wand/update_icon_state()
	icon_state = "[initial(icon_state)][charges ? "" : "-drained"]"

/obj/item/gun/magic/wand/attack__legacy__attackchain(atom/target, mob/living/user)
	if(target == user)
		return
	..()

/obj/item/gun/magic/wand/afterattack__legacy__attackchain(atom/target, mob/living/user)
	if(!charges)
		shoot_with_empty_chamber(user)
		return
	if(target == user)
		if(no_den_usage)
			var/area/A = get_area(user)
			if(istype(A, /area/wizard_station))
				to_chat(user, "<span class='warning'>You know better than to violate the security of The Den, best wait until you leave to use [src].</span>")
				return
			else
				no_den_usage = FALSE
		zap_self(user)
	else
		..()
	update_icon()

/obj/item/gun/magic/wand/proc/zap_self(mob/living/user)
	user.visible_message("<span class='danger'>[user] zaps [user.p_themselves()] with [src].</span>")
	playsound(user, fire_sound, 50, 1)
	user.create_attack_log("<b>[key_name(user)]</b> zapped [user.p_themselves()] with a <b>[src]</b>")
	add_attack_logs(user, user, "zapped [user.p_themselves()] with a [src]", ATKLOG_ALL)

// WAND OF DEATH


/obj/item/gun/magic/wand/death
	name = "wand of death"
	desc = "This deadly wand overwhelms the victim's body with pure energy, slaying them without fail."
	fire_sound = 'sound/magic/wandodeath.ogg'
	ammo_type = /obj/item/ammo_casing/magic/death
	icon_state = "deathwand"
	belt_icon = "wand_death"
	max_charges = 3 //3, 2, 2, 1

/obj/item/gun/magic/wand/death/zap_self(mob/living/user)
	..()
	charges--
	if(isliving(user))
		if(user.mob_biotypes & MOB_UNDEAD) //negative energy heals the undead
			user.revive()
			to_chat(user, "<span class='notice'>You feel great!</span>")
			return
	to_chat(user, "<span class='warning'>You irradiate yourself with pure negative energy! [pick("Do not pass go. Do not collect 200 zorkmids.", "You feel more confident in your spell casting skills.", "You Die...", "Do you want your possessions identified?")]</span>")
	if(ismachineperson(user)) //speshul snowfleks deserv speshul treetment
		user.adjustFireLoss(6969)
	user.death(FALSE)

// WAND OF HEALING

/obj/item/gun/magic/wand/resurrection
	name = "wand of resurrection"
	desc = "This wand uses healing magics to heal and revive. They are rarely utilized within the Wizard Federation for some reason."
	ammo_type = /obj/item/ammo_casing/magic/heal
	fire_sound = 'sound/magic/staff_healing.ogg'
	icon_state = "revivewand"
	belt_icon = "wand_revive"
	max_charges = 3 //3, 2, 2, 1

/obj/item/gun/magic/wand/resurrection/zap_self(mob/living/user)
	..()
	charges--
	if(isliving(user))
		if(user.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
			to_chat(user, "<span class='warning'>You irradiate yourself with pure positive energy! [pick("Do not pass go. Do not collect 200 zorkmids.", "You feel more confident in your spell casting skills.", "You Die...", "Do you want your possessions identified?")]</span>")
			user.death(FALSE)
			return
	user.revive()
	to_chat(user, "<span class='notice'>You feel great!</span>")

// WAND OF POLYMORPH


/obj/item/gun/magic/wand/polymorph
	name = "wand of polymorph"
	desc = "This wand is attuned to chaos and will radically alter the victim's form."
	ammo_type = /obj/item/ammo_casing/magic/change
	fire_sound = 'sound/magic/staff_change.ogg'
	icon_state = "polywand"
	belt_icon = "wand_polymorph"
	max_charges = 10 //10, 5, 5, 4

/obj/item/gun/magic/wand/polymorph/zap_self(mob/living/user)
	..() //because the user mob ceases to exists by the time wabbajack fully resolves
	wabbajack(user)
	charges--

// WAND OF TELEPORTATION


/obj/item/gun/magic/wand/teleport
	name = "wand of teleportation"
	desc = "This wand will wrench targets through space and time to move them somewhere else."
	ammo_type = /obj/item/ammo_casing/magic/teleport
	icon_state = "telewand"
	belt_icon = "wand_tele"
	max_charges = 10 //10, 5, 5, 4
	no_den_usage = TRUE
	fire_sound = 'sound/magic/wand_teleport.ogg'

/obj/item/gun/magic/wand/teleport/zap_self(mob/living/user)
	do_teleport(user, user, 10)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(10, FALSE, user)
	smoke.start()
	charges--
	..()

// WAND OF DOOR CREATION


/obj/item/gun/magic/wand/door
	name = "wand of door creation"
	desc = "This particular wand can create doors in any wall for the unscrupulous wizard who shuns teleportation magics."
	ammo_type = /obj/item/ammo_casing/magic/door
	fire_sound = 'sound/magic/staff_door.ogg'
	icon_state = "doorwand"
	belt_icon = "wand_door"
	max_charges = 20 //20, 10, 10, 7
	no_den_usage = TRUE

/obj/item/gun/magic/wand/door/zap_self(mob/living/user)
	to_chat(user, "<span class='notice'>You feel vaguely more open with your feelings.</span>")
	charges--
	..()

// WAND OF FIREBALL


/obj/item/gun/magic/wand/fireball
	name = "wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames."
	fire_sound = 'sound/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/fireball
	icon_state = "firewand"
	belt_icon = "wand_fireball"
	max_charges = 8 //8, 4, 4, 3

/obj/item/gun/magic/wand/fireball/zap_self(mob/living/user)
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2, cause = "Self-fireball")
	charges--
	..()

/obj/item/gun/magic/wand/fireball/attack__legacy__attackchain(atom/target, mob/living/user)
	if(!iscarbon(target))
		return ..()

	var/mob/living/M = target
	if(cigarette_lighter_act(user, M))
		return

	if(M != user)	// Do not blow yourself up!
		return ..()	// Blow everyone else up!

/obj/item/gun/magic/wand/fireball/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!charges)
		to_chat(user, "<span class='warning'>[src] is out of charge!</span>")
		return TRUE

	if(prob(50) || user.mind.assigned_role == "Wizard")
		if(target == user)
			user.visible_message(
				"<span class='warning'>Holy shit! Did [user] just manage to light [user.p_their()] [cig.name] with [src], with only moderate eyebrow singing!?</span>",
				"<span class='notice'>You swish and flick [src], lighting [cig] with a plume of flame, whilst only moderately eyebrow singing your eyebrows.</span>",
				"<span class='warning'>You hear a brief burst of flame!</span>"
			)
		else
			user.visible_message(
				"<span class='warning'>Holy shit! Did [user] just manage to light [cig] for [target] with [src], only moderately singing [target.p_their()] eyebrows!?</span>",
				"<span class='notice'>You swish and flick [src] at [target], lighting [user.p_their()] [cig.name] with a plume of flame, whilst only moderately singing [target.p_their()] eyebrows.</span>",
				"<span class='warning'>You hear a brief burst of flame!</span>"
			)
		cig.light(user, target)
		return TRUE

	// Oops...
	user.visible_message(
		"<span class='userdanger'>Unsure which end of [src] is which, [user] zaps [user.p_themselves()] with a fireball!</span>",
		"<span class='userdanger'>Unsure which end of [src] is which, you accidentally zap yourself with a fireball!</span>",
		"<span class='userdanger'>You hear a firey explosion!</span>"
	)
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2, cause = "Fireball to the face from failed cigarette lighting")
	charges--
	return TRUE

// This is needed to you don't try to perform an execution/suicide when lighting a cigarette.
/obj/item/gun/magic/wand/fireball/handle_suicide(mob/user, mob/living/carbon/human/target, params)
	var/mask_item = target.get_item_by_slot(ITEM_SLOT_MASK)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette) && user.zone_selected == "mouth" && user.a_intent == INTENT_HELP)
		return
	. = ..()

// WAND OF SLIPPING

/obj/item/gun/magic/wand/slipping
	name = "wand of slipping"
	desc = "This wand shoots... banana peels?"
	fire_sound = 'sound/items/bikehorn.ogg'
	ammo_type = /obj/item/ammo_casing/magic/slipping
	icon_state = "wandofslipping"
	max_charges = 5 //5, 4, 3, 2

/obj/item/gun/magic/wand/slipping/zap_self(mob/living/user)
	to_chat(user, "<span class='notice'>You feel rather silly!.</span>")
	charges--
	..()

// WAND OF CHAOS - Only spawned by the Staff of Chaos as a rare random effect

/obj/item/gun/magic/wand/chaos
	name = "wand of chaos"
	desc = "Payback time!"
	fire_sound = 'sound/magic/staff_chaos.ogg'
	ammo_type = /obj/item/ammo_casing/magic/chaos
	icon_state = "chaoswand"
	max_charges = 20
	variable_charges = FALSE
	no_den_usage = TRUE

/obj/item/gun/magic/wand/chaos/zap_self(mob/living/user)
	if(!ishuman(user))
		return
	to_chat(user, "<span class='chaosneutral'>[pick("Chaos chaos!", "You can do anything!", "You hear a mariachi band playing in the distance.", \
		"Would you like a glass of water?", "What fun is there in making sense?", "Maybe you ought to go back home and crawl under your bed.", \
		"Time to dual wield chaos wands!", "Sixty percent of the time, it works every time.", "Cheese for everyone!", "You hear a deep voice cackling.", \
		"Xom bursts into laughter!", "Xom thinks this is hilarious!")]</span>")
	var/obj/item/projectile/magic/chaos/proj = new /obj/item/projectile/magic/chaos(src)
	proj.chaos_chaos(user)
	qdel(proj)
	charges--
	..()
