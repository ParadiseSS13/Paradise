import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Stack, Input } from '../components';
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
                  <Stack key={prize.name} className="PrizeCounter__Item">
                    <Stack.Item lineHeight="0" align="center">
                      <div
                        className={classes([
                          'prize_counter64x64',
                          prize.imageID,
                        ])}
                      />
                    </Stack.Item>
                    <Stack.Item width="100%">
                      <Stack vertical textAlign="center">
                        <Stack.Item bold mt={1}>
                          {prize.name}
                        </Stack.Item>
                        <Stack.Divider />
                        <Stack.Item mb={1}>{prize.desc}</Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        className={classes([
                          'PrizeCounter__BuyButton',
                          disabled && 'PrizeCounter__BuyButton--disabled',
                        ])}
                        icon="ticket"
                        content={prize.cost}
                        tooltip={disabled ? 'Not enough tickets.' : null}
                        tooltipPosition="top-end"
                        onClick={() =>
                          !disabled &&
                          act('purchase', { 'purchase': prize.itemID })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                );
              })}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
