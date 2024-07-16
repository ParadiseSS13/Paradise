/obj/item/melee
	icon = 'icons/obj/weapons/melee.dmi'
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	needs_permit = TRUE

/obj/item/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=5"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/slash.ogg' //pls replace


/obj/item/melee/chainofcommand/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='suicide'>[user] is strangling [user.p_themselves()] with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS

/obj/item/melee/rapier
	name = "captain's rapier"
	desc = "An elegant weapon, for a more civilized age."
	icon_state = "rapier"
	item_state = "rapier"
	flags = CONDUCT
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration_percentage = 75
	sharp = TRUE
	origin_tech = "combat=5"
	attack_verb = list("lunged at", "stabbed")
	hitsound = 'sound/weapons/rapierhit.ogg'
	materials = list(MAT_METAL = 1000)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF // Theft targets should be hard to destroy

/obj/item/melee/rapier/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(alert_admins_on_destroy))

/obj/item/melee/icepick
	name = "ice pick"
	desc = "Used for chopping ice. Also excellent for mafia esque murders."
	icon_state = "icepick"
	item_state = "icepick"
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("stabbed", "jabbed", "iced,")

/obj/item/melee/candy_sword
	name = "candy cane sword"
	desc = "A large candy cane with a sharpened point. Definitely too dangerous for schoolchildren."
	icon_state = "candy_sword"
	item_state = "candy_sword"
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("slashed", "stabbed", "sliced", "caned")

/obj/item/melee/flyswatter
	name = "flyswatter"
	desc = "Useful for killing insects of all sizes."
	icon_state = "flyswatter"
	item_state = "flyswatter"
	force = 1
	throwforce = 1
	attack_verb = list("swatted", "smacked")
	hitsound = 'sound/effects/snap.ogg'
	w_class = WEIGHT_CLASS_SMALL
	//Things in this list will be instantly splatted.  Flyman weakness is handled in the flyman species weakness proc.
	var/list/strong_against

/obj/item/melee/flyswatter/Initialize(mapload)
	. = ..()
	strong_against = typecacheof(list(
					/mob/living/simple_animal/hostile/poison/bees/,
					/mob/living/simple_animal/butterfly,
					/mob/living/simple_animal/cockroach,
					/obj/item/queen_bee))
	strong_against -= /mob/living/simple_animal/hostile/poison/bees/syndi // Syndi-bees have special anti-flyswatter tech installed

/obj/item/melee/flyswatter/attack(mob/living/M, mob/living/user, def_zone)
	. = ..()
	if(is_type_in_typecache(M, strong_against))
		new /obj/effect/decal/cleanable/insectguts(M.drop_location())
		user.visible_message("<span class='warning'>[user] splats [M] with [src].</span>",
			"<span class='warning'>You splat [M] with [src].</span>",
			"<span class='warning'>You hear a splat.</span>")
		if(isliving(M))
			var/mob/living/bug = M
			bug.death(TRUE)
		if(!QDELETED(M))
			qdel(M)

/obj/item/melee/spellblade
	name = "spellblade"
	desc = "An enchanted blade with a series of runes along the side."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "spellblade"
	item_state = "spellblade"
	hitsound = 'sound/weapons/rapierhit.ogg'
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	armour_penetration_flat = 50
	sharp = TRUE
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

/obj/item/melee/spellblade/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	enchant?.on_hit(target, user, proximity, src)

/obj/item/melee/spellblade/attack_self(mob/user)
	if(enchant)
		return

	var/static/list/options = list("Lightning" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "chain_lightning"),/// todo add icons for these
							"Fire" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "fire"),
							"Bluespace" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "blink"),
							"Forcewall" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "shield"),)
	var/static/list/options_to_type = list("Lightning" = /datum/enchantment/lightning,
									"Fire" = /datum/enchantment/fire,
									"Bluespace" = /datum/enchantment/bluespace,
									"Forcewall" = /datum/enchantment/forcewall,)

	var/choice = show_radial_menu(user, src, options)
	if(!choice)
		return
	add_enchantment(options_to_type[choice], user)

/obj/item/melee/spellblade/proc/add_enchantment(new_enchant, mob/living/user, intentional = TRUE)
	var/datum/enchantment/E = new new_enchant
	enchant = E
	E.on_gain(src, user)
	E.power *= power
	if(intentional)
		SSblackbox.record_feedback("nested tally", "spellblade_enchants", 1, list("[E.name]"))

/obj/item/melee/spellblade/examine(mob/user)
	. = ..()
	if(enchant && (iswizard(user) || IS_CULTIST(user))) // only wizards and cultists understand runes
		. += "The runes along the side read; [enchant.desc]."


/obj/item/melee/spellblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0
	return ..()

