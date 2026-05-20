/obj/item/reagent_containers/glass/gnesis
	name = "fluid-filled octahedron"
	desc = "A strange container made of a crystalline matrix. It looks like it can hold reagents but it's a mystery how to access them"
	icon = 'icons/goonstation/mob/featherzone.dmi'
	icon_state = "minicache"
	inhand_icon_state = "beaker"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 25, 30, 50)
	volume = 200
	resistance_flags = ACID_PROOF
	container_type = REFILLABLE | DRAINABLE
	materials = list(MAT_GNESIS_GLASS = 2000)

/obj/item/reagent_containers/glass/gnesis/examine(mob/user)
	if(!isflockmob(user))
		return ..()

	. = list(
		SPAN_FLOCKSAY("<b>###=- Ident confirmed, data packet received.</b>"),
		SPAN_FLOCKSAY("<b>ID:</b> Reagent Minicache"),
		SPAN_FLOCKSAY("<b>System Storage:</b> [(reagents.total_volume / volume)]% filled."),
		SPAN_FLOCKSAY("<b>###=-</b>")
	)

/obj/item/reagent_containers/glass/gnesis/prefilled
	list_reagents = list("gnesis_tox" = 50)
