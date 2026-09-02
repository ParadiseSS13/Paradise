import { useState } from 'react';
import { Button, Icon, ImageButton, LabeledList, Section, Slider, Stack, Tabs } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

const GENDERS = [
  { name: 'Male', icon: 'mars' },
  { name: 'Female', icon: 'venus' },
  { name: 'Genderless', icon: 'genderless' },
];

const BLOOD_TYPES = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

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
  appearances: string[];
  id_icon: string;
  photo_cooldown: boolean;
};

const unset = 'Empty';
const InfoInput = ({ label, value, onCommit, onClick, onRClick, tooltip }) => (
  <LabeledList.Item label={label}>
    <Stack fill mb={-0.5}>
      <Stack.Item grow>
        <Button.Input fluid textAlign="center" value={value || unset} onCommit={onCommit} />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="file-signature"
          tooltip={tooltip}
          tooltipPosition={'bottom-end'}
          onClick={onClick}
          onContextMenu={onRClick}
        />
      </Stack.Item>
    </Stack>
  </LabeledList.Item>
);

export const AgentCard = (props) => {
  const [tabIndex, setTabIndex] = useState(0);
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
    <Window width={435} height={500} theme="syndicate">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item textAlign="center">
            <Tabs fluid>
              <Tabs.Tab key="Card Info" selected={0 === tabIndex} onClick={() => setTabIndex(0)}>
                <Icon name="table" /> Card Info
              </Tabs.Tab>
              <Tabs.Tab key="Appearance" selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
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

export const AgentCardInfo = (props) => {
  const { act, data } = useBackend<Data>();
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
    photo_cooldown,
  } = data;

  const tooltipTextCopy = (
    <span>
      Autofill options.
      <br />
      LMB - Autofill your own data.
      <br />
      RMB - Autofill someone else data.
    </span>
  );

  const tooltipTextRandom = (
    <span>
      Autofill options.
      <br />
      LMB - Autofill your own data.
      <br />
      RMB - Autofill with random data.
    </span>
  );

  return (
    <>
      <Stack.Item>
        <Section title="Card Info">
          <LabeledList>
            <InfoInput
              label="Name"
              value={registered_name}
              tooltip={tooltipTextCopy}
              onCommit={(value) => act('change_name', { name: value })}
              onClick={() => act('change_name', { option: 'Primary' })}
              onRClick={(event) => {
                event.preventDefault();
                act('change_name', { option: 'Secondary' });
              }}
            />
            <LabeledList.Item label="Sex">
              <Stack fill mb={-0.5}>
                {GENDERS.map((gender) => (
                  <Stack.Item grow key={gender.name}>
                    <Button
                      fluid
                      icon={gender.icon}
                      content={gender.name}
                      selected={sex === gender.name}
                      onClick={() => act('change_sex', { sex: gender.name })}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              <Slider
                width="100%"
                minValue={20}
                value={age || 0}
                maxValue={300}
                onChange={(e, value) => act('change_age', { age: value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Rank">
              <Stack fill mb={-0.5}>
                <Stack.Item grow>
                  <Button fluid onClick={() => act('change_occupation')} textAlign="center">
                    {assignment ? assignment : '[UNSET]'}
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <ImageButton
                    fluid
                    imageSize={21}
                    color={'transparent'}
                    tooltip={'Change HUD icon'}
                    tooltipPosition={'bottom-end'}
                    dmIcon={'icons/mob/hud/job_assets.dmi'}
                    dmIconState={job_icon}
                    onClick={() => act('change_occupation', { option: 'Primary' })}
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <InfoInput
              label="Fingerprint"
              value={fingerprint_hash}
              onCommit={(value) => act('change_fingerprints', { new_fingerprints: value })}
              onClick={() => act('change_fingerprints', { option: 'Primary' })}
              onRClick={(event) => {
                event.preventDefault();
                act('change_fingerprints', { option: 'Secondary' });
              }}
              tooltip={tooltipTextRandom}
            />
            <LabeledList.Item label="Blood Type">
              <Stack fill mb={-0.5}>
                {BLOOD_TYPES.map((type) => (
                  <Stack.Item grow key={type}>
                    <Button
                      fluid
                      content={type}
                      selected={blood_type === type}
                      onClick={() => act('change_blood_type', { new_type: type })}
                    />
                  </Stack.Item>
                ))}
                <Stack.Item>
                  <Button fluid icon="file-signature" onClick={() => act('change_blood_type', { option: 'Primary' })} />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <InfoInput
              label="DNA"
              value={dna_hash}
              onCommit={(value) => act('change_dna_hash', { new_dna: value })}
              onClick={() => act('change_dna_hash', { option: 'Primary' })}
              onRClick={(event) => {
                event.preventDefault();
                act('change_dna_hash', { option: 'Secondary' });
              }}
              tooltip={tooltipTextRandom}
            />
            <InfoInput
              label="Account"
              value={associated_account_number || 0}
              onCommit={(value) => act('change_money_account', { new_account: value })}
              onClick={() => act('change_money_account', { option: 'Primary' })}
              onRClick={(event) => {
                event.preventDefault();
                act('change_money_account', { option: 'Secondary' });
              }}
              tooltip={tooltipTextRandom}
            />
            <LabeledList.Item label="Photo">
              <Button
                fluid
                textAlign="center"
                disabled={!photo_cooldown}
                tooltip={photo_cooldown ? '' : "You can't generate a new photo yet."}
                onClick={() => act('change_photo')}
              >
                {photo ? 'Update' : unset}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill title="Card Settings">
          <LabeledList>
            <LabeledList.Item label="Card Info">
              <Button.Confirm
                fluid
                textAlign="center"
                content="Delete Card Info"
                confirmContent="Are you sure?"
                onClick={() => act('delete_info')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Access">
              <Button.Confirm
                fluid
                textAlign="center"
                content="Reset Access"
                confirmContent="Are you sure?"
                onClick={() => act('clear_access')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="AI Tracking">
              <Button fluid textAlign="center" onClick={() => act('change_ai_tracking')}>
                {ai_tracking ? 'Untrackable' : 'Trackable'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </>
  );
};

export const AgentCardAppearances = (props) => {
  const { act, data } = useBackend<Data>();
  const [selectedAppearance, setSelectedAppearance] = useSharedState('selectedAppearance', '');
  const { appearances, id_icon } = data;
  return (
    <Stack.Item grow>
      <Section fitted fill scrollable title={'Card Appearance'}>
        {appearances.map((appearance) => (
          <ImageButton
            key={appearance}
            dmIcon={id_icon}
            dmIconState={appearance}
            imageSize={64}
            selected={appearance === selectedAppearance}
            tooltip={appearance}
            style={{
              opacity: (appearance === selectedAppearance && '1') || '0.5',
            }}
            onClick={() => {
              setSelectedAppearance(appearance);
              act('change_appearance', {
                new_appearance: appearance,
              });
            }}
          />
        ))}
      </Section>
    </Stack.Item>
  );
};
