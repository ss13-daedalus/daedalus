/client
//START Admin Things
	//This should be changed to a datum
	var/obj/admins/holder = null // Stays null if client isn't an admin. Stores properties about the admin, if not null.
	var/buildmode = 0
	var/stealth = 0
	var/fakekey = null
	var/seeprayers = 0
	//Hosts can change their color
	var/ooccolor = "#b82e00"
	var/muted = null //Can't talk in OOC, say, whisper, emote... anything except for adminhelp and admin-pm. An admin punishment
	var/muted_complete = null //Can't talk in any way shape or form (muted + can't adminhelp or respond to admin pm-s). An admin punishment
	var/admin_invis = 0

//END Admin Things

	var/listen_ooc = 1
	var/move_delay = 1
	var/moving = null
	var/adminobs = null
	var/deadchat = 0.0
	var/changes = 0
	var/canplaysound = 1
	var/ambience_playing = null
	var/no_ambi = 0
	var/area = null
	var/played = 0
	var/team = null
	var/warned = 0
	var/be_syndicate = 0 //Moving this into client vars, since I was silly when I made it.

	var/STFU_ghosts		//80+ people rounds are fun to admin when text flies faster than airport security
	var/STFU_radio		//80+ people rounds are fun to admin when text flies faster than airport security
	var/sound_adminhelp = 0 //If set to 1 this will play a sound when adminhelps are received.

	var/midis = 1 //Check if midis should be played for someone
	var/bubbles = 1 //Check if bubbles should be displayed for someone
	var/be_alien = 0 //Check if that guy wants to be an alien
	var/be_pai = 1 //Consider client when searching for players to recruit as a pAI


	var/vote = null
	var/showvote = null



	// comment out the line below when debugging locally to enable the options & messages menu
	//control_freak = 1

client/verb/read_news()
	set name = "Read News"
	set category = "OOC"
	set desc = "Read important news and updates"
	display_all_news_list()

// check if there are any news in the player's "inbox"
client/proc/has_news()
	var/list/news = load_news()

	// load the list of news already read by this player
	var/path = savefile_path(src.mob)
	if(!fexists(path))
		return

	var/savefile/F = new(path)
	var/list/read_news = list()
	F["read_news"] >> read_news

	for(var/datum/news/N in news)
		if(N.ID in read_news)
			continue
		else return 1

	return 0

// display only the news that haven't been read yet
client/proc/display_news_list()
	var/list/news = load_news()

	var/output = ""
	if(has_news())
		// load the list of news already read by this player
		var/path = savefile_path(src.mob)
		if(!fexists(path))
			return

		var/savefile/F = new(path)
		var/list/read_news
		F["read_news"] >> read_news
		if(!read_news) read_news = list()

		for(var/datum/news/N in news)
			if(N.ID in read_news)
				continue
			read_news += N.ID
			output += "<b>[N.title]</b><br>"
			output += "[N.body]<br>"
			output += "<small>authored by <i>[N.author]</i></small><br>"
			output += "<br>"

		F["read_news"] << read_news
	else
		output += "<b>Nothing new!</b><br><br>"

	output += "<a href='?src=\ref[news_topic_handler];client=\ref[src];action=show_all_news'>Display All</a><br>"
	if(src.holder)
		output += "<a href='?src=\ref[news_topic_handler];client=\ref[src];action=add_news'>Add</a> <a href=http://baystation12.net/forums/index.php/topic,3680.0.html>Guidelines</a><br>"

	usr << browse(output, "window=news;size=600x400")


// display all news, even the ones read already
client/proc/display_all_news_list()
	var/list/news = load_news()

	var/admin = (src.holder)

	// load the list of news already read by this player
	var/path = savefile_path(src.mob)
	if(!fexists(path))
		return

	var/savefile/F = new(path)
	var/list/read_news
	F["read_news"] >> read_news
	if(!read_news) read_news = list()

	var/output = ""
	for(var/datum/news/N in news)
		if(!(N.ID in read_news))
			read_news += N.ID
		var/date = time2text(N.date,"MM/DD")
		output += "[date] <b>[N.title]</b><br>"
		output += "[N.body]<br>"
		output += "<small>authored by <i>[N.author]</i></small>"
		if(src.holder)
			output += " <a href='?src=\ref[news_topic_handler];client=\ref[src];action=remove;ID=[N.ID]'>Delete</a> <a href='?src=\ref[news_topic_handler];client=\ref[src];action=edit;ID=[N.ID]'>Edit</a>"
		output += "<br>"
		output += "<br>"
	F["read_news"] << read_news
	if(admin)
		output += "<a href='?src=\ref[news_topic_handler];client=\ref[src];action=add_news'>Add</a> <a href=http://baystation12.net/forums/index.php/topic,3680.0.html>Guidelines</a><br>"
	usr << browse(output, "window=news;size=600x400")

client/proc/add_news()
	if(!src.holder)
		src << "<b>You tried to modify the news, but you're not an admin!"
		return

	var/title = input(src.mob, "Select a title for the news", "Title") as null|text
	if(!title) return

	var/body = input(src.mob, "Enter a body for the news", "Body") as null|message
	if(!body) return

	make_news(title, body, key)

	spawn(1)
		display_all_news_list()

client/proc/remove_news(ID as num)
	if(!src.holder)
		src << "<b>You tried to modify the news, but you're not an admin!"
		return

	var/savefile/News = new("data/news.sav")
	var/list/news

	News["news"]   >> news

	for(var/datum/news/N in news)
		if(N.ID == ID)
			news.Remove(N)

	News["news"]   << news

	spawn(1)
		display_all_news_list()

client/proc/edit_news(ID as num)
	if(!src.holder)
		src << "<b>You tried to modify the news, but you're not an admin!"
		return

	var/savefile/News = new("data/news.sav")
	var/list/news

	News["news"]   >> news

	var/datum/news/found
	for(var/datum/news/N in news)
		if(N.ID == ID)
			found = N
	if(!found) src << "<b>* An error occured, sorry.</b>"

	var/title = input(src.mob, "Select a title for the news", "Title") as null|text
	if(!title) return

	var/body = input(src.mob, "Enter a body for the news", "Body") as null|message
	if(!body) return

	found.title = title
	found.body = body


	News["news"]   << news

	spawn(1)
		display_all_news_list()

client/proc/show_disconnected_pipes()
	set name = "Show Disconnected Pipes"
	set category = "Debug"

	if (!Debug2)
		return

	for(var/obj/machinery/atmospherics/pipe/simple/P in world)
		if(!P.node1 || !P.node2)
			usr << "[P], [P.x], [P.y], [P.z], [P.loc.loc]"

	for(var/obj/machinery/atmospherics/pipe/manifold/P in world)
		if(!P.node1 || !P.node2 || !P.node3)
			usr << "[P], [P.x], [P.y], [P.z], [P.loc.loc]"

	for(var/obj/machinery/atmospherics/pipe/manifold4w/P in world)
		if(!P.node1 || !P.node2 || !P.node3 || !P.node4)
			usr << "[P], [P.x], [P.y], [P.z], [P.loc.loc]"

// reference: /client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)

