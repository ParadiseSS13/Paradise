import { useBackend } from '../backend';
import {
  Button,
  Section,
  LabeledList,
  Box,
  ProgressBar,
  Stack,
  Tabs,
  Icon,
} from '../components';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';
import { AccessList } from './common/AccessList';

export const RCD = (props, context) => {
  return (
    <Window width={470} height={660}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <MatterReadout />
          <ConstructionType />
          <AirlockSettings />
          <TypesAndAccess />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MatterReadout = (props, context) => {
  const { data } = useBackend(context);
  const { matter, max_matter } = data;
  const good_matter = max_matter * 0.7;
  const average_matter = max_matter * 0.25;
  return (
    <Stack.Item>
      <Section title="Matter Storage">
        <ProgressBar
          ranges={{
            good: [good_matter, Infinity],
            average: [average_matter, good_matter],
            bad: [-Infinity, average_matter],
          }}
          value={matter}
          maxValue={max_matter}
        >
          <Box textAlign="center">{matter + ' / ' + max_matter + ' units'}</Box>
        </ProgressBar>
      </Section>
    </Stack.Item>
  );
};

const ConstructionType = () => {
  return (
    <Stack.Item>
      <Section fill title="Construction Type">
        <ConstructionTypeCheckbox mode_type="Floors and Walls" />
        <ConstructionTypeCheckbox mode_type="Airlocks" />
        <ConstructionTypeCheckbox mode_type="Windows" />
        <ConstructionTypeCheckbox mode_type="Deconstruction" />
      </Section>
    </Stack.Item>
  );
};

const ConstructionTypeCheckbox = (props, context) => {
  const { act, data } = useBackend(context);
  const { mode_type } = props;
  const { mode } = data;
  return (
    <Button.Checkbox
      content={mode_type}
      checked={mode === mode_type ? 1 : 0}
      onClick={() =>
        act('mode', {
          mode: mode_type,
        })
      }
    />
  );
};

const AirlockSettings = (props, context) => {
  const { act, data } = useBackend(context);
  const { door_name, electrochromic, airlock_glass } = data;
  return (
    <Stack.Item>
      <Section title="Airlock Settings">
        <Stack textAlign="center">
          <Stack.Item grow>
            <Button
              fluid
              color="transparent"
              icon="pen-alt"
              content={door_name}
              onClick={() => modalOpen(context, 'renameAirlock')}
            />
          </Stack.Item>
          <Stack.Item>
            {airlock_glass === 1 && (
              <Button
                fluid
                icon={electrochromic ? 'toggle-on' : 'toggle-off'}
                content={'Electrochromic'}
                selected={electrochromic}
                onClick={() => act('electrochromic')}
              />
            )}
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const TypesAndAccess = (props, context) => {
  const { act, data } = useBackend(context);
  const { tab, locked, one_access, selected_accesses, regions } = data;
  return (
    <Stack fill vertical mt={1}>
      <Stack.Item>
        <Tabs>
          <Tabs.Tab
            icon="cog"
            selected={tab === 1}
            onClick={() => act('set_tab', { tab: 1 })}
          >
            Airlock Types
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 2}
            icon="list"
            onClick={() => act('set_tab', { tab: 2 })}
          >
            Airlock Access
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      {tab === 1 ? (
        <Section fill scrollable title="Types">
          <Stack>
            <Stack.Item>
              <AirlockTypeList check_number={0} />
            </Stack.Item>
            <Stack.Item>
              <AirlockTypeList check_number={1} />
            </Stack.Item>
          </Stack>
        </Section>
      ) : tab === 2 && locked ? (
        <Section
          fill
          title="Access"
          buttons={
            <Button
              icon="lock-open"
              content="Unlock"
              onClick={() =>
                act('set_lock', {
                  new_lock: 'unlock',
                })
              }
            />
          }
        >
          <Stack fill>
            <Stack.Item grow textAlign="center" align="center" color="label">
              <Icon name="lock" size="5" mb={3} />
              <br />
              Airlock access selection is currently locked.
            </Stack.Item>
          </Stack>
        </Section>
      ) : (
        <Section fill scrollable>
          <AccessList
            sectionButtons={
              <Button
                icon="lock"
                content="Lock"
                onClick={() =>
                  act('set_lock', {
                    new_lock: 'lock',
                  })
                }
              />
            }
            usedByRcd={1}
            rcdButtons={
              <>
                <Button.Checkbox
                  checked={one_access}
                  content="One"
                  onClick={() =>
                    act('set_one_access', {
                      access: 'one',
                    })
                  }
                />
                <Button.Checkbox
                  checked={!one_access}
                  width={4}
                  content="All"
                  onClick={() =>
                    act('set_one_access', {
                      access: 'all',
                    })
                  }
                />
              </>
            }
            accesses={regions}
            selectedList={selected_accesses}
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
        </Section>
      )}
    </Stack>
  );
};

const AirlockTypeList = (props, context) => {
  const { act, data } = useBackend(context);
  const { door_types_ui_list, door_type } = data;
  const { check_number } = props;
  // Filter either odd or even airlocks in the list, based on what `check_number` is.
  const doors_filtered = [];
  for (let i = 0; i < door_types_ui_list.length; i++) {
    if (i % 2 === check_number) {
      doors_filtered.push(door_types_ui_list[i]);
    }
  }
  return (
    <Box>
      {doors_filtered.map((entry, i) => (
        <Stack key={i}>
          <Stack.Item>
            <img
              src={`data:image/jpeg;base64,${entry.image}`}
              style={{
                'vertical-align': 'middle',
                width: '32px',
                margin: '0px',
                'margin-left': '0px',
              }}
            />
          </Stack.Item>
          <Stack.Item>
            <Button.Checkbox
              ml={1.5}
              mt={1}
              width={14}
              checked={door_type === entry.type}
              content={entry.name}
              onClick={() =>
                act('door_type', {
                  door_type: entry.type,
                })
              }
            />
          </Stack.Item>
        </Stack>
      ))}
    </Box>
  );
};
