/datum/faction/discountdan
	name = "Discount Dan"
	desc = "Best-quality food and drinks!"
	ID = DISCOUNTDAN
	required_pref = DDANOP
	initial_role = DDANREP
	late_role = DDANOP
	initroletype = /datum/role/ddanrep
	roletype = /datum/role/ddanop
	logo_state = "discount-logo"
	hud_icons = list("discount-logo")

/datum/faction/discountdan/ddanop/OnPostSetup()
//	for(var/datum/role/nuclear_operative/N in members)
//		var/datum/mind/ddmind = N.antag
//		var/mob/living/carbon/human/H = ddmind.current
//		forgeObjectives()
		//H.dna.ResetUI()
		//H.regenerate_icons()
		//equip_ddanop(H)

//	var/mob/living/carbon/human/H = antag.current
//	H.dna.ResetUI()
//	H.regenerate_icons()
//	equip_ddanop(H)
	//var/datum/money_account/M = create_account("Discount Dan",0,FALSE,0,1,TRUE)

/datum/faction/discountdan/ddanop/forgeObjectives()
	AppendObjective(/datum/objective/stealcash)
	AnnounceObjectives()

/datum/faction/discountdan/ddanop/proc/equip_ddanop(var/mob/living/carbon/human/H)

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset(src), slot_ears)
	var/list/shirts = list(/obj/item/clothing/under/lawyer/red,/obj/item/clothing/under/lawyer/blue)
	var/chosen_shirt = pick(shirts)
	H.equip_to_slot_or_del(new chosen_shirt, slot_w_uniform)
	disable_suit_sensors(H)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(src), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(src), slot_back)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(src), slot_in_backpack)


	var/obj/item/weapon/card/id/W = new(src)
	W.assignment = "Discount Dan Representative"
	//W.registered_name = real_name
	W.name = "[W.assignment]"
	W.access = get_centcom_access("Emergency Responder")
	W.icon_state = "ERT_empty"	//placeholder until revamp
	H.equip_to_slot_or_del(W, slot_wear_id)