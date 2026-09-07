import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';

export const PrisonerImplantManager = (props) => {
  const { act, data } = useBackend();
  const { loginState, prisonerInfo, chemicalInfo, trackingInfo } = data;

  let body;
  if (!loginState.logged_in) {
    return (
      <Window theme="security" width={500} height={850}>
        <Window.Content>
          <LoginScreen />
        </Window.Content>
      </Window>
    );
  }

  let injectionAmount = [1, 5, 10]; // used for auto generating chemical implant inject buttons

  return (
    <Window theme="security" width={500} height={850}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <LoginInfo />
          <Stack.Item grow>
            <Section fill scrollable title="Prisoner Points Manager System">
              <LabeledList>
                <LabeledList.Item label="Prisoner">
                  <Button
                    icon={prisonerInfo.name ? 'eject' : 'id-card'}
                    selected={prisonerInfo.name}
                    content={prisonerInfo.name ? prisonerInfo.name : '-----'}
                    tooltip={prisonerInfo.name ? 'Eject ID' : 'Insert ID'}
                    onClick={() => act('id_card')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Points">
                  {prisonerInfo.points !== null ? prisonerInfo.points : '-/-'}
                  <Button
                    ml={2}
                    icon="minus-square"
                    disabled={prisonerInfo.points === null}
                    content="Reset"
                    onClick={() => act('reset_points')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Point Goal">
                  {prisonerInfo.goal !== null ? prisonerInfo.goal : '-/-'}
                  <Button
                    ml={2}
                    icon="pen"
                    disabled={prisonerInfo.goal === null}
                    content="Edit"
                    onClick={() => modalOpen('set_points')}
                  />
                </LabeledList.Item>
                <LabeledList.Item>
                  <box hidden={prisonerInfo.goal === null}>
                    1 minute of prison time should roughly equate to 150 points.
                    <br />
                    <br />
                    Sentences should not exceed 5000 points.
                    <br />
                    <br />
                    Permanent prisoners should not be given a point goal.
                    <br />
                    <br />
                    Prisoners who meet their point goal will be able to automatically access their locker and return to
                    the station using the shuttle.
                  </box>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Tracking Implants">
              {trackingInfo.map((implant) => (
                <>
                  <Box p={1} backgroundColor={'rgba(255, 255, 255, 0.05)'}>
                    <Box bold>Subject: {implant.subject}</Box>
                    <Box key={implant.subject}>
                      {' '}
                      <br />
                      <LabeledList>
                        <LabeledList.Item label="Location">{implant.location}</LabeledList.Item>
                        <LabeledList.Item label="Health">{implant.health}</LabeledList.Item>
                        <LabeledList.Item label="Prisoner">
                          <Button
                            icon="exclamation-triangle"
                            content="Warn"
                            tooltip="Broadcast a message to this poor sod"
                            onClick={() =>
                              modalOpen('warn', {
                                uid: implant.uid,
                              })
                            }
                          />
                        </LabeledList.Item>
                      </LabeledList>
                    </Box>
                  </Box>
                  <br />
                </>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Chemical Implants">
              {chemicalInfo.map((implant) => (
                <>
                  <Box p={1} backgroundColor={'rgba(255, 255, 255, 0.05)'}>
                    <Box bold>Subject: {implant.name}</Box>
                    <Box key={implant.name}>
                      {' '}
                      <br />
                      <LabeledList>
                        <LabeledList.Item label="Remaining Reagents">{implant.volume}</LabeledList.Item>
                      </LabeledList>
                      {injectionAmount.map((amount) => (
                        <Button
                          mt={2}
                          key={amount}
                          disabled={implant.volume < amount}
                          icon="syringe"
                          content={`Inject ${amount}u`}
                          onClick={() =>
                            act('inject', {
                              uid: implant.uid,
                              amount: amount,
                            })
                          }
                        />
                      ))}
                    </Box>
                  </Box>
                  <br />
                </>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
