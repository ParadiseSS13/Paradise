import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Button, Section, Stack, Divider } from '../components';
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
                <Button
                  fluid
                  iconRight
                  icon="ticket-alt"
                  disabled={!tickets}
                  content={<>Tickets: {<b>{tickets}</b>}</>}
                  onClick={() => act('eject')}
                />
              }
            >
              {prizes.map((prizes) => (
                <Stack key={prizes.name} className="PrizeCounter__Item">
                  <Stack.Item lineHeight="0" align="center">
                    <div
                      className={classes([
                        'prize_counter64x64',
                        prizes.imageID,
                      ])}
                    />
                  </Stack.Item>
                  <Stack.Item width="100%">
                    <Stack vertical textAlign="center">
                      <Stack.Item bold mt={1}>
                        {prizes.name}
                      </Stack.Item>
                      <Divider />
                      <Stack.Item mt={0}>{prizes.desc}</Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      className={classes([
                        'PrizeCounter__BuyButton',
                        prizes.cost > tickets &&
                          'PrizeCounter__BuyButton--disabled',
                      ])}
                      icon="ticket-alt"
                      content={prizes.cost}
                      onClick={() =>
                        act('purchase', {
                          'purchase': prizes.itemID,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
