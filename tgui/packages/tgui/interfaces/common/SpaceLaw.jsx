export const spaceLaw = {
  codes: {
    '00': {
      damageStation: {
        name: 'Damage to Station Assets',
        severity: 'minor',
        description: 'To deliberately damage the station or station property to a minor degree with malicious intent.',
      },
      workplaceHazard: {
        name: 'Workplace Hazard',
        severity: 'medium',
        description: 'To endanger the crew or station through negligent but not deliberately malicious actions.',
      },
      sabotage: {
        name: 'Sabotage',
        severity: 'major',
        description: 'To hinder the work of the crew or station through malicious actions.',
      },
    },
    '01': {
      kidnapping: {
        name: 'Kidnapping',
        severity: 'medium',
        description: 'To hold a crewmember under duress or against their will.',
      },
    },
    '02': {
      battery: {
        name: 'Battery',
        severity: 'minor',
        description: 'To use minor physical force against someone without intent to seriously injure them.',
      },
      assault: {
        name: 'Assault',
        severity: 'medium',
        description: 'To use excessive physical force against someone without the apparent intent to kill them.',
      },
      aggravatedAssault: {
        name: 'Aggravated Assault',
        severity: 'major',
        description: 'To use excessive physical force resulting in severe or life-threatening harm.',
      },
    },
    '03': {
      drugPossession: {
        name: 'Drug Possession',
        severity: 'minor',
        description:
          'The unauthorized possession of recreational use drugs such as ambrosia, krokodil, crank, meth, aranesp, bath salts, or THC.',
      },
      narcoticsDistribution: {
        name: 'Narcotics Distribution',
        severity: 'medium',
        description:
          'To distribute narcotics and other controlled substances. This includes ambrosia and space drugs. It is not illegal for them to be grown.',
      },
    },
    '04': {
      weaponPossession: {
        name: 'Possession of a Weapon',
        severity: 'medium',
        description: "To be in possession of a dangerous item that is not part of one's job.",
      },
      restrictedWeapon: {
        name: 'Possession of a Restricted Weapon',
        severity: 'major',
        description:
          'To be in unauthorized possession of restricted weapons/items such as: Guns, Batons, Harmful Chemicals, Non-Beneficial Explosives, Combat Implants (Anti-Drop, CNS Rebooter, Razorwire), MODsuit Modules (Power Kick, Stealth).',
      },
    },
    '05': {
      indecentExposure: {
        name: 'Indecent Exposure',
        severity: 'minor',
        description: 'To be intentionally and publicly unclothed.',
      },
      rioting: {
        name: 'Rioting',
        severity: 'medium',
        description: 'To partake in an unauthorized and disruptive assembly of crewmen.',
      },
      incitingRiot: {
        name: 'Inciting a Riot',
        severity: 'major',
        description: 'To attempt to stir the crew into a riot.',
      },
    },
    '06': {
      abuseEquipment: {
        name: 'Abuse of Equipment',
        severity: 'minor',
        description: 'To utilize security/non-lethal equipment in an illegitimate fashion.',
      },
      abuseConfiscated: {
        name: 'Abuse of Confiscated Equipment',
        severity: 'medium',
        description: 'To take and use equipment confiscated as evidence.',
      },
      contrabandPossession: {
        name: 'Possession of Contraband',
        severity: 'major',
        description: 'To be in the possession of contraband items.',
      },
    },
    '07': {
      pettyTheft: {
        name: 'Petty Theft',
        severity: 'minor',
        description:
          'To take items from areas one lacks access to or to take items belonging to others or the station as a whole.',
      },
      robbery: {
        name: 'Robbery',
        severity: 'medium',
        description: "To steal items from another's person.",
      },
      theft: {
        name: 'Theft',
        severity: 'major',
        description: "To steal restricted or dangerous items from either an area or one's person.",
      },
    },
    '08': {
      trespass: {
        name: 'Trespass',
        severity: 'minor',
        description:
          'To be in an area which a person lacks authorized ID access for. This counts for general areas of the station.',
      },
      majorTrespass: {
        name: 'Major Trespass',
        severity: 'major',
        description:
          'Being in a restricted area without prior authorization. This includes Security areas, Command areas (including EVA), the Engine Room, Atmos, or Toxins Research.',
      },
    },
  },
  modifiers: {
    cooperation: {
      cooperate: {
        name: 'Cooperation with Security',
        description: 'Being helpful to the members of security, revealing things during questioning.',
        timeMultiplier: 0.5,
      },
      refuseCooperate: {
        name: 'Refusal to Cooperate',
        description: 'Non-cooperative behaviour while already detained inside the brig and awaiting a sentence.',
        timeMultiplier: 1.5,
      },
    },
    surrenderResisting: {
      resistingArrest: {
        name: 'Resisting Arrest',
        description: 'To resist or impede an officer legally arresting or searching you.',
        timeAdded: 5,
      },
      surrender: {
        name: 'Surrender',
        description: 'Willfully surrendering to Security.',
        timeMultiplier: 0.5,
      },
    },
    aiding: {
      aidingAbetting: {
        name: 'Aiding and Abetting',
        description: 'To knowingly assist a criminal.',
      },
    },
    officer: {
      againstAnOfficer: {
        name: 'Offence Against an Officer',
        description:
          'To batter, assault or kidnap an Officer. An Officer is defined as any member of Security, Command, or of Dignitary status (Magistrate, Blueshield, Representative). ',
        timeAdded: 5,
      },
    },
    repeatOffender: {
      repeatOffenderFirst: {
        name: 'Repeat Offender - Second Offence',
        description: 'To be brigged for the same offense more than once.',
        timeAdded: 10,
      },
      repeatOffenderSecond: {
        name: 'Repeat Offender - Third Offence',
        description: 'To be brigged for the same offense more than once.',
        timeAdded: 20,
      },
    },
  },
  severities: {
    minor: {
      minTime: 1,
      maxTime: 5,
    },
    medium: {
      minTime: 5,
      maxTime: 10,
    },
    major: {
      minTime: 10,
      maxTime: 15,
    },
  },
};
