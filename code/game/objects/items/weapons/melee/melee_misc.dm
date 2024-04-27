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

//Security Sword
/obj/item/melee/secsword
	name = "securiblade"
	desc = "This nanite-honed blade comes with a battery in the hilt, to add an electric shock to every swing."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	var/base_icon = "secsword"
	icon_state = "secsword0"
	item_state = "secsword0"
	flags = CONDUCT
	force = 15
	var/stam_damage = 35 // 3 hits to stamcrit
	var/burn_damage = 10
	throwforce = 5
	w_class = WEIGHT_CLASS_BULKY
	sharp = TRUE
	origin_tech = "combat=4"
	attack_verb = list("stabbed", "slashed", "sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	materials = list(MAT_METAL = 1000)
	needs_permit = TRUE
	/// How much power does it cost to stun someone
	var/stam_hitcost = 1000
	/// How much power does it cost to burn someone
	var/burn_hitcost = 1500
	/// the initial cooldown tracks the time between stamina damage. tracks the world.time when the baton is usable again.
	var/cooldown = 3.5 SECONDS
	var/obj/item/stock_parts/cell/high/cell = null
	var/state = 0 //Sword state 0 - off, 1 - stam, 2 - burn

/obj/item/melee/secsword/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>It is [round(cell.percent())]% charged.</span>"
	. += "<span class='notice'>Can be recharged with a recharger</span>"

/obj/item/melee/secsword/update_icon_state()
	if(!cell)
		icon_state = "[base_icon]3"
		item_state = "[base_icon]0"
	else
		icon_state = "[base_icon][state]"
		item_state = "[base_icon][state]"

/obj/item/melee/secsword/Initialize(mapload)
	. = ..()
	link_new_cell()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 1, _parryable_attack_types = NON_PROJECTILE_ATTACKS)

/obj/item/melee/secsword/proc/link_new_cell(unlink = FALSE)
	if(unlink)
		cell = null
	else
		cell = new(src)

/obj/item/melee/secsword/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = I
		if(cell)
			to_chat(user, "<span class='warning'>[src] already has a cell!</span>")
			return
		if(C.maxcharge < stam_hitcost)
			to_chat(user, "<span class='warning'>[src] requires a higher capacity cell!</span>")
			return
		if(!user.unEquip(I))
			return
		I.forceMove(src)
		cell = I
		to_chat(user, "<span class='notice'>You install [I] into [src].</span>")
		update_icon(UPDATE_ICON_STATE)

/obj/item/melee/secsword/screwdriver_act(mob/living/user, obj/item/I)
	if(!cell)
		to_chat(user, "<span class='warning'>There's no cell installed!</span>")
		return
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	user.put_in_hands(cell)
	to_chat(user, "<span class='notice'>You remove [cell] from [src].</span>")
	cell.update_icon()
	cell = null
	update_icon(UPDATE_ICON_STATE)

/obj/item/melee/secsword/attack_self(mob/user)
	if(!cell)
		state = 0
	else
		state++
	if(state > 2)
		state = 0
	if(state == 0)
		if(!cell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user, "<span class='warning'>[src]'s edge is now turned off.</span>")
	else if(state == 1)
		if(cell.charge < stam_hitcost)
			state = 0
			to_chat(user, "<span class='notice'>[src] does not have enough charge to stun!</span>")
		else
			to_chat(user, "<span class='notice'>[src]'s edge is now set to stun.</span>")
	else
		if(cell.charge < burn_hitcost)
			state = 0
			to_chat(user, "<span class='notice'>[src] does not have enough charge to burn!</span>")
		else
			to_chat(user, "<span class='notice'>[src]'s edge is now set to burn.</span>")
	update_icon()
	add_fingerprint(user)

