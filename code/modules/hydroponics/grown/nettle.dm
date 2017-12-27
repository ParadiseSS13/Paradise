/obj/item/seeds/nettle
	name = "pack of nettle seeds"
	desc = "These seeds grow into nettles."
	icon_state = "seed-nettle"
	species = "nettle"
	plantname = "Nettles"
	product = /obj/item/weapon/grown/nettle/basic
	lifespan = 30
	endurance = 40 // tuff like a toiger
	yield = 4
	growthstages = 5
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy)
	mutatelist = list(/obj/item/seeds/nettle/death)
	reagents_add = list("sacid" = 0.5)

/obj/item/seeds/nettle/death
	name = "pack of death-nettle seeds"
	desc = "These seeds grow into death-nettles."
	icon_state = "seed-deathnettle"
	species = "deathnettle"
	plantname = "Death Nettles"
	product = /obj/item/weapon/grown/nettle/death
	endurance = 25
	maturation = 8
	yield = 2
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy, /datum/plant_gene/trait/stinging)
	mutatelist = list()
	reagents_add = list("facid" = 0.5, "sacid" = 0.5)
	rarity = 20

/obj/item/weapon/grown/nettle //abstract type
	name = "nettle"
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "nettle"
	damtype = "fire"
	force = 15
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	origin_tech = "combat=3"
	attack_verb = list("stung")

/obj/item/weapon/grown/nettle/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is eating some of the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|TOXLOSS)

/obj/item/weapon/grown/nettle/pickup(mob/living/user)
	..()
	if(!ishuman(user))
		return 0
	var/mob/living/carbon/human/H = user
	if(H.gloves)
		return 0
	var/organ = ((H.hand ? "l_":"r_") + "arm")
	var/obj/item/organ/external/affecting = H.get_organ(organ)
	if(affecting)
		if(affecting.take_damage(0, force))
			H.UpdateDamageIcon()
	to_chat(H, "<span class='userdanger'>The nettle burns your bare hand!</span>")
	return 1



/obj/item/weapon/grown/nettle/afterattack(atom/A as mob|obj, mob/user,proximity)
	if(!proximity)
		return
	if(force > 0)
		force -= rand(1, (force / 3) + 1) // When you whack someone with it, leaves fall off
	else
		to_chat(usr, "All the leaves have fallen off the nettle from violent whacking.")
		usr.unEquip(src)
		qdel(src)

/obj/item/weapon/grown/nettle/basic
	seed = /obj/item/seeds/nettle

/obj/item/weapon/grown/nettle/basic/add_juice()
	..()
	force = round((5 + seed.potency / 5), 1)

/obj/item/weapon/grown/nettle/death
	seed = /obj/item/seeds/nettle/death
	name = "deathnettle"
	desc = "The <span class='danger'>glowing</span> nettle incites <span class='boldannounce'>rage</span> in you just from looking at it!"
	icon_state = "deathnettle"
	force = 30
	throwforce = 15
	origin_tech = "combat=5"

/obj/item/weapon/grown/nettle/death/add_juice()
	..()
	force = round((5 + seed.potency / 2.5), 1)

/obj/item/weapon/grown/nettle/death/pickup(mob/living/carbon/user)
	if(..())
		if(prob(50))
			user.Paralyse(5)
			to_chat(user, "<span class='userdanger'>You are stunned by the Deathnettle when you try picking it up!</span>")

/obj/item/weapon/grown/nettle/death/attack(mob/living/carbon/M, mob/user)
	..()
	if(isliving(M))
		to_chat(M, "<span class='danger'>You are stunned by the powerful acid of the Deathnettle!</span>")
		add_logs(user, M, "attacked", src)

		M.AdjustEyeBlurry(force/7)
		if(prob(20))
			M.Paralyse(force / 6)
			M.Weaken(force / 15)
		M.drop_item()
