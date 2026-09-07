import { NumberInput, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const ColourMatrixTester = (props) => {
  const { act, data } = useBackend();
  const { colour_data } = data;

  const matrixEntries = [
    [
      { name: 'RR', idx: 0 },
      { name: 'RG', idx: 1 },
      { name: 'RB', idx: 2 },
      { name: 'RA', idx: 3 },
    ],
    [
      { name: 'GR', idx: 4 },
      { name: 'GG', idx: 5 },
      { name: 'GB', idx: 6 },
      { name: 'GA', idx: 7 },
    ],
    [
      { name: 'BR', idx: 8 },
      { name: 'BG', idx: 9 },
      { name: 'BB', idx: 10 },
      { name: 'BA', idx: 11 },
    ],
    [
      { name: 'AR', idx: 12 },
      { name: 'AG', idx: 13 },
      { name: 'AB', idx: 14 },
      { name: 'AA', idx: 15 },
    ],
  ];

  return (
    <Window width={360} height={190}>
      <Window.Content>
        <Stack fill vertical>
          <Section fill title="Modify Matrix">
            {matrixEntries.map((k) => (
              <Stack key={k} textAlign="center" textColor="label">
                {k.map((k2) => (
                  <Stack.Item key={k2.name} grow mt={1}>
                    {k2.name}:&nbsp;
                    <NumberInput
                      width={4}
                      value={colour_data[k2.idx]}
                      step={0.05}
                      minValue={-5}
                      maxValue={5}
                      stepPixelSize={5}
                      onChange={(value) =>
                        act('setvalue', {
                          /* +1 to account for BYOND lists */
                          idx: k2.idx + 1,
                          value: value,
                        })
                      }
                    />
                  </Stack.Item>
                ))}
              </Stack>
            ))}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
