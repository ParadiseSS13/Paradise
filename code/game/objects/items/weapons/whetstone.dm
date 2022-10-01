/obj/item/whetstone
	name = "whetstone"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "whetstone"
	desc = "A block of stone used to sharpen things."
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/screwdriver.ogg'
	var/used = FALSE
	var/increment = 4
	var/max = 30
	var/prefix = "sharpened"
	var/requires_sharpness = TRUE
	var/claw_damage_increase = 2


/obj/item/whetstone/attackby(obj/item/I, mob/user, params)
	if(used)
		to_chat(user, "<span class='warning'>The whetstone is too worn to use again!</span>")
		return
	if(I.force >= max || I.throwforce >= max)//no esword sharpening
		to_chat(user, "<span class='warning'>[I] is much too powerful to sharpen further!</span>")
		return
	if(requires_sharpness && !I.sharp)
		to_chat(user, "<span class='warning'>You can only sharpen items that are already sharp, such as knives!</span>")
		return
	if(istype(I, /obj/item/twohanded))//some twohanded items should still be sharpenable, but handle force differently. therefore i need this stuff
		var/obj/item/twohanded/TH = I
		if(TH.force_wielded >= max || TH.force_wielded > initial(TH.force_wielded))
			to_chat(user, "<span class='warning'>[TH] is much too powerful to sharpen further!</span>")
			return
		TH.force_wielded = clamp(TH.force_wielded + increment, 0, max)//wieldforce is increased since normal force wont stay
		TH.force_unwielded = clamp(TH.force_unwielded + increment, 0, max)

	if(istype(I, /obj/item/melee/energy))
		var/obj/item/melee/energy/E = I
		if(E.force_on > initial(E.force_on) || (E.force > initial(E.force)))
			to_chat(user, "<span class='warning'>[E] is much too powerful to sharpen further!</span>")
			return
		E.throwforce_on = clamp(E.throwforce_on + increment, 0, max)
		E.throwforce_off = clamp(E.throwforce_off + increment, 0, max)
		E.force_on = clamp(E.force_on + increment, 0, max)
		E.force_off = clamp(E.force_off + increment, 0, max)

	if(I.force > initial(I.force))
		to_chat(user, "<span class='warning'>[I] has already been refined before. It cannot be sharpened further!</span>")
		return
	user.visible_message("<span class='notice'>[user] sharpens [I] with [src]!</span>", "<span class='notice'>You sharpen [I], making it much more deadly than before.</span>")
	if(!requires_sharpness)
		set_sharpness(TRUE)
	I.force = clamp(I.force + increment, 0, max)
	I.throwforce = clamp(I.throwforce + increment, 0, max)
	I.name = "[prefix] [I.name]"
	playsound(get_turf(src), usesound, 50, 1)
	name = "worn out [name]"
	desc = "[desc] At least, it used to."
	used = TRUE
	update_icon()

/obj/item/whetstone/attack_self(mob/user)
	if(used)
		to_chat(user, "<span class='warning'>The whetstone is too worn to use again!</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/unarmed_attack/attack = H.dna.species.unarmed
		if(istype(attack, /datum/unarmed_attack/claws))
			var/datum/unarmed_attack/claws/C = attack
			if(!C.has_been_sharpened)
				C.has_been_sharpened = TRUE
				attack.damage += claw_damage_increase
				H.visible_message("<span class='notice'>[H] sharpens [H.p_their()] claws on [src]!</span>", "<span class='notice'>You sharpen your claws on [src].</span>")
				playsound(get_turf(H), usesound, 50, 1)
				name = "worn out [name]"
				desc = "[desc] At least, it used to."
				used = TRUE
				update_icon()
			else
				to_chat(user, "<span class='warning'>You can not sharpen your claws any further!</span>")

/obj/item/whetstone/super
	name = "super whetstone block"
	desc = "A block of stone that will make your weapon sharper than Einstein on adderall."
	increment = 200
	max = 200
	prefix = "super-sharpened"
	requires_sharpness = FALSE
	claw_damage_increase = 200
