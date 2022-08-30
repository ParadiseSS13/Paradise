/obj/item/implant/sad_trombone
	name = "sad trombone microchip"
	activated = FALSE
	trigger_emotes = list("deathgasp")
	// If something forces the clown to fake death, it's pretty funny to still see the sad trombone played
	trigger_causes = MICROCHIP_EMOTE_TRIGGER_UNINTENTIONAL | MICROCHIP_TRIGGER_DEATH_ANY

/obj/item/implant/sad_trombone/get_data()
	var/dat = {"<b>Microchip Specifications:</b><BR>
				<b>Name:</b> Honk Co. Sad Trombone Microchip<BR>
				<b>Life:</b> Activates upon death.<BR>
				"}
	return dat

/obj/item/implant/sad_trombone/emote_trigger(emote, mob/source, force)
	activate(emote)

/obj/item/implant/sad_trombone/death_trigger(mob/user, gibbed)
	activate(gibbed)


/obj/item/implant/sad_trombone/activate()
	playsound(loc, 'sound/misc/sadtrombone.ogg', 50, FALSE)

/obj/item/implanter/sad_trombone
	name = "micromicrochipper (sad trombone)"

/obj/item/implanter/sad_trombone/New() //gross
	imp = new /obj/item/implant/sad_trombone
	..()

/obj/item/implantcase/sad_trombone
	name = "microchip case - 'Sad Trombone'"
	desc = "A glass case containing a sad trombone microchip."

/obj/item/implantcase/sad_trombone/New() //gross
	imp = new /obj/item/implant/sad_trombone
	..()
