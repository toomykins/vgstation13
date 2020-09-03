/datum/faction/discountdan
	name = "Discount Dan"
	desc = "Best-quality food and drinks!"
	ID = DISCOUNTDAN
	required_pref = DDANREP
	initial_role = DDANREP
	late_role = DDANOP
	initroletype = /datum/role/ddanrep
	roletype = /datum/role/ddanop
	logo_state = "discount-logo"
	hud_icons = list("discount-logo")
	var/codes[5]
///datum/faction/discountdan/ddanop/OnPostSetup()



/datum/faction/discountdan/OnPostSetup()

/datum/map_element/dungeon/discountshuttle
	file_path = "maps/misc/discountshuttle.dmm"
	unique = TRUE

/datum/faction/discountdan/New()
	..()
	var/list/codewords = list("HQ, The 'trasies know! Shut it down! Verify Signal [rand(70,99)]!","Headquarters, execute order 66!", "Boss, implement Safeguard Mechanism [rand(30,70)]!!","*COUGH* WOULD You KINDLY *COUGH* Approve my Request? That's for you, HQ.","HQ, the bird is in the bin and has been fed a worm, over.","The nannies know! HQ, Approve Plan B-[rand(2,9)]!","Headquarters, order to immediately cease the continuation of the cessation of the interrupt routines! Stat!","HQ, this is agent [pick(list("007","69","420"))], Violate clause #[rand(30,100)] at your earliest convenience!","Command! Reinforce sector [rand(10-99)]-[rand(10-99)] now!",")
	//codes = list(CARGOTAKEOVER = pick(
	var/i
	for(i=1,i<=codes.len,i++)
		var/pickedstring = pick(codewords)
		codes[i] = pickedstring
		codewords.Remove(pickedstring)

	load_dungeon(/datum/map_element/dungeon/discountshuttle)
	discount_shuttle.initialize()


/obj/machinery/discountcodelistener
	name = "\improper Discount Dan Secret Code Interpretation Device"
	desc = "Listens to secret codes said by certain people."
	icon = 'icons/obj/items.dmi'
	icon_state = "red_phone"

	use_power = 0
	anchored = 1
	density = 1
	flags = HEAR

/obj/machinery/discountcodelistener/Hear(var/datum/speech/speech, var/rendered_speech="")
	var/message = speech.message
	var/atom/movable/speaker = speech.speaker
	//say("wew")
	if(speaker && istype(speaker,/mob/living) && !istype(speaker,/mob/living/silicon))
		var/mob/living/M = speaker
		if(M.mind && M.mind.GetRole(DDANREP))
			interpretDiscountCode(message,M)

/obj/machinery/discountcodelistener/proc/interpretDiscountCode(var/message, var/mob/living/M)
	var/datum/faction/discountdan/DD = find_active_faction_by_type(/datum/faction/discountdan)

	///var/datum/mind/repmind = M.mind
	///var/datum/faction/repfac = find_active_faction_by_member(repmind.GetRole(DDANREP))
