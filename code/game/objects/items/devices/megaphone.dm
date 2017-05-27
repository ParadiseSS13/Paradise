/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = 1
	flags = CONDUCT

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0
	var/list/insultmsg = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")

/obj/item/device/megaphone/attack_self(mob/living/user as mob)
	if(user.client && (user.client.prefs.muted & MUTE_IC))
		to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
		return
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You don't know how to use this!</span>")
		return
	if(!user.can_speak())
		to_chat(user, "<span class='warning'>You find yourself unable to speak at all.</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H && H.mind && H.mind.miming)
			to_chat(user, "<span class='warning'>Your vow of silence prevents you from speaking.</span>")
			return
	if(spamcheck)
		to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
		return

	var/message = input(user, "Shout a message:", "Megaphone") as text|null
	if(!message)
		return
	message = sanitize(copytext(message, 1, MAX_MESSAGE_LEN))
	if(!message)
		return
	message = capitalize(message)
	if((loc == user && !user.incapacitated()))
		if(emagged)
			if(insults)
				saymsg(user, pick(insultmsg))
				insults--
			else
				to_chat(user, "<span class='warning'>*BZZZZzzzzzt*</span>")
		else
			saymsg(user, message)

		spamcheck = 1
		spawn(20)
			spamcheck = 0

/obj/item/device/megaphone/proc/saymsg(mob/living/user as mob, message)
	audible_message("<span class='game say'><span class='name'>[user]</span> broadcasts, <span class='reallybig'>\"[message]\"</span></span>", hearing_distance = 14)
	for(var/obj/O in oview(14, get_turf(src)))
		O.hear_talk(user, "<span class='reallybig'>[message]</span>")

/obj/item/device/megaphone/emag_act(user as mob)
	if(!emagged)
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		emagged = 1
		insults = rand(1, 3)//to prevent dickflooding
