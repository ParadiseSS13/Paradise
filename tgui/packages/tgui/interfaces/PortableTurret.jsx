import { Button, LabeledList, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AccessList } from './common/AccessList';

export const PortableTurret = (props) => {
  const { act, data } = useBackend();
  const {
    locked,
    on,
    lethal,
    lethal_is_configurable,
    targetting_is_configurable,
    check_weapons,
    neutralize_noaccess,
    access_is_configurable,
    regions,
    selectedAccess,
    one_access,
    neutralize_norecord,
    neutralize_criminals,
    neutralize_all,
    neutralize_unidentified,
    neutralize_cyborgs,
  } = data;
  return (
    <Window width={475} height={750}>
      <Window.Content>
        <Stack fill vertical>
          <NoticeBox>Swipe an ID card to {locked ? 'unlock' : 'lock'} this interface.</NoticeBox>
          <Stack.Item m={0}>
            <Section>
              <LabeledList>
                <LabeledList.Item label="Status">
                  <Button
                    icon={on ? 'power-off' : 'times'}
                    content={on ? 'On' : 'Off'}
                    selected={on}
                    disabled={locked}
                    onClick={() => act('power')}
                  />
                </LabeledList.Item>
                {!!lethal_is_configurable && (
                  <LabeledList.Item label="Lethals">
                    <Button
                      icon={lethal ? 'exclamation-triangle' : 'times'}
                      content={lethal ? 'On' : 'Off'}
                      color={lethal ? 'bad' : ''}
                      disabled={locked}
                      onClick={() => act('lethal')}
                    />
                  </LabeledList.Item>
                )}
                {!!access_is_configurable && (
                  <LabeledList.Item label="One Access Mode">
                    <Button
                      icon={one_access ? 'address-card' : 'exclamation-triangle'}
                      content={one_access ? 'On' : 'Off'}
                      selected={one_access}
                      disabled={locked}
                      onClick={() => act('one_access')}
                    />
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
          </Stack.Item>
          {!!targetting_is_configurable && (
            <Stack.Item>
              <Section title="Humanoid Targets">
                <Button.Checkbox
                  fluid
                  checked={neutralize_criminals}
                  content="Wanted Criminals"
                  disabled={locked}
                  onClick={() => act('autharrest')}
                />
                <Button.Checkbox
                  fluid
                  checked={neutralize_norecord}
                  content="No Sec Record"
                  disabled={locked}
                  onClick={() => act('authnorecord')}
                />
                <Button.Checkbox
                  fluid
                  checked={check_weapons}
                  content="Unauthorized Weapons"
                  disabled={locked}
                  onClick={() => act('authweapon')}
                />
                <Button.Checkbox
                  fluid
                  checked={neutralize_noaccess}
                  content="Unauthorized Access"
                  disabled={locked}
                  onClick={() => act('authaccess')}
                />
              </Section>
              <Section title="Other Targets">
                <Button.Checkbox
                  fluid
                  checked={neutralize_unidentified}
                  content="Unidentified Lifesigns (Xenos, Animals, Etc)"
                  disabled={locked}
                  onClick={() => act('authxeno')}
                />
                <Button.Checkbox
                  fluid
                  checked={neutralize_cyborgs}
                  content="Cyborgs"
                  disabled={locked}
                  onClick={() => act('authborgs')}
                />
                <Button.Checkbox
                  fluid
                  checked={neutralize_all}
                  content="All Non-Synthetics"
                  disabled={locked}
                  onClick={() => act('authsynth')}
                />
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            {!!access_is_configurable && (
              <AccessList
                accesses={regions}
                selectedList={selectedAccess}
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
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
