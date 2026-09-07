import { Button, Collapsible, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const CryopodConsole = (props) => {
  const { data } = useBackend();
  const { account_name, allow_items } = data;

  return (
    <Window title="Cryopod Console" width={400} height={480}>
      <Window.Content>
        <Section title={`Hello, ${account_name || '[REDACTED]'}!`}>
          This automated cryogenic freezing unit will safely store your corporeal form until your next assignment.
        </Section>
        <CrewList />
        {!!allow_items && <ItemList />}
      </Window.Content>
    </Window>
  );
};

const CrewList = (props) => {
  const { data } = useBackend();
  const { frozen_crew } = data;

  return (
    <Collapsible title="Stored Crew">
      {!frozen_crew.length ? (
        <NoticeBox>No stored crew!</NoticeBox>
      ) : (
        <Section>
          <LabeledList>
            {frozen_crew.map((person, index) => (
              <LabeledList.Item key={index} label={person.name}>
                {person.rank}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      )}
    </Collapsible>
  );
};

const ItemList = (props) => {
  const { act, data } = useBackend();
  const { frozen_items } = data;

  const replaceItemName = (item) => {
    let itemName = item.toString();
    if (itemName.startsWith('the ')) {
      itemName = itemName.slice(4, itemName.length);
    }
    return toTitleCase(itemName);
  };

  return (
    <Collapsible title="Stored Items">
      {!frozen_items.length ? (
        <NoticeBox>No stored items!</NoticeBox>
      ) : (
        <>
          <Section>
            <LabeledList>
              {frozen_items.map((item) => (
                <LabeledList.Item
                  key={item}
                  label={replaceItemName(item.name)}
                  buttons={
                    <Button
                      icon="arrow-down"
                      content="Drop"
                      mr={1}
                      onClick={() => act('one_item', { item: item.uid })}
                    />
                  }
                />
              ))}
            </LabeledList>
          </Section>
          <Button content="Drop All Items" color="red" onClick={() => act('all_items')} />
        </>
      )}
    </Collapsible>
  );
};
