import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const NTRecruiter = (props) => {
  const { act, data } = useBackend();
  const {
    gamestatus,
    cand_name,
    cand_birth,
    cand_age,
    cand_species,
    cand_planet,
    cand_job,
    cand_records,
    cand_curriculum,
    total_curriculums,
    reason,
  } = data;
  if (gamestatus === 0) {
    return (
      <Window width={400} height={550}>
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item grow>
              <Section fill>
                <Stack.Item pt="45%" fontSize="31px" color="white" textAlign="center" bold>
                  Nanotrasen Recruiter Simulator
                </Stack.Item>
                <Stack.Item pt="1%" fontSize="16px" textAlign="center" color="label">
                  Work as the Nanotrasen recruiter and avoid hiring incompetent employees!
                </Stack.Item>
              </Section>
            </Stack.Item>
            <Section>
              <Button
                textAlign="center"
                lineHeight={2}
                fluid
                icon="play"
                color="green"
                content="Begin Shift"
                onClick={() => act('start_game')}
              />
              <Button
                textAlign="center"
                lineHeight={2}
                fluid
                icon="info"
                color="blue"
                content="Guide"
                onClick={() => act('instructions')}
              />
            </Section>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
  if (gamestatus === 1) {
    return (
      <Window width={400} height={550}>
        <Window.Content>
          <Stack fill vertical>
            <Section
              fill
              color="grey"
              title="Guide"
              buttons={<Button icon="arrow-left" content="Main Menu" onClick={() => act('back_to_menu')} />}
            >
              <LabeledList>
                <LabeledList.Item label="1#" color="silver">
                  To win this game you must hire/dismiss <b>{total_curriculums}</b> candidates, one wrongly made choice
                  leads to a game over.
                </LabeledList.Item>
                <LabeledList.Item label="2#" color="silver">
                  Make the right choice by truly putting yourself into the skin of a recruiter working for Nanotrasen!
                </LabeledList.Item>
                <LabeledList.Item label="3#" color="silver">
                  <b>Unique</b> characters may appear, pay attention to them!
                </LabeledList.Item>
                <LabeledList.Item label="4#" color="silver">
                  Make sure to pay attention to details like age, planet names, the requested job and even the species
                  of the candidate!
                </LabeledList.Item>
                <LabeledList.Item label="5#" color="silver">
                  Not every employment record is good, remember to make your choice based on the <b>company morals</b>!
                </LabeledList.Item>
                <LabeledList.Item label="6#" color="silver">
                  The planet of origin has no restriction on the species of the candidate, don&apos;t think too much
                  when you see humans that came from Boron!
                </LabeledList.Item>
                <LabeledList.Item label="7#" color="silver">
                  Pay attention to <b>typos</b> and <b>missing words</b>, these do make for bad applications!
                </LabeledList.Item>
                <LabeledList.Item label="8#" color="silver">
                  Remember, you are recruiting people to work at one of the many NT stations, so no hiring for{' '}
                  <b>jobs</b> that they <b>don&apos;t offer</b>!
                </LabeledList.Item>
                <LabeledList.Item label="9#" color="silver">
                  Keep your eyes open for incompatible <b>naming schemes</b>, no company wants a Vox named Joe!
                </LabeledList.Item>
                <LabeledList.Item label="10#" color="silver">
                  For some unknown reason <b>clowns</b> are never denied by the company, no matter what.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
  if (gamestatus === 2) {
    return (
      <Window width={400} height={550}>
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item grow>
              <Section fill scrollable color="label" fontSize="14px" title="Employment Applications">
                <Box fontSize="24px" textAlign="center" color="silver" bold>
                  Candidate Number #{cand_curriculum}
                </Box>
                <br />
                <LabeledList>
                  <LabeledList.Item label="Name" color="silver">
                    <b>{cand_name}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Species" color="silver">
                    <b>{cand_species}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Age" color="silver">
                    <b>{cand_age}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Date of Birth" color="silver">
                    <b>{cand_birth}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Planet of Origin" color="silver">
                    <b>{cand_planet}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Requested Job" color="silver">
                    <b>{cand_job}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Employment Records" color="silver">
                    <b>{cand_records}</b>
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section fill title="Stamp the application!" color="grey" textAlign="center">
                <Stack>
                  <Stack.Item grow basis={0}>
                    <Button
                      fluid
                      color="red"
                      content="Dismiss"
                      fontSize="150%"
                      icon="ban"
                      lineHeight={4.5}
                      onClick={() => act('dismiss')}
                    />
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <Button
                      fluid
                      color="green"
                      content="Hire"
                      fontSize="150%"
                      icon="arrow-circle-up"
                      lineHeight={4.5}
                      onClick={() => act('hire')}
                    />
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
  if (gamestatus === 3) {
    return (
      <Window width={400} height={550}>
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item grow>
              <Section pt="40%" fill>
                <Stack.Item bold color="red" fontSize="50px" textAlign="center">
                  {'Game Over'}
                </Stack.Item>
                <Stack.Item fontSize="15px" color="label" textAlign="center">
                  {reason}
                </Stack.Item>
                <Stack.Item color="blue" fontSize="20px" textAlign="center" pt="10px">
                  FINAL SCORE: {cand_curriculum - 1}/{total_curriculums}
                </Stack.Item>
              </Section>
            </Stack.Item>
            <Section>
              <Button lineHeight={4} fluid icon="arrow-left" content="Main Menu" onClick={() => act('back_to_menu')} />
            </Section>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
};
