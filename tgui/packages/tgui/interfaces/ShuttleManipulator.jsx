import { useState } from 'react';
import { Box, Button, LabeledList, Section, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const ShuttleManipulator = (props) => {
  const [tabIndex, setTabIndex] = useState(0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <StatusView />;
      case 1:
        return <TemplatesView />;
      case 2:
        return <ModificationView />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window width={650} height={700}>
      <Window.Content scrollable>
        <Box fillPositionedParent>
          <Tabs>
            <Tabs.Tab key="Status" selected={0 === tabIndex} onClick={() => setTabIndex(0)} icon="info-circle">
              Status
            </Tabs.Tab>
            <Tabs.Tab key="Templates" selected={1 === tabIndex} onClick={() => setTabIndex(1)} icon="file-import">
              Templates
            </Tabs.Tab>
            <Tabs.Tab key="Modification" selected={2 === tabIndex} onClick={() => setTabIndex(2)} icon="tools">
              Modification
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

const StatusView = (props) => {
  const { act, data } = useBackend();

  const { shuttles } = data;

  return (
    <Box>
      {shuttles.map((s) => (
        <Section key={s.name} title={s.name}>
          <LabeledList>
            <LabeledList.Item label="ID">{s.id}</LabeledList.Item>
            <LabeledList.Item label="Shuttle Timer">{s.timeleft}</LabeledList.Item>
            <LabeledList.Item label="Shuttle Mode">{s.mode}</LabeledList.Item>
            <LabeledList.Item label="Shuttle Status">{s.status}</LabeledList.Item>
            <LabeledList.Item label="Actions">
              <Button
                content="Jump To"
                icon="location-arrow"
                onClick={() => act('jump_to', { type: 'mobile', id: s.id })}
              />
              <Button content="Fast Travel" icon="fast-forward" onClick={() => act('fast_travel', { id: s.id })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </Box>
  );
};

const TemplatesView = (props) => {
  const { act, data } = useBackend();

  const { templates_tabs, existing_shuttle, templates } = data;

  return (
    <Box>
      <Tabs>
        {templates_tabs.map((t) => (
          <Tabs.Tab
            key={t}
            selected={t === existing_shuttle.id}
            icon="file"
            onClick={() => act('select_template_category', { cat: t })}
          >
            {t}
          </Tabs.Tab>
        ))}
      </Tabs>
      {!!existing_shuttle &&
        templates[existing_shuttle.id].templates.map((t) => (
          <Section key={t.name} title={t.name}>
            <LabeledList>
              {t.description && <LabeledList.Item label="Description">{t.description}</LabeledList.Item>}
              {t.admin_notes && <LabeledList.Item label="Admin Notes">{t.admin_notes}</LabeledList.Item>}
              <LabeledList.Item label="Actions">
                <Button
                  content="Load Template"
                  icon="download"
                  onClick={() => act('select_template', { shuttle_id: t.shuttle_id })}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
    </Box>
  );
};

const ModificationView = (props) => {
  const { act, data } = useBackend();

  const { existing_shuttle, selected } = data;

  return (
    <Box>
      {existing_shuttle ? (
        <Section title={'Selected Shuttle: ' + existing_shuttle.name}>
          <LabeledList>
            <LabeledList.Item label="Status">{existing_shuttle.status}</LabeledList.Item>
            {existing_shuttle.timer && <LabeledList.Item label="Timer">{existing_shuttle.timeleft}</LabeledList.Item>}
            <LabeledList.Item label="Actions">
              <Button
                content="Jump To"
                icon="location-arrow"
                onClick={() => act('jump_to', { type: 'mobile', id: existing_shuttle.id })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ) : (
        <Section title="Selected Shuttle: None" />
      )}

      {selected ? (
        <Section title={'Selected Template: ' + selected.name}>
          <LabeledList>
            {selected.description && <LabeledList.Item label="Description">{selected.description}</LabeledList.Item>}
            {selected.admin_notes && <LabeledList.Item label="Admin Notes">{selected.admin_notes}</LabeledList.Item>}
            <LabeledList.Item label="Actions">
              <Button
                content="Preview"
                icon="eye"
                onClick={() => act('preview', { shuttle_id: selected.shuttle_id })}
              />
              <Button content="Load" icon="download" onClick={() => act('load', { shuttle_id: selected.shuttle_id })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ) : (
        <Section title="Selected Template: None" />
      )}
    </Box>
  );
};
