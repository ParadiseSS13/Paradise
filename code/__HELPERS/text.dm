/*
 * Holds procs designed to help with filtering text
 * Contains groups:
 *			SQL sanitization
 *			Text sanitization
 *			Text searches
 *			Text modification
 *			Misc
 */


/*
 * SQL sanitization
 */

// Run all strings to be used in an SQL query through this proc first to properly escape out injection attempts.
/proc/sanitizeSQL(var/t as text)
	if(isnull(t))
		return null
	if(!istext(t))
		t = "[t]" // Just quietly assume any non-texts are supposed to be text
	var/sqltext = dbcon.Quote(t);
	return copytext(sqltext, 2, length(sqltext));//Quote() adds quotes around input, we already do that

/proc/format_table_name(table as text)
	return sqlfdbktableprefix + table

/*
 * Text sanitization
 */
// Can be used almost the same way as normal input for text
/proc/clean_input(Message, Title, Default, mob/user=usr)
	var/txt = input(user, Message, Title, Default) as text | null
	if(txt)
		return html_encode(txt)

//Simply removes < and > and limits the length of the message
/proc/strip_html_simple(var/t,var/limit=MAX_MESSAGE_LEN)
	var/list/strip_chars = list("<",">")
	t = copytext(t,1,limit)
	for(var/char in strip_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + copytext(t, index+1)
			index = findtext(t, char)
	return t

//Removes a few problematic characters
/proc/sanitize_simple(var/t,var/list/repl_chars = list("\n"="#","\t"="#"))
	for(var/char in repl_chars)
		t = replacetext(t, char, repl_chars[char])
	return t

/proc/readd_quotes(var/t)
	var/list/repl_chars = list("&#34;" = "\"")
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+5)
			index = findtext(t, char)
	return t

//Runs byond's sanitization proc along-side sanitize_simple
/proc/sanitize(var/t,var/list/repl_chars = null)
	return html_encode(sanitize_simple(t,repl_chars))

// Gut ANYTHING that isnt alphanumeric, or brackets
/proc/paranoid_sanitize(t)
	var/regex/alphanum_only = regex("\[^a-zA-Z0-9# ,.?!:;()]", "g")
	return alphanum_only.Replace(t, "#")

// Less agressive, to allow discord features, such as <>, / and @
/proc/not_as_paranoid_sanitize(t)
	var/regex/alphanum_slashes_only = regex("\[^a-zA-Z0-9# ,.?!:;()/<>@]", "g")
	return alphanum_slashes_only.Replace(t, "#")

//Runs sanitize and strip_html_simple
//I believe strip_html_simple() is required to run first to prevent '<' from displaying as '&lt;' after sanitize() calls byond's html_encode()
/proc/strip_html(var/t,var/limit=MAX_MESSAGE_LEN)
	return copytext((sanitize(strip_html_simple(t))),1,limit)

// Used to get a properly sanitized multiline input, of max_length
/proc/stripped_multiline_input(mob/user, message = "", title = "", default = "", max_length=MAX_MESSAGE_LEN, no_trim=FALSE)
	var/name = input(user, message, title, default) as message|null
	if(no_trim)
		return copytext(html_encode(name), 1, max_length)
	else
		return trim(html_encode(name), max_length)

//Runs byond's sanitization proc along-side strip_html_simple
//I believe strip_html_simple() is required to run first to prevent '<' from displaying as '&lt;' that html_encode() would cause
/proc/adminscrub(var/t,var/limit=MAX_MESSAGE_LEN)
	return copytext((html_encode(strip_html_simple(t))),1,limit)


//Returns null if there is any bad text in the string
/proc/reject_bad_text(var/text, var/max_length=512)
	if(length(text) > max_length)	return			//message too long
	var/non_whitespace = 0
	for(var/i=1, i<=length(text), i++)
		switch(text2ascii(text,i))
			if(62,60,92,47)	return			//rejects the text if it contains these bad characters: <, >, \ or /
			if(127 to 255)	return			//rejects weird letters like �
			if(0 to 31)		return			//more weird stuff
			if(32)			continue		//whitespace
			else			non_whitespace = 1
	if(non_whitespace)		return text		//only accepts the text if it has some non-spaces

