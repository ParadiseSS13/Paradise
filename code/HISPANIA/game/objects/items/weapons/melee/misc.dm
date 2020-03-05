///Melee Weapons of Hispania/

///wooden sword///

/obj/item/melee/woodensword
	name = "wooden sword"
	desc = "A wooden sword made with wood and duct tape"
	icon = 'icons/hispania/obj/items.dmi'
	icon_state = "woodsword"
	item_state = "woodsword"
	force = 8
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 0
	armour_penetration = 0
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	hispania_icon = TRUE

/obj/item/melee/woodensword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
    if(attack_type == MELEE_ATTACK)
        final_block_chance += 20
    if(attack_type == THROWN_PROJECTILE_ATTACK)
        final_block_chance += 40
    return ..()

