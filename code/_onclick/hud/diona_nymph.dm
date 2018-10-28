/* Diony Nymph HUD */
/mob/living/simple_animal/diona/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/diona(src)

/datum/hud/diona/New()
	..()
	var/obj/screen/diona/blood = new /obj/screen/diona/blood()
	var/obj/screen/diona/merge = new /obj/screen/diona/merge()
	var/obj/screen/diona/evolve = new /obj/screen/diona/evolve()
	var/obj/screen/diona/intent = new /obj/screen/diona/intent()
	static_inventory += blood
	static_inventory += merge
	static_inventory += evolve
	toggleable_inventory += intent

/obj/screen/diona/intent
	name = "Intent"
	icon_state = "help"
	icon = 'icons/mob/screen_simplemob.dmi'	
	screen_loc = ui_acti

/obj/screen/diona/intent/Click()
	if(isnymph(usr))
		var/mob/living/simple_animal/diona/N = usr
		if(N.a_intent == "help") 
			N.a_intent = "harm"
		else
			N.a_intent = "help"
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


