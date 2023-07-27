/obj/effect/proc_holder/spell/infinite_guns
	name = "Lesser Summon Guns"
	desc = "Why reload when you have infinite guns? Summons an unending stream of bolt action rifles. Requires both hands free to use."
	school = "conjuration"
	base_cooldown = 60 SECONDS
	cooldown_min = 1 SECONDS //Gun wizard
	clothes_req = TRUE

	action_icon_state = "bolt_action"


/obj/effect/proc_holder/spell/infinite_guns/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/infinite_guns/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		C.drop_from_active_hand()
		C.swap_hand()
		C.drop_from_active_hand()
		var/obj/item/gun/projectile/shotgun/boltaction/enchanted/GUN = new
		C.put_in_hands(GUN)

