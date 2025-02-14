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
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=5"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/slash.ogg' //pls replace


/obj/item/melee/chainofcommand/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='suicide'>[user] is strangling [user.p_themselves()] with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return OXYLOSS

/obj/item/melee/saber
	name = "captain's saber"
	desc = "An elegant weapon, for a more civilized age."
	icon_state = "saber"
	item_state = "saber"
	flags = CONDUCT
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration_percentage = 75
	sharp = TRUE
	origin_tech = null
	attack_verb = list("lunged at", "stabbed")
	hitsound = 'sound/weapons/rapierhit.ogg'
	materials = list(MAT_METAL = 1000)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF // Theft targets should be hard to destroy
	// values for slapping
	var/slap_sound = 'sound/effects/woodhit.ogg'
	COOLDOWN_DECLARE(slap_cooldown)

/obj/item/melee/saber/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The blade looks very well-suited for piercing armour.</span>"

/obj/item/melee/saber/examine_more(mob/user)
	. = ..()
	. += "Swords are a traditional ceremonial weapon carried by commanding officers of many armies and navies, even long after firearms and laserarms rendered them obsolete. \
	Despite having no roots in such traditions, Nanotrasen participates in them, as these trappings of old tradition help to promote the air of authority the company wishes for its captains to possess."
	. += ""
	. += "Whilst not intended to actually be used in combat, the ceremonial blades issued by Nanotrasen are in-fact quite functional, \
	able to both inflict grievous wounds on aggressors that get too close, whilst also elegantly parrying their blows (assuming the wielder is skilled with the blade). \
	The sharp edge is adept at hacking unarmored targets, whilst the rigid tip is also quite effective at at defeating even modern body armor with thrusting attacks, as modern armor is generally designed to defeat ballistic and laser weapons rather than swords..."

/obj/item/melee/saber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)
	AddElement(/datum/element/high_value_item)

/obj/item/melee/saber/attack__legacy__attackchain(mob/living/target, mob/living/user)
	if(user.a_intent != INTENT_HELP || !ishuman(target))
		return ..()
	if(!COOLDOWN_FINISHED(src, slap_cooldown))
		return
	var/mob/living/carbon/human/H = target
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally slaps [user.p_themselves()] with [src]!</span>", \
							"<span class='userdanger'>You accidentally slap yourself with [src]!</span>")
		slap(user, user)
	else
		user.visible_message("<span class='danger'>[user] slaps [H] with the flat of the blade!</span>", \
							"<span class='userdanger'>You slap [H] with the flat of the blade!</span>")
		slap(target, user)

/obj/item/melee/saber/proc/slap(mob/living/carbon/human/target, mob/living/user)
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(loc, slap_sound, 50, TRUE, -1)
	target.AdjustConfused(4 SECONDS, 0, 4 SECONDS)
	target.apply_damage(10, STAMINA)
	add_attack_logs(user, target, "Slapped by [src]", ATKLOG_ALL)
	COOLDOWN_START(src, slap_cooldown, 4 SECONDS)

/obj/item/melee/saber/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting [user.p_their()] stomach open with [src]! It looks like [user.p_theyre()] trying to commit seppuku!</span>", \
						"<span class='suicide'>[user] is falling on [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>"))
	return BRUTELOSS

// Traitor Sword
/obj/item/melee/snakesfang
	name = "snakesfang"
	desc = "A uniquely curved, black and red sword. Extra-edgy and cutting-edge."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon_state = "snakesfang"
	item_state = "snakesfang"
	flags = CONDUCT
	force = 25
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	sharp = TRUE
	origin_tech = "combat=6;syndicate=3"
	attack_verb = list("slashed", "sliced", "chopped")
	hitsound = 'sound/weapons/bladeslice.ogg'
	materials = list(MAT_METAL = 1000)

/obj/item/melee/snakesfang/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)

