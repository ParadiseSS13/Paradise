import { useState } from 'react';
import { Button, Input, Section } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  emoji_list: Emoji[];
};

type Emoji = {
  name: string;
};

export const Emojipedia = (props) => {
  const { data } = useBackend<Data>();
  const { emoji_list } = data;
  const [searchText, setSearchText] = useState('');
  const filteredEmoji = emoji_list.filter((emoji) => emoji.name.toLowerCase().includes(searchText.toLowerCase()));

  return (
    <Window width={325} height={400}>
      <Window.Content scrollable>
        <Section
          fill
          scrollable
          // required: follow semantic versioning every time you touch this file
          title={'Emojipedia v1.0.1'}
          buttons={
            <>
              <Input placeholder="Search by name" value={searchText} onChange={(value) => setSearchText(value)} />
              <Button tooltip={'Click on an emoji to copy its tag!'} tooltipPosition="bottom" icon="circle-question" />
            </>
          }
        >
          {filteredEmoji.map((emoji) => (
            <Button
              key={emoji.name}
              m={1}
              color={'transparent'}
              className={classes(['emoji16x16', `emoji-${emoji.name}`])}
              style={{ transform: 'scale(1.5)' }}
              tooltip={emoji.name}
              onClick={() => {
                copyText(emoji.name);
              }}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const copyText = (text: string) => {
  const input = document.createElement('input');
  const formattedText = `:${text}:`;
  input.value = formattedText;
  document.body.appendChild(input);
  input.select();
  document.execCommand('copy');
  document.body.removeChild(input);
};
