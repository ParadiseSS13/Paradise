import { Box, Button, Dropdown, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Teleporter = (props) => {
  const { act, data } = useBackend();
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
    adv_beacon_allowed,
    advanced_beacon_locking,
  } = data;
  return (
    <Window width={350} height={325}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            {(!powerstation || !teleporterhub) && (
              <Section fill title="Error">
                {teleporterhub}
                {!powerstation && <Box color="bad"> Powerstation not linked </Box>}
                {powerstation && !teleporterhub && <Box color="bad"> Teleporter hub not linked </Box>}
              </Section>
            )}
            {powerstation && teleporterhub && (
              <Section
                fill
                scrollable
                title="Status"
                buttons={
                  // eslint-disable-next-line react/jsx-no-useless-fragment
                  <>
                    {!!adv_beacon_allowed && (
                      <>
                        <Box inline color="label">
                          Advanced Beacon Locking:&nbsp;
                        </Box>
                        <Button
                          selected={advanced_beacon_locking}
                          icon={advanced_beacon_locking ? 'toggle-on' : 'toggle-off'}
                          content={advanced_beacon_locking ? 'Enabled' : 'Disabled'}
                          onClick={() =>
                            act('advanced_beacon_locking', {
                              on: advanced_beacon_locking ? 0 : 1,
                            })
                          }
                        />
                      </>
                    )}
                  </>
                }
              >
                <Stack mb={1}>
                  <Stack.Item width={8.5} color="label">
                    Teleport target:
                  </Stack.Item>
                  <Stack.Item>
                    {/* The duplication of the dropdowns is due to the
                  updates of selected not affecting the state
                  of the dropdown */}
                    {regime === REGIME_TELEPORT && (
                      <Dropdown
                        width={18.2}
                        selected={target}
                        disabled={calibrating}
                        options={Object.keys(targetsTeleport)}
                        color={target !== 'None' ? 'default' : 'bad'}
                        onSelected={(val) =>
                          act('settarget', {
                            x: targetsTeleport[val]['x'],
                            y: targetsTeleport[val]['y'],
                            z: targetsTeleport[val]['z'],
                            tptarget: targetsTeleport[val]['pretarget'],
                          })
                        }
                      />
                    )}
                    {regime === REGIME_GATE && (
                      <Dropdown
                        width={18.2}
                        selected={target}
                        disabled={calibrating}
                        options={Object.keys(targetsTeleport)}
                        color={target !== 'None' ? 'default' : 'bad'}
                        onSelected={(val) =>
                          act('settarget', {
                            x: targetsTeleport[val]['x'],
                            y: targetsTeleport[val]['y'],
                            z: targetsTeleport[val]['z'],
                            tptarget: targetsTeleport[val]['pretarget'],
                          })
                        }
                      />
                    )}
                    {regime === REGIME_GPS && <Box>{target}</Box>}
                  </Stack.Item>
                </Stack>
                <Stack>
                  <Stack.Item width={8.5} color="label">
                    Regime:
                  </Stack.Item>
                  <Stack.Item grow textAlign="center">
                    <Button
                      fluid
                      content="Gate"
                      tooltip="Teleport to another teleport hub."
                      tooltipPosition="top"
                      color={regime === REGIME_GATE ? 'good' : null}
                      onClick={() => act('setregime', { regime: REGIME_GATE })}
                    />
                  </Stack.Item>
                  <Stack.Item grow textAlign="center">
                    <Button
                      fluid
                      content="Teleporter"
                      tooltip="One-way teleport."
                      tooltipPosition="top"
                      color={regime === REGIME_TELEPORT ? 'good' : null}
                      onClick={() => act('setregime', { regime: REGIME_TELEPORT })}
                    />
                  </Stack.Item>
                  <Stack.Item grow textAlign="center">
                    <Button
                      fluid
                      content="GPS"
                      tooltip="Teleport to a location stored in a GPS device."
                      tooltipPosition="top-end"
                      color={regime === REGIME_GPS ? 'good' : null}
                      disabled={locked ? false : true}
                      onClick={() => act('setregime', { regime: REGIME_GPS })}
                    />
                  </Stack.Item>
                </Stack>
                <Stack label="Calibration" mt={1}>
                  <Stack.Item width={8.5} color="label">
                    Calibration:
                  </Stack.Item>
                  <Stack.Item>
                    {target !== 'None' && (
                      <Stack fill>
                        <Stack.Item width={15.8} textAlign="center" mt={0.5}>
                          {(calibrating && <Box color="average">In Progress</Box>) ||
                            (calibrated && <Box color="good">Optimal</Box>) || <Box color="bad">Sub-Optimal</Box>}
                        </Stack.Item>
                        <Stack.Item grow>
                          <Button
                            icon="sync-alt"
                            tooltip="Calibrates the hub. \
                          Accidents may occur when the \
                          calibration is not optimal."
                            tooltipPosition="bottom-end"
                            disabled={calibrated || calibrating ? true : false}
                            onClick={() => act('calibrate')}
                          />
                        </Stack.Item>
                      </Stack>
                    )}
                    {target === 'None' && <Box lineHeight="21px">No target set</Box>}
                  </Stack.Item>
                </Stack>
              </Section>
            )}
            {!!(locked && powerstation && teleporterhub && regime === REGIME_GPS) && (
              <Section title="GPS">
                <Stack>
                  <Button
                    content="Upload GPS data"
                    tooltip="Loads the GPS data from the device."
                    icon="upload"
                    onClick={() => act('load')}
                  />
                  <Button content="Eject" tooltip="Ejects the GPS device" icon="eject" onClick={() => act('eject')} />
                </Stack>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
