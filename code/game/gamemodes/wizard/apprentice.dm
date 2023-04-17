/obj/item/contract
	name = "contract"
	desc = "A magic contract."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/used = 0
	var/infinity_uses = 0

/////////Apprentice Contract//////////

/obj/item/contract/apprentice
	name = "apprentice contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."

/obj/item/contract/apprentice/Topic(href, href_list)
	..()
	if(!ishuman(usr))
		to_chat(usr, "Вы даже не гуманоид... Вы не понимаете как этим пользоваться и что здесь написано.")
		return 0

	var/mob/living/carbon/human/teacher = usr

	if(teacher.stat || teacher.restrained())
		return 0

	if(loc == teacher || (in_range(src, teacher) && isturf(loc)))
		teacher.set_machine(src)
		if(href_list["school"])
			if(used)
				to_chat(teacher, "<span class='notice'>You already used this contract!</span>")
				return
			if (!infinity_uses)
				used = 1
			to_chat(teacher, "<span class='notice'>Apprentice waiting...</span>")
			var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_wizard")
			var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as the wizard apprentice of [teacher.real_name]?", ROLE_WIZARD, TRUE, source = source)
			if(length(candidates))
				var/mob/C = pick(candidates)
				new /obj/effect/particle_effect/smoke(teacher.loc)
				var/mob/living/carbon/human/apprentice = new/mob/living/carbon/human(teacher.loc)
				apprentice.key = C.key
				to_chat(apprentice, "<span class='notice'>You are the [teacher.real_name]'s apprentice! You are bound by magic contract to follow [teacher.p_their()] orders and help [teacher.p_them()] in accomplishing their goals.</span>")

				school_href_choose(href_list, teacher, apprentice)

				apprentice.equip_or_collect(new /obj/item/radio/headset(apprentice), slot_l_ear)
				apprentice.equip_or_collect(new /obj/item/clothing/under/color/lightpurple(apprentice), slot_w_uniform)
				apprentice.equip_or_collect(new /obj/item/clothing/shoes/sandal(apprentice), slot_shoes)
				apprentice.equip_or_collect(new /obj/item/clothing/suit/wizrobe(apprentice), slot_wear_suit)
				apprentice.equip_or_collect(new /obj/item/clothing/head/wizard(apprentice), slot_head)
				apprentice.equip_or_collect(new /obj/item/storage/backpack/satchel(apprentice), slot_back)
				apprentice.equip_or_collect(new /obj/item/storage/box/survival(apprentice), slot_in_backpack)
				apprentice.equip_or_collect(new /obj/item/teleportation_scroll/apprentice(apprentice), slot_r_store)
				var/wizard_name_first = pick(GLOB.wizard_first)
				var/wizard_name_second = pick(GLOB.wizard_second)
				var/randomname = "[wizard_name_first] [wizard_name_second]"
				var/newname = sanitize(copytext_char(input(apprentice, "You are the wizard's apprentice. Would you like to change your name to something else?", "Name change", randomname) as null|text,1,MAX_NAME_LEN))

				if(!newname)
					newname = randomname
				apprentice.mind.name = newname
				apprentice.real_name = newname
				apprentice.name = newname
				var/datum/objective/protect/new_objective = new /datum/objective/protect
				new_objective.owner = apprentice.mind
				new_objective:target = teacher.mind
				new_objective.explanation_text = "Protect [teacher.real_name], the wizard teacher."
				apprentice.mind.objectives += new_objective
				SSticker.mode.apprentices += apprentice.mind
				apprentice.mind.special_role = SPECIAL_ROLE_WIZARD_APPRENTICE
				SSticker.mode.update_wiz_icons_added(apprentice.mind)
				apprentice.faction = list("wizard")
			else
				used = 0
				to_chat(teacher, "<span class='warning'>Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later.</span>")
	return

/////////Apprentice Choose Book//////////

/obj/item/contract/apprentice_choose_book
	name = "магический учебник"
	desc = "Магический учебник, позволяющий ученику-владельцу определиться в своем обучении."
	icon = 'icons/obj/library.dmi'
	icon_state = "book15"

	var/mob/living/carbon/human/owner

/obj/item/contract/apprentice_choose_book/infinity_book
	name = "магический учебник полукровки"
	desc = "Магический учебник с яркой выраженной подписью какой-то полукровки. Похоже он как-то переписал магию, из-за которой учебник не стирает буквы после использования. Откуда он у вас?!"
	infinity_uses = 1

