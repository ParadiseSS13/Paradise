import { useBackend, useLocalState } from '../backend';
import { Fragment } from 'inferno';
import { Box, Button, Flex, Icon, Input, LabeledList, Section, Table, Tabs } from '../components';
import { Window } from '../layouts';
import { ComplexModal, modalOpen, modalRegisterBodyOverride} from './common/ComplexModal';

const expandModalBodyOverride = (modal, context) => {
  const { act, data } = useBackend(context);
  const expandinfo = modal.args;
  return (
    <Section level={2} m="-1rem" pb="1rem">
      <LabeledList>
        <LabeledList.Item label="Title">{expandinfo.title}</LabeledList.Item>
        <LabeledList.Item label="Author">{expandinfo.author}</LabeledList.Item>
        <LabeledList.Item label="Summary">{expandinfo.summary}</LabeledList.Item>
        <LabeledList.Item label="Rating">{expandinfo.rating}</LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const reportModalBodyOverride = (modal, context) => {
  const { act, data } = useBackend(context);
  const report_content = modal.args;
  const {
    selected_report
  } = data;

  return (
    <Section level={2} m="-1rem" pb="1rem" title="Report this book for Rule Violations">
      <LabeledList>
        <LabeledList.Item label="Title">{report_content.title}</LabeledList.Item>
        <LabeledList.Item label="Reasons">
            <Box>
              {report_content
                .map(report_content => (
                <Fragment key={report_content.type}>
                  <Button
                    content={report_content.description}
                    selected = {report_content.type === selected_report}
                    onClick={() => act('set_report', {
                      report_type: report_content.type,
                    })}
                  />
                  <br />
                </Fragment>
              ))}
            </Box>
          </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const LibraryComputer = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window resizable>
      <ComplexModal/>
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
        Corporate Literature
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
    external_booklist,
    archive_pagenumber,
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
        {external_booklist
          .map(external_booklist => (
            <Table.Row
              key={external_booklist.id}>
              <Table.Cell>{external_booklist.id}</Table.Cell>
              <Table.Cell textAlign="left"><Icon name="book" /> {external_booklist.title}</Table.Cell>
              <Table.Cell textAlign="left">{external_booklist.author}</Table.Cell>
              <Table.Cell>nil</Table.Cell>
              <Table.Cell>{external_booklist.category}</Table.Cell>
              <Table.Cell textAlign="right">
                <Button
                  content="Report"
                  icon="flag"
                  color="bad"
                  onClick={() => modalOpen(context, 'report_book',{
                    bookid: external_booklist.id,
                  })}
                />
                <Button
                  content="Order"
                  icon="print"
                  onClick={() => act('order_external_book', {
                    bookid: external_booklist.id,
                  })}
                />
                <Button
                  content="More..."
                  onClick={() => modalOpen(context, 'expand_info',{
                    bookid: external_booklist.id,
                  })}
                />
              </Table.Cell>
            </Table.Row>
          ))}
      </Table>
      <div className="CameraConsole__toolbarRight">
          <Button
            icon="chevron-left"
            disabled={archive_pagenumber === 1}
            onClick={() => act('deincrementpage')}
          />
          <Button
            icon="chevron-right"
            onClick={() => act('incrementpage')}
          />
        </div>
    </Section>
  );
};

const ProgramatticBooks = (properties, context) => {
  const { act, data } = useBackend(context);

  const {
    programmatic_booklist,
  } = data;

  return (
    <Section
      title="Corporate Book Catalog">
      <Table className="LibraryBooks__list">
        <Table.Row bold>
          <Table.Cell>SSID</Table.Cell>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Author</Table.Cell>
          <Table.Cell textAlign="middle">Actions</Table.Cell>
        </Table.Row>
        {programmatic_booklist
          .map(programmatic_booklist => (
            <Table.Row
              key={programmatic_booklist.id}>
              <Table.Cell>{programmatic_booklist.id}</Table.Cell>
              <Table.Cell textAlign="left"><Icon name="book" /> {programmatic_booklist.title}</Table.Cell>
              <Table.Cell textAlign="left">{programmatic_booklist.author}</Table.Cell>
              <Table.Cell textAlign="right">
                <Button
                  content="Order"
                  icon="print"
                  onClick={() => act('order_programmatic_book', {
                    bookid: programmatic_booklist.id,
                  })}
                />
                <Button
                  content="More..."
                  onClick={() => modalOpen(context, 'expand_info',{
                    bookid: programmatic_booklist.id,
                  })}
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
      <LabeledList>
        <LabeledList.Item label="Title">
          <Button
            fluid
            textAlign="left"
            icon="pen"
            width="auto"
            disabled={selectedbook.copyright}
            content={selectedbook.title}
            onClick={() => modalOpen(context, 'edit_title')} />
        </LabeledList.Item>
        <LabeledList.Item label="Author">
          <Button
            fluid
            textAlign="left"
            icon="pen"
            width="auto"
            disabled={selectedbook.copyright}
            content={selectedbook.author}
            onClick={() => modalOpen(context, 'edit_author')} />
        </LabeledList.Item>
        <LabeledList.Item label="Copyright">
          {selectedbook.copyright}
        </LabeledList.Item>
        <LabeledList.Item label="Summary">
          {selectedbook.summary}
          <Button
            fluid
            textAlign="right"
            icon="pen"
            width="auto"
            disabled={selectedbook.copyright}
            content="Edit Summary"
            onClick={() => modalOpen(context, 'edit_summary')} />
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
                {checkout_data.timeleft >= 0
                  ? checkout_data.timeleft
                  : "LATE"}
              </Table.Cell>
              <Table.Cell textAlign="left">
                <Button
                  content="Mark Lost"
                  icon="flag"
                  color="bad"
                  disabled={!checkout_data.allow_fine}
                  onClick={() => act('reportlost')}
                />
                <Button
                  content="Apply Fine"
                  icon="coins"
                  color="bad"
                  disabled={!checkout_data.allow_fine}
                  onClick={() => act('applyfine')}
                />
              </Table.Cell>
            </Table.Row>
          ))}
      </Table>
    </Section>
  );
};

modalRegisterBodyOverride('expand_info', expandModalBodyOverride);
modalRegisterBodyOverride('report_book', reportModalBodyOverride );
