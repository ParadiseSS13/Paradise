/datum/spell/aoe/conjure/build/mime_wall
	name = "Invisible Wall"
	desc = "The mime's performance transmutates into physical reality."
	summon_type = list(/obj/structure/forcefield/mime)
	invocation_type = "emote"
	invocation_emote_self = "<span class='notice'>You form a wall in front of yourself.</span>"
	summon_lifespan = 20 SECONDS
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	cast_sound = null
	human_req = TRUE
	antimagic_flags = NONE

	action_icon_state = "mime"
	action_background_icon_state = "bg_mime"

/datum/spell/aoe/conjure/build/mime_wall/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			to_chat(usr, "<span class='notice'>You must dedicate yourself to silence first.</span>")
			return
		invocation = "<B>[usr.name]</B> looks as if a wall is in front of [usr.p_them()]."
	else
		invocation_type ="none"
	..()

/datum/spell/mime/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/mime/speak
	name = "Speech"
	desc = "Make or break a vow of silence."
	clothes_req = FALSE
	base_cooldown = 5 MINUTES
	human_req = TRUE

	action_icon_state = "mime_silence"
	action_background_icon_state = "bg_mime"

/datum/spell/mime/speak/Click()
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

/datum/spell/mime/speak/cast(list/targets,mob/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		H.mind.miming=!H.mind.miming
		if(H.mind.miming)
			to_chat(H, "<span class='notice'>You make a vow of silence.</span>")
		else
			to_chat(H, "<span class='notice'>You break your vow of silence.</span>")

//Advanced Mimery traitor item spells

/datum/spell/forcewall/mime
	name = "Invisible Greater Wall"
	desc = "Form an invisible three tile wide blockade."
	wall_type = /obj/effect/forcefield/mime
	invocation_type = "emote"
	invocation_emote_self = "<span class='notice'>You form a blockade in front of yourself.</span>"
	base_cooldown = 60 SECONDS
	sound =  null

	action_icon_state = "mime_bigwall"
	action_background_icon_state = "bg_mime"

/datum/spell/forcewall/mime/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			to_chat(usr, "<span class='notice'>You must dedicate yourself to silence first.</span>")
			return
		invocation = "<B>[usr.name]</B> looks as if a blockade is in front of [usr.p_them()]."
	else
		invocation_type ="none"
	..()

/datum/spell/mime/fingergun
	name = "Finger Gun"
	desc = "Shoot lethal, silencing bullets out of your fingers! 3 bullets available per cast. Use your fingers to holster them manually."
	clothes_req = FALSE
	base_cooldown = 30 SECONDS
	human_req = TRUE
	antimagic_flags = NONE

	action_icon_state = "fingergun"
	action_background_icon_state = "bg_mime"
	var/gun = /obj/item/gun/projectile/revolver/fingergun
	var/obj/item/gun/projectile/revolver/fingergun/current_gun

/datum/spell/mime/fingergun/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/human/C in targets)
		if(!current_gun)
			to_chat(user, "<span class='notice'>You draw your fingers!</span>")
			current_gun = new gun(get_turf(user), src)
			C.drop_item()
			C.put_in_hands(current_gun)
			RegisterSignal(C, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(holster_hand))
		else
			holster_hand(user, TRUE)
			revert_cast(user)


/datum/spell/mime/fingergun/Destroy()
	current_gun = null
	return ..()

/datum/spell/mime/fingergun/proc/holster_hand(atom/target, any=FALSE)
	SIGNAL_HANDLER
	if(!current_gun || !any && action.owner.get_active_hand() != current_gun)
		return
	to_chat(action.owner, "<span class='notice'>You holster your fingers. Another time perhaps...</span>")
	QDEL_NULL(current_gun)

/datum/spell/mime/fingergun/fake
	desc = "Pretend you're shooting bullets out of your fingers! 3 bullets available per cast. Use your fingers to holster them manually."
	gun = /obj/item/gun/projectile/revolver/fingergun/fake

// Mime Spellbooks

/obj/item/spellbook/oneuse/mime
	spell = /datum/spell/aoe/conjure/build/mime_wall
	spellname = "Invisible Wall"
	name = "Miming Manual : "
	desc = "It contains various pictures of mimes mid-performance, aswell as some illustrated tutorials."
	icon_state = "bookmime"

/obj/item/spellbook/oneuse/mime/attack_self__legacy__attackchain(mob/user)
	var/datum/spell/S = new spell
	for(var/datum/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == S.type)
			if(user.mind)
				to_chat(user, "<span class='notice'>You've already read this one.</span>")
			return
	if(used)
		recoil(user)
	else
		user.mind.AddSpell(S)
		to_chat(user, "<span class='notice'>You flip through the pages. Your understanding of the boundaries of reality increases. You can cast [spellname]!</span>")
		user.create_log(MISC_LOG, "learned the spell [spellname] ([S])")
		user.create_attack_log("<font color='orange'>[key_name(user)] learned the spell [spellname] ([S]).</font>")
		onlearned(user)

/obj/item/spellbook/oneuse/mime/recoil(mob/user)
	to_chat(user, "<span class='notice'>You flip through the pages. Nothing of interest to you.</span>")

/obj/item/spellbook/oneuse/mime/onlearned(mob/user)
	used = TRUE
	if(!locate(/datum/spell/mime/speak) in user.mind.spell_list) //add vow of silence if not known by user
		user.mind.AddSpell(new /datum/spell/mime/speak)
		to_chat(user, "<span class='notice'>You have learned how to use silence to improve your performance.</span>")

/obj/item/spellbook/oneuse/mime/fingergun
	spell = /datum/spell/mime/fingergun
	spellname = "Finger Gun"
	desc = "It contains illustrations of guns and how to mime them."

/obj/item/spellbook/oneuse/mime/fingergun/fake
	spell = /datum/spell/mime/fingergun/fake

/obj/item/spellbook/oneuse/mime/greaterwall
	spell = /datum/spell/forcewall/mime
	spellname = "Invisible Greater Wall"
	desc = "It contains illustrations of the great walls of human history."
