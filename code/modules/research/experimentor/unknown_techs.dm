/////////////////////////MYSTERIOUS TECH DEFINITIONS//////////////////////////
// Strange Objects are replaced by Mysterious Tech, each of which serves
// as a "container" for the expanded relic selection. Each type of container
// has its own rarity and stat ranges which affect the "unboxed" product.
// tech can be "unboxed" by the experimentor, which can also be used to tweak
// the final stats of the object before unboxing.
//
// There are three "primary" stats for each piece of tech that are determined upon generation. Not all
// stats apply to all permutations of an object; high or low stats may not be relevant. If a triphasic
// scanning module is installed, exact stats are shown, otherwise stats are shown on a continuuum from
// very low (less than 20), low (21-40), average (41-60), high (61-80) and very high (80+).
//
// Stability - Determines failure rate of activated objects. Low stability may cause catastrophic failure on activation, destroying the object.
// Potency - How good the object is at doing what it does. Amplifies positive/negative effects.
// Innovation - How likely the object is to be a rarer and more powerful variety.
// Flexibility - The "currency" used to tweak the item's stats in the experimentor. An upgraded experimentor uses slightly less flexibility for each tweak.


/obj/item/unknown_tech
	name = "Unknown Tech"
	desc = "An unknown piece of technology. You get a strong feeling that this a glitch in the universe and shouldn't exist."
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	var/unpacked_name = "Unknown"
	var/stability
	var/potency
	var/innovation
	var/flexibility
	var/containedtype
	var/list/typelist = list("Device", "Device", "Device")
	var/list/iconlist = list("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
    // Determines how the base stat bell curve shakes out. Applies to each stat except flexibility, which is linearly distributed between a range.
    // A mean of 50 and a sd of 10 mean that most points will come out around 40-60 and will rarely go between 20-80.
	var/stability_standardeviation = 10
	var/stability_mean = 50
	var/potency_standardeviation = 10
	var/potency_mean = 50
	var/innovation_standardeviation = 10
	var/innovation_mean = 50
	var/flexibility_min = 20
	var/flexibility_max = 100
    // Innovation weight for each rarity tier. a weighting of 3 means each point of innovation adds 3% of the base chance for that tier to the tier's modified chance.
	var/uncommon_weighting = 2
	var/rare_weighting = 2
	var/vrare_weighting = 0.5
    // Base probability percentage for each rarity tier (common rarity is determined by the remainder out of 100%, 80% by default).
	var/uncommon_base = 14
	var/rare_base = 5
	var/vrare_base = 1

// Basically rolls 2d6 to approximate a normal distribution with a standard deviation of sigma and a mean of mu. Rounds to the nearest integer.
/obj/item/unknown_tech/proc/NormDistRand(var/sigma, var/mu)
    var/randroll = (rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100) + rand(0,100))
    return round(((randroll-600)*sigma)/100+mu,1)

/obj/item/unknown_tech/New()
	..()
	icon_state = pick(iconlist)
	containedtype = pick(typelist)
	stability = NormDistRand(stability_standardeviation, stability_mean)
	potency = NormDistRand(potency_standardeviation, potency_mean)
	innovation = NormDistRand(innovation_standardeviation, innovation_mean)
	flexibility = rand(flexibility_min, flexibility_max)

/obj/item/unknown_tech/proc/adjuststability(var/statchange)
	stability += statchange
	if (stability > 100)
		stability = 100
	if (stability < 0)
		stability = 0

/obj/item/unknown_tech/proc/adjustinnovation(var/statchange)
	innovation += statchange
	if (innovation > 100)
		innovation = 100
	if (innovation < 0)
		innovation = 0

/obj/item/unknown_tech/proc/adjustpotency(var/statchange)
	potency += statchange
	if (potency > 100)
		potency = 100
	if (potency < 0)
		potency = 0

/obj/item/unknown_tech/proc/adjustflexibility(var/statchange)
	flexibility += statchange
	if (flexibility > 100)
		flexibility = 100
	if (flexibility < 0)
		flexibility = 0

/obj/item/unknown_tech/proc/reroll()
	icon_state = pick(iconlist)
	containedtype = pick(typelist)
	stability = NormDistRand(stability_standardeviation, stability_mean)
	potency = NormDistRand(potency_standardeviation, potency_mean)
	innovation = NormDistRand(innovation_standardeviation, innovation_mean)

/obj/item/unknown_tech/proto_tech/
	name = "Prototype Technology"
	desc = "An unknown piece of technology stamped with the NanoTrasen logo. Clearly not production ready, it was probably left by a previous shift."
	unpacked_name = "Prototype"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"

/obj/item/unknown_tech/myst_tech/
	name = "Mysterious Technology"
	desc = "An unknown piece of technology stamped only with a strange barcode. The tooling is clearly different from in-house."
	unpacked_name = "Mysterious"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	rare_weighting = 4
	vrare_weighting = 2

/obj/item/unknown_tech/alien_tech/
	name = "Alien Technology"
	desc = "An unknown piece of technology stamped with lettering in no recognizable language. The make is unlike any you've ever seen."
	unpacked_name = "Alien"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	rare_weighting = 10
	vrare_weighting = 20