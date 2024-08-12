import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Stack, ImageButton, Input, Icon } from '../components';
import { Window } from '../layouts';

type Prize = {
  name: string;
  desc: string;
  cost: number;
  itemID: number;
  imageID: string;
};

type PrizeData = {
  tickets: number;
  prizes: Prize[];
};

export const PrizeCounter = (props, context) => {
  const { act, data } = useBackend<PrizeData>(context);
  const { tickets, prizes = [] } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
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
                  <Stack.Item>
                    <Input
                      mt={0.1}
                      width={12.5}
                      placeholder="Search for a prize"
                      value={searchText}
                      onInput={(e, value) => setSearchText(value)}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      fluid
                      iconRight
                      icon="ticket"
                      disabled={!tickets}
                      content={<>Tickets: {<b>{tickets}</b>}</>}
                      onClick={() => act('eject')}
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
                    asset={['prize_counter64x64', prize.imageID]}
                    title={prize.name}
                    buttonsAlt
                    buttons={
                      <Button.Translucent
                        bold
                        fontSize={1.5}
                        textColor={disabled && 'gray'}
                        textAlign="center"
                        tooltip={disabled && 'Not enough tickets'}
                        disabled={disabled}
                        onClick={() => act('purchase', { 'purchase': prize.itemID })}
                      >
                        {prize.cost} <br /> <Icon name="ticket" color={disabled ? 'bad' : 'good'} size={1.6} />
                      </Button.Translucent>
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
