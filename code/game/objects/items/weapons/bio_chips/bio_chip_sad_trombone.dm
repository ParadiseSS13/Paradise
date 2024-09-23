/obj/item/bio_chip/sad_trombone
	name = "sad trombone bio-chip"
	activated = FALSE
	trigger_emotes = list("deathgasp")
	// If something forces the clown to fake death, it's pretty funny to still see the sad trombone played
	trigger_causes = BIOCHIP_EMOTE_TRIGGER_UNINTENTIONAL | BIOCHIP_TRIGGER_DEATH_ANY
	implant_data = /datum/implant_fluff/sad_trombone
	implant_state = "implant-honk"

/obj/item/bio_chip/sad_trombone/emote_trigger(emote, mob/source, force)
	activate(emote)

/obj/item/bio_chip/sad_trombone/death_trigger(mob/user, gibbed)
	activate(gibbed)


/obj/item/bio_chip/sad_trombone/activate()
	playsound(loc, 'sound/misc/sadtrombone.ogg', 50, FALSE)

/obj/item/bio_chip_implanter/sad_trombone
	name = "bio-chip implanter (sad trombone)"
	implant_type = /obj/item/bio_chip/sad_trombone

/obj/item/bio_chip_case/sad_trombone
	name = "bio-chip case - 'Sad Trombone'"
	desc = "A glass case containing a sad trombone bio-chip."
	implant_type = /obj/item/bio_chip/sad_trombone
