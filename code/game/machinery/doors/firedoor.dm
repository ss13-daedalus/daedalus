/var/const/OPEN = 1
/var/const/CLOSED = 2


/obj/machinery/door/firedoor
	name = "Firelock"
	desc = "Apply crowbar"
	icon = 'icons/obj/doors/Doorfire.dmi'
	icon_state = "door_open"
	var/blocked = 0
	opacity = 0
	density = 0
	var/nextstate = null


	Bumped(atom/AM)
		if(p_open || operating)	return
		if(!density)	return ..()
		return 0


	power_change()
		if(powered(ENVIRON))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		return


	attackby(obj/item/weapon/C as obj, mob/user as mob)
		src.add_fingerprint(user)
		if(operating)	return//Already doing something.
		if(istype(C, /obj/item/weapon/welding_tool))
			var/obj/item/weapon/welding_tool/W = C
			if(W.remove_fuel(0, user))
				src.blocked = !src.blocked
				user << text("\red You [blocked?"welded":"unwelded"] the [src]")
				update_icon()
				return

		if (istype(C, /obj/item/weapon/crowbar) || (istype(C,/obj/item/weapon/fire_axe) && C.wielded == 1))
			if(blocked || operating)	return
			if(src.density)
				spawn(0)
					open()
					return
			else //close it up again
				spawn(0)
					close()
					return
		return


	process()
		if(operating || stat & NOPOWER || !nextstate)	return
		switch(nextstate)
			if(OPEN)
				spawn()
					open()
			if(CLOSED)
				spawn()
					close()
		nextstate = null
		return


	animate(animation)
		switch(animation)
			if("opening")
				flick("door_opening", src)
			if("closing")
				flick("door_closing", src)
		return


	update_icon()
		overlays = null
		if(density)
			icon_state = "door_closed"
			if(blocked)
				overlays += "welded"
		else
			icon_state = "door_open"
			if(blocked)
				overlays += "welded_open"
		return



//border_only fire doors are special when it comes to air groups
/obj/machinery/door/firedoor/border_only
