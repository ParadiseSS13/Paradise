/obj/machinery/computer3/aifixer
	default_prog = /datum/file/program/aifixer
	spawn_parts = list(/obj/item/part/computer/storage/hdd/big,/obj/item/part/computer/ai_holder)
	icon_state = "frame-rnd"


/datum/file/program/aifixer
	name			= "AI system integrity restorer"
	desc			= "Repairs and revives artificial intelligence cores."
	image			= 'icons/ntos/airestore.png'
	active_state	= "ai-fixer-empty"
	req_access		= list(access_captain, access_robotics, access_heads)

	update_icon()
		if(!computer || !computer.cradle)
			overlay.icon_state = "ai-fixer-404"
			return // what

		if(!computer.cradle.occupant)
			overlay.icon_state = "ai-fixer-empty"
		else
			if(computer.cradle.occupant.health >= 0 && computer.cradle.occupant.stat != 2)
				overlay.icon_state = "ai-fixer-full"
			else
				overlay.icon_state = "ai-fixer-404"
		computer.update_icon()

	interact()
		if(!interactable())
			return

		if(!computer.cradle)
			computer.Crash(MISSING_PERIPHERAL)
			return

		popup.set_content(aifixer_menu())
		popup.open()
		return

	proc/aifixer_menu()
		var/dat = ""
		if(computer.cradle.occupant)
			var/laws
			dat += "<h3>Stored AI: [computer.cradle.occupant.name]</h3>"
			dat += "<b>System integrity:</b> [(computer.cradle.occupant.health+100)/2]%<br>"

			if(computer.cradle.occupant.laws.zeroth)
				laws += "<b>0:</b> [computer.cradle.occupant.laws.zeroth]<BR>"

			var/number = 1
			for(var/index = 1, index <= computer.cradle.occupant.laws.inherent.len, index++)
				var/law = computer.cradle.occupant.laws.inherent[index]
				if(length(law) > 0)
					laws += "<b>[number]:</b> [law]<BR>"
					number++

			for(var/index = 1, index <= computer.cradle.occupant.laws.supplied.len, index++)
				var/law = computer.cradle.occupant.laws.supplied[index]
				if(length(law) > 0)
					laws += "<b>[number]:</b> [law]<BR>"
					number++

			dat += "<b>Laws:</b><br>[laws]<br>"

			if(computer.cradle.occupant.stat == 2)
				dat += "<span class='bad'>AI non-functional</span>"
			else
				dat += "<span class='good'>AI functional</span>"
			if(!computer.cradle.busy)
				dat += "<br><br>[topic_link(src,"fix","Begin Reconstruction")]"
			else
				dat += "<br><br>Reconstruction in process, please wait.<br>"
		dat += "<br>[topic_link(src,"close","Close")]"
		return dat

	Topic(var/href, var/list/href_list)
		if(!interactable() || !computer.cradle || ..(href,href_list))
			return

		if("fix" in href_list)
			var/mob/living/silicon/ai/occupant = computer.cradle.occupant
			if(!occupant) return

			computer.cradle.busy = 1
			computer.overlays += image('icons/obj/computer.dmi', "ai-fixer-on")

			var/i = 0
			while(occupant.health < 100)
				if(!computer || (computer.stat&~MAINT)) // takes some time, keep checking
					break

				occupant.adjustOxyLoss(-1)
				occupant.adjustFireLoss(-1)
				occupant.adjustToxLoss(-1)
				occupant.adjustBruteLoss(-1)
				occupant.updatehealth()
				if(occupant.health >= 0 && computer.cradle.occupant.stat == 2)
					occupant.stat = 0
					occupant.lying = 0
					dead_mob_list -= occupant
					living_mob_list += occupant
					update_icon()

				i++
				if(i == 5)
					computer.use_power(50) // repairing an AI is nontrivial.  laptop battery may not be enough.
					computer.power_change() // if the power runs out, set stat
					i = 0

				computer.updateUsrDialog()

				sleep(10)
			computer.cradle.busy = 0
			computer.overlays -= image('icons/obj/computer.dmi', "ai-fixer-on")

		computer.updateUsrDialog()
		return
