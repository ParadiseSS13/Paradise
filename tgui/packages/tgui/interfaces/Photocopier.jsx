import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Photocopier = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={400} height={440}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Section title="Photocopier" color="silver">
            <Stack mb={1}>
              <Stack.Item width={12}>Copies:</Stack.Item>
              <Stack.Item width="2em" bold>
                {data.copynumber}
              </Stack.Item>
              <Stack.Item style={{ float: 'right' }}>
                <Button icon="minus" textAlign="center" content="" onClick={() => act('minus')} />
                <Button icon="plus" textAlign="center" content="" onClick={() => act('add')} />
              </Stack.Item>
            </Stack>
            <Stack mb={2}>
              <Stack.Item width={12}>Toner:</Stack.Item>
              <Stack.Item bold>{data.toner}</Stack.Item>
            </Stack>
            <Stack mb={1}>
              <Stack.Item width={12}>Inserted Document:</Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  textAlign="center"
                  disabled={!data.copyitem && !data.mob}
                  content={data.copyitem ? data.copyitem : data.mob ? data.mob + "'s ass!" : 'document'}
                  onClick={() => act('removedocument')}
                />
              </Stack.Item>
            </Stack>
            <Stack>
              <Stack.Item width={12}>Inserted Folder:</Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  textAlign="center"
                  disabled={!data.folder}
                  content={data.folder ? data.folder : 'folder'}
                  onClick={() => act('removefolder')}
                />
              </Stack.Item>
            </Stack>
          </Section>
          <Section>
            <Actions />
          </Section>
          <Files />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Actions = (props) => {
  const { act, data } = useBackend();
  const { issilicon } = data;
  return (
    <>
      <Button fluid icon="copy" textAlign="center" content="Copy" onClick={() => act('copy')} />
      <Button fluid icon="file-import" textAlign="center" content="Scan" onClick={() => act('scandocument')} />
      {!!issilicon && (
        <>
          <Button
            fluid
            icon="file"
            color="green"
            textAlign="center"
            content="Print Text"
            onClick={() => act('ai_text')}
          />
          <Button
            fluid
            icon="image"
            color="green"
            textAlign="center"
            content="Print Image"
            onClick={() => act('ai_pic')}
          />
        </>
      )}
    </>
  );
};

const Files = (props) => {
  const { act, data } = useBackend();
  return (
    <Section fill scrollable title="Scanned Files">
      {data.files.map((file) => (
        <Section
          key={file.name}
          title={file.name}
          buttons={
            <Stack>
              <Button
                icon="print"
                content="Print"
                disabled={data.toner <= 0}
                onClick={() =>
                  act('filecopy', {
                    uid: file.uid,
                  })
                }
              />
              <Button.Confirm
                icon="trash-alt"
                content="Delete"
                color="bad"
                onClick={() =>
                  act('deletefile', {
                    uid: file.uid,
                  })
                }
              />
            </Stack>
          }
        />
      ))}
    </Section>
  );
};