// Used to get a sanitized input.
/proc/stripped_input(mob/user, message = "", title = "", default = "", max_length=MAX_MESSAGE_LEN, no_trim=FALSE)
	var/name = html_encode(input(user, message, title, default) as text|null)
	if(!no_trim)
		name = trim(name) //trim is "outside" because html_encode can expand single symbols into multiple symbols (such as turning < into &lt;)
	return copytext(name, 1, max_length)

// Uses client.typing to check if the popup should appear or not
/proc/typing_input(mob/user, message = "", title = "", default = "")
	if(user.client.checkTyping()) // Prevent double windows
		return null
	var/client/C = user.client // Save it in a var in case the client disconnects from the mob
	C.typing = TRUE
	var/msg = input(user, message, title, default) as text|null
	if(!C)
		return null
	C.typing = FALSE
	if(!user || C != user.client) // User got out of the mob for some reason or the mob is gone
		return null
	return msg

//Filters out undesirable characters from names
/proc/reject_bad_name(var/t_in, var/allow_numbers=0, var/max_length=MAX_NAME_LEN)
	// Decode so that names with characters like < are still rejected
	t_in = html_decode(t_in)
	if(!t_in || length(t_in) > max_length)
		return //Rejects the input if it is null or if it is longer than the max length allowed

	var/number_of_alphanumeric	= 0
	var/last_char_group			= 0
	var/t_out = ""

	for(var/i=1, i<=length(t_in), i++)
		var/ascii_char = text2ascii(t_in,i)
		switch(ascii_char)
			// A  .. Z
			if(65 to 90)			//Uppercase Letters
				t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// a  .. z
			if(97 to 122)			//Lowercase Letters
				if(last_char_group<2)		t_out += ascii2text(ascii_char-32)	//Force uppercase first character
				else						t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// 0  .. 9
			if(48 to 57)			//Numbers
				if(!last_char_group)		continue	//suppress at start of string
				if(!allow_numbers)			continue
				t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 3

			// '  -  . ,
			if(39, 45, 46, 44)			//Common name punctuation
				if(!last_char_group) continue
				t_out += ascii2text(ascii_char)
				last_char_group = 2

			// ~   |   @  :  #  $  %  &  *  +  !
			if(126, 124, 64, 58, 35, 36, 37, 38, 42, 43, 33)			//Other symbols that we'll allow (mainly for AI)
				if(!last_char_group)		continue	//suppress at start of string
				if(!allow_numbers)			continue
				t_out += ascii2text(ascii_char)
				last_char_group = 2

			//Space
			if(32)
				if(last_char_group <= 1)	continue	//suppress double-spaces and spaces at start of string
				t_out += ascii2text(ascii_char)
				last_char_group = 1
			else
				return

	if(number_of_alphanumeric < 2)	return		//protects against tiny names like "A" and also names like "' ' ' ' ' ' ' '"

	if(last_char_group == 1)
		t_out = copytext(t_out,1,length(t_out))	//removes the last character (in this case a space)

	for(var/bad_name in list("space","floor","wall","r-wall","monkey","unknown","inactive ai","plating"))	//prevents these common metagamey names
		if(cmptext(t_out,bad_name))	return	//(not case sensitive)

	return t_out

//checks text for html tags
//if tag is not in whitelist (var/list/paper_tag_whitelist in global.dm)
//relpaces < with &lt;
proc/checkhtml(var/t)
	t = sanitize_simple(t, list("&#"="."))
	var/p = findtext(t,"<",1)
	while(p)	//going through all the tags
		var/start = p++
		var/tag = copytext(t,p, p+1)
		if(tag != "/")
			while(reject_bad_text(copytext(t, p, p+1), 1))
				tag = copytext(t,start, p)
				p++
			tag = copytext(t,start+1, p)
			if(!(tag in paper_tag_whitelist))	//if it's unkown tag, disarming it
				t = copytext(t,1,start-1) + "&lt;" + copytext(t,start+1)
		p = findtext(t,"<",p)
	return t
/*
 * Text searches
 */