/obj/item/contract/apprentice_choose_book/Topic(href, href_list)
	..()
	if(!ishuman(usr))
		to_chat(usr, "Вы даже не гуманоид... Вы не понимаете как этим пользоваться и что здесь написано.")
		return 0

	var/mob/living/carbon/human/apprentice = usr

	if(apprentice.stat || apprentice.restrained())
		return 0

	if(loc == apprentice || (in_range(src, apprentice) && isturf(loc)))
		apprentice.set_machine(src)
		if(href_list["school"])
			if(used)
				to_chat(apprentice, "<span class='notice'>Учебник уже был изучен!</span>")
				return
			if (!infinity_uses)
				used = 1

			school_href_choose(href_list, null, apprentice)
	return

/////////Choose Spells Pack//////////

/obj/item/contract/proc/school_href_choose(href_list, mob/living/carbon/human/teacher, mob/living/carbon/human/apprentice)
	var/school_id = href_list["school"]
	var/datum/possible_schools/schools = new
	for (var/datum/magick_school/school in schools.schools_list)
		if (school_id != school.id)
			continue
		school.owner = apprentice
		school.kit()
		if (teacher)
			to_chat(teacher, "<B>Ваш подопечный прибыл по первому вашему зову. Прилежно и усердно обучаясь у вас, он смог выучить одну из школ магии. [school.desc]")
			to_chat(apprentice, "<B>Ваше служение не осталось незамеченный. Обучаясь у [teacher.real_name], вы смогли научиться одной из школ магии. [school.desc]")
		else
			to_chat(apprentice, "<B>Выбрана [school.name]. [school.desc]")
		break

/obj/item/contract/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat = {"<meta charset="UTF-8">"}
	if(used)
		dat += used_contract()
	else
		dat += tittle()

		var/datum/possible_schools/schools = new
		for (var/datum/magick_school/school in schools.schools_list)
			dat += "<A href='byond://?src=[UID()];school=[school.id]'>[school.name]</A><BR>"
			dat += "<I>[school.desc]</I><BR>"

	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

///Титульник в контракте
/obj/item/contract/proc/tittle()
	var/dat = "<B>Contract of apprenticeship:</B><BR>"
	dat += "<I>Using this contract, you may summon an apprentice to aid you on your mission.</I><BR>"
	dat += "<I>If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.</I><BR>"

	dat += "<B>Which school of magic is your apprentice studying?:</B><BR>"
	return dat

/obj/item/contract/apprentice_choose_book/tittle()
	var/dat = "<B>Магический учебник:</B><BR>"
	dat += "<I>Изучив этот учебник, вы определитесь в магии, которую будете практиковать.</I><BR>"
	dat += "<I>Перед тем как выбрать один из путей, хорошо подумайте и поговорите со своим учителем для получении рекомендаций.</I><BR>"
	dat += "<I>Если учитель не настроен на разговор - ничего страшного! В данном учебнике приведено краткое описание возможных путей.</I><BR>"

	dat += "<BR><B>Какую школу магии вы хотели бы изучать?:</B><BR>"
	return dat

///Сообщение выдаваемое при использовании использованных контрактов
/obj/item/contract/proc/used_contract()
	return "<span class='notice'>You have already summoned your apprentice.</span><BR>"

/obj/item/contract/apprentice_choose_book/used_contract()
	return "<span class='notice'>Письмена стерты, а все страницы пусты. Похоже учебник уже был изучен.</span><BR>"

/////////Magick Schools//////////

/datum/possible_schools
	var/list/datum/schools_list = list (
		new /datum/magick_school.fire,
		new /datum/magick_school.healer,
		new /datum/magick_school.motion,
		new /datum/magick_school.defense,
		new /datum/magick_school.stand,
		new /datum/magick_school.sabotage,
		new /datum/magick_school.sculpt,
		new /datum/magick_school.instability,
		new /datum/magick_school.vision,
		new /datum/magick_school.replace,
		new /datum/magick_school.destruction,
		new /datum/magick_school.singulo,
		new /datum/magick_school.blood,
		new /datum/magick_school.necromantic,
	)


/datum/magick_school
	var/name = "Школа Безымянности (перешлите это разработчику)"
	var/id = "no_name"
	var/desc = "Описание заклинаний"
	var/mob/living/carbon/human/owner

/datum/magick_school/proc/kit()
	return 0


/datum/magick_school/healer
	name = "Школа Исцеления"
	id = "healer"
	desc = "Школа, практикующие заклинания для выживания и исцеления травм, с созданием защитного барьера для самозащиты."

/datum/magick_school/healer/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/summonitem(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall(null))
	owner.equip_or_collect(new /obj/item/gun/magic/staff/healing(owner), slot_r_hand)

	//Нацепляем белый балахон
	var/obj/item/clothing/suit/storage/mercy_hoodie/suit = new (owner)
	suit.magical = TRUE
	suit.name = "Роба целителя"
	suit.desc = "Магическая роба прислужника-целителя, оберегающая от проказы."
	owner.equip_or_collect(suit, slot_wear_suit)
	var/obj/item/clothing/head/mercy_hood/head = new (owner)
	head.magical = TRUE
	head.name = "Капюшон целителя"
	head.desc = "Магический капюшон робы прислужника-целителя, оберегающий от проказы."
	owner.equip_or_collect(head, slot_head)


