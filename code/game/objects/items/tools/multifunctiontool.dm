//Multifunction tools
/obj/item/multifunctiontool
	var/list/tool_icon_states = list() //which icon should it be
	var/list/tool_behaviours = list()  //what tool behaviour(s) should be here
	var/list/tool_mode_names = list() //text added to the examine description
	var/active_behaviour_index = 1
	var/swapsound //the sound that plays for swapping

/obj/item/multifunctiontool/attack_self(mob/living/carbon/user) //activating the item causes it to swap icons and behaviours
	if(tool_behaviours.len > 1)
		select_mode(user)
	tool_behaviour = tool_behaviours[active_behaviour_index]
	icon_state = tool_icon_states[active_behaviour_index]
	playsound(get_turf(user), swapsound, 50, 1)
	to_chat(user, "<span class='notice'>You use a different part on [src].</span>")

/obj/item/multifunctiontool/proc/select_mode(mob/living/user)
	active_behaviour_index++
	if(active_behaviour_index > tool_behaviours.len)
		active_behaviour_index = 1
	return

/obj/item/multifunctiontool/examine(mob/user)
	. = ..()
	. += "[tool_mode_names[active_behaviour_index]]"
		
//Tools		
/obj/item/multifunctiontool/drill
	name = "Power Drill"
	desc = "A simple hand drill with bolt and screw bits."
	icon = 'icons/obj/tools.dmi'
	icon_state = "drill_screw"
	item_state = "drill"
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 8
	throwforce = 8
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=150, MAT_SILVER=50, MAT_TITANIUM=25)
	origin_tech = "engineering=2;combat=2"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	toolspeed = 0.25
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	tool_behaviour = TOOL_SCREWDRIVER
	tool_behaviours = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	tool_icon_states = list("drill_screw", "drill_bolt")
	tool_mode_names = list("Screwdriver bit attached", "Bolt bit attached")
	swapsound = 'sound/items/change_drill.ogg'

/obj/item/multifunctiontool/drill/suicide_act(mob/user)
	if(tool_behaviour == TOOL_WRENCH)
		user.visible_message("<span class='suicide'>[user] is pressing [src] against [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!")
	else
		user.visible_message("<span class='suicide'>[user] is putting [src] to [user.p_their()] temple. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/multifunctiontool/powerjaws
	name = "jaws of life"
	desc = "A set of jaws of life, the magic of science has managed to fit it down into a device small enough to fit in a tool belt. has prying and cutting attachments."
	icon = 'icons/obj/tools.dmi'
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	usesound = 'sound/items/jaws_pry.ogg'
	swapsound = 'sound/items/change_jaws.ogg'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 15
	throwforce = 7
	throw_speed = 2
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=150, MAT_SILVER=50, MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	toolspeed = 0.25
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	tool_behaviour = TOOL_CROWBAR
	tool_behaviours = list(TOOL_CROWBAR, TOOL_WIRECUTTER)
	tool_icon_states = list("jaws_pry", "jaws_cutter")
	tool_mode_names = list("Pry jaws attached", "Cutting jaws attached")

/obj/item/multifunctiontool/powerjaws/suicide_act(mob/user)
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
	