/datum/enchantment
	/// used for blackbox logging
	var/name = "You shouldn't be seeing this, file an issue report."
	/// used for wizards/cultists examining the runes on the blade
	var/desc = "Someone messed up, file an issue report."
	/// used for damage values
	var/power = 1
	/// whether the enchant procs despite not being in proximity
	var/ranged = FALSE
	/// stores the world.time after which it can be used again, the `initial(cooldown)` is the cooldown between activations.
	var/cooldown = -1
	/// If the spellblade has traits, has it applied them?
	var/applied_traits = FALSE

/datum/enchantment/proc/on_hit(mob/living/target, mob/living/user, proximity, obj/item/melee/spellblade/S)
	if(world.time < cooldown)
		return FALSE
	if(!istype(target))
		return FALSE
	if(target.stat == DEAD)
		return FALSE
	if(!ranged && !proximity)
		return FALSE
	cooldown = world.time + initial(cooldown)
	return TRUE

/datum/enchantment/proc/on_gain(obj/item/melee/spellblade, mob/living/user)
	return

/datum/enchantment/proc/toggle_traits(obj/item/I, mob/living/user)
	return

/datum/enchantment/lightning
	name = "lightning"
	desc = "this blade conducts arcane energy to arc between its victims. It also makes the user immune to shocks."
	// the damage of the first lighting arc.
	power = 20
	cooldown = 3 SECONDS

/datum/enchantment/lightning/on_gain(obj/item/melee/spellblade/S, mob/living/user)
	..()
	RegisterSignal(S, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED), PROC_REF(toggle_traits))
	if(user)
		toggle_traits(S, user)


/datum/enchantment/lightning/on_hit(mob/living/target, mob/living/user, proximity, obj/item/melee/spellblade/S)
	. = ..()
	if(.)
		zap(target, user, list(user), power)

/datum/enchantment/lightning/toggle_traits(obj/item/I, mob/living/user)
	var/enchant_ID = UID(src) // so it only removes the traits applied by this specific enchant.
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
	var/enchant_ID = UID(src) // so it only removes the traits applied by this specific enchant.
	if(applied_traits)
		REMOVE_TRAIT(user, TRAIT_NOFIRE, "[enchant_ID]")
		REMOVE_TRAIT(user, TRAIT_RESISTHEAT, "[enchant_ID]")
		applied_traits = FALSE
	else
		ADD_TRAIT(user, TRAIT_RESISTHEAT, "[enchant_ID]")
		ADD_TRAIT(user, TRAIT_NOFIRE, "[enchant_ID]")
		applied_traits = TRUE

/datum/enchantment/fire/on_hit(mob/living/target, mob/living/user, proximity, obj/item/melee/spellblade/S)
	. = ..()
	if(.)
		fireflash_s(target, 4, 8000 * power, 500)

/datum/enchantment/forcewall
	name = "forcewall"
	desc = "this blade will partially shield you against attacks and stuns for a short duration after striking a foe"
	cooldown = 4 SECONDS

/datum/enchantment/forcewall/on_hit(mob/living/target, mob/living/user, proximity, obj/item/melee/spellblade/S)
	. = ..()
	if(!.)
		return
	user.apply_status_effect(STATUS_EFFECT_FORCESHIELD)

/datum/enchantment/bluespace
	name = "bluespace"
	desc = "this the fabric of space, transporting its wielder over medium distances to strike foes"
	cooldown = 2.5 SECONDS
	ranged = TRUE
	// the number of deciseconds of stun applied by the teleport strike
	power = 5

/datum/enchantment/bluespace/on_hit(mob/living/target, mob/living/user, proximity, obj/item/melee/spellblade/S)
	if(proximity) // don't put it on cooldown if adjacent
		return
	. = ..()
	if(!.)
		return
	var/turf/user_turf = get_turf(user)
	if(get_dist(user_turf, get_turf(target)) > 9) //blocks cameras without blocking xray or thermals
		return
	if(!((target in view(9, user)) || user.sight & SEE_MOBS))
		return
	var/list/turfs = list()
	for(var/turf/T in orange(1, get_turf(target)))
		if(is_blocked_turf(T, TRUE))
			continue
		turfs += T

	var/target_turf = pick(turfs)
	user_turf.Beam(target_turf, "warp_beam", time = 0.3 SECONDS)
	user.forceMove(target_turf)
	S.melee_attack_chain(user, target)
	target.Weaken(power)

/obj/item/melee/spellblade/random
	power = 0.5

/obj/item/melee/spellblade/random/Initialize(mapload)
	. = ..()
	var/list/options = list(/datum/enchantment/lightning,
							/datum/enchantment/fire,
							/datum/enchantment/forcewall,
							/datum/enchantment/bluespace,)
	var/datum/enchantment/E = pick(options)
	add_enchantment(E, intentional = FALSE)
