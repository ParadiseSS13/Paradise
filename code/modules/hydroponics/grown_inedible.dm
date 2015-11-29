// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/weapons.dmi'
	var/plantname
	var/potency = 1

/obj/item/weapon/grown/New(newloc,planttype)

	..()

	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src

	//Handle some post-spawn var stuff.
	if(planttype)
		plantname = planttype
		var/datum/seed/S = plant_controller.seeds[plantname]
		if(!S || !S.chems)
			return

		potency = S.get_trait(TRAIT_POTENCY)

		for(var/rid in S.chems)
			var/list/reagent_data = S.chems[rid]
			var/rtotal = reagent_data[1]
			if(reagent_data.len > 1 && potency > 0)
				rtotal += round(potency/reagent_data[2])
			reagents.add_reagent(rid,max(1,rtotal))

/obj/item/weapon/grown/deathnettle // -- Skie
	plantname = "deathnettle"
	desc = "The \red glowing \black nettle incites \red<B>rage</B>\black in you just from looking at it!"
	icon = 'icons/obj/weapons.dmi'
	name = "deathnettle"
	icon_state = "deathnettle"
	damtype = "fire"
	force = 30
	throwforce = 1
	w_class = 2.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "combat=3"
	attack_verb = list("stung")
	New()
		..()
		spawn(5)
			force = round((5+potency/2.5), 1)

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is eating some of the [src.name]! It looks like \he's trying to commit suicide.</b>"
		return (BRUTELOSS|TOXLOSS)

/obj/item/weapon/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'icons/obj/trash.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = 2.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/corncob/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/kitchenknife) || istype(W, /obj/item/weapon/kitchenknife/ritual))
		user << "<span class='notice'>You use [W] to fashion a pipe out of the corn cob!</span>"
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		qdel(src)
		return

/obj/item/weapon/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 2.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20


// Sunflower

/obj/item/weapon/grown/sunflower
	name = "sunflower"
	desc = "A large, fresh-grown sunflower. How cheery!"
	icon = 'icons/obj/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	w_class = 2.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/grown/sunflower/attack(mob/M as mob, mob/user as mob)
	M << "<font color='green'><b> [user] smacks you with a [name]!</font><font color='yellow'><b>FLOWER POWER<b></font>"
	user << "<font color='green'> Your [name]'s </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>"


// Novaflower

/obj/item/weapon/grown/novaflower
	name = "novaflower"
	desc = "A large, fresh-grown novaflower. It seems to radiate heat."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "novaflower"
	item_state = "sunflower"
	w_class = 2.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/grown/novaflower/attack(mob/living/carbon/M as mob, mob/user as mob)
	M << "<font color='green'>[user] smacks you with a [name]!</font><font color='yellow'><b>FLOWER POWER</b></font>"
	user << "<font color='green'> Your [name]'s </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>"
	if(istype(M, /mob/living))
		M << "<span class='warning'>You are heated by the warmth of the of the [name]!</span>"
		M.bodytemperature += potency/2 * TEMPERATURE_DAMAGE_COEFFICIENT

/obj/item/weapon/grown/novaflower/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		user << "<span class='warning'>The [name] burns your bare hand!</span>"
		user.adjustFireLoss(rand(1,5))