/obj/item/melee/snakesfang/examine_more(mob/user)
	. = ..()
	. += "A uniquely curved, black and red sword. Extra-edgy and cutting-edge."
	. += ""
	. += "The MK-IV Enhanced Combat Blade, more colloquially known as the ‘Snakesfang’, is a vicious yet stylish weapon designed \
	by a relatively unknown weapons forge with known ties to the Syndicate. With a wide, curved blade and dual points \
	resembling the fangs of the organization’s serpent motif, the Snakesfang is a statement like no other."
	. += ""
	. += "While the benefits of its unique design are dubious at best, the Snakesfang is undoubtedly a perilous weapon, with a hardened \
	plastitanium edge that can cause untold harm to a soft target. In the right hands, it can be a terrifying weapon to behold, \
	and it’s said that blood runs down the blade in just the right way, to drip artfully from the twin ‘fangs’ at its apex."

// Unathi Sword
/obj/item/melee/breach_cleaver
	name = "breach cleaver"
	desc = "Massive, heavy, and utterly impractical. This sharpened chunk of steel is too big and too heavy to be called a sword."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	base_icon_state = "breach_cleaver"
	icon_state = "breach_cleaver0"
	flags = CONDUCT
	force = 5
	throwforce = 5
	armour_penetration_flat = 30
	w_class = WEIGHT_CLASS_BULKY
	sharp = TRUE
	origin_tech = "combat=6;syndicate=5"
	attack_verb = list("slashed", "cleaved", "chopped")
	hitsound = 'sound/weapons/swordhitheavy.ogg'
	materials = list(MAT_METAL = 2000)
	/// How much damage the sword does when wielded
	var/force_wield = 40

/obj/item/melee/breach_cleaver/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_wielded = force_wield, force_unwielded = force, icon_wielded = "[base_icon_state]1", wield_callback = CALLBACK(src, PROC_REF(wield)), unwield_callback = CALLBACK(src, PROC_REF(unwield)))
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)

/obj/item/melee/breach_cleaver/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += "<span class='notice'>When wielded, this blade has different effects depending on your intent, similar to a martial art. \
			Help intent will strike with the flat, dealing stamina, disarm intent forces them away, grab intent knocks down the target, \
			and harm intent deals heavy damage.</span>"

/obj/item/melee/breach_cleaver/examine_more(mob/user)
	. = ..()
	. += "Massive, heavy, and utterly impractical. This sharpened chunk of steel is too big and too heavy to be called a sword."
	. += ""
	. += "The Unathi Breach Cleaver is a weapon the scaled, warlike race favours for its impressive weight and myriad combat applications. \
	The pinnacle of Moghes' combat technology, it combines all of this knowledge into a massive, heavy slab of alloyed metal that most \
	species find difficult to lift, let alone use in any sort of fight."
	. += ""
	. += "Actually a little lightweight for its size, a Breach Cleaver is unmatched in combat utility as a weapon, a tool for getting into\
	places and as a slab of armour for the wielder. The leather of the Kar'oche beast, a predator native to Moghes, binds the hilt, \
	allowing it to be gripped securely by its warrior. The wide blade is often etched with scenes depicting military victories or great hunts."

/obj/item/melee/breach_cleaver/update_icon_state()
	icon_state = "[base_icon_state]0"

/obj/item/melee/breach_cleaver/proc/wield(obj/item/source, mob/living/carbon/human/user)
	to_chat(user, "<span class='notice'>You heave [src] up in both hands.</span>")
	user.apply_status_effect(STATUS_EFFECT_BREACH_AND_CLEAVE)
	update_icon(UPDATE_ICON_STATE)

/obj/item/melee/breach_cleaver/proc/unwield(obj/item/source, mob/living/carbon/human/user)
	user.remove_status_effect(STATUS_EFFECT_BREACH_AND_CLEAVE)
	update_icon(UPDATE_ICON_STATE)