//Checks the beginning of a string for a specified sub-string
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end)

//Checks the beginning of a string for a specified sub-string. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix_case(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtextEx(text, prefix, start, end)

//Checks the end of a string for a specified substring.
//Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtext(text, suffix, start, null)
	return

//Checks the end of a string for a specified substring. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix_case(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtextEx(text, suffix, start, null)

/*
 * Text modification
 */
// See bygex.dm
/proc/replace_characters(var/t,var/list/repl_chars)
	for(var/char in repl_chars)
		t = replacetext(t, char, repl_chars[char])
	return t

//Strips the first char and returns it and the new string as a list
/proc/strip_first(t)
	return list(copytext(t, 1, 2), copytext(t, 2, 0))

//Strips the last char and returns it and the new string as a list
/proc/strip_last(t)
	return list(copytext(t, 1, length(t)), copytext(t, length(t)))

//Adds 'u' number of zeros ahead of the text 't'
/proc/add_zero(t, u)
	while(length(t) < u)
		t = "0[t]"
	return t

//Adds 'u' number of spaces ahead of the text 't'
/proc/add_lspace(t, u)
	while(length(t) < u)
		t = " [t]"
	return t

//Adds 'u' number of spaces behind the text 't'
/proc/add_tspace(t, u)
	while(length(t) < u)
		t = "[t] "
	return t

