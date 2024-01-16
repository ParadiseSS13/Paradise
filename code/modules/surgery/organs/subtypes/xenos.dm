/obj/item/organ/internal/alien
	origin_tech = "biotech=5"
	icon_state = "xgibmid2"
	var/list/alien_powers = list()
	var/list/human_powers = list()
	tough = TRUE
	sterile = TRUE
	/// Amount of credits that will be received by selling this in the cargo shuttle
	var/cargo_profit = 100
	/// Has this organ been hijacked? Stores a ref of the hijacking item
	var/obj/hijacked

/// This adds and removes alien spells upon addition, if a noncarbon tries to do this well... I blame adminbus
/obj/item/organ/internal/alien/insert(mob/living/carbon/M, special = 0)
	..()
	if(!hijacked)
		for(var/powers_to_add in alien_powers)
			M.AddSpell(new powers_to_add)
	else
		for(var/powers_to_add in human_powers)
			M.AddSpell(new powers_to_add)

/obj/item/organ/internal/alien/remove(mob/living/carbon/M, special = 0)
	if(!hijacked)
		for(var/powers_to_remove in alien_powers)
			M.RemoveSpell(new powers_to_remove)
	else
		for(var/powers_to_add in human_powers)
			M.AddSpell(new powers_to_add)
	. = ..()

/obj/item/organ/internal/alien/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Can be sold on the cargo shuttle for [cargo_profit] credits.</span>"
	if(hijacked)
		. += "<span class='notice'>This organ is hijacked, use a wirecutter on it to remove the hijacking device.</span>"
	else
		. += "<span class='notice'>You can hijack the latent functions of this organ by using an Organ Hijacking Device on it.</span>"

/obj/item/organ/internal/alien/attackby(obj/item/organ_hijacker/hijacker, mob/user, params)
	if(istype(hijacker))
		to_chat(user, "<span class='notice'>You insert [hijacker] into [src]. This will override it's primary function and unlock latent abilities used to control the hivemind.</span>")
		hijacked = hijacker
		user.unEquip(hijacker, TRUE)
		hijacker.forceMove(src)
		return
	return ..()

/obj/item/organ/internal/alien/wirecutter_act(mob/living/user, obj/item/I)
	if(hijacked)
		hijacked.forceMove(get_turf(src))
		to_chat(user, "<span class='notice'>With an grisly squish, you remove [hijacked] from [src] reverting it to it's previous function.</span>")
		hijacked = null
		return TRUE

/obj/item/organ/internal/alien/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("sacid", 10)
	return S

/obj/item/organ/internal/alien/Destroy()
	QDEL_NULL(hijacked)
	return ..()

//XENOMORPH ORGANS

/obj/item/organ/internal/alien/plasmavessel
	name = "xeno plasma vessel"
	icon_state = "plasma"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "biotech=5;plasmatech=4"
	slot = "plasmavessel"
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/plant_weeds, /obj/effect/proc_holder/spell/alien_spell/transfer_plasma)
	human_powers = list(/obj/effect/proc_holder/spell/alien_spell/syphon_plasma)

	var/stored_plasma = 100
	var/max_plasma = 300
	var/heal_rate = 5
	var/plasma_rate = 10

/obj/item/organ/internal/alien/plasmavessel/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("plasma", stored_plasma / 10)
	return S

/obj/item/organ/internal/alien/plasmavessel/queen
	name = "bloated xeno plasma vessel"
	icon_state = "plasma_large"
	origin_tech = "biotech=6;plasmatech=4"
	stored_plasma = 200
	plasma_rate = 25

/obj/item/organ/internal/alien/plasmavessel/drone
	name = "large xeno plasma vessel"
	icon_state = "plasma_large"
	stored_plasma = 200

/obj/item/organ/internal/alien/plasmavessel/sentinel
	stored_plasma = 100
	max_plasma = 250

