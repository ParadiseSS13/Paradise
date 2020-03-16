/obj/item/storage/pill_bottle/dice
	name = "bag of dice"
	desc = "Contains all the luck you'll ever need."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"
	can_hold = list(/obj/item/dice)
	allow_wrap = FALSE

/obj/item/storage/pill_bottle/dice/New()
	..()
	var/special_die = pick("1","2","fudge","00","100")
	if(special_die == "1")
		new /obj/item/dice/d1(src)
	if(special_die == "2")
		new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d6(src)
	if(special_die == "fudge")
		new /obj/item/dice/fudge(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	if(special_die == "00")
		new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
	if(special_die == "100")
		new /obj/item/dice/d100(src)

/obj/item/storage/pill_bottle/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is gambling with death! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/obj/item/dice //depreciated d6, use /obj/item/dice/d6 if you actually want a d6
	name = "die"
	desc = "A die with six sides. Basic and servicable."
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = WEIGHT_CLASS_TINY

	var/sides = 6
	var/result = null
	var/list/special_faces = list() //entries should match up to sides var if used

	var/rigged = DICE_NOT_RIGGED
	var/rigged_value

/obj/item/dice/Initialize(mapload)
	. = ..()
	if(!result)
		result = roll(sides)
	update_icon()

/obj/item/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is gambling with death! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/obj/item/dice/d1
	name = "d1"
	desc = "A die with one side. Deterministic!"
	icon_state = "d1"
	sides = 1

/obj/item/dice/d2
	name = "d2"
	desc = "A die with two sides. Coins are undignified!"
	icon_state = "d2"
	sides = 2

/obj/item/dice/d4
	name = "d4"
	desc = "A die with four sides. The nerd's caltrop."
	icon_state = "d4"
	sides = 4

/obj/item/dice/d4/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 1, 4) //1d4 damage

/obj/item/dice/d6
	name = "d6"

/obj/item/dice/fudge
	name = "fudge die"
	desc = "A die with six sides but only three results. Is this a plus or a minus? Your mind is drawing a blank..."
	sides = 3 //shhh
	icon_state = "fudge"
	special_faces = list("minus","blank","plus")

/obj/item/dice/d8
	name = "d8"
	desc = "A die with eight sides. It feels... lucky."
	icon_state = "d8"
	sides = 8

/obj/item/dice/d10
	name = "d10"
	desc = "A die with ten sides. Useful for percentages."
	icon_state = "d10"
	sides = 10

/obj/item/dice/d00
	name = "d00"
	desc = "A die with ten sides. Works better for d100 rolls than a golfball."
	icon_state = "d00"
	sides = 10

/obj/item/dice/d12
	name = "d12"
	desc = "A die with twelve sides. There's an air of neglect about it."
	icon_state = "d12"
	sides = 12

/obj/item/dice/d20
	name = "d20"
	desc = "A die with twenty sides. The prefered die to throw at the GM."
	icon_state = "d20"
	sides = 20

/obj/item/dice/d100
	name = "d100"
	desc = "A die with one hundred sides! Probably not fairly weighted..."
	icon_state = "d100"
	sides = 100

/obj/item/dice/d100/update_icon()
	return

/obj/item/dice/d20/e20
	var/triggered = 0

/obj/item/dice/attack_self(mob/user as mob)
	diceroll(user)

/obj/item/dice/throw_impact(atom/target)
	diceroll(thrownby)
	. = ..()

/obj/item/dice/proc/diceroll(mob/user)
	result = roll(sides)
	if(rigged != DICE_NOT_RIGGED && result != rigged_value)
		if(rigged == DICE_BASICALLY_RIGGED && prob(Clamp(1/(sides - 1) * 100, 25, 80)))
			result = rigged_value
		else if(rigged == DICE_TOTALLY_RIGGED)
			result = rigged_value

	. = result

	var/fake_result = roll(sides)//Daredevil isn't as good as he used to be
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "NAT 20!"
	else if(sides == 20 && result == 1)
		comment = "Ouch, bad luck."
	update_icon()
	if(initial(icon_state) == "d00")
		result = (result - 1)*10
	if(special_faces.len == sides)
		result = special_faces[result]
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message("[user] has thrown [src]. It lands on [result]. [comment]", \
							 "<span class='notice'>You throw [src]. It lands on [result]. [comment]</span>", \
							 "<span class='italics'>You hear [src] rolling, it sounds like a [fake_result].</span>")
	else if(!src.throwing) //Dice was thrown and is coming to rest
		visible_message("<span class='notice'>[src] rolls to a stop, landing on [result]. [comment]</span>")

/obj/item/dice/d20/e20/diceroll(mob/user as mob, thrown)
	if(triggered)
		return

	. = ..()

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

			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			investigate_log("E20 detonated at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]) with a roll of [result]. Triggered by: [key_name(user)]", INVESTIGATE_BOMB)
			message_admins("E20 detonated at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a> with a roll of [result]. Triggered by: [key_name_admin(user)]")
			log_game("E20 detonated at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]) with a roll of [result]. Triggered by: [key_name(user)]")


/obj/item/dice/update_icon()
	overlays.Cut()
	overlays += "[icon_state][result]"

/obj/item/storage/box/dice
	name = "Box of dice"
	desc = "ANOTHER ONE!? FUCK!"
	icon_state = "box"

/obj/item/storage/box/dice/New()
	..()
	new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
