/datum/mutiny_fluff
	var/datum/game_mode/mutiny/mode

	New(datum/game_mode/mutiny/M)
		mode = M

	proc/announce_directives()
		for (var/obj/machinery/faxmachine/fax in world)
			if (fax.department == "Captain's Office")
				var/obj/item/weapon/paper/directive_x = new(fax.loc)
				directive_x.name = "emergency action message"
				directive_x.info = get_fax_body()

	proc/get_fax_body()
		return {"
			<center><h5>NOT A DRILL . . . EMERGENCY DIRECTIVE . . . NOT A DRILL</h5></center>
			<p>
				<b>TO:</b> Captain [mode.head_loyalist], Commanding Officer, [station_name()]<br>
				<b>FROM:</b> NanoTrasen Emergency Messaging Relay<br>
				<b>DATE:</b> [time2text(world.realtime, "MM/DD")]/[game_year]<br>
				<b>SUBJECT:</b> Directive X<br>
			</p>

			[mode.current_directive.get_description()]

			<hr>
			<h5><b>Emergency Authentication Protocol</b></h5>
			<p>
				A member of your Command Staff is this shift's designated Emergency Secondary Authenticator.<br>
				This Emergency Secondary Authenticator is uniquely aware of their role and possesses the Emergency Secondary Authentication Key.<br>
				As Captain, you possess the Captain's Authentication Key.<br>
				The Emergency Authentication Device is located in the vault of your station, and requires simultaneous activation of the Authentication Keys.<br>
				An <b>Authentication Key Pinpointer</b> can be delivered via Cargo Bay to assist recovery of the Authentication Keys should they be lost aboard the station.<br>
				A key's destruction or removal from the station's perimeter will automatically and irreversibly activate the Emergency Authentication Device.
			</p>
			<br>

			<h5><b>Orders</b></h5>
			<p>
				Captain [mode.head_loyalist], you are to immediately initiate the following procedure; codenamed Directive X:
			</p>
			<ol>
				[get_orders()]
			</ol>
			<br>

			<h5><b>Authentication</b></h5>

			<b>Encoded Authentication String:</b> <small>T0JCJUwoIVFDQA==</small><br>
			<b>Emergency Action Code:</b> O B B _ L _ _ Q C _<br>
			<font color='red'><u>ERROR: DECODING INCOMPLETE (40% LOSS)</u></font>
			<br>
			<br>
			<br>

			<center><h5>NOT A DRILL . . . EMERGENCY DIRECTIVE . . . NOT A DRILL</h5></center>
		"}

	proc/get_orders()
		var/text = "<li>Immediate external transmission and signals silence. Evacuation and Cargo services will remain available. All ERT teams are engaged elsewhere. Do not communicate with Central Command under any circumstances.</li>"
		for(var/order in mode.current_directive.special_orders)
			text += "<li>[order]</li>"

		text += "<li>Upon completion of this Directive, Captain [mode.head_loyalist] and the Emergency Secondary Authenticator must utilise the Captain's Authentication Key and the Emergency Secondary Authentication Key to activate the Emergency Authentication Device.</li>"
		return text

	proc/get_pda_body()
		return {"<b>&larr; From Anonymous Channel:</b> <p>\"You must read this! NanoTrasen Chain of Command COMPROMISED. Command Encryptions BROKEN. [station_name()] Captain [mode.head_loyalist] will receive orders that must NOT BE BROUGHT TO FRUITION!

They don't care about us they only care about WEALTH and POWER... Share this message with people you trust.

Be safe, friend.\" (Unable to Reply)</p>"}

	proc/announce()
		world << "<B>The current game mode is - Mutiny!</B>"
		world << {"
<p>The crew will be divided by their sense of ethics when a morally turbulent emergency directive arrives with an incomplete command validation code.<br><br>
The [loyalist_tag("Head Loyalist")] is the Captain, who carries the [loyalist_tag("Captain's Authentication Key")] at all times.<br>
The [mutineer_tag("Head Mutineer")] is a random Head of Staff who carries the [mutineer_tag("Emergency Secondary Authentication Key")].</p>
Both keys are required to activate the <b>Emergency Authentication Device (EAD)</b> in the vault, signalling to NanoTrasen that the directive is complete.
<hr>
<p>
<b>Loyalists</b> - Follow the Head Loyalist in carrying out [loyalist_tag("NanoTrasen's directives")] then activate the <b>EAD</b>.<br>
<b>Mutineers</b> - Prevent the completion of the [mutineer_tag("improperly validated directives")] and the activation of the <b>EAD</b>.
</p>
		"}

	proc/loyalist_tag(text)
		return "<font color='blue'><b>[text]</b></font>"

	proc/mutineer_tag(text)
		return "<font color='#FFA500'><b>[text]</b></font>"

	proc/their(datum/mind/head)
		if (head.current.gender == MALE)
			return "his"
		else if (head.current.gender == FEMALE)
			return "her"

		return "their"

	proc/loyalist_major_victory()
		return {"
NanoTrasen has praised the efforts of Captain [mode.head_loyalist] and loyal members of [their(mode.head_loyalist)] crew, who recently managed to put down a mutiny--amid a local interstellar crisis--aboard the <b>[station_name()]</b>, a research station in [system_name()].
The mutiny was spurred by a top secret directive sent to the station, presumably in response to the crisis within the system.
Despite the mutiny, the crew was successful in implementing the directive and activating their on-board emergency authentication device.
[mode.mutineers.len] members of the station's personnel were charged with terrorist action against the Company and, if found guilty by a Sol magistrate, will be sentenced to life incarceration.
NanoTrasen will be awarding [mode.loyalists.len] members of the crew with the [loyalist_tag("Star of Loyalty")], following their successful efforts, at a ceremony this coming Thursday.
[mode.body_count.len] are believed to have died during the coup.
<p>NanoTrasen's image will forever be haunted by the fact that a mutiny took place on one of its own stations.</p>
		"}

	proc/loyalist_minor_victory()
		return {"
NanoTrasen has praised the efforts of Captain [mode.head_loyalist] and loyal members of [their(mode.head_loyalist)] crew, who recently managed to put down a mutiny--amid a local interstellar crisis--aboard the <b>[station_name()]</b>, a research station in [system_name()].
The mutiny was spurred by a top secret directive sent to the station, presumably in response to the crisis within the system.
Despite the mutiny, the crew was successful in implementing the directive. Unfortunately, they failed to notify Central Command of their successes due to a breach in the chain of command.
[mode.mutineers.len] members of the station's personnel were charged with terrorist action against the Company and, if found guilty by a Sol magistrate, will be sentenced to life incarceration.
NanoTrasen will be awarding [mode.loyalists.len] members of the crew with the [loyalist_tag("Star of Loyalty")], following their mostly successful efforts, at a ceremony this coming Thursday.
[mode.body_count.len] are believed to have died during the coup.
<p>NanoTrasen's image will forever be haunted by the fact that a mutiny took place on one of its own stations.</p>
		"}

	proc/no_victory()
		return {"
NanoTrasen has been thrust into turmoil following an apparent mutiny by key personnel aboard the <b>[station_name()]</b>, a research station in [system_name()].
The mutiny was spurred by a top secret directive sent to the station, presumably in response to the crisis within the system.
No further information has yet emerged from the station or its crew, who are presumed to be in holding with NanoTrasen investigators.
NanoTrasen officials refuse to comment.
Sources indicate that [mode.mutineers.len] members of the station's personnel are currently under investigation for terrorist activity, and [mode.loyalists.len] crew are currently providing evidence to investigators, believed to be the 'loyal' station personnel.
[mode.body_count.len] are believed to have died during the coup.
<p>NanoTrasen's image will forever be haunted by the fact that a mutiny took place on one of its own stations.</p>
		"}

	proc/mutineer_minor_victory()
		return {"
Reports have emerged that an impromptu mutiny has taken place, amid a local interstellar crisis, aboard the <b>[station_name()]</b>, a research station in [system_name()].
The mutiny was spurred by a top secret directive sent to the station, presumably in response to the crisis within the system.
Information at present indicates that the top-secret directive--which has since been retracted--was invalid due to a broken authentication code. Members of the crew, including an unidentified Head of Staff, prevented the directive from being accomplished.
[mode.mutineers.len] members of the station's personnel were released from interrogations today, following a mutiny investigation.
NanoTrasen has reprimanded [mode.loyalists.len] members of the crew for failing to follow command validation procedures.
[mode.body_count.len] are believed to have died during the coup.
<p>Even though the directive was not successfully implemented, NanoTrasen's image will forever be haunted by the fact that its authentication protocol was breached with such magnitude and that a mutiny was the result.</p>
		"}

	proc/mutineer_major_victory()
		return {"
NanoTrasen has praised the efforts of [mode.head_mutineer.assigned_role] [mode.head_mutineer] and several other members of the crew, who recently seized control of a company station in [system_name()]--<b>[station_name()]</b>--amid a local interstellar crisis.
What appears to have been a "legitimate" mutiny was spurred by a top secret directive sent to the station, presumably in response to the crisis within the system.
It has been revealed that the directive was invalid and fraudulent. Company officials have not released a statement about the source of the directive.
Thanks to the efforts of the resistant members of the crew, the directive was not carried out.
[mode.mutineers.len] members of the station's personnel were congratulated and awarded with the [mutineer_tag("Star of Bravery")], for their efforts in preventing the illegal directive's completion.
NanoTrasen has [mode.loyalists.len] members of the crew in holding, while it investigates the circumstances that led to the acceptance and initiation of an invalid directive.
[mode.body_count.len] are believed to have died during the coup.
<p>Even though the directive was not successfully implemented, NanoTrasen's image will forever be haunted by the fact that its authentication protocol was breached with such magnitude and that a mutiny was the result.</p>
		"}

	proc/secret_transcript()
		return {"
<center><h3>Corporate Rival Threat Assessment</h3></center>
<center><b>Gilthari Exports Incident Transcript</b></center>
<center><font color='red'>CONFIDENTIAL: PROPERTY OF NANOTRASEN</font></center>
<i>Location:</i> Operator's Desk, D Deck, Polumetis Installation<br>
<i>Time:</i> 16:11, May 24, 2558 (Sol Reckoning)<br>
<br>
<br>

<center>\[Start of transcript\]</center>
<center>\[Sound of an internal airlock door opening\]</center>
TM: Thank you for coming to see me, Director. I'm afraid this is urgent.<br>
D: Mr. Mitchell, first you send cryptic messages to my office and then you request to have me come personally to this barely lit closet you call a workstation; all of this to talk about a computer glitch?<br>
<center>\[Sound of the internal airlock door shutting\]</center>
TM: Do you remember <b>Mallory</b>?<br>
D: Who?<br>
TM: It's not who, it's what. The computer program we planted in the [system_name()] communications satellite.<br>
D: What is so important about this computer program?<br>
TM: We call her an eavesdropper. Captures network traffic, records it, and forwards the stream to the receiver autonomously.<br>
D: Speak English <i>goddamnit</i>.<br>
TM: Standard intelligence acquisition package, sir; we bug their satellite and listen. It's like we have their playbook and we know what their moves are going to be on the market before they make them.<br>
D: So Mallory doesn't work?<br>
TM: She worked, sir. We've had an ear on NanoTrasen's regional communications for weeks.<br>
D: Any news about their <b>Plasma refinement process</b>?<br>
TM: No sir. Our analysts believe they are using a separate channel for their most sensitive data.<br>
D: So what's the problem?<br>
TM: The intelligence hasn't been doing us any good. Anything that appears actionable, I send it to the analysts and they make a plan. Thing is, NanoTrasen always sees us coming.<br>
D: Tim...<br>
TM: I think they discovered the hack, sir. Case in point, <b>Energine Consolidated Solutions</b>. That subsidiary of ours that was awarded a lease on NanoTrasen's mining platform in Nyx? NanoTrasen acquired them a week before we made the announcement.<br>
D: They know about they have a bug. <i>They left her on and fed her the information for us to hear</i>, those sneaks. How did they find it?<br>
TM: Top secret communique came through. I'm not sure what happened. Either Mallory couldn't replicate the encryption scheme and garbled it going out or the transmission was already corrupted to begin with.<br>
D: Either way the transmission caused NanoTrasen to look at the satellite. They found out about Mallory.<br>
TM: Precisely sir. There's only so much I can do to cover our tracks from here.<br>
D: I'm pulling the plug. We have assets in the sector that are capable of a job like this. Thank you for bringing this to my attention.<br>
<center>\[Computer device chirps\]</center>
D: One last thing, did you happen to read anything from those secure transmissions?<br>
TM: Just the subject, 'Directive X'.<br>
D: Directive X... Now what do you suppose that means?<br>
<center>\[End of transcript\]</center>
		"}
