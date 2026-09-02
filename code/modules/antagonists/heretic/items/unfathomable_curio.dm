//Item for knock/moon heretic sidepath, it can block 5 hits of damage, acts as storage and if the heretic is examined the examiner suffers brain damage and blindness

/obj/item/storage/belt/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "It. It looks backs. It looks past. It looks in. It sees. It hides. It opens."
	icon_state = "unfathomable_curio"
	inhand_icon_state = "unfathomable_curio"
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbelt_pickup.ogg'
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	can_hold = list(
		/obj/item/ammo_box/lionhunter,
		/obj/item/heretic_labyrinth_handbook,
		/obj/item/clothing/neck/eldritch_amulet,
		/obj/item/clothing/neck/heretic_focus,
		/obj/item/codex_cicatrix,
		/obj/item/eldritch_potion,
		/obj/item/food/grown/poppy, // Used to regain a Living Heart.
		/obj/item/food/grown/harebell, // Used to reroll targets
		/obj/item/melee/rune_carver,
		/obj/item/melee/sickly_blade,
		/obj/item/organ, // Organs are also often used in rituals.
		/obj/item/reagent_containers/drinks/bottle/eldritch,
		/obj/item/stack/sheet/glass, // Glass is often used by moon heretics
	)
	//Vars used for the shield component
	var/heretic_shield_icon = "unfathomable_shield"
	var/max_charges = 1
	var/recharge_start_delay = 30 SECONDS
	var/charge_increment_delay = 30 SECONDS
	var/charge_recovery = 1

/obj/item/storage/belt/unfathomable_curio/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, \
	charge_recovery = charge_recovery, shield_icon = heretic_shield_icon, run_hit_callback = CALLBACK(src, PROC_REF(shield_damaged)))


/obj/item/storage/belt/unfathomable_curio/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot & slot_flags))
		return

	RegisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(shield_reaction))

	if(!IS_HERETIC(user))
		to_chat(user, SPAN_WARNING("The curio wraps around you, and you feel the beating of something dark inside it..."))

/obj/item/storage/belt/unfathomable_curio/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS)

// Here we make sure our curio is only able to block while worn on the belt slot
/obj/item/storage/belt/unfathomable_curio/proc/shield_reaction(mob/living/carbon/human/owner,
	atom/movable/hitby,
	attack_text = "the attack",
	final_block_chance = 0,
	damage = 0,
	attack_type = MELEE_ATTACK,
	damage_type = BRUTE
)
	SIGNAL_HANDLER

	if(hit_reaction(owner, hitby, attack_text, 0, damage, attack_type) && (owner.belt == src))
		return TRUE
	return NONE

// Our on hit effect
/obj/item/storage/belt/unfathomable_curio/proc/shield_damaged(mob/living/carbon/wearer, attack_text, new_current_charges)
	wearer.visible_message(SPAN_DANGER("[wearer]'s veil makes [attack_text] miss, but the force behind the blow causes it to disperse!"))
	if(IS_HERETIC(wearer))
		return

	to_chat(wearer, SPAN_WARNING("Laughter echoes in your mind...."))
	wearer.adjustBrainLoss(80)


/obj/item/storage/belt/unfathomable_curio/examine(mob/living/carbon/user)
	. = ..()
	if(IS_HERETIC(user))
		return

	user.adjustBrainLoss(10)
	user.EyeBlind(5 SECONDS)
	. += SPAN_NOTICE("It. It looked. IT WRAPS ITSELF AROUND ME.")


