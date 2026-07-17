// ============================================================================
// Migrated effects: old /datum/disease content ported into the virus2 system.
// Each effect here reproduces the behaviour of a legacy /datum/disease so that
// content survives once the old system (code/datums/disease.dm) is retired.
// All are restricted = 2 (never mutate in randomly, hidden from encyclopedia)
// and are meant to be assigned directly to a crafted/predefined disease.
// ============================================================================

// --- Rapid Petrification (was /datum/disease/petrification) -----------------
// Legacy behaviour: non-contagious, 100%/tick stage advance, escalating pain
// then Stun, then turn_into_statue() at the final stage. Cured by acids.
// The acid cure is preserved via a reagent check (magnitis is the precedent
// for reagent-gated effects), since virus2 has no per-disease reagent cure.

#define PETRIFICATION_ACID_CURED(M) (M.reagents && (M.reagents.has_reagent(SACID) || M.reagents.has_reagent(PACID) || M.reagents.has_reagent(ACIDSPIT) || M.reagents.has_reagent(ACIDTEA)))

/datum/disease2/effect/petrification_warning
	name = "Calcification Syndrome"
	desc = "The infected's tissue stiffens; movement becomes slow and painful."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	restricted = 2
	chance = 10
	max_chance = 25

/datum/disease2/effect/petrification_warning/activate(var/mob/living/mob)
	if(PETRIFICATION_ACID_CURED(mob)) // acid dissolves the petrifying agent
		if(virus)
			virus.cure(mob)
		return
	if(prob(50))
		mob.simple_message("<span class='userdanger'>You are slowing down. Moving is extremely painful for you.</span>",\
			"<span class='notice'>You feel like Michelangelo di Lodovico Buonarroti Simoni trapped in a foreign body.</span>")
		mob.pain_shock_stage += 100
	else
		mob.simple_message("<span class='userdanger'>Your skin starts losing color and cracking. Your body becomes numb.</span>",\
			"<span class='notice'>You decide to channel your inner Italian sculptor to create a beautiful statue.</span>")
		mob.Stun(3)

/datum/disease2/effect/petrification
	name = "Rapid Petrification"
	desc = "UNKNOWN"
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	restricted = 2

/datum/disease2/effect/petrification/activate(var/mob/living/mob)
	if(PETRIFICATION_ACID_CURED(mob))
		if(virus)
			virus.cure(mob)
		return
	if(mob.turn_into_statue(1))
		mob.simple_message("<span class='userdanger'>Your body turns to stone.</span>",\
			"<span class='notice'>You've created a masterwork statue of David!</span>")
		if(virus)
			virus.cure(mob)

#undef PETRIFICATION_ACID_CURED


// ============================================================================
// Contagious symptom diseases. Each old /datum/disease becomes ONE effect that
// switches on the parent disease's stage, reproducing the legacy stage_act()
// exactly: same messages, emotes, damage and stage thresholds. chance = 100 so
// activate() runs every processing tick like the old stage_act did, and the
// internal prob() rolls are copied verbatim. None of these were curable = 1 in
// the old system, so (faithfully) none self-cure by reagent - only the explicit
// rest/random cures the originals had are reproduced.
// ============================================================================

// --- The Flu (was /datum/disease/flu) ---------------------------------------
/datum/disease2/effect/flu
	name = "The Flu"
	desc = "H13N1 flu virion. Aches, coughing and general malaise."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/flu/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2, 3)
			var/rest_prob = (virus.stage == 2) ? 20 : 15
			if(mob.lying && prob(rest_prob))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.stage = max(1, virus.stage - 1)
				return
			if(prob(1))
				mob.emote("sneeze")
			if(prob(1))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your muscles ache.</span>")
				if(prob(20))
					mob.take_organ_damage(1)
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your stomach hurts.</span>")
				if(prob(20))
					mob.adjustToxLoss(1)
					mob.updatehealth()

// --- The Cold (was /datum/disease/cold) -------------------------------------
// NOTE: legacy stage-3 escalation into the flu is reproduced once a predefined
// flu /datum/disease2/disease exists to hand off to (wiring step). Marked TODO.
/datum/disease2/effect/cold
	name = "The Cold"
	desc = "XY-rhinovirus. Sneezing, sore throat; may worsen into the flu."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/cold/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			if(mob.lying && prob(40))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(1) && prob(5))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(1))
				mob.emote("sneeze")
			if(prob(1))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your throat feels sore.</span>")
			if(prob(1))
				to_chat(mob, "<span class='warning'>Mucous runs down the back of your throat.</span>")
		if(3)
			if(mob.lying && prob(25))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(1) && prob(1))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(1))
				mob.emote("sneeze")
			if(prob(1))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your throat feels sore.</span>")
			if(prob(1))
				to_chat(mob, "<span class='warning'>Mucous runs down the back of your throat.</span>")
			// TODO(wiring): if(prob(1) && prob(50)) hand off to predefined flu disease2, then virus.cure(mob)

