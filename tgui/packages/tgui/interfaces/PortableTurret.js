import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const PortableTurret = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    locked,
    on,
    lethal,
    lethal_is_configurable,
    targetting_is_configurable,
    check_weapons,
    neutralize_noaccess,
    neutralize_norecord,
    neutralize_criminals,
    neutralize_all,
    neutralize_unidentified,
    neutralize_cyborgs,
  } = data;
  return (
    <Window
      width={300}
      height={300}>
      <Window.Content>
        <NoticeBox>
          Swipe an ID card to {locked ? 'unlock' : 'lock'} this interface.
        </NoticeBox>
        <Fragment>
          <Section>
            <LabeledList>
              <LabeledList.Item label="Status">
                <Button
                  icon={on ? 'power-off' : 'times'}
                  content={on ? 'On' : 'Off'}
                  selected={on}
                  disabled={locked}
                  onClick={() => act('power')} />
                <Button
                  content={lethal ? 'Lethal' : 'Non-Lethal'}
                  color={lethal ? "bad" : ""}
                  disabled={locked || !lethal_is_configurable}
                  onClick={() => act('lethal')} />
              </LabeledList.Item>
            </LabeledList>
          </Section>
          {!!targetting_is_configurable && (
            <Fragment>
              <Section title="Humanoid Targets">
                <Button.Checkbox
                  fluid
                  checked={neutralize_criminals}
                  content="Wanted Criminals"
                  disabled={locked}
                  onClick={() => act('autharrest')} />
                <Button.Checkbox
                  fluid
                  checked={neutralize_norecord}
                  content="No sec record"
                  disabled={locked}
                  onClick={() => act('authnorecord')} />
                <Button.Checkbox
                  fluid
                  checked={check_weapons}
                  content="Unauthorized Weapons"
                  disabled={locked}
                  onClick={() => act('authweapon')} />
                <Button.Checkbox
                  fluid
                  checked={neutralize_noaccess}
                  content="Unauthorized Access"
                  disabled={locked}
                  onClick={() => act('authaccess')} />
              </Section>
              <Section title="Other Targets">
                <Button.Checkbox
                  fluid
                  checked={neutralize_unidentified}
                  content="Unidentified Lifesigns (Xenos, Animals, Etc)"
                  disabled={locked}
                  onClick={() => act('authxeno')} />
                <Button.Checkbox
                  fluid
                  checked={neutralize_cyborgs}
                  content="Cyborgs"
                  disabled={locked}
                  onClick={() => act('authborgs')} />
                <Button.Checkbox
                  fluid
                  checked={neutralize_all}
                  content="All Non-Synthetics"
                  disabled={locked}
                  onClick={() => act('authsynth')} />
              </Section>
            </Fragment>
          )}
        </Fragment>
      </Window.Content>
    </Window>
  );
};
