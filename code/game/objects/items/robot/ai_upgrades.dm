///AI Upgrades

/obj/item/ai_upgrade
	name = "parent ai upgrade"
	desc = "A base rootkit for ai upgrades. If you are seeing this, report where you found it on the github issues."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"
	new_attack_chain = TRUE

/obj/item/ai_upgrade/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(is_ai(target))
		ai_upgrade_action(target, user)
		return ITEM_INTERACT_COMPLETE

/obj/item/ai_upgrade/proc/ai_upgrade_action(mob/living/silicon/ai/AI, mob/user)
	return

//Malf Picker
/obj/item/ai_upgrade/malf_upgrade
	name = "combat software upgrade"
	desc = "A highly illegal, highly dangerous upgrade for artificial intelligence units, granting them a variety of powers as well as the ability to hack APCs."

/obj/item/ai_upgrade/malf_upgrade/ai_upgrade_action(mob/living/silicon/ai/AI, mob/user)
	if(!istype(AI))
		return
	if(AI.malf_picker)
		AI.malf_picker.processing_time += 50
		to_chat(AI, "<span class='userdanger'>[user] has attempted to upgrade you with combat software that you already possess. You gain 50 points to spend on Malfunction Modules instead.</span>")
	else
		to_chat(AI, "<span class='userdanger'>[user] has upgraded you with combat software!</span>")
		AI.add_malf_picker()
	to_chat(user, "<span class='notice'>You upgrade [AI]. [src] is consumed in the process.</span>")
	qdel(src)


//Lipreading
/obj/item/ai_upgrade/surveillance_upgrade
	name = "surveillance software upgrade"
	desc = "A software package that will allow an artificial intelligence to 'hear' from its cameras via lip reading."

/obj/item/ai_upgrade/surveillance_upgrade/ai_upgrade_action(mob/living/silicon/ai/AI, mob/user)
	if(!istype(AI))
		return
	if(AI.eyeobj)
		AI.eyeobj.relay_speech = 1
		to_chat(AI, "<span class='userdanger'>[user] has upgraded you with surveillance software!</span>")
		to_chat(AI, "Via a combination of hidden microphones and lip reading software, you are able to use your cameras to listen in on conversations.")
	to_chat(user, "<span class='notice'>You upgrade [AI]. [src] is consumed in the process.</span>")
	qdel(src)

// AI program reset
/obj/item/ai_upgrade/ai_program_reset
	name = "Program Reset Disk"
	desc = "Insert this disk into the AI core to completely reset their programs."
	w_class = WEIGHT_CLASS_TINY

/obj/item/ai_upgrade/ai_program_reset/ai_upgrade_action(mob/living/silicon/ai/AI, mob/user)
	if(!istype(AI))
		return
	to_chat(user, "<span class='notice'>You reset [AI]'s program storage to factory settings.</span>")
	AI.reset_programs()
