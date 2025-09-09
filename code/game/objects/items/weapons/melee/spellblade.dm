// MARK: SPELLBLADE
/obj/item/melee/spellblade
	name = "spellblade"
	desc = "An enchanted blade with a series of runes along the side."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "spellblade"
	hitsound = 'sound/weapons/rapierhit.ogg'
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	armor_penetration_flat = 50
	sharp = TRUE
	new_attack_chain = TRUE
	///enchantment holder, gives it unique on hit effects.
	var/datum/enchantment/enchant = null
	///the cooldown and power of enchantments are multiplied by this var when its applied
	var/power = 1

/obj/item/melee/spellblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)

/obj/item/melee/spellblade/Destroy()
	QDEL_NULL(enchant)
	return ..()

/obj/item/melee/spellblade/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	enchant?.pre_hit(target, user, src)

/obj/item/melee/spellblade/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	enchant?.on_hit(target, user, src)

/obj/item/melee/spellblade/activate_self(mob/user)
	if(..())
		return
	if(enchant)
		return

	var/static/list/options = list(
		"Lightning" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "chain_lightning"),
		"Fire" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "fire"),
		"Bluespace" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "blink"),
		"Forcewall" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "shield"),
		"Temporal Slash" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "spacetime"),
	)
	var/static/list/options_to_type = list(
		"Lightning" = /datum/enchantment/lightning,
		"Fire" = /datum/enchantment/fire,
		"Bluespace" = /datum/enchantment/bluespace,
		"Forcewall" = /datum/enchantment/forcewall,
		"Temporal Slash" = /datum/enchantment/time_slash,
	)

	var/choice = show_radial_menu(user, src, options)
	if(!choice)
		return
	add_enchantment(options_to_type[choice], user)

/obj/item/melee/spellblade/proc/add_enchantment(new_enchant, mob/living/user, intentional = TRUE)
	var/datum/enchantment/E = new new_enchant
	enchant = E
	E.on_gain(src, user)
	E.power *= power
	E.on_apply_to_blade(src)
	if(intentional)
		SSblackbox.record_feedback("nested tally", "spellblade_enchants", 1, list("[E.name]"))

/obj/item/melee/spellblade/examine(mob/user)
	. = ..()
	if(enchant && (iswizard(user) || IS_CULTIST(user))) // only wizards and cultists understand runes
		. += "The runes along the side read; [enchant.desc]."

/datum/enchantment
	/// used for blackbox logging
	var/name = "You shouldn't be seeing this, file an issue report."
	/// used for wizards/cultists examining the runes on the blade
	var/desc = "Someone messed up, file an issue report."
	/// used for damage values
	var/power = 1
	/// whether the enchant procs despite not being in proximity
	var/ranged = FALSE
	/// stores cooldown between activations.
	var/cooldown = 0
	/// If the spellblade has traits, has it applied them?
	var/applied_traits = FALSE
	COOLDOWN_DECLARE(enchant_cooldown)

/datum/enchantment/proc/on_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/S)
	if(!COOLDOWN_FINISHED(src, enchant_cooldown) || !istype(target) || target.stat == DEAD)
		return FALSE
	return TRUE

/datum/enchantment/proc/pre_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/S)
	if(!ranged || !COOLDOWN_FINISHED(src, enchant_cooldown) || !istype(target) || target.stat == DEAD)
		return FALSE
	return TRUE

/datum/enchantment/proc/on_gain(obj/item/melee/spellblade/S, mob/living/user)
	return

/datum/enchantment/proc/toggle_traits(obj/item/I, mob/living/user)
	return

/datum/enchantment/proc/on_apply_to_blade(obj/item/melee/spellblade/S)
	return

/datum/enchantment/lightning
	name = "lightning"
	desc = "this blade conducts arcane energy to arc between its victims. It also makes the user immune to shocks"
	// the damage of the first lighting arc.
	power = 20
	cooldown = 3 SECONDS

/datum/enchantment/lightning/on_gain(obj/item/melee/spellblade/S, mob/living/user)
	..()
	RegisterSignal(S, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED), PROC_REF(toggle_traits))
	if(user)
		toggle_traits(S, user)

/datum/enchantment/lightning/on_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/S)
	. = ..()
	if(.)
		zap(target, user, list(user), power)
		COOLDOWN_START(src, enchant_cooldown, cooldown)

/datum/enchantment/lightning/toggle_traits(obj/item/I, mob/living/user)
	var/enchant_ID = UID() // so it only removes the traits applied by this specific enchant.
	if(applied_traits)
		REMOVE_TRAIT(user, TRAIT_SHOCKIMMUNE, "[enchant_ID]")
	else
		ADD_TRAIT(user, TRAIT_SHOCKIMMUNE, "[enchant_ID]")
	applied_traits = !applied_traits

/datum/enchantment/lightning/proc/zap(mob/living/target, mob/living/source, protected_mobs, voltage)
	source.Beam(target, "lightning[rand(1,12)]", 'icons/effects/effects.dmi', time = 2 SECONDS, maxdistance = 7, beam_type = /obj/effect/ebeam/chain)
	if(!target.electrocute_act(voltage, "lightning", flags = SHOCK_TESLA)) // if it fails to shock someone, break the chain
		return
	protected_mobs += target
	addtimer(CALLBACK(src, PROC_REF(arc), target, voltage, protected_mobs), 2.5 SECONDS)

/datum/enchantment/lightning/proc/arc(mob/living/source, voltage, protected_mobs)
	voltage = voltage - 4
	if(voltage <= 0)
		return

	for(var/mob/living/L in oview(7, get_turf(source)))
		if(L in protected_mobs)
			continue
		zap(L, source, protected_mobs, voltage)
		break

