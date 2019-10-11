/obj/item/borg/upgrade/ai
	name = "B.O.R.I.S. module"
	desc = "Bluespace Optimized Remote Intelligence Synchronization. An uplink device which takes the place of an MMI in cyborg endoskeletons, creating a robotic shell controlled by an AI."
	icon = 'icons/hispania/obj/module.dmi'
	icon_state = "boris"
	origin_tech = "engineering=3;magnets=4;programming=5"

/obj/item/borg/upgrade/ai/action(mob/living/silicon/robot/R)
	if(..())
		return
	if(R.shell)
		to_chat(usr, "<span class='warning'>This unit is already an AI shell!</span>")
		return
	if(R.key) //You cannot replace a player unless the key is completely removed.
		to_chat(usr, "<span class='warning'>Intelligence patterns detected in this [R.braintype]. Aborting.</span>")
		return

	R.make_shell(src)
	return TRUE
