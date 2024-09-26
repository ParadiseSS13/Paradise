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
  shoes: ShoeSkin[];
  chameleon_name: string
};

type ShoeSkin = {
  name: string;
  icon: string;
};

type IDCard = {
  name: string;
};

const unset = 'Empty';

export const Chameleon = (props, context) => {
  return (
    <Window width={430} height={500} theme="syndicate">
      <Window.Content>
        <AgentCardAppearances />
      </Window.Content>
    </Window>
  );
};

export const AgentCardAppearances = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const [selectedAppearance, setSelectedAppearance] = useSharedState(context, 'selectedAppearance', null);
  const { shoes, chameleon_name } = data;
  return (
    <Stack.Item grow>
      <Section  title={'Card Appearance'}>
        {shoes.map((shoe) => (
          <Button
            m={0.5}
            compact
            color={'translucent'}
            key={shoe.name}
            selected={shoe.name === selectedAppearance}
            tooltip={shoe.name}
            className={classes([chameleon_name + '64x64', shoe.icon])}
            onClick={() => {
              setSelectedAppearance(shoe.name);
              act('change_appearance', {
                new_appearance: shoe.name + "_" + shoe.icon
              });
            }}
          />
        ))}
      </Section>
    </Stack.Item>
  );
};
