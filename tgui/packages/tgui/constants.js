// UI states, which are mirrored from the BYOND code.
export const UI_INTERACTIVE = 2;
export const UI_UPDATE = 1;
export const UI_DISABLED = 0;
export const UI_CLOSE = -1;

// All game related colors are stored here
export const COLORS = {
  // Department colors
  department: {
    captain: '#c06616',
    security: '#e74c3c',
    medbay: '#3498db',
    science: '#9b59b6',
    engineering: '#f1c40f',
    cargo: '#f39c12',
    centcom: '#00c100',
    other: '#c38312',
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

export const RADIO_CHANNELS = [
  {
    name: 'Syndicate',
    freq: 1213,
    color: '#6D3F40',
  },
  {
    name: 'SyndTeam',
    freq: 1244,
    color: '#6D3F40',
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
    color: '#5C5C7C',
  },
  {
    name: 'Special Ops',
    freq: 1341,
    color: '#686868',
  },
  {
    name: 'Supply',
    freq: 1347,
    color: '#7F6539',
  },
  {
    name: 'Service',
    freq: 1349,
    color: '#80A000',
  },
  {
    name: 'Science',
    freq: 1351,
    color: '#993399',
  },
  {
    name: 'Command',
    freq: 1353,
    color: '#204090',
  },
  {
    name: 'Medical',
    freq: 1355,
    color: '#009190',
  },
  {
    name: 'Engineering',
    freq: 1357,
    color: '#A66300',
  },
  {
    name: 'Security',
    freq: 1359,
    color: '#A30000',
  },
  {
    name: 'AI Private',
    freq: 1343,
    color: '#FF00FF',
  },
  {
    name: 'Common',
    freq: 1459,
    color: '#408010',
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
];

export const getGasLabel = (gasId, fallbackValue) => {
  const gasSearchString = String(gasId).toLowerCase();
  const gas = GASES.find(gas => gas.id === gasSearchString
    || gas.name.toLowerCase() === gasSearchString);
  return gas && gas.label
    || fallbackValue
    || gasId;
};

export const getGasColor = gasId => {
  const gasSearchString = String(gasId).toLowerCase();
  const gas = GASES.find(gas => gas.id === gasSearchString
    || gas.name.toLowerCase() === gasSearchString);
  return gas && gas.color;
};