// --- The Cold, ICE9 strain (was /datum/disease/cold9) -----------------------
/datum/disease2/effect/cold9
	name = "The Cold (ICE9)"
	desc = "ICE9-rhinovirus. Like the common cold, but leaves the body stiff and cold."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/cold9/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			mob.bodytemperature--
			if(prob(1) && prob(10))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(1))
				mob.emote("sneeze")
			if(prob(1))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your throat feels sore.</span>")
			if(prob(5))
				to_chat(mob, "<span class='warning'>You feel stiff.</span>")
		if(3)
			mob.bodytemperature -= 2
			if(prob(1))
				mob.emote("sneeze")
			if(prob(1))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>Your throat feels sore.</span>")
			if(prob(10))
				to_chat(mob, "<span class='warning'>You feel stiff.</span>")

// --- Spanish inquisition Flu (was /datum/disease/fluspanish) -----------------
// NOTE: the legacy stage_act was mis-declared on /datum/disease/inquisition and
// never actually ran. This port reproduces what it was *meant* to do (fever burn).
/datum/disease2/effect/fluspanish
	name = "Spanish Inquisition Flu"
	desc = "1nqu1s1t10n flu virion. The victim burns in their own skin."
	stage = 1
	badness = EFFECT_DANGER_HARMFUL
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/fluspanish/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			mob.bodytemperature++
			if(prob(5))
				mob.emote("sneeze")
			if(prob(5))
				mob.audible_cough()
			if(prob(1))
				to_chat(mob, "<span class='warning'>You're burning in your own skin!</span>")
				mob.take_organ_damage(0, 5)
		if(3)
			mob.bodytemperature += 2
			if(prob(5))
				mob.emote("sneeze")
			if(prob(5))
				mob.audible_cough()
			if(prob(5))
				to_chat(mob, "<span class='warning'>You're burning in your own skin!</span>")
				mob.take_organ_damage(0, 5)

// --- GBS (was /datum/disease/gbs) -------------------------------------------
// curable = 0 in the original: the listed Synaptizine+Sulfur cure never actually
// fired. Reproduced faithfully - no reagent cure, only the lethal progression.
/datum/disease2/effect/gbs
	name = "GBS"
	desc = "Gravitokinetic Bipotential SADS+. Escalating toxin buildup, then the body tears itself apart."
	stage = 1
	badness = EFFECT_DANGER_DEADLY
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/gbs/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(45))
				mob.adjustToxLoss(5)
				mob.updatehealth()
			if(prob(1))
				mob.emote("sneeze")
		if(3)
			if(prob(5))
				mob.audible_cough()
			else if(prob(5))
				mob.emote("gasp", null, null, TRUE)
			if(prob(10))
				to_chat(mob, "<span class='warning'>You're starting to feel very weak...</span>")
		if(4)
			if(prob(10))
				mob.audible_cough()
			mob.adjustToxLoss(5)
			mob.updatehealth()
		if(5)
			to_chat(mob, "<span class='warning'>Your body feels as if it's trying to rip itself open...</span>")
			if(prob(50))
				mob.gib()

// --- Fake GBS (was /datum/disease/fake_gbs) ---------------------------------
// The harmless impostor: looks like GBS, does nothing lethal.
/datum/disease2/effect/fake_gbs
	name = "GBS"
	desc = "Gravitokinetic Bipotential SADS-. Mimics GBS but is ultimately harmless."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/fake_gbs/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(1))
				mob.emote("sneeze")
		if(3)
			if(prob(5))
				mob.audible_cough()
			else if(prob(5))
				mob.emote("gasp", null, null, TRUE)
			if(prob(10))
				to_chat(mob, "<span class='warning'>You're starting to feel very weak...</span>")
		if(4)
			if(prob(10))
				mob.audible_cough()
		if(5)
			if(prob(10))
				mob.audible_cough()

