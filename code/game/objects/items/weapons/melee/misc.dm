/obj/item/weapon/melee
	needs_permit = 1

/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	origin_tech = "combat=4"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/slash.ogg' //pls replace


/obj/item/weapon/melee/chainofcommand/suicide_act(mob/user)
		to_chat(viewers(user), "<span class='suicide'>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
		return (OXYLOSS)

/obj/item/weapon/melee/rapier
	name = "captain's rapier"
	desc = "An elegant weapon, for a more civilized age."
	icon_state = "rapier"
	item_state = "rapier"
	flags = CONDUCT
	force = 15
	throwforce = 10
	w_class = 4
	block_chance = 50
	armour_penetration = 75
	sharp = 1
	edge = 1
	origin_tech = "combat=5"
	attack_verb = list("lunged at", "stabbed")
	hitsound = 'sound/weapons/slash.ogg'
	materials = list(MAT_METAL = 1000)

/obj/item/weapon/melee/rapier/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/weapon/melee/icepick
	name = "ice pick"
	desc = "Used for chopping ice. Also excellent for mafia esque murders."
	icon_state = "icepick"
	item_state = "icepick"
	force = 15
	throwforce = 10
	w_class = 2
	attack_verb = list("stabbed", "jabbed", "iced,")

/obj/item/weapon/melee/candy_sword
	name = "candy cane sword"
	desc = "A large candy cane with a sharpened point. Definitely too dangerous for schoolchildren."
	icon_state = "candy_sword"
	item_state = "candy_sword"
	force = 10
	throwforce = 7
	w_class = 3
	attack_verb = list("slashed", "stabbed", "sliced", "caned")