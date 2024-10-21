// MARK: Vibroblade
#define CHARGE_LEVEL_NONE 0
#define CHARGE_LEVEL_LOW 1
#define CHARGE_LEVEL_MEDIUM 2
#define CHARGE_LEVEL_HIGH 3
#define CHARGE_LEVEL_OVERCHARGE 4

/obj/item/melee/vibroblade
	name = "\improper vibroblade"
	desc = "Виброклинок воинов Раскинта. Микрогенератор ультразвука в рукояти позволяет лезвию вибрировать \
		с огромной частотой, что позволяет при его достаточной зарядке наносить глубокие раны даже ударами по касательной."
	icon = 'modular_ss220/objects/icons/melee.dmi'
	icon_state = "vibroblade"
	item_state = "vibroblade"
	lefthand_file = 'modular_ss220/objects/icons/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/melee_righthand.dmi'
	hitsound = 'modular_ss220/objects/sound/weapons/melee/sardaukar/knifehit1.ogg'
	drop_sound = 'modular_ss220/aesthetics_sounds/sound/handling/drop/knife.ogg'
	pickup_sound = 'modular_ss220/objects/sound/weapons/melee/sardaukar/equip.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	force = 20
	throwforce = 15
	throw_speed = 2
	throw_range = 5
	armour_penetration_percentage = 75
	slot_flags = SLOT_FLAG_BELT
	w_class = WEIGHT_CLASS_NORMAL
	sharp = TRUE
	flags = CONDUCT
	var/charge_level = CHARGE_LEVEL_NONE
	var/max_charge_level = CHARGE_LEVEL_OVERCHARGE
	/// How long does it take to reach next level of charge.
	var/charge_time = 4 SECONDS
	/// TRUE if the item keeps charge only when is held in hands. FALSE if the item always keeps charge.
	var/hold_to_be_charged = TRUE
	var/emp_proof = FALSE
	/// Body parts that can be cut off.
	var/list/cutoff_candidates = list(
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
	)

/obj/item/melee/vibroblade/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, PROC_REF(thrown))
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)

/obj/item/melee/vibroblade/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_MOVABLE_POST_THROW)

/obj/item/melee/vibroblade/update_icon_state()
	icon_state = initial(icon_state) + (charge_level > CHARGE_LEVEL_NONE ? "_[charge_level]" : "")

/obj/item/melee/vibroblade/examine(mob/user)
	. = ..()
	. += span_notice("Используйте [src] в руке, чтобы повысить уровень заряда.")
	if(charge_level == CHARGE_LEVEL_NONE)
		. += span_notice("[src] не заряжен.")
		return

	. += span_notice("[src] заряжен на [(charge_level / max_charge_level)*100]%.")
	. += charge_level == max_charge_level \
		? span_danger("Следующий удар будет крайне травмирующим!") \
		: span_warning("Следующий удар будет усиленным!")

/obj/item/melee/vibroblade/attack_self(mob/living/user)
	. = ..()
	if(charge_level >= max_charge_level)
		user.visible_message(
			span_notice("[user.name] пытается зарядить [src], но кнопка на рукояти не поддается!"),
			span_notice("Вы пытаетесь нажать на кнопку зарядки [src], но она заблокирована.")
		)
		return FALSE

	user.visible_message(
		span_notice("[user.name] нажимает на кнопку зарядки [src]..."),
		span_notice("Вы нажимаете на кнопку зарядки [src], заряжая микрогенератор...")
	)

	if(!do_after_once(user, charge_time, allow_moving = TRUE, must_be_held = TRUE, target = src))
		return
	playsound(loc, 'sound/effects/sparks3.ogg', vol = 10, vary = TRUE)
	do_sparks(1, TRUE, src)
	set_charge_level(charge_level + 1)

/obj/item/melee/vibroblade/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	force = initial(force) * get_damage_factor()

