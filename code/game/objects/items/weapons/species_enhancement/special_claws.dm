/obj/item/weapon/species_enhancement/claws
	name = "Claw Sharpener"
	desc = "An illegal genetic serum with nanobots designed to enhance the user's claws."
	species = list("Tajaran", "Unathi", "Vulpkanin", "Kidan", "Vox")

/obj/item/weapon/species_enhancement/claws/injected(var/mob/living/carbon/human/target)
	var/obj/item/organ/internal/cyberimp/chest/arm_mod/fancy_claws/claws_to_add = new /obj/item/organ/internal/cyberimp/chest/arm_mod/fancy_claws
	claws_to_add.insert(target)
	..()

/obj/item/organ/internal/cyberimp/chest/arm_mod/fancy_claws
	name = "Sharpened Claws"
	desc = "TODO, yell at a coder."
	icon_state = "chest_implant" //Currently lacks a better one.
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/internal/cyberimp/chest/arm_mod/fancy_claws/emp_act(severity)
	return //Can't EMP claws

/obj/item/organ/internal/cyberimp/chest/arm_mod/fancy_claws/New()
	..()
	var/obj/item/weapon/wirecutters/claws/implant = new /obj/item/weapon/wirecutters/claws
	holder = implant
	implant.holder = src

/obj/item/weapon/wirecutters/claws
	name = "Claws"
	desc = "Your claws, currently ready to cut something."
	edge = 0
	force = 18 //Same as e-daggers
	var/obj/item/organ/internal/cyberimp/chest/arm_mod/holder
	flags = ABSTRACT | NODROP
	hitsound = 'sound/weapons/slice.ogg'
	attack_verb = list("scratched", "clawed")
	gender = PLURAL

/obj/item/weapon/wirecutters/claws/attack_self(mob/user)
	var/obj/item/weapon/crowbar/claws/new_claws = new /obj/item/weapon/crowbar/claws
	to_chat(user, "<span class='notice'>You get ready to dig your claws in to pry something open.</span>")
	holder.holder = new_claws
	new_claws.holder = holder
	qdel(src)
	user.put_in_active_hand(new_claws)

/obj/item/weapon/wirecutters/claws/dropped()//if somebody manages to drop this somehow...
	..()
	loc = null//send it to nullspace to get retrieved by the implant later on. gotta cover those edge cases.

/obj/item/weapon/crowbar/claws
	name = "Claws"
	desc = "Your claws, currently ready to dig into something."
	sharp = 1
	force = 18 //Same as e-daggers
	var/obj/item/organ/internal/cyberimp/chest/arm_mod/holder
	flags = ABSTRACT | NODROP
	hitsound = 'sound/weapons/slice.ogg'
	attack_verb = list("scratched", "clawed")
	gender = PLURAL

/obj/item/weapon/crowbar/claws/attack_self(mob/user)
	var/obj/item/weapon/screwdriver/claws/new_claws = new /obj/item/weapon/screwdriver/claws
	to_chat(user, "<span class='notice'>You get ready to stick one of your claws into a slit to turn a screw.</span>")
	holder.holder = new_claws
	new_claws.holder = holder
	qdel(src)
	user.put_in_active_hand(new_claws)

/obj/item/weapon/crowbar/claws/dropped()
	..()
	loc = null

/obj/item/weapon/screwdriver/claws
	name = "Claws"
	desc = "Your claws, currently ready to be stuck into something."
	sharp = 1
	force = 18 //Same as e-daggers
	var/obj/item/organ/internal/cyberimp/chest/arm_mod/holder
	flags = ABSTRACT | NODROP
	hitsound = 'sound/weapons/slice.ogg'
	attack_verb = list("scratched", "clawed")
	gender = PLURAL

/obj/item/weapon/screwdriver/claws/attack_self(mob/user)
	var/obj/item/weapon/wirecutters/claws/new_claws = new /obj/item/weapon/wirecutters/claws
	to_chat(user, "<span class='notice'>You get ready to cut something with your claws.</span>")
	holder.holder = new_claws
	new_claws.holder = holder
	qdel(src)
	user.put_in_active_hand(new_claws)

/obj/item/weapon/screwdriver/claws/dropped()
	..()
	loc = null
