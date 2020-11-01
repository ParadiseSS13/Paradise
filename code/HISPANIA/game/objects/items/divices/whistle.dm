/obj/item/whistle
	name = "\improper whistle"
	desc = "A metal pea-whistle, can be blown while held."
	icon = 'icons/hispania/obj/tools.dmi'
	item_state = "whistle"
	icon_state = "whistle"
	w_class = WEIGHT_CLASS_TINY
	flags = CONDUCT
	var/spamcheck = FALSE

/obj/item/whistle/attack_self(mob/user)
	whistle_playsound(user)

//Funcion de whistle
/obj/item/whistle/proc/whistle_playsound(mob/user)
	if(spamcheck)
		to_chat(user, "<span class='notice'>You are out of breath wait a moment.</span>")
		return
	user.visible_message("<span class='danger'>[user] blows into [src]!</span>")
	playsound(get_turf(src), 'sound/hispania/effects/whistle.ogg', 100, 1, vary = 0)  //Volumen alto
	spamcheck = TRUE
	addtimer(VARSET_CALLBACK(src, spamcheck, FALSE), 10 SECONDS)
