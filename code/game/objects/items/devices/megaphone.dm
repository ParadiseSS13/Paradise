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
	if(user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(src, "\red You cannot speak in IC (muted).")
			return
	if(!ishuman(user))
		to_chat(user, "\red You don't know how to use this!")
		return
	if(user.silent)
		to_chat(user, "<span class='warning'>You find yourself unable to speak at all.</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H && H.mind)
			if(H.mind.miming)
				to_chat(user, "<span class='warning'>Your vow of silence prevents you from speaking.</span>")
				return
	if(spamcheck)
		to_chat(user, "\red \The [src] needs to recharge!")
		return

	var/message = input(user, "Shout a message:", "Megaphone") as text|null
	if(!message)
		return
	message = sanitize(copytext(message, 1, MAX_MESSAGE_LEN))
	if(!message)
		return
	message = capitalize(message)
	if((src.loc == user && usr.stat == 0))
		if(emagged)
			if(insults)
				saymsg(user, pick(insultmsg))
				insults--
			else
				to_chat(user, "\red *BZZZZzzzzzt*")
		else
			saymsg(user, message)

		spamcheck = 1
		spawn(20)
			spamcheck = 0
		return

/obj/item/device/megaphone/proc/saymsg(mob/living/user as mob, message)
	audible_message("<span class='game say'><span class='name'>[user]</span> broadcasts, <FONT size=3>\"[message]\"</FONT></span>", hearing_distance = 14)
	for(var/obj/O in oview(14, get_turf(src)))
		O.hear_talk(user, "<FONT size=3>[message]</FONT>")

/obj/item/device/megaphone/emag_act(user as mob)
	if(!emagged)
		to_chat(user, "\red You overload \the [src]'s voice synthesizer.")
		emagged = 1
		insults = rand(1, 3)//to prevent dickflooding
