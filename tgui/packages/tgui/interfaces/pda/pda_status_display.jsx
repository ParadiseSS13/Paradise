import { Box, Button, LabeledList } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const pda_status_display = (props) => {
  const { act, data } = useBackend();

  const { records } = data;

  // The magic number values for the statdisp entry can be found in code\__DEFINES\machines.dm

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Code">
          <Button color="transparent" icon="trash" content="Clear" onClick={() => act('Status', { statdisp: 0 })} />
          <Button color="transparent" icon="clock" content="Evac ETA" onClick={() => act('Status', { statdisp: 1 })} />
          <Button color="transparent" icon="edit" content="Message" onClick={() => act('Status', { statdisp: 2 })} />
          <Button
            color="transparent"
            icon="exclamation-triangle"
            content="Red Alert"
            onClick={() =>
              act('Status', {
                statdisp: 3,
                alert: 'redalert',
              })
            }
          />
          <Button
            color="transparent"
            icon="boxes"
            content="NT Logo"
            onClick={() =>
              act('Status', {
                statdisp: 3,
                alert: 'default',
              })
            }
          />
          <Button
            color="transparent"
            icon="lock"
            content="Lockdown"
            onClick={() =>
              act('Status', {
                statdisp: 3,
                alert: 'lockdown',
              })
            }
          />
          <Button
            color="transparent"
            icon="biohazard"
            content="Biohazard"
            onClick={() =>
              act('Status', {
                statdisp: 3,
                alert: 'biohazard',
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Message line 1">
          <Button content={records.message1 + ' (set)'} icon="pen" onClick={() => act('SetMessage', { msgnum: 1 })} />
        </LabeledList.Item>
        <LabeledList.Item label="Message line 2">
          <Button content={records.message2 + ' (set)'} icon="pen" onClick={() => act('SetMessage', { msgnum: 2 })} />
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};