/datum/enchantment/fire
	name = "fire"
	desc = "this blade ignites on striking a foe, releasing a ball of fire. It also makes the wielder immune to fire"
	cooldown = 8 SECONDS

/datum/enchantment/fire/on_gain(obj/item/melee/spellblade/S, mob/living/user)
	..()
	RegisterSignal(S, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED), PROC_REF(toggle_traits))
	if(user)
		toggle_traits(S, user)

/datum/enchantment/fire/toggle_traits(obj/item/I, mob/living/user)
	var/enchant_ID = UID() // so it only removes the traits applied by this specific enchant.
	if(applied_traits)
		REMOVE_TRAIT(user, TRAIT_NOFIRE, "[enchant_ID]")
		REMOVE_TRAIT(user, TRAIT_RESISTHEAT, "[enchant_ID]")
		applied_traits = FALSE
	else
		ADD_TRAIT(user, TRAIT_RESISTHEAT, "[enchant_ID]")
		ADD_TRAIT(user, TRAIT_NOFIRE, "[enchant_ID]")
		applied_traits = TRUE

/datum/enchantment/fire/on_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/S)
	. = ..()
	if(.)
		fireflash_s(target, 4, 8000 * power, 500)
		COOLDOWN_START(src, enchant_cooldown, cooldown)

/datum/enchantment/forcewall
	name = "forcewall"
	desc = "this blade will partially shield you against attacks and stuns for a short duration after striking a foe"
	cooldown = 4 SECONDS
	// multiplier for how much the cooldown is reduced by. A miner spellblade can only buff every 4 seconds, making it more vunerable, the wizard one is much more consistant.
	power = 2

/datum/enchantment/forcewall/on_apply_to_blade(obj/item/melee/spellblade/S)
	cooldown /= power

/datum/enchantment/forcewall/on_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/S)
	. = ..()
	if(.)
		user.apply_status_effect(STATUS_EFFECT_FORCESHIELD)
		COOLDOWN_START(src, enchant_cooldown, cooldown)

/datum/enchantment/bluespace
	name = "bluespace"
	desc = "this blade will cut through the fabric of space, transporting its wielder over medium distances to strike foes"
	cooldown = 2.5 SECONDS
	ranged = TRUE
	// the number of deciseconds of stun applied by the teleport strike
	power = 5

/datum/enchantment/bluespace/pre_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/S)
	. = ..()
	if(.)
		var/turf/user_turf = get_turf(user)
		if(get_dist(user_turf, get_turf(target)) > 9) //blocks cameras without blocking xray or thermals
			return
		if(!((target in view(9, user)) || user.sight & SEE_MOBS))
			return
		var/list/turfs = list()
		for(var/turf/T in orange(1, get_turf(target)))
			if(T.is_blocked_turf(exclude_mobs = TRUE))
				continue
			turfs += T

		var/target_turf = pick(turfs)
		user_turf.Beam(target_turf, "warp_beam", time = 0.3 SECONDS)
		user.forceMove(target_turf)
		S.melee_attack_chain(user, target)
		target.Weaken(power)
		COOLDOWN_START(src, enchant_cooldown, cooldown)

/datum/enchantment/bluespace/on_apply_to_blade(obj/item/melee/spellblade/S)
	cooldown /= S.power

/datum/enchantment/time_slash
	name = "temporal"
	desc = "this blade will slice faster but weaker, and will curse the target, slashing them a few seconds after they have not been swinged at for each hit"
	power = 20 // This should come out to 32.5 damage per hit. However, delayed.

/datum/enchantment/time_slash/on_apply_to_blade(obj/item/melee/spellblade/S)
	S.force /= 2

/datum/enchantment/time_slash/on_hit(mob/living/target, mob/living/user, obj/item/melee/spellblade/S)
	user.changeNext_move(CLICK_CD_MELEE * 0.5)
	. = ..()
	if(.)
		target.apply_status_effect(STATUS_EFFECT_TEMPORAL_SLASH, power)

/obj/effect/temp_visual/temporal_slash
	name = "temporal slash"
	desc = "A cut through spacetime"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "arcane_barrage"
	layer = FLY_LAYER
	plane = GRAVITY_PULSE_PLANE
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	duration = 0.5 SECONDS
	/// Who we are orbiting
	var/target
	/// A funky color matrix to recolor the slash to
	var/list/funky_color_matrix = list(0.4,0,0,0, 0,1.1,0,0, 0,0,1.65,0, -0.3,0.15,0,1, 0,0,0,0)

/obj/effect/temp_visual/temporal_slash/Initialize(mapload, new_target)
	. = ..()
	target = new_target
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, orbit), target, 0, FALSE, 0, 0, FALSE, TRUE)
	var/matrix/M = matrix()
	M.Scale(1, 2)
	M.Turn(rand(0, 360))
	transform = M
	addtimer(CALLBACK(src, PROC_REF(animate_slash)), 0.25 SECONDS)

/obj/effect/temp_visual/temporal_slash/proc/animate_slash()
	plane = -1
	color = funky_color_matrix
	animate(src, alpha = 0, time = duration, easing = EASE_OUT)

/obj/item/melee/spellblade/random
	power = 0.5

/obj/item/melee/spellblade/random/Initialize(mapload)
	. = ..()
	var/list/options = list(
		/datum/enchantment/lightning,
		/datum/enchantment/fire,
		/datum/enchantment/forcewall,
		/datum/enchantment/bluespace,
		/datum/enchantment/time_slash,
	)

	var/datum/enchantment/E = pick(options)
	add_enchantment(E, intentional = FALSE)
