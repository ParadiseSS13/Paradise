/obj/item/storage/belt/sheath/saber
	icon = 'modular_ss220/objects/icons/belts.dmi'
	icon_override = 'modular_ss220/mobs/icons/mob/belts.dmi'
	var/base_name = "sheath"
	icon_state = "sheath_classic"
	item_state = null
	base_icon_state = "sheath_classic"
	can_hold = list(/obj/item/melee/saber)

	/// allows one-time reskinning
	var/is_unique_reskin_available = TRUE
	/// the skin choices
	var/list/options = list("Классика" = "classic", "Церемониальный" = "ceremonial", "Шашка" = "cossack")

/obj/item/storage/belt/sheath/saber/examine(mob/user)
	. = ..()
	if(is_unique_reskin_available)
		. += span_notice("<b>Ctrl-click</b> по предмету в руке, чтобы один раз изменить внешний вид.")

/obj/item/storage/belt/sheath/saber/CtrlClick(mob/user)
	. = ..()
	if(!is_unique_reskin_available)
		to_chat(user, span_warning("Внешний вид уже выбран!"))
		return
	if(!user.is_holding(src))
		to_chat(user, span_warning("Вы должны взять ножны в руки, чтобы сделать это."))
		return
	if(user.incapacitated())
		to_chat(user, span_warning("Вы не можете этого сделать прямо сейчас!"))
		return
	if(!length(contents))
		to_chat(user, span_warning("Чтобы это сделать, меч должен быть внутри!"))
		return
	reskin(user, contents[1])

/obj/item/storage/belt/sheath/saber/proc/reskin(mob/living/carbon/human/user, obj/item/melee/saber/saber)
	var/list/skins = list()
	for(var/option in options)
		skins[option] = image(icon, icon_state = "[base_name]_[options[option]]-sword")
	var/choice = show_radial_menu(user, src, skins, radius = 40, custom_check = CALLBACK(src, PROC_REF(reskin_radial_check), user), require_near = TRUE)
	if(!choice)
		return

	is_unique_reskin_available = FALSE
	var/new_skin = options[choice]
	base_icon_state = "[base_name]_[new_skin]"
	update_icon()
	saber.reskin(new_skin)
	user.update_inv_r_hand()
	user.update_inv_l_hand()
	to_chat(user, "[choice] идеально вам подходит.")

/obj/item/storage/belt/sheath/saber/proc/reskin_radial_check(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human = user
	if(!human.is_in_hands(src) || HAS_TRAIT(human, TRAIT_HANDS_BLOCKED))
		return FALSE
	return TRUE
