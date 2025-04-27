import { useState } from 'react';
import { Button, Icon, ImageButton, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Prize = {
  name: string;
  desc: string;
  icon: string;
  icon_state: string;
  cost: number;
  itemID: number;
};

type PrizeData = {
  tickets: number;
  prizes: Prize[];
};

export const PrizeCounter = (props) => {
  const { act, data } = useBackend<PrizeData>();
  const { tickets, prizes = [] } = data;
  const [searchText, setSearchText] = useState('');
  const [toggleSearch, setToggleSearch] = useState(false);
  const filteredPrizes = prizes.filter((prize) => prize.name.toLowerCase().includes(searchText.toLowerCase()));
  return (
    <Window width={450} height={585} title="Arcade Ticket Exchange">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Available Prizes"
              buttons={
                <Stack>
                  {toggleSearch && (
                    <Stack.Item>
                      <Input
                        mt={0.1}
                        width={12.5}
                        placeholder="Search for a prize"
                        value={searchText}
                        onChange={(value) => setSearchText(value)}
                      />
                    </Stack.Item>
                  )}
                  <Stack.Item>
                    <Button fluid iconPosition="right" icon="ticket" disabled={!tickets} onClick={() => act('eject')}>
                      Tickets: <b>{tickets}</b>
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="search"
                      tooltip="Toggle search"
                      tooltipPosition="bottom-end"
                      selected={toggleSearch}
                      onClick={() => setToggleSearch(!toggleSearch)}
                    />
                  </Stack.Item>
                </Stack>
              }
            >
              {filteredPrizes.map((prize) => {
                const disabled = prize.cost > tickets;
                return (
                  <ImageButton
                    fluid
                    key={prize.name}
                    title={prize.name}
                    dmIcon={prize.icon}
                    dmIconState={prize.icon_state}
                    buttonsAlt={
                      <Button
                        bold
                        fontSize={1.5}
                        tooltip={disabled && 'Not enough tickets'}
                        disabled={disabled}
                        onClick={() => act('purchase', { 'purchase': prize.itemID })}
                      >
                        {prize.cost}
                        <Icon m={0} mt={0.25} name="ticket" color={disabled ? 'bad' : 'good'} size={1.6} />
                      </Button>
                    }
                  >
                    {prize.desc}
                  </ImageButton>
                );
              })}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
