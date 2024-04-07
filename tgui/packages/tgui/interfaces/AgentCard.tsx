import { BooleanLike } from 'common/react';
import { useBackend, useLocalState, useSharedState } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  Tabs,
  Icon,
  Stack,
  Box,
} from '../components';
import { Window } from '../layouts';
import { classes } from 'common/react';

type Data = {
  ai_tracking: BooleanLike;
  associated_account_number: number;
  age: number;
  registered_name: string;
  sex: string;
  blood_type: string;
  dna_hash: string;
  fingerprint_hash: string;
  photo: string;
  assignment: string;
  job_icon: string;
  idcards: IDCard[];
};

type IDCard = {
  name: string;
};

export const AgentCard = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <AgentCardInfo />;
      case 1:
        return <AgentCardAppearances />;
      default:
        return <AgentCardInfo />;
    }
  };

  return (
    <Window width={400} height={500} theme="syndicate">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item textAlign="center">
            <Tabs fluid>
              <Tabs.Tab
                key="Card Info"
                selected={0 === tabIndex}
                onClick={() => setTabIndex(0)}
              >
                <Icon name="table" /> Card Info
              </Tabs.Tab>
              <Tabs.Tab
                key="Appearance"
                selected={1 === tabIndex}
                onClick={() => setTabIndex(1)}
              >
                <Icon name="id-card" /> Appearance
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          {decideTab(tabIndex)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const AgentCardInfo = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    registered_name,
    sex,
    age,
    assignment,
    job_icon,
    associated_account_number,
    blood_type,
    dna_hash,
    fingerprint_hash,
    photo,
    ai_tracking,
  } = data;

  return (
    <>
      <Stack.Item>
        <Section title="Card Info">
          <LabeledList>
            <LabeledList.Item label="Name">
              <Button
                content={registered_name ? registered_name : '[UNSET]'}
                onClick={() => act('change_name')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Sex">
              <Button
                iconRight={false}
                content={sex ? sex : '[UNSET]'}
                onClick={() => act('change_sex')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              <Button
                content={age ? age : '[UNSET]'}
                onClick={() => act('change_age')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Rank">
              <Button
                onClick={() => act('change_occupation')}
                textAlign="middle"
              >
                <Box
                  className={classes(['orbit_job16x16', job_icon])}
                  verticalAlign="bottom"
                  my="2px"
                />{' '}
                {assignment ? assignment : '[UNSET]'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Fingerprints">
              <Button
                content={fingerprint_hash ? fingerprint_hash : '[UNSET]'}
                onClick={() => act('change_fingerprints')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Blood Type">
              <Button
                content={blood_type ? blood_type : '[UNSET]'}
                onClick={() => act('change_blood_type')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="DNA Hash">
              <Button
                content={dna_hash ? dna_hash : '[UNSET]'}
                onClick={() => act('change_dna_hash')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Money Account">
              <Button
                content={
                  associated_account_number
                    ? associated_account_number
                    : '[UNSET]'
                }
                onClick={() => act('change_money_account')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Photo">
              <Button
                content={photo ? 'Update' : '[UNSET]'}
                onClick={() => act('change_photo')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill title="Card Settings">
          <LabeledList>
            <LabeledList.Item label="Card Info">
              <Button
                content="Delete Card Info"
                onClick={() => act('delete_info')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Access">
              <Button
                content="Reset Access"
                onClick={() => act('clear_access')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="AI Tracking">
              <Button
                content={ai_tracking ? 'Untrackable' : 'Trackable'}
                onClick={() => act('change_ai_tracking')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </>
  );
};

export const AgentCardAppearances = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [selectedAppearance, setSelectedAppearance] = useSharedState(
    context,
    'selectedAppearance',
    null
  );
  const { idcards } = data;
  return (
    <Stack.Item grow>
      <Section fill scrollable title={'Card Appearance'}>
        {idcards.map((idcard) => (
          <Button
            m={0.5}
            compact
            color={'translucent'}
            key={idcard.name}
            selected={idcard.name === selectedAppearance}
            tooltip={idcard.name}
            className={classes(['idcards64x64', idcard.name])}
            onClick={() => {
              setSelectedAppearance(idcard.name);
              act('change_appearance', {
                new_appearance: idcard.name,
              });
            }}
          />
        ))}
      </Section>
    </Stack.Item>
  );
};
