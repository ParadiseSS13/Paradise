/obj/effect/proc_holder/spell/targeted/click/mimic
	name = "Mimic"
	desc =  "Learn a new form to mimic or become one of your known forms"
	clothes_req = FALSE
	charge_max = 50
	include_user = TRUE // To change forms
	action_icon_state = "genetic_morph"
	allowed_type = /atom/movable
	auto_target_single = FALSE
	click_radius = -1
	selection_activated_message = "<span class='sinister'>Click on a target to remember it's form. Click on yourself to change form.</span>"
	create_logs = FALSE
	action_icon_state = "morph_mimic"
	/// Which form is currently selected
	var/datum/mimic_form/selected_form
	/// Which forms the user can become
	var/list/available_forms = list()
	/// How many forms the user can remember
	var/max_forms = 5
	/// Which index will be overriden next when the user wants to remember another form
	var/next_override_index = 1
	/// If a message is shown when somebody examines the user from close range
	var/perfect_disguise = FALSE

/obj/effect/proc_holder/spell/targeted/click/mimic/valid_target(atom/target, user)
	if(istype(target, /obj/screen))
		return FALSE
	if(istype(target, /obj/singularity))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/targeted/click/mimic/cast(list/targets, mob/user)
	var/atom/movable/A = targets[1]
	if(A == user)
		INVOKE_ASYNC(src, .proc/pick_form, user)
		return

	INVOKE_ASYNC(src, .proc/remember_form, A, user)

/obj/effect/proc_holder/spell/targeted/click/mimic/proc/remember_form(atom/movable/A, mob/user)
	if(A.name in available_forms)
		to_chat(user, "<span class='warning'>[A] is already an available form.</span>")
		revert_cast(user)
		return
	if(length(available_forms) >= max_forms)
		to_chat(user, "<span class='warning'>You start to forget the form of [available_forms[next_override_index]] to learn a new one.</span>")

	to_chat(user, "<span class='sinister'>You start remembering the form of [A].</span>")
	if(!do_after(user, 2 SECONDS, FALSE, user))
		to_chat(user, "<span class='warning'>You lose focus.</span>")
		return

	// Forget the old form if needed
	if(length(available_forms) >= max_forms)
		qdel(available_forms[next_override_index])
		available_forms[next_override_index++] = A.name
		// Reset if needed
		if(next_override_index > max_forms)
			next_override_index = 1

	available_forms[A.name] = new /datum/mimic_form(A, user)
	to_chat(user, "<span class='sinister'>You learn the form of [A].</span>")

/obj/effect/proc_holder/spell/targeted/click/mimic/proc/pick_form(mob/user)
	if(!length(available_forms))
		to_chat(user, "<span class='warning'>No available forms. Learn more forms by using this spell on other objects first.</span>")
		revert_cast(user)
		return

	var/list/forms = list("Original Form")
	forms += available_forms.Copy()
	var/what = input(user, "Which form do you want to become", "Mimic") as null|anything in forms
	if(!what)
		to_chat(user, "<span class='notice'>You decide against changing forms.</span>")
		revert_cast(user)
		return

	if(what == "Original Form")
		restore_form(user)
		return
	to_chat(user, "<span class='sinister'>You start becoming [what].</span>")
	if(!do_after(user, 2 SECONDS, FALSE, user))
		to_chat(user, "<span class='warning'>You lose focus.</span>")
		return
	take_form(available_forms[what], user)

/obj/effect/proc_holder/spell/targeted/click/mimic/proc/take_form(datum/mimic_form/form, mob/user)
	selected_form = form

	var/old_name = "[user]"
	if(ishuman(user))
		// Not fully finished yet
		var/mob/living/carbon/human/H = user
		H.name_override = form.name

	else
		user.appearance = form.appearance
		user.transform = initial(user.transform)
		user.pixel_y = initial(user.pixel_y)
		user.pixel_x = initial(user.pixel_x)

	show_change_form_message(user, old_name, "[user]")
	user.create_log(MISC_LOG, "Mimicked into [user]")
	RegisterSignal(user, COMSIG_PARENT_EXAMINE, .proc/examine_override)
	RegisterSignal(user, COMSIG_MOB_DEATH, .proc/on_death)

	SEND_SIGNAL(user, COMSIG_MAGIC_MIMIC_CHANGE_FORM, form)

