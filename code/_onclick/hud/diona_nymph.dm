/* Diony Nymph HUD */
/mob/living/simple_animal/diona/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/diona(src)

/datum/hud/diona/New()
	..()
	static_inventory += diona_button(new /obj/screen/diona/blood())
	static_inventory += diona_button(new /obj/screen/diona/merge())
	static_inventory += diona_button(new /obj/screen/diona/evolve())
	toggleable_inventory += new /obj/screen/diona/intent()

datum/hud/diona/proc/diona_button(var/obj/screen/diona/D)
	var/obj/screen/diona/button/B = new /obj/screen/diona/button
	B.overlays += D
	B.master = D
	B.screen_loc = D.screen_loc
	return B

/obj/screen/diona/button
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_default"

/obj/screen/diona/button/Click(location, control, params)
	return usr.client.Click(master, location, control, params)

/obj/screen/diona/intent
	name = "Intent"
	icon_state = "help"
	icon = 'icons/mob/screen_simplemob.dmi'	
	screen_loc = ui_acti

/obj/screen/diona/intent/Click()
	if(isnymph(usr))
		var/mob/living/simple_animal/diona/N = usr
		if(N.a_intent == INTENT_HELP) 
			N.a_intent = INTENT_HARM
		else
			N.a_intent = INTENT_HELP
		icon_state = N.a_intent

/obj/screen/diona/blood
	icon = 'icons/obj/bloodpack.dmi' //borrowing an icon
	icon_state = "full"
	name = "Steal blood"
	desc = "Take a blood sample from a suitable donor."
	screen_loc = ui_rhand

/obj/screen/diona/blood/Click()
	if(isnymph(usr))
		var/mob/living/simple_animal/diona/N = usr
		N.steal_blood()

/obj/screen/diona/merge
	icon = 'icons/mob/human_races/r_diona.dmi'  //borrowing an icon
	icon_state = "preview"
	name = "Merge with gestalt"
	desc = "Merge with another diona."
	screen_loc = ui_lhand

/obj/screen/diona/merge/Click()
	if(isnymph(usr))
		var/mob/living/simple_animal/diona/N = usr
		N.merge()	

/obj/screen/diona/evolve
	icon = 'icons/obj/cloning.dmi' //borrowing an icon
	icon_state = "pod_1"
	name = "Evolve"
	desc = "Grow to a more complex form."
	screen_loc = ui_storage1

/obj/screen/diona/evolve/Click()
	if(isnymph(usr))
		var/mob/living/simple_animal/diona/N = usr
		N.evolve()	


