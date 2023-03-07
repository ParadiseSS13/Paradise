/obj/effect/proc_holder/spell/sentient_sword_lunge
	name = "Lunge"
	desc = "Lunge at something in your viewrange."
	clothes_req = FALSE
	base_cooldown = 15 SECONDS
	invocation = "EN GUARD!"
	invocation_type = "shout"
	sound = 'sound/magic/repulse.ogg'
	action_icon_state = "repulse"

/obj/effect/proc_holder/spell/sentient_sword_lunge/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/sentient_sword_lunge/cast(list/targets, mob/user = usr)
	if(!istype(user.loc, /obj/item/nullrod/scythe/talking))
		to_chat(user, "<span class='warning'>You cannot use this ability if you're outside a blade!</span>")
		return
	var/obj/item/nullrod/scythe/talking/user_sword = user.loc
	user_sword.throw_at(targets[1], 10, 3, user)
