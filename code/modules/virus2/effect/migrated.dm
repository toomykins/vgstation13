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
	affect_voice = 1
	affect_voice_active = 1

// Faithful port of the old say.dm HONK-garble: replaces up to `stage` words with
// HONK, prob(3 * stage) each, skipping words with speech modifiers.
/datum/disease2/effect/pierrot_throat/affect_mob_voice(var/datum/speech/speech)
	if(!virus)
		return
	var/list/temp_message = splittext(speech.message, " ")
	var/list/pick_list = list()
	for(var/i = 1, i <= temp_message.len, i++)
		pick_list += i
	for(var/i = 1, ((i <= virus.stage) && (i <= temp_message.len)), i++)
		if(prob(3 * virus.stage))
			var/H = pick(pick_list)
			if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":"))
				continue
			temp_message[H] = "HONK"
			pick_list -= H
		speech.message = jointext(temp_message, " ")

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


// Advance-preset diseases (the culture bottles that used /datum/disease/advance/*).
/datum/disease2/disease/predefined/mig_adv_cold
	form = "Cold"
	category = DISEASE_MIG_ADV_COLD
	max_stage = 4
	spread = SPREAD_AIRBORNE | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/adv_sneeze)
	origin = "Engineered Cold"

/datum/disease2/disease/predefined/mig_adv_flu
	form = "Flu"
	category = DISEASE_MIG_ADV_FLU
	max_stage = 4
	spread = SPREAD_AIRBORNE | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/adv_cough)
	origin = "Engineered Flu"

/datum/disease2/disease/predefined/mig_adv_voice
	form = "Epiglottis Mutation"
	category = DISEASE_MIG_ADV_VOICE
	max_stage = 5
	spread = SPREAD_AIRBORNE | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/adv_voice_change)
	origin = "Epiglottis Virion"

/datum/disease2/disease/predefined/mig_adv_heal
	form = "Liver Enhancer"
	category = DISEASE_MIG_ADV_HEAL
	max_stage = 5
	spread = SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/adv_heal)
	origin = "Liver Enhancement Virion"

/datum/disease2/disease/predefined/mig_adv_hallucigen
	form = "Reality Impairment"
	category = DISEASE_MIG_ADV_HALLUCIGEN
	max_stage = 5
	spread = SPREAD_AIRBORNE | SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/adv_hallucigen)
	origin = "Hullucigen Virion"


// --- Jungle Fever (was /datum/disease/jungle_fever, madmonkey antag) ---------
// The disease makes its host the MADMONKEY antag; spread is the special monkey-
// bite handling in monkey/combat.dm and other_mobs.dm (rewired to this disease).
/datum/disease2/effect/jungle_fever
	name = "Jungle Fever"
	desc = "Kongey Vibrion M-909. The host goes ape."
	stage = 1
	badness = EFFECT_DANGER_HARMFUL
	restricted = 2
	chance = 100
	max_chance = 100

/datum/disease2/effect/jungle_fever/activate(var/mob/living/carbon/mob)
	if(!mob.mind || mob.mind.GetRole(MADMONKEY))
		return
	var/datum/role/madmonkey/MM = new
	MM.AssignToRole(mob.mind, 1)
	MM.Greet(GREET_DEFAULT)
	MM.OnPostSetup()
	MM.AnnounceObjectives()

/datum/disease2/disease/predefined/mig_jungle_fever
	form = "Jungle Fever"
	category = DISEASE_MIG_JUNGLE
	max_stage = 1
	infectionchance = 0
	infectionchance_base = 0
	spread = SPREAD_BLOOD
	effects = list(new /datum/disease2/effect/jungle_fever)
	origin = "Kongey Vibrion M-909"

// TRUE if the mob currently carries the migrated Jungle Fever disease.
/mob/living/proc/has_jungle_fever()
	for(var/id in virus2)
		var/datum/disease2/disease/D = virus2[id]
		if(D.category == DISEASE_MIG_JUNGLE)
			return TRUE
	return FALSE
