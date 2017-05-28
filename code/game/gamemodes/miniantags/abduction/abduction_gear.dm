#define VEST_STEALTH 1
#define VEST_COMBAT 2
#define GIZMO_SCAN 1
#define GIZMO_MARK 2

//AGENT VEST
/obj/item/clothing/suit/armor/abductor/vest
	name = "agent vest"
	desc = "A vest outfitted with advanced stealth technology. It has two modes - combat and stealth."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "vest_stealth"
	item_state = "armor"
	blood_overlay_type = "armor"
	origin_tech = "magnets=7;biotech=4;powerstorage=4;abductor=4"
	armor = list(melee = 15, bullet = 15, laser = 15, energy = 15, bomb = 15, bio = 15, rad = 15)
	actions_types = list(/datum/action/item_action/hands_free/activate)
	var/mode = VEST_STEALTH
	var/stealth_active = 0
	var/combat_cooldown = 10
	var/datum/icon_snapshot/disguise
	var/stealth_armor = list(melee = 15, bullet = 15, laser = 15, energy = 15, bomb = 15, bio = 15, rad = 15)
	var/combat_armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 50, rad = 50)
	species_fit = null
	sprite_sheets = null

/obj/item/clothing/suit/armor/abductor/vest/proc/flip_mode()
	switch(mode)
		if(VEST_STEALTH)
			mode = VEST_COMBAT
			DeactivateStealth()
			armor = combat_armor
			icon_state = "vest_combat"
		if(VEST_COMBAT)// TO STEALTH
			mode = VEST_STEALTH
			armor = stealth_armor
			icon_state = "vest_stealth"
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_wear_suit()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/armor/abductor/vest/item_action_slot_check(slot, mob/user)
	if(slot == slot_wear_suit) //we only give the mob the ability to activate the vest if he's actually wearing it.
		return 1

/obj/item/clothing/suit/armor/abductor/vest/proc/SetDisguise(datum/icon_snapshot/entry)
	disguise = entry

/obj/item/clothing/suit/armor/abductor/vest/proc/ActivateStealth()
	if(disguise == null)
		return
	stealth_active = 1
	if(ishuman(loc))
		var/mob/living/carbon/human/M = src.loc
		spawn(0)
			anim(M.loc,M,'icons/mob/mob.dmi',,"cloak",,M.dir)

		M.name_override = disguise.name
		M.icon = disguise.icon
		M.icon_state = disguise.icon_state
		M.overlays = disguise.overlays
		M.update_inv_r_hand()
		M.update_inv_l_hand()

/obj/item/clothing/suit/armor/abductor/vest/proc/DeactivateStealth()
	if(!stealth_active)
		return
	stealth_active = 0
	if(ishuman(loc))
		var/mob/living/carbon/human/M = src.loc
		spawn(0)
			anim(M.loc,M,'icons/mob/mob.dmi',,"uncloak",,M.dir)
		M.name_override = null
		M.overlays.Cut()
		M.regenerate_icons()

/obj/item/clothing/suit/armor/abductor/vest/hit_reaction()
	DeactivateStealth()
	return 0

/obj/item/clothing/suit/armor/abductor/vest/IsReflect()
	DeactivateStealth()
	return 0

/obj/item/clothing/suit/armor/abductor/vest/ui_action_click()
	switch(mode)
		if(VEST_COMBAT)
			Adrenaline()
		if(VEST_STEALTH)
			if(stealth_active)
				DeactivateStealth()
			else
				ActivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/proc/Adrenaline()
	if(ishuman(loc))
		if(combat_cooldown != initial(combat_cooldown))
			to_chat(src.loc, "<span class='warning'>Combat injection is still recharging.</span>")
			return
		var/mob/living/carbon/human/M = src.loc
		M.adjustStaminaLoss(-75)
		M.SetParalysis(0)
		M.SetStunned(0)
		M.SetWeakened(0)
		combat_cooldown = 0
		processing_objects.Add(src)

/obj/item/clothing/suit/armor/abductor/vest/process()
	combat_cooldown++
	if(combat_cooldown==initial(combat_cooldown))
		processing_objects.Remove(src)

