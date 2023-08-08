//Техника агрессивного маркетинга мистера Ченга
/datum/martial_art/mr_chang
	name = "Mr. Chang's Aggressive Marketing"
	combos = list(/datum/martial_combo/mr_chang/steal_card)
	has_explaination_verb = TRUE
	var/stun_on_cooldown = FALSE

/datum/martial_art/mr_chang/attack_reaction(var/mob/living/carbon/human/defender, var/mob/living/carbon/human/attacker, var/obj/item/I)
	//Stunning discounts!
	if(can_use(defender) && defender.in_throw_mode && !defender.incapacitated(FALSE, TRUE) && defender.a_intent == INTENT_DISARM && !stun_on_cooldown)
		defender.visible_message("<span class='warning'>[defender] intercept attack of [attacker]!</span>")
		attacker.forceMove(defender.loc)
		attacker.adjustStaminaLoss(200)
		stun_on_cooldown = TRUE
		defender.SpinAnimation(10,1)
		attacker.SpinAnimation(10,1)
		add_attack_logs(defender, attacker, "Intercepted attack with [src]: Stunning discounts!")
		var/msg = pick("Сногсшибательные скидки!", "От скидок кругом голова!", "Предложение — хоть стой, хоть падай!", \
					"Пол тоже продаётся!", "С вас 350000 кредитов!", "Вы за это заплатите!")
		defender.say(msg)

		var/sound = pick('sound/weapons/mr_chang/mr_chang_1.mp3', 'sound/weapons/mr_chang/mr_chang_2.mp3', \
						'sound/weapons/mr_chang/mr_chang_3.mp3', 'sound/weapons/mr_chang/mr_chang_4.mp3', \
						'sound/weapons/mr_chang/mr_chang_5.mp3')
		playsound(get_turf(defender), sound, 50, 1, -1)

		spawn(4 SECONDS)
			stun_on_cooldown = FALSE
		return TRUE

/datum/martial_art/mr_chang/explaination_header(user)
	to_chat(user, "<b><i>\nПринимая позу лотоса, вы начинаете медитацию. Знания Мистера Чанга наполнаяют ваш разум.</i></b>")

/datum/martial_art/mr_chang/explaination_footer(user)
	to_chat(user, "<span class='notice'>Stunning discounts!</span>: Включенный интент Disarm и режим броска позволяют перехватить атаку в ближнем бою по себе и перебросить через себя атакующего на пол, опрокинув неприятеля в стаминакрит. Перезарядка: 4 секунды.")
	to_chat(user, "<span class='notice'>Business lunch</span>: Глутамат натрия теперь восстанавливает 0,75 ожогового/физического урона. (Содержится в малом количестве в еде Mr. Chang)")
	to_chat(user, "<span class='notice'>TAKEYOMONEY</span>: Пачка купюр при броске наносит урон, пропорциональный толщине пачки.")
	to_chat(user, "<span class='notice'>Change please!</span>: Монеты при броске имеют шанс в 30% застрять в теле жертвы, нанося малый периодический урон")
