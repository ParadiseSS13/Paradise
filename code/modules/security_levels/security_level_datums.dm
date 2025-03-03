/**
 * Security levels
 *
 * These are used by the security level subsystem. Each one of these represents a security level that a player can set.
 *
 * Base type is abstract
 */
/datum/security_level
	/// The name of this security level.
	var/name = "Not set."
	/// The numerical level of this security level, see defines for more information.
	var/number_level = -1
	/// The delay, after which the security level will be set
	var/set_delay = 0
	/// The sound that we will play when elevated to this security level
	var/elevating_to_sound
	/// The sound that we will play when lowered to this security level
	var/lowering_to_sound
	/// The AI announcement sound about code change, that will be played after main sound
	var/ai_announcement_sound
	/// Color of security level
	var/color
	/// The status display that will be posted to all status displays on security level set
	var/status_display_mode = STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME
	/// The status display data that will be posted to all status displays on security level set
	var/status_display_data = ""
	/// Our announcement title when lowering to this level
	var/lowering_to_announcement_title = "Not set."
	/// Our announcement when lowering to this level
	var/lowering_to_announcement_text = "Not set."
	/// Our announcement title when elevating to this level
	var/elevating_to_announcement_title = "Not set."
	/// Our announcement when elevating to this level
	var/elevating_to_announcement_text = "Not set."

/**
 * Should contain actions that must be completed before actual security level set
 */
/datum/security_level/proc/pre_change()
	return

/**
 * GREEN
 *
 * No threats
 */
/datum/security_level/green
	name = "green"
	number_level = SEC_LEVEL_GREEN
	ai_announcement_sound = 'sound/AI/green.ogg'
	color = "limegreen"
	lowering_to_announcement_title = "ВНИМАНИЕ! Уровень угрозы понижен до ЗЕЛЁНОГО."
	lowering_to_announcement_text = "Все угрозы для станции устранены. Все оружие должно быть в кобуре, и законы о конфиденциальности вновь полностью соблюдаются."

/**
 * BLUE
 *
 * Caution advised
 */
/datum/security_level/blue
	name = "blue"
	number_level = SEC_LEVEL_BLUE
	elevating_to_sound = 'sound/misc/notice1.ogg'
	ai_announcement_sound = 'sound/AI/blue.ogg'
	color = "dodgerblue"
	lowering_to_announcement_title = "ВНИМАНИЕ! Уровень угрозы понижен до СИНЕГО."
	lowering_to_announcement_text = "Непосредственная угроза миновала. Служба безопасности может больше не держать оружие в полной боевой готовности, но может по-прежнему держать его на виду. Выборочные обыски запрещены."
	elevating_to_announcement_title = "ВНИМАНИЕ! Уровень угрозы повышен до СИНЕГО."
	elevating_to_announcement_text = "Станция получила надежные данные о возможной враждебной активности на борту. Служба Безопасности может держать оружие на виду."

/**
 * RED
 *
 * Hostile threats
 */
/datum/security_level/red
	name = "red"
	number_level = SEC_LEVEL_RED
	elevating_to_sound = 'sound/misc/notice1.ogg'
	ai_announcement_sound = 'sound/AI/red.ogg'
	color = "red"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "redalert"
	lowering_to_announcement_title = "ВНИМАНИЕ! КОД КРАСНЫЙ!"
	lowering_to_announcement_text = "Код был снижен до красного. Станции по-прежнему грозит серьёзная опасность. Службе Безопасности рекомендуется иметь оружие в полной боевой готовности. Выборочные обыски разрешены."
	elevating_to_announcement_title = "ВНИМАНИЕ! КОД КРАСНЫЙ!"
	elevating_to_announcement_text = "Станции грозит серьёзная опасность. Службе Безопасности рекомендуется иметь оружие в полной боевой готовности. Выборочные обыски разрешены."

/**
 * Gamma
 *
 * Station major hostile threats
 */
/datum/security_level/gamma
	name = "gamma"
	number_level = SEC_LEVEL_GAMMA
	lowering_to_sound = 'sound/effects/new_siren.ogg'
	elevating_to_sound = 'sound/effects/new_siren.ogg'
	ai_announcement_sound = 'sound/AI/gamma.ogg'
	color = "gold"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "gammaalert"
	lowering_to_announcement_title = "Внимание! Код ГАММА!"
	lowering_to_announcement_text = "Центральным Командованием был установлен Код Гамма на станции. Служба безопасности должна быть полностью вооружена. Гражданский персонал обязан немедленно обратиться к Главам отделов для получения дальнейших указаний."
	elevating_to_announcement_text = "Центральным Командованием был установлен Код Гамма на станции. Служба безопасности должна быть полностью вооружена. Гражданский персонал обязан немедленно обратиться к Главам отделов для получения дальнейших указаний."
	elevating_to_announcement_title = "Внимание! Код ГАММА!"

/**
 * Epsilon
 *
 * Station is not longer under the Central Command and to be destroyed by Death Squad (Or maybe not)
 */
/datum/security_level/epsilon
	name = "epsilon"
	number_level = SEC_LEVEL_EPSILON
	set_delay = 15 SECONDS
	lowering_to_sound = 'sound/effects/purge_siren.ogg'
	elevating_to_sound = 'sound/effects/purge_siren.ogg'
	ai_announcement_sound = 'sound/AI/epsilon.ogg'
	color = "blueviolet"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "epsilonalert"
	lowering_to_announcement_title = "ВНИМАНИЕ! КОД ЭПСИЛОН!"
	lowering_to_announcement_text = "Центральным Командованием был установлен код ЭПСИЛОН. Все контракты расторгнуты."
	elevating_to_announcement_title = "ВНИМАНИЕ! КОД ЭПСИЛОН!"
	elevating_to_announcement_text = "Центральным Командованием был установлен код ЭПСИЛОН. Все контракты расторгнуты."

/datum/security_level/epsilon/pre_change()
	sound_to_playing_players_on_station_level(S = sound('sound/effects/powerloss.ogg'))

/**
 * DELTA
 *
 * Station self-destruiction mechanism has been engaged
 */
/datum/security_level/delta
	name = "delta"
	number_level = SEC_LEVEL_DELTA
	elevating_to_sound = 'sound/effects/delta_klaxon.ogg'
	ai_announcement_sound = 'sound/AI/delta.ogg'
	color = "orangered"
	status_display_mode = STATUS_DISPLAY_ALERT
	status_display_data = "deltaalert"
	elevating_to_announcement_title = "ВНИМАНИЕ! КОД ДЕЛЬТА!"
	elevating_to_announcement_text = "Механизм самоуничтожения станции задействован. Все члены экипажа обязаны подчиняться всем указаниям, данными Главами отделов. Любые нарушения этих приказов наказуемы уничтожением на месте. Это не учебная тревога."
