// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/ai
	icon_state = "NONE"
	detonate = 0
	ttone = "data"

/obj/item/device/pda/ai/proc/set_name_and_job(newname as text, newjob as text, newrank as null|text)
	owner = newname
	ownjob = newjob
	if(newrank)
		ownrank = newrank
	else
		ownrank = ownjob
	name = newname + " (" + ownjob + ")"

/obj/item/device/pda/ai/verb/cmd_send_pdamesg()
	set category = "AI IM"
	set name = "Send PDA Message"
	set src in usr
	
	if(usr.stat == DEAD)
		usr << "You can't send PDA messages because you are dead!"
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(!M)
		usr << "<span class='warning'>Cannot use messenger!</span>"
	var/list/plist = M.available_pdas()
	if (plist)
		var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)
		if (!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		M.create_message(usr, selected)

/obj/item/device/pda/ai/verb/cmd_show_message_log()
	set category = "AI IM"
	set name = "Show Message Log"
	set src in usr
	
	if(usr.stat == DEAD)
		usr << "You can't do that because you are dead!"
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(!M)
		usr << "<span class='warning'>Cannot use messenger!</span>"
	var/HTML = "<html><head><title>AI PDA Message Log</title></head><body>"
	for(var/index in M.tnote)
		if(index["sent"])
			HTML += addtext("<i><b>&rarr; To <a href='byond://?src=\ref[src];choice=Message;target=",index["src"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
		else
			HTML += addtext("<i><b>&larr; From <a href='byond://?src=\ref[src];choice=Message;target=",index["target"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
	HTML +="</body></html>"
	usr << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")

/obj/item/device/pda/ai/verb/cmd_toggle_pda_receiver()
	set category = "AI IM"
	set name = "Toggle Sender/Receiver"
	set src in usr
	
	if(usr.stat == DEAD)
		usr << "You can't do that because you are dead!"
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	M.toff = !M.toff
	usr << "<span class='notice'>PDA sender/receiver toggled [(M.toff ? "Off" : "On")]!</span>"


/obj/item/device/pda/ai/verb/cmd_toggle_pda_silent()
	set category = "AI IM"
	set name = "Toggle Ringer"
	set src in usr
	
	if(usr.stat == DEAD)
		usr << "You can't do that because you are dead!"
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	M.silent = !M.silent
	usr << "<span class='notice'>PDA ringer toggled [(M.silent ? "Off" : "On")]!</span>"

/obj/item/device/pda/ai/can_use()
	return 1


/obj/item/device/pda/ai/attack_self(mob/user as mob)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return

/obj/item/device/pda/ai/pai
	ttone = "assist"