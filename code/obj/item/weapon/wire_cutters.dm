/obj/item/weapon/wire_cutters
	name = "wire cutters"
	desc = "This cuts wires."
	icon = 'icons/obj/items.dmi'
	icon_state = "cutters"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 6.0
	throw_speed = 2
	throw_range = 9
	w_class = 2.0
	m_amt = 80
	origin_tech = "materials=1;engineering=1"

	New()
		if(prob(50))
			icon_state = "cutters-y"
