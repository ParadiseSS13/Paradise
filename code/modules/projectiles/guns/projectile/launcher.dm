/obj/item/weapon/gun/launcher

	name = "launcher"
	desc = "A device that launches things."
	icon = 'icons/obj/weapons.dmi'
	w_class = 5.0
	flags =  FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BACK

	var/release_force = 0
	var/fire_sound_text = "a launcher firing"

//Check if we're drawing and if the bow is loaded.
/obj/item/weapon/gun/launcher/proc/chamber_round()
	return (!isnull(in_chamber))

//This should not fit in a combat belt or holster.
/obj/item/weapon/gun/launcher/isHandgun()
	return 0

//Launchers are mechanical, no other impact.
/obj/item/weapon/gun/launcher/emp_act(severity)
	return

//This normally uses a proc on projectiles and our ammo is not strictly speaking a projectile.
/obj/item/weapon/gun/launcher/can_hit(var/mob/living/target as mob, var/mob/living/user as mob)
	return

//Override this to avoid a runtime with suicide handling.
/obj/item/weapon/gun/launcher/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if (M == user && user.zone_sel.selecting == "mouth")
		user << "\red Shooting yourself with \a [src] is pretty tricky. You can't seem to manage it."
		return
	..()

/obj/item/weapon/gun/launcher/proc/update_release_force()
	return 0

/obj/item/weapon/gun/launcher/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)

	if (!user.IsAdvancedToolUser())
		user << "\red You don't have the dexterity to do this!"
		return 0

	add_fingerprint(user)

	//Make sure target turfs both exist.
	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return 0

	if(!special_check(user))
		return 0

	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			user << "<span class='warning'>[src] is not ready to fire again!"
		return 0

	if(!chamber_round()) //CHECK
		return click_empty(user)

	if(!in_chamber)
		return 0

	update_release_force()

	playsound(user, fire_sound, 50, 1)
	user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
	"<span class='warning'>You fire [src][reflex ? "by reflex":""]!</span>", \
	"You hear [fire_sound_text]!")

	in_chamber.loc = get_turf(user)
	in_chamber.throw_at(target,10,release_force)

	sleep(1)

	in_chamber = null

	update_icon()

	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()

	return 1

/obj/item/weapon/gun/launcher/attack_self(mob/living/user as mob)
	return