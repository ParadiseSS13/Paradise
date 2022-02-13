import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Icon, Input, LabeledList, Section, Table, Tabs } from '../components';
import { Window } from '../layouts';

export const LibraryComputer = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    booklist,
    usertype,
    loginstate,
    selectedbook,
  } = data;

  return (
    <Window resizable>
      <Window.Content scrollable className="Layout__content--flexColumn">
        <LibraryComputerNavigation />
        <LibraryPageContent />
      </Window.Content>
    </Window>
  );
};

const LibraryComputerNavigation = (properties, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  return (
    <Tabs>
      <Tabs.Tab
        selected={0 === tabIndex}
        onClick={() => setTabIndex(0)}>
        <Icon name="list" />
        Book Archives
      </Tabs.Tab>
      <Tabs.Tab
        selected={1 === tabIndex}
        onClick={() => setTabIndex(1)}>
        <Icon name="list" />
        Upload Book
      </Tabs.Tab>
      <Tabs.Tab
        selected={2 === tabIndex}
        onClick={() => setTabIndex(2)}>
        <Icon name="list" />
        Patron Manager
      </Tabs.Tab>
    </Tabs>
  );
};

const LibraryPageContent = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  switch (tabIndex) {
    case 0:
      return <LibraryBooksList />;
    case 1:
      return <UploadBooks />;
    default:
      return "WE SHOULDN'T BE HERE!";
  }
};

const LibraryBooksList = (properties, context) => {
  const { act, data } = useBackend(context);

  const {
    booklist,
    usertype,
    loginstate,
  } = data;

  return (
    <Section
      title="Book System Access">
      <Table className="LibraryBooks__list">
        <Table.Row bold>
          <Table.Cell>SSID</Table.Cell>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Author</Table.Cell>
          <Table.Cell>Ratings</Table.Cell>
          <Table.Cell>Category</Table.Cell>
          <Table.Cell textAlign="middle">Actions</Table.Cell>
        </Table.Row>
        {booklist
          .map(booklist => (
            <Table.Row
              key={booklist.id}>
              <Table.Cell>{booklist.id}</Table.Cell>
              <Table.Cell textAlign="left"><Icon name="book" /> {booklist.title}</Table.Cell>
              <Table.Cell textAlign="left">{booklist.author}</Table.Cell>
              <Table.Cell>nil</Table.Cell>
              <Table.Cell>{booklist.category}</Table.Cell>
              <Table.Cell textAlign="right">
                <Button
                  content="Report"
                  icon="flag"
                  color="bad"
                />
                <Button
                  content="Order"
                  icon="print"
                />
                <Button
                  content="More..."
                />
              </Table.Cell>
            </Table.Row>
          ))}
      </Table>
    </Section>
  );
};

const UploadBooks = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    selectedbook,
  } = data;

  return (
    <Section
      title="Book System Upload">
      <Flex>
        <Box>{selectedbook.title}</Box>
        <Box>{selectedbook.author}</Box>
      </Flex>
    </Section>
  );
};
