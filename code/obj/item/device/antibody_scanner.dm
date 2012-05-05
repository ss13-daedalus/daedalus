/obj/item/device/antibody_scanner
	name = "Antibody Scanner"
	desc = "Used to scan living beings for antibodies in their blood."
	icon_state = "health"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT | USEDELAY


/obj/item/device/antibody_scanner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if(! istype(M, /mob/living/carbon) || !M:antibodies)
		user << "Unable to detect antibodies.."
	else
		// iterate over the list of antigens and see what matches
		var/code = ""
		for(var/V in ANTIGENS) if(text2num(V) & M.antibodies) code += ANTIGENS[V]
		user << text("\blue [src] The antibody scanner displays a cryptic set of data: [code]")
