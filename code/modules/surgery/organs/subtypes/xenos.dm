/obj/item/organ/internal/xenos
	origin_tech = "biotech=5"
	icon_state = "xgibmid2"
	var/list/alien_powers = list()
	tough = 1
	sterile = 1

///obj/item/organ/internal/xenos/New()
//	for(var/A in alien_powers)
//		if(ispath(A))
//			alien_powers -= A
//			alien_powers += new A(src)
//	..()

///can be changed if xenos get an update..
/obj/item/organ/internal/xenos/insert(mob/living/carbon/M, special = 0)
	..()
	for(var/P in alien_powers)
		M.verbs |= P
    	//M.verbs |= alien_powers.Copy()

/obj/item/organ/internal/xenos/remove(mob/living/carbon/M, special = 0)
	for(var/P in alien_powers)
		M.verbs -= P
		//M.verbs -= alien_powers.Copy()

	. = ..()

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

/obj/item/organ/internal/xenos/plasmavessel/insert(mob/living/carbon/M, special = 0)
	..()
	if(isalien(M))
		var/mob/living/carbon/alien/A = M
		A.updatePlasmaDisplay()

/obj/item/organ/internal/alien/plasmavessel/remove(mob/living/carbon/M, special = 0)
	. =..()
	if(isalien(M))
		var/mob/living/carbon/alien/A = M
		A.updatePlasmaDisplay()


/obj/item/organ/internal/xenos/acidgland
	name = "xeno acid gland"
	icon_state = "acid"
	parent_organ = "head"
	slot = "acid"
	origin_tech = "biotech=5;materials=2;combat=2"
	alien_powers = list(/mob/living/carbon/alien/humanoid/proc/corrosive_acid)


/obj/item/organ/internal/xenos/hivenode
	name = "xeno hive node"
	icon_state = "hivenode"
	parent_organ = "head"
	slot = "hivenode"
	origin_tech = "biotech=5;magnets=4;bluespace=3"
	w_class = 1
	alien_powers = list(/mob/living/carbon/alien/humanoid/verb/whisp)

/obj/item/organ/internal/xenos/hivenode/insert(mob/living/carbon/M, special = 0)
	..()
	M.faction |= "alien"
	M.add_language("Hivemind")
	M.add_language("Xenomorph")

/obj/item/organ/internal/xenos/hivenode/remove(mob/living/carbon/M, special = 0)
	M.faction -= "alien"
	M.remove_language("Hivemind")
	M.remove_language("Xenomorph")
	. = ..()

/obj/item/organ/internal/xenos/neurotoxin
	name = "xeno neurotoxin gland"
	icon_state = "neurotox"
	parent_organ = "head"
	slot = "neurotox"
	origin_tech = "biotech=5;combat=5"
	alien_powers = list(/mob/living/carbon/alien/humanoid/proc/neurotoxin)

/obj/item/organ/internal/xenos/resinspinner
	name = "xeno resin organ"//...there tiger....
	parent_organ = "mouth"
	icon_state = "liver-x"
	slot = "spinner"
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
