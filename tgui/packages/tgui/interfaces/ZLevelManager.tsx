import { Button, LabeledList, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { useState } from 'react';

type JumpToCoordsProps = {
  coords: Coord3;
};

const JumpToCoords = (props: JumpToCoordsProps) => {
  const { act } = useBackend();
  const { coords } = props;
  const { x, y, z } = coords;
  return <Button onClick={() => act('jump_to_coords', { x: x, y: y, z: z })}>JMP</Button>;
};

type Coord3 = {
  x: number;
  y: number;
  z: number;
};

type Ruin = {
  name: string;
  mappath: string;
  coords: Coord3;
};

type ZLevel = {
  name: string;
  zpos: number;
  linkage: number;
  transition_tag?: string;
  traits: string[];
  neighbors: { [key: string]: number };
  ruins: Ruin[];
};

type ManagerData = {
  levels: { [key: string]: ZLevel };
};

export const ZLevelManager = () => {
  const { data } = useBackend<ManagerData>();
  const { levels } = data;

  const [activeZ, setActiveZ] = useState(1);
  const zlevel = levels[`${activeZ}`];

  const neighbor_to_element = (neighbor: ZLevel) => {
    if (neighbor === undefined) return 'None';
    if (zlevel.linkage == 0) return 'None';
    if (neighbor.zpos == zlevel.zpos) return 'Looped';
    const neighbor_zlevel = levels[`${neighbor.zpos}`];
    return (
      <Button onClick={() => setActiveZ(neighbor.zpos)}>
        {neighbor_zlevel.name} ({neighbor.zpos})
      </Button>
    );
  };

  return (
    <Window width={600} height={500} title="Z-Level Manager">
      <Window.Content scrollable>
        <Stack fill>
          <Stack.Item>
            <Section fill fitted>
              <Tabs vertical>
                {Object.values(levels).map((level, i) => (
                  <Tabs.Tab
                    key={i + 1}
                    color="transparent"
                    selected={level.zpos === activeZ}
                    onClick={() => setActiveZ(i + 1)}
                  >
                    {level.name} ({level.zpos})
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {zlevel && (
              <>
                <Section title={`${zlevel.name} (${zlevel.zpos})`}>
                  <Stack fill vertical>
                    <Stack.Item>Traits: {zlevel.traits.join(', ')}</Stack.Item>
                    <Stack.Item>
                      Connections:
                      <br />
                      North: {neighbor_to_element(levels[`${zlevel.neighbors.north}`])}
                      <br />
                      South: {neighbor_to_element(levels[`${zlevel.neighbors.south}`])}
                      <br />
                      East: {neighbor_to_element(levels[`${zlevel.neighbors.east}`])}
                      <br />
                      West: {neighbor_to_element(levels[`${zlevel.neighbors.west}`])}
                      <br />
                    </Stack.Item>
                  </Stack>
                </Section>
                {!!zlevel.ruins.length && (
                  <Section title="Known Ruins">
                    <Stack vertical fill>
                      <LabeledList>
                        {zlevel.ruins
                          .toSorted((a, b) => a.name.localeCompare(b.name))
                          .map((ruin) => (
                            <LabeledList.Item
                              label={ruin.name}
                              buttons={<JumpToCoords coords={ruin.coords} />}
                              className="candystripe"
                            >
                              ({ruin.coords.x},{ruin.coords.y},{ruin.coords.z})
                            </LabeledList.Item>
                          ))}
                      </LabeledList>
                    </Stack>
                  </Section>
                )}
              </>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
