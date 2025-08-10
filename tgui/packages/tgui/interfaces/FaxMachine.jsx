import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const FaxMachine = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={540} height={295}>
      <Window.Content>
        <Section title="Authorization">
          <LabeledList>
            <LabeledList.Item label="ID Card">
              <Button
                icon={data.scan_name ? 'eject' : 'id-card'}
                selected={data.scan_name}
                content={data.scan_name ? data.scan_name : '-----'}
                tooltip={data.scan_name ? 'Eject ID' : 'Insert ID'}
                onClick={() => act('scan')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Authorize">
              <Button
                icon={data.authenticated ? 'sign-out-alt' : 'id-card'}
                selected={data.authenticated}
                disabled={data.nologin}
                content={data.realauth ? 'Log Out' : 'Log In'}
                onClick={() => act('auth')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Fax Menu">
          <LabeledList>
            <LabeledList.Item label="Network">{data.network}</LabeledList.Item>
            <LabeledList.Item label="Document">
              <Button
                icon={data.paper ? 'eject' : 'paperclip'}
                disabled={!data.authenticated && !data.paper}
                content={data.paper ? data.paper : '-----'}
                onClick={() => act('paper')}
              />
              {!!data.paper && <Button icon="pencil-alt" content="Rename" onClick={() => act('rename')} />}
            </LabeledList.Item>
            <LabeledList.Item label="Sending To">
              <Button
                icon="print"
                content={data.destination ? data.destination : '-----'}
                disabled={!data.authenticated}
                onClick={() => act('dept')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Action">
              <Button
                icon="envelope"
                content={data.sendError ? data.sendError : 'Send'}
                disabled={!data.paper || !data.destination || !data.authenticated || data.sendError}
                onClick={() => act('send')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
