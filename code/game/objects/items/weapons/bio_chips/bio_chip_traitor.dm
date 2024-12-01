/obj/item/bio_chip/traitor
	name = "Mindslave Bio-chip"
	desc = "Divide and Conquer!"
	origin_tech = "programming=5;biotech=5;syndicate=8"
	activated = FALSE
	implant_data = /datum/implant_fluff/traitor
	implant_state = "implant-syndicate"

	/// The UID of the mindslave's `mind`. Stored to solve GC race conditions and ensure we can remove their mindslave status even when they're deleted or gibbed.
	var/mindslave_UID

/obj/item/bio_chip/traitor/implant(mob/living/carbon/human/mindslave_target, mob/living/carbon/human/user)
	// Check `activated` here so you can't just keep taking it out and putting it back into other people.
	if(activated || !istype(mindslave_target) || !istype(user)) // Both the target and the user need to be human.
		return FALSE

	// If the target is catatonic or doesn't have a mind, return.
	if(!mindslave_target.mind)
		to_chat(user, "<span class='warning'><i>This person doesn't have a mind for you to slave!</i></span>")
		return FALSE

	// Fails if they're already a mindslave of someone, or if they're mindshielded.
	if(IS_MINDSLAVE(mindslave_target) || ismindshielded(mindslave_target))
		mindslave_target.visible_message(
			"<span class='warning'>[mindslave_target] seems to resist the bio-chip!</span>", \
			"<span class='warning'>You feel a strange sensation in your head that quickly dissipates.</span>")
		qdel(src)
		return FALSE

	// Mindslaving yourself.
	if(mindslave_target == user)
		to_chat(user, "<span class='notice'>Making yourself loyal to yourself was a great idea! Perhaps even the best idea ever! Actually, you just feel like an idiot.</span>")
		user.adjustBrainLoss(20)
		qdel(src)
		return FALSE

	// Create a new mindslave datum for the target with the user as their master.
	mindslave_target.mind.add_antag_datum(new /datum/antagonist/mindslave/implant(user.mind))
	mindslave_UID = mindslave_target.mind.UID()
	log_admin("[key_name_admin(user)] has mind-slaved [key_name_admin(mindslave_target)].")
	return ..()

/obj/item/bio_chip/traitor/removed(mob/target)
	. = ..()
	var/datum/mind/M = locateUID(mindslave_UID)
	M.remove_antag_datum(/datum/antagonist/mindslave/implant)

/obj/item/bio_chip_implanter/traitor
	name = "bio-chip implanter (Mindslave)"
	implant_type = /obj/item/bio_chip/traitor

/obj/item/bio_chip_case/traitor
	name = "bio-chip case - 'Mindslave'"
	desc = "A glass case containing a mindslave bio-chip."
	implant_type = /obj/item/bio_chip/traitor
