/obj/item/melee/baton/electrostaff
	name = "электропосох"
	desc = "Шоковая палка, только более мощная, двуручная и доступная наиболее авторитетным членам силовых структур Nanotrasen. А еще у неё нет тупого конца."
	lefthand_file = 'modular_ss220/objects/icons/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/melee_righthand.dmi'
	icon = 'modular_ss220/objects/icons/melee.dmi'
	base_icon = "electrostaff"
	icon_state = "electrostaff_orange"
	slot_flags = SLOT_FLAG_BELT
	w_class = WEIGHT_CLASS_HUGE
	force = 10
	throwforce = 7
	origin_tech = "combat=5"
	attack_verb = list("attacked", "beaten")
	/// What sound plays when its opening
	var/sound_on = 'modular_ss220/objects/sound/weapons/melee/electrostaff/on.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, RAD = 0, FIRE = 80, ACID = 80)

	stam_damage = 80
	/// How much burn damage it does when turned on
	var/burn_damage = 5

	turned_on = FALSE
	knockdown_duration = 15 SECONDS
	hitcost = 1600 // 6 hits to 0 power
	cooldown = 3.5 SECONDS
	knockdown_delay = 2.5 SECONDS

	/// allows one-time reskinning
	var/unique_reskin = TRUE
	/// the skin choice
	var/current_skin = null
	var/list/options = list()

/obj/item/melee/baton/electrostaff/Initialize(mapload)
	current_skin = "_orange"
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)
	AddComponent(/datum/component/two_handed, force_unwielded = force / 2, force_wielded = force, wield_callback = CALLBACK(src, PROC_REF(on_wield)), unwield_callback = CALLBACK(src, PROC_REF(on_unwield)))
	options["Оранжевое свечение"] = "_orange"
	options["Красное свечение"] = "_red"
	options["Фиолетовое свечение"] = "_purple"
	options["Синее свечение"] = "_blue"
	. = ..()

/obj/item/melee/baton/electrostaff/loaded/Initialize(mapload) //this one starts with a cell pre-installed.
	link_new_cell()
	. = ..()

/obj/item/melee/baton/electrostaff/update_icon_state()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		if(cell?.charge >= hitcost)
			icon_state = "[base_icon][current_skin]_active"
		else
			if(cell != null)
				icon_state = "[base_icon][current_skin]_wield"
			else
				icon_state = "[base_icon][current_skin]_nocell_wield"
	else
		if(cell != null)
			icon_state = "[base_icon][current_skin]"
		else
			icon_state = "[base_icon][current_skin]_nocell"

/obj/item/melee/baton/electrostaff/examine(mob/user)
	. = ..()
	. -= "<span class='notice'>This item can be recharged in a recharger. Using a screwdriver on this item will allow you to access its power cell, which can be replaced.</span>"
	. += "<span class='notice'>Данный предмет не имеет внешних разъемов для зарядки. Используйте <b>отвертку</b> для доступа к внутренней батарее, чтобы заменить или зарядить её.</span>"
	if(unique_reskin)
		. += "<span class='notice'>Alt-клик, чтобы изменить свечение.</span>"

/obj/item/melee/baton/electrostaff/attack_self(mob/user)
	var/signal_ret = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user)
	if(signal_ret & COMPONENT_NO_INTERACT)
		return
	if(signal_ret & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

/obj/item/melee/baton/electrostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return FALSE
	. = ..()

/obj/item/melee/baton/electrostaff/proc/on_wield(obj/item/source, mob/living/carbon/user)
	after_turn(TRUE, user)

/obj/item/melee/baton/electrostaff/proc/on_unwield(obj/item/source, mob/living/carbon/user)
	turned_on = FALSE
	after_turn(FALSE, user)

/obj/item/melee/baton/electrostaff/proc/after_turn(to_turn_on, mob/living/carbon/user)
	if(cell?.charge >= hitcost)
		if(to_turn_on)
			turned_on = TRUE
		to_chat(user, "<span class='notice'>[src] [turned_on ? "включен" : "выключен"].</span>")
		playsound(src, turned_on ? sound_on : "sparks", 75, TRUE, -1)
	else
		if(!cell)
			to_chat(user, "<span class='warning'>[src] не имеет источников питания!</span>")
		else
			to_chat(user, "<span class='warning'>[src] обесточен.</span>")
	update_icon()
	add_fingerprint(user)

/// returning false results in no baton attack animation, returning true results in an animation.
/obj/item/melee/baton/electrostaff/baton_stun(mob/living/L, mob/user, skip_cooldown = FALSE)
	. = ..(L, user, skip_cooldown)
	if(. == TRUE)
		if(user.a_intent == INTENT_HARM)
			L.apply_damage(burn_damage, BURN)

/obj/item/melee/baton/electrostaff/AltClick(mob/user)
	. = ..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>Вы не можете этого сделать прямо сейчас!</span>")
		return
	if(unique_reskin && loc == user)
		reskin_staff(user)

/obj/item/melee/baton/electrostaff/proc/reskin_staff(mob/M)
	var/list/skins = list()
	for(var/I in options)
		skins[I] = image(icon, icon_state = "[base_icon][options[I]]")
	var/choice = show_radial_menu(M, src, skins, radius = 40, custom_check = CALLBACK(src, PROC_REF(reskin_radial_check), M), require_near = TRUE)

	if(choice && reskin_radial_check(M))
		current_skin = options[choice]
		to_chat(M, "[choice] идеально подходит вашему посоху.")
		unique_reskin = FALSE
		update_icon()
		M.update_inv_r_hand()
		M.update_inv_l_hand()

/obj/item/melee/baton/electrostaff/proc/reskin_radial_check(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!src || !H.is_in_hands(src) || HAS_TRAIT(H, TRAIT_HANDS_BLOCKED))
		return FALSE
	return TRUE

/obj/item/weaponcrafting/gunkit/electrostaff
	name = "\improper electrostaff parts kit"
	desc = "Возьмите 2 оглушающие дубинки. Соедините их вместе, поместив внутрь батарею. Используйте остальные инструменты (лишних винтиков быть не должно)."
	origin_tech = "combat=6;materials=4"
	outcome = /obj/item/melee/baton/electrostaff/loaded

/datum/design/electrostaff
	name = "Electrostaff Parts Kit"
	desc = "Оперативный ответ."
	id = "electrostaff"
	req_tech = list("combat" = 7, "magnets" = 5, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000, MAT_GOLD = 3000, MAT_SILVER = 1500)
	build_path = /obj/item/weaponcrafting/gunkit/electrostaff
	category = list("Weapons")

/datum/crafting_recipe/electrostaff
	name = "Electrostaff"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = list(/obj/item/melee/baton/electrostaff/loaded)
	reqs = list(/obj/item/melee/baton = 2,
				/obj/item/stock_parts/cell/high = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/assembly/signaler/anomaly/flux = 1,
				/obj/item/weaponcrafting/gunkit/electrostaff = 1)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
