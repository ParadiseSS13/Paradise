/obj/item/toy/UNO
	name = "UNO card"
	desc = "An UNO card."
	icon = 'icons/hispania/obj/UNO.dmi'
	burn_state = FLAMMABLE
	burntime = 5
	var/card_hitsound = null
	var/card_force = 0
	var/card_throwforce = 0
	var/card_throw_speed = 4
	var/card_throw_range = 20
	var/msg = ""

/obj/item/storage/bag/UNO

/obj/item/toy/UNO/New()
	for(var/color in list("green","red","yellow","blue"))
		for(var/number in list("zero","one","two","three","four","five","six","seven","eight","nine","plustwo","order","turn"))
			new /obj/item/toy/UNO/color/number
					icon_state = color