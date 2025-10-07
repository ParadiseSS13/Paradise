/obj/item/melee/touch_attack
	name = "outstretched hand"
	desc = "High Five?"
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	flags = ABSTRACT | NODROP | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throw_range = 0
	throw_speed = 0
	new_attack_chain = TRUE
	/// Has it been blocked by antimagic? If so, abort.
	var/blocked_by_antimagic = FALSE
	var/catchphrase = "High Five!"
	var/on_use_sound = null
	var/datum/spell/touch/attached_spell

/obj/item/melee/touch_attack/New(spell)
	attached_spell = spell
	..()

/obj/item/melee/touch_attack/Destroy()
	if(attached_spell)
		attached_spell.attached_hand = null
		attached_spell.UnregisterSignal(attached_spell.action.owner, COMSIG_MOB_WILLINGLY_DROP)
	return ..()

/obj/item/melee/touch_attack/customised_abstract_text(mob/living/carbon/owner)
	return "<span class='warning'>[owner.p_their(TRUE)] [owner.l_hand == src ? "left hand" : "right hand"] is burning in magic fire.</span>"

/obj/item/melee/touch_attack/attack(mob/living/target, mob/living/carbon/human/user)
	if(..() || !iscarbon(user)) //Look ma, no hands
		return FINISH_ATTACK
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return FINISH_ATTACK

/obj/item/melee/touch_attack/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/mob/mob_victim = target
	if(istype(mob_victim) && mob_victim.can_block_magic(attached_spell.antimagic_flags))
		to_chat(user, "<span class='danger'>[mob_victim] absorbs your spell!</span>")
		blocked_by_antimagic = TRUE
		if(attached_spell && attached_spell.cooldown_handler)
			attached_spell.cooldown_handler.start_recharge(attached_spell.cooldown_handler.recharge_duration * 0.5)
		qdel(src)
		return

/obj/item/melee/touch_attack/proc/handle_delete(mob/user)
	if(catchphrase)
		user.say(catchphrase)
	playsound(get_turf(user), on_use_sound, 50, 1)
	if(attached_spell)
		attached_spell.perform(list())
	qdel(src)

/obj/item/melee/touch_attack/disintegrate
	name = "disintegrating touch"
	desc = "This hand of mine glows with an awesome power!"
	catchphrase = "EI NATH!!"
	on_use_sound = 'sound/magic/disintegrate.ogg'

/obj/item/melee/touch_attack/disintegrate/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || target == user || blocked_by_antimagic || !ismob(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //exploding after touching yourself would be bad
		return
	var/mob/M = target
	do_sparks(4, 0, M.loc) //no idea what the 0 is
	M.gib()
	handle_delete(user)

/obj/item/melee/touch_attack/fleshtostone
	name = "petrifying touch"
	desc = "That's the bottom line, because flesh to stone said so!"
	icon_state = "fleshtostone"
	catchphrase = "STAUN EI!!"
	on_use_sound = 'sound/magic/fleshtostone.ogg'

/obj/item/melee/touch_attack/fleshtostone/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag || target == user || blocked_by_antimagic || !isliving(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //getting hard after touching yourself would also be bad
		return
	var/mob/living/L = target
	L.Stun(4 SECONDS)
	new /obj/structure/closet/statue(L.loc, L)
	handle_delete(user)

/obj/item/melee/touch_attack/plushify
	name = "fabric touch"
	desc = "The power to sew your foes into a doom cut from the fabric of fate."
	catchphrase = "MAHR-XET 'ABL"
	on_use_sound = 'sound/magic/smoke.ogg'
	color = COLOR_PURPLE

/obj/item/melee/touch_attack/plushify/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag || target == user || blocked_by_antimagic || !isliving(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //There are better ways to get a good nights sleep in a bed.
		return
	var/mob/living/L = target
	L.plushify()
	handle_delete(user)

/obj/item/melee/touch_attack/fake_disintegrate
	name = "toy plastic hand"
	desc = "This hand of mine glows with an awesome power! Ok, maybe just batteries."
	catchphrase = "EI NATH!!"
	on_use_sound = 'sound/magic/disintegrate.ogg'
	needs_permit = FALSE

/obj/item/melee/touch_attack/fake_disintegrate/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag || target == user || blocked_by_antimagic || !ismob(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //not exploding after touching yourself would be bad
		return
	do_sparks(4, 0, target.loc)
	playsound(target.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
	handle_delete(user)

/obj/item/melee/touch_attack/cluwne
	name = "cluwne touch"
	desc = "It's time to start clowning around."
	icon_state = "cluwnecurse"
	catchphrase = "NWOLC EGNEVER"
	on_use_sound = 'sound/misc/sadtrombone.ogg'

/obj/item/melee/touch_attack/cluwne/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag || target == user || blocked_by_antimagic || !ishuman(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //clowning around after touching yourself would unsurprisingly, be bad
		return

	if(iswizard(target))
		to_chat(user, "<span class='warning'>The spell has no effect on [target].</span>")
		return

	var/datum/effect_system/smoke_spread/s = new
	s.set_up(5, FALSE, target)
	s.start()

	var/mob/living/carbon/human/H = target
	if(H.mind)
		if(H.mind.assigned_role != "Cluwne")
			H.makeCluwne()
		else
			H.makeAntiCluwne()
	handle_delete(user)