// --- Brainrot (was /datum/disease/brainrot) ---------------------------------
// curable = 0: alkysine never actually cured it. Faithful port keeps the capped
// brain damage (<=98 guard) and collapse behaviour, no reagent cure.
/datum/disease2/effect/brainrot
	name = "Brainrot"
	desc = "Cryptococcus Cosmosis. Rots the brain - fever, necrosis, collapse."
	stage = 1
	badness = EFFECT_DANGER_HARMFUL
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/brainrot/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(2))
				mob.emote("blink")
			if(prob(2))
				mob.emote("yawn")
			if(prob(2))
				to_chat(mob, "<span class='warning'>Your don't feel like yourself.</span>")
			if(prob(5))
				mob.adjustBrainLoss(1)
				mob.updatehealth()
		if(3)
			if(prob(2))
				mob.emote("stare", null, null, TRUE)
			if(prob(2))
				mob.emote("drool", null, null, TRUE)
			if(prob(10) && mob.getBrainLoss() <= 98)
				mob.adjustBrainLoss(2)
				mob.updatehealth()
				if(prob(2))
					to_chat(mob, "<span class='warning'>Your try to remember something important...but can't.</span>")
		if(4)
			if(prob(2))
				mob.emote("stare", null, null, TRUE)
			if(prob(2))
				mob.emote("drool", null, null, TRUE)
			if(prob(15) && mob.getBrainLoss() <= 98)
				mob.adjustBrainLoss(3)
				mob.updatehealth()
				if(prob(2))
					to_chat(mob, "<span class='warning'>Strange buzzing fills your head, removing all thoughts.</span>")
			if(prob(3))
				to_chat(mob, "<span class='warning'>You lose consciousness...</span>")
				for(var/mob/O in viewers(mob, null))
					O.show_message("[mob] suddenly collapses", 1)
				mob.Paralyse(rand(5, 10))
				if(prob(1))
					mob.emote("snore", null, null, TRUE)
			if(prob(15))
				mob.stuttering += 3

// --- The Rhumba Beat (was /datum/disease/rhumba_beat) -----------------------
// Keeps the original ckey=="rosham" self-cure gag for fidelity.
/datum/disease2/effect/rhumba_beat
	name = "The Rhumba Beat"
	desc = "An irresistible beat builds inside until the body cannot contain it."
	stage = 1
	badness = EFFECT_DANGER_DEADLY
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/rhumba_beat/activate(var/mob/living/carbon/mob)
	if(mob.ckey == "rosham")
		virus.cure(mob)
		return
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(45))
				mob.adjustToxLoss(5)
				mob.updatehealth()
			if(prob(1))
				to_chat(mob, "<span class='warning'>You feel strange...</span>")
		if(3)
			if(prob(5))
				to_chat(mob, "<span class='warning'>You feel the urge to dance...</span>")
			else if(prob(5))
				mob.emote("gasp", null, null, TRUE)
			else if(prob(10))
				to_chat(mob, "<span class='warning'>You feel the need to chick chicky boom...</span>")
		if(4)
			if(prob(10))
				mob.emote("gasp", null, null, TRUE)
				to_chat(mob, "<span class='warning'>You feel a burning beat inside...</span>")
			if(prob(20))
				mob.adjustToxLoss(5)
				mob.updatehealth()
		if(5)
			to_chat(mob, "<span class='warning'>Your body is unable to contain the Rhumba Beat...</span>")
			if(prob(50))
				mob.gib()


// ============================================================================
// Transforms and specials. These were curable = 1 with reagent cures, so the
// cure is preserved: while the reagent is present, prob(cure_chance) walks the
// disease down a stage, curing at stage 1 - the same walk-down the old base
// stage_act() did via has_cure().
// ============================================================================

// --- Pierrot's Throat (was /datum/disease/pierrot_throat) -------------------
// Cured by a whole banana (cure_chance 75).
/datum/disease2/effect/pierrot_throat
	name = "Pierrot's Throat"
	desc = "H0NI<42 Virus. The clown's curse - honking and silliness."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/pierrot_throat/activate(var/mob/living/carbon/mob)
	if(mob.reagents && mob.reagents.has_reagent(BANANA) && prob(75))
		if(virus.stage > 1)
			virus.stage--
		else
			virus.cure(mob)
		return
	switch(virus ? virus.stage : 0)
		if(1)
			if(prob(10))
				to_chat(mob, "<span class='warning'>You feel a little silly.</span>")
		if(2)
			if(prob(10))
				to_chat(mob, "<span class='warning'>You start seeing rainbows.</span>")
		if(3)
			if(prob(10))
				to_chat(mob, "<span class='danger'>Your thoughts are interrupted by a loud HONK!</span>")
		if(4)
			if(prob(5))
				mob.say(pick("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk..."))