/obj/effect/proc_holder/spell/targeted/click/mimic/proc/show_change_form_message(mob/user, old_name, new_name)
	user.visible_message("<span class='warning'>[old_name] contorts and slowly becomes [new_name]!</span>", "<span class='sinister'>You take form of [new_name].</span>", "You hear loud cracking noises!")

/obj/effect/proc_holder/spell/targeted/click/mimic/proc/restore_form(mob/user, show_message = TRUE)
	selected_form = null
	var/old_name = "[user]"

	user.cut_overlays()
	user.icon = initial(user.icon)
	user.icon_state = initial(user.icon_state)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.name_override = null
		H.regenerate_icons()

	else
		user.name = initial(user.name)
		user.desc = initial(user.desc)

	if(show_message)
		show_restore_form_message(user, old_name, "[user]")

	UnregisterSignal(user, list(COMSIG_PARENT_EXAMINE, COMSIG_MOB_DEATH))
	SEND_SIGNAL(user, COMSIG_MAGIC_MIMIC_RESTORE_FORM)

/obj/effect/proc_holder/spell/targeted/click/mimic/proc/show_restore_form_message(mob/user, old_name, new_name)
	user.visible_message("<span class='warning'>[old_name] shakes and contorts and quickly becomes [new_name]!</span>", "<span class='sinister'>You take return to your normal self.</span>", "You hear loud cracking noises!")

/obj/effect/proc_holder/spell/targeted/click/mimic/proc/examine_override(datum/source, mob/user, var/list/examine_list)
	examine_list.Cut()
	examine_list += selected_form.examine_text
	if(!perfect_disguise && get_dist(user, src) <= 3)
		examine_list += "<span class='warning'>It doesn't look quite right...</span>"

/obj/effect/proc_holder/spell/targeted/click/mimic/proc/on_death(mob/user, gibbed)
	if(!gibbed)
		restore_form(user, FALSE)
		show_death_message(user)

/obj/effect/proc_holder/spell/targeted/click/mimic/proc/show_death_message(mob/user)
	user.visible_message("<span class='warning'>[user] shakes and contorts as he dies. Returning to his true form!</span>", "<span class='deadsay'>Your disguise fails as your life forces drain away.</span>", "You hear loud cracking noises followed by a thud!")


/datum/mimic_form
	/// How does the form look like?
	var/appearance
	/// What is the examine text paired with this form
	var/examine_text
	/// What the name of the form is
	var/name

/datum/mimic_form/New(atom/movable/form, mob/user)
	appearance = form.appearance
	examine_text = form.examine(user)
	name = form.name


/obj/effect/proc_holder/spell/targeted/click/mimic/morph
	action_background_icon_state = "bg_morph"

/obj/effect/proc_holder/spell/targeted/click/mimic/morph/valid_target(atom/target, user)
	if(target != user && istype(target, /mob/living/simple_animal/hostile/morph))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/targeted/click/mimic/morph/show_change_form_message(mob/user, old_name, new_name)
	user.visible_message("<span class='warning'>[old_name] suddenly twists and changes shape, becoming a copy of [new_name]!</span>", \
					"<span class='notice'>You twist your body and assume the form of [new_name].</span>")

/obj/effect/proc_holder/spell/targeted/click/mimic/morph/show_restore_form_message(mob/user, old_name, new_name)
	user.visible_message("<span class='warning'>[old_name] suddenly collapses in on itself, dissolving into a pile of green flesh!</span>", \
					"<span class='notice'>You reform to your normal body.</span>")

/obj/effect/proc_holder/spell/targeted/click/mimic/morph/show_death_message(mob/user)
	user.visible_message("<span class='warning'>[user] twists and dissolves into a pile of green flesh!</span>", \
						"<span class='userdanger'>Your skin ruptures! Your flesh breaks apart! No disguise can ward off de--</span>")
