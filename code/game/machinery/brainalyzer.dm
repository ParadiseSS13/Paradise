/obj/machinery/brainalyzer
	name = "brainalyzer"
	desc = "A child of Nanotrasen's best minds, designed to both swiftly analyze and determine the mental status of a patient, while also removing the need for a company doctor to be on site and save the company money. Ain't progress grand?"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "brainscanner-open"
	density = TRUE
	dir = WEST
	anchored = TRUE
	idle_power_consumption = 1250
	active_power_consumption = 2500
	light_color = "#00FF00"
	var/mob/living/carbon/human/occupant
	/// One of the results the scanner can give you
	var/list/brain_scan_sounds = list('sound/machines/Brainalyzer_01.ogg',
									'sound/machines/Brainalyzer_02.ogg',
									'sound/machines/Brainalyzer_03.ogg',
									'sound/machines/Brainalyzer_04.ogg',
									'sound/machines/Brainalyzer_05.ogg',
									'sound/machines/Brainalyzer_06.ogg',
									'sound/machines/Brainalyzer_07.ogg',
									'sound/machines/Brainalyzer_08.ogg',
									'sound/machines/Brainalyzer_09.ogg',
									'sound/machines/Brainalyzer_10.ogg',
									'sound/machines/Brainalyzer_11.ogg'
									)
	// Keep the patient stuck inside the scanner while the sound plays
	COOLDOWN_DECLARE(scan_time)
	// To stop people from keeping others stuck in it by repeating scans
	COOLDOWN_DECLARE(spam_protection)

/obj/machinery/brainalyzer/examine(mob/user)
	. = ..()
	if(occupant)
		. += "<span class='notice'>You see [occupant.name] inside.</span>"
	if(Adjacent(user))
		. += "<span class='notice'>You can <b>Alt-Click</b> to eject the current occupant. <b>Click-drag</b> someone to the brainalyzer to place them inside.</span>"

/obj/machinery/brainalyzer/Destroy()
	go_out()
	return ..()

/obj/machinery/brainalyzer/power_change()
	if(!..())
		return
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/brainalyzer/process()
	for(var/mob/M as mob in src) // makes sure that simple mobs don't get stuck inside a sleeper when they resist out of occupant's grasp
		if(M == occupant)
			continue
		else
			M.forceMove(loc)

/obj/machinery/brainalyzer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/TYPECAST_YOUR_SHIT = I
		if(!ishuman(TYPECAST_YOUR_SHIT.affecting))
			return
		if(occupant)
			to_chat(user, "<span class='notice'>The brainalyzer is already occupied!</span>")
			return
		if(TYPECAST_YOUR_SHIT.affecting.has_buckled_mobs()) //mob attached to us
			to_chat(user, "<span class='warning'>[TYPECAST_YOUR_SHIT.affecting] will not fit into [src] because [TYPECAST_YOUR_SHIT.affecting.p_they()] [TYPECAST_YOUR_SHIT.affecting.p_have()] a fucking slime latched onto [TYPECAST_YOUR_SHIT.affecting.p_their()] head.</span>")
			return
		var/mob/living/carbon/human/M = TYPECAST_YOUR_SHIT.affecting
		if(M.abiotic())
			to_chat(user, "<span class='notice'>Subject may not hold anything in their hands.</span>")
			return
		M.forceMove(src)
		occupant = M
		playsound(src, 'sound/machines/podclose.ogg', 5)
		update_icon(UPDATE_ICON_STATE)
		add_fingerprint(user)
		qdel(TYPECAST_YOUR_SHIT)
		return

	return ..()

/obj/machinery/brainalyzer/MouseDrop_T(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return FALSE //not human
	if(user.incapacitated())
		return FALSE //user shouldn't be doing things
	if(H.anchored)
		return FALSE //mob is anchored???
	if(get_dist(user, src) > 1 || get_dist(user, H) > 1)
		return FALSE //doesn't use adjacent() to allow for non-cardinal (fuck my life)
	if(!ishuman(user) && !isrobot(user))
		return FALSE //not a borg or human
	if(occupant)
		to_chat(user, "<span class='notice'>[src] is already occupied.</span>")
		return TRUE //occupied
	if(H.buckled)
		return FALSE
	if(H.abiotic())
		to_chat(user, "<span class='notice'>Subject may not hold anything in their hands.</span>")
		return TRUE
	if(H.has_buckled_mobs()) //mob attached to us
		to_chat(user, "<span class='warning'>[H] will not fit into [src] because [H.p_they()] [H.p_have()] a slime latched onto [H.p_their()] head.</span>")
		return TRUE

	if(H == user)
		visible_message("[user] climbs into the brainalyzer.")
	else
		visible_message("[user] puts [H] into [src].")

	QDEL_LIST_CONTENTS(H.grabbed_by)
	H.forceMove(src)
	occupant = H
	playsound(src, 'sound/machines/podclose.ogg', 5)
	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(user)
	return TRUE

/obj/machinery/brainalyzer/relaymove(mob/user)
	if(user.incapacitated())
		return FALSE //maybe they should be able to get out with cuffs, but whatever
	go_out()

/obj/machinery/brainalyzer/AltClick(mob/user)
	if(issilicon(user))
		eject()
		return
	if(!Adjacent(user) || !ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	eject()

/obj/machinery/brainalyzer/proc/eject(mob/user)
	go_out()
	add_fingerprint(user)

/obj/machinery/brainalyzer/force_eject_occupant(mob/target)
	go_out()

/obj/machinery/brainalyzer/ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)
	return ..()

/obj/machinery/brainalyzer/handle_atom_del(atom/A)
	..()
	if(A == occupant)
		occupant = null
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/brainalyzer/update_icon_state()
	if(occupant)
		icon_state = "brainscanner"
	else
		icon_state = "brainscanner-open"

/obj/machinery/brainalyzer/attack_hand(user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!occupant)
		to_chat(user, "<span class='notice'>Insert the patient before initiating a brain scan.</span>")
		return

	if(occupant == user)
		return // you cant reach that

	if(!COOLDOWN_FINISHED(src, spam_protection))
		to_chat(user, "<span class='notice'>The brain scanner electronics are too hot, please wait.</span>")
		return

	psych_scan()

/obj/machinery/brainalyzer/proc/psych_scan()
	playsound(src, pick(brain_scan_sounds), 30)
	COOLDOWN_START(src, spam_protection, 20 SECONDS)
	COOLDOWN_START(src, scan_time, 8 SECONDS)

/obj/machinery/brainalyzer/proc/go_out()
	if(!COOLDOWN_FINISHED(src, scan_time))
		atom_say("Wait until the scan is over to leave.")
		return
	if(!occupant)
		return
	occupant.forceMove(loc)
	occupant = null
	playsound(src, 'sound/machines/podopen.ogg', 5)
	update_icon(UPDATE_ICON_STATE)
	// eject trash the occupant dropped
	for(var/atom/movable/A in contents - component_parts)
		A.forceMove(loc)
