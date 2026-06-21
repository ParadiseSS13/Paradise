import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { Window } from '../layouts';
import { CardSkin, IdCard } from './CardComputer/types';
import { useBackend } from '../backend';
import { CardInformation, DropdownCardSkins } from './CardComputer/card_details';
import { AccessList, AccessRegion } from './common/AccessList';

type Data = {
  card: IdCard;
  card_skins: CardSkin[];
  all_centcom_skins: CardSkin[];
  regions: AccessRegion[];
};

export const IdCardModifier = () => {
  const { act, data } = useBackend<Data>();
  const { card, card_skins, all_centcom_skins, regions } = data;
  return (
    <Window width={600} height={565}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                <Section title="Basic Information">
                  <CardInformation card={card} />
                  <LabeledList.Item label="Job Name">
                    <Button
                      icon={!card || card.rank === 'Unknown' ? 'exclamation-triangle' : 'pencil-alt'}
                      selected={!!card}
                      onClick={() => act('set_job_name')}
                    >
                      {card?.rank}
                    </Button>
                  </LabeledList.Item>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <DropdownCardSkins
                  is_centcom={true}
                  card={card}
                  card_skins={card_skins}
                  all_centcom_skins={all_centcom_skins}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <AccessList
              accesses={regions}
              selectedList={card.access}
              accessMod={(ref) =>
                act('set', {
                  access: ref,
                })
              }
              grantAll={() => act('grant_all')}
              denyAll={() => act('clear_all')}
              grantDep={(ref) =>
                act('grant_region', {
                  region: ref,
                })
              }
              denyDep={(ref) =>
                act('deny_region', {
                  region: ref,
                })
              }
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