/obj/item/device/abductor/proc/AbductorCheck(user)
	if(isabductor(user))
		return TRUE
	to_chat(user, "<span class='warning'>You can't figure how this works!</span>")
	return FALSE

/obj/item/device/abductor/proc/ScientistCheck(user)
	var/mob/living/carbon/human/H = user
	if(H.mind && H.mind.abductor)
		return H.mind.abductor.scientist

/obj/item/device/abductor/gizmo
	name = "science tool"
	desc = "A dual-mode tool for retrieving specimens and scanning appearances. Scanning can be done through cameras."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gizmo_scan"
	item_state = "gizmo"
	origin_tech = "engineering=7;magnets=4;bluespace=4;abductor=3"
	var/mode = GIZMO_SCAN
	var/mob/living/marked = null
	var/obj/machinery/abductor/console/console

/obj/item/device/abductor/gizmo/attack_self(mob/user)
	if(!AbductorCheck(user))
		return
	if(!ScientistCheck(user))
		to_chat(user, "<span class='warning'>You're not trained to use this!</span>")
		return
	if(mode == GIZMO_SCAN)
		mode = GIZMO_MARK
		icon_state = "gizmo_mark"
	else
		mode = GIZMO_SCAN
		icon_state = "gizmo_scan"
	to_chat(user, "<span class='notice'>You switch the device to [mode==GIZMO_SCAN? "SCAN": "MARK"] MODE</span>")

/obj/item/device/abductor/gizmo/attack(mob/living/M, mob/user)
	if(!AbductorCheck(user))
		return
	if(!ScientistCheck(user))
		to_chat(user, "<span class='notice'>You're not trained to use this</span>")
		return
	switch(mode)
		if(GIZMO_SCAN)
			scan(M, user)
		if(GIZMO_MARK)
			mark(M, user)


/obj/item/device/abductor/gizmo/afterattack(atom/target, mob/living/user, flag, params)
	if(flag)
		return
	if(!AbductorCheck(user))
		return
	if(!ScientistCheck(user))
		to_chat(user, "<span class='notice'>You're not trained to use this</span>")
		return
	switch(mode)
		if(GIZMO_SCAN)
			scan(target, user)
		if(GIZMO_MARK)
			mark(target, user)

/obj/item/device/abductor/gizmo/proc/scan(atom/target, mob/living/user)
	if(ishuman(target))
		if(console!=null)
			console.AddSnapshot(target)
			to_chat(user, "<span class='notice'>You scan [target] and add them to the database.</span>")

/obj/item/device/abductor/gizmo/proc/mark(atom/target, mob/living/user)
	if(marked == target)
		to_chat(user, "<span class='warning'>This specimen is already marked!</span>")
		return
	if(ishuman(target))
		if(isabductor(target))
			marked = target
			to_chat(user, "<span class='notice'>You mark [target] for future retrieval.</span>")
		else
			prepare(target,user)
	else
		prepare(target,user)

/obj/item/device/abductor/gizmo/proc/prepare(atom/target, mob/living/user)
	if(get_dist(target,user)>1)
		to_chat(user, "<span class='warning'>You need to be next to the specimen to prepare it for transport!</span>")
		return
	to_chat(user, "<span class='notice'>You begin preparing [target] for transport...</span>")
	if(do_after(user, 100, target = target))
		marked = target
		to_chat(user, "<span class='notice'>You finish preparing [target] for transport.</span>")


/obj/item/device/abductor/silencer
	name = "abductor silencer"
	desc = "A compact device used to shut down communications equipment."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "silencer"
	item_state = "silencer"
	origin_tech = "materials=4;programming=7;abductor=3"

/obj/item/device/abductor/silencer/attack(mob/living/M, mob/user)
	if(!AbductorCheck(user))
		return
	radio_off(M, user)

/obj/item/device/abductor/silencer/afterattack(atom/target, mob/living/user, flag, params)
	if(flag)
		return
	if(!AbductorCheck(user))
		return
	radio_off(target, user)

