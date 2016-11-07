/obj/effect/proc_holder/spell/targeted/conjure_item
	name = "Summon weapon"
	desc = "A generic spell that should not exist.  This summons an instance of a specific type of item, or if one already exists, un-summons it."
	invocation_type = "none"
	include_user = 1
	range = -1
	clothes_req = 0
	var/obj/item/item
	var/item_type = /obj/item/weapon/banhammer
	school = "conjuration"
	charge_max = 150
	cooldown_min = 10

/obj/effect/proc_holder/spell/targeted/conjure_item/cast(list/targets, mob/user = usr)
	if (item)
		qdel(item)
		item = null
	else
		for(var/mob/living/carbon/C in targets)
			if(C.drop_item())
				item = new item_type
				C.put_in_hands(item)

/obj/effect/proc_holder/spell/targeted/conjure_item/Destroy()
	if(item)
		qdel(item)
	return ..()