//Returns a string with reserved characters and spaces before the first letter removed
/proc/trim_left(text)
	for(var/i = 1 to length(text))
		if(text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

//Returns a string with reserved characters and spaces after the last letter removed
/proc/trim_right(text)
	for(var/i = length(text), i > 0, i--)
		if(text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)

	return ""

//Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text)
	return trim_left(trim_right(text))

//Returns a string with the first element of the string capitalized.
/proc/capitalize(var/t as text)
	return uppertext(copytext(t, 1, 2)) + copytext(t, 2)

//Centers text by adding spaces to either side of the string.
/proc/dd_centertext(message, length)
	var/new_message = message
	var/size = length(message)
	var/delta = length - size
	if(size == length)
		return new_message
	if(size > length)
		return copytext(new_message, 1, length + 1)
	if(delta == 1)
		return new_message + " "
	if(delta % 2)
		new_message = " " + new_message
		delta--
	var/spaces = add_lspace("",delta/2-1)
	return spaces + new_message + spaces

//Limits the length of the text. Note: MAX_MESSAGE_LEN and MAX_NAME_LEN are widely used for this purpose
/proc/dd_limittext(message, length)
	var/size = length(message)
	if(size <= length)
		return message
	return copytext(message, 1, length + 1)


/proc/stringmerge(var/text,var/compare,replace = "*")
//This proc fills in all spaces with the "replace" var (* by default) with whatever
//is in the other string at the same spot (assuming it is not a replace char).
//This is used for fingerprints
	var/newtext = text
	if(length(text) != length(compare))
		return 0
	for(var/i = 1, i < length(text), i++)
		var/a = copytext(text,i,i+1)
		var/b = copytext(compare,i,i+1)
//if it isn't both the same letter, or if they are both the replacement character
//(no way to know what it was supposed to be)
		if(a != b)
			if(a == replace) //if A is the replacement char
				newtext = copytext(newtext,1,i) + b + copytext(newtext, i+1)
			else if(b == replace) //if B is the replacement char
				newtext = copytext(newtext,1,i) + a + copytext(newtext, i+1)
			else //The lists disagree, Uh-oh!
				return 0
	return newtext

/proc/stringpercent(var/text,character = "*")
//This proc returns the number of chars of the string that is the character
//This is used for detective work to determine fingerprint completion.
	if(!text || !character)
		return 0
	var/count = 0
	for(var/i = 1, i <= length(text), i++)
		var/a = copytext(text,i,i+1)
		if(a == character)
			count++
	return count

/proc/reverse_text(var/text = "")
	var/new_text = ""
	for(var/i = length(text); i > 0; i--)
		new_text += copytext(text, i, i+1)
	return new_text

//This proc strips html properly, but it's not lazy like the other procs.
//This means that it doesn't just remove < and > and call it a day.
//Also limit the size of the input, if specified.
/proc/strip_html_properly(var/input, var/max_length = MAX_MESSAGE_LEN, allow_lines = 0)
	if(!input)
		return
	var/opentag = 1 //These store the position of < and > respectively.
	var/closetag = 1
	while(1)
		opentag = findtext(input, "<")
		closetag = findtext(input, ">")
		if(closetag && opentag)
			if(closetag < opentag)
				input = copytext(input, (closetag + 1))
			else
				input = copytext(input, 1, opentag) + copytext(input, (closetag + 1))
		else if(closetag || opentag)
			if(opentag)
				input = copytext(input, 1, opentag)
			else
				input = copytext(input, (closetag + 1))
		else
			break
	if(max_length)
		input = copytext(input,1,max_length)
	return sanitize(input, allow_lines ? list("\t" = " ") : list("\n" = " ", "\t" = " "))

/proc/trim_strip_html_properly(var/input, var/max_length = MAX_MESSAGE_LEN, allow_lines = 0)
    return trim(strip_html_properly(input, max_length, allow_lines))

//Used in preferences' SetFlavorText and human's set_flavor verb
//Previews a string of len or less length
/proc/TextPreview(var/string,var/len=40)
	if(length(string) <= len)
		if(!length(string))
			return "\[...\]"
		else
			return html_encode(string) //NO DECODED HTML YOU CHUCKLEFUCKS
	else
		return "[copytext_preserve_html(string, 1, 37)]..."

//alternative copytext() for encoded text, doesn't break html entities (&#34; and other)
/proc/copytext_preserve_html(var/text, var/first, var/last)
	return html_encode(copytext(html_decode(text), first, last))

//Run sanitize(), but remove <, >, " first to prevent displaying them as &gt; &lt; &34; in some places, after html_encode().
//Best used for sanitize object names, window titles.
//If you have a problem with sanitize() in chat, when quotes and >, < are displayed as html entites -
//this is a problem of double-encode(when & becomes &amp;), use sanitize() with encode=0, but not the sanitizeSafe()!
/proc/sanitizeSafe(var/input, var/max_length = MAX_MESSAGE_LEN, var/encode = 1, var/trim = 1, var/extra = 1)
	return sanitize(replace_characters(input, list(">"=" ","<"=" ", "\""="'")), max_length, encode, trim, extra)


//Replace BYOND text macros with span classes for to_chat
/proc/replace_text_macro(match, code, rest)
	var/regex/text_macro = new("(\\xFF.)(.*)$")
	return text_macro.Replace(rest, /proc/replace_text_macro)

/proc/macro2html(text)
    var/static/regex/text_macro = new("(\\xFF.)(.*)$")
    return text_macro.Replace(text, /proc/replace_text_macro)

/proc/dmm_encode(text)
	// First, go through and nix out any of our escape sequences so we don't leave ourselves open to some escape sequence attack
	// Some coder will probably despise me for this, years down the line

	var/list/repl_chars = list("#?qt;", "#?lbr;", "#?rbr;")
	for(var/char in repl_chars)
		var/index = findtext(text, char)
		var/keylength = length(char)
		while(index)
			log_runtime(EXCEPTION("Bad string given to dmm encoder! [text]"))
			// Replace w/ underscore to prevent "&#3&#123;4;" from cheesing the radar
			// Should probably also use canon text replacing procs
			text = copytext(text, 1, index) + "_" + copytext(text, index+keylength)
			index = findtext(text, char)

	// Then, replace characters as normal
	var/list/repl_chars_2 = list("\"" = "#?qt;", "{" = "#?lbr;", "}" = "#?rbr;")
	for(var/char in repl_chars_2)
		var/index = findtext(text, char)
		var/keylength = length(char)
		while(index)
			text = copytext(text, 1, index) + repl_chars_2[char] + copytext(text, index+keylength)
			index = findtext(text, char)
	return text


/proc/dmm_decode(text)
	// Replace what we extracted above
	var/list/repl_chars = list("#?qt;" = "\"", "#?lbr;" = "{", "#?rbr;" = "}")
	for(var/char in repl_chars)
		var/index = findtext(text, char)
		var/keylength = length(char)
		while(index)
			text = copytext(text, 1, index) + repl_chars[char] + copytext(text, index+keylength)
			index = findtext(text, char)
	return text

//Checks if any of a given list of needles is in the haystack
/proc/text_in_list(haystack, list/needle_list, start=1, end=0)
	for(var/needle in needle_list)
		if(findtext(haystack, needle, start, end))
			return 1
	return 0

//Like above, but case sensitive
/proc/text_in_list_case(haystack, list/needle_list, start=1, end=0)
	for(var/needle in needle_list)
		if(findtextEx(haystack, needle, start, end))
			return 1
	return 0


// Pencode
/proc/pencode_to_html(text, mob/user, obj/item/pen/P = null, format = 1, sign = 1, fields = 1, deffont = PEN_FONT, signfont = SIGNFONT, crayonfont = CRAYON_FONT, no_font = FALSE)
	text = replacetext(text, "\[b\]",		"<B>")
	text = replacetext(text, "\[/b\]",		"</B>")
	text = replacetext(text, "\[i\]",		"<I>")
	text = replacetext(text, "\[/i\]",		"</I>")
	text = replacetext(text, "\[u\]",		"<U>")
	text = replacetext(text, "\[/u\]",		"</U>")
	if(sign)
		text = replacetext(text, "\[sign\]",	"<font face=\"[signfont]\"><i>[user ? user.real_name : "Anonymous"]</i></font>")
	if(fields)
		text = replacetext(text, "\[field\]",	"<span class=\"paper_field\"></span>")
	if(format)
		text = replacetext(text, "\[h1\]",	"<H1>")
		text = replacetext(text, "\[/h1\]",	"</H1>")
		text = replacetext(text, "\[h2\]",	"<H2>")
		text = replacetext(text, "\[/h2\]",	"</H2>")
		text = replacetext(text, "\[h3\]",	"<H3>")
		text = replacetext(text, "\[/h3\]",	"</H3>")
		text = replacetext(text, "\n",			"<BR>")
		text = replacetext(text, "\[center\]",	"<center>")
		text = replacetext(text, "\[/center\]",	"</center>")
		text = replacetext(text, "\[br\]",		"<BR>")
		text = replacetext(text, "\[large\]",	"<font size=\"4\">")
		text = replacetext(text, "\[/large\]",	"</font>")

	if(istype(P, /obj/item/toy/crayon) || !format) // If it is a crayon, and he still tries to use these, make them empty!
		text = replacetext(text, "\[*\]", 		"")
		text = replacetext(text, "\[hr\]",		"")
		text = replacetext(text, "\[small\]", 	"")
		text = replacetext(text, "\[/small\]", 	"")
		text = replacetext(text, "\[list\]", 	"")
		text = replacetext(text, "\[/list\]", 	"")
		text = replacetext(text, "\[table\]", 	"")
		text = replacetext(text, "\[/table\]", 	"")
		text = replacetext(text, "\[row\]", 	"")
		text = replacetext(text, "\[cell\]", 	"")
		text = replacetext(text, "\[logo\]", 	"")
	if(istype(P, /obj/item/toy/crayon))
		text = "<font face=\"[crayonfont]\" color=[P ? P.colour : "black"]><b>[text]</b></font>"
	else 	// They are using "not a crayon" - formatting is OK and such
		text = replacetext(text, "\[*\]",		"<li>")
		text = replacetext(text, "\[hr\]",		"<HR>")
		text = replacetext(text, "\[small\]",	"<font size = \"1\">")
		text = replacetext(text, "\[/small\]",	"</font>")
		text = replacetext(text, "\[list\]",	"<ul>")
		text = replacetext(text, "\[/list\]",	"</ul>")
		text = replacetext(text, "\[table\]",	"<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>")
		text = replacetext(text, "\[/table\]",	"</td></tr></table>")
		text = replacetext(text, "\[grid\]",	"<table>")
		text = replacetext(text, "\[/grid\]",	"</td></tr></table>")
		text = replacetext(text, "\[row\]",		"</td><tr>")
		text = replacetext(text, "\[cell\]",	"<td>")
		text = replacetext(text, "\[logo\]",	"<img src = ntlogo.png>")
		text = replacetext(text, "\[time\]",	"[station_time_timestamp()]") // TO DO
		if(!no_font)
			if(P)
				text = "<font face=\"[deffont]\" color=[P ? P.colour : "black"]>[text]</font>"
			else
				text = "<font face=\"[deffont]\">[text]</font>"

	text = copytext(text, 1, MAX_PAPER_MESSAGE_LEN)
	return text

/proc/convert_pencode_arg(text, tag, arg)
	arg = sanitize_simple(html_encode(arg), list("''"="","\""="", "?"=""))
	// https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html#rule-4---css-escape-and-strictly-validate-before-inserting-untrusted-data-into-html-style-property-values
	var/list/style_attacks = list("javascript:", "expression", "byond:", "file:")

	for(var/style_attack in style_attacks)
		if(findtext(arg, style_attack))
			// Do not attempt to render dangerous things
			return text

	if(tag == "class")
		return "<span class='[arg]'>"

	if(tag == "style")
		return "<span style='[arg]'>"

	if(tag == "img")
		var/list/img_props = splittext(arg, ";")
		if(img_props.len == 3)
			return "<img src='[img_props[1]]' width='[img_props[2]]' height='[img_props[3]]'>"
		if(img_props.len == 2)
			return "<img src='[img_props[1]]' width='[img_props[2]]'>"
		return "<img src='[arg]'>"

	return text

/proc/admin_pencode_to_html()
	var/text = pencode_to_html(arglist(args))
	var/regex/R = new(@"\[(.*?) (.*?)\]", "ge")
	text = R.Replace(text, /proc/convert_pencode_arg)

	text = replacetext(text, "\[/class\]", "</span>")
	text = replacetext(text, "\[/style\]", "</span>")
	text = replacetext(text, "\[/img\]", "</img>")

	return text

/proc/html_to_pencode(text)
	text = replacetext(text, "<BR>",								"\n")
	text = replacetext(text, "<center>",							"\[center\]")
	text = replacetext(text, "</center>",							"\[/center\]")
	text = replacetext(text, "<BR>",								"\[br\]")
	text = replacetext(text, "<B>",									"\[b\]")
	text = replacetext(text, "</B>",								"\[/b\]")
	text = replacetext(text, "<I>",									"\[i\]")
	text = replacetext(text, "</I>",								"\[/i\]")
	text = replacetext(text, "<U>",									"\[u\]")
	text = replacetext(text, "</U>",								"\[/u\]")
	text = replacetext(text, "<font size=\"4\">",					"\[large\]")
	text = replacetext(text, "<span class=\"paper_field\"></span>",	"\[field\]")

	text = replacetext(text, "<H1>",	"\[h1\]")
	text = replacetext(text, "</H1>",	"\[/h1\]")
	text = replacetext(text, "<H2>",	"\[h2\]")
	text = replacetext(text, "</H2>",	"\[/h2\]")
	text = replacetext(text, "<H3>",	"\[h3\]")
	text = replacetext(text, "</H3>",	"\[/h3\]")

	text = replacetext(text, "<li>",					"\[*\]")
	text = replacetext(text, "<HR>",					"\[hr\]")
	text = replacetext(text, "<font size = \"1\">",		"\[small\]")
	text = replacetext(text, "<ul>",					"\[list\]")
	text = replacetext(text, "</ul>",					"\[/list\]")
	text = replacetext(text, "<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>",	"\[table\]")
	text = replacetext(text, "</td></tr></table>",		"\[/table\]")
	text = replacetext(text, "<table>",					"\[grid\]")
	text = replacetext(text, "</td></tr></table>",		"\[/grid\]")
	text = replacetext(text, "</td><tr>",				"\[row\]")
	text = replacetext(text, "<td>",					"\[cell\]")
	text = replacetext(text, "<img src = ntlogo.png>",	"\[logo\]")
	return text

#define string2charlist(string) (splittext(string, regex("(\\x0A|.)")) - splittext(string, ""))
