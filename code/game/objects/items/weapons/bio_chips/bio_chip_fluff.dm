
/**
 * # Bio-chip Fluff Datum
 *
 * Bio-chip fluff is just lore about the bio-chip that is accessed through the implantpad, you must attach
 * one of these datums to the implant_data var on a bio-chip for it to show it up.
 */
/datum/implant_fluff
	var/name = "Unknown bio-chip"
	var/life = "Not Specified."
	var/notes = "No Notes."
	var/function = "An electronic insert that supplements biological functions."

/datum/implant_fluff/abductor
	name = "GC$X9%D#G"
	life = "Unknown."
	notes = "Appears to contain highly advanced bluespace technology."

/datum/implant_fluff/adrenaline
	name = "Cybersun Industries RX-2 Adrenaline Bio-chip"
	life = "Five days."
	notes = "One of Cybersun Industries' oldest and simplest implants, it is rumoured to be among their best-selling products."
	function = "Subjects injected with this bio-chip can activate an injection of medical cocktails that removes stuns, increases speed, and has mild healing effects."

/datum/implant_fluff/basic_adrenalin
	name = "Cybersun Industries RX-1 Adrenaline Bio-chip"
	life = "Five days or after 1 use."
	notes = "A reduced-size version of Cybersun Industries' hugely popular RX-2 biochip, designed to offer the same robust jolt of energy for the budget-conscious consumer. Single use only."
	function = "Subjects injected with this bio-chip can activate an injection of medical cocktails that removes stuns, increases speed, and has mild healing effects."

/datum/implant_fluff/proto_adrenaline
	name = "Cybersun Industries FX-1 Proto-Adrenaline Bio-chip"
	life = "5 days, destroyed after 1 use."
	notes = "An ultra-minimalist version of Cybersun Industries' hugely popular RX-2 biochip, for those operating on a shoestring budget."
	function = "Injects a mixture of adrenaline, noradrenaline, and cortisol into the subject, giving them a very quick burst of energy that will clear all stunning effects and allow them to rise to their feet. The effect is extremely short lived and lacks any staying power."

/datum/implant_fluff/supercharge
	name = "Cybersun Industries RX-4 Synthetic Supercharge Bio-chip"
	life = "Known to last for up to a year."
	notes = "A complex bio-chip utilizing a multitude of synthetic chemicals invented by Cybersun Industries. It's rumored that synthetic rights groups maintain stockpiles of these."
	function = "Synthetic subjects injected with this bio-chip can activate an injection of lubricants, coolants, and positronic patching fluid."

/datum/implant_fluff/chem
	name = "Bishop Cybernetics Chemical Injection Bio-chip"
	life = "Deactivates upon death but remains within the body."
	notes = "Can be loaded with any sort of chemical agent via syringe and can hold 50 units. Can only be loaded while still in its original case."
	function = "Contains a small capsule that can contain various chemicals. Upon receiving a specially encoded signal the bio-chip releases the chemicals directly into the blood stream."

/datum/implant_fluff/death_alarm
	name = "Bishop Cybernetics Death Alarm Bio-chip"
	notes = "Alerts crew to crewmember death. Produced by Bishop Cybernetics in a collaboration with Zeng-Hu Pharmaceuticals."
	function = "Contains a compact radio signaler that triggers when the host's lifesigns cease."

/datum/implant_fluff/dust
	name = "Cybersun Industries Dust Bio-chip"
	life = "Unknown, attempts to retrieve a sample of the bio-chip have often led to the destruction of the bio-chip... and user."
	notes = "Activates upon death or from manual activation by the user."
	function = "Contains a compact, electrically activated heat source that turns its host to ash upon activation, or their death."

/datum/implant_fluff/emp
	name = "Cybersun Industries RX-22 Electromagnetic Pulse Emitter Bio-chip"
	life = "Destroyed upon final activation."
	notes = "An miniaturized nuclear squib fit snugly into a bio-chip."
	function = "Upon detonization the bio-chip will release an EMP affecting the immediate area around the user."

/datum/implant_fluff/explosive
	name = "Cybersun Industries RX-78 Employee Management Bio-chip"
	life = "Destroyed upon activation."
	notes = "Appears to contain a small, dense explosive device wired to a signaller chip. The serial number on the side is scratched out."
	function = "Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death."

/datum/implant_fluff/explosive_macro
	name = "Cybersun Industries RX-79 Employee Management Bio-chip"
	life = "Destroyed upon activation."
	notes = "Compared to its predecessor, the RX-79 contains a much larger explosive; sometimes you just need a bigger boom. Due to its bulkiness, it has been known to press into the user's frontal lobe, impairing judgement."
	function = "Contains a bulky, electrically triggered explosive that detonates upon receiving a specially encoded signal or upon host death."

/datum/implant_fluff/freedom
	name = "Cybersun Industries RX-92 Quick Escape Bio-chip"
	life = "Destroyed after 4 uses."
	notes = "A bio-chip that is illegal in many systems. It is notoriously known for allowing users to grotesquely fracture bones and over-exert joints in order to slip out of the tightest of restraints."
	function = "Uses a mixture of cybernetic nanobots, bone regrowth chemicals, and radio signals to quickly break the user out of restraints."