// --- Kingston / Yildun Fusobacter Syndrome (was /datum/disease/kingston) ----
// Sneeze -> vomit -> Tajaran ("catbeast"). Cured by The Manly Dorf (chance 100).
/datum/disease2/effect/kingston
	name = "Yildun Infectious Fusobacter Syndrome"
	desc = "Baccilli Yiffus. No god, please no."
	stage = 1
	badness = EFFECT_DANGER_HARMFUL
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/kingston/activate(var/mob/living/carbon/mob)
	if(mob.reagents && mob.reagents.has_reagent(MANLYDORF) && prob(100))
		if(virus.stage > 1)
			virus.stage--
		else
			virus.cure(mob)
		return
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(1))
				mob.emote("sneeze")
		if(3)
			if(ishuman(mob) && prob(1))
				var/mob/living/carbon/human/H = mob
				H.vomit()
		if(4)
			if(prob(1))
				mob.say(pick(";I FEEL FRISKY", "*me scritches behind his ears.", "*me licks [mob.gender == MALE ? "his" : "her"] arm.", ";YIFF", ";MEOW"))
				return
			if(prob(1) && prob(50) && ishuman(mob))
				var/mob/living/carbon/human/H = mob
				to_chat(H, "<span class=\"warning\">You feel a wave of extreme pain and uncleanliness as your body morphs.</span>")
				H.set_species("Tajaran", transfer_damage = TRUE)
				for(var/obj/item/W in H)
					H.drop_from_inventory(W)

// --- Magnitis (was /datum/disease/magnitis) ---------------------------------
// curable = 0: the old iron "cure" never fired (iron isn't even checked in the
// old stage_act), so faithfully there is NO cure - just escalating magnetism.
/datum/disease2/effect/magnitis_legacy
	name = "Magnitis"
	desc = "Fukkos Miracos. The body acts as a powerful magnet."
	stage = 1
	badness = EFFECT_DANGER_HARMFUL
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/magnitis_legacy/proc/pull(var/mob/living/carbon/mob, var/radius, var/maxiter)
	for(var/obj/M in orange(radius, mob))
		if(!M.anchored && (M.is_conductor()))
			for(var/i = 0, i < rand(1, maxiter), i++)
				step_towards(M, mob)
	for(var/mob/living/silicon/S in orange(radius, mob))
		if(istype(S, /mob/living/silicon/ai))
			continue
		for(var/i = 0, i < rand(1, maxiter), i++)
			step_towards(S, mob)

/datum/disease2/effect/magnitis_legacy/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(2))
				to_chat(mob, "<span class='warning'>You feel a slight shock course through your body.</span>")
			if(prob(2))
				pull(mob, 2, 1)
		if(3)
			if(prob(2))
				to_chat(mob, "<span class='warning'>You feel a strong shock course through your body.</span>")
			if(prob(2))
				to_chat(mob, "<span class='warning'>You feel like clowning around.</span>")
			if(prob(4))
				pull(mob, 4, 2)
		if(4)
			if(prob(2))
				to_chat(mob, "<span class='warning'>You feel a powerful shock course through your body.</span>")
			if(prob(2))
				to_chat(mob, "<span class='warning'>You query upon the nature of miracles.</span>")
			if(prob(8))
				pull(mob, 6, 3)

// --- Wizarditis (was /datum/disease/wizarditis) -----------------------------
// Cured by The Manly Dorf (chance 100).
/datum/disease2/effect/wizarditis_legacy
	name = "Wizarditis"
	desc = "Rincewindus Vulgaris. The victim believes themselves a wizard."
	stage = 1
	badness = EFFECT_DANGER_HARMFUL
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/wizarditis_legacy/proc/spawn_wizard_clothes(var/mob/living/carbon/mob, var/chance = 0)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(prob(chance))
			if(!istype(H.head, /obj/item/clothing/head/wizard))
				if(H.head)
					H.drop_from_inventory(H.head)
				H.head = new /obj/item/clothing/head/wizard(H)
				H.head.hud_layerise()
			return
		if(prob(chance))
			if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(H.wear_suit)
					H.drop_from_inventory(H.wear_suit)
				H.wear_suit = new /obj/item/clothing/suit/wizrobe(H)
				H.wear_suit.hud_layerise()
			return
		if(prob(chance))
			if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
				if(H.shoes)
					H.drop_from_inventory(H.shoes)
				H.shoes = new /obj/item/clothing/shoes/sandal(H)
				H.hud_layerise()
			return
	else
		if(prob(chance))
			if(!istype(mob.get_held_item_by_index(GRASP_RIGHT_HAND), /obj/item/weapon/staff))
				if(mob.drop_item(mob.get_held_item_by_index(GRASP_RIGHT_HAND)))
					mob.put_in_r_hand(new /obj/item/weapon/staff(mob))

/datum/disease2/effect/wizarditis_legacy/proc/teleport(var/mob/living/carbon/mob)
	var/list/theareas = new/list()
	for(var/area/AR in orange(80, mob))
		if(theareas.Find(AR) || isspace(AR))
			continue
		theareas += AR
	if(!theareas.len)
		return
	var/area/thearea = pick(theareas)
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(T.z != mob.z)
			continue
		if(T.name == "space")
			continue
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L += T
	if(!L.len)
		return
	mob.say("SCYAR NILA [uppertext(thearea.name)]!")
	mob.forceMove(pick(L))

