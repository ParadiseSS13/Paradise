import { ReactNode, useState } from 'react';
import { Box, Button, Divider, Dropdown, LabeledList, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

interface Crime {
  name: string;
  desc: string;
  severity: string;
  code: string;
  min_time: number;
  max_time: number;
}

interface Modifier {
  name: string;
  desc: string;
  category: string;
  time_added: number;
  time_multiplier: number;
}

interface BrigData {
  cell_id: string;
  occupant: string;
  crimes: string;
  brigged_by: string;
  time_set: string;
  time_left: string;
  timing: boolean;
  isAllowed: boolean;
  prisoner_name: string | null;
  prisoner_notes: string | null;
  prisoner_time: number | null;
  prisoner_hasrec: boolean;
  spns: string[];
  all_crimes: Crime[];
  all_modifiers: Modifier[];
}

const SEVERITIES = {
  minor: { minTime: 0, maxTime: 5 },
  medium: { minTime: 5, maxTime: 10 },
  major: { minTime: 10, maxTime: 15 },
};

export const BrigTimer = (props: any) => {
  const { act, data } = useBackend<BrigData>();
  const { all_crimes = [], all_modifiers = [] } = data;

  const [selectedCrimes, setSelectedCrimes] = useState<Record<string, string | null>>({});
  const [selectedModifiers, setSelectedModifiers] = useState<Record<string, string | null>>({});

  const selectedCrimesList = all_crimes.filter((c) => selectedCrimes[c.name]);
  const selectedModsList = all_modifiers.filter((m) => selectedModifiers[m.name]);

  const formattedCrimes = selectedCrimesList.map((c) => c.name).join(', ');
  const formattedModifiers = selectedModsList.map((m) => m.name).join(', ');

  const crimeSummary = [data.prisoner_notes, formattedCrimes, formattedModifiers ? `(${formattedModifiers})` : '']
    .filter(Boolean)
    .join(' - ');

  const baseTimer = selectedCrimesList.reduce(
    (acc, crime) => {
      const sev = SEVERITIES[crime.severity] || { minTime: 0, maxTime: 0 };
      return {
        minTime: acc.minTime + sev.minTime,
        maxTime: acc.maxTime + sev.maxTime,
      };
    },
    { minTime: 0, maxTime: 0 }
  );

  const summedTimer = selectedModsList.reduce(
    (acc, val) => ({
      minTime: acc.minTime + (val.time_added ?? 0),
      maxTime: acc.maxTime + (val.time_added ?? 0),
    }),
    baseTimer
  );

  const multipliedTimer = selectedModsList.reduce(
    (acc, val) => ({
      minTime: acc.minTime * (val.time_multiplier ?? 1),
      maxTime: acc.maxTime * (val.time_multiplier ?? 1),
    }),
    summedTimer
  );

  const suggestedMin = Math.min(Math.ceil(multipliedTimer.minTime), 60);
  const suggestedMax = Math.min(Math.ceil(multipliedTimer.maxTime), 60);

  const getTimerText = () => {
    if (suggestedMin === 60 && suggestedMax === 60) return 'Permanent Confinement';
    if (suggestedMax === 60) return `${suggestedMin} Minutes to Permanent Confinement`;
    if (suggestedMin === suggestedMax && suggestedMin !== 0) return `${suggestedMin} Minutes`;
    if (suggestedMin || suggestedMax) return `${suggestedMin} to ${suggestedMax} Minutes`;
    return 'Select Crimes for Suggestion';
  };

  const nameText = data.timing ? (
    <Box color={data.prisoner_hasrec ? 'green' : 'red'}>{data.occupant}</Box>
  ) : (
    data.occupant
  );

  const crimesByCode = all_crimes.reduce(
    (acc, c) => {
      if (!acc[c.code]) acc[c.code] = [];
      acc[c.code].push(c);
      return acc;
    },
    {} as Record<string, Crime[]>
  );

  const modsByCategory = all_modifiers.reduce(
    (acc, m) => {
      if (!acc[m.category]) acc[m.category] = [];
      acc[m.category].push(m);
      return acc;
    },
    {} as Record<string, Modifier[]>
  );

  return (
    <Window width={580} height={data.timing ? 270 : 710}>
      <Window.Content scrollable>
        {data.timing ? (
          <Section title="Cell Information" fill>
            <LabeledList>
              <LabeledList.Item label="Cell ID">{data.cell_id}</LabeledList.Item>
              <LabeledList.Item label="Occupant">{nameText}</LabeledList.Item>
              <LabeledList.Item label="Crimes">{data.crimes}</LabeledList.Item>
              <LabeledList.Item label="Brigged By">{data.brigged_by}</LabeledList.Item>
              <LabeledList.Item label="Time Brigged For">{data.time_set}</LabeledList.Item>
              <LabeledList.Item label="Time Left">{data.time_left}</LabeledList.Item>
              <LabeledList.Item label="Actions">
                <Stack fill>
                  <Stack.Item grow={1} basis={0}>
                    <Button fluid icon="lightbulb-o" onClick={() => act('flash')} />
                  </Stack.Item>
                  <Stack.Item grow={1} basis={0}>
                    <Button fluid icon="plus" content="+10m" onClick={() => act('add_time')} />
                  </Stack.Item>
                  <Stack.Item grow={1} basis={0}>
                    <Button fluid icon="sync" content="Reset" onClick={() => act('restart_timer')} />
                  </Stack.Item>
                  <Stack.Item grow={1} basis={0}>
                    <Button fluid icon="eject" content="Release" onClick={() => act('stop')} />
                  </Stack.Item>
                </Stack>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ) : (
          <Stack vertical fill>
            <Stack.Item>
              <Section title="New Prisoner">
                <Stack fill>
                  <Stack.Item grow={1} basis={0}>
                    <LabeledList>
                      <LabeledList.Item label="Prisoner Name">
                        <Button fluid content={data.prisoner_name || '-----'} onClick={() => act('prisoner_name')} />
                        {!!data.spns.length && (
                          <Box mt="0.3rem">
                            <Dropdown
                              fluid
                              options={data.spns}
                              selected={data.prisoner_name || ''}
                              onSelected={(value) => act('prisoner_name', { prisoner_name: value })}
                            />
                          </Box>
                        )}
                      </LabeledList.Item>
                      <LabeledList.Item label="Notes">
                        <Button fluid content={data.prisoner_notes || '-----'} onClick={() => act('prisoner_notes')} />
                      </LabeledList.Item>
                      <LabeledList.Item label="Timer">{getTimerText()}</LabeledList.Item>
                      <LabeledList.Item label="Set Time">
                        <Button fluid content={data.prisoner_time || '-----'} onClick={() => act('prisoner_time')} />
                      </LabeledList.Item>
                      <LabeledList.Item label="Action">
                        <Button
                          fluid
                          icon="gavel"
                          content="Start Sentence"
                          color="success"
                          disabled={!data.prisoner_name || !selectedCrimesList.length || !data.prisoner_time}
                          onClick={() => act('start', { final_crimes: crimeSummary })}
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item grow={1} basis={0} ml={2}>
                    <Box bold color="label">
                      Selected Charges:
                    </Box>
                    <Box italic>{formattedCrimes || 'None'}</Box>
                    <Divider />
                    <Box bold color="label">
                      Modifiers:
                    </Box>
                    <Box italic>{formattedModifiers || 'N/A'}</Box>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item grow={1}>
              <Section title="Law Selection">
                <Stack vertical fill>
                  <Box textAlign="center" bold color="label" mb={1}>
                    CRIMES
                  </Box>
                  {Object.entries(crimesByCode).map(([code, category]) => (
                    <Stack.Item key={code}>
                      <Stack fill>
                        {category.map((crime) => (
                          <Stack.Item grow={1} basis={0} key={crime.name}>
                            <Button
                              fluid
                              textAlign="center"
                              tooltip={crime.desc}
                              selected={!!selectedCrimes[crime.name]}
                              onClick={() =>
                                setSelectedCrimes({
                                  ...selectedCrimes,
                                  [crime.name]: selectedCrimes[crime.name] ? null : crime.name,
                                })
                              }
                            >
                              {crime.name}
                            </Button>
                          </Stack.Item>
                        ))}
                      </Stack>
                    </Stack.Item>
                  ))}
                  <Divider />
                  <Box textAlign="center" bold color="label" mb={1}>
                    MODIFIERS
                  </Box>
                  {Object.entries(modsByCategory).map(([modifierGroup, category]) => (
                    <Stack.Item key={modifierGroup}>
                      <Stack fill>
                        {category.map((modifier) => (
                          <Stack.Item grow={1} basis={0} key={modifier.name}>
                            <Button
                              fluid
                              textAlign="center"
                              tooltip={modifier.desc}
                              color={selectedModifiers[modifier.name] ? 'green' : ''}
                              onClick={() =>
                                setSelectedModifiers({
                                  ...selectedModifiers,
                                  [modifier.name]: selectedModifiers[modifier.name] ? null : modifier.name,
                                })
                              }
                            >
                              {modifier.name}
                            </Button>
                          </Stack.Item>
                        ))}
                      </Stack>
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            </Stack.Item>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
