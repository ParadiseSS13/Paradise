//Redefining some robot procs, since drones can't be repaired and really shouldn't take component damage.
/mob/living/silicon/robot/drone/take_overall_damage(brute, burn, updating_health = TRUE, used_weapon = null, sharp = 0)
	bruteloss += brute
	fireloss += burn
	if(updating_health)
		updatehealth("take overall damage")

/mob/living/silicon/robot/drone/heal_overall_damage(brute, burn, updating_health = TRUE)

	bruteloss -= brute
	fireloss -= burn

	if(bruteloss<0) bruteloss = 0
	if(fireloss<0) fireloss = 0
	if(updating_health)
		updatehealth("heal overall damage")

/mob/living/silicon/robot/drone/take_organ_damage(brute, burn, updating_health = TRUE, sharp = 0)
	take_overall_damage(brute,burn, updating_health, null, sharp)

/mob/living/silicon/robot/drone/heal_organ_damage(brute, burn, updating_health = TRUE)
	heal_overall_damage(brute,burn, updating_health)

/mob/living/silicon/robot/drone/getFireLoss()
	return fireloss

/mob/living/silicon/robot/drone/getBruteLoss()
	return bruteloss