/datum/disease2/effect/wizarditis_legacy/activate(var/mob/living/carbon/mob)
	if(mob.reagents && mob.reagents.has_reagent(MANLYDORF) && prob(100))
		if(virus.stage > 1)
			virus.stage--
		else
			virus.cure(mob)
		return
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(1) && prob(50))
				mob.say(pick("You shall not pass!", "Expeliarmus!", "By Merlins beard!", "Feel the power of the Dark Side!"))
			if(prob(1) && prob(50))
				to_chat(mob, "<span class='warning'>You feel [pick("that you don't have enough mana.", "that the winds of magic are gone.", "an urge to summon familiar.")]</span>")
		if(3)
			if(prob(1) && prob(50))
				mob.say(pick("NEC CANTIO!", "AULIE OXIN FIERA!", "STI KALY!", "TARCOL MINTI ZHERI!"))
			if(prob(1) && prob(50))
				to_chat(mob, "<span class='warning'>You feel [pick("the magic bubbling in your veins", "that this location gives you a +1 to INT", "an urge to summon familiar.")].</span>")
		if(4)
			if(prob(1))
				mob.say(pick("NEC CANTIO!", "AULIE OXIN FIERA!", "STI KALY!", "EI NATH!"))
				return
			if(prob(1) && prob(50))
				to_chat(mob, "<span class='warning'>You feel [pick("the tidal wave of raw power building inside", "that this location gives you a +2 to INT and +1 to WIS", "an urge to teleport")].</span>")
				spawn_wizard_clothes(mob, 50)
			if(prob(1) && prob(1))
				teleport(mob)

// --- Xenomorph Transformation (was /datum/disease/xeno_transformation) -------
// Cured by Spaceacillin + Glycerol (both, chance 50).
/datum/disease2/effect/xeno_transformation_legacy
	name = "Xenomorph Transformation"
	desc = "Rip-LEY Alien Microbes. The host becomes a xenomorph."
	stage = 1
	badness = EFFECT_DANGER_DEADLY
	restricted = 2
	chance = 100
	max_chance = 100
	var/gibbed = 0

/datum/disease2/effect/xeno_transformation_legacy/activate(var/mob/living/carbon/mob)
	if(mob.reagents && mob.reagents.has_reagent(SPACEACILLIN) && mob.reagents.has_reagent(GLYCEROL) && prob(50))
		if(virus.stage > 1)
			virus.stage--
		else
			virus.cure(mob)
		return
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(8))
				to_chat(mob, "Your throat feels scratchy.")
				mob.take_organ_damage(1)
			if(prob(9))
				to_chat(mob, "<span class='warning'>Kill...</span>")
			if(prob(9))
				to_chat(mob, "<span class='warning'>Kill...</span>")
		if(3)
			if(prob(8))
				to_chat(mob, "<span class='warning'>Your throat feels very scratchy.</span>")
				mob.take_organ_damage(1)
			if(prob(10))
				to_chat(mob, "Your skin feels tight.")
				mob.take_organ_damage(5)
			if(prob(4))
				to_chat(mob, "<span class='warning'>You feel a stabbing pain in your head.</span>")
				mob.Paralyse(2)
			if(prob(4))
				to_chat(mob, "<span class='warning'>You can feel something move...inside.</span>")
		if(4)
			if(prob(10))
				to_chat(mob, pick("<span class='warning'>Your skin feels very tight.</span>", "<span class='warning'>Your blood boils!</span>"))
				mob.take_organ_damage(8)
			if(prob(20))
				mob.say(pick("You look delicious.", "Going to... devour you...", "Hsssshhhhh!"))
			if(prob(8))
				to_chat(mob, "<span class='warning'>You can feel... something...inside you.</span>")
		if(5)
			to_chat(mob, "<span class='warning'>Your skin feels impossibly calloused...</span>")
			mob.adjustToxLoss(10)
			mob.updatehealth()
			if(prob(40))
				if(gibbed)
					return
				gibs(mob)
				gibbed = 1
				mob.Alienize()

// --- Robotic Transformation (was /datum/disease/robotic_transformation) ------
// Cured by Copper (chance 50). MoMMI variant is the /mommi subtype.
/datum/disease2/effect/robotic_transformation
	name = "Robotic Transformation"
	desc = "R2D2 Nanomachines. Converts the victim into a cyborg."
	stage = 1
	badness = EFFECT_DANGER_DEADLY
	restricted = 2
	chance = 100
	max_chance = 100
	var/gibbed = 0
	var/robot_type = "Cyborg"

