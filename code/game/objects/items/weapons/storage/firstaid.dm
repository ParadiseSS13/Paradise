/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 *		Dice Pack (in a pill bottle)
 */

/*
 * First Aid Kits
 */
/obj/item/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	var/empty = 0
	req_one_access =list(ACCESS_MEDICAL, ACCESS_ROBOTICS) //Access and treatment are utilized for medbots.
	var/treatment_brute = "salglu_solution"
	var/treatment_oxy = "salbutamol"
	var/treatment_fire = "salglu_solution"
	var/treatment_tox = "charcoal"
	var/treatment_virus = "spaceacillin"
	var/med_bot_skin = null
	var/syndicate_aligned = FALSE
	var/robot_arm // This is for robot construction


/obj/item/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "A medical kit that contains several medical patches and pills for treating burns. Contains one epinephrine syringe for emergency use and a health analyzer."
	icon_state = "ointment"
	item_state = "firstaid-ointment"
	med_bot_skin = "ointment"

	New()
		..()
		if(empty) return

		icon_state = pick("ointment","firefirstaid")

		new /obj/item/reagent_containers/food/pill/patch/silver_sulf( src )
		new /obj/item/reagent_containers/food/pill/patch/silver_sulf( src )
		new /obj/item/reagent_containers/food/pill/patch/silver_sulf( src )
		new /obj/item/reagent_containers/food/pill/patch/silver_sulf( src )
		new /obj/item/healthanalyzer( src )
		new /obj/item/reagent_containers/hypospray/autoinjector( src )
		new /obj/item/reagent_containers/food/pill/salicylic( src )
		return

/obj/item/storage/firstaid/fire/empty
	empty = 1

/obj/item/storage/firstaid/regular
	desc = "A general medical kit that contains medical patches for both brute damage and burn damage. Also contains an epinephrine syringe for emergency use and a health analyzer"
	icon_state = "firstaid"

	New()
		..()
		if(empty) return
		new /obj/item/reagent_containers/food/pill/patch/styptic( src )
		new /obj/item/reagent_containers/food/pill/patch/styptic( src )
		new /obj/item/reagent_containers/food/pill/salicylic( src )
		new /obj/item/reagent_containers/food/pill/patch/silver_sulf( src )
		new /obj/item/reagent_containers/food/pill/patch/silver_sulf( src )
		new /obj/item/healthanalyzer( src )
		new /obj/item/reagent_containers/hypospray/autoinjector( src )
		return

/obj/item/storage/firstaid/toxin
	name = "toxin first aid kit"
	desc = "A medical kit designed to counter poisoning by common toxins. Contains three pills and syringes, and a health analyzer to determine the health of the patient."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"
	med_bot_skin = "tox"

	New()
		..()
		if(empty) return

		icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

		new /obj/item/reagent_containers/syringe/charcoal( src )
		new /obj/item/reagent_containers/syringe/charcoal( src )
		new /obj/item/reagent_containers/syringe/charcoal( src )
		new /obj/item/reagent_containers/food/pill/charcoal( src )
		new /obj/item/reagent_containers/food/pill/charcoal( src )
		new /obj/item/reagent_containers/food/pill/charcoal( src )
		new /obj/item/healthanalyzer( src )
		return

/obj/item/storage/firstaid/toxin/empty
	empty = 1

/obj/item/storage/firstaid/o2
	name = "oxygen deprivation first aid kit"
	desc = "A first aid kit that contains four pills of salbutamol, which is able to counter injuries caused by suffocation. Also contains a health analyzer to determine the health of the patient."
	icon_state = "o2"
	item_state = "firstaid-o2"
	med_bot_skin = "o2"

	New()
		..()
		if(empty) return
		new /obj/item/reagent_containers/food/pill/salbutamol( src )
		new /obj/item/reagent_containers/food/pill/salbutamol( src )
		new /obj/item/reagent_containers/food/pill/salbutamol( src )
		new /obj/item/reagent_containers/food/pill/salbutamol( src )
		new /obj/item/healthanalyzer( src )
		return

/obj/item/storage/firstaid/o2/empty
	empty = 1

