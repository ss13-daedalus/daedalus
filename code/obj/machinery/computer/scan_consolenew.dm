/obj/machinery/computer/scan_consolenew/New()
	..()
	spawn(5)
		src.connected = locate(/obj/machinery/dna_scannernew, get_step(src, WEST))
		spawn(250)
			src.injectorready = 1
		return
	return

/obj/machinery/computer/scan_consolenew/attackby(obj/item/W as obj, mob/user as mob)
	if ((istype(W, /obj/item/weapon/disk/data)) && (!src.diskette))
		user.drop_item()
		W.loc = src
		src.diskette = W
		user << "You insert [W]."
		src.updateUsrDialog()

/obj/machinery/computer/scan_consolenew/process() //not really used right now
	processing_objects.Remove(src) //Lets not have it waste CPU
	if(stat & (NOPOWER|BROKEN))
		return
	if (!( src.status )) //remove this
		return
	return

/obj/machinery/computer/scan_consolenew/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/scan_consolenew/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/scan_consolenew/attack_hand(user as mob)
	if(..())
		return
	if(!(user in message))
		user << "\blue This machine looks extremely complex. You'd probably need a decent knowledge of Genetics to understand it."
		message += user
	var/dat
	if (src.delete && src.temphtml) //Window in buffer but its just simple message, so nothing
		src.delete = src.delete

	else if (!src.delete && src.temphtml) //Window in buffer - its a menu, dont add clear message
		dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>Main Menu</A>", src.temphtml, src)
	else
		if (src.connected) //Is something connected?
			var/mob/occupant = src.connected.occupant
			dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>" //Blah obvious
			if(occupant && occupant.dna) //is there REALLY someone in there?
				if(occupant.mutations2 & NOCLONE)
					dat += "The occupant's DNA structure is ruined beyond recognition, please insert a subject with an intact DNA structure.<BR><BR>" //NOPE. -Pete
					dat += text("<A href='?src=\ref[];buffermenu=1'>View/Edit/Transfer Buffer</A><BR><BR>", src)
					dat += text("<A href='?src=\ref[];radset=1'>Radiation Emitter Settings</A><BR><BR>", src)
				else
					if (!istype(occupant,/mob/living/carbon/human))
						sleep(1)
					var/t1
					switch(occupant.stat) // obvious, see what their status is
						if(0)
							t1 = "Conscious"
						if(1)
							t1 = "Unconscious"
						else
							t1 = "*dead*"
					dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
					dat += text("<font color='green'>Radiation Level: []%</FONT><BR><BR>", occupant.radiation)
					dat += text("Unique Enzymes : <font color='blue'>[]</FONT><BR>", uppertext(occupant.dna.unique_enzymes))
					dat += text("Unique Identifier: <font color='blue'>[]</FONT><BR>", occupant.dna.uni_identity)
					dat += text("Structural Enzymes: <font color='blue'>[]</FONT><BR><BR>", occupant.dna.struc_enzymes)
					dat += text("<A href='?src=\ref[];unimenu=1'>Modify Unique Identifier</A><BR>", src)
					dat += text("<A href='?src=\ref[];strucmenu=1'>Modify Structural Enzymes</A><BR><BR>", src)
					dat += text("<A href='?src=\ref[];buffermenu=1'>View/Edit/Transfer Buffer</A><BR><BR>", src)
					dat += text("<A href='?src=\ref[];genpulse=1'>Pulse Radiation</A><BR>", src)
					dat += text("<A href='?src=\ref[];radset=1'>Radiation Emitter Settings</A><BR><BR>", src)
					dat += text("<A href='?src=\ref[];rejuv=1'>Inject Rejuvenators</A><BR><BR>", src)
			else
				dat += "The scanner is empty.<BR><BR>"
				dat += text("<A href='?src=\ref[];buffermenu=1'>View/Edit/Transfer Buffer</A><BR><BR>", src)
				dat += text("<A href='?src=\ref[];radset=1'>Radiation Emitter Settings</A><BR><BR>", src)
			if (!( src.connected.locked ))
				dat += text("<A href='?src=\ref[];locked=1'>Lock (Unlocked)</A><BR>", src)
			else
				dat += text("<A href='?src=\ref[];locked=1'>Unlock (Locked)</A><BR>", src)
				//Other stuff goes here
			if (!isnull(src.diskette))
				dat += text("<A href='?src=\ref[];eject_disk=1'>Eject Disk</A><BR>", src)
			dat += text("<BR><BR><A href='?src=\ref[];mach_close=scannernew'>Close</A>", user)
		else
			dat = "<font color='red'> Error: No DNA Modifier connected. </FONT>"
	user << browse(dat, "window=scannernew;size=700x625")
	onclose(user, "scannernew")
	return

