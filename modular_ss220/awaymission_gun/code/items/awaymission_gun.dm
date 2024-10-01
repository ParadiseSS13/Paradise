/obj/item/gun/energy/laser/awaymission_aeg
	name = "Wireless Energy Gun"
	desc = "An energy gun that recharges wirelessly during away missions. Does not work outside the gate."
	icon = 'modular_ss220/awaymission_gun/icons/items/energy.dmi'
	lefthand_file = 'modular_ss220/awaymission_gun/icons/inhands/lefthand.dmi'
	righthand_file = 'modular_ss220/awaymission_gun/icons/inhands/righthand.dmi'
	icon_state = "laser_gate"
	item_state = "nucgun"
	force = 10
	origin_tech = "combat=5;magnets=3;powerstorage=4"
	selfcharge = TRUE // Selfcharge is enabled and disabled, and used as the away mission tracker
	can_charge = 0

/obj/item/gun/energy/laser/awaymission_aeg/Initialize(mapload)
	. = ..()
	// Force update it incase it spawns outside an away mission and shouldnt be charged
	onTransitZ(new_z = loc.z)

/obj/item/gun/energy/laser/awaymission_aeg/onTransitZ(old_z, new_z)
	. = ..()
	if(is_away_level(new_z))
		if(ismob(loc))
			to_chat(loc, span_notice("Ваш [src] активируется, начиная аккумулировать энергию из материи сущего."))
		selfcharge = TRUE
		return
	if(ismob(loc) && selfcharge)
		to_chat(loc, span_danger("Ваш [src] деактивируется, так как он подавляется системами станции.</span>"))
	cell.charge = 0
	selfcharge = FALSE
	update_icon()

/obj/item/gun/energy/laser/awaymission_aeg/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.unEquip(src)

// GUNS
/obj/item/gun/energy/laser/awaymission_aeg/rnd
	name = "Exploreverse Mk.I"
	desc = "Прототип оружия с миниатюрным реактором для исследований в крайне отдаленных секторах. \
	\n Данная модель использует экспериментальную систему обратного восполнения, работающую на принципе огромной аккумуляции энергии, но крайне уязвимую к радиопомехам, которыми кишит сектор станции, попростую не работая там."
	origin_tech = "combat=2;powerstorage=3"

/obj/item/gun/energy/laser/awaymission_aeg/rnd/mk2
	name = "Exploreverse Mk.II"
	desc = "Второй прототип оружия с миниатюрным реактором и забавным рычагом для исследований в крайне отдаленных секторах. \
	\nДанная модель оснащена системой ручного восполнения энергии \"Za.E.-8 A.L'sya\", \
	позволяющей в короткие сроки восполнить необходимую электроэнергию с помощью ручного труда и конвертации личной энергии подключенного к системе зарядки. \
	\nТеперь еще более нелепый дизайн с торчащими проводами!"
	icon_state = "laser_gate_mk2"
	origin_tech = "combat=3;magnets=2;powerstorage=2;programming=3;"

/obj/item/gun/energy/laser/awaymission_aeg/rnd/mk2/attack_self(mob/living/user)
	var/msg_for_all = span_warning("[user.name] усердно давит на рычаг зарядки [src], но он не поддается!")
	var/msg_for_user = span_notice("Вы пытаетесь надавить на рычаг зарядки [src], но он заблокирован.")
	var/msg_recharge_all = span_notice("[user.name] усердно давит на рычаг зарядки [src]...")
	var/msg_recharge_user = span_notice("Вы со всей силы давите на рычаг зарядки [src], пытаясь зарядить её...")

	if(!is_away_level(loc.z))
		user.visible_message(msg_for_all, msg_for_user)
		return FALSE

	if(cell.charge >= cell.maxcharge)
		user.visible_message(msg_for_all, msg_for_user)
		return FALSE

	if(user.nutrition <= NUTRITION_LEVEL_STARVING)
		user.visible_message(
			span_warning("[user.name] слабо давит на [src], но бесполезно: слишком мало сил!"),
			span_notice("Вы пытаетесь надавить на рычаг зарядки [src], но не можете из-за голода и усталости!"))
		return FALSE

	user.visible_message(msg_recharge_all, msg_recharge_user)
	playsound(loc, 'sound/effects/sparks3.ogg', 10, 1)
	do_sparks(1, 1, src)

	if(!do_after_once(user, 3 SECONDS, target = src))
		return
	cell.give(166)
	on_recharge()
	user.adjust_nutrition(-25)
	. = ..()
