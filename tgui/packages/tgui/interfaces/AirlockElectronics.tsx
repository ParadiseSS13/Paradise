import { Button, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AccessList, AccessRegion } from './common/AccessList';

const NORTH = 1;
const SOUTH = 2;
const EAST = 4;
const WEST = 8;

export const AirlockElectronics = (props) => {
  return (
    <Window width={500} height={565}>
      <Window.Content>
        <Stack fill vertical>
          <UnrestrictedAccess />
          <ChooseAccess />
        </Stack>
      </Window.Content>
    </Window>
  );
};

type UnrestrictedAccessData = {
  unrestricted_dir: number;
};

const UnrestrictedAccess = (props) => {
  const { act, data } = useBackend<UnrestrictedAccessData>();
  const { unrestricted_dir } = data;
  return (
    <Section title="Access Control">
      <Stack fill vertical>
        <Stack.Item bold mb={1}>
          Unrestricted Access From:
        </Stack.Item>
        <Stack fill>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="arrow-left"
              content="East"
              selected={unrestricted_dir & EAST}
              onClick={() =>
                act('unrestricted_access', {
                  unres_dir: EAST,
                })
              }
            />
          </Stack.Item>

          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="arrow-up"
              content="South"
              selected={unrestricted_dir & SOUTH}
              onClick={() =>
                act('unrestricted_access', {
                  unres_dir: SOUTH,
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="arrow-right"
              content="West"
              selected={unrestricted_dir & WEST}
              onClick={() =>
                act('unrestricted_access', {
                  unres_dir: WEST,
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              textAlign="center"
              icon="arrow-down"
              content="North"
              selected={unrestricted_dir & NORTH}
              onClick={() =>
                act('unrestricted_access', {
                  unres_dir: NORTH,
                })
              }
            />
          </Stack.Item>
        </Stack>
      </Stack>
    </Section>
  );
};

type AirlockElectronicsData = {
  selected_accesses: number[];
  one_access: BooleanLike;
  regions: AccessRegion[];
};

export const ChooseAccess = (props) => {
  const { act, data } = useBackend<AirlockElectronicsData>();
  const { selected_accesses, one_access, regions } = data;
  return (
    <AccessList
      sectionButtons={<></>}
      grantableList={[]}
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
  );
};
