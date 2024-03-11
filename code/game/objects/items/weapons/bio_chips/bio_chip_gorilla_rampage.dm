/// Dumb path but easier to search for admins
/obj/item/bio_chip/gorilla_rampage
	name = "magillitis serum bio-chip"
	desc = "An experimental biochip which causes irreversable rapid muscular growth in Hominidae. Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	icon_state = "gorilla_rampage"
	origin_tech = "combat=5;biotech=5;syndicate=2"
	uses = 1
	implant_data = /datum/implant_fluff/gorilla_rampage
	implant_state = "implant-syndicate"

/obj/item/bio_chip/gorilla_rampage/activate()
	if(!iscarbon(imp_in))
		return

	var/mob/living/carbon/target = imp_in
	target.visible_message("<span class='userdanger'>[target] swells and their hair grows rapidly. Uh oh!.</span>","<span class='userdanger'>You feel your muscles swell and your hair grow as you return to monke.</span>", "<span class='userdanger'>You hear angry gorilla noises.</span>")
	target.gorillize(TRUE)

/obj/item/bio_chip_implanter/gorilla_rampage
	name = "bio-chip implanter (magillitis serum)"
	implant_type = /obj/item/bio_chip/gorilla_rampage

/obj/item/bio_chip_case/gorilla_rampage
	name = "bio-chip case - 'magillitis serum'"
	desc = "A glass case containing a magillitis bio-chip."
	implant_type = /obj/item/bio_chip/gorilla_rampage
