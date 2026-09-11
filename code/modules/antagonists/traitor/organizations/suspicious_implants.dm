/obj/item/organ/internal/cyberimp/chest/nutriment/suspicious //Nutriment pump that gives the hunger hallucination
	name = "suspicious implant"
	desc = "This implant looks highly experimental. It probably has some nasty side effects."
	implant_overlay = null
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_GOLD = 500)

/obj/item/organ/internal/cyberimp/chest/nutriment/suspicious/on_life()
	if(!owner)
		return
	if(synthesizing)
		return
	if(disabled_by_emp)
		return
	if(owner.stat == DEAD)
		return
	if(status & ORGAN_DEAD)
		return FALSE
	owner.invoke_hallucination(/obj/effect/hallucination/fake_nutrition)
	if(owner.nutrition <= hunger_threshold)
		synthesizing = TRUE
		to_chat(owner, SPAN_NOTICE("You feel less hungry..."))
		owner.adjust_nutrition(50)
		addtimer(CALLBACK(src, PROC_REF(synth_cool)), 50)

/obj/item/organ/internal/cyberimp/arm/gun/laser/suspicious // Arm laser that doesn't self-charge
	name = "suspicious implant"
	desc = "This implant looks highly experimental. It probably has some nasty side effects."
	icon_state = "sus_laser"
	contents = newlist(/obj/item/gun/energy/laser/mounted/suspicious)

/obj/item/organ/internal/cyberimp/arm/gun/laser/suspicious/l
	parent_organ = "l_arm"

/obj/item/gun/energy/laser/mounted/suspicious
	name = "suspicious mounted laser"
	selfcharge = FALSE

/obj/item/organ/internal/cyberimp/chest/nutriment/death_alarm //'Death Alarm' that goes off when the user is hungry
	name = "suspicious implant"
	desc = "This implant looks highly experimental. It probably has some nasty side effects."
	icon_state = "sus_death"
	implant_overlay = null
	slot = "heartdrive"
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_GOLD = 500)
	hunger_threshold = NUTRITION_LEVEL_HUNGRY

/obj/item/organ/internal/cyberimp/chest/nutriment/death_alarm/on_life()
	if(!owner)
		return
	if(synthesizing)
		return
	if(owner.stat == DEAD)
		return
	if(status & ORGAN_DEAD)
		return FALSE
	if(owner.nutrition <= hunger_threshold)
		var/mobname = owner.real_name
		var/mob/M = owner
		var/area/t = get_area(M)

		var/obj/item/radio/headset/a = new /obj/item/radio/headset(src)
		a.follow_target = M
		a.autosay("[mobname] has died in [t.name]!", "[mobname]'s Death Alarm")
		qdel(src)
		qdel(a)

		synthesizing = TRUE
		addtimer(CALLBACK(src, PROC_REF(synth_cool)), 50)
