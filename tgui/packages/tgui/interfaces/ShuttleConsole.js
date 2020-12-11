import { useBackend } from '../backend';
import { Button, LabeledList, Box, Fragment, Section, NoticeBox } from '../components';
import { Window } from '../layouts';
import { LabeledListItem } from '../components/LabeledList';

export const ShuttleConsole = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Location">
              {data.status ? (
                data.status
              ) : (
                <NoticeBox color="red">
                  Shuttle Missing
                </NoticeBox>
              )}
            </LabeledList.Item>
            {!!data.shuttle && (// only show this stuff if there's a shuttle
              !!data.docking_ports_len && (
                <LabeledList.Item label={"Send to "}>
                  {data.docking_ports.map(port => (
                    <Button
                      icon="chevron-right"
                      key={port.name}
                      content={port.name}
                      onClick={() => act('move', {
                        move: port.id,
                      })} />
                  )
                  )}
                </LabeledList.Item>
              ) || (// ELSE, if there's no docking ports.
                <Fragment>
                  <LabeledListItem label="Status" color="red">
                    <NoticeBox color="red">
                      Shuttle Locked
                    </NoticeBox>
                  </LabeledListItem>
                  {!!data.admin_controlled && (
                    <LabeledListItem label="Authorization">
                      <Button
                        icon="exclamation-circle"
                        content="Request Authorization"
                        disabled={!data.status}
                        onClick={() => act('request')} />
                    </LabeledListItem>
                  )}
                </Fragment>
              )
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
