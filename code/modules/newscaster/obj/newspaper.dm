#define SCREEN_COVER 0
#define SCREEN_PAGE_INNER 1
#define SCREEN_PAGE_LAST 2

/**
  * # Newspaper
  *
  * A newspaper displaying the stories of all channels contained within.
  */
/obj/item/newspaper
	name = "newspaper"
	desc = "An issue of The Griffon, the newspaper circulating aboard Nanotrasen Space Stations."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	inhand_icon_state = "newspaper"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bapped")
	/// The current screen to display.
	var/screen = 0
	/// The number of pages.
	var/pages = 0
	/// The currently selected page.
	var/curr_page = 0
	/// The channels to display as content.
	var/list/datum/feed_channel/news_content
	/// The security notice to display optionally.
	var/datum/feed_message/important_message = null
	/// The contents of a scribble made through pen, if any.
	var/scribble = ""
	/// The page of said scribble.
	var/scribble_page = null
	/// Whether the newspaper is rolled or not, making it a deadly weapon.
	var/rolled = FALSE

/obj/item/newspaper/Initialize(mapload)
	. = ..()
	if(!news_content)
		news_content = list()

/obj/item/newspaper/attack_self__legacy__attackchain(mob/user)
	if(rolled)
		to_chat(user, "<span class='warning'>Unroll it first!</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
		pages = 0
		switch(screen)
			if(SCREEN_COVER) //Cover
				dat += "<div align='center'><b><font size=6>The Griffon</font></b></div>"
				dat += "<div align='center'><font size=2>Nanotrasen-standard newspaper, for use on Nanotrasen Space Facilities</font></div><hr>"
				if(!length(news_content))
					if(important_message)
						dat += "Contents:<br><ul><b><font color='red'>**</font>Important Security Announcement<font color='red'>**</font></b> <font size=2>\[page [pages+2]\]</font><br></ul>"
					else
						dat += "<i>Other than the title, the rest of the newspaper is unprinted...</i>"
				else
					dat += "Contents:<br><ul>"
					for(var/datum/feed_channel/NP in news_content)
						pages++
					if(important_message)
						dat += "<b><font color='red'>**</font>Important Security Announcement<font color='red'>**</font></b> <font size=2>\[page [pages+2]\]</font><br>"
					var/temp_page=0
					for(var/datum/feed_channel/NP in news_content)
						temp_page++
						dat += "<b>[NP.channel_name]</b> <font size=2>\[page [temp_page+1]\]</font><br>"
					dat += "</ul>"
				if(scribble_page==curr_page)
					dat += "<br><i>There is a small scribble near the end of this page... It reads: \"[scribble]\"</i>"
				dat+= "<hr><div style='float:right;'><a href='byond://?src=[UID()];next_page=1'>Next Page</a></div> <div style='float:left;'><a href='byond://?src=[human_user.UID()];mach_close=newspaper_main'>Done reading</a></div>"
			if(SCREEN_PAGE_INNER) // X channel pages inbetween.
				for(var/datum/feed_channel/NP in news_content)
					pages++ //Let's get it right again.
				var/datum/feed_channel/C = news_content[curr_page]
				dat += "<font size=4><b>[C.channel_name]</b></font><font size=1> \[created by: <font color='maroon'>[C.author]</font>\]</font><br><br>"
				if(C.censored)
					dat += "This channel was deemed dangerous to the general welfare of the station and therefore marked with a <b><font color='red'>D-Notice</b></font>. Its contents were not transferred to the newspaper at the time of printing."
				else
					if(!length(C.messages))
						dat += "No Feed stories stem from this channel..."
					else
						dat += "<ul>"
						var/i = 0
						for(var/datum/feed_message/MESSAGE in C.messages)
							var/title = (MESSAGE.censor_flags & NEWSCASTER_CENSOR_STORY) ? "\[REDACTED\]" : MESSAGE.title
							var/body = (MESSAGE.censor_flags & NEWSCASTER_CENSOR_STORY) ? "\[REDACTED\]" : MESSAGE.body
							i++
							dat += "<b>[title]</b> <br>"
							dat += "[body] <br>"
							if(MESSAGE.img)
								user << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat += "<img src='tmp_photo[i].png' width = '180'><br>"
							dat += "<font size=1>\[Story by <font color='maroon'>[MESSAGE.author]</font>\]</font><br><br>"
						dat += "</ul>"
				if(scribble_page==curr_page)
					dat += "<br><i>There is a small scribble near the end of this page... It reads: \"[scribble]\"</i>"
				dat+= "<br><hr><div style='float:left;'><a href='byond://?src=[UID()];prev_page=1'>Previous Page</a></div> <div style='float:right;'><a href='byond://?src=[UID()];next_page=1'>Next Page</a></div>"
			if(SCREEN_PAGE_LAST) //Last page
				for(var/datum/feed_channel/NP in news_content)
					pages++
				if(important_message!=null)
					dat += "<div style='float:center;'><font size=4><b>Wanted Issue:</b></font></div><br><br>"
					dat += "<b>Criminal name</b>: <font color='maroon'>[important_message.author]</font><br>"
					dat += "<b>Description</b>: [important_message.body]<br>"
					dat += "<b>Photo:</b>: "
					if(important_message.img)
						user << browse_rsc(important_message.img, "tmp_photow.png")
						dat += "<br><img src='tmp_photow.png' width = '180'>"
					else
						dat += "None"
				else
					dat += "<i>Apart from some uninteresting Classified ads, there's nothing on this page...</i>"
				if(scribble_page==curr_page)
					dat += "<br><i>There is a small scribble near the end of this page... It reads: \"[scribble]\"</i>"
				dat+= "<hr><div style='float:left;'><a href='byond://?src=[UID()];prev_page=1'>Previous Page</a></div>"
			else
				// No trailing punctuation so that it's easy to copy and paste the address
				if(GLOB.configuration.url.github_url)
					dat += "We're sorry to break your immersion, but there has been an error with the newscaster. Please report this error, along with any more information you have, to [GLOB.configuration.url.github_url]/issues/new?template=bug_report.md"
				else
					dat += "We're sorry to break your immersion, but there has been an error with the newscaster. Unfortunately there is no GitHub URL set in the config. This is really bad."

		dat += "<br><hr><div align='center'>[curr_page+1]</div>"
		human_user << browse(dat, "window=newspaper_main;size=300x400")
		onclose(human_user, "newspaper_main")
	else
		to_chat(user, "<span class='warning'>The paper is full of unintelligible symbols!</span>")

/obj/item/newspaper/Topic(href, href_list)
	if(..())
		return
	var/mob/living/M = usr
	if(!Adjacent(M))
		return

	if(href_list["next_page"])
		if(curr_page == pages + 1)
			return //Don't need that at all, but anyway.
		else if(curr_page == pages) //We're at the middle, get to the end
			screen = SCREEN_PAGE_LAST
		else if(curr_page == 0) //We're at the start, get to the middle
			screen = SCREEN_PAGE_INNER
		curr_page++
		playsound(loc, "pageturn", 50, TRUE)

	else if(href_list["prev_page"])
		if(curr_page == 0)
			return
		else if(curr_page == 1)
			screen = SCREEN_COVER
		else if(curr_page == pages + 1) //we're at the end, let's go back to the middle.
			screen = SCREEN_PAGE_INNER
		curr_page--
		playsound(loc, "pageturn", 50, TRUE)
	if(loc == M)
		attack_self__legacy__attackchain(M)

/obj/item/newspaper/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(is_pen(W))
		if(rolled)
			to_chat(user, "<span class='warning'>Unroll it first!</span>")
			return
		if(scribble_page == curr_page)
			to_chat(user, "<span class='notice'>There's already a scribble in this page... You wouldn't want to make things too cluttered, would you?</span>")
		else
			var/s = tgui_input_text(user, "Write something", "Newspaper")
			if(!s || !Adjacent(user))
				return
			scribble_page = curr_page
			scribble = s
			user.visible_message("<span class='notice'>[user] scribbles something on [src].</span>",\
								"<span class='notice'>You scribble on page number [curr_page] of [src].</span>")
			attack_self__legacy__attackchain(user)
		return
	return ..()

/obj/item/newspaper/AltClick(mob/user)
	if(ishuman(user) && Adjacent(user) && !user.incapacitated())
		rolled = !rolled
		icon_state = "newspaper[rolled ? "_rolled" : ""]"
		update_icon()
		var/verbtext = "[rolled ? "" : "un"]roll"
		user.visible_message("<span class='notice'>[user] [verbtext]s [src].</span>",\
								"<span class='notice'>You [verbtext] [src].</span>")
		name = "[rolled ? "rolled" : ""] [initial(name)]"
	return ..()

#undef SCREEN_COVER
#undef SCREEN_PAGE_INNER
#undef SCREEN_PAGE_LAST