/datum/magick_school/motion
	name = "Школа Пространства"
	id = "motion"
	desc = "Школа, практикующая разнообразные техники перемещения. Эфирный прыжок, телепортация и блинк заставят возненавидеть назойливого волшебника!"

/datum/magick_school/motion/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink(null))

	//Нацепляем фиолетовый защитный балахон
	var/obj/item/clothing/suit/space/suit = new
	suit.magical = TRUE
	suit.slowdown = 0
	suit.icon_state = "psyamp"
	suit.name = "Роба межпространства"
	suit.desc = "Магическая роба прислужника школы пространства, оберегающий владельца от перемещений в агрессивных средах."
	owner.equip_or_collect(suit, slot_wear_suit)
	var/obj/item/clothing/head/helmet/space/head = new
	head.magical = TRUE
	head.icon_state = "amp"
	head.name = "Капюшон Межпространства"
	head.desc = "Магический головной убор робы прислужника школы пространства, оберегающий от перемещений в агрессивных средах."
	owner.equip_or_collect(head, slot_head)


/datum/magick_school/sabotage
	name = "Школа Диверсии"
	id = "sabotage"
	desc = "Школа, практикующаяся в нанесении ущерба грязным технологиям магглов. Магглы не любят, когда технологии восстают против них самих."

/datum/magick_school/sabotage/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/summonitem(null))
	owner.equip_or_collect(new /obj/item/gun/magic/staff/animate(owner), slot_r_hand)

	var/obj/item/clothing/suit/blacktrenchcoat/suit = new
	suit.magical = TRUE
	suit.name = "Роба саботёра"
	suit.desc = "Магическая роба-саботёра. Стильная и приталенная!"
	owner.equip_or_collect(suit, slot_wear_suit)

	var/obj/item/clothing/head/fedora/head = new
	suit.magical = TRUE
	suit.name = "Ведора саботёра"
	suit.desc = "Магическая ведора-саботёра. Стильная и уважаемая!"
	owner.equip_or_collect(head, slot_head)


/datum/magick_school/defense
	name = "Школа Защиты"
	id = "defense"
	desc = "Школа, практикующая заклинания защиты, не допускающая допуск неприятеля и заставляющая его держать дистанцию!"

/datum/magick_school/defense/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall/greater(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/repulse(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/sacred_flame(null))
	ADD_TRAIT(owner, RESISTHOT, SUMMON_MAGIC)	//sacred_flame из-за не совсем верной выдачи, без этого, не выдает защиту от огня.

	//Стандартный костюм мага-воителя, который есть в башне волшебника и так.
	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/magusred(owner), slot_wear_suit)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/magus(owner), slot_head)


/datum/magick_school/fire
	name = "Школа Огня"
	id = "fire"
	desc = "Классическая школа огня, прислужники которой искусно владеют стихией огня!"

/datum/magick_school/fire/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/smoke(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/fireball(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/sacred_flame(null))
	ADD_TRAIT(owner, RESISTHOT, SUMMON_MAGIC)

	//Надеваем красный балахон
	var/obj/item/clothing/suit/victcoat/red/suit = new
	suit.name = "Роба огня"
	suit.desc = "Магическая роба последователей школы огня."
	suit.magical = 1
	owner.equip_or_collect(suit, slot_wear_suit)


/datum/magick_school/sculpt
	name = "Школа Ваяния"
	id = "sculpt"
	desc = "Школа, практикующая оживление статики, и каменение динамики."

/datum/magick_school/sculpt/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/flesh_to_stone(null))
	owner.equip_or_collect(new /obj/item/gun/magic/staff/animate(owner), slot_r_hand)

	//Костюм настоящего художника-скульптора.
	var/obj/item/clothing/suit/chef/classic/suit = new
	suit.magical = TRUE
	suit.name = "Фартук скульптора-волшебника"
	suit.desc = "Классический фартук последователей школы ваяния, хорошо защищает от разлетающейся глины."
	owner.equip_or_collect(suit, slot_wear_suit)
	var/obj/item/clothing/head/beret/ce/head = new
	head.magical = TRUE
	head.name = "Берет скульптора-волшебника"
	head.desc = "Классический берет последователей школы ваяния, позволяет выглядеть как настоящий художник."
	owner.equip_or_collect(head, slot_head)


/datum/magick_school/stand
	name = "Школа Хранителей"
	id = "stand"
	desc = "Школа, практикующее владение собственным стендом-защитником с защитной стеной."

/datum/magick_school/stand/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall/greater(null))
	owner.equip_or_collect(new /obj/item/guardiancreator(owner), slot_r_hand)


