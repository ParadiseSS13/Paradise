// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/weapons.dmi'
	var/plantname
	var/potency = 1
	burn_state = FLAMMABLE

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

/obj/item/weapon/grown/nettle //abstract type
	name = "nettle"
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "nettle"
	damtype = "fire"
	force = 15
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwforce = 5
	w_class = 1
	throw_speed = 1
	throw_range = 3
	origin_tech = "combat=1"
	attack_verb = list("stung")

/obj/item/weapon/grown/nettle/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is eating some of the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|TOXLOSS)

/obj/item/weapon/grown/nettle/pickup(mob/living/user)
	if(!iscarbon(user))
		return 0
	var/mob/living/carbon/C = user
	if(ishuman(user))
		var/mob/living/carbon/human/H = C
		if(H.gloves)
			return 0
		var/organ = ((user.hand ? "l_":"r_") + "arm")
		var/obj/item/organ/external/affecting = H.get_organ(organ)
		if(affecting.take_damage(0,force))
			user.UpdateDamageIcon()
	else
		C.take_organ_damage(0,force)
	to_chat(C, "<span class='userdanger'>The nettle burns your bare hand!</span>")
	return 1

/obj/item/weapon/grown/nettle/afterattack(atom/A as mob|obj, mob/user,proximity)
	if(!proximity) return
	if(force > 0)
		force -= rand(1, (force / 3) + 1) // When you whack someone with it, leaves fall off
	else
		to_chat(usr, "All the leaves have fallen off the nettle from violent whacking.")
		usr.unEquip(src)
		qdel(src)


/obj/item/weapon/grown/nettle/death
	name = "deathnettle"
	desc = "The <span class='danger'>glowing</span> nettle incites <span class='boldannounce'>rage</span> in you just from looking at it!"
	icon_state = "deathnettle"
	force = 30
	throwforce = 15
	origin_tech = "combat=3"

/obj/item/weapon/grown/nettle/death/pickup(mob/living/carbon/user)
	if(..())
		if(prob(50))
			user.Paralyse(5)
			to_chat(user, "<span class='userdanger'>You are stunned by the Deathnettle when you try picking it up!</span>")

/obj/item/weapon/grown/nettle/death/afterattack(mob/living/carbon/M, mob/user)
	if(istype(M, /mob/living))
		to_chat(M, "<span class='danger'>You are stunned by the powerful acid of the Deathnettle!</span>")
		add_logs(user, M, "attacked", src)

		M.eye_blurry += force/7
		if(prob(20))
			M.Paralyse(force / 6)
			M.Weaken(force / 15)
		M.drop_item()
	..()

/obj/item/weapon/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'icons/obj/trash.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = 2
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/corncob/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || istype(W, /obj/item/weapon/kitchen/knife))
		to_chat(user, "<span class='notice'>You use [W] to fashion a pipe out of the corn cob!</span>")
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		qdel(src)
		return

/obj/item/weapon/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 2
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
	w_class = 2
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/grown/sunflower/attack(mob/M as mob, mob/user as mob)
	to_chat(M, "<font color='green'><b> [user] smacks you with a [name]!</font><font color='yellow'><b>FLOWER POWER<b></font>")
	to_chat(user, "<font color='green'> Your [name]'s </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>")


// Novaflower

/obj/item/weapon/grown/novaflower
	name = "novaflower"
	desc = "A large, fresh-grown novaflower. It seems to radiate heat."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "novaflower"
	item_state = "sunflower"
	w_class = 2
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/grown/novaflower/attack(mob/living/carbon/M as mob, mob/user as mob)
	to_chat(M, "<font color='green'>[user] smacks you with a [name]!</font><font color='yellow'><b>FLOWER POWER</b></font>")
	to_chat(user, "<font color='green'> Your [name]'s </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>")
	if(istype(M, /mob/living))
		to_chat(M, "<span class='danger'>You are lit on fire from the intense heat of the [name]!</span>")
		M.adjust_fire_stacks(potency / 20)
		if(M.IgniteMob())
			message_admins("[key_name_admin(user)] set [key_name_admin(M)] on fire")
			log_game("[key_name(user)] set [key_name(M)] on fire")

/obj/item/weapon/grown/novaflower/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		to_chat(user, "<span class='warning'>The [name] burns your bare hand!</span>")
		user.adjustFireLoss(rand(1,5))
