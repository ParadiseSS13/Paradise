// code\game\machinery\doors\airlock_electronics.dm
import { useBackend } from '../backend';
import { Button, Divider, Flex, Section } from '../components';
import { Window } from '../layouts';
import { AccessList } from './common/AccessList';
import { Fragment } from 'inferno';

export const AirlockElectronics = (props, context) => {
  return (
    <Window resizable>
      <UnrestrictedAccess />
      <Divider />
      <ChooseAccess />
    </Window>
  );
};

const UnrestrictedAccess = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    unrestricted_dir,
  } = data;
  return (
    <Section title="Access Control">
      <Flex direction="column">
        <Flex.Item bold mb={1}>
          Unrestricted Access Settings
        </Flex.Item>
        <Flex.Item>
          <Button width={5.7}
            icon="arrow-up"
            content="North"
            selected={data.unrestricted_dir === 1 ? "selected" : null}
            onClick={() => act('unrestricted_access', {
              unres_dir: 1,
            })}
          />
          <Button width={5.7}
            icon="arrow-down"
            content="South"
            selected={data.unrestricted_dir === 2 ? "selected" : null}
            onClick={() => act('unrestricted_access', {
              unres_dir: 2,
            })}
          />
          <Button width={5.7}
            icon="arrow-right"
            content="East"
            selected={data.unrestricted_dir === 3 ? "selected" : null}
            onClick={() => act('unrestricted_access', {
              unres_dir: 3,
            })}
          />
          <Button width={5.7}
            icon="arrow-left"
            content="West"
            selected={data.unrestricted_dir === 4 ? "selected" : null}
            onClick={() => act('unrestricted_access', {
              unres_dir: 4,
            })}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const ChooseAccess = (props, context) => {
  const { act, data }= useBackend(context);
  const {
    selected_accesses,
    one_access,
    regions,
  } = data;
  return (
    <AccessList
      usedByRcd={1}
      rcdButtons={
        <Fragment>
          <Button.Checkbox
            checked={data.one_access}
            content="One"
            onClick={() => act('set_one_access', {
              access: 'one',
            })}
          />
          <Button.Checkbox
            checked={!data.one_access}
            content="All"
            onClick={() => act('set_one_access', {
              access: 'all',
            })}
          />
        </Fragment>
      }
      accesses={data.regions}
      selectedList={data.selected_accesses}
      accessMod={ref => act('set', {
        access: ref,
      })}
      grantAll={() => act('grant_all')}
      denyAll={() => act('clear_all')}
      grantDep={ref => act('grant_region', {
        region: ref,
      })}
      denyDep={ref => act('deny_region', {
        region: ref,
      })}
    />
  );
};
