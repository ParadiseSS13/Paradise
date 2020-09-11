import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Grid } from '../components';
import { Window } from '../layouts';
import { GridColumn } from '../components/Grid';

export const Teleporter = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    calibrated,
    calibrating,
    powerstation,
    isGate,
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
                  tooltip="Teleport to another teleport hub"
                  color={isGate ? 'good' : null}
                  onClick={() => act('regimeset')}> Gate
                </Button>
                <Button
                  tooltip="One-way teleport"
                  color={isGate ? null : 'good'}
                  onClick={() => act('regimeset')}>
                  Teleporter
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Teleport target">
                <Button
                  icon="edit"
                  tooltip="Changes the destination"
                  content={target} onClick={() => act('settarget')}
                  color={target !== "None" ? null : "bad"}
                />
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
                          Accidents may occur when calibration is not optimal"
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
        {(locked && powerstation && teleporterhub)
        && (
          <Section title="GPS">
            <LabeledList>
              <LabeledList.Item label="GPS">
                <Box class="ml-1">
                  <Button
                    content="Set target"
                    tooltip="Sets target from GPS memory"
                    icon="arrow-down"
                    onClick={() => act('lock')}
                  />
                  <Button
                    content="Eject"
                    tooltip="Ejects the gps device"
                    icon="eject"
                    onClick={() => act('eject')}
                  />
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
