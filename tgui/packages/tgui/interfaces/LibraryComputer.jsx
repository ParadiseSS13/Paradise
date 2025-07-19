import { Fragment, useState } from 'react';
import { Box, Button, Dropdown, Icon, LabeledList, NoticeBox, Section, Stack, Table, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal, modalOpen, modalRegisterBodyOverride } from './common/ComplexModal';

export const LibraryComputer = (props) => {
  const [tabIndex, setTabIndex] = useState(0);
  return (
    <Window width={1050} height={600}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <LibraryComputerNavigation tabIndex={tabIndex} setTabIndex={setTabIndex} />
          <LibraryPageContent tabIndex={tabIndex} />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const expandModalBodyOverride = (modal) => {
  const { act, data } = useBackend();
  const expandinfo = modal.args;

  const { user_ckey } = data;

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Title">{expandinfo.title}</LabeledList.Item>
        <LabeledList.Item label="Author">{expandinfo.author}</LabeledList.Item>
        <LabeledList.Item label="Summary">{expandinfo.summary}</LabeledList.Item>
        <LabeledList.Item label="Rating">
          {expandinfo.rating}
          <Icon name="star" color="yellow" verticalAlign="top" />
        </LabeledList.Item>
        {!expandinfo.isProgrammatic && (
          <LabeledList.Item label="Categories">{expandinfo.categories.join(', ')}</LabeledList.Item>
        )}
      </LabeledList>
      <br />
      {user_ckey === expandinfo.ckey && ( //  we only want the book author to be able to delete the book
        <Button
          content="Delete Book"
          icon="trash"
          color="red"
          disabled={expandinfo.isProgrammatic}
          onClick={() =>
            act('delete_book', {
              bookid: expandinfo.id,
              user_ckey: user_ckey,
            })
          }
        />
      )}
      <Button
        content="Report Book"
        icon="flag"
        color="red"
        disabled={expandinfo.isProgrammatic}
        onClick={() =>
          modalOpen('report_book', {
            bookid: expandinfo.id,
          })
        }
      />
      <Button
        content="Rate Book"
        icon="star"
        color="caution"
        disabled={expandinfo.isProgrammatic}
        onClick={() =>
          modalOpen('rate_info', {
            bookid: expandinfo.id,
          })
        }
      />
    </Section>
  );
};

const reportModalBodyOverride = (modal) => {
  const { act, data } = useBackend();
  const report_content = modal.args;
  const { selected_report, report_categories, user_ckey } = data;

  return (
    <Section level={2} m="-1rem" pb="1.5rem" title="Report this book for Rule Violations">
      <LabeledList>
        <LabeledList.Item label="Title">{report_content.title}</LabeledList.Item>
        <LabeledList.Item label="Reasons">
          <Box>
            {report_categories.map((report_categories, index) => (
              <Fragment key={index}>
                <Button
                  content={report_categories.description}
                  selected={report_categories.category_id === selected_report}
                  onClick={() =>
                    act('set_report', {
                      report_type: report_categories.category_id,
                    })
                  }
                />
                <br />
              </Fragment>
            ))}
          </Box>
        </LabeledList.Item>
      </LabeledList>
      <Button.Confirm
        bold
        icon="paper-plane"
        content="Submit Report"
        onClick={() =>
          act('submit_report', {
            bookid: report_content.id,
            user_ckey: user_ckey,
          })
        }
      />
    </Section>
  );
};

const RatingTools = (properties) => {
  const { act, data } = useBackend();

  const { selected_rating } = data;

  let ratingVals = [...Array(10)].map((_, i) => i + 1);
  return (
    <Stack>
      {ratingVals.map((rating_num, index) => (
        <Stack.Item key={index}>
          <Button
            bold
            icon="star"
            color={selected_rating >= rating_num ? 'caution' : 'default'}
            onClick={() =>
              act('set_rating', {
                rating_value: rating_num,
              })
            }
          />
        </Stack.Item>
      ))}
      <Stack.Item bold ml={2} fontSize="150%">
        {selected_rating + '/10'}
        <Icon name="star" color="yellow" ml={0.5} verticalAlign="top" />
      </Stack.Item>
    </Stack>
  );
};

const rateModalBodyOverride = (modal) => {
  const { act, data } = useBackend();
  const rate_content = modal.args;

  const { user_ckey } = data;

  return (
    <Section level={2} m="-1rem" pb="1.5rem">
      <LabeledList>
        <LabeledList.Item label="Title">{rate_content.title}</LabeledList.Item>
        <LabeledList.Item label="Author">{rate_content.author}</LabeledList.Item>
        <LabeledList.Item label="Rating">
          {rate_content.current_rating ? rate_content.current_rating : 0}
          <Icon name="star" color="yellow" ml={0.5} verticalAlign="middle" />
        </LabeledList.Item>
        <LabeledList.Item label="Total Ratings">
          {rate_content.total_ratings ? rate_content.total_ratings : 0}
        </LabeledList.Item>
      </LabeledList>
      <RatingTools />
      <Button.Confirm
        mt={2}
        content="Submit"
        icon="paper-plane"
        onClick={() =>
          act('rate_book', {
            bookid: rate_content.id,
            user_ckey: user_ckey,
          })
        }
      />
    </Section>
  );
};

const LibraryComputerNavigation = (props) => {
  const { data } = useBackend();
  const { tabIndex, setTabIndex } = props;
  const { login_state } = data;
  return (
    <Stack.Item mb={1}>
      <Tabs fluid textAlign="center">
        <Tabs.Tab selected={0 === tabIndex} onClick={() => setTabIndex(0)}>
          Book Archives
        </Tabs.Tab>
        <Tabs.Tab selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
          Corporate Literature
        </Tabs.Tab>
        <Tabs.Tab selected={2 === tabIndex} onClick={() => setTabIndex(2)}>
          Upload Book
        </Tabs.Tab>
        {login_state === 1 && (
          <Tabs.Tab selected={3 === tabIndex} onClick={() => setTabIndex(3)}>
            Patron Manager
          </Tabs.Tab>
        )}
        <Tabs.Tab selected={4 === tabIndex} onClick={() => setTabIndex(4)}>
          Inventory
        </Tabs.Tab>
      </Tabs>
    </Stack.Item>
  );
};

const LibraryPageContent = (props) => {
  const { tabIndex } = props;

  switch (tabIndex) {
    case 0:
      return <LibraryBooksList />;
    case 1:
      return <ProgramatticBooks />;
    case 2:
      return <UploadBooks />;
    case 3:
      return <PatronManager />;
    case 4:
      return <Inventory />;
    default:
      return "You are somehow on a tab that doesn't exist! Please let a coder know.";
  }
};

const SearchTools = (properties) => {
  const { act, data } = useBackend();

  const { searchcontent, book_categories, user_ckey } = data;

  let categoryMap = [];
  {
    book_categories.map((category) => (categoryMap[category.description] = category.category_id));
  }

  return (
    <Stack>
      <Stack.Item width="35%">
        <Box fontSize="1.2rem" m=".5em" bold>
          <Icon name="edit" verticalAlign="middle" size={1.5} mr="1rem" />
          Search Inputs
        </Box>
        <LabeledList>
          <LabeledList.Item label="Title">
            <Button
              textAlign="left"
              icon="pen"
              width={20}
              content={searchcontent.title || 'Input Title'}
              onClick={() => modalOpen('edit_search_title')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Author">
            <Button
              textAlign="left"
              icon="pen"
              width={20}
              content={searchcontent.author || 'Input Author'}
              onClick={() => modalOpen('edit_search_author')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Ratings">
            <Stack>
              <Stack.Item>
                <Button
                  mr={1}
                  width="min-content"
                  content={searchcontent.ratingmin}
                  onClick={() => modalOpen('edit_search_ratingmin')}
                />
              </Stack.Item>
              <Stack.Item>To</Stack.Item>
              <Stack.Item>
                <Button
                  ml={1}
                  width="min-content"
                  content={searchcontent.ratingmax}
                  onClick={() => modalOpen('edit_search_ratingmax')}
                />
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Stack.Item width="40%">
        <Box fontSize="1.2rem" m=".5em" bold>
          <Icon name="clipboard-list" verticalAlign="middle" size={1.5} mr="1rem" />
          Book Categories
        </Box>
        <LabeledList>
          <LabeledList.Item label="Select Categories">
            <Box mt={2}>
              <Dropdown
                mt={0.6}
                width="190px"
                options={book_categories.map((c) => c.description)}
                onSelected={(val) =>
                  act('toggle_search_category', {
                    category_id: categoryMap[val],
                  })
                }
              />
            </Box>
          </LabeledList.Item>
        </LabeledList>
        <br />
        {book_categories
          .filter((category) => searchcontent.categories.includes(category.category_id))
          .map((book_categories) => (
            <Button
              key={book_categories.category_id}
              content={book_categories.description}
              selected
              icon="unlink"
              onClick={() =>
                act('toggle_search_category', {
                  category_id: book_categories.category_id,
                })
              }
            />
          ))}
      </Stack.Item>
      <Stack.Item>
        <Box fontSize="1.2rem" m=".5em" bold>
          <Icon name="search-plus" verticalAlign="middle" size={1.5} mr="1rem" />
          Search Actions
        </Box>
        <Button content="Clear Search" icon="eraser" onClick={() => act('clear_search')} />
        {searchcontent.ckey ? (
          <Button
            mb={0.5}
            content="Stop Showing My Books"
            color="bad"
            icon="search"
            onClick={() => act('clear_ckey_search')}
          />
        ) : (
          <Button
            content="Find My Books"
            icon="search"
            onClick={() =>
              act('find_users_books', {
                user_ckey: user_ckey,
              })
            }
          />
        )}
      </Stack.Item>
    </Stack>
  );
};

const LibraryBooksList = (properties) => {
  const { act, data } = useBackend();

  const { external_booklist, archive_pagenumber, num_pages, login_state } = data;

  return (
    <Section
      fill
      scrollable
      title="Book System Access"
      buttons={
        <div>
          <Button
            icon="angle-double-left"
            disabled={archive_pagenumber === 1}
            onClick={() => act('deincrementpagemax')}
          />
          <Button icon="chevron-left" disabled={archive_pagenumber === 1} onClick={() => act('deincrementpage')} />
          <Button bold content={archive_pagenumber} onClick={() => modalOpen('setpagenumber')} />
          <Button
            icon="chevron-right"
            disabled={archive_pagenumber === num_pages}
            onClick={() => act('incrementpage')}
          />
          <Button
            icon="angle-double-right"
            disabled={archive_pagenumber === num_pages}
            onClick={() => act('incrementpagemax')}
          />
        </div>
      }
    >
      <SearchTools />
      <hr />
      <Table className="Library__Booklist">
        <Table.Row bold>
          <Table.Cell>SSID</Table.Cell>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Author</Table.Cell>
          <Table.Cell>Ratings</Table.Cell>
          <Table.Cell>Category</Table.Cell>
          <Table.Cell textAlign="middle">Actions</Table.Cell>
        </Table.Row>
        {external_booklist.map((external_booklist) => (
          <Table.Row key={external_booklist.id}>
            <Table.Cell>{external_booklist.id}</Table.Cell>
            <Table.Cell textAlign="left">
              <Icon name="book" mr={0.5} />
              {external_booklist.title.length > 45
                ? external_booklist.title.substr(0, 45) + '...'
                : external_booklist.title}
            </Table.Cell>
            <Table.Cell textAlign="left">
              {external_booklist.author.length > 30
                ? external_booklist.author.substr(0, 30) + '...' // we don't want obscenely long author names
                : external_booklist.author}
            </Table.Cell>
            <Table.Cell>
              {external_booklist.rating}
              <Icon name="star" ml={0.5} color="yellow" verticalAlign="middle" />
            </Table.Cell>
            <Table.Cell>{external_booklist.categories.join(', ').substr(0, 45)}</Table.Cell>
            <Table.Cell textAlign="right">
              {login_state === 1 && (
                <Button
                  content="Order"
                  icon="print"
                  onClick={() =>
                    act('order_external_book', {
                      bookid: external_booklist.id,
                    })
                  }
                />
              )}
              <Button
                content="More..."
                onClick={() =>
                  modalOpen('expand_info', {
                    bookid: external_booklist.id,
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

const ProgramatticBooks = (properties) => {
  const { act, data } = useBackend();

  const { programmatic_booklist, login_state } = data;

  return (
    <Section fill scrollable title="Corporate Book Catalog">
      <Table className="Library__Booklist">
        <Table.Row bold>
          <Table.Cell>SSID</Table.Cell>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Author</Table.Cell>
          <Table.Cell textAlign="middle">Actions</Table.Cell>
        </Table.Row>
        {programmatic_booklist.map((programmatic_booklist, index) => (
          <Table.Row key={index}>
            <Table.Cell>{programmatic_booklist.id}</Table.Cell>
            <Table.Cell textAlign="left">
              <Icon name="book" mr={2} />
              {programmatic_booklist.title}
            </Table.Cell>
            <Table.Cell textAlign="left">{programmatic_booklist.author}</Table.Cell>
            <Table.Cell textAlign="right">
              {login_state === 1 && (
                <Button
                  content="Order"
                  icon="print"
                  onClick={() =>
                    act('order_programmatic_book', {
                      bookid: programmatic_booklist.id,
                    })
                  }
                />
              )}
              <Button
                content="More..."
                onClick={() =>
                  modalOpen('expand_info', {
                    bookid: programmatic_booklist.id,
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

const UploadBooks = (properties) => {
  const { act, data } = useBackend();
  const { selectedbook, book_categories, user_ckey } = data;

  let categoryMap = [];
  {
    book_categories.map((category) => (categoryMap[category.description] = category.category_id));
  }

  return (
    <Section
      fill
      scrollable
      title="Book System Upload"
      buttons={
        <Button.Confirm
          bold
          width={9.5}
          icon="upload"
          disabled={selectedbook.copyright}
          content="Upload Book"
          onClick={() =>
            act('uploadbook', {
              user_ckey: user_ckey,
            })
          }
        />
      }
    >
      {selectedbook.copyright ? (
        <NoticeBox color="red">WARNING: You cannot upload or modify the attributes of a copyrighted book</NoticeBox>
      ) : (
        <br />
      )}
      <Box ml={15} mb={3} fontSize="1.2rem" bold>
        <Icon name="search-plus" verticalAlign="middle" size={3} mr={2} />
        Book Uploader
      </Box>
      <Stack>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Title">
              <Button
                width={20}
                textAlign="left"
                icon="pen"
                disabled={selectedbook.copyright}
                content={selectedbook.title}
                onClick={() => modalOpen('edit_selected_title')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Author">
              <Button
                width={20}
                textAlign="left"
                icon="pen"
                disabled={selectedbook.copyright}
                content={selectedbook.author}
                onClick={() => modalOpen('edit_selected_author')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Select Categories">
              <Box>
                <Dropdown
                  width="240px"
                  options={book_categories.map((c) => c.description)}
                  onSelected={(val) =>
                    act('toggle_upload_category', {
                      category_id: categoryMap[val],
                    })
                  }
                />
              </Box>
            </LabeledList.Item>
          </LabeledList>
          <br />
          {book_categories
            .filter((category) => selectedbook.categories.includes(category.category_id))
            .map((book_categories) => (
              <Button
                key={book_categories.category_id}
                content={book_categories.description}
                disabled={selectedbook.copyright}
                selected
                icon="unlink"
                onClick={() =>
                  act('toggle_upload_category', {
                    category_id: book_categories.category_id,
                  })
                }
              />
            ))}
        </Stack.Item>
        <Stack.Item mr={75}>
          <LabeledList>
            <LabeledList.Item label="Summary">
              <Button
                icon="pen"
                width="auto"
                disabled={selectedbook.copyright}
                content="Edit Summary"
                onClick={() => modalOpen('edit_selected_summary')}
              />
            </LabeledList.Item>
            <LabeledList.Item>{selectedbook.summary}</LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PatronManager = (properties) => {
  const { act, data } = useBackend();

  const { checkout_data } = data;

  return (
    <Section fill scrollable title="Checked Out Books">
      <Table className="Library__Booklist">
        <Table.Row bold>
          <Table.Cell>Patron</Table.Cell>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Time Left</Table.Cell>
          <Table.Cell>Actions</Table.Cell>
        </Table.Row>
        {checkout_data.map((checkout_data, index) => (
          <Table.Row key={index}>
            <Table.Cell>
              <Icon name="user-tag" />
              {checkout_data.patron_name}
            </Table.Cell>
            <Table.Cell textAlign="left">{checkout_data.title}</Table.Cell>
            <Table.Cell>{checkout_data.timeleft >= 0 ? checkout_data.timeleft : 'LATE'}</Table.Cell>
            <Table.Cell textAlign="left">
              <Button
                content="Mark Lost"
                icon="flag"
                color="bad"
                disabled={checkout_data.timeleft >= 0}
                onClick={() =>
                  act('reportlost', {
                    libraryid: checkout_data.libraryid,
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

const Inventory = (properties) => {
  const { act, data } = useBackend();

  const { inventory_list } = data;

  return (
    <Section fill scrollable title="Library Inventory">
      <Table className="Library__Booklist">
        <Table.Row bold>
          <Table.Cell>LIB ID</Table.Cell>
          <Table.Cell>Title</Table.Cell>
          <Table.Cell>Author</Table.Cell>
          <Table.Cell>Status</Table.Cell>
        </Table.Row>
        {inventory_list.map((inventory_list, index) => (
          <Table.Row key={index}>
            <Table.Cell>{inventory_list.libraryid}</Table.Cell>
            <Table.Cell textAlign="left">
              <Icon name="book" /> {inventory_list.title}
            </Table.Cell>
            <Table.Cell textAlign="left">{inventory_list.author}</Table.Cell>
            <Table.Cell textAlign="left">{inventory_list.checked_out ? 'Checked Out' : 'Available'}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

modalRegisterBodyOverride('expand_info', expandModalBodyOverride);
modalRegisterBodyOverride('report_book', reportModalBodyOverride);
modalRegisterBodyOverride('rate_info', rateModalBodyOverride);
