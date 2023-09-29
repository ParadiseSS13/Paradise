/obj/item/implant/gorilla_rampage //Dumb path but easier to search for admins
	name = "magillitis serum bio-chip"
	desc = "An experimental biochip which causes irreversable rapid muscular growth in Hominidae. Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	icon_state = "gorilla_rampage"
	origin_tech = "combat=5;biotech=5;syndicate=2"
	uses = 1
	implant_data = /datum/implant_fluff/gorilla_rampage
	implant_state = "implant-syndicate"
	COOLDOWN_DECLARE(gorilla_transform_cooldown)

/obj/item/implant/gorilla_rampage/activate()
	if(!COOLDOWN_FINISHED(src, gorilla_transform_cooldown))
		to_chat(usr, "<span class='notice'>[src] is still on cooldown! [(gorilla_transform_cooldown - world.time) / 10] seconds left!</span>")
		return
	if(ishuman(usr))
		var/mob/living/simple_animal/hostile/gorilla/rampaging/rampaging_gorilla = new (get_turf(src))

		playsound(rampaging_gorilla, 'sound/creatures/gorilla.ogg', 50)
		var/mob/living/carbon/human/implante = imp_in

		implante.visible_message("<span class='userdanger'>[implante] swells and their hair grows rapidly. Uh oh!</span>", "<span class='userdanger'>You feel your muscles swell and your hair grow as you return to monke.</span>", "<span class='userdanger'>You hear angry gorilla noises.</span>")
		implante.mind.transfer_to(rampaging_gorilla)
		implante.forceMove(rampaging_gorilla)
		implant(rampaging_gorilla)
		usr.status_flags |= GODMODE
	else
		var/mob/living/carbon/human/creator = locate(/mob/living/carbon/human) in usr
		if(!creator)
			return
		creator.status_flags &= ~GODMODE

		usr.mind.transfer_to(creator)
		usr.visible_message("<span class='userdanger'>[usr] quickly shrinks back into their original form!</span>","<span class='userdanger'>You feel your muscles relax as you return to your original form.</span>", "<span class='userdanger'>You hear a lack of gorilla noises.</span>")
		creator.forceMove(get_turf(usr))
		implant(creator)
		qdel(usr)

	COOLDOWN_START(src, gorilla_transform_cooldown, 90 SECONDS)

/obj/item/implanter/gorilla_rampage
	name = "bio-chip implanter (magillitis serum)"
	implant_type = /obj/item/implant/gorilla_rampage

/obj/item/implantcase/gorilla_rampage
	name = "bio-chip case - 'magillitis serum'"
	desc = "A glass case containing a magillitis bio-chip."
	implant_type = /obj/item/implant/gorilla_rampage
