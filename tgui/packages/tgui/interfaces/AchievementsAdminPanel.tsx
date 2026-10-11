import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  orphaned_keys: string[];
  archived_keys: string[];
};

export const AchievementsAdminPanel = (_props) => {
  const { act, data } = useBackend<Data>();
  const { orphaned_keys, archived_keys } = data;
  return (
    <Window title="Achievements Admin Panel" width={540} height={680}>
      <Window.Content scrollable>
        <Section title="Orphaned achievements">
          <NoticeBox>
            These achievement keys are in the database but have no matching code definition. If the database is shared
            between servers, a key may belong to a server running newer code.
          </NoticeBox>
          <LabeledList>
            {orphaned_keys.map((key) => (
              <LabeledList.Item
                key={key}
                label=""
                buttons={
                  <>
                    <Button.Confirm onClick={() => act('archive', { key })}>Archive</Button.Confirm>
                    <Button.Confirm onClick={() => act('cleanup_orphan', { key })}>Cleanup</Button.Confirm>
                  </>
                }
              >
                {key}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Archived achievements">
          <NoticeBox>Archived achievement metadata remains in the database until cleaned up.</NoticeBox>
          <LabeledList>
            {archived_keys.map((key) => (
              <LabeledList.Item
                key={key}
                label=""
                buttons={<Button.Confirm onClick={() => act('cleanup_orphan', { key })}>Cleanup</Button.Confirm>}
              >
                {key}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};