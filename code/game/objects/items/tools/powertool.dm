//Power Tools
/obj/item/powertool
	var/stateswap = 0 //what state is it in
	var/icon_state_swap = 0 //which icon should it be
	var/tool_behaviour_swap = 0 //what tool behaviour(s) should be here
	var/swapsound = 0 //the sound that plays for swapping

/obj/item/powertool/attack_self(mob/living/carbon/user) //activating the item causes it to swap icons and behaviours
	stateswap = !stateswap
	if(stateswap)
		icon_state = icon_state_swap
		tool_behaviour = tool_behaviour_swap
	else
		icon_state = initial(icon_state)
		tool_behaviour = initial(tool_behaviour)
	playsound(get_turf(user), swapsound, 50, 1)
	to_chat(user, "<span class='notice'>You attach a different bit to [src].</span>")
	return
		
/obj/item/powertool/drill
	name = "Power Drill"
	desc = "A simple hand drill with bolt and screw bits."
	icon = 'icons/obj/tools.dmi'
	icon_state = "drill_screw"
	item_state = "drill"
	icon_state_swap = "drill_bolt"
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	swapsound = 'sound/items/change_drill.ogg'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "engineering=1;combat=1"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	toolspeed = 0.25
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	tool_behaviour = TOOL_SCREWDRIVER
	tool_behaviour_swap = TOOL_WRENCH

/obj/item/powertool/drill/suicide_act(mob/user)
	if(tool_behaviour == TOOL_WRENCH)
		user.visible_message("<span class='suicide'>[user] is pressing [src] against [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!")
	else
		user.visible_message("<span class='suicide'>[user] is putting [src] to [user.p_their()] temple. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/powertool/powerjaws
	name = "jaws of life"
	desc = "A set of jaws of life, the magic of science has managed to fit it down into a device small enough to fit in a tool belt. has prying and cutting attachments."
	icon = 'icons/obj/tools.dmi'
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	icon_state_swap = "jaws_cutter"
	usesound = 'sound/items/jaws_pry.ogg'
	swapsound = 'sound/items/change_jaws.ogg'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 15
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	toolspeed = 0.25
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	tool_behaviour = TOOL_CROWBAR
	tool_behaviour_swap = TOOL_WIRECUTTER
	var/airlock_open_time = 100 // Time required to open powered airlocks

/obj/item/powertool/powerjaws/suicide_act(mob/user)
	if(tool_behaviour == TOOL_WIRECUTTER)
		user.visible_message("<span class='suicide'>[user] is wrapping \the [src] around [user.p_their()] neck. It looks like [user.p_theyre()] trying to rip [user.p_their()] head off!</span>")
		playsound(loc, 'sound/items/jaws_cut.ogg', 50, 1, -1)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/obj/item/organ/external/head/head = H.bodyparts_by_name["head"]
			if(head)
				head.droplimb(0, DROPLIMB_BLUNT, FALSE, TRUE)
				playsound(loc,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
	else
		user.visible_message("<span class='suicide'>[user] is putting [user.p_their()] head in [src]. It looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(loc, 'sound/items/jaws_pry.ogg', 50, 1, -1)
	return BRUTELOSS