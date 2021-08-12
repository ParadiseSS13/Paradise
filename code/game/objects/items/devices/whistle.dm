
#define USE_COOLDOWN 2 SECONDS

/obj/item/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon = 'icons/obj/device.dmi'
	icon_state = "voice0"
	item_state = "flashtool"	//looks exactly like a flash (and nothing like a flashbang)
	w_class = WEIGHT_CLASS_TINY
	flags = CONDUCT
	var/spamcheck = 0
	COOLDOWN_DECLARE(halt_cooldown)

/obj/item/hailer/attack_self(mob/living/carbon/user as mob)
	if(!COOLDOWN_FINISHED(src, halt_cooldown))
		return

	COOLDOWN_START(src, halt_cooldown, USE_COOLDOWN)

	if(emagged)
		playsound(get_turf(src), 'sound/voice/binsult.ogg', 100, 1, vary = 0)//hueheuheuheuheuheuhe
		user.visible_message("<span class='warning'>[user]'s [name] gurgles, \"FUCK YOUR CUNT YOU SHIT EATING CUNT TILL YOU ARE A MASS EATING SHIT CUNT. EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS TO FUCK UP SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FROM THE DEPTHS OF SHIT\"</span>")
	else
		playsound(get_turf(src), 'sound/voice/halt.ogg', 100, 1, vary = 0)
		user.visible_message("<span class='warning'>[user]'s [name] rasps, \"Halt! Security!\"</span>")

/obj/item/hailer/emag_act(user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		emagged = 1

#undef USE_COOLDOWN
