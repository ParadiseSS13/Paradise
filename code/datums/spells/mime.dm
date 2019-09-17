/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall
	name = "Invisible Wall"
	desc = "The mime's performance transmutates into physical reality."
	school = "mime"
	panel = "Mime"
	summon_type = list(/obj/effect/forcefield/mime)
	invocation_type = "emote"
	invocation_emote_self = "<span class='notice'>You form a wall in front of yourself.</span>"
	summon_lifespan = 300
	charge_max = 300
	clothes_req = 0
	range = 0
	cast_sound = null
	human_req = 1

	action_icon_state = "mime"
	action_background_icon_state = "bg_mime"

/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			to_chat(usr, "<span class='notice'>You must dedicate yourself to silence first.</span>")
			return
		invocation = "<B>[usr.real_name]</B> looks as if a wall is in front of [usr.p_them()]."
	else
		invocation_type ="none"
	..()


/obj/effect/proc_holder/spell/targeted/mime/speak
	name = "Speech"
	desc = "Make or break a vow of silence."
	school = "mime"
	panel = "Mime"
	clothes_req = 0
	charge_max = 3000
	range = -1
	include_user = 1
	human_req = 1

	action_icon_state = "mime"
	action_background_icon_state = "bg_mime"

/obj/effect/proc_holder/spell/targeted/mime/speak/Click()
	if(!usr)
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(H.mind.miming)
		still_recharging_msg = "<span class='warning'>You can't break your vow of silence that fast!</span>"
	else
		still_recharging_msg = "<span class='warning'>You'll have to wait before you can give your vow of silence again!</span>"
	..()

/obj/effect/proc_holder/spell/targeted/mime/speak/cast(list/targets,mob/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		H.mind.miming=!H.mind.miming
		if(H.mind.miming)
			to_chat(H, "<span class='notice'>You make a vow of silence.</span>")
		else
			to_chat(H, "<span class='notice'>You break your vow of silence.</span>")

//Advanced Mimery traitor item spells

/obj/effect/proc_holder/spell/targeted/forcewall/mime
	name = "Invisible Greater Wall"
	desc = "Form an invisible three tile wide blockade."
	school = "mime"
	panel = "Mime"
	wall_type = /obj/effect/forcefield/mime/advanced
	invocation_type = "emote"
	invocation_emote_self = "<span class='notice'>You form a blockade in front of yourself.</span>"
	charge_max = 600
	sound =  null
	clothes_req = FALSE
	range = -1
	include_user = TRUE

	action_icon_state = "mime"
	action_background_icon_state = "bg_mime"
	large = TRUE

/obj/effect/proc_holder/spell/targeted/forcewall/mime/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			to_chat(usr, "<span class='notice'>You must dedicate yourself to silence first.</span>")
			return
		invocation = "<B>[usr.real_name]</B> looks as if a blockade is in front of [usr.p_them()]."
	else
		invocation_type ="none"
	..()

/obj/effect/proc_holder/spell/targeted/mime/fingergun
	name = "Finger Gun"
	desc = "Shoot stunning, invisible bullets out of your fingers! 6 bullets available per cast. Use your fingers to holster them manually."
	school = "mime"
	panel = "Mime"
	clothes_req = 0
	charge_max = 600
	range = -1
	include_user = 1
	human_req = 1

	action_icon_state = "fingergun"
	action_background_icon_state = "bg_mime"
	var/gun = /obj/item/gun/projectile/revolver/fingergun

/obj/effect/proc_holder/spell/targeted/mime/fingergun/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/C in targets)
		if(!istype(C.get_active_hand(), gun) && !istype(C.get_inactive_hand(), gun))
			to_chat(user, "<span class='notice'>You draw your fingers!</span>")
			C.drop_item()
			C.put_in_hands(new gun)
		else
			to_chat(user, "<span class='notice'>Holster your fingers first.</span>")
			revert_cast(user)

/obj/effect/proc_holder/spell/targeted/mime/fingergun/fake
	desc = "Pretend you're shooting bullets out of your fingers! 6 bullets available per cast. Use your fingers to holster them manually."
	gun = /obj/item/gun/projectile/revolver/fingergun/fake

// Mime Spellbooks

/obj/item/spellbook/oneuse/mime
	spell = /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall
	spellname = "Invisible Wall"
	name = "Miming Manual : "
	desc = "It contains various pictures of mimes mid-performance, aswell as some illustrated tutorials."
	icon_state = "bookmime"

/obj/item/spellbook/oneuse/mime/attack_self(mob/user)
	var/obj/effect/proc_holder/spell/S = new spell
	for(var/obj/effect/proc_holder/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == S.type)
			if(user.mind)
				to_chat(user, "<span class='notice'>You've already read this one.</span>")
			return
	if(used)
		recoil(user)
	else
		user.mind.AddSpell(S)
		to_chat(user, "<span class='notice'>You flip through the pages. Your understanding of the boundaries of reality increases. You can cast [spellname]!</span>")
		user.create_attack_log("<font color='orange'>[key_name(user)] learned the spell [spellname] ([S]).</font>")
		onlearned(user)

/obj/item/spellbook/oneuse/mime/recoil(mob/user)
	to_chat(user, "<span class='notice'>You flip through the pages. Nothing of interest to you.</span>")

/obj/item/spellbook/oneuse/mime/onlearned(mob/user)
	used = 1
	if(!locate(/obj/effect/proc_holder/spell/targeted/mime/speak) in user.mind.spell_list) //add vow of silence if not known by user
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak)
		to_chat(user, "<span class='notice'>You have learned how to use silence to improve your performance.</span>")

/obj/item/spellbook/oneuse/mime/fingergun
	spell = /obj/effect/proc_holder/spell/targeted/mime/fingergun
	spellname = "Finger Gun"
	desc = "It contains illustrations of guns and how to mime them."

/obj/item/spellbook/oneuse/mime/fingergun/fake
	spell = /obj/effect/proc_holder/spell/targeted/mime/fingergun/fake

/obj/item/spellbook/oneuse/mime/greaterwall
	spell = /obj/effect/proc_holder/spell/targeted/forcewall/mime
	spellname = "Invisible Greater Wall"
	desc = "It contains illustrations of the great walls of human history."