/datum/implant_fluff/protofreedom
	name = "Cybersun Industries X-92 Quick Escape Bio-chip"
	life = "Destroyed after 1 use."
	notes = "A bio-chip that is illegal in many systems. This is the early prototype version of the RX-92. It's significantly cheaper than its newer version."
	function = "Uses a mixture of cheap cybernetic nanobots, bone regrowth chemicals, and radio signals to quickly break the user out of restraints."

/datum/implant_fluff/krav_maga
	name = "Cybersun Industries Krav Maga Neurotrainer"
	life = "Will cease functioning 4 hours after death of host."
	notes = "As a consequence of using a neurotrainer, using this bio-chip will overwrite other martial arts knowledge in the user's brain."
	function = "Teaches even the clumsiest host the arts of Krav Maga."

/datum/implant_fluff/mindshield
	name = "Nanotrasen Type 3 Mindshield Bio-chip"
	life = "Studies have shown the bio-chip to last up to 10 years."
	notes = "This is the third iteration of a bio-chip that has garnered attention from many galactic humanoid rights groups over concerns of self autonomy. Allegedly, it used to force the user to be completely loyal to Nanotrasen."
	function = "Personnel injected with this device can better resist mental compulsions such as brainwashing and mindslaving."

/datum/implant_fluff/storage
	name = "Cybersun Industries RX-16 Collapsible Body Cavity Bio-chip"
	notes = "This bio-chip uses bluespace technology to store items inside the user's body."
	function = "Allows the user to store two small objects within a bluespace body cavity."

/datum/implant_fluff/tracking
	name = "Nanotrasen RFID Tracking Bio-chip"
	life = "Unknown, known to last up to a few years."
	notes = "Tracking bio-chips are Neuro-safe! Makes use of a specialized shell that will melt and disintegrate into bio-safe elements in the event of a malfunction. "
	function = "Continuously transmits a low power signal. Can be used for tracking and teleporting to the user."

/datum/implant_fluff/traitor
	name = "Syndicate Type E Mindslave Bio-chip"
	life = "Unknown, no collected sample has been active long enough to determine lifespan."
	notes = "Any humanoid injected with this bio-chip will become loyal to the injector, unless of course the host is already loyal to someone else. It's Diplomacy made easy. The Syndicate is known to use this for political and diplomatic leverage."
	function = " Contains a small pod of nanobots that manipulate the host's mental functions and slave the host to the implanter."

/datum/implant_fluff/uplink
	name = "Syndicate Agent Uplink Bio-chip"
	life = "Unknown, no collected sample has been active long enough to determine lifespan."
	notes = "An intricate piece of machinery that interfaces directly with the user's brain. The inner workings of this implant are a closely guarded Syndicate secret."
	function = "Allows the user to access a syndicate uplink connected contained within their body, invisible from the outside but provides the same functionality as a regular uplink."

/datum/implant_fluff/sad_trombone
	name = "Honk Ltd. Comedy Bio-chip"
	notes = "A bio-chip manufactured by Bishop Cybernetics that plays a sad trombone noise when the user dies."
	function = "Plays a sad trombone noise upon death of the implantee."

/datum/implant_fluff/pathfinder
	name = "Paizo Productions 5-E Pathfinder Implant"
	life = "Lasts 2-12 months. Known to fail at the worst possible time, space radiation may be a factor."
	notes = "By use of an internal private GPS signal, allows the pathfinder module to have the MODsuit find the user. Also wirelessly transfers ID information to the suit, to allow doors to open."
	function = "Allows for the recall of a Modular Outerwear Device by the implant owner at any time."

/datum/implant_fluff/gorilla_rampage
	name = "Magillitis Serum Bio-chip"
	life = "Unknown, no collected sample has been active long enough to determine lifespan."
	notes = "An experimental serum which causes rapid muscular growth in Hominidae. Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	function = "Allows the user to transform into an angry, fast, and robust gorilla. Very deadly in close quarters."

/datum/implant_fluff/stealth
	name = "Syndicate S3 \"Stealth\" Bio-chip"
	life = "Unknown. No collected sample has been active long enough to determine lifespan."
	notes = "Manually activated by the user."
	function = "A biochip housing a highly specialized cloaking nanoswarm. When activated, the nanoswarm will assemble into a box-like shape around the user and render them invisible. Solid impacts will temporarily disrupt the cloaking mechanism."

/datum/implant_fluff/shock
	name = "Syndicate ARC-7 \"Power\" Bio-chip"
	life = "5-12 months, depending on active use."
	notes = "Manually activated by the user."
	function = "An effective biochip designed to redirect large amounts of power in destructive arcs. Attempts to reduce the minimum power drain to allow for weapon and cell charging have failed so far."

/datum/implant_fluff/deathrattle
	name = "Bishop Cybernetics Death Rattle Bio-chip"
	life = "Destroyed upon activation."
	notes = "Alerts implanted crew to crewmember death. Produced by Bishop Cybernetics in collaboration with Zeng-Hu Pharmaceuticals."
	function = "Contains a compact radio signaller that triggers when the host's lifesigns cease. Does not announce location of death, and only announces to other crew with implanted Death Rattles."
