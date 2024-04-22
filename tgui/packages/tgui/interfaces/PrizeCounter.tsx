import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Stack, ImageButton, Input } from '../components';
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
  const filteredPrizes = prizes.filter((prize) =>
    prize.name.toLowerCase().includes(searchText.toLowerCase())
  );
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
                    key={prize.name}
                    asset
                    imageAsset={'prize_counter64x64'}
                    image={prize.imageID}
                    title={prize.name}
                    content={prize.desc}
                  >
                    <ImageButton.Item
                      bold
                      width={'64px'}
                      fontSize={1.5}
                      textColor={disabled && 'gray'}
                      content={prize.cost}
                      icon={'ticket'}
                      iconSize={1.6}
                      iconColor={disabled ? 'bad' : 'good'}
                      tooltip={disabled && 'Not enough tickets'}
                      disabled={disabled}
                      onClick={() =>
                        act('purchase', { 'purchase': prize.itemID })
                      }
                    />
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
