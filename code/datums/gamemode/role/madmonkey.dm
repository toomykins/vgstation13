// Jungle Fever is now a virus2 disease: /datum/disease2/effect/jungle_fever and
// /datum/disease2/disease/predefined/mig_jungle_fever (see virus2/effect/migrated.dm).

/*============
*             *
*  ROLE BEGIN *
*             *
============*/

/datum/role/madmonkey
	name = MADMONKEY
	id = MADMONKEY
	special_role = MADMONKEY
	logo_state = "monkey-logo"
	greets = list(GREET_MASTER,GREET_DEFAULT,GREET_CUSTOM)
	default_admin_voice = "Monkey King"
	admin_voice_style = "rough"
	var/countdown = 60

/datum/role/madmonkey/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>[custom]</B>")
		if (GREET_MASTER)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'><B>You are the Jungle Fever patient zero!</B><BR>Find somewhere safe, you will transform in one minute. At that time, start biting!</span>")
		else //default
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'><B>You are a [name]!</B><BR>Bite crewmembers to add to your ranks!</span>")

/datum/role/madmonkey/OnPostSetup(var/laterole = FALSE)
	if(faction)
		return
	var/datum/faction/F = find_active_faction_by_type(/datum/faction/junglefever)
	if(!F)
		F = ticker.mode.CreateFaction(/datum/faction/junglefever, null, 1)
		F.forgeObjectives()
		F.HandleRecruitedRole(src)
	else
		F.HandleRecruitedRole(src)

/datum/role/madmonkey/process()
	..()
	if(!antag || !antag.current || isobserver(antag.current) || ismonkey(antag.current))
		return
	if (countdown > 0)
		countdown--
		if (countdown == 50)
			to_chat(antag.current, "<span class='alert'>You feel hungry for bananas.</span>")
		else if (countdown == 30)
			to_chat(antag.current, "<span class='alert'>You feel like you're about to go ape.</span>")
		else if (countdown <= 0)
			var/mob/living/carbon/monkey/M = antag.current.monkeyize()
			M.infect_disease2_predefined(DISEASE_MIG_JUNGLE, 1, "Jungle Fever")
	if (antag && antag.current.hud_used)
		if(antag.current.hud_used.countdown_display)
			antag.current.hud_used.countdown_display.overlays.len = 0
			var/first = round(countdown/10)
			var/second = countdown%10
			var/image/I1 = new('icons/obj/centcomm_stuff.dmi',src,"[first]",30)
			var/image/I2 = new('icons/obj/centcomm_stuff.dmi',src,"[second]",30)
			I1.pixel_x += 10 * PIXEL_MULTIPLIER
			I2.pixel_x += 17 * PIXEL_MULTIPLIER
			I1.pixel_y -= 11 * PIXEL_MULTIPLIER
			I2.pixel_y -= 11 * PIXEL_MULTIPLIER
			antag.current.hud_used.countdown_display.overlays += I1
			antag.current.hud_used.countdown_display.overlays += I2
		else
			antag.current.hud_used.countdown_monkey()
