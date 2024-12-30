/datum/spell/sentient_sword_lunge
	name = "Lunge"
	desc = "Lunge at something in your view range."
	clothes_req = FALSE
	base_cooldown = 15 SECONDS
	invocation = "EN GARDE!"
	invocation_type = "shout"
	sound = 'sound/magic/repulse.ogg'
	action_icon_state = "lunge"

/datum/spell/sentient_sword_lunge/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/datum/spell/sentient_sword_lunge/cast(list/targets, mob/user = usr)
	if(!istype(user.loc, /obj/item))
		to_chat(user, "<span class='warning'>You cannot use this ability if you're outside a blade!</span>")
		return
	var/obj/item/nullrod/scythe/talking/user_sword = user.loc
	if(ishuman(user_sword.loc))
		var/mob/living/carbon/holder = user_sword.loc
		holder.drop_item_to_ground(user_sword)
	else if(isstorage(user_sword.loc))
		if(prob(50))
			to_chat(user, "<span class='warning'>You fail to break out of [user_sword.loc]!</span>")
			return
		var/turf/our_turf = get_turf(user_sword.loc)
		our_turf.visible_message("<span class='danger'>[user_sword] leaps out of [user_sword.loc]!</span>")
		user_sword.forceMove(our_turf)
	user_sword.throw_at(targets[1], 10, 3, user)
