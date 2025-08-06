/obj/item/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	inhand_icon_state = "paper"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 20
	origin_tech = "bluespace=6"
	resistance_flags = FLAMMABLE
	var/uses = 4

/obj/item/teleportation_scroll/apprentice
	name = "lesser scroll of teleportation"
	uses = 1
	origin_tech = "bluespace=5"

/obj/item/teleportation_scroll/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Number of uses: [uses]. This scroll will vanish after the final use.</span>"
	. += "<span class='notice'>P.S. Don't forget to bring your gear, you'll need it to cast most spells.</span>"

/obj/item/teleportation_scroll/attack_self__legacy__attackchain(mob/living/user)
	if(!uses) //somehow?
		to_chat(user, "<span class='warning'>You attempt to read the scroll but it disintegrates in your hand, it appears that is has run out of charges!</span>")
		qdel(src)
		return

	var/picked_area
	picked_area = tgui_input_list(user, "Area to jump to", "Teleport where?", SSmapping.teleportlocs)
	if(!picked_area)
		return

	var/area/thearea = SSmapping.teleportlocs[picked_area]
	if(user.stat || user.restrained())
		return

	if(!(user == loc || (in_range(src, user) && isturf(user.loc))))
		return //They can't use it if they put it in their bag or drop it and walk off, but if they are stood next to it they can.

	if(thearea.tele_proof && !istype(thearea, /area/wizard_station)) //Nowhere in SSmapping.teleportlocs should be tele_proof, but better safe than sorry
		to_chat(user, "<span class='warning'>A mysterious force disrupts your arcane spell matrix, and you remain where you are.</span>")
		return

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(5, FALSE, get_turf(user))
	smoke.attach(user)
	smoke.start()
	var/list/L = list()

	for(var/turf/T in get_area_turfs(thearea.type))
		if(T.is_blocked_turf())
			continue
		L.Add(T)

	if(!length(L))
		to_chat(user, "<span class='warning'>The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.</span>")
		return

	if(user && user.buckled)
		user.unbuckle(force = TRUE)

	if(user?.has_buckled_mobs())
		user.unbuckle_all_mobs(force = TRUE)

	user.forceMove(pick(L))
	smoke.start()
	uses--

	if(!uses)
		to_chat(user, "<span class='warning'>The scroll fizzles out of existence as the last of the magic within fades.</span>")
		qdel(src)

	user.update_action_buttons_icon()  //Update action buttons as some spells might now be castable
