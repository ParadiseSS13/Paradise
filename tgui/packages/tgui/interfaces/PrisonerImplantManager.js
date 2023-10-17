import { useBackend } from '../backend';
import { Button, Section, Box, Flex } from '../components';
import { LabeledList, LabeledListItem } from '../components/LabeledList';
import { ComplexModal, modalOpen } from './common/ComplexModal';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import { Window } from '../layouts';

export const PrisonerImplantManager = (props, context) => {
  const { act, data } = useBackend(context);
  const { loginState, prisonerInfo, chemicalInfo, trackingInfo } = data;

  let body;
  if (!loginState.logged_in) {
    return (
      <Window theme="security" resizable>
        <Window.Content>
          <LoginScreen />
        </Window.Content>
      </Window>
    );
  }

  let injectionAmount = [1, 5, 10]; // used for auto generating chemical implant inject buttons

  return (
    <Window theme="security" resizable>
      <ComplexModal />
      <Window.Content>
        <LoginInfo />
        <Section title="Prisoner Points Manager System">
          <LabeledList>
            <LabeledListItem label="Prisoner">
              <Button
                icon={prisonerInfo.name ? 'eject' : 'id-card'}
                selected={prisonerInfo.name}
                content={prisonerInfo.name ? prisonerInfo.name : '-----'}
                tooltip={prisonerInfo.name ? 'Eject ID' : 'Insert ID'}
                onClick={() => act('id_card')}
              />
            </LabeledListItem>
            <LabeledListItem label="Points">
              {prisonerInfo.points !== null ? prisonerInfo.points : '-/-'}
              <Button
                ml={2}
                icon="minus-square"
                disabled={prisonerInfo.points === null}
                content="Reset"
                onClick={() => act('reset_points')}
              />
            </LabeledListItem>
            <LabeledListItem label="Point Goal">
              {prisonerInfo.goal !== null ? prisonerInfo.goal : '-/-'}
              <Button
                ml={2}
                icon="pen"
                disabled={prisonerInfo.goal === null}
                content="Edit"
                onClick={() => modalOpen(context, 'set_points')}
              />
            </LabeledListItem>
            <LabeledListItem>
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
                Prisoners who meet their point goal will be able to
                automatically access their locker and return to the station
                using the shuttle.
              </box>
            </LabeledListItem>
          </LabeledList>
        </Section>
        <Section title="Tracking Implants">
          {trackingInfo.map((implant) => (
            <>
              <Box bold>Subject: {implant.subject}</Box>
              <Box key={implant.subject}>
                <LabeledList>
                  <LabeledListItem label="Location">
                    {implant.location}
                  </LabeledListItem>
                  <LabeledListItem label="Health">
                    {implant.health}
                  </LabeledListItem>
                  <LabeledListItem label="Prisoner">
                    <Button
                      icon="exclamation-triangle"
                      content="Warn"
                      tooltip="Broadcast a message to this poor sod"
                      onClick={() =>
                        modalOpen(context, 'warn', {
                          uid: implant.uid,
                        })
                      }
                    />
                  </LabeledListItem>
                </LabeledList>
              </Box>
              <br />
            </>
          ))}
        </Section>
        <Section title="Chemical Implants">
          {chemicalInfo.map((implant) => (
            <>
              <Box bold>Subject: {implant.name}</Box>
              <Box key={implant.name}>
                <LabeledList>
                  <LabeledListItem label="Remaining Reagents">
                    {implant.volume}
                  </LabeledListItem>
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
              <br />
            </>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
