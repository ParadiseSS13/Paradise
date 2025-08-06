import { Box, Button, Dimmer, Icon, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const PersonalCrafting = (props) => {
  const { act, data } = useBackend();
  const {
    busy,
    category,
    display_craftable_only,
    display_compact,
    prev_cat,
    next_cat,
    subcategory,
    prev_subcat,
    next_subcat,
  } = data;
  return (
    <Window width={700} height={800}>
      <Window.Content scrollable>
        {!!busy && (
          <Dimmer fontSize="32px">
            <Icon name="cog" spin={1} />
            {' Crafting...'}
          </Dimmer>
        )}
        <Section
          title={category}
          buttons={
            <>
              <Button
                content="Show Craftable Only"
                icon={display_craftable_only ? 'check-square-o' : 'square-o'}
                selected={display_craftable_only}
                onClick={() => act('toggle_recipes')}
              />
              <Button
                content="Compact Mode"
                icon={display_compact ? 'check-square-o' : 'square-o'}
                selected={display_compact}
                onClick={() => act('toggle_compact')}
              />
            </>
          }
        >
          <Box>
            <Button content={prev_cat} icon="arrow-left" onClick={() => act('backwardCat')} />
            <Button content={next_cat} icon="arrow-right" onClick={() => act('forwardCat')} />
          </Box>
          {subcategory && (
            <Box>
              <Button content={prev_subcat} icon="arrow-left" onClick={() => act('backwardSubCat')} />
              <Button content={next_subcat} icon="arrow-right" onClick={() => act('forwardSubCat')} />
            </Box>
          )}
          {display_compact ? <CompactView /> : <ExpandedView />}
        </Section>
      </Window.Content>
    </Window>
  );
};

const CompactView = (props) => {
  const { act, data } = useBackend();
  const { display_craftable_only, can_craft, cant_craft } = data;
  return (
    <Box mt={1}>
      <LabeledList>
        {can_craft.map((r) => (
          <LabeledList.Item key={r.name} label={r.name}>
            <Button icon="hammer" content="Craft" onClick={() => act('make', { make: r.ref })} />
            {r.catalyst_text && <Button tooltip={r.catalyst_text} content="Catalysts" color="transparent" />}
            <Button tooltip={r.req_text} content="Requirements" color="transparent" />
            {r.tool_text && <Button tooltip={r.tool_text} content="Tools" color="transparent" />}
          </LabeledList.Item>
        ))}
        {!display_craftable_only &&
          cant_craft.map((r) => (
            <LabeledList.Item key={r.name} label={r.name}>
              <Button icon="hammer" content="Craft" disabled />
              {r.catalyst_text && <Button tooltip={r.catalyst_text} content="Catalysts" color="transparent" />}
              <Button tooltip={r.req_text} content="Requirements" color="transparent" />
              {r.tool_text && <Button tooltip={r.tool_text} content="Tools" color="transparent" />}
            </LabeledList.Item>
          ))}
      </LabeledList>
    </Box>
  );
};

const ExpandedView = (props) => {
  const { act, data } = useBackend();
  const { display_craftable_only, can_craft, cant_craft } = data;
  return (
    <Box mt={1}>
      {can_craft.map((r) => (
        <Section
          key={r.name}
          title={r.name}
          buttons={<Button icon="hammer" content="Craft" onClick={() => act('make', { make: r.ref })} />}
        >
          <LabeledList>
            {r.catalyst_text && <LabeledList.Item label="Catalysts">{r.catalyst_text}</LabeledList.Item>}
            <LabeledList.Item label="Requirements">{r.req_text}</LabeledList.Item>
            {r.tool_text && <LabeledList.Item label="Tools">{r.tool_text}</LabeledList.Item>}
          </LabeledList>
        </Section>
      ))}
      {!display_craftable_only &&
        cant_craft.map((r) => (
          <Section key={r.name} title={r.name} buttons={<Button icon="hammer" content="Craft" disabled />}>
            <LabeledList>
              {r.catalyst_text && <LabeledList.Item label="Catalysts">{r.catalyst_text}</LabeledList.Item>}
              <LabeledList.Item label="Requirements">{r.req_text}</LabeledList.Item>
              {r.tool_text && <LabeledList.Item label="Tools">{r.tool_text}</LabeledList.Item>}
            </LabeledList>
          </Section>
        ))}
    </Box>
  );
};
