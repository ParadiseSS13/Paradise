import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Section, Tabs, Icon, Stack } from '../components';
import { Window } from '../layouts';

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
    <Window width={425} height={500} theme="syndicate">
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

export const AgentCardInfo = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    registered_name,
    sex,
    age,
    assignment,
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
              <Button content={registered_name ? registered_name : '[UNSET]'} onClick={() => act('change_name')} />
            </LabeledList.Item>
            <LabeledList.Item label="Sex">
              <Button iconRight={false} content={sex ? sex : '[UNSET]'} onClick={() => act('change_sex')} />
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              <Button content={age ? age : '[UNSET]'} onClick={() => act('change_age')} />
            </LabeledList.Item>
            <LabeledList.Item label="Rank">
              <Button content={assignment ? assignment : '[UNSET]'} onClick={() => act('change_occupation')} />
            </LabeledList.Item>
            <LabeledList.Item label="Fingerprints">
              <Button
                content={fingerprint_hash ? fingerprint_hash : '[UNSET]'}
                onClick={() => act('change_fingerprints')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Blood Type">
              <Button content={blood_type ? blood_type : '[UNSET]'} onClick={() => act('change_blood_type')} />
            </LabeledList.Item>
            <LabeledList.Item label="DNA Hash">
              <Button content={dna_hash ? dna_hash : '[UNSET]'} onClick={() => act('change_dna_hash')} />
            </LabeledList.Item>
            <LabeledList.Item label="Money Account">
              <Button
                content={associated_account_number ? associated_account_number : '[UNSET]'}
                onClick={() => act('change_money_account')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Photo">
              <Button content={photo ? 'Update' : '[UNSET]'} onClick={() => act('change_photo')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill title="Card Settings">
          <LabeledList>
            <LabeledList.Item label="Card Info">
              <Button content="Delete Card Info" onClick={() => act('delete_info')} />
            </LabeledList.Item>
            <LabeledList.Item label="Access">
              <Button content="Reset Access" onClick={() => act('clear_access')} />
            </LabeledList.Item>
            <LabeledList.Item label="AI Tracking">
              <Button content={ai_tracking ? 'Untrackable' : 'Trackable'} onClick={() => act('change_ai_tracking')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </>
  );
};

export const AgentCardAppearances = (props, context) => {
  const { act, data } = useBackend(context);
  const [selectedAppearance, setSelectedAppearance] = useLocalState(context, 'selectedAppearance', null);
  const { appearances } = data;
  return (
    <Stack.Item grow>
      <Section fill scrollable title="Card Appearance">
        {appearances.map((appearance_unit) => (
          <Button
            compact
            m={0.5}
            color="translucent"
            key={appearance_unit.name}
            selected={appearance_unit === selectedAppearance}
            content={
              <img
                src={`data:image/jped;base64,${appearance_unit.image}`}
                style={{
                  width: '64px',
                  'vertical-align': 'middle',
                  '-ms-interpolation-mode': 'nearest-neighbor',
                }}
                onClick={() => {
                  setSelectedAppearance(appearance_unit);
                  act('change_appearance', {
                    new_appearance: appearance_unit.name,
                  });
                }}
              />
            }
          />
        ))}
      </Section>
    </Stack.Item>
  );
};
