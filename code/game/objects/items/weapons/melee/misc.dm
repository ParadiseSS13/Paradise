/obj/item/melee
	needs_permit = 1

/obj/item/melee/proc/check_martial_counter(mob/living/carbon/human/target, mob/living/carbon/human/user)
	var/message = "<span class='danger'>[target.name] blocks [src] and twists [user]'s arm behind [user.p_their()] back!</span>"
	var/self_message = "<span class='userdanger'>You block the attack!</span>"
	if(target.check_martial_art_defense(target, user, src, message, self_message))
		user.Stun(4 SECONDS)
		return TRUE

/obj/item/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=5"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/slash.ogg' //pls replace


/obj/item/melee/chainofcommand/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='suicide'>[user] is strangling [user.p_them()]self with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
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
	block_chance = 50
	armour_penetration = 75
	sharp = TRUE
	origin_tech = "combat=5"
	attack_verb = list("lunged at", "stabbed")
	hitsound = 'sound/weapons/rapierhit.ogg'
	materials = list(MAT_METAL = 1000)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF // Theft targets should be hard to destroy

/obj/item/melee/rapier/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/melee/mantisblade
	name = "Gorlex mantis blade"
	desc = "A blade designed to be hidden just beneath the skin. The brain is directly linked to this bad boy, allowing it to spring into action."
	icon_state = "syndie_mantis"
	item_state = "syndie_mantis"
	force = 20
	throwforce = 20
	w_class = WEIGHT_CLASS_NORMAL
	block_chance = 30
	armour_penetration = 30
	sharp = TRUE
	origin_tech = "combat=5"
	attack_verb = list("slashed", "stabbed", "sliced", "caned")
	hitsound = 'sound/weapons/bladeslice.ogg'
	materials = list(MAT_METAL = 1000)

/obj/item/melee/mantisblade/equipped(mob/user, slot)
	. = ..()

	if(slot == slot_l_hand)
		transform = null
	else
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/melee/mantisblade/attack(mob/living/M, mob/living/user, secondattack = FALSE)
	. = ..()
	var/obj/item/melee/mantisblade/secondsword = user.get_inactive_hand()
	if(istype(secondsword, /obj/item/melee/mantisblade) && !secondattack && user.a_intent == INTENT_HARM)
		addtimer(CALLBACK(src, PROC_REF(mantis_attack), M, user, FALSE), 0.2 SECONDS)
	return

/obj/item/melee/mantisblade/proc/mantis_attack(mob/living/M, mob/living/user, secondattack = FALSE)
	var/obj/item/melee/mantisblade/secondsword = user.get_inactive_hand()
	secondsword.attack(M, user, TRUE)
	user.changeNext_move(CLICK_CD_MELEE)

/obj/item/melee/mantisblade/shellguard
	name = "Shellguard mantis blade"
	force = 15
	armour_penetration = 20
	block_chance = 20
	icon_state = "mantis"
	item_state = "mantis"

/obj/item/melee/mantisblade/shellguard/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
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
					/obj/item/queen_bee
	))

/obj/item/melee/flyswatter/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		if(is_type_in_typecache(target, strong_against))
			new /obj/effect/decal/cleanable/insectguts(target.drop_location())
			to_chat(user, "<span class='warning'>You easily splat the [target].</span>")
			if(istype(target, /mob/living/))
				var/mob/living/bug = target
				bug.death(1)
			else
				qdel(target)
