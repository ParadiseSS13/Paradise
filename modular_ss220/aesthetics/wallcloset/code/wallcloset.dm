/obj/structure/closet/walllocker
	icon = 'modular_ss220/aesthetics/wallcloset/icons/wallclosets.dmi'
	door_anim_time = 2
	enable_door_overlay = TRUE

/obj/structure/closet/walllocker/emerglocker
	door_anim_time = 2

/obj/structure/closet/walllocker/firelocker
	icon_state = "firecloset"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/walllocker/firelocker, 32, 32)

/obj/structure/closet/walllocker/firelocker/populate_contents()
	new /obj/item/extinguisher(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/clothing/head/hardhat/red(src)

/obj/structure/closet/walllocker/medlocker
	icon_state = "medcloset"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/walllocker/medlocker, 32, 32)

/obj/structure/closet/walllocker/medlocker/populate_contents()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/reagent_containers/syringe/charcoal(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)
	new /obj/item/stack/medical/splint(src)