/obj/item/device/abductor/silencer/proc/radio_off(atom/target, mob/living/user)
	if(!(user in (viewers(7,target))))
		return

	var/turf/targloc = get_turf(target)

	var/mob/living/carbon/human/M
	for(M in view(2,targloc))
		if(M == user)
			continue
		to_chat(user, "<span class='notice'>You silence [M]'s radio devices.</span>")
		radio_off_mob(M)

/obj/item/device/abductor/silencer/proc/radio_off_mob(mob/living/carbon/human/M)
	var/list/all_items = M.GetAllContents()

	for(var/obj/I in all_items)
		if(istype(I,/obj/item/device/radio/))
			var/obj/item/device/radio/r = I
			r.listening = 0
			if(!istype(I,/obj/item/device/radio/headset))
				r.broadcasting = 0 //goddamned headset hacks

/obj/item/weapon/gun/energy/alien
	name = "alien pistol"
	desc = "A complicated gun that fires bursts of high-intensity radiation."
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	restricted_species = list("Abductor")
	icon_state = "alienpistol"
	item_state = "alienpistol"
	origin_tech = "combat=4;magnets=7;powerstorage=3;abductor=3"
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/weapon/paper/abductor
	name = "Dissection Guide"
	icon_state = "alienpaper_words"
	info = {"<b>Dissection for Dummies</b><br>

<br>
 1.Acquire fresh specimen.<br>
 2.Put the specimen on operating table.<br>
 3.Apply scalpel to the chest, preparing for experimental dissection.<br>
 4.Apply scalpel to specimen's torso.<br>
 5.Clamp bleeders on specimen's torso with a hemostat.<br>
 6.Retract skin of specimen's torso with a retractor.<br>
 7.Saw through the specimen's torso with a saw.<br>
 8.Apply retractor again to specimen's torso.<br>
 9.Search through the specimen's torso with your hands to remove any superfluous organs.<br>
 10.Insert replacement gland (Retrieve one from gland storage).<br>
 11.Cauterize the patient's torso with a cautery.<br>
 12.Consider dressing the specimen back to not disturb the habitat. <br>
 13.Put the specimen in the experiment machinery.<br>
 14.Choose one of the machine options. The target will be analyzed and teleported to the selected drop-off point.<br>
 15.You will receive one supply credit, and the subject will be counted towards your quota.<br>
<br>
Congratulations! You are now trained for invasive xenobiology research!"}

/obj/item/weapon/paper/abductor/update_icon()
	return

/obj/item/weapon/paper/abductor/AltClick()
	return

#define BATON_STUN 0
#define BATON_SLEEP 1
#define BATON_CUFF 2
#define BATON_PROBE 3
#define BATON_MODES 4

/obj/item/weapon/abductor_baton
	name = "advanced baton"
	desc = "A quad-mode baton used for incapacitation and restraining of specimens."
	var/mode = BATON_STUN
	icon = 'icons/obj/abductor.dmi'
	icon_state = "wonderprodStun"
	item_state = "wonderprod"
	slot_flags = SLOT_BELT
	origin_tech = "materials=4;combat=4;biotech=7;abductor=4"
	force = 7
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/toggle_mode)

/obj/item/weapon/abductor_baton/proc/toggle(mob/living/user=usr)
	mode = (mode+1)%BATON_MODES
	var/txt
	switch(mode)
		if(BATON_STUN)
			txt = "stunning"
		if(BATON_SLEEP)
			txt = "sleep inducement"
		if(BATON_CUFF)
			txt = "restraining"
		if(BATON_PROBE)
			txt = "probing"

	to_chat(usr, "<span class='notice'>You switch the baton to [txt] mode.</span>")
	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/weapon/abductor_baton/update_icon()
	switch(mode)
		if(BATON_STUN)
			icon_state = "wonderprodStun"
			item_state = "wonderprodStun"
		if(BATON_SLEEP)
			icon_state = "wonderprodSleep"
			item_state = "wonderprodSleep"
		if(BATON_CUFF)
			icon_state = "wonderprodCuff"
			item_state = "wonderprodCuff"
		if(BATON_PROBE)
			icon_state = "wonderprodProbe"
			item_state = "wonderprodProbe"

