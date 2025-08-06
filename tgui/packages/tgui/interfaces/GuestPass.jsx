import { Button, Icon, LabeledList, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AccessList } from './common/AccessList';

export const GuestPass = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={500} height={690}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab icon="id-card" selected={!data.showlogs} onClick={() => act('mode', { mode: 0 })}>
                Issue Pass
              </Tabs.Tab>
              <Tabs.Tab icon="scroll" selected={data.showlogs} onClick={() => act('mode', { mode: 1 })}>
                Records ({data.issue_log.length})
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            <Section title="Authorization">
              <LabeledList>
                <LabeledList.Item label="ID Card">
                  <Button
                    icon={data.scan_name ? 'eject' : 'id-card'}
                    selected={data.scan_name}
                    content={data.scan_name ? data.scan_name : '-----'}
                    tooltip={data.scan_name ? 'Eject ID' : 'Insert ID'}
                    onClick={() => act('scan')}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            {!data.showlogs && (
              <Section title="Issue Guest Pass">
                <LabeledList>
                  <LabeledList.Item label="Issue To">
                    <Button
                      icon="pencil-alt"
                      content={data.giv_name ? data.giv_name : '-----'}
                      disabled={!data.scan_name}
                      onClick={() => act('giv_name')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Reason">
                    <Button
                      icon="pencil-alt"
                      content={data.reason ? data.reason : '-----'}
                      disabled={!data.scan_name}
                      onClick={() => act('reason')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Duration">
                    <Button
                      icon="pencil-alt"
                      content={data.duration ? data.duration : '-----'}
                      disabled={!data.scan_name}
                      onClick={() => act('duration')}
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            )}
          </Stack.Item>
          {!data.showlogs &&
            (!data.scan_name ? (
              <Stack.Item grow>
                <Section fill>
                  <Stack fill>
                    <Stack.Item bold grow fontSize={1.5} textAlign="center" align="center" color="label">
                      <Icon name="id-card" size={5} color="gray" mb={5} />
                      <br />
                      Please, insert ID Card
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            ) : (
              <Stack.Item grow>
                <AccessList
                  sectionButtons={
                    <Button
                      icon="id-card"
                      content={data.printmsg}
                      disabled={!data.canprint}
                      onClick={() => act('issue')}
                    />
                  }
                  grantableList={data.grantableList}
                  accesses={data.regions}
                  selectedList={data.selectedAccess}
                  accessMod={(ref) =>
                    act('access', {
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
            ))}
          {!!data.showlogs && (
            <Stack.Item grow m={0}>
              <Section
                fill
                scrollable
                title="Issuance Log"
                buttons={
                  <Button icon="print" content={'Print'} disabled={!data.scan_name} onClick={() => act('print')} />
                }
              >
                {(!!data.issue_log.length && (
                  <LabeledList>
                    {data.issue_log.map((a, i) => (
                      <LabeledList.Item key={i}>{a}</LabeledList.Item>
                    ))}
                  </LabeledList>
                )) || (
                  <Stack fill>
                    <Stack.Item bold grow fontSize={1.5} textAlign="center" align="center" color="label">
                      <Icon.Stack>
                        <Icon name="scroll" size={5} color="gray" />
                        <Icon name="slash" size={5} color="red" />
                      </Icon.Stack>
                      <br />
                      No logs
                    </Stack.Item>
                  </Stack>
                )}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
