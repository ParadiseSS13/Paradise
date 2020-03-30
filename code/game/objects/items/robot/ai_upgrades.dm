///AI Upgrades


//Malf Picker
/obj/item/malf_upgrade
	name = "combat software upgrade"
	desc = "A highly illegal, highly dangerous upgrade for artificial intelligence units, granting them a variety of powers as well as the ability to hack APCs. Will announce the upgrade to the entire station."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"
	var/announce_installation = TRUE


/obj/item/malf_upgrade/afterattack(mob/living/silicon/ai/AI, mob/user)
	if(!istype(AI))
		return
	if(AI.malf_picker)
		AI.malf_picker.processing_time += 50
		to_chat(AI, "<span class='userdanger'>[user] has attempted to upgrade you with combat software that you already possess. You gain 50 points to spend on Malfunction Modules instead.</span>")
	else
		to_chat(AI, "<span class='userdanger'>[user] has upgraded you with combat software!</span>")
		AI.add_malf_picker()
		if(announce_installation)
			GLOB.minor_announcement.Announce("ERROR ER0RR $R-  [AI] has been upgraded with combat software. Thank you for your- 0RRO$!R41.%%!!(%$^^__+ @#F0E4.")
	to_chat(user, "<span class='notice'>You upgrade [AI]. [src] is consumed in the process.</span>")
	qdel(src)

/obj/item/malf_upgrade/examine(mob/user)
	. = ..()
	if(isAntag(user))
		if(announce_installation)
			. += "<span class='notice'>You're familiar with this kind of illegal tech. You think you can disable the installation announcement by reprogramming \the [src] on an AI system integrity restorer console.</span>"
		else
			. += "<span class='notice'>The installation announcement on \the [src] is disabled.</span>"

//Lipreading
/obj/item/surveillance_upgrade
	name = "surveillance software upgrade"
	desc = "A software package that will allow an artificial intelligence to 'hear' from its cameras via lip reading."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"

/obj/item/surveillance_upgrade/afterattack(mob/living/silicon/ai/AI, mob/user)
	if(!istype(AI))
		return
	if(AI.eyeobj)
		AI.eyeobj.relay_speech = 1
		to_chat(AI, "<span class='userdanger'>[user] has upgraded you with surveillance software!</span>")
		to_chat(AI, "Via a combination of hidden microphones and lip reading software, you are able to use your cameras to listen in on conversations.")
	to_chat(user, "<span class='notice'>You upgrade [AI]. [src] is consumed in the process.</span>")
	qdel(src)
