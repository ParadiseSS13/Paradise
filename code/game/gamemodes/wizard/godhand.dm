/obj/item/melee/touch_attack
	name = "outstretched hand"
	desc = "High Five?"
	var/catchphrase = "High Five!"
	var/on_use_sound = null
	var/datum/spell/touch/attached_spell
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "disintegrate"
	item_state = null
	flags = ABSTRACT | NODROP | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0

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

/obj/item/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return
	..()

/obj/item/melee/touch_attack/afterattack(atom/target, mob/user, proximity)
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
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/melee/touch_attack/disintegrate/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //exploding after touching yourself would be bad
		return
	var/mob/M = target
	do_sparks(4, 0, M.loc) //no idea what the 0 is
	M.gib()
	..()

/obj/item/melee/touch_attack/fleshtostone
	name = "petrifying touch"
	desc = "That's the bottom line, because flesh to stone said so!"
	catchphrase = "STAUN EI!!"
	on_use_sound = 'sound/magic/fleshtostone.ogg'
	icon_state = "fleshtostone"
	item_state = "fleshtostone"

/obj/item/melee/touch_attack/fleshtostone/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !isliving(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //getting hard after touching yourself would also be bad
		return
	var/mob/living/L = target
	L.Stun(4 SECONDS)
	new /obj/structure/closet/statue(L.loc, L)
	..()

/obj/item/melee/touch_attack/fake_disintegrate
	name = "toy plastic hand"
	desc = "This hand of mine glows with an awesome power! Ok, maybe just batteries."
	catchphrase = "EI NATH!!"
	on_use_sound = 'sound/magic/disintegrate.ogg'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	needs_permit = FALSE

/obj/item/melee/touch_attack/fake_disintegrate/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //not exploding after touching yourself would be bad
		return
	do_sparks(4, 0, target.loc)
	playsound(target.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
	..()

/obj/item/melee/touch_attack/cluwne
	name = "cluwne touch"
	desc = "It's time to start clowning around."
	catchphrase = "NWOLC EGNEVER"
	on_use_sound = 'sound/misc/sadtrombone.ogg'
	icon_state = "cluwnecurse"
	item_state = "cluwnecurse"

/obj/item/melee/touch_attack/cluwne/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ishuman(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //clowning around after touching yourself would unsurprisingly, be bad
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
	..()
