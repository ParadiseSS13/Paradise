import { useState } from 'react';
import { ImageButton, Input, Section, Stack } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  chameleon_skins: ChameleonSkin[];
  chameleon_name: string;
  icon: string;
  selected_appearance: string;
};

type ChameleonSkin = {
  name: string;
  icon: string;
  icon_state: string;
};

export const Chameleon = (props) => {
  return (
    <Window width={440} height={500} theme="syndicate">
      <Window.Content>
        <ChameleonAppearances />
      </Window.Content>
    </Window>
  );
};

const selectSkins = (skins, searchText = '') => {
  const testSearch = createSearch(searchText, (skin: ChameleonSkin) => skin.name);
  return skins.filter(testSearch);
};

export const ChameleonAppearances = (props) => {
  const { act, data } = useBackend<Data>();
  const [searchText, setSearchText] = useState('');
  const chameleon_skins = selectSkins(data.chameleon_skins, searchText);
  const { selected_appearance } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input fluid placeholder="Search for an appearance" onChange={(value) => setSearchText(value)} />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={'Item Appearance'}>
          {chameleon_skins.map((chameleon_skin) => {
            const skin_name = chameleon_skin.name + '_' + chameleon_skin.icon_state;
            return (
              <ImageButton
                dmIcon={chameleon_skin.icon}
                dmIconState={chameleon_skin.icon_state}
                imageSize={64}
                m={0.5}
                key={skin_name}
                selected={skin_name === selected_appearance}
                tooltip={chameleon_skin.name}
                style={{
                  opacity: (skin_name === selected_appearance && '1') || '0.5',
                }}
                onClick={() => {
                  act('change_appearance', {
                    new_appearance: skin_name,
                  });
                }}
              />
            );
          })}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