client
	proc/debug_variables(datum/D in world)
		set category = "Debug"
		set name = "View Variables"
		//set src in world


		var/title = ""
		var/body = ""

		if(!D)	return
		if(istype(D, /atom))
			var/atom/A = D
			title = "[A.name] (\ref[A]) = [A.type]"

			#ifdef VARSICON
			if (A.icon)
				body += debug_variable("icon", new/icon(A.icon, A.icon_state, A.dir), 0)
			#endif

		var/icon/sprite

		if(istype(D,/atom))
			var/atom/AT = D
			if(AT.icon && AT.icon_state)
				sprite = new /icon(AT.icon, AT.icon_state)
				usr << browse_rsc(sprite, "view_vars_sprite.png")

		title = "[D] (\ref[D]) = [D.type]"

		body += {"<script type="text/javascript">

					function updateSearch(){
						var filter_text = document.getElementById('filter');
						var filter = filter_text.value.toLowerCase();

						if(event.keyCode == 13){	//Enter / return
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");
							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.style.backgroundColor == "#ffee88" )
									{
										alist = lis\[i\].getElementsByTagName("a")
										if(alist.length > 0){
											location.href=alist\[0\].href;
										}
									}
								}catch(err) {   }
							}
							return
						}

						if(event.keyCode == 38){	//Up arrow
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");
							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.style.backgroundColor == "#ffee88" )
									{
										if( (i-1) >= 0){
											var li_new = lis\[i-1\];
											li.style.backgroundColor = "white";
											li_new.style.backgroundColor = "#ffee88";
											return
										}
									}
								}catch(err) {  }
							}
							return
						}

						if(event.keyCode == 40){	//Down arrow
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");
							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.style.backgroundColor == "#ffee88" )
									{
										if( (i+1) < lis.length){
											var li_new = lis\[i+1\];
											li.style.backgroundColor = "white";
											li_new.style.backgroundColor = "#ffee88";
											return
										}
									}
								}catch(err) {  }
							}
							return
						}

						//This part here resets everything to how it was at the start so the filter is applied to the complete list. Screw efficiency, it's client-side anyway and it only looks through 200 or so variables at maximum anyway (mobs).
						if(complete_list != null && complete_list != ""){
							var vars_ol1 = document.getElementById("vars");
							vars_ol1.innerHTML = complete_list
						}

						if(filter.value == ""){
							return;
						}else{
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");

							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.innerText.toLowerCase().indexOf(filter) == -1 )
									{
										vars_ol.removeChild(li);
										i--;
									}
								}catch(err) {   }
							}
						}
						var lis_new = vars_ol.getElementsByTagName("li");
						for ( var j = 0; j < lis_new.length; ++j )
						{
							var li1 = lis\[j\];
							if (j == 0){
								li1.style.backgroundColor = "#ffee88";
							}else{
								li1.style.backgroundColor = "white";
							}
						}
					}



					function selectTextField(){
						var filter_text = document.getElementById('filter');
						filter_text.focus();
						filter_text.select();

					}

					function loadPage(list) {

						if(list.options\[list.selectedIndex\].value == ""){
							return;
						}

						location.href=list.options\[list.selectedIndex\].value;

					}
				</script> "}

		body += "<body onload='selectTextField(); updateSearch()' onkeyup='updateSearch()'>"

		body += "<div align='center'><table width='100%'><tr><td width='50%'>"

		if(sprite)
			body += "<table align='center' width='100%'><tr><td><img src='view_vars_sprite.png'></td><td>"
		else
			body += "<table align='center' width='100%'><tr><td>"

		body += "<div align='center'>"

		if(istype(D,/atom))
			var/atom/A = D
			body += "<a href='byond://?src=\ref[src];datumedit=\ref[D];varnameedit=name'><b>[D]</b></a>"
			if(A.dir)
				body += "<br><font size='1'><a href='byond://?src=\ref[src];rotatedatum=\ref[D];rotatedir=left'><<</a> <a href='byond://?src=\ref[src];datumedit=\ref[D];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='byond://?src=\ref[src];rotatedatum=\ref[D];rotatedir=right'>>></a></font>"
			if(istype(A,/mob))
				var/mob/M = A
				body += "<br><font size='1'><a href='byond://?src=\ref[src];datumedit=\ref[D];varnameedit=ckey'>[M.ckey ? M.ckey : "No ckey"]</a> / <a href='byond://?src=\ref[src];datumedit=\ref[D];varnameedit=real_name'>[M.real_name ? M.real_name : "No real name"]</a></font>"
				body += {"
				<br><font size='1'>
				BRUTE:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["brute"]'>[M.getBruteLoss()]</a>
				FIRE:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["fire"]'>[M.getFireLoss()]</a>
				TOXIN:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["toxin"]'>[M.getToxLoss()]</a>
				OXY:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["oxygen"]'>[M.getOxyLoss()]</a>
				CLONE:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["clone"]'>[M.getCloneLoss()]</a>
				BRAIN:<font size='1'><a href='byond://?src=\ref[src];mobToDamage=\ref[D];adjustDamage=\ref["brain"]'>[M.getBrainLoss()]</a>
				</font>


				"}
		else
			body += "<b>[D]</b>"

		body += "</div>"

		body += "</tr></td></table>"

		var/formatted_type = text("[D.type]")
		if(length(formatted_type) > 25)
			var/middle_point = length(formatted_type) / 2
			var/splitpoint = findtext(formatted_type,"/",middle_point)
			if(splitpoint)
				formatted_type = "[copytext(formatted_type,1,splitpoint)]<br>[copytext(formatted_type,splitpoint)]"
			else
				formatted_type = "Type too long" //No suitable splitpoint (/) found.

		body += "<div align='center'><b><font size='1'>[formatted_type]</font></b>"

		if(src.holder && src.holder.marked_datum && src.holder.marked_datum == D)
			body += "<br><font size='1' color='red'><b>Marked Object</b></font>"

		body += "</div>"

		body += "</div></td>"

		body += "<td width='50%'><div align='center'><a href='byond://?src=\ref[src];datumrefresh=\ref[D]'>Refresh</a>"

		//if(ismob(D))
		//	body += "<br><a href='byond://?src=\ref[src];mob_player_panel=\ref[D]'>Show player panel</a></div></td></tr></table></div><hr>"

		body += {"	<form>
					<select name="file" size="1"
					onchange="loadPage(this.form.elements\[0\])"
					target="_parent._top"
					onmouseclick="this.focus()"
					style="background-color:#ffffff">
				"}

		body += {"	<option value>Select option</option>
  					<option value> </option>
				"}


		body += "<option value='byond://?src=\ref[src];mark_object=\ref[D]'>Mark Object</option>"
		if(ismob(D))
			body += "<option value='byond://?src=\ref[src];mob_player_panel=\ref[D]'>Show player panel</option>"

		body += "<option value>---</option>"

		if(ismob(D))
			body += "<option value='byond://?src=\ref[src];give_spell=\ref[D]'>Give Spell</option>"
			body += "<option value='byond://?src=\ref[src];ninja=\ref[D]'>Make Space Ninja</option>"
			body += "<option value='byond://?src=\ref[src];godmode=\ref[D]'>Toggle Godmode</option>"
			body += "<option value='byond://?src=\ref[src];build_mode=\ref[D]'>Toggle Build Mode</option>"
//			body += "<option value='byond://?src=\ref[src];direct_control=\ref[D]'>Assume Direct Control</option>"
			if(ishuman(D))
				body += "<option value>---</option>"
				body += "<option value='byond://?src=\ref[src];makeai=\ref[D]'>Make AI</option>"
				body += "<option value='byond://?src=\ref[src];makeaisilent=\ref[D]'>Make AI (Silently)</option>"
				body += "<option value='byond://?src=\ref[src];makerobot=\ref[D]'>Make cyborg</option>"
				body += "<option value='byond://?src=\ref[src];makemonkey=\ref[D]'>Make monkey</option>"
				body += "<option value='byond://?src=\ref[src];makealien=\ref[D]'>Make alien</option>"
				body += "<option value='byond://?src=\ref[src];makemetroid=\ref[D]'>Make metroid</option>"
			body += "<option value>---</option>"
			body += "<option value='byond://?src=\ref[src];gib=\ref[D]'>Gib</option>"
		if(isobj(D))
			body += "<option value='byond://?src=\ref[src];delall=\ref[D]'>Delete all of type</option>"
		if(isobj(D) || ismob(D) || isturf(D))
			body += "<option value='byond://?src=\ref[src];explode=\ref[D]'>Trigger explosion</option>"
			body += "<option value='byond://?src=\ref[src];emp=\ref[D]'>Trigger EM pulse</option>"

		body += "</select></form>"

		body += "</div></td></tr></table></div><hr>"

		body += "<font size='1'><b>E</b> - Edit, tries to determine the variable type by itself.<br>"
		body += "<b>C</b> - Change, asks you for the var type first.<br>"
		body += "<b>M</b> - Mass modify: changes this variable for all objects of this type.</font><br>"

		body += "<hr><table width='100%'><tr><td width='20%'><div align='center'><b>Search:</b></div></td><td width='80%'><input type='text' id='filter' name='filter_text' value='' style='width:100%;'></td></tr></table><hr>"

		body += "<ol id='vars'>"

		var/list/names = list()
		for (var/V in D.vars)
			names += V

		names = sortList(names)

		for (var/V in names)
			body += debug_variable(V, D.vars[V], 0, D)

		body += "</ol>"

		var/html = "<html><head>"
		if (title)
			html += "<title>[title]</title>"
		html += {"<style>
	body
	{
		font-family: Verdana, sans-serif;
		font-size: 9pt;
	}
	.value
	{
		font-family: "Courier New", monospace;
		font-size: 8pt;
	}
	</style>"}
		html += "</head><body>"
		html += body

		html += {"
			<script type='text/javascript'>
				var vars_ol = document.getElementById("vars");
				var complete_list = vars_ol.innerHTML;
			</script>
		"}

		html += "</body></html>"

		usr << browse(html, "window=variables\ref[D];size=475x650")

		return

	proc/debug_variable(name, value, level, var/datum/DA = null)
		var/html = ""

		if(DA)
			html += "<li style='backgroundColor:white'>(<a href='byond://?src=\ref[src];datumedit=\ref[DA];varnameedit=[name]'>E</a>) (<a href='byond://?src=\ref[src];datumchange=\ref[DA];varnamechange=[name]'>C</a>) (<a href='byond://?src=\ref[src];datummass=\ref[DA];varnamemass=[name]'>M</a>) "
		else
			html += "<li>"

		if (isnull(value))
			html += "[name] = <span class='value'>null</span>"

		else if (istext(value))
			html += "[name] = <span class='value'>\"[value]\"</span>"

		else if (isicon(value))
			#ifdef VARSICON
			var/icon/I = new/icon(value)
			var/rnd = rand(1,10000)
			var/rname = "tmp\ref[I][rnd].png"
			usr << browse_rsc(I, rname)
			html += "[name] = (<span class='value'>[value]</span>) <img class=icon src=\"[rname]\">"
			#else
			html += "[name] = /icon (<span class='value'>[value]</span>)"
			#endif

/*		else if (istype(value, /image))
			#ifdef VARSICON
			var/rnd = rand(1, 10000)
			var/image/I = value

			src << browse_rsc(I.icon, "tmp\ref[value][rnd].png")
			html += "[name] = <img src=\"tmp\ref[value][rnd].png\">"
			#else
			html += "[name] = /image (<span class='value'>[value]</span>)"
			#endif
*/
		else if (isfile(value))
			html += "[name] = <span class='value'>'[value]'</span>"

		else if (istype(value, /datum))
			var/datum/D = value
			html += "<a href='byond://?src=\ref[src];Vars=\ref[value]'>[name] \ref[value]</a> = [D.type]"

		else if (istype(value, /client))
			var/client/C = value
			html += "<a href='byond://?src=\ref[src];Vars=\ref[value]'>[name] \ref[value]</a> = [C] [C.type]"
	//
		else if (istype(value, /list))
			var/list/L = value
			html += "[name] = /list ([L.len])"

			if (L.len > 0 && !(name == "underlays" || name == "overlays" || name == "vars" || L.len > 500))
				// not sure if this is completely right...
				if(0)   //(L.vars.len > 0)
					html += "<ol>"
					html += "</ol>"
				else
					html += "<ul>"
					var/index = 1
					for (var/entry in L)
						if(istext(entry))
							html += debug_variable(entry, L[entry], level + 1)
						//html += debug_variable("[index]", L[index], level + 1)
						else
							html += debug_variable(index, L[index], level + 1)
						index++
					html += "</ul>"

		else
			html += "[name] = <span class='value'>[value]</span>"

		html += "</li>"

		return html

	Topic(href, href_list, hsrc)

		if (href_list["Vars"])
			debug_variables(locate(href_list["Vars"]))
		else if (href_list["varnameedit"])
			if(!href_list["datumedit"] || !href_list["varnameedit"])
				usr << "Varedit error: Not all information has been sent Contact a coder."
				return
			var/DAT = locate(href_list["datumedit"])
			if(!DAT)
				usr << "Item not found"
				return
			if(!istype(DAT,/datum) && !istype(DAT,/client))
				usr << "Can't edit an item of this type. Type must be /datum or /client, so anything except simple variables."
				return
			modify_variables(DAT, href_list["varnameedit"], 1)
		else if (href_list["varnamechange"])
			if(!href_list["datumchange"] || !href_list["varnamechange"])
				usr << "Varedit error: Not all information has been sent. Contact a coder."
				return
			var/DAT = locate(href_list["datumchange"])
			if(!DAT)
				usr << "Item not found"
				return
			if(!istype(DAT,/datum) && !istype(DAT,/client))
				usr << "Can't edit an item of this type. Type must be /datum or /client, so anything except simple variables."
				return
			modify_variables(DAT, href_list["varnamechange"], 0)
		else if (href_list["varnamemass"])
			if(!href_list["datummass"] || !href_list["varnamemass"])
				usr << "Varedit error: Not all information has been sent. Contact a coder."
				return
			var/atom/A = locate(href_list["datummass"])
			if(!A)
				usr << "Item not found"
				return
			if(!istype(A,/atom))
				usr << "Can't mass edit an item of this type. Type must be /atom, so an object, turf, mob or area. You cannot mass edit clients!"
				return
			cmd_mass_modify_object_variables(A, href_list["varnamemass"])
		else if (href_list["mob_player_panel"])
			if(!href_list["mob_player_panel"])
				return
			var/mob/MOB = locate(href_list["mob_player_panel"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			src.holder.show_player_panel(MOB)
			href_list["datumrefresh"] = href_list["mob_player_panel"]
		else if (href_list["give_spell"])
			if(!href_list["give_spell"])
				return
			var/mob/MOB = locate(href_list["give_spell"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			src.give_spell(MOB)
			href_list["datumrefresh"] = href_list["give_spell"]
		else if (href_list["ninja"])
			if(!href_list["ninja"])
				return
			var/mob/MOB = locate(href_list["ninja"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			src.cmd_admin_ninjafy(MOB)
			href_list["datumrefresh"] = href_list["ninja"]
		else if (href_list["godmode"])
			if(!href_list["godmode"])
				return
			var/mob/MOB = locate(href_list["godmode"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			src.cmd_admin_godmode(MOB)
			href_list["datumrefresh"] = href_list["godmode"]
		else if (href_list["gib"])
			if(!href_list["gib"])
				return
			var/mob/MOB = locate(href_list["gib"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			src.cmd_admin_gib(MOB)

		else if (href_list["build_mode"])
			if(!href_list["build_mode"])
				return
			var/mob/MOB = locate(href_list["build_mode"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return
			togglebuildmode(MOB)
			href_list["datumrefresh"] = href_list["build_mode"]

/*		else if (href_list["direct_control"])
			if(!href_list["direct_control"])
				return
			var/mob/MOB = locate(href_list["direct_control"])
			if(!MOB)
				return
			if(!ismob(MOB))
				return
			if(!src.holder)
				return

			if(usr.client)
				usr.client.cmd_assume_direct_control(MOB)*/

		else if (href_list["delall"])
			if(!href_list["delall"])
				return
			var/atom/A = locate(href_list["delall"])
			if(!A)
				return
			if(!isobj(A))
				usr << "This can only be used on objects (of type /obj)"
				return
			if(!A.type)
				return
			var/action_type = alert("Strict type ([A.type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(alert("Are you really sure you want to delete all objects of type [A.type]?",,"Yes","No") != "Yes")
				return
			if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
				return
			var/a_type = A.type
			if(action_type == "Strict type")
				var/i = 0
				for(var/obj/O in world)
					if(O.type == a_type)
						i++
						del(O)
				if(!i)
					usr << "No objects of this type exist"
					return
				log_admin("[key_name(usr)] deleted all objects of scrict type [a_type] ([i] objects deleted) ")
				message_admins("\blue [key_name(usr)] deleted all objects of scrict type [a_type] ([i] objects deleted) ", 1)
			else if(action_type == "Type and subtypes")
				var/i = 0
				for(var/obj/O in world)
					if(istype(O,a_type))
						i++
						del(O)
				if(!i)
					usr << "No objects of this type exist"
					return
				log_admin("[key_name(usr)] deleted all objects of scrict type with subtypes [a_type] ([i] objects deleted) ")
				message_admins("\blue [key_name(usr)] deleted all objects of type with subtypes [a_type] ([i] objects deleted) ", 1)

		else if (href_list["explode"])
			if(!href_list["explode"])
				return
			var/atom/A = locate(href_list["explode"])
			if(!A)
				return
			if(!isobj(A) && !ismob(A) && !isturf(A))
				return
			src.cmd_admin_explosion(A)
			href_list["datumrefresh"] = href_list["explode"]
		else if (href_list["emp"])
			if(!href_list["emp"])
				return
			var/atom/A = locate(href_list["emp"])
			if(!A)
				return
			if(!isobj(A) && !ismob(A) && !isturf(A))
				return
			src.cmd_admin_emp(A)
			href_list["datumrefresh"] = href_list["emp"]
		else if (href_list["mark_object"])
			if(!href_list["mark_object"])
				return
			var/datum/D = locate(href_list["mark_object"])
			if(!D)
				return
			if(!src.holder)
				return
			src.holder.marked_datum = D
			href_list["datumrefresh"] = href_list["mark_object"]
		else if (href_list["rotatedatum"])
			if(!href_list["rotatedir"])
				return
			var/atom/A = locate(href_list["rotatedatum"])
			if(!A)
				return
			if(!istype(A,/atom))
				usr << "This can only be done to objects of type /atom"
				return
			if(!src.holder)
				return
			switch(href_list["rotatedir"])
				if("right")
					A.dir = turn(A.dir, -45)
				if("left")
					A.dir = turn(A.dir, 45)
			href_list["datumrefresh"] = href_list["rotatedatum"]
		else if (href_list["makemonkey"])
			var/mob/M = locate(href_list["makemonkey"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("monkeyone"=href_list["makemonkey"]))
		else if (href_list["makerobot"])
			var/mob/M = locate(href_list["makerobot"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("makerobot"=href_list["makerobot"]))
		else if (href_list["makealien"])
			var/mob/M = locate(href_list["makealien"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("makealien"=href_list["makealien"]))
		else if (href_list["makemetroid"])
			var/mob/M = locate(href_list["makemetroid"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("makemetroid"=href_list["makemetroid"]))
		else if (href_list["makeai"])
			var/mob/M = locate(href_list["makeai"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("makeai"=href_list["makeai"]))
		else if (href_list["makeaisilent"])
			var/mob/M = locate(href_list["makeaisilent"])
			if(!M)
				return
			if(!ishuman(M))
				usr << "This can only be done to objects of type /mob/living/carbon/human"
				return
			if(!src.holder)
				usr << "You are not an administrator."
				return
			var/action_type = alert("Confirm mob type change?",,"Transform","Cancel")
			if(!action_type || action_type == "Cancel")
				return
			if(!M)
				usr << "Mob doesn't exist anymore"
				return
			holder.Topic(href, list("makeaisilent"=href_list["makeaisilent"]))
		else if (href_list["adjustDamage"] && href_list["mobToDamage"])
			var/mob/M = locate(href_list["mobToDamage"])
			var/Text = locate(href_list["adjustDamage"])

			var/amount =  input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num
			if(Text == "brute")
				M.adjustBruteLoss(amount)
			else if(Text == "fire")
				M.adjustFireLoss(amount)
			else if(Text == "toxin")
				M.adjustToxLoss(amount)
			else if(Text == "oxygen")
				M.adjustOxyLoss(amount)
			else if(Text == "brain")
				M.adjustBrainLoss(amount)
			else if(Text == "clone")
				M.adjustCloneLoss(amount)
			else
				usr << "You caused an error. DEBUG: Text:[Text] Mob:[M]"
				return

			if(amount != 0)
				log_admin("[key_name(usr)] dealt [amount] amount of [Text] damage to [M] ")
				message_admins("\blue [key_name(usr)] dealt [amount] amount of [Text] damage to [M] ", 1)
				href_list["datumrefresh"] = href_list["mobToDamage"]
		else
			..()


		if (href_list["datumrefresh"])
			if(!href_list["datumrefresh"])
				return
			var/datum/DAT = locate(href_list["datumrefresh"])
			if(!DAT)
				return
			if(!istype(DAT,/datum))
				return
			src.debug_variables(DAT)

/client/proc/changeling_absorb_dna()
	set category = "Changeling"
	set name = "Absorb DNA"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if (!istype(usr.equipped(), /obj/item/weapon/grab))
		usr << "\red We must be grabbing a creature in our active hand to absorb them."
		return

	var/obj/item/weapon/grab/G = usr.equipped()
	var/mob/M = G.affecting

	if (!ishuman(M))
		usr << "\red This creature is not compatible with our biology."
		return

	if (M.mutations2 & NOCLONE)
		usr << "\red This creature's DNA is ruined beyond useability!"
		return

	if (!G.killing)
		usr << "\red We must have a tighter grip to absorb this creature."
		return

	if (usr.changeling.isabsorbing)
		usr << "\red We are already absorbing!"
		return



	var/mob/living/carbon/human/T = M

	usr << "\blue This creature is compatible. We must hold still..."
	usr.changeling.isabsorbing = 1
	if (!do_mob(usr, T, 150))
		usr << "\red Our absorption of [T] has been interrupted!"
		usr.changeling.isabsorbing = 0
		return

	usr << "\blue We extend a proboscis."
	usr.visible_message(text("\red <B>[usr] extends a proboscis!</B>"))

	if (!do_mob(usr, T, 150))
		usr << "\red Our absorption of [T] has been interrupted!"
		usr.changeling.isabsorbing = 0
		return

	usr << "\blue We stab [T] with the proboscis."
	usr.visible_message(text("\red <B>[usr] stabs [T] with the proboscis!</B>"))
	T << "\red <B>You feel a sharp stabbing pain!</B>"
	T.take_overall_damage(40)

	if (!do_mob(usr, T, 150))
		usr << "\red Our absorption of [T] has been interrupted!"
		usr.changeling.isabsorbing = 0
		return

	usr << "\blue We have absorbed [T]!"
	usr.visible_message(text("\red <B>[usr] sucks the fluids from [T]!</B>"))
	T << "\red <B>You have been absorbed by the changeling!</B>"

	usr.changeling.absorbed_dna[T.real_name] = T.dna
	if(usr.nutrition < 400) usr.nutrition = min((usr.nutrition + T.nutrition), 400)
	usr.changeling.chem_charges += 10
	usr.changeling.geneticpoints += 2
	if(T.changeling)
		if(T.changeling.absorbed_dna)
			usr.changeling.absorbed_dna |= T.changeling.absorbed_dna //steal all their loot

			T.changeling.absorbed_dna = list()
			T.changeling.absorbed_dna[T.real_name] = T.dna

		if(T.changeling.purchasedpowers)
			for(var/obj/effect/proc_holder/power/Tp in T.changeling.purchasedpowers)
				if(Tp in usr.changeling.purchasedpowers)
					continue
				else
					usr.changeling.purchasedpowers += Tp

					if(!Tp.isVerb)
						call(Tp.verbpath)()

					else
						if(usr.changeling.changeling_level == 1)
							usr.make_lesser_changeling()
						else
							usr.make_changeling()




		usr.changeling.chem_charges += T.changeling.chem_charges
		usr.changeling.geneticpoints += T.changeling.geneticpoints
		T.changeling.chem_charges = 0
	usr.changeling.isabsorbing = 0

	T.death(0)
	T.Drain()

	return

/client/proc/changeling_transform()
	set category = "Changeling"
	set name = "Transform (5)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if (usr.changeling.absorbed_dna.len <= 0)
		usr << "\red We have not yet absorbed any compatible DNA."
		return

	if(usr.changeling.chem_charges < 5)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in usr.changeling.absorbed_dna

	if (S == null)
		return

	usr.changeling.chem_charges -= 5

	usr.visible_message(text("\red <B>[usr] transforms!</B>"))

	usr.dna = usr.changeling.absorbed_dna[S]
	usr.real_name = S
	updateappearance(usr, usr.dna.uni_identity)
	domutcheck(usr, null)

	usr.verbs -= /client/proc/changeling_transform

	spawn(10)
		usr.verbs += /client/proc/changeling_transform

	return

/client/proc/changeling_lesser_form()
	set category = "Changeling"
	set name = "Lesser Form (1)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if(usr.changeling.chem_charges < 1)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	if(usr.changeling.geneticdamage != 0)
		usr << "Our genes are still mending themselves!  We cannot transform!"
		return

	usr.changeling.chem_charges--

	usr.remove_changeling_powers()

	usr.visible_message(text("\red <B>[usr] transforms!</B>"))

	usr.changeling.geneticdamage = 30
	usr << "Our genes cry out!"

	var/list/implants = list() //Try to preserve implants.
	for(var/obj/item/weapon/W in usr)
		if (istype(W, /obj/item/weapon/implant))
			implants += W

	usr.update_clothing()
	usr.monkeyizing = 1
	usr.canmove = 0
	usr.icon = null
	usr.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( usr.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	del(animation)

	var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey(src)
	O.dna = usr.dna
	usr.dna = null
	O.changeling = usr.changeling

	for(var/obj/item/W in usr)
		usr.drop_from_slot(W)


	for(var/obj/T in usr)
		del(T)
	//for(var/R in usr.organs) //redundant, let's give garbage collector work to do --rastaf0
	//	del(usr.organs[text("[]", R)])

	O.loc = usr.loc

	O.name = text("monkey ([])",copytext(md5(usr.real_name), 2, 6))
	O.setToxLoss(usr.getToxLoss())
	O.adjustBruteLoss(usr.getBruteLoss())
	O.setOxyLoss(usr.getOxyLoss())
	O.adjustFireLoss(usr.getFireLoss())
	O.stat = usr.stat
	O.a_intent = "hurt"
	for (var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O
		continue

	if(usr.mind)
		usr.mind.transfer_to(O)

	O.make_lesser_changeling()
	O.verbs += /client/proc/changeling_lesser_transform
	del(usr)
	return

/client/proc/changeling_lesser_transform()
	set category = "Changeling"
	set name = "Transform (1)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if (usr.changeling.absorbed_dna.len <= 0)
		usr << "\red We have not yet absorbed any compatible DNA."
		return

	if(usr.changeling.chem_charges < 1)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	var/S = input("Select the target DNA: ", "Target DNA", null) in usr.changeling.absorbed_dna

	if (S == null)
		return

	usr.changeling.chem_charges -= 1

	usr.remove_changeling_powers()

	usr.visible_message(text("\red <B>[usr] transforms!</B>"))

	usr.dna = usr.changeling.absorbed_dna[S]

	var/list/implants = list()
	for (var/obj/item/weapon/implant/I in usr) //Still preserving implants
		implants += I

	usr.update_clothing()
	usr.monkeyizing = 1
	usr.canmove = 0
	usr.icon = null
	usr.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( usr.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("monkey2h", animation)
	sleep(48)
	del(animation)

	for(var/obj/item/W in usr)
		usr.u_equip(W)
		if (usr.client)
			usr.client.screen -= W
		if (W)
			W.loc = usr.loc
			W.dropped(usr)
			W.layer = initial(W.layer)

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )
	if (isblockon(getblock(usr.dna.uni_identity, 11,3),11))
		O.gender = FEMALE
	else
		O.gender = MALE
	O.dna = usr.dna
	usr.dna = null
	O.changeling = usr.changeling
	O.real_name = S

	for(var/obj/T in usr)
		del(T)

	O.loc = usr.loc

	updateappearance(O,O.dna.uni_identity)
	domutcheck(O, null)
	O.setToxLoss(usr.getToxLoss())
	O.adjustBruteLoss(usr.getBruteLoss())
	O.setOxyLoss(usr.getOxyLoss())
	O.adjustFireLoss(usr.getFireLoss())
	O.stat = usr.stat
	for (var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O
		continue

	if(usr.mind)
		usr.mind.transfer_to(O)

	O.make_changeling()

	del(usr)
	return

/client/proc/changeling_fakedeath()
	set category = "Changeling"
	set name = "Regenerative Stasis (20)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.changeling.chem_charges < 20)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges -= 20

	usr << "\blue We will regenerate our form."

	usr.lying = 1
	usr.canmove = 0
	usr.changeling.changeling_fakedeath = 1
	usr.remove_changeling_powers()

	usr.emote("gasp")

	spawn(1200)
		usr.stat = 0
		//usr.fireloss = 0
		usr.setToxLoss(0)
		//usr.bruteloss = 0
		usr.setOxyLoss(0)
		usr.setCloneLoss(0)
		usr.SetParalysis(0)
		usr.SetStunned(0)
		usr.SetWeakened(0)
		usr.radiation = 0
		//usr.health = 100
		//usr.updatehealth()
		var/mob/living/M = src
		M.heal_overall_damage(M.getBruteLoss(), M.getFireLoss())
		usr.reagents.clear_reagents()
		usr.lying = 0
		usr.canmove = 1
		usr << "\blue We have regenerated."
		usr.visible_message(text("\red <B>[usr] appears to wake from the dead, having healed all wounds.</B>"))

		usr.changeling.changeling_fakedeath = 0
		if (usr.changeling.changeling_level == 1)
			usr.make_lesser_changeling()
		else if (usr.changeling.changeling_level == 2)
			usr.make_changeling()

	return

/client/proc/changeling_boost_range()
	set category = "Changeling"
	set name = "Ranged Sting (10)"
	set desc="Your next sting ability can be used against targets 2 squares away."

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if(usr.changeling.chem_charges < 10)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges -= 10

	usr << "\blue Your throat adjusts to launch the sting."
	usr.changeling.sting_range = 2

	usr.verbs -= /client/proc/changeling_boost_range

	spawn(5)
		usr.verbs += /client/proc/changeling_boost_range

	return

/client/proc/changeling_silence_sting()
	set category = "Changeling"
	set name = "Silence sting (10)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims
	if(T && T in view(usr.changeling.sting_range))

		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 10)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 10
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
		//	T << "You feel a small prick and a burning sensation in your throat."
			T.silent += 30
		//else
		//	T << "You feel a small prick."

		usr.verbs -= /client/proc/changeling_silence_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_silence_sting

		return

/client/proc/changeling_blind_sting()
	set category = "Changeling"
	set name = "Blind sting (20)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims
	if(T && T in view(usr.changeling.sting_range))
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 20)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 20
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		var/obj/effect/overlay/B = new /obj/effect/overlay( T.loc )
		B.icon_state = "blspell"
		B.icon = 'icons/obj/wizard.dmi'
		B.name = "spell"
		B.anchored = 1
		B.density = 0
		B.layer = 4
		T.canmove = 0
		spawn(5)
			del(B)
			T.canmove = 1

		if(!T.changeling)
			T << text("\blue Your eyes cry out in pain!")
			T.disabilities |= 1
			spawn(300)
				T.disabilities &= ~1
			T.eye_blind = 10
			T.eye_blurry = 20

		usr.verbs -= /client/proc/changeling_blind_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_blind_sting

		return

/client/proc/changeling_deaf_sting()
	set category = "Changeling"
	set name = "Deaf sting (5)"
	set desc="Sting target:"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 5)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 5
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
			T.disabilities |= 32
			spawn(300)
				T.disabilities &= ~32

		usr.verbs -= /client/proc/changeling_deaf_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_deaf_sting

		return

/client/proc/changeling_paralysis_sting()
	set category = "Changeling"
	set name = "Paralysis sting (30)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))

		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 30)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 30
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
			T << "You feel a small prick and a burning sensation."

			if (T.reagents)
				T.reagents.add_reagent("zombiepowder", 20)
		else
			T << "You feel a small prick."

		usr.verbs -= /client/proc/changeling_paralysis_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_paralysis_sting

		return

/client/proc/changeling_transformation_sting()
	set category = "Changeling"
	set name = "Transformation sting (30)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 30)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		if(T.stat != 2 || (T.mutations & HUSK) || (!ishuman(T) && !ismonkey(T)))
			usr << "\red We can't transform that target!"
			return

		var/S = input("Select the target DNA: ", "Target DNA", null) in usr.changeling.absorbed_dna

		if (S == null)
			return

		usr.changeling.chem_charges -= 30
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
			T.visible_message(text("\red <B>[T] transforms!</B>"))

			T.dna = usr.changeling.absorbed_dna[S]
			T.real_name = S
			updateappearance(T, T.dna.uni_identity)
			domutcheck(T, null)

		usr.verbs -= /client/proc/changeling_transformation_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_transformation_sting

		return

/client/proc/changeling_unfat_sting()
	set category = "Changeling"
	set name = "Unfat sting (5)"
	set desc = "Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 5)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 5
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
			T << "You feel a small prick and a burning sensation."
			T.overeatduration = 0
			T.nutrition -= 100
		else
			T << "You feel a small prick."

		usr.verbs -= /client/proc/changeling_unfat_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_unfat_sting

	return

/client/proc/changeling_unstun()
	set category = "Changeling"
	set name = "Epinephrine Sacs (45)"
	set desc = "Removes all stuns"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.changeling.chem_charges < 45)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges -= 45

	var/mob/living/carbon/human/C = usr

	if(C)
		C.stat = 0
		C.SetParalysis(0)
		C.SetStunned(0)
		C.SetWeakened(0)
		C.lying = 0
		C.canmove = 1

	usr.verbs -= /client/proc/changeling_unstun

	spawn(5)
		usr.verbs += /client/proc/changeling_unstun



/client/proc/changeling_fastchemical()

	usr.changeling.chem_recharge_multiplier = usr.changeling.chem_recharge_multiplier*2

/client/proc/changeling_engorgedglands()

	usr.changeling.chem_storage = usr.changeling.chem_storage+25

/client/proc/changeling_digitalcamo()
	set category = "Changeling"
	set name = "Toggle Digital Camoflague (10)"
	set desc = "The AI can no longer track us, but we will look different if examined.  Has a constant cost while active."

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.changeling.chem_charges < 10)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges -= 10

	var/mob/living/carbon/human/C = usr

	if(C)
		C << "[C.digitalcamo ? "We return to normal." : "We distort our form."]"
		C.digitalcamo = !C.digitalcamo
		spawn(0)
			while(C && C.digitalcamo)
				C.changeling.chem_charges -= 1/4
				sleep(10)


	usr.verbs -= /client/proc/changeling_digitalcamo

	spawn(5)
		usr.verbs += /client/proc/changeling_digitalcamo


/client/proc/changeling_DEATHsting()
	set category = "Changeling"
	set name = "Death Sting (40)"
	set desc = "Causes spasms onto death."

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))

		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 40)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 40
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
			T << "You feel a small prick and your chest becomes tight."

			T.silent = (10)
			T.Paralyse(10)
			T.make_jittery(1000)

			if (T.reagents)
				T.reagents.add_reagent("lexorin", 40)

		else
			T << "You feel a small prick."

		usr.verbs -= /client/proc/changeling_DEATHsting

		spawn(5)
			usr.verbs += /client/proc/changeling_DEATHsting

		return



/client/proc/changeling_rapidregen()
	set category = "Changeling"
	set name = "Rapid Regeneration (30)"
	set desc = "Begins rapidly regenerating.  Does not effect stuns or chemicals."

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.changeling.chem_charges < 30)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges -= 30

	var/mob/living/carbon/human/C = usr

	spawn(0)
		for(var/i = 0, i<10,i++)
			if(C)
				C.adjustBruteLoss(-10)
				C.adjustToxLoss(-10)
				C.adjustOxyLoss(-10)
				C.adjustFireLoss(-10)
				sleep(10)


	usr.verbs -= /client/proc/changeling_rapidregen

	spawn(5)
		usr.verbs += /client/proc/changeling_rapidregen




/client/proc/changeling_lsdsting()
	set category = "Changeling"
	set name = "Hallucination Sting (15)"
	set desc = "Causes terror in the target."

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))

		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 15)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 15
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."

		if(!T.changeling)
		//	T << "You feel a small prick." // No warning.

			var/timer = rand(300,600)

			spawn(timer)
				if(T)
					if(T.reagents)
					//	T.reagents.add_reagent("LSD", 50) // Slight overkill, it seems.
						T.hallucination = 400


		usr.verbs -= /client/proc/changeling_lsdsting

		spawn(5)
			usr.verbs += /client/proc/changeling_lsdsting

		return
/client/proc/fireproof_core()
	set category = "Malfunction"
	set name = "Fireproof Core"
	for(var/mob/living/silicon/ai/ai in world)
		ai.fire_res_on_core = 1
	usr.verbs -= /client/proc/fireproof_core
	usr << "\red Core fireproofed."

/client/proc/upgrade_turrets()
	set category = "Malfunction"
	set name = "Upgrade Turrets"
	usr.verbs -= /client/proc/upgrade_turrets
	for(var/obj/machinery/turret/turret in world)
		turret.health += 30
		turret.shot_delay = 20

/client/proc/disable_rcd()
	set category = "Malfunction"
	set name = "Disable RCDs"
	for(var/datum/AI_Module/large/disable_rcd/rcdmod in usr:current_modules)
		if(rcdmod.uses > 0)
			rcdmod.uses --
			for(var/obj/item/weapon/rcd/rcd in world)
				rcd.disabled = 1
			for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in world)
				rcd.disabled = 1
			usr << "RCD-disabling pulse emitted."
		else usr << "Out of uses."

/client/proc/overload_machine(obj/machinery/M as obj in world)
	set name = "Overload Machine"
	set category = "Malfunction"
	if (istype(M, /obj/machinery))
		for(var/datum/AI_Module/small/overload_machine/overload in usr:current_modules)
			if(overload.uses > 0)
				overload.uses --
				for(var/mob/V in hearers(M, null))
					V.show_message("\blue You hear a loud electrical buzzing sound!", 2)
				spawn(50)
					explosion(get_turf(M), 0,1,1,0)
					del(M)
			else usr << "Out of uses."
	else usr << "That's not a machine."

/client/proc/blackout()
	set category = "Malfunction"
	set name = "Blackout"
	for(var/datum/AI_Module/small/blackout/blackout in usr:current_modules)
		if(blackout.uses > 0)
			blackout.uses --
			for(var/obj/machinery/power/apc/apc in world)
				if(prob(30*apc.overload))
					apc.overload_lighting()
				else apc.overload++
		else usr << "Out of uses."

/client/proc/interhack()
	set category = "Malfunction"
	set name = "Hack intercept"
	usr.verbs -= /client/proc/interhack
	ticker.mode:hack_intercept()

/client/proc/reactivate_camera(obj/machinery/camera/C as obj in world)
	set name = "Reactivate Camera"
	set category = "Malfunction"
	if (istype (C, /obj/machinery/camera))
		for(var/datum/AI_Module/small/reactivate_camera/camera in usr:current_modules)
			if(camera.uses > 0)
				if(!C.status)
					C.status = !C.status
					camera.uses --
					for(var/mob/V in viewers(src, null))
						V.show_message(text("\blue You hear a quiet click."))
				else
					usr << "This camera is either active, or not repairable."
			else usr << "Out of uses."
	else usr << "That's not a camera."




/client/proc/rightandwrong()
	set category = "Spells"
	set desc = "Summon Guns"
	set name = "Wizards: No sense of right and wrong!"

	for(var/mob/living/carbon/human/H in world)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue
		if(prob(25))
			ticker.mode.traitors += H.mind
			H.mind.special_role = "traitor"
			var/datum/objective/survive/survive = new
			survive.owner = H.mind
			H.mind.objectives += survive
			H << "<B>You are the survivor! Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...</B>"
			var/obj_count = 1
			for(var/datum/objective/OBJ in H.mind.objectives)
				H << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
				obj_count++
		var/randomize = pick("taser","egun","laser","revolver","smg","decloner","deagle","gyrojet","pulse","silenced","cannon","shotgun","freeze","uzi","crossbow")
		switch (randomize)
			if("taser")
				new /obj/item/weapon/gun/energy/taser(get_turf(H))
			if("egun")
				new /obj/item/weapon/gun/energy(get_turf(H))
			if("laser")
				new /obj/item/weapon/gun/energy/laser(get_turf(H))
			if("revolver")
				new /obj/item/weapon/gun/projectile(get_turf(H))
			if("smg")
				new /obj/item/weapon/gun/projectile/automatic/c20r(get_turf(H))
			if("decloner")
				new /obj/item/weapon/gun/energy/decloner(get_turf(H))
			if("deagle")
				new /obj/item/weapon/gun/projectile/deagle/camo(get_turf(H))
			if("gyrojet")
				new /obj/item/weapon/gun/projectile/gyropistol(get_turf(H))
			if("pulse")
				new /obj/item/weapon/gun/energy/pulse_rifle(get_turf(H))
			if("silenced")
				new /obj/item/weapon/gun/projectile/silenced(get_turf(H))
			if("cannon")
				new /obj/item/weapon/gun/energy/lasercannon(get_turf(H))
			if("shotgun")
				new /obj/item/weapon/gun/projectile/shotgun/combat(get_turf(H))
			if("freeze")
				new /obj/item/weapon/gun/energy/temperature(get_turf(H))
			if("uzi")
				new /obj/item/weapon/gun/projectile/automatic/mini_uzi(get_turf(H))
			if("crossbow")
				new /obj/item/weapon/gun/energy/crossbow(get_turf(H))
	usr.verbs -= /client/proc/rightandwrong

//BLIND

/client/proc/blind()
	set category = "Spells"
	set name = "Blind"
	set desc = "This spell temporarly blinds a single person and does not require wizard garb."

	var/mob/M = input(usr, "Who do you wish to blind?") as mob in oview()

	if(M)
		if(usr.stat)
			src << "Not when you are incapacitated."
			return
	//	if(!usr.casting()) return
		usr.verbs -= /client/proc/blind
		spawn(300)
			usr.verbs += /client/proc/blind

		usr.whisper("STI KALY")
	//	usr.spellvoice()

		var/obj/effect/overlay/B = new /obj/effect/overlay( M.loc )
		B.icon_state = "blspell"
		B.icon = 'icons/obj/wizard.dmi'
		B.name = "spell"
		B.anchored = 1
		B.density = 0
		B.layer = 4
		M.canmove = 0
		spawn(5)
			del(B)
			M.canmove = 1
		M << text("\blue Your eyes cry out in pain!")
		M.disabilities |= 1
		spawn(300)
			M.disabilities &= ~1
		M.eye_blind = 10
		M.eye_blurry = 20
		return

//MAGIC MISSILE

/client/proc/magicmissile()
	set category = "Spells"
	set name = "Magic missile"
	set desc = "This spell fires several, slow moving, magic projectiles at nearby targets."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return

	usr.say("FORTI GY AMA")
	usr.spellvoice()

	for (var/mob/living/M as mob in oview())
		spawn(0)
			var/obj/effect/overlay/A = new /obj/effect/overlay( usr.loc )
			A.icon_state = "magicm"
			A.icon = 'icons/obj/wizard.dmi'
			A.name = "a magic missile"
			A.anchored = 0
			A.density = 0
			A.layer = 4
			var/i
			for(i=0, i<20, i++)
				if (!istype(M)) //it happens sometimes --rastaf0
					break
				var/obj/effect/overlay/B = new /obj/effect/overlay( A.loc )
				B.icon_state = "magicmd"
				B.icon = 'icons/obj/wizard.dmi'
				B.name = "trail"
				B.anchored = 1
				B.density = 0
				B.layer = 3
				spawn(5)
					del(B)
				step_to(A,M,0)
				if (get_dist(A,M) == 0)
					M.Weaken(5)
					M.take_overall_damage(0,10)
					del(A)
					return
				sleep(5)
			del(A)

	usr.verbs -= /client/proc/magicmissile
	spawn(100)
		usr.verbs += /client/proc/magicmissile

//SMOKE

/client/proc/smokecloud()

	set category = "Spells"
	set name = "Smoke"
	set desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
//	if(!usr.casting()) return
	usr.verbs -= /client/proc/smokecloud
	spawn(120)
		usr.verbs += /client/proc/smokecloud
	var/datum/effect/effect/system/bad_smoke_spread/smoke = new /datum/effect/effect/system/bad_smoke_spread()
	smoke.set_up(10, 0, usr.loc)
	smoke.start()


//SLEEP SMOKE

///client/proc/smokecloud()
//
//	set category = "Spells"
//	set name = "Sleep Smoke"
//	set desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb. But, without the robes, you have no protection against the magic."
//	if(usr.stat)
//		src << "Not when you are incapacitated."
//		return
//	if(!usr.casting()) return
//	usr.verbs -= /client/proc/smokecloud
//	spawn(120)
//		usr.verbs += /client/proc/smokecloud
//	var/datum/effect/system/sleep_smoke_spread/smoke = new /datum/effect/system/sleep_smoke_spread()
//	smoke.set_up(10, 0, usr.loc)
//	smoke.start()

//FORCE WALL

/client/proc/forcewall()

	set category = "Spells"
	set name = "Forcewall"
	set desc = "This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
//	if(!usr.casting()) return

	usr.verbs -= /client/proc/forcewall
	spawn(100)
		usr.verbs += /client/proc/forcewall
	var/forcefield

	usr.whisper("TARCOL MINTI ZHERI")
//	usr.spellvoice()

	forcefield =  new /obj/effect/forcefield(locate(usr.x,usr.y,usr.z))
	spawn (300)
		del (forcefield)
	return

//FIREBALLAN

/client/proc/fireball(mob/living/T as mob in oview())
	set category = "Spells"
	set name = "Fireball"
	set desc = "This spell fires a fireball at a target and does not require wizard garb."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
//	if(!usr.casting()) return

	usr.verbs -= /client/proc/fireball
	spawn(200)
		usr.verbs += /client/proc/fireball

	usr.say("ONI SOMA")
	//	usr.spellvoice()

	var/obj/effect/overlay/A = new /obj/effect/overlay( usr.loc )
	A.icon_state = "fireball"
	A.icon = 'icons/obj/wizard.dmi'
	A.name = "a fireball"
	A.anchored = 0
	A.density = 0
	var/i
	for(i=0, i<100, i++)
		step_to(A,T,0)
		if (get_dist(A,T) <= 1)
			T.take_overall_damage(20,25)
			explosion(T.loc, -1, -1, 2, 2)
			del(A)
			return
		sleep(2)
	del(A)
	return

//KNOCK

/client/proc/knock()
	set category = "Spells"
	set name = "Knock"
	set desc = "This spell opens nearby doors and does not require wizard garb."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
//	if(!usr.casting()) return
	usr.verbs -= /client/proc/knock
	spawn(100)
		usr.verbs += /client/proc/knock

	usr.whisper("AULIE OXIN FIERA")
//	usr.spellvoice()

	for(var/obj/machinery/door/G in oview(3))
		spawn(1)
			G.open()
	return

//KILL

/*
/mob/proc/kill(mob/living/M as mob in oview(1))
	set category = "Spells"
	set name = "Disintegrate"
	set desc = "This spell instantly kills somebody adjacent to you with the vilest of magick."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	usr.verbs -= /mob/proc/kill
	spawn(600)
		usr.verbs += /mob/proc/kill

	usr.say("EI NATH")
	usr.spellvoice()

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(4, 1, M)
	s.start()

	M.dust()
*/

//DISABLE TECH

/client/proc/blink()
	set category = "Spells"
	set name = "Blink"
	set desc = "This spell randomly teleports you a short distance."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	var/list/turfs = new/list()
	for(var/turf/T in orange(6))
		if(istype(T,/turf/space)) continue
		if(T.density) continue
		if(T.x>world.maxx-4 || T.x<4)	continue	//putting them at the edge is dumb
		if(T.y>world.maxy-4 || T.y<4)	continue
		turfs += T
	if(!turfs.len) turfs += pick(/turf in orange(6))
	var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
	smoke.set_up(10, 0, usr.loc)
	smoke.start()
	var/turf/picked = pick(turfs)
	if(!isturf(picked)) return
	usr.loc = picked
	usr.verbs -= /client/proc/blink
	spawn(40)
		usr.verbs += /client/proc/blink

//TELEPORT

/client/proc/jaunt()
	set category = "Spells"
	set name = "Ethereal Jaunt"
	set desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	usr.verbs -= /client/proc/jaunt
	spawn(300)
		usr.verbs += /client/proc/jaunt
	spell_jaunt(usr)

/client/proc/mutate()
	set category = "Spells"
	set name = "Mutate"
	set desc = "This spell causes you to turn into a hulk and gain laser vision for a short while."
	if(usr.stat)
		src << "Not when you are incapacitated."
		return
	if(!usr.casting()) return
	usr.verbs -= /client/proc/mutate
	spawn(400)
		usr.verbs += /client/proc/mutate

	usr.say("BIRUZ BENNAR")
	usr.spellvoice()

	usr << text("\blue You feel strong! You feel pressure building behind your eyes!")
	if (!(usr.mutations & HULK))
		usr.mutations |= HULK
	if (!(usr.mutations & LASER))
		usr.mutations |= LASER
	spawn (300)
		if (usr.mutations & LASER) usr.mutations &= ~LASER
		if (usr.mutations & HULK) usr.mutations &= ~HULK
	return

//BODY SWAP /N

