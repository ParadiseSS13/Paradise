import { classes } from '../../common/react';
import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, Section, ProgressBar, Stack, NoticeBox } from '../components';
import { Window } from '../layouts';

type MintData = {
  active: BooleanLike;
  moneyBag: BooleanLike;
  moneyBagContent: number;
  moneyBagMaxContent: number;
  totalCoins: number;
  chosenMaterial: string;
  materials: MintMaterial[];
};

type MintMaterial = {
  name: string;
  amount: number;
  id: string;
};

export const CoinMint = (props, context) => {
  const { act, data } = useBackend<MintData>(context);
  const { materials, moneyBag, moneyBagContent, moneyBagMaxContent } = data;
  return (
    <Window width={300} height={400}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <NoticeBox m={0} info>
              Total coins produced: {data.totalCoins}
            </NoticeBox>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title={'Coin Type'}
              buttons={
                <Button
                  icon={'power-off'}
                  content={data.active ? 'Turn Off' : 'Turn On'}
                  color={data.active && 'bad'}
                  tooltip={!moneyBag && 'Need a money bag'}
                  disabled={!moneyBag}
                  onClick={() => act('activate')}
                />
              }
            >
              {materials.map((material) => (
                <Button
                  key={material.id}
                  fluid
                  color={'transparent'}
                  selected={material.id === data.chosenMaterial}
                  content={
                    <Stack>
                      <Stack.Item
                        className={classes(['materials32x32', material.id])}
                      />
                      <Stack.Item mt={1}>
                        {material.name} - {material.amount / 2000}
                      </Stack.Item>
                    </Stack>
                  }
                  onClick={() =>
                    act('selectMaterial', { material: material.id })
                  }
                />
              ))}
            </Section>
          </Stack.Item>
          {!!moneyBag && (
            <Stack.Item>
              <Section
                title={'Money Bag'}
                buttons={
                  <Button
                    icon={'eject'}
                    content={'Eject'}
                    onClick={() => act('ejectBag')}
                  />
                }
              >
                <ProgressBar
                  width={'100%'}
                  minValue={0}
                  maxValue={moneyBagMaxContent}
                  value={moneyBagContent}
                >
                  {moneyBagContent} / {moneyBagMaxContent}
                </ProgressBar>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
