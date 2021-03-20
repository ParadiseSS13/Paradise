/obj/item/storage/box/syndie_kit/contractor
	name = "contractor kit"
	desc = "A box containing supplies destined to Syndicate contractors."
	// Settings
	/// Amount of random items to be added to the contractor kit.
	/// See [/obj/item/storage/box/syndie_kit/contractor/var/item_list] for the available items.
	var/num_additional_items = 3
	/// Items that may be part of the random items given to a contractor as part of their kit.
	/// Ideally all about 5 TC or less and fit the theme. Some of these are nukeops only.
	/// One item may show up only once.
	var/list/item_list = list(
		// Offensive
		/obj/item/gun/projectile/automatic/fullauto/twomode/c20r/toy,
		/obj/item/storage/box/syndie_kit/throwing_weapons,
		/obj/item/pen/edagger,
		/obj/item/gun/projectile/automatic/toy/pistol/riot,
		/obj/item/soap/syndie,
		/obj/item/storage/box/syndie_kit/dart_gun,
		/obj/item/gun/syringe/rapidsyringe,
		/obj/item/storage/backpack/duffel/syndie/x4,
		// Mixed
		/obj/item/storage/box/syndie_kit/emp,
		/obj/item/flashlight/emp,
		// Support
		/obj/item/storage/box/syndidonkpockets,
		/obj/item/storage/belt/military/traitor,
		/obj/item/clothing/shoes/chameleon/noslip,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/storage/backpack/duffel/syndie/surgery,
		/obj/item/multitool/ai_detect,
		/obj/item/encryptionkey/binary,
		/obj/item/jammer,
		/obj/item/implanter/freedom,
	)


/obj/item/storage/box/syndie_kit/contractor/New()
	..()
	new /obj/item/paper/contractor_guide(src)
	new /obj/item/contractor_uplink(src)
	new /obj/item/storage/box/syndie_kit/contractor_loadout(src)
	// Add the random items
	for(var/i in 1 to num_additional_items)
		var/obj/item/I = pick_n_take(item_list)
		new I(src)

/obj/item/storage/box/syndie_kit/contractor_loadout
	name = "contractor standard loadout box"
	desc = "A standard issue box included in a contractor kit."

/obj/item/storage/box/syndie_kit/contractor_loadout/New()
	..()
	new /obj/item/clothing/head/helmet/space/syndicate/contractor(src)
	new /obj/item/clothing/suit/space/syndicate/contractor(src)
	new /obj/item/melee/classic_baton/telescopic/contractor(src)
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/card/id/syndicate(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(src)
	new /obj/item/lighter/zippo(src)

/obj/item/paper/contractor_guide
	name = "contractor guide"

/obj/item/paper/contractor_guide/Initialize()
	info = {"<p>Welcome agent, congratulations on your new position as a Syndicate contractor. On top of your already assigned objectives,
			this kit will provide you contracts to take on for telecrystal payments.</p>
			<p>Provided within is your specialist contractor space suit. It's even more compact, being able to fit into a pocket, and faster than the
			Syndicate space suit available to you on your hidden uplink. We also provide you a chameleon jumpsuit and mask, both of which can be changed
			to any form you need for the moment. The cigarettes are a special blend - they will heal your injuries slowly over time.</p>
			<p>Three additional items have been randomly selected from what we had available and included in this kit. We hope they're useful to you for your mission.</p>
			<p>The Contractor Hub, available in your contractor uplink, can provide you unique items and abilities. These are bought using Contractor Rep,
			with two Rep being provided each time you complete a contract.</p>
			<h3>Using the Contractor Uplink</h3>
			<ol>
				<li>Take the contractor uplink from this kit and activate it.</li>
				<li>From there, you can accept a contract, and redeem your TC payments from completed contracts.</li>
				<li>The payment number shown in brackets is the bonus you'll receive when bringing your target <b>alive</b>. You receive the
				other number regardless of whether they were alive or not.</li>
				<li>Contracts are completed by bringing the target to the designated extraction zone, calling for extraction, and putting them
				inside the extraction portal.</li>
			</ol>
			<p>Be careful when accepting a contract. While you'll be able to see its extraction zone beforehand, cancelling will make it
			unavailable to take on again.</p>
			<h3>Extracting</h3>
			<ol>
				<li>Make sure both yourself and your target are at the extraction zone.</li>
				<li>Call the extraction, and stand back from the drop point.</li>
				<li>If it fails, make sure your target is inside, and there's a free space for the extraction portal to appear.</li>
				<li>Grab your target, and drag them into the extraction portal.</li>
			</ol>
			<h3>Ransoms</h3>
			<p>We need your target for our own reasons, but we ransom them back to your mission area once their use is served. They will return back
			from where you sent them off from in several minutes time. Don't worry, we give you a cut of what we get paid. We pay this into whatever
			ID card you have equipped, on top of the TC payment we give.</p>
			<p>Good luck agent. You can burn this document with the supplied lighter.</p>"}

	return ..()
