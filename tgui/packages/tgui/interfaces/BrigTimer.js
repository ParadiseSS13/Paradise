import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Dropdown, Box, Section } from '../components';
import { Window } from '../layouts';

export const BrigTimer = (props, context) => {
  const { act, data } = useBackend(context);
  data.nameText = data.occupant;
  if (data.timing) {
    if (data.prisoner_hasrec) {
      data.nameText = (<Box color="green">{data.occupant}</Box>);
    } else {
      data.nameText = (<Box color="red">{data.occupant}</Box>);
    }
  }
  let nameIcon = "pencil-alt";
  if (data.prisoner_name) {
    if (!data.prisoner_hasrec) {
      nameIcon = "exclamation-triangle";
    }
  }
  let nameOptions = [];
  let i = 0;
  for (i = 0; i < data.spns.length; i++) {
    nameOptions.push(data.spns[i]);
  }
  return (
    <Window resizable>
      <Window.Content>
        <Section title="Cell Information">
          <LabeledList>
            <LabeledList.Item label="Cell ID">
              {data.cell_id}
            </LabeledList.Item>
            <LabeledList.Item label="Occupant">
              {data.nameText}
            </LabeledList.Item>
            <LabeledList.Item label="Crimes">
              {data.crimes}
            </LabeledList.Item>
            <LabeledList.Item label="Brigged By">
              {data.brigged_by}
            </LabeledList.Item>
            <LabeledList.Item label="Time Brigged For">
              {data.time_set}
            </LabeledList.Item>
            <LabeledList.Item label="Time Left">
              {data.time_left}
            </LabeledList.Item>
            <LabeledList.Item label="Actions">
              <Fragment>
                <Button
                  icon="lightbulb-o"
                  content="Flash"
                  disabled={!data.isAllowed}
                  onClick={() => act('flash')} />
                <Button
                  icon="sync"
                  content="Reset Timer"
                  disabled={!data.timing || !data.isAllowed}
                  onClick={() => act('restart_timer')} />
                <Button
                  icon="eject"
                  content="Release Prisoner"
                  disabled={!data.timing || !data.isAllowed}
                  onClick={() => act('stop')} />
              </Fragment>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!data.timing && (
          <Section title="New Prisoner">
            <LabeledList>
              <LabeledList.Item label="Prisoner Name">
                <Button
                  icon={nameIcon}
                  content={data.prisoner_name ? data.prisoner_name : "-----"}
                  disabled={!data.isAllowed}
                  onClick={() => act('prisoner_name')} />
                {!!data.spns.length && (
                  <Dropdown
                    disabled={!data.isAllowed || !data.spns.length}
                    options={data.spns}
                    width="250px"
                    onSelected={value => act('prisoner_name',
                      {
                        prisoner_name: value,
                      })} />
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Prisoner Crimes">
                <Fragment>
                  <Button
                    icon="file-signature"
                    content="Add Crimes"
                    disabled={!data.isAllowed}
                    onClick={() => act('prisoner_charge')} />
                  <Button
                    icon="trash-alt"
                    content="Clear Crimes"
                    disabled={!data.isAllowed}
                    onClick={() => act('clear_crimes')} />
                  <LabeledList.Item label="Crimes">
                    {data.prisoner_charge}
                  </LabeledList.Item>
                </Fragment>
              </LabeledList.Item>
              <LabeledList.Item label="Prisoner Time">
                <Fragment>
                  <Button
                    icon="pencil-alt"
                    content={data.prisoner_time ? data.prisoner_time : "-----"}
                    disabled={!data.isAllowed}
                    onClick={() => act('prisoner_time')} />
                  <Button
                    icon="gavel"
                    content="Start Sentence"
                    disabled={!data.prisoner_name
                    || !data.prisoner_charge
                    || !data.prisoner_time
                    || !data.isAllowed}
                    onClick={() => act('start')} />
                </Fragment>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
