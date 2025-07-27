/obj/item/organ/internal/lungs
	name = "lungs"
	icon_state = "lungs"
	slot = "lungs"
	organ_tag = "lungs"
	gender = PLURAL
	w_class = WEIGHT_CLASS_NORMAL

	organ_datums = list(/datum/organ/lungs)

/obj/item/organ/internal/lungs/plasmaman
	name = "plasma filter"
	desc = "A spongy rib-shaped mass for filtering plasma from the air."
	icon = 'icons/obj/species_organs/plasmaman.dmi'

	organ_datums = list(/datum/organ/lungs/plasmamen)

/obj/item/organ/internal/lungs/vox
	name = "vox lungs"
	desc = "They're filled with dust....wow."
	icon = 'icons/obj/species_organs/vox.dmi'
	sterile = TRUE

	organ_datums = list(/datum/organ/lungs/vox)

/obj/item/organ/internal/lungs/drask
	name = "drask lungs"
	icon = 'icons/obj/species_organs/drask.dmi'

	organ_datums = list(/datum/organ/lungs/drask)

/obj/item/organ/internal/lungs/tajaran
	name = "tajaran lungs"
	icon = 'icons/obj/species_organs/tajaran.dmi'
	organ_datums = list(/datum/organ/lungs/tajaran)

/obj/item/organ/internal/lungs/unathi
	name = "unathi lungs"
	icon = 'icons/obj/species_organs/unathi.dmi'
	organ_datums = list(/datum/organ/lungs/unathi)

/obj/item/organ/internal/lungs/cybernetic
	name = "cybernetic lungs"
	desc = "A cybernetic version of the lungs found in traditional humanoid entities. It functions the same as an organic lung and is merely meant as a replacement."
	icon_state = "lungs-c"
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	var/species_state = "default"

/obj/item/organ/internal/lungs/cybernetic/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] is configured for [species_state] standards of atmosphere.</span>"

/obj/item/organ/internal/lungs/cybernetic/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	var/possible = list("default" = /datum/organ/lungs, "vox" = /datum/organ/lungs/vox, "plasmamen" = /datum/organ/lungs/plasmamen)
	var/chosen = input(user, "Select lung type", "What kind of lung settings?") as null|anything in possible
	if(isnull(chosen) || chosen == species_state || !Adjacent(user) || !I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	species_state = chosen
	to_chat(user, "<span class='notice'>You configure [src] to [chosen] settings.</span>")

	var/typepath = possible[chosen]
	var/datum/organ/lungs/lungs = new typepath(src)
	qdel(organ_datums[lungs.organ_tag])
	organ_datums[lungs.organ_tag] = lungs
	if(owner) // this should never happen, but in case it somehow does...
		owner.internal_organ_datums[lungs.organ_tag] = lungs

/obj/item/organ/internal/lungs/cybernetic/upgraded
	name = "upgraded cybernetic lungs"
	desc = "A more advanced version of the stock cybernetic lungs. They are capable of filtering out lower levels of toxins and carbon dioxide."
	icon_state = "lungs-c-u"
	origin_tech = "biotech=5"

	organ_datums = list(/datum/organ/lungs/advanced_cyber)

/obj/item/organ/internal/lungs/cybernetic/upgraded/multitool_act(mob/user, obj/item/I)
	. = ..()
	var/datum/organ/lungs/lungs = organ_datums[ORGAN_DATUM_LUNGS]
	lungs.make_advanced()
