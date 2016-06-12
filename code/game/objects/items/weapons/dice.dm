/obj/item/weapon/dice
	name = "d6"
	desc = "A die with six sides. Basic and servicable."
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = 1
	var/sides = 6
	var/result = null

/obj/item/weapon/dice/New()
	result = rand(1, sides)
	update_icon()

/obj/item/weapon/dice/d2
	name = "d2"
	desc = "A die with two sides. Coins are undignified!"
	icon_state = "d2"
	sides = 2

/obj/item/weapon/dice/d4
	name = "d4"
	desc = "A die with four sides. The nerd's caltrop."
	icon_state = "d4"
	sides = 4

/obj/item/weapon/dice/d8
	name = "d8"
	desc = "A die with eight sides. It feels... lucky."
	icon_state = "d8"
	sides = 8

/obj/item/weapon/dice/d10
	name = "d10"
	desc = "A die with ten sides. Useful for percentages."
	icon_state = "d10"
	sides = 10

/obj/item/weapon/dice/d00
	name = "d00"
	desc = "A die with ten sides. Works better for d100 rolls than a golfball."
	icon_state = "d00"
	sides = 10

/obj/item/weapon/dice/d12
	name = "d12"
	desc = "A die with twelve sides. There's an air of neglect about it."
	icon_state = "d12"
	sides = 12

/obj/item/weapon/dice/d20
	name = "d20"
	desc = "A die with twenty sides. The prefered die to throw at the GM."
	icon_state = "d20"
	sides = 20

/obj/item/weapon/dice/d20/e20
	var/triggered = 0

/obj/item/weapon/dice/attack_self(mob/user as mob)
	diceroll(user)

/obj/item/weapon/dice/throw_at(atom/target, range, speed, mob/user as mob)
	if(!..())
		return
	diceroll(user)

/obj/item/weapon/dice/proc/diceroll(mob/user as mob)
	result = rand(1, sides)
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "Nat 20!"
	else if(sides == 20 && result == 1)
		comment = "Ouch, bad luck."
	update_icon()
	if(initial(icon_state) == "d00")
		result = (result - 1)*10
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message("<span class='notice'>[user] has thrown [src]. It lands on [result]. [comment]</span>", \
							 "<span class='notice'>You throw [src]. It lands on [result]. [comment]</span>", \
							 "<span class='notice'>You hear [src] landing on [result]. [comment]</span>")
	else if(src.throwing == 0) //Dice was thrown and is coming to rest
		visible_message("<span class='notice'>[src] rolls to a stop, landing on [result]. [comment]</span>")
/*
/obj/item/weapon/dice/d4/Crossed(var/mob/living/carbon/human/H)
	if(istype(H) && !H.shoes)
		to_chat(H, "<span class='userdanger'>You step on the D4!</span>")
		H.apply_damage(4,BRUTE,(pick("l_leg", "r_leg")))
		H.Weaken(3)
*///ew.


/obj/item/weapon/dice/d20/e20/diceroll(mob/user as mob, thrown)
	if(triggered)
		return
	..()
	if(result == 1)
		to_chat(user, "<span class='danger'>Rocks fall, you die.</span>")
		user.gib()
	else
		triggered = 1
		visible_message("<span class='notice'>You hear a quiet click.</span>")
		spawn(40)
			var/cap = 0
			if(result > MAX_EX_LIGHT_RANGE && result != 20)
				cap = 1
				result = min(result, MAX_EX_LIGHT_RANGE) //Apply the bombcap
			else if(result == 20) //Roll a nat 20, screw the bombcap
				result = 24
			var/turf/epicenter = get_turf(src)
			explosion(epicenter, round(result*0.25), round(result*0.5), round(result), round(result*1.5), 1, cap)

/obj/item/weapon/dice/update_icon()
	overlays.Cut()
	overlays += "[src.icon_state][src.result]"
/obj/item/weapon/storage/box/dice
	name = "Box of dice"
	desc = "ANOTHER ONE!? FUCK!"
	icon_state = "box"

/obj/item/weapon/storage/box/dice/New()
	..()
	new /obj/item/weapon/dice/d2(src)
	new /obj/item/weapon/dice/d4(src)
	new /obj/item/weapon/dice/d8(src)
	new /obj/item/weapon/dice/d10(src)
	new /obj/item/weapon/dice/d00(src)
	new /obj/item/weapon/dice/d12(src)
	new /obj/item/weapon/dice/d20(src)
