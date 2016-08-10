/obj/item/weapon/melee/touch_attack
	name = "\improper outstretched hand"
	desc = "High Five?"
	var/catchphrase = "High Five!"
	var/on_use_sound = null
	var/obj/effect/proc_holder/spell/targeted/touch/attached_spell
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	item_state = null
	flags = ABSTRACT | NODROP
	w_class = 5
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0

/obj/item/weapon/melee/touch_attack/New(var/spell)
	attached_spell = spell
	..()

/obj/item/weapon/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return
	if(user.lying || user.handcuffed)
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return
	..()

/obj/item/weapon/melee/touch_attack/afterattack(atom/target, mob/user, proximity)
	user.say(catchphrase)
	playsound(get_turf(user), on_use_sound,50,1)
	attached_spell.attached_hand = null
	qdel(src)

/obj/item/weapon/melee/touch_attack/disintegrate
	name = "disintegrating touch"
	desc = "This hand of mine glows with an awesome power!"
	catchphrase = "EI NATH!!"
	on_use_sound = "sound/magic/Disintegrate.ogg"
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/weapon/melee/touch_attack/disintegrate/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || user.lying || user.handcuffed) //exploding after touching yourself would be bad
		return
	var/mob/M = target
	var/datum/effect/system/spark_spread/sparks = new
	sparks.set_up(4, 0, M.loc) //no idea what the 0 is
	sparks.start()
	M.gib()
	..()

/obj/item/weapon/melee/touch_attack/fleshtostone
	name = "petrifying touch"
	desc = "That's the bottom line, because flesh to stone said so!"
	catchphrase = "STAUN EI!!"
	on_use_sound = "sound/magic/FleshToStone.ogg"
	icon_state = "fleshtostone"
	item_state = "fleshtostone"

/obj/item/weapon/melee/touch_attack/fleshtostone/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || user.lying || user.handcuffed) //getting hard after touching yourself would also be bad
		return
	if(user.lying || user.handcuffed)
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return
	var/mob/M = target
	M.Stun(2)
	new /obj/structure/closet/statue(M.loc, M)
	..()

/obj/item/weapon/melee/touch_attack/fake_disintegrate
	name = "toy plastic hand"
	desc = "This hand of mine glows with an awesome power! Ok, maybe just batteries."
	catchphrase = "EI NATH!!"
	on_use_sound = "sound/magic/Disintegrate.ogg"
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/weapon/melee/touch_attack/fake_disintegrate/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || user.lying || user.handcuffed) //not exploding after touching yourself would be bad
		return
	var/datum/effect/system/spark_spread/sparks = new
	sparks.set_up(4, 0, target.loc) //no idea what the 0 is
	sparks.start()
	playsound(target.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
	..()

/obj/item/weapon/melee/touch_attack/cluwne
	name = "cluwne touch"
	desc = "It's time to start clowning around."
	catchphrase = "NWOLC EGNEVER"
	on_use_sound = "sound/misc/sadtrombone.ogg"
	icon_state = "cluwnecurse"
	item_state = "cluwnecurse"

/obj/item/weapon/melee/touch_attack/cluwne/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ishuman(target) || !iscarbon(user) || user.lying || user.handcuffed) //clowning around after touching yourself would unsurprisingly, be bad
		return

	if(iswizard(target))
		to_chat(user, "<span class='warning'>The spell has no effect on [target].</span>")
		return

	var/datum/effect/system/harmless_smoke_spread/s = new /datum/effect/system/harmless_smoke_spread
	s.set_up(5, 0, target)
	s.start()

	var/mob/living/carbon/human/H = target
	if(H.mind)
		if(H.mind.assigned_role != "Cluwne")
			H.makeCluwne()
		else
			H.makeAntiCluwne()
	..()
