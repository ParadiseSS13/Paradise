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
        General Literature
      </Tabs.Tab>
      <Tabs.Tab
        selected={2 === tabIndex}
        onClick={() => setTabIndex(2)}>
        <Icon name="list" />
        Upload Book
      </Tabs.Tab>
      <Tabs.Tab
        selected={3 === tabIndex}
        onClick={() => setTabIndex(3)}>
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
      return <ProgramatticBooks />;
    case 2:
      return <UploadBooks />;
    case 3:
      return <PatronManager />;
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
                  onClick={() => act('reportbook')}
                />
                <Button
                  content="Order"
                  icon="print"
                  onClick={() => act('orderbook')}
                />
                <Button
                  content="More..."
                  onClick={() => act('expandinfo')}
                />
              </Table.Cell>
            </Table.Row>
          ))}
      </Table>
    </Section>
  );
};

const ProgramatticBooks = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    selectedbook,
  } = data;

  return (
    <Section
      title="Book System Upload">
      <Flex />

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
      <LabeledList>
        <LabeledList.Item label="Title">
          <Button
            fluid
            textAlign="left"
            width="auto"
            disabled={selectedbook.copyright}
            content={selectedbook.title}
            onClick={() => act('titleedit')} />
        </LabeledList.Item>
        <LabeledList.Item label="Author">
          <Button
            fluid
            textAlign="left"
            width="auto"
            disabled={selectedbook.copyright}
            content={selectedbook.author}
            onClick={() => act('authoredit')} />
        </LabeledList.Item>
        <LabeledList.Item label="Copyright">
          {selectedbook.copyright}
        </LabeledList.Item>
        <LabeledList.Item label="Summary">
          {selectedbook.summary}
          <Button
            fluid
            textAlign="right"
            width="auto"
            disabled={selectedbook.copyright}
            content="Edit Summary"
            onClick={() => act('summaryedit')} />
        </LabeledList.Item>
      </LabeledList>
      <Button
        fluid
        textAlign="center"
        width="auto"
        disabled={selectedbook.copyright}
        content="Upload Book"
        onClick={() => act('uploadbook')} />
    </Section>
  );
};

const PatronManager = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    checkout_data,
  } = data;

  return (
    <Section
      title="Checked Out Books">
      <Table className="LibraryBooks__list">
        <Table.Row bold>
          <Table.Cell>Patron</Table.Cell>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Time Left</Table.Cell>
          <Table.Cell>Actions</Table.Cell>
        </Table.Row>
        {checkout_data
          .map(checkout_data => (
            <Table.Row
              key={checkout_data.libraryid}>
              <Table.Cell><Icon name="user-tag" /> {checkout_data.patron_name}</Table.Cell>
              <Table.Cell textAlign="left">{checkout_data.title}</Table.Cell>
              <Table.Cell>
                {checkout_data.islate === 1
                  ? checkout_data.timeleft
                  : "LATE"}
              </Table.Cell>
              <Table.Cell textAlign="left">
                <Button
                  content="Mark Lost"
                  icon="flag"
                  color="bad"
                  disabled={checkout_data.allow_fine}
                  onClick={() => act('reportlost')}
                />
                <Button
                  content="Apply Fine"
                  icon="coins"
                  color="bad"
                  disabled={checkout_data.allow_fine}
                  onClick={() => act('applyfine')}
                />
              </Table.Cell>
            </Table.Row>
          ))}
      </Table>
    </Section>
  );
};
