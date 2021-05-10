/obj/item/toy/plushie_hispania_sound
	name = "Lona Huge Head Plushie"
	desc = "An adorable stuffed huge head that resembles a mixed race girl from a sad world."
	icon = 'icons/hispania/obj/toy.dmi'
	icon_state = "lona"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	attack_verb = list("poofed", "bopped", "whapped","cuddled","fluffed")
	var/cooldown = FALSE
	var/list/toysounds  = list('sound/hispania/effects/toys/lona1.ogg','sound/hispania/effects/toys/lona2.ogg','sound/hispania/effects/toys/yeah.ogg')

/obj/item/toy/plushie_hispania_sound/attack_self(mob/user)
	var/cuddle_verb = pick("hugs","cuddles","snugs")
	user.visible_message("<span class='notice'>[user] [cuddle_verb] the [src].</span>")
	if(!cooldown)
		to_chat(user, "<span class='notice'>You press the button on [src].</span>")
		playsound(user, pick(toysounds), 20, 1)
		cooldown = TRUE
		spawn(3 SECONDS) cooldown = FALSE
		return
	..()

/obj/item/toy/plushie_hispania_sound/attack(mob/M as mob, mob/user as mob)
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 20, 1)
	if(iscarbon(M))
		if(prob(10))
			M.reagents.add_reagent("love", 1) //Si, te pueden "Inyectar" amor. <3
	return ..()

/obj/item/toy/plushie_hispania_sound/cocoana
	name = "Cocoana Huge Head Plushie"
	desc = "An adorable stuffed huge head that resembles a half elf girl from a sad world."
	icon_state = "cocoana"
	toysounds = list('sound/hispania/effects/toys/cocoana1.ogg', 'sound/hispania/effects/toys/cocoana2.ogg', 'sound/hispania/effects/toys/cocoana3.ogg', 'sound/hispania/effects/toys/cocoana4.ogg')
