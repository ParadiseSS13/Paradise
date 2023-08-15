/**
 * # Pill
 *
 * A swallowable pill. Can be dissolved in reagent containers.
 */
/obj/item/reagent_containers/food/pill
	name = "pill"
	desc = "A pill."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "pill"
	container_type = NONE
	possible_transfer_amounts = null
	volume = 100
	has_lid = FALSE
	consume_sound = null
	can_taste = FALSE
	antable = FALSE

/obj/item/reagent_containers/food/pill/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "pill[rand(1, 20)]"

/obj/item/reagent_containers/food/pill/attack(mob/living/carbon/M, mob/user, def_zone)
	if(!istype(M))
		return FALSE
	bitesize = reagents.total_volume
	if(M.eat(src, user))
		qdel(src)
		return TRUE
	return FALSE

/obj/item/reagent_containers/food/pill/afterattack(obj/target, mob/user, proximity)
	if(!proximity || !target.is_refillable())
		return
	if(target.reagents.holder_full())
		to_chat(user, "<span class='warning'>[target] is full.</span>")
		return

	to_chat(user, "<span class='notice'>You [!target.reagents.total_volume ? "break open" : "dissolve"] [src] in [target].</span>")
	for(var/mob/O in oviewers(2, user))
		O.show_message("<span class='warning'>[user] puts something in [target].</span>", 1)
	reagents.trans_to(target, reagents.total_volume)
	qdel(src)

// Basic set of pills below
/obj/item/reagent_containers/food/pill/tox
	name = "\improper Toxin pill"
	desc = "Highly toxic."
	icon_state = "pill21"
	list_reagents = list("toxin" = 50)

/obj/item/reagent_containers/food/pill/initropidril
	name = "\improper Initropidril pill"
	desc = "Don't swallow this."
	icon_state = "pill21"
	list_reagents = list("initropidril" = 50)

/obj/item/reagent_containers/food/pill/fakedeath
	name = "fake death pill"
	desc = "Swallow then rest to appear dead, stand up to wake up. Also mutes the user's voice."
	icon_state = "pill4"
	list_reagents = list("capulettium_plus" = 50)

/obj/item/reagent_containers/food/pill/adminordrazine
	name = "\improper Adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill16"
	list_reagents = list("adminordrazine" = 50)

/obj/item/reagent_containers/food/pill/morphine
	name = "\improper Morphine pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"
	list_reagents = list("morphine" = 30)

/obj/item/reagent_containers/food/pill/methamphetamine
	name = "\improper Methamphetamine pill"
	desc = "Helps improve the ability to concentrate."
	icon_state = "pill8"
	list_reagents = list("methamphetamine" = 5)

/obj/item/reagent_containers/food/pill/haloperidol
	name = "\improper Haloperidol pill"
	desc = "Haloperidol is an anti-psychotic used to treat psychiatric problems."
	icon_state = "pill8"
	list_reagents = list("haloperidol" = 15)

/obj/item/reagent_containers/food/pill/happy_psych
	name = "mood stabilizer pill"
	desc = "Used to temporarily alleviate anxiety and depression. Take only as prescribed."
	icon_state = "pill_happy"
	list_reagents = list("happiness" = 15, "mannitol" = 5)

/obj/item/reagent_containers/food/pill/happy
	name = "happy pill"
	desc = "They have little happy faces on them and smell like marker pens."
	icon_state = "pill_happy"
	list_reagents = list("space_drugs" = 15, "sugar" = 15)

/obj/item/reagent_containers/food/pill/happy/happiness
	name = "fun pill"
	desc = "Makes you feel real good!"
	list_reagents = list("happiness" = 15)

/obj/item/reagent_containers/food/pill/zoom
	name = "zoom pill"
	desc = "Zoooom!"
	icon_state = "pill18"
	list_reagents = list("synaptizine" = 5, "methamphetamine" = 5)

/obj/item/reagent_containers/food/pill/charcoal
	name = "\improper Charcoal pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"
	list_reagents = list("charcoal" = 50)

/obj/item/reagent_containers/food/pill/epinephrine
	name = "\improper Epinephrine pill"
	desc = "Used to provide shots of adrenaline."
	icon_state = "pill6"
	list_reagents = list("epinephrine" = 50)

/obj/item/reagent_containers/food/pill/salicylic
	name = "\improper Salicylic Acid pill"
	desc = "Commonly used to treat moderate pain and fevers."
	icon_state = "pill4"
	list_reagents = list("sal_acid" = 20)

/obj/item/reagent_containers/food/pill/salbutamol
	name = "\improper Salbutamol pill"
	desc = "Used to treat respiratory distress."
	icon_state = "pill8"
	list_reagents = list("salbutamol" = 20)

/obj/item/reagent_containers/food/pill/hydrocodone
	name = "\improper Hydrocodone pill"
	desc = "Used to treat extreme pain."
	icon_state = "pill6"
	list_reagents = list("hydrocodone" = 15)

/obj/item/reagent_containers/food/pill/calomel
	name = "\improper Calomel pill"
	desc = "Can be used to purge impurities, but is highly toxic itself."
	icon_state = "pill3"
	list_reagents = list("calomel" = 15)

/obj/item/reagent_containers/food/pill/mutadone
	name = "\improper Mutadone pill"
	desc = "Used to cure genetic abnormalities."
	icon_state = "pill13"
	list_reagents = list("mutadone" = 1)

/obj/item/reagent_containers/food/pill/mannitol
	name = "\improper Mannitol pill"
	desc = "Used to treat cranial swelling."
	icon_state = "pill19"
	list_reagents = list("mannitol" = 10)

/obj/item/reagent_containers/food/pill/pentetic
	name ="\improper Pentetic pill"
	desc = "Used to purge substances and radiation."
	icon_state = "pill7"
	list_reagents = list("pen_acid" = 5)

/obj/item/reagent_containers/food/pill/ironsaline
	name = "\improper Iron saline pill"
	desc = "Used to help with blood loss."
	icon_state = "pill2"
	list_reagents = list("iron" = 10, "salglu_solution" = 10)

/obj/item/reagent_containers/food/pill/lazarus_reagent
	name = "\improper Lazarus Reagent pill"
	desc = "Miraculous drug used for revival. Use with caution. Improper use may cause bodies to violently blow apart."
	icon_state = "pill9"
	list_reagents = list("lazarus_reagent" = 1)

/obj/item/reagent_containers/food/pill/rezadone
	name = "\improper Rezadone pill"
	desc = "Used to rapidly repair cellular defects within a subject's cell structure."
	icon_state = "pill10"
	list_reagents = list("rezadone" = 1)
