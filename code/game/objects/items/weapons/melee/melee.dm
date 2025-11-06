/obj/item/melee
	icon = 'icons/obj/weapons/melee.dmi'
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	needs_permit = TRUE

// MARK: CAPTAIN'S SABER
/obj/item/melee/saber
	name = "captain's saber"
	desc = "An elegant weapon, for a more civilized age."
	icon_state = "saber"
	inhand_icon_state = "rapier"
	flags = CONDUCT
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	armor_penetration_percentage = 75
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


// MARK: BONE SWORD
/obj/item/melee/bone_sword
	name = "bone sword"
	desc = "A curved blade made of sharpened bone and bound with sinew."
	icon_state = "bone_sword"
	force = 18
	throwforce = 14
	w_class = WEIGHT_CLASS_BULKY
	sharp = TRUE
	attack_verb = list("slashed", "sliced", "chopped")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/melee/bone_sword/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 4, _stamina_coefficient = 0.6, _parryable_attack_types = NON_PROJECTILE_ATTACKS)

#define SECSWORD_OFF 0
#define SECSWORD_STUN 1
#define SECSWORD_BURN 2

// MARK: SECURIBLADE
/obj/item/melee/secsword
	name = "securiblade"
	desc = "A simple, practical blade developed by Shellguard munitions for ‘enhanced’ riot control."
	base_icon_state = "secsword0"
	flags = CONDUCT
	force = 15
	throwforce = 5
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "combat=4"
	attack_verb = list("stabbed", "slashed", "sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'
	materials = list(MAT_METAL = 1000)
	new_attack_chain = TRUE
	/// The icon the sword has when turned off
	var/base_icon = "secsword"
	/// How much stamina damage the sword does in stamina mode
	var/stam_damage = 35 // 3 hits to stamcrit
	/// How much burn damage the sword does in burn mode
	var/burn_damage = 10
	/// How much power does it cost to stun someone
	var/stam_hitcost = 1000
	/// How much power does it cost to burn someone
	var/burn_hitcost = 1500
	/// the initial cooldown tracks the time between stamina damage. tracks the world.time when the baton is usable again.
	var/cooldown = 3.5 SECONDS
	/// The sword's power cell - starts high
	var/obj/item/stock_parts/cell/high/cell
	/// The sword's current mode. Defaults to off.
	var/state = SECSWORD_OFF
	/// Stun cooldown
	COOLDOWN_DECLARE(stun_cooldown)

/obj/item/melee/secsword/Initialize(mapload)
	. = ..()
	cell = new(src)
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 1, _parryable_attack_types = NON_PROJECTILE_ATTACKS)
	update_appearance(UPDATE_ICON_STATE)

/obj/item/melee/secsword/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/melee/secsword/examine(mob/user)
	. = ..()
	if(!cell)
		. += "<span class='notice'>The powercell has been removed!</span>"
		return
	. += "<span class='notice'>It is [round(cell.percent())]% charged.</span>"
	if(round(cell.percent() < 100))
		. += "<span class='notice'>Can be recharged with a recharger.</span>"

/obj/item/melee/secsword/examine_more(mob/user)
	. = ..()
	. += "A simple, practical blade developed by Shellguard munitions for ‘enhanced’ riot control."
	. += ""
	. += "The Securiblade is a simple blade of lightweight silver plasteel, augmented with an energy-emitting edge and with a simple \
	power pack built into the hilt. A multi-purpose option for the NT Officer with a flair for impracticality, the \
	Securiblade serves just as well as a regular sword, as it does a stun weapon or even an energized, heated blade."
	. += ""
	. += "While not the most popular option among the officers of Nanotrasen’s security forces, the Securiblade has still been valued for the multiple options it \
	presents in combat. Deactivated, it’s a simple sword, but powered, it can either be utilized as a useful stun weapon, or as a dangerous, heated blade \
	that can inflict grievous burn wounds on any suspects unfortunate enough to meet an officer using it. Rest assured, the Securiblade is a reliable tool in the hands of a skilled officer."

/obj/item/melee/secsword/update_icon_state()
	if(!cell)
		icon_state = "[base_icon]3"
	else
		icon_state = "[base_icon][state]"

