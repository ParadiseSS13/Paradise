/obj/item/bio_chip/death_alarm
	name = "death alarm bio-chip"
	desc = "An alarm which monitors host vital signs and transmits a radio message upon death."
	activated = BIOCHIP_ACTIVATED_PASSIVE
	trigger_causes = BIOCHIP_TRIGGER_DEATH_ANY
	implant_data = /datum/implant_fluff/death_alarm
	implant_state = "implant-nanotrasen"

	var/mobname = "Unknown"
	var/static/list/stealth_areas = typecacheof(list(/area/syndicate_mothership, /area/shuttle/syndicate_elite))
	/// Tracking to prevent multiple EMPs in the same tick from flooding radio.
	COOLDOWN_DECLARE(emp_spam_lock)

/obj/item/bio_chip/death_alarm/implant(mob/target)
	. = ..()
	if(.)
		mobname = target.real_name

/obj/item/bio_chip/death_alarm/activate(cause) // Death signal sends name followed by the gibbed / not gibbed check
	var/mob/M = imp_in
	var/area/t = get_area(M)

	var/obj/item/radio/headset/a = new /obj/item/radio/headset(src)
	a.follow_target = M

	switch(cause)
		if("gib")
			a.autosay("[mobname] has died-zzzzt in-in-in...", "[mobname]'s Death Alarm")
			qdel(src)
		if("emp")
			if(!COOLDOWN_FINISHED(src, emp_spam_lock))
				return
			var/name = prob(50) ? t.name : pick(SSmapping.teleportlocs)
			a.autosay("[mobname] has died in [name]!", "[mobname]'s Death Alarm")
			COOLDOWN_START(src, emp_spam_lock, 0.1 SECONDS)
		else
			if(is_type_in_typecache(t, stealth_areas))
				//give the syndies a bit of stealth
				a.autosay("[mobname] has died in Space!", "[mobname]'s Death Alarm")
			else
				a.autosay("[mobname] has died in [t.name]!", "[mobname]'s Death Alarm")
			qdel(src)

	qdel(a)

/obj/item/bio_chip/death_alarm/emp_act(severity)			//for some reason alarms stop going off in case they are emp'd, even without this
	activate("emp")	//let's shout that this dude is dead

/obj/item/bio_chip/death_alarm/death_trigger(mob/source, gibbed)
	if(gibbed)
		activate("gib")
	else
		activate("death")

/obj/item/bio_chip/death_alarm/removed(mob/target)
	if(..())
		UnregisterSignal(target, COMSIG_MOB_DEATH)
		return TRUE
	return FALSE

/obj/item/bio_chip_implanter/death_alarm
	name = "bio-chip implanter (Death Alarm)"
	implant_type = /obj/item/bio_chip/death_alarm

/obj/item/bio_chip_case/death_alarm
	name = "bio-chip Case - 'Death Alarm'"
	desc = "A case containing a death alarm bio-chip."
	implant_type = /obj/item/bio_chip/death_alarm
