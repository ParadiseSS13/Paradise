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

// MARK: SNAKESFANG
/obj/item/melee/snakesfang
	name = "snakesfang"
	desc = "A uniquely curved, black and red sword. Extra-edgy and cutting-edge."
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

// MARK: BREACH CLEAVER
/obj/item/melee/breach_cleaver
	name = "breach cleaver"
	desc = "Massive, heavy, and utterly impractical. This sharpened chunk of steel is too big and too heavy to be called a sword."
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

// MARK: CHAINSAW
/obj/item/melee/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon_state = "gchainsaw"
	base_icon_state = "gchainsaw"
	hitsound = "swing_hit"
	attack_verb = list("sawed", "cut", "hacked", "carved", "cleaved", "butchered", "felled", "timbered")
	origin_tech = "materials=3;engineering=4;combat=2"
	materials = list(MAT_METAL = 13000)
	w_class = WEIGHT_CLASS_HUGE
	flags = CONDUCT
	sharp = TRUE
	force = 13
	throwforce = 13 // how
	throw_range = 4
	var/force_on = 24
	new_attack_chain = TRUE

// These 2 are currently used by syndie chainsaw
/obj/item/melee/chainsaw/proc/wield()
	return

/obj/item/melee/chainsaw/proc/unwield()
	return

/obj/item/melee/chainsaw/update_icon_state()
	icon_state = base_icon_state

/obj/item/melee/chainsaw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		icon_wielded = "[icon_state]_on", \
		force_wielded = force_on, \
		force_unwielded = force, \
		attacksound = 'sound/weapons/chainsaw.ogg',\
		wieldsound = 'sound/weapons/chainsawstart.ogg', \
		wield_callback = CALLBACK(src, PROC_REF(wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(unwield)))

// MARK: SYNDIE CHAINSAW
/obj/item/melee/chainsaw/syndie
	desc = "Perfect for felling trees or fellow spacemen."
	icon_state = "chainsaw"
	base_icon_state = "chainsaw"
	origin_tech = "materials=6;syndicate=4"
	w_class = WEIGHT_CLASS_BULKY // can't fit in backpacks
	force = 15
	throwforce = 15
	force_on = 40
	throw_speed = 1
	throw_range = 5
	armour_penetration_percentage = 50
	armour_penetration_flat = 10
	flags_2 = RANDOM_BLOCKER_2

/obj/item/melee/chainsaw/syndie/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/butchers_humans)

/obj/item/melee/chainsaw/syndie/wield() // you can't disarm an active chainsaw, you crazy person.
	set_nodrop(TRUE, loc)

/obj/item/melee/chainsaw/syndie/unwield()
	set_nodrop(FALSE, loc)

/obj/item/melee/chainsaw/syndie/attack(mob/living/target, mob/living/user, params)
	if(..())
		return FINISH_ATTACK
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		target.KnockDown(8 SECONDS)
		if(target.stat != DEAD && !isrobot(target) && !(user.reagents.get_reagent_amount("mephedrone") > 15))
			user.apply_status_effect(STATUS_EFFECT_CHAINSAW_SLAYING)

/obj/item/melee/chainsaw/syndie/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if((attack_type in NON_PROJECTILE_ATTACKS) && owner.has_status_effect(STATUS_EFFECT_CHAINSAW_SLAYING)) // It's a chainsaw, you can't block projectiles with it
		final_block_chance = 80 // Need to be ready to ruuuummbllleeee
	return ..()

// MARK: SLAYER CHAINSAW
/obj/item/melee/chainsaw/doomslayer
	name = "OOOH BABY"
	desc = "<span class='warning'>VRRRRRRR!!!</span>"
	armour_penetration_percentage = 100
	force_on = 30

/obj/item/melee/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message("<span class='danger'>Ranged attacks just make [owner] angrier!</span>")
		playsound(src, pick('sound/weapons/bulletflyby.ogg','sound/weapons/bulletflyby2.ogg','sound/weapons/bulletflyby3.ogg'), 75, 1)
		return TRUE
	return FALSE
