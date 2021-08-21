/obj/effect/proc_holder/spell/conjure_item
	name = "Summon weapon"
	desc = "A generic spell that should not exist.  This summons an instance of a specific type of item, or if one already exists, un-summons it."
	invocation_type = "none"
	clothes_req = FALSE
	var/obj/item/item
	var/item_type = /obj/item/banhammer
	school = "conjuration"
	charge_max = 150
	cooldown_min = 10

/obj/effect/proc_holder/spell/conjure_item/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/conjure_item/cast(list/targets, mob/user = usr)
	if(item)
		QDEL_NULL(item)
	else
		for(var/mob/living/carbon/C in targets)
			if(C.drop_item())
				item = new item_type
				C.put_in_hands(item)

/obj/effect/proc_holder/spell/conjure_item/Destroy()
	QDEL_NULL(item)
	return ..()
