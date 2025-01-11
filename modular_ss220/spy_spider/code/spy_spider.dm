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

/obj/item/radio/spy_spider/attack_self__legacy__attackchain(mob/user)
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

/obj/item/clothing/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/radio/spy_spider))
		return ..()
	if(spy_spider_attached || !((slot_flags & ITEM_SLOT_OUTER_SUIT) || (slot_flags & ITEM_SLOT_JUMPSUIT)))
		to_chat(user, span_warning("Ты не находишь места для жучка!"))
		return TRUE
	var/obj/item/radio/spy_spider/spy_spider = I

	if(!spy_spider.broadcasting)
		to_chat(user, span_warning("Жучок выключен!"))
		return TRUE

	user.unequip(spy_spider)
	spy_spider.forceMove(src)
	spy_spider_attached = spy_spider
	to_chat(user, span_info("Ты незаметно прикрепляешь жучок к [src]."))
	return TRUE

/obj/item/clothing/proc/remove_spy_spider(cloth_uid, spider_uid)
	if(!in_range(src, usr))
		to_chat(usr, span_info("Тебе нужно подойти ближе, чтобы снять жучок с [src.declent_ru(GENITIVE)]."))
		return
	if(usr.stat || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || usr.restrained())
		to_chat(usr, span_info("Тебе нужны свободные руки для этого"))
		return
	if(isnull(src.spy_spider_attached))
		to_chat(usr, span_info("На [src.declent_ru(PREPOSITIONAL)] нет жучка."))
		return

	var/obj/item/I = locate(spider_uid)
	if(do_after(usr, 3 SECONDS, needhand = TRUE, target = src))
		if(usr.put_in_any_hand_if_possible(I))
			usr.visible_message("[capitalize(usr.declent_ru(NOMINATIVE))] что-то снимает с [src.declent_ru(GENITIVE)] !", span_notice("Вы успешно снимаете жучок с [src.declent_ru(ACCUSATIVE)]."))
		else
			I.forceMove(get_turf(src))
			usr.visible_message("[capitalize(usr.declent_ru(NOMINATIVE))] роняет шпионский жучок на пол.", span_notice("Вы роняете жучок на пол."))
		spy_spider_attached = null

/obj/item/clothing/Topic(href, href_list)
	. = ..()
	remove_spy_spider(href_list["src"], href_list["remove_spy_spider"])

/**
 * HUMAN PART
 */
/mob/living/carbon/human/attackby__legacy__attackchain(obj/item/I, mob/living/user, def_zone)
	if(!istype(I, /obj/item/radio/spy_spider))
		return ..()

	if(!(w_uniform || wear_suit))
		to_chat(user, span_warning("У тебя нет желания лезть к [src.declent_ru(GENITIVE)] в трусы. Жучок надо крепить на одежду!"))
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

	user.unequip_to(spy_spider, clothing_for_attach)
	clothing_for_attach.spy_spider_attached = spy_spider
	to_chat(user, span_info("Ты незаметно прикрепляешь жучок к одежде [src.declent_ru(ACCUSATIVE)]."))
	return TRUE

/obj/item/clothing/suit/storage/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/radio/spy_spider))
		return
	. = ..()

// Spy spider detection
/obj/item/detective_scanner/scan(atom/A, mob/user)
	. = ..()

	if(!scanning)
		scanning = TRUE

	if(istype(A, /obj/item/clothing))
		var/obj/item/clothing/scanned_clothing = A
		usr.visible_message("[capitalize(usr.declent_ru(NOMINATIVE))] сканирует одежду на наличие шпиоского устройства.")

		if(scanned_clothing.spy_spider_attached)
			// Triger /obj/item/clothing/Topic
			add_log(span_info("<a href='byond://?src=[scanned_clothing.UID()];remove_spy_spider=[scanned_clothing.spy_spider_attached.UID()];' class='warning'><b>Найдено шпионское устройство!</b></a>"))
		else
			usr.visible_message("Но ничего не находит")
	scanning = FALSE