/obj/item/melee/breach_cleaver/attack_obj__legacy__attackchain(obj/O, mob/living/user, params)
	if(!HAS_TRAIT(src, TRAIT_WIELDED)) // Only works good when wielded
		return ..()
	if(!ismachinery(O) && !isstructure(O)) // This sword hates doors
		return ..()
	if(SEND_SIGNAL(src, COMSIG_ATTACK_OBJ, O, user) & COMPONENT_NO_ATTACK_OBJ)
		return
	if(flags & (NOBLUDGEON))
		return
	var/mob/living/carbon/human/H = user
	H.changeNext_move(CLICK_CD_MELEE)
	H.do_attack_animation(O)
	H.visible_message("<span class='danger'>[H] has hit [O] with [src]!</span>", "<span class='danger'>You hit [O] with [src]!</span>")
	var/damage = force_wield
	damage += H.physiology.melee_bonus
	O.take_damage(damage * 3, BRUTE, MELEE, TRUE, get_dir(src, H), 30) // Multiplied to do big damage to doors, closets, windows, and machines, but normal damage to mobs.

/obj/item/melee/breach_cleaver/attack__legacy__attackchain(mob/target, mob/living/user)
	if(!HAS_TRAIT(src, TRAIT_WIELDED) || !ishuman(target))
		return ..()

	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/targetlimb = H.get_organ(ran_zone(user.zone_selected))

	switch(user.a_intent)
		if(INTENT_HELP) // Stamina damage
			H.visible_message("<span class='danger'>[user] slams [H] with the flat of the blade!</span>", \
							"<span class='userdanger'>[user] slams you with the flat of the blade!</span>", \
							"<span class='italics'>You hear a thud.</span>")
			user.do_attack_animation(H, ATTACK_EFFECT_DISARM)
			playsound(loc, 'sound/weapons/swordhit.ogg', 50, TRUE, -1)
			H.AdjustConfused(4 SECONDS, 0, 4 SECONDS)
			H.apply_damage(40, STAMINA, targetlimb, H.run_armor_check(targetlimb, MELEE))
			add_attack_logs(user, H, "Slammed by a breach cleaver. (Help intent, Stamina)", ATKLOG_ALL)

		if(INTENT_DISARM) // Slams away
			if(H.stat != CONSCIOUS || IS_HORIZONTAL(H))
				return ..()

			H.visible_message("<span class='danger'>[user] smashes [H] with the blade's tip!</span>", \
							"<span class='userdanger'>[user] smashes you with the blade's tip!</span>", \
							"<span class='italics'>You hear crushing.</span>")

			user.do_attack_animation(H, ATTACK_EFFECT_KICK)
			playsound(get_turf(user), 'sound/weapons/sonic_jackhammer.ogg', 50, TRUE, -1)
			H.apply_damage(25, BRUTE, targetlimb, H.run_armor_check(targetlimb, MELEE))
			var/atom/throw_target = get_edge_target_turf(H, user.dir, TRUE)
			H.throw_at(throw_target, 4, 1)
			add_attack_logs(user, H, "Smashed away by a breach cleaver. (Disarm intent, Knockback)", ATKLOG_ALL)

		if(INTENT_GRAB) // Knocks down
			H.visible_message("<span class='danger'>[user] cleaves [H] with an overhead strike!</span>", \
							"<span class='userdanger'>[user] cleaves you with an overhead strike!</span>", \
							"<span class='italics'>You hear a chopping noise.</span>")

			user.do_attack_animation(H, ATTACK_EFFECT_DISARM)
			playsound(get_turf(user), 'sound/weapons/armblade.ogg', 50, TRUE, -1)
			H.apply_damage(30, BRUTE, targetlimb, H.run_armor_check(targetlimb, MELEE), TRUE)
			H.KnockDown(4 SECONDS)
			add_attack_logs(user, H, "Cleaved overhead with a breach cleaver. (Grab intent, Knockdown)", ATKLOG_ALL)

		if(INTENT_HARM)
			return ..()

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

/obj/item/melee/flyswatter/attack__legacy__attackchain(mob/living/M, mob/living/user, def_zone)
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

