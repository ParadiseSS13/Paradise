/obj/item/implant/traitor
	name = "Mindslave Implant"
	desc = "Divide and Conquer"
	origin_tech = "programming=5;biotech=5;syndicate=8"
	activated = FALSE

/obj/item/implant/traitor/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Mind-Slave Implant<BR>
				<b>Life:</b> ??? <BR>
				<b>Important Notes:</b> Any humanoid injected with this implant will become loyal to the injector, unless of course the host is already loyal to someone else.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
				<b>Special Features:</b> Diplomacy was never so easy.<BR>
				<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat

/obj/item/implant/traitor/implant(mob/living/carbon/human/mindslave_target, mob/living/carbon/human/user)
	// Check `activated` here so you can't just keep taking it out and putting it back into other people.
	if(!..() || activated || !istype(mindslave_target) || !istype(user)) // Both the target and the user need to be human.
		return FALSE

	// If the target is catatonic or doesn't have a mind, return.
	if(!mindslave_target.mind)
		to_chat(user, "<span class='warning'><i>This person doesn't have a mind for you to slave!</i></span>")
		return FALSE

	// Fails if they're already a mindslave of someone, or if they're mindshielded.
	if(ismindslave(mindslave_target) || ismindshielded(mindslave_target))
		mindslave_target.visible_message(
			"<span class='warning'>[mindslave_target] seems to resist the implant!</span>", \
			"<span class='warning'>You feel a strange sensation in your head that quickly dissipates.</span>")
		removed(mindslave_target)
		qdel(src)
		return FALSE

	// Mindslaving yourself.
	if(mindslave_target == user)
		to_chat(user, "<span class='notice'>Making yourself loyal to yourself was a great idea! Perhaps even the best idea ever! Actually, you just feel like an idiot.</span>")
		user.adjustBrainLoss(20)
		removed(mindslave_target)
		qdel(src)
		return FALSE

	// Create a new mindslave datum for the target with the user as their master.
	mindslave_target.mind.add_antag_datum(new /datum/antagonist/mindslave(user.mind))
	log_admin("[key_name_admin(user)] has mind-slaved [key_name_admin(mindslave_target)].")
	return TRUE

/obj/item/implant/traitor/removed(mob/target)
	if(..())
		target.mind.remove_antag_datum(/datum/antagonist/mindslave)
		return TRUE
	return FALSE