/obj/item/melee/secsword/emp_act(severity)
	if(!cell)
		return
	cell.use(round(cell.charge / severity))
	update_icon()

/obj/item/melee/secsword/get_cell()
	return cell

/obj/item/melee/secsword/proc/clear_cell()
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING
	UnregisterSignal(cell, COMSIG_PARENT_QDELETING)
	cell = null
	update_icon()

/obj/item/melee/secsword/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	. = ..()
	if(!istype(used, /obj/item/stock_parts/cell))
		return ITEM_INTERACT_COMPLETE
	var/obj/item/stock_parts/cell/C = used
	if(cell)
		to_chat(user, "<span class='warning'>[src] already has a cell!</span>")
		return ITEM_INTERACT_COMPLETE
	if(C.maxcharge < stam_hitcost)
		to_chat(user, "<span class='warning'>[src] requires a higher capacity cell!</span>")
		return ITEM_INTERACT_COMPLETE
	if(!user.unequip(used))
		return ITEM_INTERACT_COMPLETE
	used.forceMove(src)
	cell = used
	to_chat(user, "<span class='notice'>You install [used] into [src].</span>")
	update_icon()
	return ITEM_INTERACT_COMPLETE

/obj/item/melee/secsword/screwdriver_act(mob/living/user, obj/item/I)
	if(!cell)
		to_chat(user, "<span class='warning'>There's no cell installed!</span>")
		return
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	user.put_in_hands(cell)
	to_chat(user, "<span class='notice'>You remove [cell] from [src].</span>")
	cell.update_icon()
	clear_cell()

/obj/item/melee/secsword/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK
	if(!cell)
		to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		return FINISH_ATTACK

	add_fingerprint(user)
	if(cell.charge < stam_hitcost || (SECSWORD_STUN && cell.charge < burn_hitcost))
		state = SECSWORD_OFF
		armor_penetration_percentage = 0
		to_chat(user, "<span class='notice'>[src] does not have enough charge!</span>")
		return FINISH_ATTACK
	switch(state)
		if(SECSWORD_OFF)
			state = SECSWORD_STUN
			armor_penetration_percentage = 30
			to_chat(user, "<span class='warning'>[src]'s edge is now set to stun.</span>")
		if(SECSWORD_STUN)
			state = SECSWORD_BURN
			armor_penetration_percentage = 60
			to_chat(user, "<span class='warning'>[src]'s edge is now set to burn.</span>")
		if(SECSWORD_BURN)
			state = SECSWORD_OFF
			armor_penetration_percentage = 0
			to_chat(user, "<span class='notice'>[src]'s edge is now turned off.</span>")
	update_icon()
	playsound(src, "sparks", 60, TRUE, -1)
	return FINISH_ATTACK

