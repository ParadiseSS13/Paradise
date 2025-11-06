import { range } from 'common/collections';
import { ReactNode } from 'react';
import { Box, Button, Icon, Image, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

const ROWS = 5;
const COLUMNS = 9;

const getColumnsAmount = (mode: number): number => {
  if (mode === 0) {
    return 5;
  }
  return 9;
};

const BUTTON_DIMENSIONS = '64px';

type GridSpotKey = string;

const getGridSpotKey = (spot: [number, number]): GridSpotKey => {
  return `${spot[0]}/${spot[1]}`;
};

const CornerText = (props: { align: 'left' | 'right'; children: string }): ReactNode => {
  const { align, children } = props;

  return (
    <Box
      style={{
        position: 'absolute',
        left: align === 'left' ? '6px' : '48px', // spacing letters is hard, but it looks good like this
        textAlign: align,
        textShadow: '2px 2px 2px #000',
        top: '2px',
      }}
    >
      {children}
    </Box>
  );
};

type AlternateAction = {
  icon: string;
  text: string;
};

const ALTERNATE_ACTIONS: Record<string, AlternateAction> = {
  enable_internals: {
    icon: 'lungs',
    text: 'Enable internals',
  },

  disable_internals: {
    icon: 'lungs',
    text: 'Disable internals',
  },

  enable_lock: {
    icon: 'lock',
    text: 'Enable lock',
  },

  disable_lock: {
    icon: 'unlock',
    text: 'Disable lock',
  },

  suit_sensors: {
    icon: 'tshirt',
    text: 'Adjust suit sensors',
  },

  remove_accessory: {
    icon: 'medal',
    text: 'Remove accessory',
  },

  dislodge_headpocket: {
    icon: 'head-side-virus', // I can't find a better icon, this will do
    text: 'Dislodge headpocket',
  },
};

const SLOTS: Record<
  string,
  {
    displayName: string;
    gridSpot: GridSpotKey;
    image?: string;
    additionalComponent?: ReactNode;
  }
> = {
  eyes: {
    displayName: 'eyewear',
    gridSpot: getGridSpotKey([0, 0]),
    image: 'inventory-glasses.png',
  },

  head: {
    displayName: 'headwear',
    gridSpot: getGridSpotKey([0, 1]),
    image: 'inventory-head.png',
  },

  mask: {
    displayName: 'mask',
    gridSpot: getGridSpotKey([1, 1]),
    image: 'inventory-mask.png',
  },

  neck: {
    displayName: 'neck',
    gridSpot: getGridSpotKey([1, 0]),
    image: 'inventory-neck.png',
  },

  pet_collar: {
    displayName: 'collar',
    gridSpot: getGridSpotKey([1, 1]),
    image: 'inventory-collar.png',
  },

  right_ear: {
    displayName: 'right ear',
    gridSpot: getGridSpotKey([0, 2]),
    image: 'inventory-ears.png',
  },

  left_ear: {
    displayName: 'left ear',
    gridSpot: getGridSpotKey([1, 2]),
    image: 'inventory-ears.png',
  },

  parrot_headset: {
    displayName: 'headset',
    gridSpot: getGridSpotKey([1, 2]),
    image: 'inventory-ears.png',
  },

  handcuffs: {
    displayName: 'handcuffs',
    gridSpot: getGridSpotKey([1, 3]),
  },

  legcuffs: {
    displayName: 'legcuffs',
    gridSpot: getGridSpotKey([1, 4]),
  },

  jumpsuit: {
    displayName: 'uniform',
    gridSpot: getGridSpotKey([2, 0]),
    image: 'inventory-uniform.png',
  },

  suit: {
    displayName: 'suit',
    gridSpot: getGridSpotKey([2, 1]),
    image: 'inventory-suit.png',
  },

  gloves: {
    displayName: 'gloves',
    gridSpot: getGridSpotKey([2, 2]),
    image: 'inventory-gloves.png',
  },

  right_hand: {
    displayName: 'right hand',
    gridSpot: getGridSpotKey([2, 3]),
    image: 'inventory-hand_r.png',
    additionalComponent: <CornerText align="left">R</CornerText>,
  },

  left_hand: {
    displayName: 'left hand',
    gridSpot: getGridSpotKey([2, 4]),
    image: 'inventory-hand_l.png',
    additionalComponent: <CornerText align="right">L</CornerText>,
  },

  shoes: {
    displayName: 'shoes',
    gridSpot: getGridSpotKey([3, 1]),
    image: 'inventory-shoes.png',
  },

  suit_storage: {
    displayName: 'suit storage',
    gridSpot: getGridSpotKey([4, 0]),
    image: 'inventory-suit_storage.png',
  },

  id: {
    displayName: 'ID',
    gridSpot: getGridSpotKey([4, 1]),
    image: 'inventory-id.png',
  },

  belt: {
    displayName: 'belt',
    gridSpot: getGridSpotKey([4, 2]),
    image: 'inventory-belt.png',
  },

  back: {
    displayName: 'backpack',
    gridSpot: getGridSpotKey([4, 3]),
    image: 'inventory-back.png',
  },

  left_pocket: {
    displayName: 'left pocket',
    gridSpot: getGridSpotKey([3, 4]),
    image: 'inventory-pocket.png',
  },

  right_pocket: {
    displayName: 'right pocket',
    gridSpot: getGridSpotKey([3, 3]),
    image: 'inventory-pocket.png',
  },

  pda: {
    displayName: 'PDA',
    gridSpot: getGridSpotKey([4, 4]),
    image: 'inventory-pda.png',
  },
};

const ALTERNATIVE_SLOTS: Record<
  string,
  {
    displayName: string;
    gridSpot: GridSpotKey;
    image?: string;
    additionalComponent?: ReactNode;
  }
> = {
  eyes: {
    displayName: 'eyewear',
    gridSpot: getGridSpotKey([0, 0]),
    image: 'inventory-glasses.png',
  },

  head: {
    displayName: 'headwear',
    gridSpot: getGridSpotKey([0, 1]),
    image: 'inventory-head.png',
  },

  mask: {
    displayName: 'mask',
    gridSpot: getGridSpotKey([1, 1]),
    image: 'inventory-mask.png',
  },

  neck: {
    displayName: 'neck',
    gridSpot: getGridSpotKey([1, 0]),
    image: 'inventory-neck.png',
  },

  pet_collar: {
    displayName: 'collar',
    gridSpot: getGridSpotKey([1, 1]),
    image: 'inventory-collar.png',
  },

  right_ear: {
    displayName: 'right ear',
    gridSpot: getGridSpotKey([0, 2]),
    image: 'inventory-ears.png',
  },

  left_ear: {
    displayName: 'left ear',
    gridSpot: getGridSpotKey([1, 2]),
    image: 'inventory-ears.png',
  },

  parrot_headset: {
    displayName: 'headset',
    gridSpot: getGridSpotKey([1, 2]),
    image: 'inventory-ears.png',
  },

  handcuffs: {
    displayName: 'handcuffs',
    gridSpot: getGridSpotKey([1, 3]),
  },

  legcuffs: {
    displayName: 'legcuffs',
    gridSpot: getGridSpotKey([1, 4]),
  },

  jumpsuit: {
    displayName: 'uniform',
    gridSpot: getGridSpotKey([2, 0]),
    image: 'inventory-uniform.png',
  },

  suit: {
    displayName: 'suit',
    gridSpot: getGridSpotKey([2, 1]),
    image: 'inventory-suit.png',
  },

  gloves: {
    displayName: 'gloves',
    gridSpot: getGridSpotKey([2, 2]),
    image: 'inventory-gloves.png',
  },

  right_hand: {
    displayName: 'right hand',
    gridSpot: getGridSpotKey([4, 4]),
    image: 'inventory-hand_r.png',
    additionalComponent: <CornerText align="left">R</CornerText>,
  },

  left_hand: {
    displayName: 'left hand',
    gridSpot: getGridSpotKey([4, 5]),
    image: 'inventory-hand_l.png',
    additionalComponent: <CornerText align="right">L</CornerText>,
  },

  shoes: {
    displayName: 'shoes',
    gridSpot: getGridSpotKey([3, 1]),
    image: 'inventory-shoes.png',
  },

  suit_storage: {
    displayName: 'suit storage',
    gridSpot: getGridSpotKey([4, 0]),
    image: 'inventory-suit_storage.png',
  },

  id: {
    displayName: 'ID',
    gridSpot: getGridSpotKey([4, 1]),
    image: 'inventory-id.png',
  },

  belt: {
    displayName: 'belt',
    gridSpot: getGridSpotKey([4, 2]),
    image: 'inventory-belt.png',
  },

  back: {
    displayName: 'backpack',
    gridSpot: getGridSpotKey([4, 3]),
    image: 'inventory-back.png',
  },

  left_pocket: {
    displayName: 'left pocket',
    gridSpot: getGridSpotKey([4, 7]),
    image: 'inventory-pocket.png',
  },

  right_pocket: {
    displayName: 'right pocket',
    gridSpot: getGridSpotKey([4, 6]),
    image: 'inventory-pocket.png',
  },

  pda: {
    displayName: 'PDA',
    gridSpot: getGridSpotKey([4, 8]),
    image: 'inventory-pda.png',
  },
};

enum ObscuringLevel {
  Completely = 1,
  Hidden = 2,
}

type Interactable = {
  interacting: BooleanLike;
  cantstrip: BooleanLike;
};

/**
 * Some possible options:
 *
 * null - No interactions, no item, but is an available slot
 * { interacting: 1 } - No item, but we're interacting with it
 * { icon: icon, name: name } - An item with no alternate actions
 *   that we're not interacting with.
 * { icon, name, interacting: 1 } - An item with no alternate actions
 *   that we're interacting with.
 */
type StripMenuItem =
  | null
  | Interactable
  | ((
      | {
          icon: string;
          name: string;
          alternates?: Array<string>;
        }
      | {
          obscured: ObscuringLevel;
        }
    ) &
      Partial<Interactable>);

type StripMenuData = {
  items: Record<keyof typeof SLOTS, StripMenuItem>;
  name: string;
  show_mode: number;
};

export const StripMenu = (props) => {
  const { act, data } = useBackend<StripMenuData>();

  const gridSpots = new Map<GridSpotKey, string>();
  if (data.show_mode === 0) {
    for (const key of Object.keys(data.items)) {
      gridSpots.set(SLOTS[key].gridSpot, key);
    }
  } else {
    for (const key of Object.keys(data.items)) {
      gridSpots.set(ALTERNATIVE_SLOTS[key].gridSpot, key);
    }
  }

  const get_button_transparency = (item) => {
    if (item?.cantstrip) {
      return false;
    }
    if (item?.interacting) {
      return false;
    }
    return true;
  };

  const get_button_color = (item) => {
    if (item?.interacting) {
      return 'average';
    }
    return null;
  };

  const disable_background_hover = (item) => {
    if (item?.cantstrip) {
      return 'transparent';
    }
    return 'none';
  };

  if (gridSpots.size === 0) {
    return (
      <Window
        title={`Stripping ${data.name}`}
        width={getColumnsAmount(data.show_mode) * 64 + 6 * (getColumnsAmount(data.show_mode) + 1)}
        height={390}
        theme="nologo"
      >
        <Window.Content style={{ backgroundColor: 'rgba(0, 0, 0, 0.5)' }}>
          <Stack fill>
            <Stack.Item bold grow textAlign="center" align="center" color="average">
              No slots
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window
      title={`Stripping ${data.name}`}
      width={getColumnsAmount(data.show_mode) * 64 + 6 * (getColumnsAmount(data.show_mode) + 1)}
      height={390}
      theme="nologo"
    >
      <Window.Content style={{ backgroundColor: 'rgba(0, 0, 0, 0.5)' }}>
        <Stack fill vertical>
          {range(0, ROWS).map((row) => (
            <Stack.Item key={row}>
              <Stack fill>
                {range(0, getColumnsAmount(data.show_mode)).map((column) => {
                  const key = getGridSpotKey([row, column]);
                  const keyAtSpot = gridSpots.get(key);

                  if (!keyAtSpot) {
                    return (
                      <Stack.Item
                        key={key}
                        style={{
                          width: BUTTON_DIMENSIONS,
                          height: BUTTON_DIMENSIONS,
                        }}
                      />
                    );
                  }

                  const item = data.items[keyAtSpot];
                  const slot = SLOTS[keyAtSpot];

                  let alternateActions: Array<string> | undefined;

                  let content;
                  let tooltip;

                  if (item === null) {
                    tooltip = slot.displayName;
                  } else if ('name' in item) {
                    content = (
                      <Image
                        src={`data:image/jpeg;base64,${item.icon}`}
                        height="100%"
                        width="100%"
                        style={{
                          imageRendering: 'pixelated',
                          verticalAlign: 'middle',
                        }}
                      />
                    );

                    tooltip = item.name;
                  } else if ('obscured' in item) {
                    content = (
                      <Icon
                        name={item.obscured === ObscuringLevel.Completely ? 'ban' : 'eye-slash'}
                        size={3}
                        ml={0}
                        mt={2.5}
                        color="white"
                        style={{
                          textAlign: 'center',
                          height: '100%',
                          width: '100%',
                        }}
                      />
                    );

                    tooltip = `obscured ${slot.displayName}`;
                  }

                  if (item !== null) {
                    if ('alternates' in item) {
                      if (item.alternates !== null) {
                        alternateActions = item.alternates;
                      }
                    }
                  }

                  return (
                    <Stack.Item
                      key={key}
                      style={{
                        width: BUTTON_DIMENSIONS,
                        height: BUTTON_DIMENSIONS,
                      }}
                    >
                      <Box
                        style={{
                          position: 'relative',
                          width: '100%',
                          height: '100%',
                        }}
                      >
                        <Button
                          onClick={() => {
                            act('use', {
                              key: keyAtSpot,
                            });
                          }}
                          fluid
                          color={get_button_color(item)}
                          tooltip={tooltip}
                          style={{
                            position: 'relative',
                            width: '100%',
                            height: '100%',
                            padding: 0,
                            backgroundColor: disable_background_hover(item),
                          }}
                        >
                          {slot.image && (
                            <Image
                              src={resolveAsset(slot.image)}
                              opacity={0.7}
                              style={{
                                position: 'absolute',
                                width: '32px',
                                height: '32px',
                                left: '50%',
                                top: '50%',
                                transform: 'translateX(-50%) translateY(-50%) scale(2)',
                              }}
                            />
                          )}

                          <Box style={{ position: 'relative' }}>{content}</Box>

                          {slot.additionalComponent}
                        </Button>
                        <Stack direction="row-reverse">
                          {alternateActions !== undefined &&
                            alternateActions.map((actionKey, index) => {
                              const buttonOffset = index * 1.8;
                              return (
                                <Stack.Item key={index} width="100%">
                                  <Button
                                    onClick={() => {
                                      act('alt', {
                                        key: keyAtSpot,
                                        action_key: actionKey,
                                      });
                                    }}
                                    tooltip={ALTERNATE_ACTIONS[actionKey].text}
                                    width="1.8em"
                                    style={{
                                      background: 'rgba(0, 0, 0, 0.6)',
                                      position: 'absolute',
                                      bottom: 0,
                                      right: `${buttonOffset}em`,
                                      zIndex: 2 + index,
                                    }}
                                  >
                                    <Icon name={ALTERNATE_ACTIONS[actionKey].icon} />
                                  </Button>
                                </Stack.Item>
                              );
                            })}
                        </Stack>
                      </Box>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
