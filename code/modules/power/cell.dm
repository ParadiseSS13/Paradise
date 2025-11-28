/obj/item/stock_parts/cell
	name = "power cell"
	desc = "A rechargeable electrochemical power cell. This one is cheap and doesn't have very good capacity as a result."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	origin_tech = "powerstorage=1"
	force = 5
	throwforce = 5
	throw_range = 5
	/// Battery's current state of charge (kilojoules)
	var/charge = 0
	/// Battery's maximum state of charge (kilojoules)
	var/maxcharge = 2500
	/// How much energy the cell starts with (kilojoules)
	var/starting_charge
	materials = list(MAT_METAL = 700, MAT_GLASS = 50)
	///If the battery will explode
	var/rigged = FALSE
	/// How much energy is given to a recharging cell every tick (kilojoules / tick)
	var/chargerate = 100
	///Whether it will recharge automatically
	var/self_recharge = FALSE
	///Whether the description will include the maxcharge
	var/ratingdesc = TRUE
	///Additional overlay to signify battery being organic
	var/grown_battery = FALSE

/obj/item/stock_parts/cell/get_cell()
	return src

/obj/item/stock_parts/cell/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	charge = !isnull(starting_charge) ? starting_charge : maxcharge
	if(ratingdesc)
		// State of charge is in kJ so we multiply it by 1000 to get Joules
		desc += "<span class='notice'>It can store [DisplayJoules(maxcharge * 1000)]. Doctors recommend that you do not swallow it.</span>"
	update_icon(UPDATE_OVERLAYS)

/obj/item/stock_parts/cell/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/stock_parts/cell/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("self_recharge")
			if(var_value)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/stock_parts/cell/process()
	if(self_recharge)
		give(chargerate * 0.25)
	else
		return PROCESS_KILL

/obj/item/stock_parts/cell/update_overlays()
	. = ..()
	if(grown_battery)
		. += image('icons/obj/power.dmi', "grown_wires")
	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		. += "cell-o2"
	else
		. += "cell-o1"

/obj/item/stock_parts/cell/proc/percent()		// return % charge of cell
	return 100 * charge / maxcharge