/obj/item/melee/spellblade/afterattack__legacy__attackchain(atom/target, mob/user, proximity, params)
	. = ..()
	enchant?.on_hit(target, user, proximity, src)

/obj/item/melee/spellblade/attack_self__legacy__attackchain(mob/user)
	if(enchant)
		return

	var/static/list/options = list("Lightning" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "chain_lightning"),/// todo add icons for these
							"Fire" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "fire"),
							"Bluespace" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "blink"),
							"Forcewall" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "shield"),
							"Temporal Slash" = image(icon = 'icons/effects/spellblade.dmi', icon_state = "spacetime"),)
	var/static/list/options_to_type = list("Lightning" = /datum/enchantment/lightning,
									"Fire" = /datum/enchantment/fire,
									"Bluespace" = /datum/enchantment/bluespace,
									"Forcewall" = /datum/enchantment/forcewall,
									"Temporal Slash" = /datum/enchantment/time_slash,)

	var/choice = show_radial_menu(user, src, options)
	if(!choice)
		return
	add_enchantment(options_to_type[choice], user)

/obj/item/melee/spellblade/proc/add_enchantment(new_enchant, mob/living/user, intentional = TRUE)
	var/datum/enchantment/E = new new_enchant
	enchant = E
	E.on_apply_to_blade(src)
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
	/// A modifier that can be appled to the cooldown after the enchantment has been initialized. Used by the forcewall spellblade
	var/cooldown_multiplier = 1

/datum/enchantment/proc/on_hit(mob/living/target, mob/living/user, proximity, obj/item/melee/spellblade/S)
	if(world.time < cooldown)
		return FALSE
	if(!istype(target))
		return FALSE
	if(target.stat == DEAD)
		return FALSE
	if(!ranged && !proximity)
		return FALSE
	cooldown = world.time + (initial(cooldown) * cooldown_multiplier)
	return TRUE

/datum/enchantment/proc/on_gain(obj/item/melee/spellblade, mob/living/user)
	return

/datum/enchantment/proc/toggle_traits(obj/item/I, mob/living/user)
	return

/datum/enchantment/proc/on_apply_to_blade(obj/item/melee/spellblade)
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
	// multiplier for how much the cooldown is reduced by. A miner spellblade can only buff every 4 seconds, making it more vunerable, the wizard one is much more consistant.
	power = 2

/datum/enchantment/forcewall/on_apply_to_blade(obj/item/melee/spellblade)
	cooldown_multiplier /= power

/datum/enchantment/forcewall/on_hit(mob/living/target, mob/living/user, proximity, obj/item/melee/spellblade/S)
	. = ..()
	if(!.)
		return
	user.apply_status_effect(STATUS_EFFECT_FORCESHIELD)

/datum/enchantment/bluespace
	name = "bluespace"
	desc = "this blade will cut through the fabric of space, transporting its wielder over medium distances to strike foes"
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

/datum/enchantment/time_slash
	name = "temporal"
	desc = "this blade will slice faster but weaker, and will curse the target, slashing them a few seconds after they have not been swinged at for each hit"
	power = 15 // This should come out to 40 damage per hit. However, delayed.

/datum/enchantment/time_slash/on_apply_to_blade(obj/item/melee/spellblade)
	spellblade.force /= 2

/datum/enchantment/time_slash/on_hit(mob/living/target, mob/living/user, proximity, obj/item/melee/spellblade/S)
	user.changeNext_move(CLICK_CD_MELEE * 0.5)
	. = ..()
	if(!.)
		return
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
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT // Let us not have this visual block clicks
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
	var/list/options = list(/datum/enchantment/lightning,
							/datum/enchantment/fire,
							/datum/enchantment/forcewall,
							/datum/enchantment/bluespace,
							/datum/enchantment/time_slash,)
	var/datum/enchantment/E = pick(options)
	add_enchantment(E, intentional = FALSE)
