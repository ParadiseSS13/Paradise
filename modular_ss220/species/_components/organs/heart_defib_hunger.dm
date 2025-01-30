/*
=== Компонент запуска сердца ===
Отслеживает смерть носителя, и в случае чего - запускает сердце с неким шансом
*/
#define AUTO_DEFIBRILATION_THRESHOLD 100

/datum/component/defib_heart_hunger
	var/obj/item/organ/internal/organ

/datum/component/defib_heart_hunger/Initialize(human, income_chemical_id = "")
	organ = parent
	START_PROCESSING(SSdcs, src)

/datum/component/defib_heart_hunger/Destroy(force, silent)
	STOP_PROCESSING(SSdcs, src)
	. = ..()

/datum/component/defib_heart_hunger/process()
	var/mob/living/carbon/human/owner = organ.owner
	if(!owner)
		var/obj/item/organ/internal/limb = parent
		owner = limb.owner
	if(!owner)
		return
	var/damage_amount = owner.getBruteLoss() + owner.getFireLoss() + owner.getCloneLoss()
	if(owner?.nutrition < NUTRITION_LEVEL_HUNGRY || owner.stat != DEAD || damage_amount > AUTO_DEFIBRILATION_THRESHOLD)
		return
	var/defib_chance = owner.nutrition - NUTRITION_LEVEL_HUNGRY
	owner.adjust_nutrition(-defib_chance)
	if(prob(defib_chance))
		owner.setOxyLoss(0)
		owner.set_heartattack(FALSE)
		owner.update_revive()
		owner.KnockOut()
		owner.Paralyse(10 SECONDS)
		owner.emote("gasp")
		SEND_SIGNAL(owner, COMSIG_LIVING_MINOR_SHOCK, 100)
		owner.med_hud_set_health()
		owner.med_hud_set_status()
		add_attack_logs(owner, owner, "Revived by heart")
		owner.reagents.add_reagent("mannitol", 2)
		owner.reagents.add_reagent("epinephrine", 2)
		SSblackbox.record_feedback("tally", "players_revived", 1, "self_revived")
		owner.visible_message(span_warning("Тело [owner] содрагают судороги!"))

#undef AUTO_DEFIBRILATION_THRESHOLD