// use power from a cell
/obj/item/stock_parts/cell/use(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(charge < amount)
		return 0
	charge = (charge - amount)
	return 1

// recharge the cell
/obj/item/stock_parts/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(maxcharge < amount)
		amount = maxcharge
	var/power_used = min(maxcharge - charge, amount)
	charge += power_used
	return power_used

/obj/item/stock_parts/cell/examine(mob/user)
	. = ..()
	if(rigged)
		. += "<span class='danger'>This power cell seems to be faulty!</span>"
	else
		. += "<span class='notice'>The charge meter reads [round(percent())]%.</span>"

/obj/item/stock_parts/cell/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='suicide'>[user] is licking the electrodes of [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return FIRELOSS

/obj/item/stock_parts/cell/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = W

		if(S.reagents.has_reagent("plasma", 5) || S.reagents.has_reagent("plasma_dust", 5))
			to_chat(user, "You inject the solution into the power cell.")
			rigged = TRUE

			log_admin("LOG: [key_name(user)] injected a power cell with plasma, rigging it to explode.")
			message_admins("LOG: [key_name_admin(user)] injected a power cell with plasma, rigging it to explode.")
		S.reagents.clear_reagents()
	else
		return ..()


/obj/item/stock_parts/cell/proc/explode()
	var/turf/T = get_turf(loc)
	if(charge == 0)
		return

	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = round(sqrt(charge) / 60)
	var/light_impact_range = round(sqrt(charge) / 30)
	var/flash_range = light_impact_range
	if(light_impact_range == 0)
		rigged = FALSE
		corrupt()
		return
	//explosion(T, 0, 1, 2, 2)
	log_admin("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")
	message_admins("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")

	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range, cause = "Powercell explosion")
	charge = 0 //Extra safety in the event the cell does not QDEL right
	qdel(src)

/obj/item/stock_parts/cell/proc/corrupt()
	charge /= 2
	maxcharge = max(maxcharge / 2, chargerate)
	if(prob(10))
		rigged = TRUE //broken batterys are dangerous

/obj/item/stock_parts/cell/emp_act(severity)
	charge -= 1000 / severity
	if(charge < 0)
		charge = 0
	..()

/obj/item/stock_parts/cell/ex_act(severity)
	..()
	if(!QDELETED(src))
		switch(severity)
			if(2)
				if(prob(50))
					corrupt()
			if(3)
				if(prob(25))
					corrupt()

/obj/item/stock_parts/cell/blob_act(obj/structure/blob/B)
	ex_act(EXPLODE_DEVASTATE)

/obj/item/stock_parts/cell/proc/get_electrocute_damage()
	if(charge >= 1000)
		return clamp(20 + round(charge / 25000), 20, 195) + rand(-5, 5)
	else
		return 0

// MARK: Cell variants
/obj/item/stock_parts/cell/empty
	starting_charge = 0

/obj/item/stock_parts/cell/high
	name = "high-capacity power cell"
	desc = "A rechargeable electrochemical power cell. This one is a premium design with a good charge capacity."
	origin_tech = "powerstorage=2"
	icon_state = "hcell"
	maxcharge = 10000
	materials = list(MAT_GLASS = 60)
	rating = 3
	chargerate = 1500

/obj/item/stock_parts/cell/high/plus
	name = "high-capacity power cell+"
	desc = "A rechargeable electrochemical power cell. Where the hell did this one come from...?"
	icon_state = "h+cell"
	maxcharge = 15000
	chargerate = 2250

/obj/item/stock_parts/cell/high/empty
	starting_charge = 0

/obj/item/stock_parts/cell/super
	name = "super-capacity power cell"
	desc = "A rechargeable electrochemical power cell. \
	This one utilizes some experimental tweaks to the cell chemistry to achieve a better charge capacity than any cell currently available on the market."
	origin_tech = "powerstorage=3;materials=3"
	icon_state = "scell"
	maxcharge = 20000
	materials = list(MAT_GLASS = 300)
	rating = 4
	chargerate = 2000

/obj/item/stock_parts/cell/super/empty
	starting_charge = 0

/obj/item/stock_parts/cell/hyper
	name = "hyper-capacity power cell"
	desc = "A rechargeable electrochemical power cell. \
	A highly experimental and expensive exotic cell chemistry combined with tweaks to the electrolyte to allow \
	for even more tightly packed anodes and cathodes, giving this cell an incredible charge capacity."
	origin_tech = "powerstorage=4;engineering=4;materials=4"
	icon_state = "hpcell"
	inhand_icon_state = "scell"
	maxcharge = 30000
	materials = list(MAT_GLASS = 400)
	rating = 5
	chargerate = 3000

/obj/item/stock_parts/cell/hyper/empty
	starting_charge = 0

/obj/item/stock_parts/cell/bluespace
	name = "bluespace power cell"
	desc = "A rechargeable electrochemical power cell. At the very forefront of power storage technology, there are few gains to be found from optimizing the cell's chemistry. \
	So the designers of this cell tried something much more conceptually simple: They took a super-capacity cell and made it twice as big. \
	They then exploited the transdimensional properties of bluespace to squeeze it down to a standard cell's form factor."
	origin_tech = "powerstorage=5;bluespace=4;materials=4;engineering=4"
	icon_state = "bscell"
	maxcharge = 40000
	materials = list(MAT_GLASS = 600)
	rating = 6
	chargerate = 4000

/obj/item/stock_parts/cell/bluespace/empty
	starting_charge = 0

/obj/item/stock_parts/cell/bluespace/charging
	name = "self-charging bluespace power cell"
	desc = "A modified bluespace power cell that draws energy directly from bluespace."
	origin_tech =  "powerstorage=10;bluespace=10"
	self_recharge = TRUE

/obj/item/stock_parts/cell/bluespace/trapped
	rigged = TRUE

/obj/item/stock_parts/cell/infinite
	name = "infinite-capacity power cell"
	desc = "A self-recarging power cell. It produces endless amounts of energy seemingly out of nowhere."
	icon_state = "icell"
	origin_tech =  "powerstorage=7"
	maxcharge = 30000
	materials = list(MAT_GLASS=1000)
	rating = 6
	chargerate = 30000
	self_recharge = TRUE

/obj/item/stock_parts/cell/infinite/use()
	return TRUE

/obj/item/stock_parts/cell/infinite/abductor
	name = "void core"
	desc = "An alien power cell of unknown design. It produces endless amounts of energy seemingly out of nowhere."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cell"
	inhand_icon_state = "acell"
	maxcharge = 50000
	rating = 12
	chargerate = 50000
	ratingdesc = FALSE

/obj/item/stock_parts/cell/infinite/abductor/update_overlays()
	return list()

/obj/item/stock_parts/cell/potato
	name = "potato battery"
	desc = "A rechargeable starch-based power cell. The charge capacity depends on the potency of the plant used to create it."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "potato"
	inhand_icon_state = "pcell"
	origin_tech = "powerstorage=1;biotech=1"
	charge = 100
	maxcharge = 300
	materials = list()
	grown_battery = TRUE //it has the overlays for wires

/obj/item/stock_parts/cell/high/slime
	name = "charged slime core"
	desc = "A yellow slime core infused with plasma, it crackles with power."
	origin_tech = "powerstorage=5;biotech=4"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "yellow slime extract"
	inhand_icon_state = "slcell"
	materials = list()
	rating = 5 //self-recharge makes these desirable
	self_recharge = TRUE // Infused slime cores self-recharge, over time
	chargerate = 500

// MARK: Internal Cells
// Special non-removable internal power cells inside stuff like guns. None of these should be obtainable.
/obj/item/stock_parts/cell/energy_gun
	name = "energy gun internal power cell"
	desc = "If you can see this, make an issue report to GitHub."
	maxcharge = 1000

/obj/item/stock_parts/cell/energy_gun/hos_gun
	name = "\improper X-01 multiphase energy gun internal power cell"
	maxcharge = 1200

/obj/item/stock_parts/cell/energy_gun/lever_action
	name = "lever action rifle internal power cell"
	maxcharge = 150

/obj/item/stock_parts/cell/energy_gun/lmg
	name = "cyborg LMG internal power cell"
	maxcharge = 600

/obj/item/stock_parts/cell/energy_gun/bsg
	name = "\improper B.S.G internal power cell"
	maxcharge = 40000
	chargerate = 2600 // about 30 seconds to charge with a default recharger

/// 200 pulse shots
/obj/item/stock_parts/cell/energy_gun/pulse
	name = "pulse rifle internal power cell"
	maxcharge = 40000
	chargerate = 1500

/// 25 pulse shots
/obj/item/stock_parts/cell/energy_gun/pulse/carbine
	name = "pulse carbine internal power cell"
	maxcharge = 5000

/// 10 pulse shots
/obj/item/stock_parts/cell/energy_gun/pulse/pistol
	name = "pulse pistol internal power cell"
	maxcharge = 2000

/obj/item/stock_parts/cell/emproof
	name = "\improper EMP-proof cell"
	desc = "An EMP-proof cell. If you can see this, make an issue report to GitHub."
	maxcharge = 500
	rating = 3

/obj/item/stock_parts/cell/emproof/empty
	starting_charge = 0

/obj/item/stock_parts/cell/emproof/emp_act(severity)
	return

/obj/item/stock_parts/cell/emproof/corrupt()
	return

/// EMP proof so emp_act does not double dip.
/obj/item/stock_parts/cell/emproof/reactive
	name = "reactive armor internal power cell"
	desc = "If you can see this, make an issue report to GitHub."
	maxcharge = 2400

/obj/item/stock_parts/cell/ninja
	name = "spider-clan power cell"
	desc = "A standard ninja-suit power cell."
	maxcharge = 10000

/obj/item/stock_parts/cell/flayerprod
	name = "mindflayer prod internal power cell"
	desc = "If you can see this, make an issue report to GitHub."
	maxcharge = 4000
	self_recharge = TRUE
	chargerate = 200 //This self charges it 50 power per tick at the base level