/datum/magick_school/instability
	name = "Школа Неустойчивости"
	id = "instability"
	desc = "Школа, не позволяющая магглам стоять в полный рост перед волшебниками. Ей даже интересовалась федерация Клоунов."

/datum/magick_school/instability/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/summonitem(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/repulse(null))
	owner.equip_or_collect(new /obj/item/gun/magic/staff/slipping(owner), slot_r_hand)
	owner.equip_or_collect(new /obj/item/bikehorn, slot_belt)


/datum/magick_school/blood
	name = "Школа Крови"
	id = "blood"
	desc = "Запретная школа, вызывающая опасения у архимагов, но допущенная к изучению. Юный последователь крови получает собственную робу, цепь и камни душ."

/datum/magick_school/blood/kit()
	owner.equip_or_collect(new /obj/item/storage/belt/soulstone/full(owner), slot_belt)
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct(null))

	var/obj/item/melee/chainofcommand/chain = new
	chain.name = "Жертвенная Цепь"
	chain.desc = "Цепь последователя школы крови для нанесения увечий и пускания крови."
	chain.force = 15
	owner.equip_or_collect(chain, slot_r_hand)

	var/obj/item/clothing/suit/hooded/cultrobes/suit = new
	suit.name = "Жертвенная роба"
	suit.desc = "Магическая роба последователей школы крови."
	owner.equip_or_collect(suit, slot_wear_suit)


/datum/magick_school/necromantic
	name = "Школа Некромантии"
	id = "necro"
	desc = "Запретная школа, заставляющая мертвых служить некроманту, заключившему контракт души."

/datum/magick_school/necromantic/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/lichdom(null))
	owner.equip_or_collect(new /obj/item/necromantic_stone(owner), slot_l_store)
	owner.equip_or_collect(new /obj/item/necromantic_stone(owner), slot_r_store)


/datum/magick_school/vision
	name = "Школа Прозрения"
	id = "vision"
	desc = "Древняя школа, практикующее безмерное видение с лишением зрения недостойных. Послужники носят уникальные робы."

/datum/magick_school/vision/kit()
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/trigger/blind(null))
	owner.equip_or_collect(new /obj/item/scrying(owner), slot_r_hand)
	//Выдаем трейты ОРБа
	if(!(XRAY in owner.mutations))
		owner.mutations.Add(XRAY)
		owner.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
		owner.see_in_dark = 8
		owner.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		to_chat(owner, "<span class='notice'>The walls suddenly disappear.</span>")

	//Нацепляем простой фиолетовый балахон
	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/psypurple(owner), slot_wear_suit)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/amp(owner), slot_head)


/datum/magick_school/singulo
	name = "Школа Сингулярности"
	id = "singulo"
	desc = "Древняя школа, практикующая древние познания владения сингулярности."

/datum/magick_school/singulo/kit()
	owner.equip_or_collect(new /obj/item/twohanded/singularityhammer(owner), slot_r_hand)
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/repulse(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/summonitem(null))

	//Всё тот же костюм мага воителя, но с спрайтом сингулярного рыцаря.
	var/obj/item/clothing/suit/wizrobe/magusred/suit = new
	suit.magical = TRUE
	suit.icon_state = "hardsuit-singuloth"
	suit.item_state = "singuloth_hardsuit"
	suit.name = "Роба межпространства"
	suit.desc = "Древняя броня последователя школы сингулярности."
	owner.equip_or_collect(suit, slot_wear_suit)
	var/obj/item/clothing/head/wizard/magus/head = new
	head.magical = TRUE
	head.icon_state = "hardsuit0-singuloth"
	head.item_state = "singuloth_helm"
	head.name = "Капюшон межпространства"
	head.desc = "Древний шлем последователя школы сингулярности."
	owner.equip_or_collect(head, slot_head)


/datum/magick_school/replace
	name = "Школа Подмены"
	id = "replace"
	desc = "Старая школа, практикующая заклинания для чтения без мантии с подменам разума и открытием закрытых дверей."

/datum/magick_school/replace/kit()		//старый набор
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/mind_transfer(null))

	//Нацепляем простой фиолетовый балахон
	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/psypurple(owner), slot_wear_suit)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/amp(owner), slot_head)


/datum/magick_school/destruction
	name = "Школа Разрушения"
	id = "destruction"
	desc = "Старая школа, практикующая заклинания на нанесении ущерба."

/datum/magick_school/destruction/kit()	//старый набор
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/fireball(null))
	owner.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/lightning(null))

	//Стандартный костюм мага-воителя, который есть в башне волшебника и так.
	owner.equip_or_collect(new /obj/item/clothing/suit/wizrobe/magusred(owner), slot_wear_suit)
	owner.equip_or_collect(new /obj/item/clothing/head/wizard/magus(owner), slot_head)

