/client/proc/create_poll()
	set name = "Create Server Poll"
	set category = "Server"
	if(!check_rights(R_SERVER))	
		return
	if(!dbcon.IsConnected())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	create_poll_window()

/client/proc/create_poll_window(var/errormessage = "")
	if(!check_rights(R_SERVER))	
		return
	var/output={"<!DOCTYPE html>
<html>
<head>
<script>
var numoptions = 0;
function update_vis() {
	var polloptions = document.getElementById("polloptions");
	var polltype = document.getElementById("polltype").value;
	if(polltype == "[POLLTYPE_TEXT]") {
		polloptions.style.display = "none";
	} else {
		polloptions.style.display = "block";
	}
	if(polltype == "[POLLTYPE_RATING]") {
		for(var i = 0; i < numoptions; i++) {
			document.getElementById("ratingoption" + i).style.display = "block";
		}
	} else {
		for(var i = 0; i < numoptions; i++) {
			document.getElementById("ratingoption" + i).style.display = "none";
		}
	}
	if(polltype == "[POLLTYPE_MULTI]") {
		document.getElementById("choiceamount").style.display = "block";
	} else {
		document.getElementById("choiceamount").style.display = "none";
	}
}
function add_option() {
	document.getElementById("polloptionsinner").innerHTML += "<div id='polloption"+numoptions+"' style='border:1px solid black;padding:10px'>"+
	"Option name: <input type='text' name='createpolloption"+numoptions+"option' value='' style='width:300px'></input><br>"+
	"<label><input type='checkbox' name='createpolloption"+numoptions+"percentagecalc' value='1' checked>Calculate options results as percentage?</label><br>"+
	"<div id='ratingoption"+numoptions+"'>"+
	"Minimum rating value: <input type='text' name='createpolloption"+numoptions+"minval' value='1'></input><br>"+
	"Maximum rating value: <input type='text' name='createpolloption"+numoptions+"maxval' value='5'></input><br>"+
	"Minimum rating description: <input type='text' name='createpolloption"+numoptions+"descmin' value='Terrible'></input><br>"+
	"Median rating description: <input type='text' name='createpolloption"+numoptions+"descmid' value=''></input><br>"+
	"Maximum rating description: <input type='text' name='createpolloption"+numoptions+"descmax' value='Great'></input>"+
	"</div>";
	numoptions++;
	document.getElementById("createpollnumoptions").value = numoptions+"";
	update_vis();
}
function del_option() {
	if(numoptions <= 1) {
		return;
	}
	numoptions--;
	document.getElementById("polloptionsinner").removeChild(document.getElementById("polloption"+numoptions));
	document.getElementById("createpollnumoptions").value = numoptions+"";
	update_vis();
}
function onload() {
	update_vis();
	add_option();
}
</script>
</head>
<body onload="onload()">
	<div style='text-align:center'><b>Create Player Poll</b></div><hr>
	<div style='text-align:center'>[errormessage]</div>
	<form name='createpoll' action='byond://' method='post' style='padding-left:30px;padding-right:30px;padding-top:10px'>
		<input type='hidden' name='createpollnumoptions' id='createpollnumoptions' value='0'>
		<table><tr><td style='width:50%' style="vertical-align:top"><div id='polloptions'><div id='polloptionsinner'>
		
		</div>
		<input type='button' onclick='add_option()' value="Add Option"></input>
		<input type='button' onclick='del_option()' value="Delete Option"></input>
		</div></td><td style="vertical-align:top">
		Select a poll type: <select name='createpoll' id='polltype' onchange="update_vis()">
			<option value='[POLLTYPE_OPTION]'>POLLTYPE_OPTION</option>
			<option value='[POLLTYPE_TEXT]'>POLLTYPE_TEXT</option>
			<option value='[POLLTYPE_RATING]'>POLLTYPE_RATING</option>
			<option value='[POLLTYPE_MULTI]'>POLLTYPE_MULTI</option>
		</select><br>
		For how many days should this poll run? <input type='text' name='createpollduration' value='7' style='width:50px'></input><br>
		Enter your question: <input type='text' name='createpollquestion' value='' style='width:300px'></input><br>
		<div id='choiceamount'>Up to how many options should be chosen? <input name='choiceamount' value='2' style='width:30px'></div>
		<label><input type='checkbox' name='createpolladminonly' value='1'>Admin only?</label><br>
		</td></tr><tr><td colspan=2 style='text-align:center'>
		<input type='submit' value='Create poll'>
		</td></tr></table>
	</form>
</body>
</html>"}
	src << browse(output, "window=createplayerpoll;size=950x500")

/client/proc/create_poll_function(href_list)
	if(!check_rights(R_SERVER))	
		return
	var/polltype = href_list["createpoll"]
	if(polltype != POLLTYPE_OPTION && polltype != POLLTYPE_TEXT && polltype != POLLTYPE_RATING && polltype != POLLTYPE_MULTI)
		create_poll_window("<font color='red'>Invalid poll type</font>")
		return
	var/choice_amount = 0
	if(polltype == POLLTYPE_MULTI)
		choice_amount = text2num(href_list["choiceamount"])
		if(!isnum(choice_amount) || choice_amount < 1)
			create_poll_window("<font color='red'>Invalid choice amount. Must be at least 1.</font>")
			return
	var/poll_len = text2num(href_list["createpollduration"])
	if(!isnum(poll_len) || poll_len < 1)
		create_poll_window("<font color='red'>Invalid poll duration. Must be at least 1.</font>")
		return
	var/adminonly = text2num(href_list["createpolladminonly"]) ? 1 : 0
	var/sql_ckey = sanitizeSQL(ckey)
	var/question = href_list["createpollquestion"]
	if(!question)
		create_poll_window("<font color='red'>Question cannot be blank.</font>")
		return
	question = sanitizeSQL(question)
	
	var/starttime
	var/endtime
	var/DBQuery/query = dbcon.NewQuery("SELECT Now() AS starttime, ADDDATE(Now(), INTERVAL [poll_len] DAY) AS endtime")
	query.Execute()
	while(query.NextRow())
		starttime = query.item[1]
		endtime = query.item[2]
	
	var/pollquery = "INSERT INTO [format_table_name("poll_question")] (polltype, starttime, endtime, question, adminonly, multiplechoiceoptions, createdby_ckey, createdby_ip) VALUES ('[polltype]', '[starttime]', '[endtime]', '[question]', '[adminonly]', '[choice_amount]', '[sql_ckey]', '[address]')"
	var/idquery = "SELECT id FROM [format_table_name("poll_question")] WHERE question = '[question]' AND starttime = '[starttime]' AND endtime = '[endtime]' AND createdby_ckey = '[sql_ckey]' AND createdby_ip = '[address]'"
	var/list/option_queries = list()
	if(polltype == POLLTYPE_MULTI || polltype == POLLTYPE_RATING || polltype == POLLTYPE_OPTION)
		var/numoptions = text2num(href_list["createpollnumoptions"])
		if(!numoptions)
			create_poll_window("<font color='red'>Invalid number of options</font>")
			return
		for(var/I in 1 to numoptions)
			var/option = href_list["createpolloption[I]option"]
			if(!option)
				create_poll_window("<font color='red'>Invalid option name for option [I]</font>")
				return
			option = sanitizeSQL(option)
			var/percentagecalc = 0
			if(text2num(href_list["createpolloption[I]percentagecalc"]))
				percentagecalc = 1
			var/minval = 0
			var/maxval = 0
			var/descmin = ""
			var/descmid = ""
			var/descmax = ""
			if(polltype == POLLTYPE_RATING)
				minval = text2num(href_list["createpolloption[I]minval"])
				if(!minval)
					create_poll_window("<font color='red'>Invalid minimum value for option [I]</font>")
					return
				maxval = text2num(href_list["createpolloption[I]maxval"])
				if(!maxval)
					create_poll_window("<font color='red'>Invalid maximum value for option [I]</font>")
					return
				if(minval >= maxval)
					create_poll_window("<font color='red'>Minimum rating value can't be more than maximum rating value</font>")
					return
				descmin = href_list["createpolloption[I]descmin"]
				if(descmin)
					descmin = sanitizeSQL(descmin)
				descmid = href_list["createpolloption[I]descmid"]
				if(descmid)
					descmid = sanitizeSQL(descmid)
				descmax = href_list["createpolloption[I]descmax"]
				if(descmax)
					descmax = sanitizeSQL(descmax)
			option_queries += "INSERT INTO [format_table_name("poll_option")] (pollid, text, percentagecalc, minval, maxval, descmin, descmid, descmax) VALUES ('{POLLID}', '[option]', '[percentagecalc]', '[minval]', '[maxval]', '[descmin]', '[descmid]', '[descmax]')"
	
	query = dbcon.NewQuery(pollquery)
	if(!query.Execute())
		var/err = query.ErrorMsg()
		create_poll_window("<font color='red'>An SQL error has occured while creating your poll</font>")
		log_game("SQL ERROR adding new poll question to table. Error : \[[err]\]\n")
		return
	var/pollid = 0
	query = dbcon.NewQuery(idquery)
	if(!query.Execute())
		var/err = query.ErrorMsg()
		create_poll_window("<font color='red'>An SQL error has occured while creating your poll</font>")
		log_game("SQL ERROR obtaining id from poll_question table. Error : \[[err]\]\n")
		return
	if(query.NextRow())
		pollid = text2num(query.item[1])
	for(var/querytext in option_queries)
		query = dbcon.NewQuery(replacetext(idquery, "{POLLID}", pollid))
		if(!query.Execute())
			var/err = query.ErrorMsg()
			create_poll_window("<font color='red'>An SQL error has occured while creating your poll</font>")
			log_game("SQL ERROR obtaining id from poll_question table. Error : \[[err]\]\n")
			return
	create_poll_window("<font color='#008800'>Your poll has been successfully created</font>")
	return pollid