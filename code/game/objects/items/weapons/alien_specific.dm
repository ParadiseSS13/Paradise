//This file contains xenoborg specic weapons.

/obj/item/melee/energy/alien/claws
	name = "energy claws"
	desc = "A set of alien energy claws."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-laser-claws"
	icon_state_on = "borg-laser-claws"
	force = 15
	force_on = 15
	throwforce = 5
	throwforce_on = 5
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	w_class_on = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "slashed", "gored", "sliced", "torn", "ripped", "butchered", "cut")
	attack_verb_on = list()

//Bottles for borg liquid squirters. PSSH PSSH
/obj/item/reagent_containers/spray/alien
	name = "liquid synthesizer"
	desc = "squirts alien liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-default"

/obj/item/reagent_containers/spray/alien/smoke
	name = "smoke synthesizer"
	desc = "squirts smokey liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-smoke"
	list_reagents = list(/datum/reagent/water = 50)

/obj/item/reagent_containers/spray/alien/smoke/afterattack(atom/A as mob|obj, mob/user as mob)
	if(istype(A, /obj/structure/reagent_dispensers) && get_dist(src,A) <= 1)
		if(!A.reagents.total_volume && A.reagents)
			to_chat(user, "<span class='notice'>\The [A] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
			return
	reagents.remove_reagent(/datum/reagent/water, 25)
	var/datum/effect_system/smoke_spread/bad/smoke = new
	smoke.set_up(5, 0, user.loc)
	smoke.start()
	playsound(user.loc, 'sound/effects/bamf.ogg', 50, 2)

/obj/item/reagent_containers/spray/alien/smoke/cyborg_recharge(coeff, emagged)
	reagents.check_and_add(/datum/reagent/water, volume, 2 * coeff)

/obj/item/reagent_containers/spray/alien/acid
	name = "acid synthesizer"
	desc = "squirts burny liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-acid"
	list_reagents = list(/datum/reagent/acid/facid = 125, /datum/reagent/acid = 125)

/obj/item/reagent_containers/spray/alien/acid/cyborg_recharge(coeff, emagged)
	reagents.check_and_add(/datum/reagent/acid/facid, volume / 2, 2 * coeff) // Volume / 2 here becuase there should be an even amount of both chems.
	reagents.check_and_add(/datum/reagent/acid, volume / 2, 2 * coeff)

/obj/item/reagent_containers/spray/alien/stun
	name = "paralytic toxin synthesizer"
	desc = "squirts viagra."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-stun"
	list_reagents = list(/datum/reagent/medicine/ether = 250)

/obj/item/reagent_containers/spray/alien/stun/cyborg_recharge(coeff, emagged)
	reagents.check_and_add(/datum/reagent/medicine/ether, volume, 2 * coeff)

//SKREEEEEEEEEEEE tool

/obj/item/flash/cyborg/alien
	name = "eye flash"
	desc = "Useful for taking pictures, making friends and flash-frying chips."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-flash"