/obj/item/storage/firstaid/brute
	name = "brute trauma treatment kit"
	desc = "A medical kit that contains several medical patches and pills for treating brute injuries. Contains one epinephrine syringe for emergency use and a health analyzer."
	icon_state = "brute"
	item_state = "firstaid-brute"
	med_bot_skin = "brute"

	New()
		..()
		if(empty) return

		icon_state = pick("brute","brute2")

		new /obj/item/reagent_containers/food/pill/patch/styptic(src)
		new /obj/item/reagent_containers/food/pill/patch/styptic(src)
		new /obj/item/reagent_containers/food/pill/patch/styptic(src)
		new /obj/item/reagent_containers/food/pill/patch/styptic(src)
		new /obj/item/healthanalyzer(src)
		new /obj/item/reagent_containers/hypospray/autoinjector(src)
		new /obj/item/stack/medical/bruise_pack(src)
		return

/obj/item/storage/firstaid/brute/empty
	empty = 1

/obj/item/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"
	med_bot_skin = "adv"

/obj/item/storage/firstaid/adv/New()
	..()
	if(empty)
		return
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/stack/medical/ointment/advanced(src)
	new /obj/item/stack/medical/ointment/advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/firstaid/adv/empty
	empty = 1

/obj/item/storage/firstaid/machine
	name = "machine repair kit"
	desc = "A kit that contains supplies to repair IPCs on the go."
	icon_state = "machinefirstaid"
	item_state = "firstaid-machine"
	med_bot_skin = "machine"

/obj/item/storage/firstaid/machine/New()
	..()
	if(empty)
		return
	new /obj/item/weldingtool(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/reagent_containers/food/drinks/oilcan/full(src)
	new /obj/item/robotanalyzer(src)

/obj/item/storage/firstaid/machine/empty
	empty = 1


/obj/item/storage/firstaid/tactical
	name = "first-aid kit"
	icon_state = "bezerk"
	desc = "I hope you've got insurance."
	max_w_class = WEIGHT_CLASS_NORMAL
	treatment_oxy = "perfluorodecalin"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"
	treatment_tox = "charcoal"
	req_one_access =list(ACCESS_SYNDICATE)
	med_bot_skin = "bezerk"
	syndicate_aligned = TRUE

/obj/item/storage/firstaid/tactical/New()
	..()
	if(empty) return
	new /obj/item/reagent_containers/hypospray/combat(src)
	new /obj/item/reagent_containers/food/pill/patch/synthflesh(src) // Because you ain't got no time to look at what damage dey taking yo
	new /obj/item/reagent_containers/food/pill/patch/synthflesh(src)
	new /obj/item/reagent_containers/food/pill/patch/synthflesh(src)
	new /obj/item/reagent_containers/food/pill/patch/synthflesh(src)
	new /obj/item/defibrillator/compact/combat/loaded(src)
	new /obj/item/clothing/glasses/hud/health/night(src)
	return

/obj/item/storage/firstaid/tactical/empty
	empty =1

/obj/item/storage/firstaid/surgery
	name = "field surgery kit"
	icon_state = "duffel-med"
	desc = "A kit for surgery in the field."
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 21
	storage_slots = 10
	can_hold = list(/obj/item/roller,/obj/item/bonesetter,/obj/item/bonegel, /obj/item/scalpel, /obj/item/hemostat,
		/obj/item/cautery, /obj/item/retractor, /obj/item/FixOVein, /obj/item/surgicaldrill, /obj/item/circular_saw)

/obj/item/storage/firstaid/surgery/New()
	..()
	new /obj/item/roller(src)
	new /obj/item/bonesetter(src)
	new /obj/item/bonegel(src)
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/cautery(src)
	new /obj/item/retractor(src)
	new /obj/item/FixOVein(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/circular_saw(src)

/*
 * Pill Bottles
 */

/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(/obj/item/reagent_containers/food/pill)
	cant_hold = list(/obj/item/reagent_containers/food/pill/patch)
	allow_quick_gather = TRUE
	use_to_pickup = TRUE
	storage_slots = 50
	max_combined_w_class = 50
	display_contents_with_number = TRUE
	var/base_name = ""
	var/label_text = ""
	var/applying_meds = FALSE //To Prevent spam clicking and generating runtimes from apply a deleting pill multiple times.
	var/rapid_intake_message = "unscrews the cap on the pill bottle and begins dumping the entire contents down their throat!"
	var/rapid_post_instake_message = "downs the entire bottle of pills in one go!"
	var/allow_wrap = TRUE
	var/wrapper_color = null

/obj/item/storage/pill_bottle/New()
	..()
	base_name = name
	if(allow_wrap)
		apply_wrap()

/obj/item/storage/pill_bottle/proc/apply_wrap()
	if(wrapper_color)
		overlays.Cut()
		var/image/I = image(icon, "pillbottle_wrap")
		I.color = wrapper_color
		overlays += I

/obj/item/storage/pill_bottle/attack(mob/M, mob/user)
	if(iscarbon(M) && contents.len)
		if(applying_meds)
			to_chat(user, "<span class='warning'>You are already applying meds.</span>")
			return
		applying_meds = TRUE
		for(var/obj/item/reagent_containers/food/pill/P in contents)
			if(P.attack(M, user))
				applying_meds = FALSE
			else
				applying_meds = FALSE
			break
	else
		return ..()

/obj/item/storage/pill_bottle/ert
	wrapper_color = COLOR_MAROON

/obj/item/storage/pill_bottle/ert/New()
	..()
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/charcoal(src)
	new /obj/item/reagent_containers/food/pill/charcoal(src)
	new /obj/item/reagent_containers/food/pill/charcoal(src)

/obj/item/storage/pill_bottle/MouseDrop(obj/over_object as obj) // Best utilized if you're a cantankerous doctor with a Vicodin habit.
	if(iscarbon(over_object))
		var/mob/living/carbon/C = over_object
		if(loc == C && src == C.get_active_hand())
			if(!contents.len)
				to_chat(C, "<span class='notice'>There is nothing in [src]!</span>")
				return
			C.visible_message("<span class='danger'>[C] [rapid_intake_message]</span>")
			if(do_mob(C, C, 100)) // 10 seconds
				for(var/obj/item/reagent_containers/food/pill/P in contents)
					P.attack(C, C)
				C.visible_message("<span class='danger'>[C] [rapid_post_instake_message]</span>")
			return

	return ..()

/obj/item/storage/pill_bottle/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen) || istype(I, /obj/item/flashlight/pen))
		var/tmp_label = sanitize(input(user, "Enter a label for [name]","Label",label_text))
		if(length(tmp_label) > MAX_NAME_LEN)
			to_chat(user, "<span class='warning'>The label can be at most [MAX_NAME_LEN] characters long.</span>")
		else
			to_chat(user, "<span class='notice'>You set the label to \"[tmp_label]\".</span>")
			label_text = tmp_label
			update_name_label()
	else
		return ..()

