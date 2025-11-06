import { DragEvent, useState } from 'react';
import { Button, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type ListInputData = {
  items: string[];
  message: string;
  timeout: number;
  title: string;
};

export const RankedListInputModal = (props) => {
  const { act, data } = useBackend<ListInputData>();
  const { items = [], message = '', timeout, title } = data;
  const [editedItems, setEditedItems] = useState<string[]>(items);

  // Dynamically changes the window height based on the message.
  const windowHeight = 330 + Math.ceil(message.length / 3);

  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Section className="ListInput__Section" fill title={message}>
          <Stack fill vertical>
            <Stack.Item grow>
              <ListDisplay filteredItems={editedItems} setEditedItems={setEditedItems} />
            </Stack.Item>
            <Stack.Item mt={0.5}>
              <InputButtons input={editedItems} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/**
 * Displays the list of selectable items.
 * If a search query is provided, filters the items.
 */
const ListDisplay = (props) => {
  const { filteredItems, setEditedItems } = props;
  const [draggedItemIndex, setDraggedItemIndex] = useState<number | null>(null);

  // Handle the drag start event
  const handleDragStart = (index: number) => {
    setDraggedItemIndex(index);
  };

  // Handle the drag over event
  const handleDragOver = (event: DragEvent<HTMLDivElement>) => {
    event.preventDefault(); // Required to allow dropping
  };

  // Handle the drop event for items
  const handleDrop = (event: DragEvent<HTMLDivElement>, index: number | null = null) => {
    if (draggedItemIndex === null) return;

    const updatedItems = [...filteredItems];
    const draggedItem = updatedItems.splice(draggedItemIndex, 1)[0]; // Remove dragged item

    // If no index is provided, add the item to the end of the list (used for drop on section)
    if (index === null) {
      updatedItems.push(draggedItem);
    } else {
      updatedItems.splice(index, 0, draggedItem); // Insert dragged item at new position
    }

    setEditedItems(updatedItems);
    setDraggedItemIndex(null); // Reset the dragged item index
    event.stopPropagation();
  };

  return (
    <Section
      fill
      scrollable
      onDrop={(e) => handleDrop(e)} // Handle drop on Section
      onDragOver={handleDragOver} // Allow dropping on Section
    >
      <Table>
        {filteredItems.map((item, index) => (
          <Table.Row
            key={index}
            style={{
              padding: '8px',
            }}
            draggable
            onDragStart={() => handleDragStart(index)}
            onDragOver={handleDragOver}
            onDrop={(e) => handleDrop(e, index)}
          >
            <Button
              fluid
              py="0.25rem"
              color="transparent"
              style={{
                animation: 'none',
                transition: 'none',
                cursor: 'move',
              }}
              icon="grip-lines"
            >
              {item.replace(/^\w/, (c) => c.toUpperCase())}
            </Button>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
