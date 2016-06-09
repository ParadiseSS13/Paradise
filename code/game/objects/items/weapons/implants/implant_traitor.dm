/obj/item/weapon/implant/traitor
	name = "Mindslave Implant"
	desc = "Divide and Conquer"
	origin_tech = "programming=5;biotech=5;syndicate=8"
	activated = 0

/obj/item/weapon/implant/traitor/get_data()
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

/obj/item/weapon/implant/traitor/implant(mob/M, mob/user)
	if(!activated) //So you can't just keep taking it out and putting it back into other people.
		var/mob/living/carbon/human/H = M
		if(ismindslave(H))
			H.visible_message("<span class='warning'>[H] seems to resist the implant!</span>", "<span class='warning'>You feel a strange sensation in your head that quickly dissipates.</span>")
			qdel(src)
			return -1
		if(..())
			var/list/implanters
			var/ref = "\ref[user.mind]"
			if(!ishuman(M))
				return 0
			if(!M.mind)
				return 0
			if(M == user)
				to_chat(user, "<span class='notice'>Making yourself loyal to yourself was a great idea! Perhaps even the best idea ever! Actually, you just feel like an idiot.</span>")
				if(isliving(user))
					var/mob/living/L = user
					L.adjustBrainLoss(20)
				removed(M)
				qdel(src)
				return -1
			if(isloyal(H))
				H.visible_message("<span class='warning'>[H] seems to resist the implant!</span>", "<span class='warning'>You feel a strange sensation in your head that quickly dissipates.</span>")
				removed(M)
				qdel(src)
				return -1
			H.implanting = 1
			to_chat(H, "<span class='notice'>You feel completely loyal to [user.name].</span>")
			if(!(user.mind in ticker.mode:implanter))
				ticker.mode:implanter[ref] = list()
			implanters = ticker.mode:implanter[ref]
			implanters.Add(H.mind)
			ticker.mode.implanted.Add(H.mind)
			ticker.mode.implanted[H.mind] = user.mind
			//ticker.mode:implanter[user.mind] += H.mind
			ticker.mode:implanter[ref] = implanters
			ticker.mode.traitors += H.mind
			H.mind.special_role = "traitor"
			to_chat(H, "<span class='warning'><B>You're now completely loyal to [user.name]!</B> You now must lay down your life to protect them and assist in their goals at any cost.</span>")
			var/datum/objective/protect/mindslave/MS = new
			MS.owner = H.mind
			MS.target = user:mind
			MS.explanation_text = "Obey every order from and protect [user:real_name], the [user:mind:assigned_role=="MODE" ? (user:mind:special_role) : (user:mind:assigned_role)]."
			H.mind.objectives += MS
			for(var/datum/objective/objective in H.mind.objectives)
				to_chat(H, "<B>Objective #1</B>: [objective.explanation_text]")

			ticker.mode.update_traitor_icons_added(user.mind)
			ticker.mode.update_traitor_icons_added(H.mind)//handles datahuds/observerhuds

			if(user.mind.som)//do not add if not a traitor..and you just picked up an implanter in the hall...
				var/datum/mindslaves/slaved = user.mind.som
				H.mind.som = slaved
				slaved.serv += H
				slaved.add_serv_hud(user.mind, "master") //handles master servent icons
				slaved.add_serv_hud(H.mind, "mindslave")

			log_admin("[ckey(user.key)] has mind-slaved [ckey(H.key)].")
			activated = 1
			return 1
		return 0

/obj/item/weapon/implant/traitor/removed(mob/target)
	if(..())
		ticker.mode.remove_traitor_mind(target.mind)
		return 1
	return 0