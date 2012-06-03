///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/construct_shell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive"
	flags = FPRINT | TABLEPASS

/obj/structure/construct_shell/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/device/soulstone))
		O.transfer_soul("CONSTRUCT",src,user)


////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////


