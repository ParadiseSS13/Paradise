/datum/hud/guardian/New(mob/owner)
	..()
	var/atom/movable/screen/using

	guardianhealthdisplay = new /atom/movable/screen/healths/guardian()
	infodisplay += guardianhealthdisplay

	using = new /atom/movable/screen/act_intent/guardian()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	using = new /atom/movable/screen/guardian/manifest()
	using.screen_loc = UI_RHAND
	static_inventory += using

	using = new /atom/movable/screen/guardian/recall()
	using.screen_loc = UI_LHAND
	static_inventory += using

	using = new /atom/movable/screen/guardian/toggle_mode()
	using.screen_loc = UI_STORAGE1
	static_inventory += using

	using = new /atom/movable/screen/guardian/toggle_light()
	using.screen_loc = UI_INVENTORY
	static_inventory += using

	using = new /atom/movable/screen/guardian/communicate()
	using.screen_loc = UI_BACK
	static_inventory += using


//HUD BUTTONS

/atom/movable/screen/guardian
	icon = 'icons/mob/guardian.dmi'
	icon_state = "base"

/atom/movable/screen/guardian/manifest
	icon_state = "manifest"
	name = "Manifest"
	desc = "Spring forth into battle!"

/atom/movable/screen/guardian/manifest/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		var/summoner_loc = G.summoner.loc
		if(istype(summoner_loc, /obj/machinery/atmospherics))
			to_chat(G, "<span class='warning'>You can not manifest while in these pipes!</span>")
			return
		if(istype(summoner_loc, /obj/structure/closet/cardboard/agent))
			to_chat(G, "<span class='warning'>You can not manifest while inside an active Stealth Implant!</span>")
			return
		if(G.loc == G.summoner)
			G.Manifest()

/atom/movable/screen/guardian/recall
	icon_state = "recall"
	name = "Recall"
	desc = "Return to your user."

/atom/movable/screen/guardian/recall/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Recall()

/atom/movable/screen/guardian/toggle_mode
	icon_state = "toggle"
	name = "Toggle Mode"
	desc = "Switch between ability modes."

/atom/movable/screen/guardian/toggle_mode/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleMode()

/atom/movable/screen/guardian/communicate
	icon_state = "communicate"
	name = "Communicate"
	desc = "Communicate telepathically with your user."

/atom/movable/screen/guardian/communicate/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Communicate()


/atom/movable/screen/guardian/toggle_light
	icon_state = "light"
	name = "Toggle Light"
	desc = "Glow like star dust."

/atom/movable/screen/guardian/toggle_light/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleLight()
