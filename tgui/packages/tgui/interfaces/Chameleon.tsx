import { BooleanLike } from 'common/react';
import { useBackend, useLocalState, useSharedState } from '../backend';
import { Button, LabeledList, Section, Tabs, Icon, Stack, Box, Slider } from '../components';
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
  shoe_skins: ShoeSkin[];
};

type ShoeSkin = {
  name: string;
};

type IDCard = {
  name: string;
};

const unset = 'Empty';

export const Chameleon = (props, context) => {
  return (
    <Window width={430} height={500} theme="syndicate">
      <Window.Content>
        <AgentCardAppearances />;
      </Window.Content>
    </Window>
  );
};

export const AgentCardAppearances = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [selectedAppearance, setSelectedAppearance] = useSharedState(context, 'selectedAppearance', null);
  const { shoe_skins } = data;
  return (
    <Stack.Item grow>
      <Section fill scrollable title={'Card Appearance'}>
        {shoe_skins.map((idcard) => (
          <Button
            m={0.5}
            compact
            color={'translucent'}
            key={idcard.name}
            selected={idcard.name === selectedAppearance}
            tooltip={idcard.name}
            className={classes(['cham_shoes64x64', idcard.name])}
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
