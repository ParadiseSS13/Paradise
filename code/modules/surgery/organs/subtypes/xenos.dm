/obj/item/organ/internal/xenos
	origin_tech = "biotech=5"
	icon_state = "xgibmid2"
	var/list/alien_powers = list()

/obj/item/organ/internal/xenos/New()
	for(var/A in alien_powers)
		if(ispath(A))
			alien_powers -= A
			alien_powers += new A(src)
	..()

///can be changed if xenos get an update..
/obj/item/organ/internal/xenos/Insert(mob/living/carbon/M, special = 0)
	..()
	for(var/mob/living/carbon/alien/humanoid/verb/P in alien_powers)
		verbs += P

/obj/item/organ/internal/xenos/Remove(mob/living/carbon/M, special = 0)
	for(var/mob/living/carbon/alien/humanoid/verb/P in alien_powers)
		verbs -= P

	..()

/obj/item/organ/internal/xenos/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("sacid", 10)
	return S

//XENOMORPH ORGANS

/obj/item/organ/internal/xenos/plasmavessel
	name = "xeno plasma vessel"
	icon_state = "plasma"
	origin_tech = "biotech=5;plasmatech=2"
	w_class = 3
	parent_organ = "chest"
	slot = "plasmavessel"
	alien_powers = list(/mob/living/carbon/alien/humanoid/verb/plant, /mob/living/carbon/alien/humanoid/verb/transfer_plasma)


	var/stored_plasma = 0
	var/max_plasma = 500
	var/heal_rate = 5
	var/plasma_rate = 10

/obj/item/organ/internal/xenos/plasmavessel/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("plasma", stored_plasma/10)
	return S

/obj/item/organ/internal/xenos/plasmavessel/queen
	name = "bloated xeno plasma vessel"
	icon_state = "plasma_large"
	origin_tech = "biotech=6;plasma=3"
	stored_plasma = 200
	max_plasma = 500
	plasma_rate = 25

/obj/item/organ/internal/xenos/plasmavessel/drone
	name = "large xeno plasma vessel"
	icon_state = "plasma_large"
	stored_plasma = 200
	max_plasma = 500

/obj/item/organ/internal/xenos/plasmavessel/sentinel
	stored_plasma = 100
	max_plasma = 250

/obj/item/organ/internal/xenos/plasmavessel/hunter
	name = "small xeno plasma vessel"
	icon_state = "plasma_tiny"
	stored_plasma = 100
	max_plasma = 150
	alien_powers = list(/mob/living/carbon/alien/humanoid/verb/plant)

/obj/item/organ/internal/xenos/plasmavessel/larva
	name = "tiny xeno plasma vessel"
	icon_state = "plasma_tiny"
	max_plasma = 100


/obj/item/organ/internal/xenos/plasmavessel/on_life()
	//If there are alien weeds on the ground then heal if needed or give some plasma
	if(locate(/obj/structure/alien/weeds) in owner.loc)
		if(owner.health >= owner.maxHealth)
			owner.adjustPlasma(plasma_rate)
		else
			var/heal_amt = heal_rate
			if(!isalien(owner))
				heal_amt *= 0.2
			owner.adjustPlasma(plasma_rate*0.5)
			owner.adjustBruteLoss(-heal_amt)
			owner.adjustFireLoss(-heal_amt)
			owner.adjustOxyLoss(-heal_amt)
			owner.adjustCloneLoss(-heal_amt)

/obj/item/organ/internal/xenos/plasmavessel/Insert(mob/living/carbon/M, special = 0)
	..()
	if(isalien(M))
		var/mob/living/carbon/alien/A = M
		A.updatePlasmaDisplay()

/obj/item/organ/internal/alien/plasmavessel/Remove(mob/living/carbon/M, special = 0)
	..()
	if(isalien(M))
		var/mob/living/carbon/alien/A = M
		A.updatePlasmaDisplay()


/obj/item/organ/internal/xenos/acidgland
	name = "xeno acid gland"
	parent_organ = "head"
	slot = "acidgland"
	origin_tech = "biotech=5;materials=2;combat=2"
	alien_powers = list(/mob/living/carbon/alien/humanoid/proc/corrosive_acid)


/obj/item/organ/internal/xenos/hivenode
	name = "xeno hive node"
	parent_organ = "head"
	slot = "hivenode"
	origin_tech = "biotech=5;magnets=4;bluespace=3"
	w_class = 1
	alien_powers = list(/mob/living/carbon/alien/humanoid/verb/whisp)

/obj/item/organ/internal/xenos/hivenode/Insert(mob/living/carbon/M, special = 0)
	..()
	M.faction |= "alien"

/obj/item/organ/internal/xenos/hivenode/Remove(mob/living/carbon/M, special = 0)
	M.faction -= "alien"
	..()

/obj/item/organ/internal/xenos/neurotoxin
	name = "xeno neurotoxin gland"
	icon_state = "neurotox"
	parent_organ = "head"
	slot = "neurotoxingland"
	origin_tech = "biotech=5;combat=5"
	alien_powers = list(/mob/living/carbon/alien/humanoid/proc/neurotoxin)

/obj/item/organ/internal/xenos/resinspinner
	name = "xeno resin organ"//...there tiger....
	parent_organ = "head"
	icon_state = "stomach-x"
	slot = "resinspinner"
	origin_tech = "biotech=5;materials=4"
	alien_powers = list(/mob/living/carbon/alien/humanoid/proc/resin)

/obj/item/organ/internal/xenos/eggsac
	name = "xeno egg sac"
	icon_state = "eggsac"
	parent_organ = "groin"
	slot = "eggsac"
	w_class = 4
	origin_tech = "biotech=8"
	alien_powers = list(/mob/living/carbon/alien/humanoid/queen/verb/lay_egg)