/datum/disease2/effect/robotic_transformation/mommi
	name = "MoMMI Transformation"
	desc = "R2D2 Autistnanites. Converts the victim into a MoMMI."
	robot_type = "MoMMI"

/datum/disease2/effect/robotic_transformation/activate(var/mob/living/carbon/mob)
	if(mob.reagents && mob.reagents.has_reagent(COPPER) && prob(50))
		if(virus.stage > 1)
			virus.stage--
		else
			virus.cure(mob)
		return
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(8))
				to_chat(mob, "Your joints feel stiff.")
				mob.take_organ_damage(1)
			if(prob(9))
				to_chat(mob, "<span class='warning'>Beep... boop...</span>")
			if(prob(9))
				to_chat(mob, "<span class='warning'>Boop... beeep...</span>")
		if(3)
			if(prob(8))
				to_chat(mob, "<span class='warning'>Your joints feel very stiff.</span>")
				mob.take_organ_damage(1)
			if(prob(8))
				mob.say(pick("Beep, boop", "beep, beep!", "Boop boop!"))
			if(prob(10))
				to_chat(mob, "Your skin feels loose.")
				mob.take_organ_damage(5)
			if(prob(4))
				to_chat(mob, "<span class='warning'>You feel a stabbing pain in your head.</span>")
				mob.Paralyse(2)
			if(prob(4))
				to_chat(mob, "<span class='warning'>You can feel something move...inside.</span>")
		if(4)
			if(prob(10))
				to_chat(mob, "<span class='warning'>Your skin feels very loose.</span>")
				mob.take_organ_damage(8)
			if(prob(20))
				mob.say(pick("beep, beep!", "Boop bop boop beep.", "kkkiiiill mmme", "I wwwaaannntt tttoo dddiiieeee..."))
			if(prob(8))
				to_chat(mob, "<span class='warning'>You can feel... something...inside you.</span>")
		if(5)
			to_chat(mob, "<span class='warning'>Your skin feels as if it's about to burst off...</span>")
			mob.adjustToxLoss(10)
			mob.updatehealth()
			if(prob(40))
				if(gibbed)
					return
				gibs(mob)
				gibbed = 1
				if(ishuman(mob) && !jobban_isbanned(mob, robot_type))
					var/mob/living/carbon/human/H = mob
					switch(robot_type)
						if("Cyborg")
							H.Robotize()
						if("MoMMI")
							H.MoMMIfy()
				else
					mob.death(1)

// --- Wendigo Transformation (was /datum/disease/wendigo_transformation) ------
// curable = 0: no cure, just the slow descent into a wendigo.
/datum/disease2/effect/wendigo_transformation
	name = "Unknown"
	desc = "The host slowly becomes a wendigo."
	stage = 1
	badness = EFFECT_DANGER_DEADLY
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/wendigo_transformation/activate(var/mob/living/carbon/mob)
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/H = mob
	switch(virus ? virus.stage : 0)
		if(2)
			if(prob(8))
				to_chat(H, "<span class='warning'>Your stomach grumbles.</span>")
			if(prob(8))
				to_chat(H, "<span class='notice'>You feel peckish.</span>")
		if(3)
			if(prob(12))
				to_chat(H, "<span class='warning'>So hungry.</span>")
				H.burn_calories(20)
			if(prob(7))
				to_chat(H, "<span class='notice'>Your stomach feels empty.</span>")
				H.vomit()
		if(4)
			if(prob(25))
				to_chat(H, "<span class='warning'>Hunger...</span>")
				H.burn_calories(100)
			if(prob(15))
				to_chat(H, "<span class='warning'>Who are we?</span>")
				H.hallucination += 10
		if(5)
			if(prob(50))
				to_chat(H, "<span class='warning'>Our mind hurts.</span>")
				H.adjustBrainLoss(25)
				H.hallucination += 20
			if(prob(15))
				var/mob/living/simple_animal/hostile/wendigo/human/W = new/mob/living/simple_animal/hostile/wendigo/human(H.loc)
				W.names += H.real_name
				H.drop_all()
				qdel(H)

