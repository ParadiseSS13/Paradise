/datum/quirk/freerunning
	name = "Freerunning"
	desc = "Una buena flexibilidad y agilidad. Te subes a mesas como si fueras una pluma!"
	value = 2
	mob_trait = TRAIT_FREERUNNING
	gain_text = "<span class='notice'>Sientes unos pies muy ligeros!</span>"
	lose_text = "<span class='danger'>Agh, que pies mas pesados.</span>"
	medical_record_text = "Paciente paso por arriba del promedio el examen de cardio."

/datum/quirk/unamasamigazo
	name = "Tolerante al Alcohol"
	desc = "Desde que has comenzado a beber has sido consiente de tu gran tolerancia."
	value = 1
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>El alcohol para ti es una bebida cualquiera.</span>"
	lose_text = "<span class='danger'>Ya no tienes mucha certeza de tu tolerancia al alcohol.</span>"
	medical_record_text = "Paciente diagnosticado con gran tolerancia al alcohol."

/datum/quirk/vorestation
	name = "Apetito Imparable"
	desc = "Ni los medicos saben como funciona tu metabolismo, eres incapaz de engordar."
	value = 1
	mob_trait = TRAIT_NOFAT
	gain_text = "<span class='notice'>A comer, a comer.</span>"
	lose_text = "<span class='danger'>Deja de comer, deja de comer.</span>"
	medical_record_text = "Paciente incapaz de engordar."

/datum/quirk/sans
	name = "Acento Comico"
	desc = "Nadie sabe como le haces para hablar asi. (A excepcion del payaso)"
	value = 2
	mob_trait = TRAIT_COMIC_SANS
	gain_text = "<span class='notice'>eeeeeheheeehehehe.</span>"
	lose_text = "<span class='danger'>...</span>"
	medical_record_text = "Paciente en posesion de un acento muy particular."

/datum/quirk/dorime
	name = "Espiritual"
	desc = "Tienes buenas relaciones con los dioses con tendencias a ser escuchado, o quizas no."
	value = 1
	mob_trait = TRAIT_AMEN
	gain_text = "<span class='notice'>Dioses vengan a mi.</span>"
	lose_text = "<span class='danger'>Perdistes tu confianza con los dioses.</span>"

/datum/quirk/hudmedimplant
	name = "Implante Medhud"
	desc = "Empiezas con un implante de MedHud."
	value = 5
	gain_text = "<span class='notice'>Ves unas barras flotando en seres vivos.</span>"
	medical_record_text = "Paciente implantado con MedHud."

/datum/quirk/hudmedimplant/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/internal/cyberimp/eyes/hud/medical/implant = new
	implant.insert(H)

/datum/quirk/nutriimplant
	name = "Implante Nutriment"
	desc = "Empiezas con un implante de Nutriment."
	value = 5
	gain_text = "<span class='notice'>Ya no te necesito, chef.</span>"
	medical_record_text = "Paciente implantado con Nutriment."

/datum/quirk/nutriimplant/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/internal/cyberimp/chest/nutriment/implant = new
	implant.insert(H)

/datum/quirk/huddiagimplant
	name = "Implante DiagnosticHUD"
	desc = "Empiezas con un implante de DiagnosticHUD."
	value = 1
	gain_text = "<span class='notice'>Ves unas barras flotantes en seres sinteticos.</span>"
	medical_record_text = "Paciente implantado con DiagnosticHUD."

/datum/quirk/huddiagimplant/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic/implant = new
	implant.insert(H)

/datum/quirk/mesonimplant
	name = "Implante Meson"
	desc = "Empiezas con un implante de meson."
	value = 2
	gain_text = "<span class='notice'>Lo puedes ver todo.</span>"
	medical_record_text = "Paciente implantado con Meson."

/datum/quirk/mesonimplant/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/internal/eyes/cybernetic/meson/implant = new
	implant.insert(H)

/datum/quirk/chadasfuck
	name = "Verdadera Robustez"
	desc = "Has hecho tanto ejercicio que te sientes invencible, tienes mas vida de lo usual."
	value = 6
	gain_text = "<span class='danger'>Un extintor es juego de nenes.</span>"
	lose_text = "<span class='notice'>No deberias jugartela mucho, siendo tan debil.</span>"
	medical_record_text = "Paciente tiene una resistencia destacable."

/datum/quirk/chadasfuck/add()
	quirk_holder.dna.species.total_health += 25

/datum/quirk/jackichanlol
	name = "Resiliente"
	desc = "Eres muy resiliente, tienes una ligera defensa de ataques."
	value = 5
	gain_text = "<span class='danger'>Puedes aguantar de todo.</span>"
	lose_text = "<span class='notice'>Te sientes menos resiliente.</span>"
	medical_record_text = "Paciente tiene una defensa destacable."

/datum/quirk/jackichanlol/add()
	quirk_holder.dna.species.armor += 3

/datum/quirk/chadpunches
	name = "Robusto"
	desc = "Tienes experiencia de combate, nunca fallas tus golpes y puedes dar unos golpes excepcionales."
	value = 4
	gain_text = "<span class='danger'>Punch-Out!</span>"
	lose_text = "<span class='notice'>Te sientes oxidado de tu entrenamiento.</span>"

/datum/quirk/chadpunches/add()
	quirk_holder.dna.species.punchdamagelow += 1 //Base es 0 y queda en 1 esto implica que no puedes fallar un puñetazo
	quirk_holder.dna.species.punchdamagehigh += 1 //Base es 9 y queda en 10