/obj/item/organ/internal/alien/plasmavessel/hunter
	name = "small xeno plasma vessel"
	icon_state = "plasma_tiny"
	stored_plasma = 50
	max_plasma = 100

/obj/item/organ/internal/alien/plasmavessel/larva
	name = "tiny xeno plasma vessel"
	icon_state = "plasma_tiny"
	stored_plasma = 25
	max_plasma = 50
	cargo_profit = 25

/obj/item/organ/internal/alien/plasmavessel/on_life()
	//If there are alien weeds on the ground then heal if needed or give some plasma
	if(locate(/obj/structure/alien/weeds) in owner.loc)
		if(owner.health >= owner.maxHealth)
			owner.add_plasma(plasma_rate)
		else
			var/heal_amt = heal_rate
			if(!isalien(owner))
				heal_amt *= 0.2
			owner.add_plasma((plasma_rate / 2))
			owner.adjustBruteLoss(-heal_amt)
			owner.adjustFireLoss(-heal_amt)
			owner.adjustOxyLoss(-heal_amt)
			owner.adjustCloneLoss(-heal_amt)

/obj/item/organ/internal/alien/plasmavessel/insert(mob/living/carbon/M, special = 0)
	..()
	M.update_plasma_display(M)

/obj/item/organ/internal/alien/plasmavessel/remove(mob/living/carbon/M, special = 0)
	. =..()
	M.update_plasma_display(M)

/obj/item/organ/internal/alien/acidgland
	name = "xeno acid gland"
	icon_state = "acid"
	slot = "acid"
	origin_tech = "biotech=5;materials=2;combat=2"
	alien_powers = list(/obj/effect/proc_holder/spell/touch/alien_spell/corrosive_acid)
	human_powers = list(/obj/effect/proc_holder/spell/touch/alien_spell/burning_touch)

/obj/item/organ/internal/alien/hivenode
	name = "xeno hive node"
	icon_state = "hivenode"
	slot = "hivenode"
	origin_tech = "biotech=5;magnets=4;bluespace=3"
	w_class = WEIGHT_CLASS_TINY
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/whisper)
	cargo_profit = 50

/obj/item/organ/internal/alien/hivenode/insert(mob/living/carbon/M, special = 0)
	..()
	M.faction |= "alien"
	M.add_language("Hivemind")
	M.add_language("Xenomorph")
	ADD_TRAIT(M, TRAIT_XENO_IMMUNE, "xeno immune")

/obj/item/organ/internal/alien/hivenode/remove(mob/living/carbon/M, special = 0)
	M.faction -= "alien"
	M.remove_language("Hivemind")
	M.remove_language("Xenomorph")
	REMOVE_TRAIT(M, TRAIT_XENO_IMMUNE, "xeno immune")
	. = ..()

/obj/item/organ/internal/alien/neurotoxin
	name = "xeno neurotoxin gland"
	icon_state = "neurotox"
	slot = "neurotox"
	origin_tech = "biotech=5;combat=5"
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/neurotoxin)
	human_powers = list(/obj/effect/proc_holder/spell/alien_spell/neurotoxin/death_to_xenos)

/obj/item/organ/internal/alien/resinspinner
	name = "xeno resin organ"
	icon_state = "liver-x"
	slot = "spinner"
	origin_tech = "biotech=5;materials=4"
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/build_resin)
	human_powers = list(/obj/effect/proc_holder/spell/touch/alien_spell/consume_resin)

/obj/item/organ/internal/alien/eggsac
	name = "xeno egg sac"
	icon_state = "eggsac"
	slot = "eggsac"
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "biotech=6"
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/plant_weeds/eggs)
	human_powers = list(/obj/effect/proc_holder/spell/alien_spell/combust_facehuggers)
	cargo_profit = 600

/obj/item/organ_hijacker
	name = "Organ Hijacking Device"
	desc = "A device used for hijacking alien organs."
	origin_tech = "biotech=3"
	w_class = WEIGHT_CLASS_TINY
	icon_state = "e_snare0"