/obj/item/melee/secsword/attack(mob/living/M, mob/living/user, params)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		if(state == SECSWORD_STUN && sword_stun(user, user, skip_cooldown = TRUE))
			user.visible_message("<span class='danger'>[user] accidentally hits [user.p_themselves()] with [src]!</span>",
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		return  FINISH_ATTACK | MELEE_COOLDOWN_PREATTACK
	if(user.mind?.martial_art?.no_baton && user.mind?.martial_art?.can_use(user)) // Just like the baton, no sword + judo.
		to_chat(user, "<span class='warning'>The sword feels off-balance in your hand due to your specific martial training!</span>")
		return  FINISH_ATTACK | MELEE_COOLDOWN_PREATTACK

	// Off
	if(!isliving(M) || state == SECSWORD_OFF)
		if(user.a_intent == INTENT_HELP)
			if(!COOLDOWN_FINISHED(src, stun_cooldown))
				return
			if(issilicon(M)) // Can't slap borgs and AIs
				user.do_attack_animation(M)
				M.visible_message(
					"<span class='warning'>[user] has slapped [M] harmlessly with [src].</span>",
					"<span class='danger'>[user] has slapped you harmlessly with [src].</span>"
				)
				return
			slap(M, user) // Just a little slap. No harm
			return
		return ..()

	// Stun mode
	if(state == SECSWORD_STUN)
		if(issilicon(M) && user.a_intent != INTENT_HELP) // Can't stun borgs and AIs
			return ..()
		else if(issilicon(M))
			user.do_attack_animation(M)
			M.visible_message(
				"<span class='warning'>[user] has slapped [M] harmlessly with [src].</span>",
				"<span class='danger'>[user] has slapped you harmlessly with [src].</span>"
			)
			return
		if(sword_stun(M, user))
			user.do_attack_animation(M)
		if(user.a_intent != INTENT_HELP) // Hurt people only if not help
			return ..()
		return
	// Burn
	var/mob/living/L = M
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/external/targetlimb = H.get_organ(ran_zone(user.zone_selected))
		H.apply_damage(burn_damage, BURN, targetlimb, H.run_armor_check(targetlimb, MELEE, armor_penetration_percentage = armor_penetration_percentage))
	else
		L.apply_damage(burn_damage, BURN)
	deduct_charge(burn_hitcost)
	return ..()

/obj/item/melee/secsword/proc/slap(mob/living/carbon/human/target, mob/living/user)
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(loc, 'sound/effects/woodhit.ogg', 50, TRUE, -1)
	target.AdjustConfused(4 SECONDS, 0, 4 SECONDS)
	target.apply_damage(10, STAMINA)
	add_attack_logs(user, target, "Slapped by [src]", ATKLOG_ALL)
	COOLDOWN_START(src, stun_cooldown, cooldown) // Shares cooldown with stun to avoid comboing slap into stun

/obj/item/melee/secsword/proc/sword_stun(mob/living/L, mob/user, skip_cooldown = FALSE)
	if(!COOLDOWN_FINISHED(src, stun_cooldown) && !skip_cooldown)
		return FALSE

	var/user_UID = user.UID()
	if(HAS_TRAIT_FROM(L, TRAIT_WAS_BATONNED, user_UID)) // Doesn't work in conjunction with stun batons.
		return FALSE

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) // No message; check_shields() handles that
			playsound(L, 'sound/weapons/genhit.ogg', 50, TRUE)
			return TRUE
		// Weaker than a stun baton, less bad effects applied
		H.Jitter(6 SECONDS)
		H.AdjustConfused(4 SECONDS, 0, 4 SECONDS)
		H.SetStuttering(6 SECONDS)
		var/obj/item/organ/external/targetlimb = H.get_organ(ran_zone(user.zone_selected))
		H.apply_damage(stam_damage, STAMINA, targetlimb, H.run_armor_check(targetlimb, MELEE))
		deduct_charge(stam_hitcost)

	ADD_TRAIT(L, TRAIT_WAS_BATONNED, user_UID) // So a person cannot hit the same person with a sword AND a baton, or two swords
	addtimer(CALLBACK(src, PROC_REF(stun_delay), L, user_UID), 2 SECONDS)
	SEND_SIGNAL(L, COMSIG_LIVING_MINOR_SHOCK, 33)
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	COOLDOWN_START(src, stun_cooldown, cooldown)
	return TRUE

// Proc called to remove trait that prevents repeated stamina damage. Called on a 2 Second timer when hit in stun mode
/obj/item/melee/secsword/proc/stun_delay(mob/living/target, user_UID)
	REMOVE_TRAIT(target, TRAIT_WAS_BATONNED, user_UID)

/obj/item/melee/secsword/proc/deduct_charge(amount)
	if(!cell)
		return
	if(cell.rigged)
		RegisterSignal(cell, COMSIG_PARENT_QDELETING, PROC_REF(clear_cell))
	cell.use(amount)
	if(cell.charge < amount) // If after the deduction the sword doesn't have enough charge for a hit it turns off.
		state = SECSWORD_OFF
		armor_penetration_percentage = 0
		playsound(src, "sparks", 60, TRUE, -1)
	update_icon()

#undef SECSWORD_OFF
#undef SECSWORD_STUN
#undef SECSWORD_BURN

// MARK: SNAKESFANG
/obj/item/melee/snakesfang
	name = "snakesfang"
	desc = "A uniquely curved, black and red sword. Extra-edgy and cutting-edge."
	icon_state = "snakesfang"
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

