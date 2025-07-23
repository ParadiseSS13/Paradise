/datum/deathrattle_group
	var/name
	var/list/implants = list()

/datum/deathrattle_group/New(name)
	if(name)
		src.name = name
	else
		// Give the group a unique name for debugging, and possible future
		// use for making custom linked groups.
		src.name = "[rand(100, 999)] [pick(GLOB.phonetic_alphabet)]"

/*
 * Proc called by new implant being added to the group. Listens for the
 * implant being implanted, removed and destroyed.
 *
 * If implant is already implanted in a person, then trigger the implantation
 * code.
 */
/datum/deathrattle_group/proc/register(obj/item/bio_chip/deathrattle/implant)
	if(implant in implants)
		return
	RegisterSignal(implant, COMSIG_PARENT_QDELETING, PROC_REF(on_implant_destruction))
	RegisterSignal(implant, COMSIG_IMPLANT_ACTIVATED, PROC_REF(on_user_death))

	implants += implant


/datum/deathrattle_group/proc/on_implant_destruction(obj/item/bio_chip/implant)
	SIGNAL_HANDLER

	implants -= implant

/datum/deathrattle_group/proc/on_user_death(obj/item/bio_chip/implant, source, mob/owner)
	SIGNAL_HANDLER
	var/victim_name = owner.mind ? owner.mind.name : owner.real_name
	// All "hearers" hear the same sound.
	var/sound = pick(
		'sound/items/knell1.ogg',
		'sound/items/knell2.ogg',
		'sound/items/knell3.ogg',
		'sound/items/knell4.ogg',
	)


	for(var/obj/item/bio_chip/deathrattle/other_implant as anything in implants)

		// Skip the unfortunate soul, and any unimplanted implants
		if(implant == other_implant || !implant.imp_in)
			continue

		var/mob/living/recipient = other_implant.imp_in
		to_chat(recipient, "<i>You hear a strange, robotic voice in your head...</i> <span class='robot'>\"<b>[victim_name]</b> has died...\"</span>")
		recipient.playsound_local(get_turf(recipient), sound, vol = 75, vary = FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	qdel(implant)

/obj/item/bio_chip/deathrattle
	name = "deathrattle implant"
	desc = "Hope no one else dies, prepare for when they do."
	activated = BIOCHIP_ACTIVATED_PASSIVE
	trigger_causes = BIOCHIP_TRIGGER_DEATH_ONCE
	implant_data = /datum/implant_fluff/deathrattle
	implant_state = "implant-nanotrasen"

	actions_types = null

/obj/item/bio_chip/deathrattle/emp_act(severity)
	activate("emp")

/obj/item/bio_chip/deathrattle/death_trigger(mob/source, gibbed)
	activate("death")

/obj/item/bio_chip_case/deathrattle
	name = "implant case - 'Deathrattle'"
	desc = "A glass case containing a deathrattle implant."
	implant_type = /obj/item/bio_chip/deathrattle
