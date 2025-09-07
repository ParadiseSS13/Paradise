/obj/item/bio_chip/grey_autocloner
	name = "technocracy cloning bio-chip"
	desc = "Allows for advanced instantanious cloning!"
	origin_tech = "materials=3;combat=5;syndicate=2"
	activated = FALSE
	trigger_causes = BIOCHIP_TRIGGER_DEATH_ANY
	implant_state = "implant-alien"
	var/obj/machinery/grey_autocloner/linked
	var/datum/dna2_record/our_record

/obj/item/bio_chip/grey_autocloner/Destroy()
	linked = null
	our_record = null
	return ..()

/obj/item/bio_chip/grey_autocloner/death_trigger(mob/source, gibbed)
	imp_in.ghostize()
	if(linked)
		linked.growclone(our_record)

/obj/item/bio_chip/grey_autocloner/implant(mob/source, mob/user, force)
	if(!linked)
		to_chat(user, "<span class='warning'>Please link the implanter with a Technocracy cloning pod!</span>")
		return FALSE
	. = ..()
	if(!. || !ishuman(imp_in))
		return FALSE
	our_record = new /datum/dna2_record()
	our_record.ckey = imp_in.ckey
	var/obj/item/organ/B = imp_in.get_int_organ(/obj/item/organ/internal/brain)
	B.dna.check_integrity()
	our_record.dna = B.dna.Clone()
	our_record.id = copytext(md5(B.dna.real_name), 2, 6)
	our_record.name = B.dna.real_name
	our_record.types = DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	our_record.languages = imp_in.languages
	if(imp_in.mind) //Save that mind so traitors can continue traitoring after cloning.
		our_record.mind = imp_in.mind.UID()

/obj/item/bio_chip_implanter/grey_autocloner
	name = "bio-chip implanter (Technocracy cloning)"
	implant_type = /obj/item/bio_chip/grey_autocloner

/obj/item/bio_chip_case/grey_autocloner
	name = "bio-chip case - 'Technocracy cloning'"
	desc = "A glass case containing an Technocracy bio-chip."
	implant_type = /obj/item/bio_chip/grey_autocloner