// MARK: BREACH CLEAVER
/obj/item/melee/breach_cleaver
	name = "breach cleaver"
	desc = "Massive, heavy, and utterly impractical. This sharpened chunk of steel is too big and too heavy to be called a sword."
	base_icon_state = "breach_cleaver"
	icon_state = "breach_cleaver0"
	flags = CONDUCT
	force = 5
	throwforce = 5
	armor_penetration_flat = 30
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

// MARK: CHAINSAW
/obj/item/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "gchainsaw"
	base_icon_state = "gchainsaw"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	hitsound = "swing_hit"
	attack_verb = list("sawed", "cut", "hacked", "carved", "cleaved", "butchered", "felled", "timbered")
	origin_tech = "materials=3;engineering=4;combat=2"
	materials = list(MAT_METAL = 13000)
	w_class = WEIGHT_CLASS_HUGE
	needs_permit = TRUE
	flags = CONDUCT
	sharp = TRUE
	force = 13
	throwforce = 13 // how
	throw_range = 4
	var/force_on = 24
	new_attack_chain = TRUE

// These 2 are currently used by syndie chainsaw
/obj/item/chainsaw/proc/wield()
	return

/obj/item/chainsaw/proc/unwield()
	return

/obj/item/chainsaw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed,					\
		icon_wielded = "[icon_state]_on",						\
		force_wielded = force_on,								\
		force_unwielded = force,								\
		attacksound = 'sound/weapons/chainsaw.ogg',				\
		wieldsound = 'sound/weapons/chainsawstart.ogg',			\
		wield_callback = CALLBACK(src, PROC_REF(wield)),		\
		unwield_callback = CALLBACK(src, PROC_REF(unwield)),	\
	)

/obj/item/chainsaw/update_icon_state()
	icon_state = base_icon_state

// MARK: SYNDIE CHAINSAW
/obj/item/chainsaw/syndie
	desc = "Perfect for felling trees or fellow spacemen."
	icon_state = "chainsaw"
	base_icon_state = "chainsaw"
	origin_tech = "materials=6;syndicate=4"
	flags_2 = RANDOM_BLOCKER_2
	w_class = WEIGHT_CLASS_BULKY // can't fit in backpacks
	force = 15
	throwforce = 15
	force_on = 40
	throw_speed = 1
	throw_range = 5
	armor_penetration_percentage = 50
	armor_penetration_flat = 10

/obj/item/chainsaw/syndie/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/butchers_humans)

/obj/item/chainsaw/syndie/wield() // you can't disarm an active chainsaw, you crazy person.
	set_nodrop(TRUE, loc)

/obj/item/chainsaw/syndie/unwield()
	set_nodrop(FALSE, loc)

/obj/item/chainsaw/syndie/attack(mob/living/target, mob/living/user, params)
	if(..())
		return FINISH_ATTACK
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		target.KnockDown(8 SECONDS)
		if(target.stat != DEAD && !isrobot(target) && user.reagents.get_reagent_amount("mephedrone") <= 15)
			user.apply_status_effect(STATUS_EFFECT_CHAINSAW_SLAYING)

/obj/item/chainsaw/syndie/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if((attack_type in NON_PROJECTILE_ATTACKS) && owner.has_status_effect(STATUS_EFFECT_CHAINSAW_SLAYING)) // It's a chainsaw, you can't block projectiles with it
		final_block_chance = 80 // Need to be ready to ruuuummbllleeee
	return ..()

// MARK: SLAYER CHAINSAW
/obj/item/chainsaw/doomslayer
	name = "OOOH BABY"
	desc = "<span class='warning'>VRRRRRRR!!!</span>"
	armor_penetration_percentage = 100
	force_on = 30

/obj/item/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message("<span class='danger'>Ranged attacks just make [owner] angrier!</span>")
		playsound(src, pick('sound/weapons/bulletflyby.ogg','sound/weapons/bulletflyby2.ogg','sound/weapons/bulletflyby3.ogg'), 75, 1)
		return TRUE
	return FALSE
