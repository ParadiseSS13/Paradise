/datum/controller/subsystem/radio/frequency_span_class(frequency)
	if(frequency == SPY_SPIDER_FREQ)
		return "spyradio"
	return ..()

/obj/item/radio/spy_spider
	name = "шпионский жучок"
	desc = "Кажется, ты видел такого в фильмах про шпионов."
	icon = 'modular_ss220/spy_spider/icons/spy_spider.dmi'
	icon_state = "spy_spider"
	frequency = SPY_SPIDER_FREQ
	freqlock = SPY_SPIDER_FREQ
	listening = FALSE
	broadcasting = FALSE
	canhear_range = 3

/obj/item/radio/spy_spider/examine(mob/user)
	. = ..()
	. += span_info("Сейчас он [broadcasting ? "включён" : "выключен"].")

/obj/item/radio/spy_spider/attack_self(mob/user)
	broadcasting = !broadcasting
	if(broadcasting)
		to_chat(user, span_info("Ты включаешь жучок."))
	else
		to_chat(user, span_info("Ты выключил жучок."))
	return TRUE

/obj/item/encryptionkey/spy_spider
	name = "Spy Encryption Key"
	icon = 'modular_ss220/spy_spider/icons/spy_spider.dmi'
	icon_state = "spy_cypherkey"
	channels = list("Spy Spider" = TRUE)

/obj/item/storage/lockbox/spy_kit
	name = "набор жучков"
	desc = "Не самый легальный из способов достать информацию, но какая разница, если никто не узнает?"
	storage_slots = 5
	req_access = list(ACCESS_FORENSICS_LOCKERS)

/obj/item/storage/lockbox/spy_kit/Initialize(mapload)
	. = ..()
	new /obj/item/radio/spy_spider(src)
	new /obj/item/radio/spy_spider(src)
	new /obj/item/radio/spy_spider(src)
	new /obj/item/encryptionkey/spy_spider(src)
	new /obj/item/encryptionkey/spy_spider(src)

/**
 * CLOTHING PART
 */
/obj/item/clothing
	var/obj/item/radio/spy_spider/spy_spider_attached

/obj/item/clothing/Destroy()
	QDEL_NULL(spy_spider_attached)
	return ..()

/obj/item/clothing/emp_act(severity)
	. = ..()
	spy_spider_attached?.emp_act(severity)

/obj/item/clothing/hear_talk(mob/M, list/message_pieces)
	. = ..()
	spy_spider_attached?.hear_talk(M, message_pieces)

/obj/item/clothing/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/radio/spy_spider))
		return ..()
	if(spy_spider_attached || !((slot_flags & SLOT_FLAG_OCLOTHING) || (slot_flags & SLOT_FLAG_ICLOTHING)))
		to_chat(user, span_warning("Ты не находишь места для жучка!"))
		return TRUE
	var/obj/item/radio/spy_spider/spy_spider = I

	if(!spy_spider.broadcasting)
		to_chat(user, span_warning("Жучок выключен!"))
		return TRUE

	user.unEquip(spy_spider)
	spy_spider.forceMove(src)
	spy_spider_attached = spy_spider
	to_chat(user, span_info("Ты незаметно прикрепляешь жучок к [src]."))
	return TRUE

/obj/item/clothing/proc/remove_spy_spider()
	set name = "Снять жучок"
	set category = "Object"
	set src in range(1, usr)

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr

	if(spy_spider_attached)
		if(!user.put_in_any_hand_if_possible(spy_spider_attached, del_on_fail = FALSE))
			var/turf/user_loc = get_turf(user)
			spy_spider_attached.forceMove(user_loc)
		spy_spider_attached = null

	verbs -= /obj/item/clothing/proc/remove_spy_spider

/**
 * HUMAN PART
 */
/mob/living/carbon/human/attackby(obj/item/I, mob/living/user, def_zone)
	if(!istype(I, /obj/item/radio/spy_spider))
		return ..()

	if(!(w_uniform || wear_suit))
		to_chat(user, span_warning("У тебя нет желания лезть к [src] в трусы. Жучок надо крепить на одежду!"))
		return TRUE

	var/obj/item/radio/spy_spider/spy_spider = I
	var/obj/item/clothing/clothing_for_attach = wear_suit || w_uniform
	if(clothing_for_attach.spy_spider_attached)
		to_chat(user, span_warning("Ты не находишь места для жучка!"))
		return TRUE

	if(!spy_spider.broadcasting)
		to_chat(user, span_warning("Жучок выключен!"))
		return TRUE

	var/attempt_cancel_message = span_warning("Ты не успеваешь установить жучок.")
	if(!do_after_once(user, 3 SECONDS, TRUE, src, TRUE, attempt_cancel_message))
		return TRUE

	user.unEquip(spy_spider)
	spy_spider.forceMove(clothing_for_attach)
	clothing_for_attach.spy_spider_attached = spy_spider
	to_chat(user, span_info("Ты незаметно прикрепляешь жучок к одежде [src]."))
	return TRUE

/obj/item/clothing/suit/storage/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/radio/spy_spider))
		return
	. = ..()

// Spy spider detection
/obj/item/detective_scanner/scan(atom/A, mob/user)
	. = ..()
	var/found_spy_device = FALSE
	if(!scanning)
		scanning = TRUE

		if(istype(A, /obj/item/clothing))
			var/obj/item/clothing/scanned_clothing = A
			if(scanned_clothing.spy_spider_attached)
				found_spy_device = TRUE

		if(found_spy_device)
			sleep(1 SECONDS)
			add_log(span_info("<B>Найдено шпионское устройство!</B>"))
			if(!(/obj/item/clothing/proc/remove_spy_spider in A.verbs))
				add_verb(A, /obj/item/clothing/proc/remove_spy_spider)

		scanning = FALSE
