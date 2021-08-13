/obj/item/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon = 'icons/obj/device.dmi'
	icon_state = "voice0"
	item_state = "flashtool"	//looks exactly like a flash (and nothing like a flashbang)
	w_class = WEIGHT_CLASS_TINY
	flags = CONDUCT
	/// How long between each 'halt' sound.
	var/halt_cooldown_time = 2 SECONDS
	/// Cooldown timer for the 'halt' sound.
	COOLDOWN_DECLARE(halt_cooldown)

/obj/item/hailer/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, halt_cooldown))
		return

	COOLDOWN_START(src, halt_cooldown, halt_cooldown_time)

	if(emagged)
		playsound(get_turf(src), 'sound/voice/binsult.ogg', 100)//hueheuheuheuheuheuhe
		user.visible_message("<span class='warning'>[user]'s [name] gurgles, \"FUCK YOUR CUNT YOU SHIT EATING CUNT TILL YOU ARE A MASS EATING SHIT CUNT. EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS TO FUCK UP SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FROM THE DEPTHS OF SHIT\"</span>")
	else
		playsound(get_turf(src), 'sound/voice/halt.ogg', 100)
		user.visible_message("<span class='warning'>[user]'s [name] rasps, \"Halt! Security!\"</span>")

/obj/item/hailer/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You overload [src]'s voice synthesizer.</span>")
		emagged = TRUE
