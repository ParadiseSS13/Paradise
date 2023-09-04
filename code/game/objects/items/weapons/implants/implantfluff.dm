
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
	notes = "One of Cybersun Industries oldest and simplest implants, even in its simplicity it is rumoured to be one of Cybersun Industries best-selling products."
	function = "Subjects injected with this bio-chip can activate an injection of medical cocktails that removes stuns, increases speed, and has mild healing effects."

/datum/implant_fluff/chem
	name = "BioTech Solutions MJ-420 Prisoner Management Bio-chip" //ah yes, MJ-420, old coders are FUNNY
	life = "Deactivates upon death but remains within the body."
	notes = "Can be loaded with any sort of chemical agent via the common syringe and can hold 50 units. Can only be loaded while still in its original case."
	function = "Contains a small capsule that can contain various chemicals. Upon receiving a specially encoded signal the bio-chip releases the chemicals directly into the blood stream."

/datum/implant_fluff/death_alarm
	name = "BioTech Solutions MJ-102 Death Alarm Bio-chip"
	notes = "Alerts crew to crewmember death."
	function = "Contains a compact radio signaler that triggers when the host's lifesigns cease."

/datum/implant_fluff/dust
	name = "Nanotrasen Employee Dust Bio-chip"
	life = "Unknown, attempts to retrieve a sample of the bio-chip have often led to the destruction of the bio-chip... and user."
	notes = "Activates upon death or from manual activation by the user."
	function = "Contains a compact, electrically activated heat source that turns its host to ash upon activation, or their death."

/datum/implant_fluff/emp
	name = "Cybersun Industries RX-22 Electromagnetic Pulse Emitter Bio-chip"
	life = "Destroyed upon final activation."
	notes = "An minituarized nuclear squib fit snuggly into a bio-chip."
	function = "Upon detonization the bio-chip will release an EMP affecting the immediate area around the user."

/datum/implant_fluff/exile
	name = "Nanotrasen Employee Exile Bio-chip"
	life = "Known to last up to 3 to 4 years."
	notes = "The onboard station gateway system has been modified to reject entry by individuals containing this bio-chip."
	function = "Prevents the user from reentering the station through the gateway.... alive."

/datum/implant_fluff/explosive
	name = "Cybersun Industries RX-78 Employee Management Bio-chip"
	life = "Destroyed upon activation."
	notes = "Appears to contain a small, dense explosive device wired to a signaller chip, the serial number on the side is scratched out."
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
	notes = "A bio-chip that is illegal in many systems. This is the early prototype version of the RX-92. It's significantly cheaper than it's newer version."
	function = "Uses a mixture of cheap cybernetic nanobots, bone regrowth chemicals, and radio signals to quickly break the user out of restraints."

/datum/implant_fluff/health
	name = "Nanotrasen Health Bio-chip"

/datum/implant_fluff/krav_maga
	name = "Prospero Foreign Industries Krav Maga Neurotrainer"
	life = "Will cease functioning 4 hours after death of host."
	notes = "As a consequence of using a neurotrainer, using this bio-chip will overwrite other martial arts knowledge in the users brain."
	function = "Teaches even the clumsiest host the arts of Krav Maga."

/datum/implant_fluff/mindshield
	name = "Nanotrasen Type 3 Mindshield Bio-chip"
	life = "Studies have shown the bio-chip to last up to 10 years."
	notes = "This is the third iteration of a bio-chip that has garnered attention from many galactic humanoid rights groups over concerns of self autonomy. Allegedly, it used to force the user to be completely loyal to Nanotrasen."
	function = "Personnel injected with this device can better resist mental compulsions such as brainwashing and mindslaving."

/datum/implant_fluff/storage
	name = "Cybersun Industries RX-16 Collapsible Body Cavity Bio-chip"
	notes = "Prolonged usage of this bio-chip often results in the users bones being fractured and occassionaly complete organ failure."
	function = "Allows the user to store two small objects within a cybernetic body cavity."

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
	notes = "An intricate piece of machinery that interfaces directly with the users brain and which inner workings are a closely guarded syndicate secret."
	function = "Allows the user to access a syndicate uplink connected contained within their body, invisible from the outside but provides the same functionality as a regular uplink."

/datum/implant_fluff/sad_trombone
	name = "BioTech Solutions Comedy Bio-chip"
	function = "Plays a sad trombone noise upon death of the implantee, allows clowns to entertain the crew even post-mortem."

/datum/implant_fluff/gorilla_rampage
	name = "Magillitis Serum Bio-chip"
	life = "Unknown, no collected sample has been active long enough to determine lifespan."
	notes = "An experimental serum which causes rapid muscular growth in Hominidae. Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	function = "Allows the user to transform into an angry fast and robust gorilla. Very deadly in close quarters."

/datum/implant_fluff/stealth
	name = "Syndicate S3 \"Stealth\" Bio-chip"
	life = "Unknown. No collected sample has been active long enough to determine lifespan."
	notes = "Manually activated by the user."
	function = "Allows the user to summon a box from a bluespace pocket located inside the implant. The exterior of this box is lined with experimental cloaking panels which render the box invisible to the naked eye."
