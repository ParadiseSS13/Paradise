/datum/surgery/core_removal
	name = "core removal"
	steps = list(/datum/surgery_step/slime/cut_flesh, /datum/surgery_step/slime/extract_core)
	allowed_mob = list(/mob/living/simple_animal/slime)
	possible_locs = list("chest", "head", "l_arm", "l_hand", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "groin")

/datum/surgery_step/slime

/datum/surgery_step/slime/is_valid_target(mob/living/simple_animal/slime/target)
	return istype(target, /mob/living/simple_animal/slime)

/datum/surgery_step/slime/can_use(mob/living/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	return istype(target) && target.stat == DEAD

/datum/surgery_step/slime/cut_flesh
	allowed_tools = list(/obj/item/scalpel = 100, /obj/item/melee/energy/sword = 75, /obj/item/kitchen/knife = 65, /obj/item/shard = 45)
	time = 16

/datum/surgery_step/slime/cut_flesh/begin_step(mob/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting through [target]'s flesh with \the [tool].", "You start cutting through [target]'s flesh with \the [tool].")

/datum/surgery_step/slime/cut_flesh/end_step(mob/living/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'> [user] cuts through [target]'s flesh with \the [tool].</span>",
	"<span class='notice'> You cut through [target]'s flesh with \the [tool], revealing its silky innards.</span>")
	return TRUE

/datum/surgery_step/slime/cut_flesh/fail_step(mob/living/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'> [user]'s hand slips, tearing [target]'s flesh with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, tearing [target]'s flesh with \the [tool]!</span>")
	return FALSE

/datum/surgery_step/slime/extract_core
	name = "extract core"
	allowed_tools = list(/obj/item/hemostat = 100, /obj/item/crowbar = 100)
	time = 16

/datum/surgery_step/slime/extract_core/begin_step(mob/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] begins to extract a core from [target].</span>",
						 "<span class='notice'>You begin to extract a core from [target]...</span>")

/datum/surgery_step/slime/extract_core/end_step(mob/user, mob/living/simple_animal/slime/slime, target_zone, obj/item/tool)
	if(slime.cores > 0)
		slime.cores--
		user.visible_message("<span class='notice'>[user] successfully extracts a core from [slime]!</span>",
			"<span class='notice'>You successfully extract a core from [slime]. [slime.cores] core\s remaining.</span>")

		new slime.coretype(slime.loc)

		if(slime.cores <= 0)
			slime.icon_state = "[slime.colour] baby slime dead-nocore"
			return TRUE
		else
			return FALSE
	else
		to_chat(user, "<span class='warning'>There aren't any cores left in [slime]!</span>")
		return TRUE

/datum/surgery_step/slime/extract_core/fail_step(mob/living/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'> [user]'s hand slips, tearing [target]'s flesh with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, tearing [target]'s flesh with \the [tool]!</span>")
	return FALSE