import { Box, Button, LabeledList, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Grid } from '../components';
import { Window } from '../layouts';

export const DnaVault = (props) => {
  const { act, data } = useBackend();
  const { completed } = data;
  return (
    <Window width={350} height={270}>
      <Window.Content>
        <Stack fill vertical>
          <DnaVaultDataBase />
          {!!completed && <GeneTherapySelection />}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const DnaVaultDataBase = (props) => {
  const { act, data } = useBackend();
  const { dna, dna_max, plants, plants_max, animals, animals_max } = data;
  const average_progress = 0.66;
  const bad_progress = 0.33;
  return (
    <Stack.Item grow>
      <Section fill title="DNA Vault Database">
        <LabeledList>
          <LabeledList.Item label="Human DNA">
            <ProgressBar
              value={dna / dna_max}
              ranges={{
                good: [average_progress, Infinity],
                average: [bad_progress, average_progress],
                bad: [-Infinity, bad_progress],
              }}
            >
              {dna + ' / ' + dna_max + ' Samples'}
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Plant DNA">
            <ProgressBar
              value={plants / plants_max}
              ranges={{
                good: [average_progress, Infinity],
                average: [bad_progress, average_progress],
                bad: [-Infinity, bad_progress],
              }}
            >
              {plants + ' / ' + plants_max + ' Samples'}
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Animal DNA">
            <ProgressBar
              value={animals / animals_max}
              ranges={{
                good: [average_progress, Infinity],
                average: [bad_progress, average_progress],
                bad: [-Infinity, bad_progress],
              }}
            >
              {animals + ' / ' + animals_max + ' Samples'}
            </ProgressBar>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const GeneTherapySelection = (props) => {
  const { act, data } = useBackend();
  const { choiceA, choiceB, used } = data;
  return (
    <Stack.Item>
      <Section fill title="Personal Gene Therapy">
        <Box bold textAlign="center" mb={1}>
          Applicable Gene Therapy Treatments
        </Box>
        {(!used && (
          <Grid>
            <Grid.Column>
              <Button
                fluid
                bold
                content={choiceA}
                textAlign="center"
                onClick={() =>
                  act('gene', {
                    choice: choiceA,
                  })
                }
              />
            </Grid.Column>
            <Grid.Column>
              <Button
                fluid
                bold
                content={choiceB}
                textAlign="center"
                onClick={() =>
                  act('gene', {
                    choice: choiceB,
                  })
                }
              />
            </Grid.Column>
          </Grid>
        )) || (
          <Box bold textAlign="center" mb={1}>
            Users DNA deemed unstable. Unable to provide more upgrades.
          </Box>
        )}
      </Section>
    </Stack.Item>
  );
};
