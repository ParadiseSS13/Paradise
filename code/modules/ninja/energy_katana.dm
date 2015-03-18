

/obj/item/weapon/katana/energy
	name = "energy katana"
	desc = "A katana infused with a strong energy"
	icon_state = "energy_katana"
	item_state = "energy_katana"
	icon_override = 'icons/mob/in-hand/swords.dmi'
	force = 40
	throwforce = 20
	var/cooldown = 0 // Because spam aint cool, yo.

/obj/item/weapon/katana/energy/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(user, 'sound/weapons/blade1.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/katana/energy/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!user || !target)
		return

	if(proximity_flag && user.mind.special_role == "Ninja" && !cooldown)
		cooldown = 1
		playsound(user, "sparks", 50, 1)
		playsound(user, 'sound/weapons/blade1.ogg', 50, 1)
		user.visible_message("<span class='danger'>[user] masterfully slices [target]!</span>", "<span class='notice'>You masterfully slice [target]!</span>")
		target.emag_act(user)
		sleep(15)
		cooldown = 0