// --- Retrovirus (was /datum/disease/dna_retrovirus) -------------------------
// Old code picked ONE cure per instance in New() - rest (60%) or Ryetalyn (40%).
// Faithfully honours both cure paths here (rest OR Ryetalyn) rather than the
// per-instance random pick, which has no clean virus2 analog.
/datum/disease2/effect/dna_retrovirus
	name = "Retrovirus"
	desc = "A DNA-altering retrovirus that constantly scrambles the host's genome."
	stage = 1
	badness = EFFECT_DANGER_HARMFUL
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/dna_retrovirus/activate(var/mob/living/carbon/mob)
	if(mob.reagents && mob.reagents.has_reagent(RYETALYN) && prob(6))
		virus.cure(mob)
		return
	switch(virus ? virus.stage : 0)
		if(1)
			if(mob.lying && prob(30))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(8))
				to_chat(mob, "<span class='warning'>Your head hurts.</span>")
			if(prob(9))
				to_chat(mob, "You feel a tingling sensation in your chest.")
			if(prob(9))
				to_chat(mob, "<span class='warning'>You feel angry.</span>")
		if(2)
			if(mob.lying && prob(20))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(8))
				to_chat(mob, "<span class='warning'>Your skin feels loose.</span>")
			if(prob(10))
				to_chat(mob, "You feel very strange.")
			if(prob(4))
				to_chat(mob, "<span class='warning'>You feel a stabbing pain in your head!</span>")
				mob.Paralyse(2)
			if(prob(4))
				to_chat(mob, "<span class='warning'>Your stomach churns.</span>")
		if(3)
			if(mob.lying && prob(20))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(10))
				to_chat(mob, "<span class='warning'>Your entire body vibrates.</span>")
			if(prob(35))
				scramble(prob(50), mob, rand(15, 45))
		if(4)
			if(mob.lying && prob(5))
				to_chat(mob, "<span class='notice'>You feel better.</span>")
				virus.cure(mob)
				return
			if(prob(60))
				scramble(prob(50), mob, rand(50, 75))


// ============================================================================
// Advance-engine symptoms used by the 5 presets (cold=sneeze, flu=cough,
// voice_change, heal, hullucigen=hallucigen). The old /datum/symptom gated on
// prob(SYMPTOM_ACTIVATION_PROB) (=3) each tick, so chance = 3 reproduces that.
// The advance engine's generative/mutation/cure machinery is functionally
// duplicated by virus2's own crafting, so only these concrete symptoms port.
// ============================================================================

// --- Sneezing (was /datum/symptom/sneeze) -----------------------------------
/datum/disease2/effect/adv_sneeze
	name = "Sneezing"
	desc = "Sniffles at first, building to full sneezes that spread the disease."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR
	restricted = 2
	chance = 3
	max_chance = 3

/datum/disease2/effect/adv_sneeze/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(1, 2, 3)
			mob.emote("sniff")
		else
			mob.emote("sneeze")
			// Old bonus: forces an extra-range AIRBORNE spread. In virus2 the
			// disease's own airborne vector + range handles propagation.

// --- Cough (was /datum/symptom/cough) ---------------------------------------
/datum/disease2/effect/adv_cough
	name = "Cough"
	desc = "A cough that, at later stages, forces the sufferer to drop small items."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR
	restricted = 2
	chance = 3
	max_chance = 3

/datum/disease2/effect/adv_cough/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(1, 2, 3)
			to_chat(mob, "<span class='notice'>[pick("You swallow excess mucus.", "You lightly cough.")]</span>")
		else
			mob.audible_cough()
			var/obj/item/I = mob.get_active_hand()
			if(I && I.w_class < W_CLASS_MEDIUM)
				mob.drop_item(I)

// --- Voice Change (was /datum/symptom/voice_change) -------------------------
/datum/disease2/effect/adv_voice_change
	name = "Voice Change"
	desc = "Alters the sufferer's voice, sowing confusion in communication."
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	restricted = 2
	chance = 3
	max_chance = 3

/datum/disease2/effect/adv_voice_change/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(1, 2, 3, 4)
			to_chat(mob, "<span class='notice'>[pick("Your throat hurts.", "You clear your throat.")]</span>")
		else
			if(ishuman(mob))
				var/mob/living/carbon/human/H = mob
				var/random_name = H.species.makeName(H.gender, H)
				H.SetSpecialVoice(random_name)