/obj/item/melee/vibroblade/attack(mob/living/target, mob/living/user, def_zone)
	var/obj/item/organ/external/selected_bodypart
	if(user.zone_selected in cutoff_candidates)
		selected_bodypart = target.get_organ(user.zone_selected)
	. = ..()

	if(charge_level == CHARGE_LEVEL_HIGH)
		target.Weaken(1.5 SECONDS)
	else if(charge_level == CHARGE_LEVEL_OVERCHARGE && selected_bodypart && istype(target, /mob/living/carbon/human))
		var/obj/item/organ/external/after_attack_bodypart = target.get_organ(user.zone_selected)

		// We compare these in case the body part hasn't been cut off by standard attack logic
		if(after_attack_bodypart == selected_bodypart)
			after_attack_bodypart.droplimb(TRUE, DROPLIMB_SHARP)
		user.visible_message(
			span_danger("[user] изящно и непринужденно отсекает [selected_bodypart] [target]!"),
			span_biggerdanger("Вы искусно отсекаете [selected_bodypart] [target]!")
		)

	set_charge_level(CHARGE_LEVEL_NONE)

/obj/item/melee/vibroblade/suicide_act(mob/living/carbon/human/user)
	var/obj/item/organ/external/head = user.get_organ(BODY_ZONE_HEAD)
	user.visible_message(span_suicide("[user] прижимает лезвие [src] к своей шее и нажимает на кнопку зарядки микрогенератора. \
		Кажется, это попытка самоубийства!"))
	user.atom_say("Слава Вечной Империи!")
	head.droplimb(TRUE, DROPLIMB_SHARP, FALSE, TRUE)
	set_charge_level(CHARGE_LEVEL_NONE)
	return BRUTELOSS

/obj/item/melee/vibroblade/emp_act(severity)
	. = ..()
	if(emp_proof)
		return
	set_charge_level(CHARGE_LEVEL_NONE)

/obj/item/melee/vibroblade/equipped(mob/user, slot, initial)
	. = ..()
	if(hold_to_be_charged && slot != SLOT_HUD_LEFT_HAND && slot != SLOT_HUD_RIGHT_HAND)
		set_charge_level(CHARGE_LEVEL_NONE)

/obj/item/melee/vibroblade/dropped(mob/user, silent)
	. = ..()
	if(hold_to_be_charged && !silent)
		set_charge_level(CHARGE_LEVEL_NONE)

/obj/item/melee/vibroblade/proc/thrown(datum/thrownthing/thrown_thing, spin)
	SIGNAL_HANDLER
	if(hold_to_be_charged)
		set_charge_level(CHARGE_LEVEL_NONE)

/obj/item/melee/vibroblade/proc/get_damage_factor()
	return 1 + 0.25 * clamp(charge_level, CHARGE_LEVEL_NONE, max_charge_level)

/obj/item/melee/vibroblade/proc/set_charge_level(charge_level)
	src.charge_level = charge_level
	force = initial(force) * get_damage_factor()
	update_icon_state()

/obj/item/melee/vibroblade/sardaukar
	name = "\improper emperor guard vibroblade"
	desc = "Виброклинок гвардейцев Императора. Микрогенератор ультразвука в рукояти позволяет лезвию вибрировать \
		с огромной частотой, что позволяет при его достаточной зарядке наносить глубокие раны даже ударами по касательной. \
		Воины Куи'кверр-Кэтиш обучаются мастерству ближнего боя с детства, поэтому в их руках он особо опасен и жесток. \
		Каждый будущий гвардеец добывает свой клинок в ритуальном бою, и его сохранность есть вопрос жизни и смерти владельца."
	icon_state = "vibroblade_elite"
	item_state = "vibroblade_elite"
	force = 25
	charge_time = 2 SECONDS
	hold_to_be_charged = FALSE
	emp_proof = TRUE

#undef CHARGE_LEVEL_NONE
#undef CHARGE_LEVEL_LOW
#undef CHARGE_LEVEL_MEDIUM
#undef CHARGE_LEVEL_HIGH
#undef CHARGE_LEVEL_OVERCHARGE
