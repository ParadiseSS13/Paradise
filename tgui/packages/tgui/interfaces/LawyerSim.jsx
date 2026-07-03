import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const LawyerSim = (props) => {
  const { act, data } = useBackend();
  const {
    gamestatus,
    crim_name,
    crim_job,
    crimes_list,
    total_sent,
    off_name,
    station_loc,
    arrest_desc,
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
                  Nanotrasen Magistrate Simulator
                </Stack.Item>
                <Stack.Item pt="1%" fontSize="16px" textAlign="center" color="label">
                  Work as the station&apos;s Magistrate and review Security&apos;s arrest records!
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
                  To win this game you must review <b>{total_curriculums}</b> arrest records, one wrongly made choice
                  leads to a game over.
                </LabeledList.Item>
                <LabeledList.Item label="2#" color="silver">
                  Make the right choice by truly putting yourself into the skin of a Magistrate working for Nanotrasen!
                </LabeledList.Item>
                <LabeledList.Item label="3#" color="silver">
                  <b>Unique</b> characters may appear, pay attention to them!
                </LabeledList.Item>
                <LabeledList.Item label="4#" color="silver">
                  Make sure to pay attention to details like listed crimes, station name, job, and the circumstances
                  around their arrest!
                </LabeledList.Item>
                <LabeledList.Item label="5#" color="silver">
                  Be sure to verify that the arresting officer had just cause. If the suspect should never have been in
                  handcuffs, it&apos;s invalid!
                </LabeledList.Item>
                <LabeledList.Item label="6#" color="silver">
                  The sentencing should match the crimes committed. Review Space Law for the exact times!
                </LabeledList.Item>
                <LabeledList.Item label="7#" color="silver">
                  Pay attention to <b>typos</b> and <b>missing words</b>, these do make for bad records!
                </LabeledList.Item>
                <LabeledList.Item label="8#" color="silver">
                  Remember, you are reviewing the arrest records of people working on a Nanotrasen station, so
                  don&apos;t approve <b>crimes</b> that <b>aren&apos;t in Space Law</b>!
                </LabeledList.Item>
                <LabeledList.Item label="9#" color="silver">
                  Keep your eyes open for nonexistant jobs. If it isn&apos;t a valid job, it&apos;s possible something
                  went wrong, and the record should be denied!
                </LabeledList.Item>
                <LabeledList.Item label="10#" color="silver">
                  Don&apos;t let the Clown fool you, they&apos;re subject to Space Law the same as anyone else!
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
              <Section fill scrollable color="label" fontSize="14px" title="Arrest Records">
                <Box fontSize="24px" textAlign="center" color="silver" bold>
                  Record Number #{cand_curriculum}
                </Box>
                <br />
                <LabeledList>
                  <LabeledList.Item label="Name" color="silver">
                    <b>{crim_name}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Job" color="silver">
                    <b>{crim_job}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Crimes" color="silver">
                    <b>{crimes_list}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Sentencing" color="silver">
                    <b>{total_sent}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Arresting Officer's Name" color="silver">
                    <b>{off_name}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Station" color="silver">
                    <b>{station_loc}</b>
                  </LabeledList.Item>
                  <LabeledList.Item label="Manner of Arrest" color="silver">
                    <b>{arrest_desc}</b>
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section fill title="Stamp the record!" color="grey" textAlign="center">
                <Stack>
                  <Stack.Item grow basis={0}>
                    <Button
                      fluid
                      color="red"
                      content="Invalid"
                      fontSize="150%"
                      icon="ban"
                      lineHeight={4.5}
                      onClick={() => act('deny')}
                    />
                  </Stack.Item>
                  <Stack.Item grow basis={0}>
                    <Button
                      fluid
                      color="green"
                      content="Valid"
                      fontSize="150%"
                      icon="arrow-circle-up"
                      lineHeight={4.5}
                      onClick={() => act('approve')}
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
