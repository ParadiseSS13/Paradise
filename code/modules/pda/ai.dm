// Special AI/pAI PDAs that cannot explode.
/obj/item/pda/silicon
	icon_state = "NONE"
	detonate = 0
	ttone = "data"

/obj/item/pda/silicon/proc/set_name_and_job(newname as text, newjob as text, newrank as null|text)
	owner = newname
	ownjob = newjob
	if(newrank)
		ownrank = newrank
	else
		ownrank = ownjob
	name = newname + " (" + ownjob + ")"

/obj/item/pda/silicon/verb/cmd_send_pdamesg()
	set category = "AI IM"
	set name = "Send PDA Message"
	set src in usr

	if(!can_use())
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(!M)
		to_chat(usr, "<span class='warning'>Cannot use messenger!</span>")
	var/list/plist = M.available_pdas()
	if(plist)
		var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)
		if(!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		M.create_message(usr, selected)

/obj/item/pda/silicon/verb/cmd_show_message_log()
	set category = "AI IM"
	set name = "Show Message Log"
	set src in usr

	if(!can_use())
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(!M)
		to_chat(usr, "<span class='warning'>Cannot use messenger!</span>")
	var/HTML = {"<html><meta charset="UTF-8"><head><title>AI PDA Message Log</title></head><body>"}
	for(var/index in M.tnote)
		if(index["sent"])
			HTML += addtext("<i><b>&rarr; To <a href='byond://?src=[UID()];choice=Message;target=",index["src"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
		else
			HTML += addtext("<i><b>&larr; From <a href='byond://?src=[UID()];choice=Message;target=",index["target"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
	HTML +="</body></html>"
	usr << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")

/obj/item/pda/silicon/verb/cmd_toggle_pda_receiver()
	set category = "AI IM"
	set name = "Toggle Sender/Receiver"
	set src in usr

	if(!can_use())
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	M.toff = !M.toff
	to_chat(usr, "<span class='notice'>PDA sender/receiver toggled [(M.toff ? "Off" : "On")]!</span>")


/obj/item/pda/silicon/verb/cmd_toggle_pda_silent()
	set category = "AI IM"
	set name = "Toggle Ringer"
	set src in usr

	if(!can_use())
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	M.notify_silent = !M.notify_silent
	to_chat(usr, "<span class='notice'>PDA ringer toggled [(M.notify_silent ? "Off" : "On")]!</span>")

/obj/item/pda/silicon/attack_self(mob/user as mob)
	if((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return

/obj/item/pda/silicon/ai/can_use()
	var/mob/living/silicon/ai/AI = usr
	if(!istype(AI))
		return 0
	return ..() && !AI.check_unable(AI_CHECK_WIRELESS)

/obj/item/pda/silicon/robot/can_use()
	var/mob/living/silicon/robot/R = usr
	if(!istype(R))
		return 0
	return ..() && R.cell.charge > 0

/obj/item/pda/silicon/pai
	ttone = "assist"

/obj/item/pda/silicon/pai/can_use()
	var/mob/living/silicon/pai/pAI = usr
	if(!istype(pAI))
		return FALSE
	if(!pAI.installed_software["messenger"])
		to_chat(usr, "<span class='warning'>You have not purchased the digital messenger!</span>")
		return FALSE
	return ..() && !pAI.silence_time