/obj/item/storage/pill_bottle/proc/update_name_label()
	if(label_text == "")
		name = base_name
	else
		name = "[base_name] ([label_text])"

/obj/item/storage/pill_bottle/patch_pack
	name = "Patch Pack"
	desc = "It's a container for storing medical patches."
	icon_state = "patch_pack"
	can_hold = list(/obj/item/reagent_containers/food/pill/patch)
	cant_hold = list()
	rapid_intake_message = "flips the lid of the Patch Pack open and begins rapidly stamping patches on themselves!"
	rapid_post_instake_message = "stamps the entire contents of the Patch Pack all over their entire body!"
	allow_wrap = FALSE

/obj/item/storage/pill_bottle/charcoal
	name = "Pill bottle (Charcoal)"
	desc = "Contains pills used to counter toxins."
	wrapper_color = COLOR_GREEN

	New()
		..()
		new /obj/item/reagent_containers/food/pill/charcoal( src )
		new /obj/item/reagent_containers/food/pill/charcoal( src )
		new /obj/item/reagent_containers/food/pill/charcoal( src )
		new /obj/item/reagent_containers/food/pill/charcoal( src )
		new /obj/item/reagent_containers/food/pill/charcoal( src )
		new /obj/item/reagent_containers/food/pill/charcoal( src )
		new /obj/item/reagent_containers/food/pill/charcoal( src )

/obj/item/storage/pill_bottle/painkillers
	name = "Pill Bottle (Salicylic Acid)"
	desc = "Contains various pills for minor pain relief."
	wrapper_color = COLOR_RED

/obj/item/storage/pill_bottle/painkillers/New()
	..()
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)

/obj/item/storage/pill_bottle/fakedeath
	allow_wrap = FALSE

/obj/item/storage/pill_bottle/fakedeath/New()
	..()
	new /obj/item/reagent_containers/food/pill/fakedeath(src)
	new /obj/item/reagent_containers/food/pill/fakedeath(src)
	new /obj/item/reagent_containers/food/pill/fakedeath(src)
