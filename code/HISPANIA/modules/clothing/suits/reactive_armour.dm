/obj/item/reactive_armour_shell
	name = "reactive armour shell"
	desc = "An experimental suit of armour, awaiting installation of an anomaly core."
	icon_state = "reactiveoff"
	icon = 'icons/obj/clothing/suits.dmi'
	w_class = WEIGHT_CLASS_BULKY

/obj/item/reactive_armour_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/static/list/anomaly_armour_types = list(
		/obj/effect/anomaly/grav					= /obj/item/clothing/suit/armor/reactive/repulse,
		/obj/effect/anomaly/flux					= /obj/item/clothing/suit/armor/reactive/tesla,
		/obj/effect/anomaly/bluespace				= /obj/item/clothing/suit/armor/reactive/teleport,
		/obj/effect/anomaly/pyro					= /obj/item/clothing/suit/armor/reactive/fire,
		/obj/effect/anomaly/bhole					= /obj/item/clothing/suit/armor/reactive/stealth
		)

	if(istype(I, /obj/item/assembly/signaler/anomaly))
		var/obj/item/assembly/signaler/anomaly/A = I
		var/armour_path = anomaly_armour_types[A.anomaly_type]
		if(!armour_path)
			armour_path = /obj/item/clothing/suit/armor/reactive/stealth //por si existe una anomalia aun no catalogada
		to_chat(user, "<span class='notice'>You insert [A] into the chest plate, and the armour gently hums to life.</span>")
		new armour_path(get_turf(src))
		qdel(src)
		qdel(A)

//Teleport RD
/obj/item/clothing/suit/armor/reactive/teleport/rd
	desc = "Someone seperated our Research Director from his own head!"
	icon = 'icons/hispania/obj/clothing/suits.dmi'

//Repulse
/obj/item/clothing/suit/armor/reactive/repulse
	name = "reactive repulse armor"
	desc = "An experimental suit of armor that violently throws back attackers."
	var/repulse_force = MOVE_FORCE_EXTREMELY_STRONG

/obj/item/clothing/suit/armor/reactive/repulse/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(prob(hit_reaction_chance))
		playsound(get_turf(owner),'sound/magic/repulse.ogg', 100, TRUE)
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], converting the attack into a wave of force!</span>")
		var/turf/T = get_turf(owner)
		var/list/thrown_items = list()
		for(var/atom/movable/A in range(T, 7))
			if(A == owner || A.anchored || thrown_items[A])
				continue
			var/throwtarget = get_edge_target_turf(T, get_dir(T, get_step_away(A, T)))
			A.throw_at(throwtarget, 10, 1, force)
			thrown_items[A] = A
		return TRUE
