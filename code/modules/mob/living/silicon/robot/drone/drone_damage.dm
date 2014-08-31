//Redefining some robot procs, since drones can't be repaired and really shouldn't take component damage.
/mob/living/silicon/robot/drone/take_overall_damage(var/brute = 0, var/burn = 0, var/sharp = 0, var/used_weapon = null)
	bruteloss += brute
	fireloss += burn

/mob/living/silicon/robot/drone/heal_overall_damage(var/brute, var/burn)

	bruteloss -= brute
	fireloss -= burn

	if(bruteloss<0) bruteloss = 0
	if(fireloss<0) fireloss = 0

/mob/living/silicon/robot/drone/take_organ_damage(var/brute = 0, var/burn = 0, var/sharp = 0)
	take_overall_damage(brute,burn)

/mob/living/silicon/robot/drone/heal_organ_damage(var/brute, var/burn)
	heal_overall_damage(brute,burn)

/mob/living/silicon/robot/drone/getFireLoss()
	return fireloss

/mob/living/silicon/robot/drone/getBruteLoss()
	return bruteloss