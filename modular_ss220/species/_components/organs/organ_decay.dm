/*
=== Компонент разложения и восстановления органов ===
Запускает процессинг, отслеживающий состояние органов, контролирует их разложение в случае смерти владельца, в случае изъятия.

В случае, если орган в теле носителя или не уничтожается и его урон ниже 25%, то происходит постепенное самовосстановление
*/

#define BASIC_RECOVER_VALUE 0.02
#define BASIC_DECAY_VALUE 0.5
#define ORGAN_RECOVERY_THRESHOLD 4 //25%
#define ORGAN_DEATH_TIMER 60 SECONDS //1 минута

/datum/component/organ_decay
	var/obj/item/organ/internal/organ = null
	var/recover_rate
	var/decay_rate
	var/death_state_timer
	var/dead_last_state = FALSE

/datum/component/organ_decay/Initialize(income_decay_rate = BASIC_RECOVER_VALUE, income_recover_rate = BASIC_DECAY_VALUE)
	organ = parent
	recover_rate = income_recover_rate
	decay_rate = income_decay_rate
	START_PROCESSING(SSdcs, src)

/datum/component/organ_decay/Destroy(force, silent)
	STOP_PROCESSING(SSdcs, src)
	. = ..()

/datum/component/organ_decay/process()
	if(organ.status & ORGAN_DEAD)
		return

	var/is_no_owner = isnull(organ.owner)
	if(!dead_last_state)
		death_state_timer = world.time
	dead_last_state = organ?.owner.stat == DEAD
	var/formaldehyde_found = organ.owner?.get_chemical_value("formaldehyde") > 0
	var/is_destroying = (dead_last_state || (is_no_owner && !organ.is_in_freezer))
	if(is_destroying && !formaldehyde_found && ((world.time - death_state_timer) >= ORGAN_DEATH_TIMER))
		organ.receive_damage(decay_rate, 1)
	if((organ.damage <= (organ.max_damage / ORGAN_RECOVERY_THRESHOLD)) && (organ.damage > 0) && !is_destroying)
		organ.heal_internal_damage(recover_rate, FALSE)
