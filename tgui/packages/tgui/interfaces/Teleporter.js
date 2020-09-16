import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Grid, Dropdown, Flex } from '../components';
import { Window } from '../layouts';
import { GridColumn } from '../components/Grid';

export const Teleporter = (props, context) => {
  const { act, data } = useBackend(context);
  let targetsTeleport = data.targetsTeleport ? data.targetsTeleport : {};
  const REGIME_TELEPORT = 0;
  const REGIME_GATE = 1;
  const REGIME_GPS = 2;
  const {
    calibrated,
    calibrating,
    powerstation,
    regime,
    teleporterhub,
    target,
    locked,
  } = data;
  return (
    <Window>
      <Window.Content>
        {(!powerstation || !teleporterhub)
        && (
          <Section
            title="Error">
            {teleporterhub}
            {!powerstation
            && (
              <Box color="bad"> Powerstation not linked </Box>
            )}
            {powerstation && !teleporterhub
            && (
              <Box color="bad"> Teleporter hub not linked </Box>
            )}
          </Section>
        )}
        {(powerstation && teleporterhub)
        && (
          <Section title="Status">
            <LabeledList>
              <LabeledList.Item label="Regime">
                <Button
                  tooltip="Teleport to another teleport hub. "
                  color={regime === REGIME_GATE ? 'good' : null}
                  onClick={() =>
                    act('setregime', { regime: REGIME_GATE })}>
                  Gate
                </Button>
                <Button
                  tooltip="One-way teleport. "
                  color={regime === REGIME_TELEPORT ? 'good' : null}
                  onClick={() =>
                    act('setregime', { regime: REGIME_TELEPORT })}>
                  Teleporter
                </Button>
                <Button
                  tooltip="Teleport to a location stored in a GPS device. "
                  color={regime === REGIME_GPS ? 'good' : null}
                  disabled={locked ? false : true}
                  onClick={() =>
                    act('setregime', { regime: REGIME_GPS })}>
                  GPS
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Teleport target">
                {/* The duplication of the dropdowns is due to the
                  updates of selected not affecting the state
                  of the dropdown */}
                {regime === REGIME_TELEPORT && (
                  <Dropdown
                    width="220px"
                    selected={target}
                    options={Object.keys(targetsTeleport)}
                    color={target !== "None" ? "default" : "bad"}
                    onSelected={val => act('settarget',
                      {
                        x: targetsTeleport[val]["x"],
                        y: targetsTeleport[val]["y"],
                        z: targetsTeleport[val]["z"],
                      })} />
                )}
                {regime === REGIME_GATE && (
                  <Dropdown
                    width="220px"
                    selected={target}
                    options={Object.keys(targetsTeleport)}
                    color={target !== "None" ? "default" : "bad"}
                    onSelected={val => act('settarget',
                      {
                        x: targetsTeleport[val]["x"],
                        y: targetsTeleport[val]["y"],
                        z: targetsTeleport[val]["z"],
                      })} />
                )}
                {regime === REGIME_GPS && (
                  <Box>
                    {target}
                  </Box>
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Calibration">
                {target !== 'None'
                && (
                  <Grid>
                    <GridColumn size="2">
                      {calibrating
                      && (
                        <Box color="average">
                          In Progress
                        </Box>
                      ) || (calibrated
                      && (
                        <Box color="good">
                          Optimal
                        </Box>
                      ) || (
                        <Box color="bad">
                          Sub-Optimal
                        </Box>
                      ))}
                    </GridColumn>
                    <GridColumn size="3">
                      <Box class="ml-1">
                        <Button
                          icon="sync-alt"
                          tooltip="Calibrates the hub. \
                          Accidents may occur when the \
                          calibration is not optimal."
                          disabled={(calibrated || calibrating) ? true : false}
                          onClick={() => act('calibrate')} />
                      </Box>
                    </GridColumn>
                  </Grid>
                )}
                {target === 'None'
                && (
                  <Box lineHeight="21px">
                    No target set
                  </Box>
                )}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
        {!!(locked && powerstation && teleporterhub && regime === REGIME_GPS)
        && (
          <Section title="GPS">
            <Flex direction="row" justify="space-around">
              <Button
                content="Upload GPS data"
                tooltip="Loads the GPS data from the device."
                icon="upload"
                onClick={() => act('load')} />
              <Button
                content="Eject"
                tooltip="Ejects the GPS device"
                icon="eject"
                onClick={() => act('eject')} />
            </Flex>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