/obj/machinery/computer/scan_consolenew/Topic(href, href_list)
	if(..())
		return
	if(!istype(usr.loc, /turf))
		return
	if ((usr.contents.Find(src) || in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["locked"])
			if ((src.connected && src.connected.occupant))
				src.connected.locked = !( src.connected.locked )
		////////////////////////////////////////////////////////
		if (href_list["genpulse"])
			src.delete = 1
			src.temphtml = text("Working ... Please wait ([] Seconds)", src.radduration)
			usr << browse(temphtml, "window=scannernew;size=550x650")
			onclose(usr, "scannernew")
			var/lock_state = src.connected.locked
			src.connected.locked = 1//lock it
			sleep(10*src.radduration)
			if (!src.connected.occupant)
				temphtml = null
				delete = 0
				return null
			if (prob(95))
				if(prob(75))
					randmutb(src.connected.occupant)
				else
					randmuti(src.connected.occupant)
			else
				if(prob(95))
					randmutg(src.connected.occupant)
				else
					randmuti(src.connected.occupant)
			src.connected.occupant.radiation += ((src.radstrength*3)+src.radduration*3)
			src.connected.locked = lock_state
			temphtml = null
			delete = 0
		if (href_list["radset"])
			src.temphtml = text("Radiation Duration: <B><font color='green'>[]</B></FONT><BR>", src.radduration)
			src.temphtml += text("Radiation Intensity: <font color='green'><B>[]</B></FONT><BR><BR>", src.radstrength)
			src.temphtml += text("<A href='?src=\ref[];radleminus=1'>--</A> Duration <A href='?src=\ref[];radleplus=1'>++</A><BR>", src, src)
			src.temphtml += text("<A href='?src=\ref[];radinminus=1'>--</A> Intesity <A href='?src=\ref[];radinplus=1'>++</A><BR>", src, src)
			src.delete = 0
		if (href_list["radleplus"])
			if (src.radduration < 20)
				src.radduration++
				src.radduration++
			dopage(src,"radset")
		if (href_list["radleminus"])
			if (src.radduration > 2)
				src.radduration--
				src.radduration--
			dopage(src,"radset")
		if (href_list["radinplus"])
			if (src.radstrength < 10)
				src.radstrength++
			dopage(src,"radset")
		if (href_list["radinminus"])
			if (src.radstrength > 1)
				src.radstrength--
			dopage(src,"radset")
		////////////////////////////////////////////////////////
		if (href_list["unimenu"])
			//src.temphtml = text("Unique Identifier: <font color='blue'>[]</FONT><BR><BR>", src.connected.occupant.dna.uni_identity)
			src.temphtml = text("Unique Identifier: <font color='blue'>[getleftblocks(src.connected.occupant.dna.uni_identity,uniblock,3)][src.subblock == 1 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),1,1)+"</U></B>" : getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),1,1)][src.subblock == 2 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),2,1)+"</U></B>" : getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),2,1)][src.subblock == 3 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),3,1)+"</U></B>" : getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),3,1)][getrightblocks(src.connected.occupant.dna.uni_identity,uniblock,3)]</FONT><BR><BR>")
			src.temphtml += text("Selected Block: <font color='blue'><B>[]</B></FONT><BR>", src.uniblock)
			src.temphtml += text("<A href='?src=\ref[];unimenuminus=1'><-</A> Block <A href='?src=\ref[];unimenuplus=1'>-></A><BR><BR>", src, src)
			src.temphtml += text("Selected Sub-Block: <font color='blue'><B>[]</B></FONT><BR>", src.subblock)
			src.temphtml += text("<A href='?src=\ref[];unimenusubminus=1'><-</A> Sub-Block <A href='?src=\ref[];unimenusubplus=1'>-></A><BR><BR>", src, src)
			src.temphtml += "<B>Modify Block:</B><BR>"
			src.temphtml += text("<A href='?src=\ref[];unipulse=1'>Radiation</A><BR>", src)
			src.delete = 0
		if (href_list["unimenuplus"])
			if (src.uniblock < 13)
				src.uniblock++
			dopage(src,"unimenu")
		if (href_list["unimenuminus"])
			if (src.uniblock > 1)
				src.uniblock--
			dopage(src,"unimenu")
		if (href_list["unimenusubplus"])
			if (src.subblock < 3)
				src.subblock++
			dopage(src,"unimenu")
		if (href_list["unimenusubminus"])
			if (src.subblock > 1)
				src.subblock--
			dopage(src,"unimenu")
		if (href_list["unipulse"])
			if(src.connected.occupant)
				var/block
				var/newblock
				var/tstructure2
				block = getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),src.subblock,1)
				src.delete = 1
				src.temphtml = text("Working ... Please wait ([] Seconds)", src.radduration)
				usr << browse(temphtml, "window=scannernew;size=550x650")
				onclose(usr, "scannernew")
				var/lock_state = src.connected.locked
				src.connected.locked = 1//lock it
				sleep(10*src.radduration)
				if (!src.connected.occupant)
					temphtml = null
					delete = 0
					return null
				///
				if (prob((80 + (src.radduration / 2))))
					block = miniscramble(block, src.radstrength, src.radduration)
					newblock = null
					if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),2,1) + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),3,1)
					if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),1,1) + block + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),3,1)
					if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),1,1) + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),2,1) + block
					tstructure2 = setblock(src.connected.occupant.dna.uni_identity, src.uniblock, newblock,3)
					src.connected.occupant.dna.uni_identity = tstructure2
					updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
					src.connected.occupant.radiation += (src.radstrength+src.radduration)
				else
					if	(prob(20+src.radstrength))
						randmutb(src.connected.occupant)
						domutcheck(src.connected.occupant,src.connected)
					else
						randmuti(src.connected.occupant)
						updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
					src.connected.occupant.radiation += ((src.radstrength*2)+src.radduration)
				src.connected.locked = lock_state
			dopage(src,"unimenu")
			src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["rejuv"])
			var/mob/living/carbon/human/H = src.connected.occupant
			if(H)
				if (H.reagents.get_reagent_amount("inaprovaline") < 60)
					H.reagents.add_reagent("inaprovaline", 30)
				usr << text("Occupant now has [] units of rejuvenation in his/her bloodstream.", H.reagents.get_reagent_amount("inaprovaline"))
				src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["strucmenu"])
			if(src.connected.occupant)
				var/temp_string1 = getleftblocks(src.connected.occupant.dna.struc_enzymes,strucblock,3)
				var/temp1 = ""
				for(var/i = 3, i <= length(temp_string1), i += 3)
					temp1 += copytext(temp_string1, i-2, i+1) + " "
				var/temp_string2 = getrightblocks(src.connected.occupant.dna.struc_enzymes,strucblock,3)
				var/temp2 = ""
				for(var/i = 3, i <= length(temp_string2), i += 3)
					temp2 += copytext(temp_string2, i-2, i+1) + " "
				src.temphtml = text("Structural Enzymes: <font color='blue'>[temp1] [src.subblock == 1 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1)+"</U></B>" : getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1)][src.subblock == 2 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1)+"</U></B>":getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1)][src.subblock == 3 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)+"</U></B>":getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)] [temp2]</FONT><BR><BR>")
				//src.temphtml = text("Structural Enzymes: <font color='blue'>[]</FONT><BR><BR>", src.connected.occupant.dna.struc_enzymes)
				src.temphtml += text("Selected Block: <font color='blue'><B>[]</B></FONT><BR>", src.strucblock)
				src.temphtml += text("<A href='?src=\ref[];strucmenuminus=1'><-</A> <A href='?src=\ref[];strucmenuchoose=1'>Block</A> <A href='?src=\ref[];strucmenuplus=1'>-></A><BR><BR>", src, src, src)
				src.temphtml += text("Selected Sub-Block: <font color='blue'><B>[]</B></FONT><BR>", src.subblock)
				src.temphtml += text("<A href='?src=\ref[];strucmenusubminus=1'><-</A> Sub-Block <A href='?src=\ref[];strucmenusubplus=1'>-></A><BR><BR>", src, src)
				src.temphtml += "<B>Modify Block:</B><BR>"
				src.temphtml += text("<A href='?src=\ref[];strucpulse=1'>Radiation</A><BR>", src)
				src.delete = 0
		if (href_list["strucmenuplus"])
			if (src.strucblock < 27)
				src.strucblock++
			dopage(src,"strucmenu")
		if (href_list["strucmenuminus"])
			if (src.strucblock > 1)
				src.strucblock--
			dopage(src,"strucmenu")
		if (href_list["strucmenuchoose"])
			var/temp = input("What block?", "Block", src.strucblock) as num
			if (temp > 27)
				temp = 27
			if (temp < 1)
				temp = 1
			src.strucblock = temp
			dopage(src,"strucmenu")
		if (href_list["strucmenusubplus"])
			if (src.subblock < 3)
				src.subblock++
			dopage(src,"strucmenu")
		if (href_list["strucmenusubminus"])
			if (src.subblock > 1)
				src.subblock--
			dopage(src,"strucmenu")
		if (href_list["strucpulse"])
			var/block
			var/newblock
			var/tstructure2
			var/oldblock
			var/lock_state = src.connected.locked
			src.connected.locked = 1//lock it
			if (src.connected.occupant)
				block = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),src.subblock,1)
				src.delete = 1
				src.temphtml = text("Working ... Please wait ([] Seconds)", src.radduration)
				usr << browse(temphtml, "window=scannernew;size=550x650")
				onclose(usr, "scannernew")
				sleep(10*src.radduration)
			else
				temphtml = null
				delete = 0
				return null
			///
			if(src.connected.occupant)
				if (prob((80 + (src.radduration / 2))))
					if (prob (20))
						oldblock = src.strucblock
						block = miniscramble(block, src.radstrength, src.radduration)
						newblock = null
						if (src.strucblock > 1 && src.strucblock < STRUCDNASIZE/2)
							src.strucblock++
						else if (src.strucblock > STRUCDNASIZE/2 && src.strucblock < STRUCDNASIZE)
							src.strucblock--
						if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
						if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
						if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + block
						tstructure2 = setblock(src.connected.occupant.dna.struc_enzymes, src.strucblock, newblock,3)
						src.connected.occupant.dna.struc_enzymes = tstructure2
						domutcheck(src.connected.occupant,src.connected)
						src.connected.occupant.radiation += (src.radstrength+src.radduration)
						src.strucblock = oldblock
					else
						block = miniscramble(block, src.radstrength, src.radduration)
						newblock = null
						if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
						if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
						if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + block
						tstructure2 = setblock(src.connected.occupant.dna.struc_enzymes, src.strucblock, newblock,3)
						src.connected.occupant.dna.struc_enzymes = tstructure2
						domutcheck(src.connected.occupant,src.connected)
						src.connected.occupant.radiation += (src.radstrength+src.radduration)
				else
					if	(prob(80-src.radduration))
						randmutb(src.connected.occupant)
						domutcheck(src.connected.occupant,src.connected)
					else
						randmuti(src.connected.occupant)
						updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
					src.connected.occupant.radiation += ((src.radstrength*2)+src.radduration)
			src.connected.locked = lock_state
			///
			dopage(src,"strucmenu")
			src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["buffermenu"])
			src.temphtml = "<B>Buffer 1:</B><BR>"
			if (!(src.buffer1))
				src.temphtml += "Buffer Empty<BR>"
			else
				src.temphtml += text("Data: <font color='blue'>[]</FONT><BR>", src.buffer1)
				src.temphtml += text("By: <font color='blue'>[]</FONT><BR>", src.buffer1owner)
				src.temphtml += text("Label: <font color='blue'>[]</FONT><BR>", src.buffer1label)
			if (src.connected.occupant && !(src.connected.occupant.mutations & HUSK)) src.temphtml += text("Save : <A href='?src=\ref[];b1addui=1'>UI</A> - <A href='?src=\ref[];b1adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b1addse=1'>SE</A><BR>", src, src, src)
			if (src.buffer1) src.temphtml += text("Transfer to: <A href='?src=\ref[];b1transfer=1'>Occupant</A> - <A href='?src=\ref[];b1injector=1'>Injector</A><BR>", src, src)
			//if (src.buffer1) src.temphtml += text("<A href='?src=\ref[];b1iso=1'>Isolate Block</A><BR>", src)
			if (src.buffer1) src.temphtml += "Disk: <A href='?src=\ref[src];save_disk=1'>Save To</a> | <A href='?src=\ref[src];load_disk=1'>Load From</a><br>"
			if (src.buffer1) src.temphtml += text("<A href='?src=\ref[];b1label=1'>Edit Label</A><BR>", src)
			if (src.buffer1) src.temphtml += text("<A href='?src=\ref[];b1clear=1'>Clear Buffer</A><BR><BR>", src)
			if (!src.buffer1) src.temphtml += "<BR>"
			src.temphtml += "<B>Buffer 2:</B><BR>"
			if (!(src.buffer2))
				src.temphtml += "Buffer Empty<BR>"
			else
				src.temphtml += text("Data: <font color='blue'>[]</FONT><BR>", src.buffer2)
				src.temphtml += text("By: <font color='blue'>[]</FONT><BR>", src.buffer2owner)
				src.temphtml += text("Label: <font color='blue'>[]</FONT><BR>", src.buffer2label)
			if (src.connected.occupant && !(src.connected.occupant.mutations2 & NOCLONE)) src.temphtml += text("Save : <A href='?src=\ref[];b2addui=1'>UI</A> - <A href='?src=\ref[];b2adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b2addse=1'>SE</A><BR>", src, src, src)
			if (src.buffer2) src.temphtml += text("Transfer to: <A href='?src=\ref[];b2transfer=1'>Occupant</A> - <A href='?src=\ref[];b2injector=1'>Injector</A><BR>", src, src)
			//if (src.buffer2) src.temphtml += text("<A href='?src=\ref[];b2iso=1'>Isolate Block</A><BR>", src)
			if (src.buffer2) src.temphtml += "Disk: <A href='?src=\ref[src];save_disk=2'>Save To</a> | <A href='?src=\ref[src];load_disk=2'>Load From</a><br>"
			if (src.buffer2) src.temphtml += text("<A href='?src=\ref[];b2label=1'>Edit Label</A><BR>", src)
			if (src.buffer2) src.temphtml += text("<A href='?src=\ref[];b2clear=1'>Clear Buffer</A><BR><BR>", src)
			if (!src.buffer2) src.temphtml += "<BR>"
			src.temphtml += "<B>Buffer 3:</B><BR>"
			if (!(src.buffer3))
				src.temphtml += "Buffer Empty<BR>"
			else
				src.temphtml += text("Data: <font color='blue'>[]</FONT><BR>", src.buffer3)
				src.temphtml += text("By: <font color='blue'>[]</FONT><BR>", src.buffer3owner)
				src.temphtml += text("Label: <font color='blue'>[]</FONT><BR>", src.buffer3label)
			if (src.connected.occupant && !(src.connected.occupant.mutations2 & NOCLONE)) src.temphtml += text("Save : <A href='?src=\ref[];b3addui=1'>UI</A> - <A href='?src=\ref[];b3adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b3addse=1'>SE</A><BR>", src, src, src)
			if (src.buffer3) src.temphtml += text("Transfer to: <A href='?src=\ref[];b3transfer=1'>Occupant</A> - <A href='?src=\ref[];b3injector=1'>Injector</A><BR>", src, src)
			//if (src.buffer3) src.temphtml += text("<A href='?src=\ref[];b3iso=1'>Isolate Block</A><BR>", src)
			if (src.buffer3) src.temphtml += "Disk: <A href='?src=\ref[src];save_disk=3'>Save To</a> | <A href='?src=\ref[src];load_disk=3'>Load From</a><br>"
			if (src.buffer3) src.temphtml += text("<A href='?src=\ref[];b3label=1'>Edit Label</A><BR>", src)
			if (src.buffer3) src.temphtml += text("<A href='?src=\ref[];b3clear=1'>Clear Buffer</A><BR><BR>", src)
			if (!src.buffer3) src.temphtml += "<BR>"
		if (href_list["b1addui"])
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffer1iue = 0
				src.buffer1 = src.connected.occupant.dna.uni_identity
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffer1owner = src.connected.occupant.name
				else
					if(src.connected.occupant.real_name == "Unknown" && src.connected.occupant.dna.original_name != "Unknown")
						src.buffer1owner = src.connected.occupant.dna.original_name  //Good god, is that unweildy
					else
						src.buffer1owner = src.connected.occupant.real_name
				src.buffer1label = "Unique Identifier"
				src.buffer1type = "ui"
				dopage(src,"buffermenu")
		if (href_list["b1adduiue"])
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffer1 = src.connected.occupant.dna.uni_identity
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffer1owner = src.connected.occupant.name
				else
					if(src.connected.occupant.real_name == "Unknown" && src.connected.occupant.dna.original_name != "Unknown")
						src.buffer1owner = src.connected.occupant.dna.original_name  //Good god, is that unweildy
					else
						src.buffer1owner = src.connected.occupant.real_name
				src.buffer1label = "Unique Identifier & Unique Enzymes"
				src.buffer1type = "ui"
				src.buffer1iue = 1
				dopage(src,"buffermenu")
		if (href_list["b2adduiue"])
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffer2 = src.connected.occupant.dna.uni_identity
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffer2owner = src.connected.occupant.name
				else
					if(src.connected.occupant.real_name == "Unknown" && src.connected.occupant.dna.original_name != "Unknown")
						src.buffer2owner = src.connected.occupant.dna.original_name  //Good god, is that unweildy
					else
						src.buffer2owner = src.connected.occupant.real_name
				src.buffer2label = "Unique Identifier & Unique Enzymes"
				src.buffer2type = "ui"
				src.buffer2iue = 1
				dopage(src,"buffermenu")
		if (href_list["b3adduiue"])
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffer3 = src.connected.occupant.dna.uni_identity
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffer3owner = src.connected.occupant.name
				else
					if(src.connected.occupant.real_name == "Unknown" && src.connected.occupant.dna.original_name != "Unknown")
						src.buffer3owner = src.connected.occupant.dna.original_name  //Good god, is that unweildy
					else
						src.buffer3owner = src.connected.occupant.real_name
				src.buffer3label = "Unique Identifier & Unique Enzymes"
				src.buffer3type = "ui"
				src.buffer3iue = 1
				dopage(src,"buffermenu")
		if (href_list["b2addui"])
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffer2iue = 0
				src.buffer2 = src.connected.occupant.dna.uni_identity
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffer2owner = src.connected.occupant.name
				else
					if(src.connected.occupant.real_name == "Unknown" && src.connected.occupant.dna.original_name != "Unknown")
						src.buffer2owner = src.connected.occupant.dna.original_name  //Good god, is that unweildy
					else
						src.buffer2owner = src.connected.occupant.real_name
				src.buffer2label = "Unique Identifier"
				src.buffer2type = "ui"
				dopage(src,"buffermenu")
		if (href_list["b3addui"])
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffer3iue = 0
				src.buffer3 = src.connected.occupant.dna.uni_identity
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffer3owner = src.connected.occupant.name
				else
					if(src.connected.occupant.real_name == "Unknown" && src.connected.occupant.dna.original_name != "Unknown")
						src.buffer3owner = src.connected.occupant.dna.original_name  //Good god, is that unweildy
					else
						src.buffer3owner = src.connected.occupant.real_name
				src.buffer3label = "Unique Identifier"
				src.buffer3type = "ui"
				dopage(src,"buffermenu")
		if (href_list["b1addse"])
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffer1iue = 0
				src.buffer1 = src.connected.occupant.dna.struc_enzymes
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffer1owner = src.connected.occupant.name
				else
					if(src.connected.occupant.real_name == "Unknown" && src.connected.occupant.dna.original_name != "Unknown")
						src.buffer1owner = src.connected.occupant.dna.original_name  //Good god, is that unweildy
					else
						src.buffer1owner = src.connected.occupant.real_name
				src.buffer1label = "Structural Enzymes"
				src.buffer1type = "se"
				dopage(src,"buffermenu")
		if (href_list["b2addse"])
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffer2iue = 0
				src.buffer2 = src.connected.occupant.dna.struc_enzymes
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffer2owner = src.connected.occupant.name
				else
					if(src.connected.occupant.real_name == "Unknown" && src.connected.occupant.dna.original_name != "Unknown")
						src.buffer2owner = src.connected.occupant.dna.original_name  //Good god, is that unweildy
					else
						src.buffer2owner = src.connected.occupant.real_name
				src.buffer2label = "Structural Enzymes"
				src.buffer2type = "se"
				dopage(src,"buffermenu")
		if (href_list["b3addse"])
			if(src.connected.occupant && src.connected.occupant.dna)
				src.buffer3iue = 0
				src.buffer3 = src.connected.occupant.dna.struc_enzymes
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffer3owner = src.connected.occupant.name
				else
					if(src.connected.occupant.real_name == "Unknown" && src.connected.occupant.dna.original_name != "Unknown")
						src.buffer3owner = src.connected.occupant.dna.original_name  //Good god, is that unweildy
					else
						src.buffer3owner = src.connected.occupant.real_name
				src.buffer3label = "Structural Enzymes"
				src.buffer3type = "se"
				dopage(src,"buffermenu")
		if (href_list["b1clear"])
			src.buffer1 = null
			src.buffer1owner = null
			src.buffer1label = null
			src.buffer1iue = null
			dopage(src,"buffermenu")
		if (href_list["b2clear"])
			src.buffer2 = null
			src.buffer2owner = null
			src.buffer2label = null
			src.buffer2iue = null
			dopage(src,"buffermenu")
		if (href_list["b3clear"])
			src.buffer3 = null
			src.buffer3owner = null
			src.buffer3label = null
			src.buffer3iue = null
			dopage(src,"buffermenu")
		if (href_list["b1label"])
			src.buffer1label = sanitize(input("New Label:","Edit Label","Infos here"))
			dopage(src,"buffermenu")
		if (href_list["b2label"])
			src.buffer2label = sanitize(input("New Label:","Edit Label","Infos here"))
			dopage(src,"buffermenu")
		if (href_list["b3label"])
			src.buffer3label = sanitize(input("New Label:","Edit Label","Infos here"))
			dopage(src,"buffermenu")
		if (href_list["b1transfer"])
			if (!src.connected.occupant || src.connected.occupant.mutations2 & NOCLONE || !src.connected.occupant.dna)
				return
			if (src.buffer1type == "ui")
				if (src.buffer1iue)
					src.connected.occupant.real_name = src.buffer1owner
					src.connected.occupant.name = src.buffer1owner
					src.connected.occupant.dna.original_name = src.buffer1owner
				src.connected.occupant.dna.uni_identity = src.buffer1
				updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
			else if (src.buffer1type == "se")
				src.connected.occupant.dna.struc_enzymes = src.buffer1
				domutcheck(src.connected.occupant,src.connected)
			src.temphtml = "Transfered."
			src.connected.occupant.radiation += rand(20,50)
			src.delete = 0
		if (href_list["b2transfer"])
			if (!src.connected.occupant || src.connected.occupant.mutations2 & NOCLONE || !src.connected.occupant.dna)
				return
			if (src.buffer2type == "ui")
				if (src.buffer2iue)
					src.connected.occupant.real_name = src.buffer2owner
					src.connected.occupant.name = src.buffer2owner
					src.connected.occupant.dna.original_name = src.buffer2owner
				src.connected.occupant.dna.uni_identity = src.buffer2
				updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
			else if (src.buffer2type == "se")
				src.connected.occupant.dna.struc_enzymes = src.buffer2
				domutcheck(src.connected.occupant,src.connected)
			src.temphtml = "Transfered."
			src.connected.occupant.radiation += rand(20,50)
			src.delete = 0
		if (href_list["b3transfer"])
			if (!src.connected.occupant || src.connected.occupant.mutations2 & NOCLONE || !src.connected.occupant.dna)
				return
			if (src.buffer3type == "ui")
				if (src.buffer3iue)
					src.connected.occupant.real_name = src.buffer3owner
					src.connected.occupant.name = src.buffer3owner
					src.connected.occupant.dna.original_name = src.buffer3owner
				src.connected.occupant.dna.uni_identity = src.buffer3
				updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
			else if (src.buffer3type == "se")
				src.connected.occupant.dna.struc_enzymes = src.buffer3
				domutcheck(src.connected.occupant,src.connected)
			src.temphtml = "Transfered."
			src.connected.occupant.radiation += rand(20,50)
			src.delete = 0
		if (href_list["b1injector"])
			if (src.injectorready)
				var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
				I.dna = src.buffer1
				I.dnatype = src.buffer1type
				I.loc = src.loc
				I.name += " ([src.buffer1label])"
				if (src.buffer1iue) I.ue = src.buffer1owner //lazy haw haw
				src.temphtml = "Injector created."
				src.delete = 0
				src.injectorready = 0
				spawn(300)
					src.injectorready = 1
			else
				src.temphtml = "Replicator not ready yet."
				src.delete = 0
		if (href_list["b2injector"])
			if (src.injectorready)
				var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
				I.dna = src.buffer2
				I.dnatype = src.buffer2type
				I.loc = src.loc
				I.name += " ([src.buffer2label])"
				if (src.buffer2iue) I.ue = src.buffer2owner //lazy haw haw
				src.temphtml = "Injector created."
				src.delete = 0
				src.injectorready = 0
				spawn(300)
					src.injectorready = 1
			else
				src.temphtml = "Replicator not ready yet."
				src.delete = 0
		if (href_list["b3injector"])
			if (src.injectorready)
				var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
				I.dna = src.buffer3
				I.dnatype = src.buffer3type
				I.loc = src.loc
				I.name += " ([src.buffer3label])"
				if (src.buffer3iue) I.ue = src.buffer3owner //lazy haw haw
				src.temphtml = "Injector created."
				src.delete = 0
				src.injectorready = 0
				spawn(300)
					src.injectorready = 1
			else
				src.temphtml = "Replicator not ready yet."
				src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["load_disk"])
			var/buffernum = text2num(href_list["load_disk"])
			if ((buffernum > 3) || (buffernum < 1))
				return
			if ((isnull(src.diskette)) || (!src.diskette.data) || (src.diskette.data == ""))
				return
			switch(buffernum)
				if(1)
					src.buffer1 = src.diskette.data
					src.buffer1type = src.diskette.data_type
					src.buffer1iue = src.diskette.ue
					src.buffer1owner = src.diskette.owner
				if(2)
					src.buffer2 = src.diskette.data
					src.buffer2type = src.diskette.data_type
					src.buffer2iue = src.diskette.ue
					src.buffer2owner = src.diskette.owner
				if(3)
					src.buffer3 = src.diskette.data
					src.buffer3type = src.diskette.data_type
					src.buffer3iue = src.diskette.ue
					src.buffer3owner = src.diskette.owner
			src.temphtml = "Data loaded."

		if (href_list["save_disk"])
			var/buffernum = text2num(href_list["save_disk"])
			if ((buffernum > 3) || (buffernum < 1))
				return
			if ((isnull(src.diskette)) || (src.diskette.read_only))
				return
			switch(buffernum)
				if(1)
					src.diskette.data = buffer1
					src.diskette.data_type = src.buffer1type
					src.diskette.ue = src.buffer1iue
					src.diskette.owner = src.buffer1owner
					src.diskette.name = "data disk - '[src.buffer1owner]'"
				if(2)
					src.diskette.data = buffer2
					src.diskette.data_type = src.buffer2type
					src.diskette.ue = src.buffer2iue
					src.diskette.owner = src.buffer2owner
					src.diskette.name = "data disk - '[src.buffer2owner]'"
				if(3)
					src.diskette.data = buffer3
					src.diskette.data_type = src.buffer3type
					src.diskette.ue = src.buffer3iue
					src.diskette.owner = src.buffer3owner
					src.diskette.name = "data disk - '[src.buffer3owner]'"
			src.temphtml = "Data saved."
		if (href_list["eject_disk"])
			if (!src.diskette)
				return
			src.diskette.loc = get_turf(src)
			src.diskette = null
		////////////////////////////////////////////////////////
		if (href_list["clear"])
			src.temphtml = null
			src.delete = 0
		if (href_list["update"]) //ignore
			src.temphtml = src.temphtml
		src.add_fingerprint(usr)
		src.updateUsrDialog()
	return
/////////////////////////// DNA MACHINES
