/obj/item/melee/touch_attack
	name = "\improper outstretched hand"
	desc = "High Five?"
	icon_state = "syndballoon"
	item_state = null
	flags = ABSTRACT | NODROP | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	/// If defined caster will say this on afterattack
	var/catchphrase = "High Five!"
	/// Sound used on successful afterattack
	var/on_use_sound = null

	/// Special message shown on item deletion. Used as a part of [/obj/effect/proc_holder/spell/touch]. Do not change manually.
	var/on_withdraw_message
	/// Whether an item needs to show message stored in "on_remove_message". This is needed to distinguish actual [proc/discharge_hand] from any qdels. Do not change manually.
	var/is_withdraw = FALSE
	/// Spell this item belongs to
	var/obj/effect/proc_holder/spell/touch/attached_spell
	/// Current owner of the item
	var/mob/living/carbon/owner


/obj/item/melee/touch_attack/New(spell, owner)
	attached_spell = spell
	src.owner = owner
	..()


/obj/item/melee/touch_attack/Destroy()
	if(owner)
		if(is_withdraw && on_withdraw_message)
			to_chat(owner, on_withdraw_message)
		owner = null

	if(attached_spell)
		attached_spell.attached_hand = null
		attached_spell.UnregisterSignal(attached_spell.action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)

	return ..()


/obj/item/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return
	if(user.lying || user.handcuffed)
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return
	..()


/obj/item/melee/touch_attack/afterattack(atom/target, mob/user, proximity)
	if(catchphrase)
		user.say(catchphrase)
	playsound(get_turf(user), on_use_sound, 50, TRUE)
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
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || user.lying || user.handcuffed) //exploding after touching yourself would be bad
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
	if(!proximity || target == user || !isliving(target) || !iscarbon(user)) //getting hard after touching yourself would also be bad
		return
	if(user.lying || user.handcuffed)
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
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
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || user.lying || user.handcuffed) //not exploding after touching yourself would be bad
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
	if(!proximity || target == user || !ishuman(target) || !iscarbon(user) || user.lying || user.handcuffed) //clowning around after touching yourself would unsurprisingly, be bad
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
