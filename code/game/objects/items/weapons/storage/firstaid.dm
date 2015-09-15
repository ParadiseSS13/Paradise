/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 *		Dice Pack (in a pill bottle)
 */

/*
 * First Aid Kits
 */
/obj/item/weapon/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	var/empty = 0


/obj/item/weapon/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "A medical kit that contains several medical patches and pills for treating burns. Contains one epinephrine syringe for emergency use and a health analyzer."
	icon_state = "ointment"
	item_state = "firstaid-ointment"

	New()
		..()
		if (empty) return

		icon_state = pick("ointment","firefirstaid")

		new /obj/item/weapon/reagent_containers/pill/patch/silver_sulf( src )
		new /obj/item/weapon/reagent_containers/pill/patch/silver_sulf( src )
		new /obj/item/weapon/reagent_containers/pill/patch/silver_sulf( src )
		new /obj/item/weapon/reagent_containers/pill/patch/silver_sulf( src )
		new /obj/item/device/healthanalyzer( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
		new /obj/item/weapon/reagent_containers/pill/salicylic( src )
		return


/obj/item/weapon/storage/firstaid/regular
	desc = "A general medical kit that contains medical patches for both brute damage and burn damage. Also contains an epinephrine syringe for emergency use and a health analyzer"
	icon_state = "firstaid"

	New()
		..()
		if (empty) return
		new /obj/item/weapon/reagent_containers/pill/patch/styptic( src )
		new /obj/item/weapon/reagent_containers/pill/patch/styptic( src )
		new /obj/item/weapon/reagent_containers/pill/salicylic( src )
		new /obj/item/weapon/reagent_containers/pill/patch/silver_sulf( src )
		new /obj/item/weapon/reagent_containers/pill/patch/silver_sulf( src )
		new /obj/item/device/healthanalyzer( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
		return

/obj/item/weapon/storage/firstaid/toxin
	name = "toxin first aid kit"
	desc = "A medical kit designed to counter poisoning by common toxins. Contains three pills and syringes, and a health analyzer to determine the health of the patient."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

	New()
		..()
		if (empty) return

		icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

		new /obj/item/weapon/reagent_containers/syringe/charcoal( src )
		new /obj/item/weapon/reagent_containers/syringe/charcoal( src )
		new /obj/item/weapon/reagent_containers/syringe/charcoal( src )
		new /obj/item/weapon/reagent_containers/pill/charcoal( src )
		new /obj/item/weapon/reagent_containers/pill/charcoal( src )
		new /obj/item/weapon/reagent_containers/pill/charcoal( src )
		new /obj/item/device/healthanalyzer( src )
		return

/obj/item/weapon/storage/firstaid/o2
	name = "oxygen deprivation first aid kit"
	desc = "A first aid kit that contains four pills of salbutamol, which is able to counter injuries caused by suffocation. Also contains a health analyzer to determine the health of the patient."
	icon_state = "o2"
	item_state = "firstaid-o2"

	New()
		..()
		if (empty) return
		new /obj/item/weapon/reagent_containers/pill/salbutamol( src )
		new /obj/item/weapon/reagent_containers/pill/salbutamol( src )
		new /obj/item/weapon/reagent_containers/pill/salbutamol( src )
		new /obj/item/weapon/reagent_containers/pill/salbutamol( src )
		new /obj/item/device/healthanalyzer( src )
		return

/obj/item/weapon/storage/firstaid/brute
	name = "brute trauma treatment kit"
	desc = "A medical kit that contains several medical patches and pills for treating brute injuries. Contains one epinephrine syringe for emergency use and a health analyzer."
	icon_state = "brute"
	item_state = "firstaid-brute"

	New()
		..()
		if (empty) return

		icon_state = pick("brute","brute2")

		new /obj/item/weapon/reagent_containers/pill/patch/styptic(src)
		new /obj/item/weapon/reagent_containers/pill/patch/styptic(src)
		new /obj/item/weapon/reagent_containers/pill/patch/styptic(src)
		new /obj/item/weapon/reagent_containers/pill/patch/styptic(src)
		new /obj/item/device/healthanalyzer(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
		new /obj/item/stack/medical/bruise_pack(src)
		return

/obj/item/weapon/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"

/obj/item/weapon/storage/firstaid/adv/New()
	..()
	if (empty) return
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	return

/obj/item/weapon/storage/firstaid/tactical
	name = "first-aid kit"
	icon_state = "bezerk"
	desc = "I hope you've got insurance."
	max_w_class = 3

/obj/item/weapon/storage/firstaid/tactical/New()
	..()
	if (empty) return
	new /obj/item/clothing/accessory/stethoscope( src )
	new /obj/item/weapon/defibrillator/compact/combat/loaded(src)
	new /obj/item/weapon/reagent_containers/hypospray/combat(src)
	new /obj/item/weapon/reagent_containers/pill/patch/styptic(src)
	new /obj/item/weapon/reagent_containers/pill/patch/silver_sulf(src)
	new /obj/item/weapon/reagent_containers/ld50_syringe/lethal(src)
	new /obj/item/clothing/glasses/hud/health/night(src)
	return

/obj/item/weapon/storage/firstaid/surgery
	name = "field surgery kit"
	icon_state = "duffel-med"
	desc = "A kit for surgery in the field."
	max_w_class = 4
	storage_slots = 10
	can_hold = list("/obj/item/roller","/obj/item/weapon/bonesetter","/obj/item/weapon/bonegel", "/obj/item/weapon/scalpel", "/obj/item/weapon/hemostat",
		"/obj/item/weapon/cautery", "/obj/item/weapon/retractor", "/obj/item/weapon/FixOVein", "/obj/item/weapon/surgicaldrill", "/obj/item/weapon/circular_saw")

/obj/item/weapon/storage/firstaid/surgery/New()
	..()
	new /obj/item/roller(src)
	new /obj/item/weapon/bonesetter(src)
	new /obj/item/weapon/bonegel(src)
	new /obj/item/weapon/scalpel(src)
	new /obj/item/weapon/hemostat(src)
	new /obj/item/weapon/cautery(src)
	new /obj/item/weapon/retractor(src)
	new /obj/item/weapon/FixOVein(src)
	new /obj/item/weapon/surgicaldrill(src)
	new /obj/item/weapon/circular_saw(src)

/*
 * Pill Bottles
 */
/obj/item/weapon/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	w_class = 2.0
	can_hold = list("/obj/item/weapon/reagent_containers/pill","/obj/item/weapon/dice","/obj/item/weapon/paper")
	allow_quick_gather = 1
	use_to_pickup = 1
	storage_slots = 14
	display_contents_with_number = 1

/obj/item/weapon/storage/pill_bottle/MouseDrop(obj/over_object as obj) //Quick pillbottle fix. -Agouri

	if (ishuman(usr)) //Can monkeys even place items in the pocket slots? Leaving this in just in case~
		var/mob/M = usr
		if (!( istype(over_object, /obj/screen) ))
			return ..()
		if ((!( M.restrained() ) && !( M.stat ) /*&& M.pocket == src*/))
			switch(over_object.name)
				if("r_hand")
					M.unEquip(src)
					M.put_in_r_hand(src)
				if("l_hand")
					M.unEquip(src)
					M.put_in_l_hand(src)
			src.add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if (usr.s_active)
				usr.s_active.close(usr)
			src.show_to(usr)
			return
	return

/obj/item/weapon/storage/pill_bottle/charcoal
	name = "Pill bottle (Charcoal)"
	desc = "Contains pills used to counter toxins."

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/charcoal( src )
		new /obj/item/weapon/reagent_containers/pill/charcoal( src )
		new /obj/item/weapon/reagent_containers/pill/charcoal( src )
		new /obj/item/weapon/reagent_containers/pill/charcoal( src )
		new /obj/item/weapon/reagent_containers/pill/charcoal( src )
		new /obj/item/weapon/reagent_containers/pill/charcoal( src )
		new /obj/item/weapon/reagent_containers/pill/charcoal( src )

/obj/item/weapon/storage/pill_bottle/dice
	name = "pack of dice"
	desc = "It's a small container with dice inside."

	New()
		..()
		new /obj/item/weapon/dice( src )
		new /obj/item/weapon/dice/d20( src )


/obj/item/weapon/storage/pill_bottle/painkillers
	name = "Pill Bottle (Salicylic Acid)"
	desc = "Contains various pills for minor pain relief."

/obj/item/weapon/storage/pill_bottle/painkillers/New()
	..()
	new /obj/item/weapon/reagent_containers/pill/salicylic(src)
	new /obj/item/weapon/reagent_containers/pill/salicylic(src)
	new /obj/item/weapon/reagent_containers/pill/salicylic(src)
	new /obj/item/weapon/reagent_containers/pill/salicylic(src)
	new /obj/item/weapon/reagent_containers/pill/salicylic(src)
	new /obj/item/weapon/reagent_containers/pill/salicylic(src)
	new /obj/item/weapon/reagent_containers/pill/salicylic(src)
	new /obj/item/weapon/reagent_containers/pill/salicylic(src)
