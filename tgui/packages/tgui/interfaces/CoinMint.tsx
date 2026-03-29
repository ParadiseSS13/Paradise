import { Button, NoticeBox, ProgressBar, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type MintData = {
  active: BooleanLike;
  moneyBag: BooleanLike;
  moneyBagContent: number;
  moneyBagMaxContent: number;
  totalCoins: number;
  totalMaterials: number;
  maxMaterials: number;
  chosenMaterial: string;
  materials: MintMaterial[];
};

type MintMaterial = {
  name: string;
  amount: number;
  id: string;
};

export const CoinMint = (props) => {
  const { act, data } = useBackend<MintData>();
  const { materials, moneyBag, moneyBagContent, moneyBagMaxContent } = data;
  const dynamicHeight = (moneyBag ? 210 : 138) + Math.ceil(materials.length / 4) * 64;
  return (
    <Window width={210} height={dynamicHeight}>
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
              title={'Coin Type'}
              buttons={
                <Button
                  icon={'power-off'}
                  color={data.active && 'bad'}
                  tooltip={!moneyBag && 'Need a money bag'}
                  disabled={!moneyBag}
                  onClick={() => act('activate')}
                />
              }
            >
              <Stack vertical>
                <Stack.Item>
                  <Stack>
                    <Stack.Item grow>
                      <ProgressBar minValue={0} maxValue={data.maxMaterials} value={data.totalMaterials} />
                    </Stack.Item>
                    <Stack.Item>
                      <Button icon={'eject'} tooltip={'Eject selected material'} onClick={() => act('ejectMat')} />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item grow>
                  {materials.map((material) => (
                    <Button
                      key={material.id}
                      bold
                      inline
                      m={0.2}
                      textAlign={'center'}
                      selected={material.id === data.chosenMaterial}
                      tooltip={material.name}
                      content={
                        <Stack vertical>
                          <Stack.Item className={classes(['materials32x32', material.id])} />
                          <Stack.Item>{material.amount}</Stack.Item>
                        </Stack>
                      }
                      onClick={() => act('selectMaterial', { material: material.id })}
                    />
                  ))}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          {!!moneyBag && (
            <Stack.Item>
              <Section
                title={'Money Bag'}
                buttons={
                  <Button icon={'eject'} content={'Eject'} disabled={data.active} onClick={() => act('ejectBag')} />
                }
              >
                <ProgressBar width={'100%'} minValue={0} maxValue={moneyBagMaxContent} value={moneyBagContent}>
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
