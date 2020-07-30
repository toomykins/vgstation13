/datum/role/ddanop
	name = DDANOP
	id = DDANOP
	required_pref = DDANOP
	special_role = DDANOP
	logo_state = "discount-logo"
	disallow_job = TRUE

// check AssignToRole in role.dm later for parent- relationship

/datum/role/ddanop/Greet()
	to_chat(antag.current, "<B><span class='warning'>You are a grunt in employment of the Discount Dan company!</span></B>")
	to_chat(antag.current, "The authorities of this specific station have not yet paid the required licensing fee.")


/datum/role/ddanop/OnPostSetup()
	var/mob/living/carbon/human/H = antag.current
	H.dna.ResetUI()
	H.regenerate_icons()
	equip_ddanop(H)
	var/datum/money_account/M = create_account("Discount Dan",0,FALSE,0,1,TRUE)

/proc/equip_ddanop(var/mob/living/carbon/human/H)
	//Special radio setup
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset(src), slot_ears)


	//Basic Uniform
	var/list/shirts = list(/obj/item/clothing/under/lawyer/red,/obj/item/clothing/under/lawyer/blue)

	var/chosen_shirt = pick(shirts)
	H.equip_to_slot_or_del(new chosen_shirt, slot_w_uniform)
	disable_suit_sensors(H)


	//equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun/nuclear(src), slot_belt)

	//Glasses
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)

	//Shoes
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(src), slot_shoes)

	//Backpack
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(src), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(src), slot_in_backpack)


	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Discount Dan Representative"
	//W.registered_name = real_name
	W.name = "[W.assignment]"
	W.access = get_centcom_access("Emergency Responder")
	W.icon_state = "ERT_empty"	//placeholder until revamp
	H.equip_to_slot_or_del(W, slot_wear_id)
	//equip_accessory(src, /obj/item/clothing/accessory/holster/handgun/preloaded/NTUSP, /obj/item/clothing/under, 5)