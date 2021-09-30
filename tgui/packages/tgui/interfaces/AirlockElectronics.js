// code\game\machinery\doors\airlock_electronics.dm
import { useBackend } from '../backend';
import { Button, Divider, Flex, Grid, Section } from '../components';
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
          Unrestricted Access From:
        </Flex.Item>
        <Grid>
          <Grid.Column>
            <Button
              fluid
              textAlign="center"
              icon="arrow-down"
              content="North"
              selected={unrestricted_dir === "north" ? "selected" : null}
              onClick={() => act('unrestricted_access', {
                unres_dir: "North",
              })}
            />
          </Grid.Column>
          <Grid.Column>
            <Button
              fluid
              textAlign="center"
              icon="arrow-up"
              content="South"
              selected={unrestricted_dir === "south" ? "selected" : null}
              onClick={() => act('unrestricted_access', {
                unres_dir: "South",
              })}
            />
          </Grid.Column>
          <Grid.Column>
            <Button
              fluid
              textAlign="center"
              icon="arrow-left"
              content="East"
              selected={unrestricted_dir === "east" ? "selected" : null}
              onClick={() => act('unrestricted_access', {
                unres_dir: "East",
              })}
            />
          </Grid.Column>
          <Grid.Column>
            <Button
              fluid
              textAlign="center"
              icon="arrow-right"
              content="West"
              selected={unrestricted_dir === "west" ? "selected" : null}
              onClick={() => act('unrestricted_access', {
                unres_dir: "West",
              })}
            />
          </Grid.Column>
        </Grid>
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
            checked={one_access}
            content="One"
            onClick={() => act('set_one_access', {
              access: 'one',
            })}
          />
          <Button.Checkbox
            checked={!one_access}
            content="All"
            onClick={() => act('set_one_access', {
              access: 'all',
            })}
          />
        </Fragment>
      }
      accesses={regions}
      selectedList={selected_accesses}
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
