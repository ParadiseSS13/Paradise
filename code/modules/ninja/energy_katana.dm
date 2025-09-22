/obj/item/katana/energy
	name = "energy katana"
	desc = "A katana infused with a strong energy."
	icon = 'icons/obj/weapons/energy_melee.dmi'
	icon_state = "energy_katana"
	throwforce = 20
	armor_penetration_percentage = 50
	armor_penetration_flat = 10
	var/cooldown = 0 // Because spam aint cool, yo.
	var/datum/effect_system/spark_spread/spark_system

/obj/item/katana/energy/attack__legacy__attackchain(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(user, 'sound/weapons/blade1.ogg', 50, TRUE, -1)
	return ..()

/obj/item/katana/energy/afterattack__legacy__attackchain(atom/target, mob/user, proximity_flag, click_parameters)
	if(!user || !target)
		return

	if(proximity_flag && user.mind.special_role == "Ninja" && !cooldown && isobj(target))
		cooldown = 1
		spark_system.start()
		playsound(user, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		playsound(user, 'sound/weapons/blade1.ogg', 50, 1)
		user.visible_message("<span class='danger'>[user] masterfully slices [target]!</span>", "<span class='notice'>You masterfully slice [target]!</span>")
		target.emag_act(user)
		sleep(15)
		cooldown = 0

/*/obj/item/katana/energy/throw_impact(atom/hit_atom)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		if(istype(H.wear_suit, /obj/item/clothing/suit/space/space_ninja))
			var/obj/item/clothing/suit/space/space_ninja/SN = H.wear_suit
			if(SN.energyKatana && SN.energyKatana == src)
				returnToOwner(H, 0, 1)
				return
	..()*/

/obj/item/katana/energy/proc/returnToOwner(mob/living/carbon/human/user, doSpark = 1, caught = 0)
	if(!istype(user))
		return
	loc = get_turf(src)

	if(doSpark)
		spark_system.start()
		playsound(get_turf(src), "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	var/msg = ""

	if(user.put_in_hands(src))
		msg = "Your Energy Katana teleports into your hand!"
	else if(user.equip_to_slot_if_possible(src, ITEM_SLOT_BELT, FALSE, TRUE))
		msg = "Your Energy Katana teleports back to you, sheathing itself as it does so!</span>"
	else
		loc = get_turf(user)
		msg = "Your Energy Katana teleports to your location!"

	if(caught)
		if(loc == user)
			msg = "You catch your Energy Katana!"
		else
			msg = "Your Energy Katana lands at your feet!"

	if(msg)
		to_chat(user, "<span class='notice'>[msg]</span>")

/obj/item/katana/energy/New()
	..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/katana/energy/Destroy()
	QDEL_NULL(spark_system)
	return ..()
