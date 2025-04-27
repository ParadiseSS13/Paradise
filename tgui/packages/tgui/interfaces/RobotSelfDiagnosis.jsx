import { Flex, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const getDamageColor = (damage, maxDamage) => {
  let damageRatio = damage / maxDamage;
  if (damageRatio <= 0.2) {
    return 'good';
  } else if (damageRatio <= 0.5) {
    return 'average';
  } else {
    return 'bad';
  }
};

export const RobotSelfDiagnosis = (props) => {
  const { data } = useBackend();
  const { component_data } = data;
  return (
    <Window width={280} height={480}>
      <Window.Content scrollable>
        {component_data.map((entry, i) => (
          <Section key={i} title={capitalize(entry.name)}>
            {entry.installed <= 0 ? (
              <NoticeBox
                m={-0.5}
                height={3.5}
                color="red"
                style={{
                  fontStyle: 'normal',
                }}
              >
                <Flex height="100%">
                  <Flex.Item grow={1} textAlign="center" align="center" color="#e8e8e8">
                    {entry.installed === -1 ? 'Destroyed' : 'Missing'}
                  </Flex.Item>
                </Flex>
              </NoticeBox>
            ) : (
              <Flex>
                <Flex.Item width="72%">
                  <LabeledList>
                    <LabeledList.Item label="Brute Damage" color={getDamageColor(entry.brute_damage, entry.max_damage)}>
                      {entry.brute_damage}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Burn Damage"
                      color={getDamageColor(entry.electronic_damage, entry.max_damage)}
                    >
                      {entry.electronic_damage}
                    </LabeledList.Item>
                  </LabeledList>
                </Flex.Item>
                <Flex.Item width="50%">
                  <LabeledList>
                    <LabeledList.Item label="Powered" color={entry.powered ? 'good' : 'bad'}>
                      {entry.powered ? 'Yes' : 'No'}
                    </LabeledList.Item>
                    <LabeledList.Item label="Enabled" color={entry.status ? 'good' : 'bad'}>
                      {entry.status ? 'Yes' : 'No'}
                    </LabeledList.Item>
                  </LabeledList>
                </Flex.Item>
              </Flex>
            )}
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
