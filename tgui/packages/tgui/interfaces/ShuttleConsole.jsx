import { Button, Fragment, LabeledList, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const ShuttleConsole = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={350} height={150}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Location">
              {data.status ? data.status : <NoticeBox color="red">Shuttle Missing</NoticeBox>}
            </LabeledList.Item>
            {!!data.shuttle && // only show this stuff if there's a shuttle
              ((!!data.docking_ports_len && (
                <LabeledList.Item label={'Send to '}>
                  {data.docking_ports.map((port) => (
                    <Button
                      icon="chevron-right"
                      key={port.name}
                      content={port.name}
                      onClick={() =>
                        act('move', {
                          move: port.id,
                        })
                      }
                    />
                  ))}
                </LabeledList.Item>
              )) || ( // ELSE, if there's no docking ports.
                <>
                  <LabeledList.Item label="Status" color="red">
                    <NoticeBox color="red">Shuttle Locked</NoticeBox>
                  </LabeledList.Item>
                  {!!data.admin_controlled && (
                    <LabeledList.Item label="Authorization">
                      <Button
                        icon="exclamation-circle"
                        content="Request Authorization"
                        disabled={!data.status}
                        onClick={() => act('request')}
                      />
                    </LabeledList.Item>
                  )}
                </>
              ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
