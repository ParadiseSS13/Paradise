import { Box, Button, Icon, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';

export const LibraryManager = (props) => {
  return (
    <Window width={600} height={600}>
      <ComplexModal />
      <Window.Content scrollable className="Layout__content--flexColumn">
        <PageContent />
      </Window.Content>
    </Window>
  );
};

const PageContent = (props) => {
  const { act, data } = useBackend();

  const { pagestate } = data;
  switch (pagestate) {
    case 1:
      return <MainMenu />;
    case 2:
      return <BooksByCkeyMenu />;
    case 3:
      return <ReportsMenu />;
    default:
      return "WE SHOULDN'T BE HERE!";
  }
};

const MainMenu = (properties) => {
  const { act, data } = useBackend();

  return (
    <Section>
      <Box fontSize="1.4rem" bold>
        <Icon name="user-shield" verticalAlign="middle" size={3} mr="1rem" />
        Library Manager
      </Box>
      <br />
      <Button
        icon="trash"
        width="auto"
        color="danger"
        content="Delete Book by SSID"
        onClick={() => modalOpen('specify_ssid_delete')}
      />
      <Button
        icon="user-slash"
        width="auto"
        color="danger"
        content="Delete All Books By CKEY"
        onClick={() => modalOpen('specify_ckey_delete')}
      />
      <br />
      <Button
        icon="search"
        width="auto"
        content="View All Books By CKEY"
        onClick={() => modalOpen('specify_ckey_search')}
      />
      <Button icon="search" width="auto" content="View All Reported Books" onClick={() => act('view_reported_books')} />
    </Section>
  );
};

const ReportsMenu = (properties) => {
  const { act, data } = useBackend();

  const { reports } = data;

  return (
    <Section>
      <Table className="Library__Booklist">
        <Box fontSize="1.2rem" bold>
          <Icon name="user-secret" verticalAlign="middle" size={2} mr="1rem" />
          <br />
          All Reported Books
          <br />
        </Box>
        <Button content="Return to Main" icon="arrow-alt-circle-left" onClick={() => act('return')} />
        <Table.Row bold>
          <Table.Cell>Uploader CKEY</Table.Cell>
          <Table.Cell>SSID</Table.Cell>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Author</Table.Cell>
          <Table.Cell>Report Type</Table.Cell>
          <Table.Cell>Reporter Ckey</Table.Cell>
          <Table.Cell textAlign="middle">Administrative Actions</Table.Cell>
        </Table.Row>
        {reports.map((report) => (
          <Table.Row key={report.id}>
            <Table.Cell bold>{report.uploader_ckey}</Table.Cell>
            <Table.Cell>{report.id}</Table.Cell>
            <Table.Cell textAlign="left">
              <Icon name="book" />
              {report.title}
            </Table.Cell>
            <Table.Cell textAlign="left">{report.author}</Table.Cell>
            <Table.Cell textAlign="left">{report.report_description}</Table.Cell>
            <Table.Cell bold>{report.reporter_ckey}</Table.Cell>
            <Table.Cell>
              <Button.Confirm
                content="Delete"
                icon="trash"
                onClick={() =>
                  act('delete_book', {
                    bookid: report.id,
                  })
                }
              />
              <Button
                content="Unflag"
                icon="flag"
                color="caution"
                onClick={() =>
                  act('unflag_book', {
                    bookid: report.id,
                  })
                }
              />
              <Button
                content="View"
                onClick={() =>
                  act('view_book', {
                    bookid: report.id,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const BooksByCkeyMenu = (properties) => {
  const { act, data } = useBackend();

  const { ckey, booklist } = data;

  return (
    <Section>
      <Table className="Library__Booklist">
        <Box fontSize="1.2rem" bold>
          <Icon name="user" verticalAlign="middle" size={2} mr="1rem" />
          <br />
          Books uploaded by {ckey}
          <br />
        </Box>
        <Button mt={1} content="Return to Main" icon="arrow-alt-circle-left" onClick={() => act('return')} />
        <Table.Row bold>
          <Table.Cell>SSID</Table.Cell>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Author</Table.Cell>
          <Table.Cell textAlign="middle">Administrative Actions</Table.Cell>
        </Table.Row>
        {booklist.map((booklist) => (
          <Table.Row key={booklist.id}>
            <Table.Cell>{booklist.id}</Table.Cell>
            <Table.Cell textAlign="left">
              <Icon name="book" />
              {booklist.title}
            </Table.Cell>
            <Table.Cell textAlign="left">{booklist.author}</Table.Cell>
            <Table.Cell textAlign="right">
              <Button.Confirm
                content="Delete"
                icon="trash"
                color="bad"
                onClick={() =>
                  act('delete_book', {
                    bookid: booklist.id,
                  })
                }
              />
              <Button
                content="View"
                onClick={() =>
                  act('view_book', {
                    bookid: booklist.id,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