/datum/disease2/effect/adv_voice_change/deactivate(var/mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		H.UnsetSpecialVoice()

// --- Toxic Filter / Heal (was /datum/symptom/heal) --------------------------
/datum/disease2/effect/adv_heal
	name = "Toxic Filter"
	desc = "The disease filters toxins from the host's bloodstream."
	stage = 1
	badness = EFFECT_DANGER_HELPFUL
	restricted = 2
	chance = 3
	max_chance = 3

/datum/disease2/effect/adv_heal/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(4, 5)
			mob.adjustToxLoss(-rand(1, 2))

// --- Hallucigen (was /datum/symptom/hallucigen) -----------------------------
/datum/disease2/effect/adv_hallucigen
	name = "Hallucigen"
	desc = "Brings on short bouts of hallucination."
	stage = 1
	badness = EFFECT_DANGER_HINDRANCE
	restricted = 2
	chance = 3
	max_chance = 3

/datum/disease2/effect/adv_hallucigen/activate(var/mob/living/carbon/mob)
	switch(virus ? virus.stage : 0)
		if(1, 2, 3, 4)
			to_chat(mob, "<span class='notice'>[pick("You notice someone in the corner of your eye.", "Is that footsteps?.")]</span>")
		else
			mob.hallucination += 5


// ============================================================================
// Predefined diseases bundling the migrated effects, so bottles/events/spells
// can hand them out via infect_disease2_predefined(). Purely additive: nothing
// references these categories yet - the rewire step points call sites here.
// spread carries SPREAD_BLOOD so the disease stays curable/extractable, matching
// the existing predefined diseases above.
// ============================================================================

/datum/disease2/disease/predefined/mig_flu
	form = "The Flu"
	category = DISEASE_MIG_FLU
	max_stage = 3
	spread = SPREAD_AIRBORNE | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/flu)
	origin = "H13N1 Flu Virion"

/datum/disease2/disease/predefined/mig_cold
	form = "The Cold"
	category = DISEASE_MIG_COLD
	max_stage = 3
	spread = SPREAD_AIRBORNE | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/cold)
	origin = "XY-Rhinovirus"

/datum/disease2/disease/predefined/mig_cold9
	form = "The Cold"
	category = DISEASE_MIG_COLD9
	max_stage = 3
	spread = SPREAD_CONTACT | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/cold9)
	origin = "ICE9-Rhinovirus"

/datum/disease2/disease/predefined/mig_fluspanish
	form = "Spanish Inquisition Flu"
	category = DISEASE_MIG_FLUSPANISH
	max_stage = 3
	spread = SPREAD_AIRBORNE | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/fluspanish)
	origin = "1nqu1s1t10n Flu Virion"

/datum/disease2/disease/predefined/mig_gbs
	form = "GBS"
	category = DISEASE_MIG_GBS
	max_stage = 5
	spread = SPREAD_CONTACT | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/gbs)
	origin = "Gravitokinetic Bipotential SADS+"

/datum/disease2/disease/predefined/mig_fake_gbs
	form = "GBS"
	category = DISEASE_MIG_FAKE_GBS
	max_stage = 5
	spread = SPREAD_CONTACT | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/fake_gbs)
	origin = "Gravitokinetic Bipotential SADS-"

/datum/disease2/disease/predefined/mig_brainrot
	form = "Brainrot"
	category = DISEASE_MIG_BRAINROT
	max_stage = 4
	spread = SPREAD_CONTACT | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/brainrot)
	origin = "Cryptococcus Cosmosis"

/datum/disease2/disease/predefined/mig_rhumba
	form = "The Rhumba Beat"
	category = DISEASE_MIG_RHUMBA
	max_stage = 5
	spread = SPREAD_CONTACT | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/rhumba_beat)
	origin = "Unknown"

/datum/disease2/disease/predefined/mig_pierrot
	form = "Pierrot's Throat"
	category = DISEASE_MIG_PIERROT
	max_stage = 4
	spread = SPREAD_AIRBORNE | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/pierrot_throat)
	origin = "H0NI<42 Virus"

/datum/disease2/disease/predefined/mig_kingston
	form = "Yildun Infectious Fusobacter Syndrome"
	category = DISEASE_MIG_KINGSTON
	max_stage = 4
	spread = SPREAD_CONTACT | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/kingston)
	origin = "Baccilli Yiffus"

/datum/disease2/disease/predefined/mig_wizarditis
	form = "Wizarditis"
	category = DISEASE_MIG_WIZARDITIS
	max_stage = 4
	spread = SPREAD_AIRBORNE | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/wizarditis_legacy)
	origin = "Rincewindus Vulgaris"

/datum/disease2/disease/predefined/mig_magnitis
	form = "Magnitis"
	category = DISEASE_MIG_MAGNITIS
	max_stage = 4
	spread = SPREAD_AIRBORNE | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/magnitis_legacy)
	origin = "Fukkos Miracos"

/datum/disease2/disease/predefined/mig_retrovirus
	form = "Retrovirus"
	category = DISEASE_MIG_RETROVIRUS
	max_stage = 4
	spread = SPREAD_CONTACT | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/dna_retrovirus)
	origin = "Retrovirus"

/datum/disease2/disease/predefined/mig_petrification
	form = "Rapid Petrification"
	category = DISEASE_MIG_PETRIFICATION
	max_stage = 4
	infectionchance = 0
	infectionchance_base = 0
	spread = SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/petrification_warning, new /datum/disease2/effect/petrification)
	origin = "Rapid Petrification Virus 11Y-ASD"
