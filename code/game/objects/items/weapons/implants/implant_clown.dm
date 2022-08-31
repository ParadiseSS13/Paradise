/obj/item/implant/sad_trombone
	name = "sad trombone bio-chip"
	activated = FALSE
	trigger_emotes = list("deathgasp")
	// If something forces the clown to fake death, it's pretty funny to still see the sad trombone played
	trigger_causes = BIOCHIP_EMOTE_TRIGGER_UNINTENTIONAL | BIOCHIP_TRIGGER_DEATH_ANY

/obj/item/implant/sad_trombone/get_data()
	var/dat = {"<b>Bio-chip Specifications:</b><BR>
				<b>Name:</b> Honk Co. Sad Trombone Bio-chip<BR>
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
	name = "bio-chip implanter (sad trombone)"

/obj/item/implanter/sad_trombone/New() //gross
	imp = new /obj/item/implant/sad_trombone
	..()

/obj/item/implantcase/sad_trombone
	name = "bio-chip case - 'Sad Trombone'"
	desc = "A glass case containing a sad trombone bio-chip."

/obj/item/implantcase/sad_trombone/New() //gross
	imp = new /obj/item/implant/sad_trombone
	..()