/obj/item/weapon/abductor_baton/attack(mob/target, mob/living/user)
	if(!isabductor(user))
		return

	if(isrobot(target))
		..()
		return

	if(!isliving(target))
		return

	var/mob/living/L = target

	user.do_attack_animation(L)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(0, "[user]'s [name]", src, MELEE_ATTACK))
			playsound(L, 'sound/weapons/Genhit.ogg', 50, 1)
			return 0

	switch(mode)
		if(BATON_STUN)
			StunAttack(L,user)
		if(BATON_SLEEP)
			SleepAttack(L,user)
		if(BATON_CUFF)
			CuffAttack(L,user)
		if(BATON_PROBE)
			ProbeAttack(L,user)

/obj/item/weapon/abductor_baton/attack_self(mob/living/user)
	toggle(user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()

/obj/item/weapon/abductor_baton/proc/StunAttack(mob/living/L,mob/living/user)
	user.lastattacked = L
	L.lastattacker = user

	L.Stun(7)
	L.Weaken(7)
	L.apply_effect(STUTTER, 7)

	L.visible_message("<span class='danger'>[user] has stunned [L] with [src]!</span>", \
							"<span class='userdanger'>[user] has stunned you with [src]!</span>")
	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(hit_appends)

	add_logs(user, L, "stunned")

/obj/item/weapon/abductor_baton/proc/SleepAttack(mob/living/L,mob/living/user)
	if(L.stunned || L.sleeping)
		L.visible_message("<span class='danger'>[user] has induced sleep in [L] with [src]!</span>", \
							"<span class='userdanger'>You suddenly feel very drowsy!</span>")
		playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		L.Sleeping(60)
		add_logs(user, L, "put to sleep")
	else
		L.AdjustDrowsy(1)
		to_chat(user, "<span class='warning'>Sleep inducement works fully only on stunned specimens! </span>")
		L.visible_message("<span class='danger'>[user] tried to induce sleep in [L] with [src]!</span>", \
							"<span class='userdanger'>You suddenly feel drowsy!</span>")

/obj/item/weapon/abductor_baton/proc/CuffAttack(mob/living/L,mob/living/user)
	if(!iscarbon(L))
		return
	var/mob/living/carbon/C = L
	if(!C.handcuffed)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
		C.visible_message("<span class='danger'>[user] begins restraining [C] with [src]!</span>", \
								"<span class='userdanger'>[user] begins shaping an energy field around your hands!</span>")
		if(do_mob(user, C, 30))
			if(!C.handcuffed)
				C.handcuffed = new /obj/item/weapon/restraints/handcuffs/energy/used(C)
				C.update_handcuffed()
				to_chat(user, "<span class='notice'>You handcuff [C].</span>")
				add_logs(user, C, "handcuffed")
		else
			to_chat(user, "<span class='warning'>You fail to handcuff [C].</span>")

/obj/item/weapon/abductor_baton/proc/ProbeAttack(mob/living/L,mob/living/user)
	L.visible_message("<span class='danger'>[user] probes [L] with [src]!</span>", \
						"<span class='userdanger'>[user] probes you!</span>")

	var/species = "<span class='warning'>Unknown species</span>"
	var/helptext = "<span class='warning'>Species unsuitable for experiments.</span>"

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		species = "<span clas=='notice'>[H.species.name]</span>"
		if(L.mind && L.mind.changeling)
			species = "<span class='warning'>Changeling lifeform</span>"
		var/obj/item/organ/internal/heart/gland/temp = locate() in H.internal_organs
		if(temp)
			helptext = "<span class='warning'>Experimental gland detected!</span>"
		else
			helptext = "<span class='notice'>Subject suitable for experiments.</span>"

	to_chat(user,"<span class='notice'>Probing result: </span>[species]")
	to_chat(user, "[helptext]")

/obj/item/weapon/restraints/handcuffs/energy
	name = "hard-light energy field"
	desc = "A hard-light field restraining the hands."
	icon_state = "cuff_white" // Needs sprite
	breakouttime = 450
	trashtype = /obj/item/weapon/restraints/handcuffs/energy/used
	origin_tech = "materials=4;magnets=5;abductor=2"

/obj/item/weapon/restraints/handcuffs/energy/used
	desc = "energy discharge"

/obj/item/weapon/restraints/handcuffs/energy/used/dropped(mob/user)
	user.visible_message("<span class='danger'>[user]'s [src] break in a discharge of energy!</span>", \
							"<span class='userdanger'>[user]'s [src] break in a discharge of energy!</span>")
	var/datum/effect/system/spark_spread/S = new
	S.set_up(4,0,user.loc)
	S.start()
	qdel(src)

/obj/item/weapon/abductor_baton/examine(mob/user)
	..()
	switch(mode)
		if(BATON_STUN)
			to_chat(user, "<span class='warning'>The baton is in stun mode.</span>")
		if(BATON_SLEEP)
			to_chat(user, "<span class='warning'>The baton is in sleep inducement mode.</span>")
		if(BATON_CUFF)
			to_chat(user, "<span class='warning'>The baton is in restraining mode.</span>")
		if(BATON_PROBE)
			to_chat(user, "<span class='warning'>The baton is in probing mode.</span>")


/obj/item/weapon/scalpel/alien
	name = "alien scalpel"
	desc = "It's a gleaming sharp knife made out of silvery-green metal."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/weapon/hemostat/alien
	name = "alien hemostat"
	desc = "You've never seen this before."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/weapon/retractor/alien
	name = "alien retractor"
	desc = "You're not sure if you want the veil pulled back."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/weapon/circular_saw/alien
	name = "alien saw"
	desc = "Do the aliens also lose this, and need to find an alien hatchet?"
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/weapon/surgicaldrill/alien
	name = "alien drill"
	desc = "Maybe alien surgeons have finally found a use for the drill."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/weapon/cautery/alien
	name = "alien cautery"
	desc = "Why would bloodless aliens have a tool to stop bleeding? Unless..."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/clothing/head/helmet/abductor
	name = "agent headgear"
	desc = "Abduct with style - spiky style. Prevents digital tracking."
	icon_state = "alienhelmet"
	item_state = "alienhelmet"
	blockTracking = 1
	origin_tech = "materials=7;magnets=4;abductor=3"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE

// Operating Table / Beds / Lockers

/obj/structure/stool/bed/abductor
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "bed"

/obj/structure/abductor_tableframe
	name = "alien table frame"
	desc = "A sturdy table frame made from alien alloy."
	icon_state = "alien_frame"
	density = 1

/obj/structure/abductor_tableframe/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
		playsound(src.loc, I.usesound, 50, 1)
		if(do_after(user, 30 * I.toolspeed, target = src))
			playsound(src.loc, I.usesound, 50, 1)
			new /obj/item/stack/sheet/mineral/abductor(get_turf(src))
			qdel(src)
			return
	if(istype(I, /obj/item/stack/sheet/mineral/abductor))
		var/obj/item/stack/sheet/P = I
		if(P.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one alien alloy sheet to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [P] to [src]...</span>")
		if(do_after(user, 50 * I.toolspeed, target = src))
			P.use(1)
			new /obj/structure/table/abductor(src.loc)
			qdel(src)
		return
	if(istype(I, /obj/item/stack/sheet/mineral/silver))
		var/obj/item/stack/sheet/P = I
		if(P.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one sheet of silver to do	this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [P] to [src]...</span>")
		if(do_after(user, 50, target = src))
			P.use(1)
			new /obj/machinery/optable/abductor(loc)
			qdel(src)

/obj/structure/table/abductor
	name = "alien table"
	desc = "Advanced flat surface technology at work!"
	icon = 'icons/obj/smooth_structures/alien_table.dmi'
	icon_state = "alien_table"
	canSmoothWith = null
	parts = /obj/item/stack/sheet/mineral/abductor

/obj/machinery/optable/abductor
	icon = 'icons/obj/abductor.dmi'
	icon_state = "bed"
	no_icon_updates = 1 //no icon updates for this; it's static.
	injected_reagents = list("corazone")

/obj/structure/closet/abductor
	name = "alien locker"
	desc = "Contains secrets of the universe."
	icon_state = "abductor"
	icon_closed = "abductor"
	icon_opened = "abductoropen"
	material_drop = /obj/item/stack/sheet/mineral/abductor
