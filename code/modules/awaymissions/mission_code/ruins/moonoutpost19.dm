//papers for moonoutpost19.dmm

/obj/item/paper/fluff/ruins/moonoutpost19/entrance
	name = "hastily written note"
	info = "A warning to whose reading this, things here went really wrong. Way too damn wrong. Turn back while you can, there's nothing left for anyone. Not anymore."

/obj/item/paper/fluff/ruins/moonoutpost19/rockstarcop
	name = "eerie note"
	info = "(you see some unintelligible scribbles covered in dried blood, the only words you can recognize are...) <br><br>If everybody knew, I never knew <br>I will wake up in a new life<br> Down by the seaside..."

/obj/item/paper/fluff/ruins/moonoutpost19/engineering
	name = "emergency procedures"
	info = "(most of the parts are unreadable due to stains on the paper, the only words you can make out is...)<br><br> ...in case of power outages, use the provided portable generators. It is recommended setting up two of them at once rather than working with one generator on high power levels. It is also recommended using the pre-marked spots for generator setup. If you are uncertain where it is, use a t-ray scanner to check the floors. Provided plasma sheets will suffice until maintai..."

/obj/item/paper/fluff/ruins/moonoutpost19/truth
	name = "unsent note"
	info = "As you have ordered, i managed to insert the device in one of the containment shield generators and cut one or two wires feeding the emergency systems. Remote signal is clear and in range, waiting for next step... <br><br>This will cost many lives but whatever make you guys satisfied and lessens my debt."


// MARK: LORE CONSOLES

/obj/machinery/computer/loreconsole/moonoutpost19/lobby
	entries = list(
		new/datum/lore_console_entry(
			"Reminder to Joe",
			{"Hey Joe, since you keep forgetting here's the list of lockdown areas and the locations of control buttons. Thank me later.
### Lobby
- Research Division lockdown
- Medical Ward lockdown

### Cargo Bay
- Exterior hangar gate
- Cargo bay gates

### Senior Researcher's Office
- Specimen Containment Zone lockdown

Note: keep in mind, in case of power outages these buttons won't be functional.
In this case you'll find a few generators in engineering wing, set them up properly then report to technicians ASAP."}))

/obj/machinery/computer/loreconsole/moonoutpost19/rdnote
	entries = list(
		new/datum/lore_console_entry(
			"Entry #1",
			{"We're wasting our time and resources here with these unnecessary things. We have means to make an ACTUAL difference.

I have expressed these feelings with the Operations Officer, so tomorrow we'll be expecting a shipment of three alien specimen eggs.
They expect us to do something 'useful' with them, i don't expect we're going to do much with the resources on hand though.

Whatever, i've made it this far already, i'm climbing this ladder even further, then we can start making a real difference."}),
		new/datum/lore_console_entry(
			"Entry #2",
			{"I had a weird dream recently about something small catching me off-guard, from under my desk where they've hidden.
And now something in my mind whispers to me about 'tax norms', how it is implemented and various terms i have never heard before.

A note to self: don't push yourself too hard over small handicaps. It obviously makes you go insane, in a scary way too... And ask your therapist for extra session regarding to this matter."}))

/obj/machinery/computer/loreconsole/moonoutpost19/log1
	entries = list(
		new/datum/lore_console_entry(
			"Data Log #82",
			{"**Subject:** Yes
**Details:**
I fricking hate our so called 'Senior Researcher' Mr. Wood.
Someone has to show him how we handle the pricks whose nose in the air in this line of business.

Therefore I have developed a gas cannon. What this device does is simply compressing air and releasing it in a specific direction---in this case it would be the airlock
of this very chamber---at a funny velocity.

He checks the containment chambers daily, all i have to do is keep this beauty locked and loaded until he opens the airlock.
After all the only difference between messing around and science is writing it down.

I bet you won't be so senior about this."}))

/obj/machinery/computer/loreconsole/moonoutpost19/log2
	entries = list(
		new/datum/lore_console_entry(
			"Data Log #74",
			{"**Subject:** Bizarre Bread
**Details:**
So, a few weeks ago our custodian, Bob noticed loaf of breads appearing around the outpost.

At first we didn't believe him of course, there is no reasonable way to put this situation in this colorful existence...
until I got the honor to actually witnessing it. Someone or something was teleporting bread directly to this location.

Despite my best efforts to isolate the outpost from this specific bluespace frequency the results have met with failure.
This was silly and i couldn't be arsed so i told Bob to do his damn job.

A few days later something extraordinary happened, the object has shown the sign of a sort of decay process which resembles a mutation. An object was experiencing mutation as if it was a living organism!

Investigations are still in progress, we'll be keeping all specimens secured in this chamber."}))
