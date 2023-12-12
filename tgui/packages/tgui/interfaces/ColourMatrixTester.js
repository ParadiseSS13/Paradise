import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Section, NumberInput } from '../components';
import { Window } from '../layouts';

export const ColourMatrixTester = (props, context) => {
  const { act, data } = useBackend(context);
  const { colour_data } = data;

  const matrix_entries = [
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
    <Window width={350} height={170}>
      <Window.Content>
        <Section title="Modify Matrix">
          {matrix_entries.map((k) => (
            <Box key={k} textAlign="center">
              {k.map((k2) => (
                <Fragment key={k2.name}>
                  {k2.name}&nbsp;
                  <NumberInput
                    value={colour_data[k2.idx]}
                    step={0.05}
                    minValue={-5}
                    maxValue={5}
                    onDrag={(e, value) =>
                      act('setvalue', {
                        /* +1 to account for BYOND lists */
                        idx: k2.idx + 1,
                        value: value,
                      })
                    }
                  />
                </Fragment>
              ))}
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
