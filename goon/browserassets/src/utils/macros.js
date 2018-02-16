const macros = {};

function wingetMacros(newMacros) {
  const idRegex = /.*?\.(?!(?:CRTL|ALT|SHIFT)\+)(.*?)(?:\+REP)?\.command/;
  // Do NOT match macros which need crtl, alt or shift to be held down.
  for (const key in newMacros) {
    const match = idRegex.exec(key);

    if (match === null) {
      continue;
    }

    const macroID = match[1].toUpperCase();

    macros[macroID] = newMacros[key];
  }
}

const keyMap = {
  Backspace: 'BACK',
  Tab: 'TAB',
  Enter: 'ENTER',
  Pause: 'PAUSE',
  Escape: 'ESCAPE',
  Esc: 'ESCAPE',
  PageUp: 'NORTHEAST',
  PageDown: 'SOUTHEAST',
  End: 'SOUTHWEST',
  Home: 'NORTHWEST',
  ArrowLeft: 'WEST',
  ArrowUp: 'NORTH',
  ArrowRight: 'EAST',
  ArrowDown: 'SOUTH',
  Insert: 'INSERT',
  Delete: 'DELETE',
  ContextMenu: 'APPS',
};

function keyToCommand(key) {
  return keyMap[key] || macros[key.toUpperCase()] || null;
}

export default {wingetMacros, keyToCommand};
