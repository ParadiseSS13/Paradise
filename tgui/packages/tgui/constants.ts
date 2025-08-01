// UI states, which are mirrored from the BYOND code.
export const UI_INTERACTIVE = 2;
export const UI_UPDATE = 1;
export const UI_DISABLED = 0;
export const UI_CLOSE = -1;

// All game related colors are stored here
export const COLORS = {
  // Department colors
  department: {
    command: '#526aff',
    security: '#CF0000',
    medical: '#009190',
    science: '#993399',
    engineering: '#A66300',
    supply: '#9F8545',
    service: '#80A000',
    centcom: '#78789B',
    other: '#C38312',
  },
  // Damage type colors
  damageType: {
    oxy: '#3498db',
    toxin: '#2ecc71',
    burn: '#e67e22',
    brute: '#e74c3c',
  },
};

// Colors defined in CSS
export const CSS_COLORS = [
  'black',
  'white',
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
  'good',
  'average',
  'bad',
  'label',
];

export type RadioChannel = {
  name: string;
  freq: number;
  color: string;
};

export const RADIO_CHANNELS: RadioChannel[] = [
  {
    name: 'Syndicate',
    freq: 1213,
    color: '#a52a2a',
  },
  {
    name: 'SyndTeam',
    freq: 1244,
    color: '#a52a2a',
  },
  {
    name: 'Red Team',
    freq: 1215,
    color: '#ff4444',
  },
  {
    name: 'Blue Team',
    freq: 1217,
    color: '#3434fd',
  },
  {
    name: 'Response Team',
    freq: 1345,
    color: '#2681a5',
  },
  {
    name: 'Special Ops',
    freq: 1341,
    color: '#2681a5',
  },
  {
    name: 'Supply',
    freq: 1347,
    color: '#b88646',
  },
  {
    name: 'Service',
    freq: 1349,
    color: '#6ca729',
  },
  {
    name: 'Science',
    freq: 1351,
    color: '#c68cfa',
  },
  {
    name: 'Command',
    freq: 1353,
    color: '#5177ff',
  },
  {
    name: 'Procedure',
    freq: 1339,
    color: '#F70285',
  },
  {
    name: 'Medical',
    freq: 1355,
    color: '#57b8f0',
  },
  {
    name: 'Medical(I)',
    freq: 1485,
    color: '#57b8f0',
  },
  {
    name: 'Engineering',
    freq: 1357,
    color: '#f37746',
  },
  {
    name: 'Security',
    freq: 1359,
    color: '#dd3535',
  },
  {
    name: 'Security(I)',
    freq: 1475,
    color: '#dd3535',
  },
  {
    name: 'AI Private',
    freq: 1343,
    color: '#d65d95',
  },
  {
    name: 'Common',
    freq: 1459,
    color: '#1ecc43',
  },
];

const GASES = [
  {
    'id': 'o2',
    'name': 'Oxygen',
    'label': 'O₂',
    'color': 'blue',
  },
  {
    'id': 'n2',
    'name': 'Nitrogen',
    'label': 'N₂',
    'color': 'red',
  },
  {
    'id': 'co2',
    'name': 'Carbon Dioxide',
    'label': 'CO₂',
    'color': 'grey',
  },
  {
    'id': 'plasma',
    'name': 'Plasma',
    'label': 'Plasma',
    'color': 'pink',
  },
  {
    'id': 'water_vapor',
    'name': 'Water Vapor',
    'label': 'H₂O',
    'color': 'grey',
  },
  {
    'id': 'nob',
    'name': 'Hyper-noblium',
    'label': 'Hyper-nob',
    'color': 'teal',
  },
  {
    'id': 'n2o',
    'name': 'Nitrous Oxide',
    'label': 'N₂O',
    'color': 'red',
  },
  {
    'id': 'no2',
    'name': 'Nitryl',
    'label': 'NO₂',
    'color': 'brown',
  },
  {
    'id': 'tritium',
    'name': 'Tritium',
    'label': 'Tritium',
    'color': 'green',
  },
  {
    'id': 'bz',
    'name': 'BZ',
    'label': 'BZ',
    'color': 'purple',
  },
  {
    'id': 'stim',
    'name': 'Stimulum',
    'label': 'Stimulum',
    'color': 'purple',
  },
  {
    'id': 'pluox',
    'name': 'Pluoxium',
    'label': 'Pluoxium',
    'color': 'blue',
  },
  {
    'id': 'miasma',
    'name': 'Miasma',
    'label': 'Miasma',
    'color': 'olive',
  },
  {
    'id': 'hydrogen',
    'name': 'Hydrogen',
    'label': 'H₂',
    'color': 'white',
  },
  {
    'id': 'ab',
    'name': 'Agent B',
    'label': 'Agent B',
    'color': 'purple',
  },
];

export const getGasLabel = (gasId, fallbackValue) => {
  const gasSearchString = String(gasId).toLowerCase();
  const gas = GASES.find((gas) => gas.id === gasSearchString || gas.name.toLowerCase() === gasSearchString);
  return (gas && gas.label) || fallbackValue || gasId;
};

export const getGasColor = (gasId) => {
  const gasSearchString = String(gasId).toLowerCase();
  const gas = GASES.find((gas) => gas.id === gasSearchString || gas.name.toLowerCase() === gasSearchString);
  return gas && gas.color;
};

export const timeAgo = (ref_time, now_time) => {
  if (ref_time > now_time) {
    return 'in the future';
  }

  // deciseconds -> seconds
  ref_time = ref_time / 10;
  now_time = now_time / 10;

  const diff = now_time - ref_time;
  if (diff > 3600) {
    const hours = Math.round(diff / 3600);
    return hours + ' hour' + (hours === 1 ? '' : 's') + ' ago';
  } else if (diff > 60) {
    const mins = Math.round(diff / 60);
    return mins + ' minute' + (mins === 1 ? '' : 's') + ' ago';
  } else {
    const secs = Math.round(diff);
    return secs + ' second' + (secs === 1 ? '' : 's') + ' ago';
  }

  return 'just now';
};
