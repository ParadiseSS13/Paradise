/obj/item/implant/traitor
	name = "Mindslave Implant"
	desc = "Divide and Conquer"
	origin_tech = "programming=5;biotech=5;syndicate=8"
	activated = 0

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

/obj/item/implant/traitor/implant(mob/M, mob/user)
	if(!M.mind)  // If the target is catatonic or doesn't have a mind, don't let them use it
		to_chat(user, "<span class='warning'><i>This person doesn't have a mind for you to slave!</i></span>")
		return 0

	if(!activated) //So you can't just keep taking it out and putting it back into other people.
		var/mob/living/carbon/human/mindslave_target = M
		if(ismindslave(mindslave_target))
			mindslave_target.visible_message("<span class='warning'>[mindslave_target] seems to resist the implant!</span>", "<span class='warning'>You feel a strange sensation in your head that quickly dissipates.</span>")
			qdel(src)
			return -1
		if(..())
			var/list/implanters
			if(!ishuman(mindslave_target))
				return 0
			if(!mindslave_target.mind)
				return 0
			if(mindslave_target == user)
				to_chat(user, "<span class='notice'>Making yourself loyal to yourself was a great idea! Perhaps even the best idea ever! Actually, you just feel like an idiot.</span>")
				if(isliving(user))
					var/mob/living/L = user
					L.adjustBrainLoss(20)
				removed(mindslave_target)
				qdel(src)
				return -1	
			if(ismindshielded(mindslave_target))
				mindslave_target.visible_message("<span class='warning'>[mindslave_target] seems to resist the implant!</span>", "<span class='warning'>You feel a strange sensation in your head that quickly dissipates.</span>")
				removed(mindslave_target)
				qdel(src)
				return -1

			mindslave_target.implanting = 1
			to_chat(mindslave_target, "<span class='danger'>You feel completely loyal to [user.name].</span>")
			if(!(user.mind in SSticker.mode.implanter))
				SSticker.mode.implanter[user.mind] = list()
			implanters = SSticker.mode.implanter[user.mind]
			implanters.Add(mindslave_target.mind)
			SSticker.mode.implanted.Add(mindslave_target.mind)
			SSticker.mode.implanted[mindslave_target.mind] = user.mind
			SSticker.mode.implanter[user.mind] = implanters
			
			to_chat(mindslave_target, "<span class='danger'><B>You're now completely loyal to [user.name]!</B> You now must lay down your life to protect [user.p_them()] and assist in [user.p_their()] goals at any cost.</span>")

			var/datum/objective/protect/mindslave/MS = new
			MS.owner = mindslave_target.mind
			MS.target = user.mind
			MS.explanation_text = "Obey every order from and protect [user.real_name], the [user.mind.assigned_role == user.mind.special_role ? (user.mind.special_role) : (user.mind.assigned_role)]."
			mindslave_target.mind.objectives += MS
			mindslave_target.mind.add_antag_datum(/datum/antagonist/mindslave)

			var/datum/mindslaves/slaved = user.mind.som
			mindslave_target.mind.som = slaved
			slaved.serv += mindslave_target
			slaved.add_serv_hud(user.mind, "master") //handles master servent icons
			slaved.add_serv_hud(mindslave_target.mind, "mindslave")

			log_admin("[key_name(user)] has mind-slaved [key_name(mindslave_target)].")
			activated = 1
			if(jobban_isbanned(M, ROLE_SYNDICATE))
				SSticker.mode.replace_jobbanned_player(M, ROLE_SYNDICATE)
			return 1
		return 0

/obj/item/implant/traitor/removed(mob/target)
	if(..())
		target.mind.remove_antag_datum(/datum/antagonist/mindslave)
		to_chat(target, "<span class='warning'>You are no longer a mindslave: you have complete and free control of your own faculties, once more!</span>")
		return 1
	return 0
