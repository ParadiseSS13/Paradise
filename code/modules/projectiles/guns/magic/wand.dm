/obj/item/weapon/gun/magic/wand/
	name = "wand of nothing"
	desc = "It's not just a stick, it's a MAGIC stick!"
	projectile_type = "/obj/item/projectile/magic"
	icon_state = "nothingwand"
	item_state = "wand"
	w_class = 2
	can_charge = 0
	max_charges = 100 //100, 50, 50, 34 (max charge distribution by 25%ths)
	var/variable_charges = 1
	var/drained = 0

/obj/item/projectile/magic/fireball/Range()
	var/mob/living/L = locate(/mob/living) in (range(src, 1) - firer)
	if(L && L.stat != DEAD)
		Bump(L) //Magic Bullet #teachthecontroversy
		return
	..()

/obj/item/weapon/gun/magic/wand/New()
	if(prob(75) && variable_charges) //25% chance of listed max charges, 50% chance of 1/2 max charges, 25% chance of 1/3 max charges
		if(prob(33))
			max_charges = Ceiling(max_charges / 3)
		else
			max_charges = Ceiling(max_charges / 2)
	..()

/obj/item/weapon/gun/magic/wand/examine(mob/user)
	..(user)
	user << "Has [charges] charge\s remaining."

/obj/item/weapon/gun/magic/wand/attack_self(mob/living/user as mob)
	if(charges)
		zap_self(user)
	else
		user << "<span class='caution'>The [name] whizzles quietly.<span>"
	..()

/obj/item/weapon/gun/magic/wand/attack(atom/target as mob, mob/living/user as mob)
	if(target == user)
		return
	..()

/obj/item/weapon/gun/magic/wand/afterattack(atom/target as mob, mob/living/user as mob)
	if(!charges && !drained)
		user << "<span class='warning'>The [name] whizzles quietly.<span>"
		icon_state = "[icon_state]-drained"
		drained = 1
		return
	if(target == user)
		if(no_den_usage)
			var/area/A = get_area(user)
			if(istype(A, /area/wizard_station))
				user << "<span class='warning'>You know better than to violate the security of The Den, best wait until you leave to use [src].<span>"
				return
		else
			no_den_usage = 0
		zap_self(user)
	else
		..()

/obj/item/weapon/gun/magic/wand/proc/zap_self(mob/living/user as mob)
	user.visible_message("<span class='notice'>[user] zaps \himself with [src]!</span>")

/obj/item/weapon/gun/magic/wand/death
	name = "wand of death"
	desc = "This deadly wand overwhelms the victim's body with pure energy, slaying them without fail."
	projectile_type = "/obj/item/projectile/magic/death"
	icon_state = "deathwand"
	max_charges = 3 //3, 2, 2, 1

/obj/item/weapon/gun/magic/wand/death/zap_self(mob/living/user as mob)
	if(alert(user, "You really want to zap yourself with the wand of death?",, "Yes", "No") == "Yes" && charges && user.get_active_hand() == src && isliving(user))
		var/message ="<span class='warning'>You irradiate yourself with pure energy! "
		message += pick("Do not pass go. Do not collect 200 zorkmids.</span>","You feel more confident in your spell casting skills.</span>","You Die...</span>","Do you want your possessions identified?</span>")
		user << message
		user.adjustOxyLoss(500)
		charges--
		..()

/obj/item/weapon/gun/magic/wand/resurrection
	name = "wand of resurrection"
	desc = "This wand uses healing magics to heal and revive. They are rarely utilized within the Wizard Federation for some reason."
	projectile_type = "/obj/item/projectile/magic/resurrection"
	icon_state = "revivewand"
	max_charges = 3 //3, 2, 2, 1

/obj/item/weapon/gun/magic/wand/resurrection/zap_self(mob/living/user as mob)
	user.setToxLoss(0)
	user.setOxyLoss(0)
	user.setCloneLoss(0)
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.radiation = 0
	user.heal_overall_damage(user.getBruteLoss(), user.getFireLoss())
	user.reagents.clear_reagents()
	user << "<span class='notice'>You feel great!</span>"
	charges--
	..()

/obj/item/weapon/gun/magic/wand/polymorph
	name = "wand of polymorph"
	desc = "This wand is attuned to chaos and will radically alter the victim's form."
	projectile_type = "/obj/item/projectile/magic/change"
	icon_state = "polywand"
	max_charges = 10 //10, 5, 5, 4

/obj/item/weapon/gun/magic/wand/polymorph/zap_self(mob/living/user as mob)
	if(alert(user, "Your new form might not have arms to zap with... Continue?",, "Yes", "No") == "Yes" && charges && user.get_active_hand() == src && isliving(user))
		..() //because the user mob ceases to exists by the time wabbajack fully resolves
		wabbajack(user)
		charges--

/obj/item/weapon/gun/magic/wand/teleport
	name = "wand of teleportation"
	desc = "This wand will wrench targets through space and time to move them somewhere else."
	projectile_type = "/obj/item/projectile/magic/teleport"
	icon_state = "telewand"
	max_charges = 10 //10, 5, 5, 4
	no_den_usage = 1

/obj/item/weapon/gun/magic/wand/teleport/zap_self(mob/living/user as mob)
	do_teleport(user, user, 10)
	var/datum/effect/system/harmless_smoke_spread/smoke = new /datum/effect/system/harmless_smoke_spread()
	smoke.set_up(10, 0, user.loc)
	smoke.start()
	charges--
	..()

/obj/item/weapon/gun/magic/wand/door
	name = "wand of door creation"
	desc = "This particular wand can create doors in any wall for the unscrupulous wizard who shuns teleportation magics."
	projectile_type = "/obj/item/projectile/magic/door"
	icon_state = "doorwand"
	max_charges = 20 //20, 10, 10, 7

/obj/item/weapon/gun/magic/wand/door/zap_self()
	return

/obj/item/weapon/gun/magic/wand/fireball
	name = "wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames."
	projectile_type = "/obj/item/projectile/magic/fireball"
	icon_state = "firewand"
	max_charges = 8 //8, 4, 4, 3

/obj/item/weapon/gun/magic/wand/fireball/zap_self(mob/living/user as mob)
	if(alert(user, "Zapping yourself with a wand of fireball is probably a bad idea, do it anyway?",, "Yes", "No") == "Yes" && charges && user.get_active_hand() == src && isliving(user))
		explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
		charges--
		..()