/obj/item/melee/secsword/attack(mob/M, mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		if(state == 1 && sword_stun(user, user, skip_cooldown = TRUE))
			user.visible_message("<span class='danger'>[user] accidentally hits [user.p_themselves()] with [src]!</span>",
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		return
	if(user.mind?.martial_art?.no_baton && user.mind?.martial_art?.can_use(user)) // Just like the baton, no sword + judo.
		to_chat(user, "<span class='warning'>The sword feels off balance in your hand due to your judo training!</span>")
		return

	if(state == 0) // Off or no battery
		return ..()
	else if(state == 1) // Stamina
		if(issilicon(M)) // Can't stun borgs and AIs
			return ..()
		if(!isliving(M))
			return ..()
		var/mob/living/L = M
		sword_stun(L, user)
		return ..()
	else //Burn
		var/mob/living/L = M
		L.apply_damage(burn_damage, BURN)
		deductcharge(burn_hitcost)
		return ..()


// Returning false results in no attack animation, returning true results in an animation.
/obj/item/melee/secsword/proc/sword_stun(mob/living/L, mob/user, skip_cooldown = FALSE)
	if(cooldown > world.time && !skip_cooldown)
		return FALSE

	var/user_UID = user.UID()
	if(HAS_TRAIT_FROM(L, TRAIT_WAS_BATONNED, user_UID)) // Doesn't work in conjunction with stun batons.
		return FALSE

	cooldown = world.time + initial(cooldown) // Tracks the world.time when hitting will be next available.
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) // No message; check_shields() handles that
			playsound(L, 'sound/weapons/genhit.ogg', 50, TRUE)
			return FALSE
		// Weaker than a stun baton, less bad effects applied
		H.Jitter(5 SECONDS)
		var/obj/item/organ/external/targetlimb = H.get_organ(ran_zone(user.zone_selected))
		H.apply_damage(stam_damage, STAMINA, targetlimb, H.run_armor_check(targetlimb, MELEE))
		H.SetStuttering(5 SECONDS)

	ADD_TRAIT(L, TRAIT_WAS_BATONNED, user_UID) // So a person cannot hit the same person with a sword AND a baton, or two swords
	addtimer(CALLBACK(src, PROC_REF(stun_delay), L, user_UID), 2 SECONDS)
	SEND_SIGNAL(L, COMSIG_LIVING_MINOR_SHOCK, 33)
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	deductcharge(stam_hitcost)
	return TRUE

/obj/item/melee/secsword/proc/stun_delay(mob/living/target, user_UID)
	REMOVE_TRAIT(target, TRAIT_WAS_BATONNED, user_UID)

/obj/item/melee/secsword/proc/deductcharge(amount)
	if(!cell)
		return
	cell.use(amount)
	if(cell.rigged)
		cell = null
		state = 0
		update_icon(UPDATE_ICON_STATE)
	if(cell.charge < (amount)) // If after the deduction the sword doesn't have enough charge for a hit it turns off.
		state = 0
		update_icon(UPDATE_ICON_STATE)

// Traitor Sword
/obj/item/melee/snakesfang
	name = "snakesfang"
	desc = "Sometimes, you do want to bring a knife to a gunfight."
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
	needs_permit = TRUE

// Unathi Sword
/obj/item/melee/breach_cleaver
	name = "clan cleaver"
	desc = "This sharpened chunk of steel is too big and too heavy to be called a sword."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon_state = "secsword0"
	item_state = "secsword0"
	flags = CONDUCT
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_BULKY
	sharp = TRUE
	origin_tech = "combat=6;syndicate=5"
	attack_verb = list("slashed", "cleaved", "chopped")
	hitsound = 'sound/weapons/bladeslice.ogg'
	materials = list(MAT_METAL = 2000)
	needs_permit = TRUE
	armor = list(BULLET = 0, LASER = 0, ENERGY = 0)


/obj/item/melee/breach_cleaver/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_wielded = 40, force_unwielded = force, icon_wielded = "[base_icon_state]1", wield_callback = CALLBACK(src, PROC_REF(wield)), unwield_callback = CALLBACK(src, PROC_REF(unwield)))
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)

/obj/item/melee/breach_cleaver/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += "<span class='warning'>When wielded, this blade has different effects depending on your intent, similar to a martial art. \
			Help intent will strike with the flat, dealing stamina, disarm intent forces them away, grab intent knocks down the target, \
			and harm intent deals heavy damage</span>"

/obj/item/melee/breach_cleaver/update_icon_state()
	icon_state = "secsword0"

/obj/item/melee/breach_cleaver/proc/wield(obj/item/source, mob/user)
	to_chat(user, "<span class='notice'>You heave [src] up in both hands.</span>")
	armor = list(BULLET = 30, LASER = 30, ENERGY = 30)

/obj/item/melee/breach_cleaver/proc/unwield(obj/item/source, mob/user)
	armor = initial(armor)

/obj/item/melee/breach_cleaver/attack(mob/target, mob/living/user)
	armour_penetration_flat = 0
	if(!HAS_TRAIT(src, TRAIT_WIELDED) || !ishuman(target))
		return ..()

	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/targetlimb = H.get_organ(ran_zone(user.zone_selected))

	switch(user.a_intent)
		if(INTENT_HELP) //Stamina damage
			H.visible_message("<span class='danger'>[user] slams [H] with the flat of the blade!</span>", \
							"<span class='userdanger'>[user] slams you with the flat of the blade!</span>", \
							"<span class='italics'>You hear a thud.</span>")
			playsound(loc, 'sound/weapons/genhit2.ogg', 70, TRUE, -1)
			H.AdjustConfused(4 SECONDS, 0, 4 SECONDS)
			H.apply_damage(40, STAMINA, targetlimb, H.run_armor_check(targetlimb, MELEE))
			add_attack_logs(user, H, "Slammed by a breach cleaver.", ATKLOG_ALL)

		if(INTENT_DISARM) //Slams away
			if(H.stat || IS_HORIZONTAL(H))
				return ..()

			H.visible_message("<span class='danger'>[user] smashes [H] with the blade's tip!</span>", \
							"<span class='userdanger'>[user] smashes you with the blade's tip!</span>", \
							"<span class='italics'>You hear crushing.</span>")

			user.do_attack_animation(H, ATTACK_EFFECT_KICK)
			playsound(get_turf(user), 'sound/weapons/sonic_jackhammer.ogg', 50, TRUE, -1)
			H.apply_damage(25, BRUTE, targetlimb, H.run_armor_check(targetlimb, MELEE))
			var/atom/throw_target = get_edge_target_turf(H, get_dir(src, get_step_away(H, src)), TRUE)
			H.throw_at(throw_target, 4, 1)
			add_attack_logs(user, H, "Smashed away by a breach cleaver.", ATKLOG_ALL)

		if(INTENT_GRAB) //Knocks down
			H.visible_message("<span class='danger'>[user] cleaves [H] with an overhead strike!</span>", \
							"<span class='userdanger'>[user] cleaves you with an overhead strike!</span>", \
							"<span class='italics'>You hear a chopping noise.</span>")

			user.do_attack_animation(H, ATTACK_EFFECT_DISARM)
			playsound(get_turf(user), 'sound/weapons/armblade.ogg', 50, TRUE, -1)
			H.apply_damage(30, BRUTE, targetlimb, H.run_armor_check(targetlimb, MELEE), TRUE)
			H.KnockDown(4 SECONDS)
			add_attack_logs(user, H, "Cleaved overhead with a breach cleaver.", ATKLOG_ALL)

		if(INTENT_HARM)
			armour_penetration_flat = 30
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
	if(!(target in view(7, user_turf))) // no camera shenangians
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
