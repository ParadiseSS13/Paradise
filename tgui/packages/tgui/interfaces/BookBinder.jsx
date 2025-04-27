import { Box, Button, Dropdown, Icon, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';

export const BookBinder = (props) => {
  const { act, data } = useBackend();
  const { selectedbook, book_categories } = data;

  let categoryMap = [];
  {
    book_categories.map((category) => (categoryMap[category.description] = category.category_id));
  }

  return (
    <Window width={600} height={400}>
      <ComplexModal />
      <Window.Content scrollable>
        <Stack fill vertical>
          <Section
            fill
            title="Book Binder"
            buttons={<Button icon="print" width="auto" content="Print Book" onClick={() => act('print_book')} />}
          >
            <Box ml={10} fontSize="1.2rem" bold>
              <Icon name="search-plus" verticalAlign="middle" size={3} mr="1rem" />
              Book Binder
            </Box>
            <Stack>
              <Stack.Item>
                <LabeledList>
                  <LabeledList.Item label="Title">
                    <Button
                      textAlign="left"
                      icon="pen"
                      width="auto"
                      content={selectedbook.title}
                      onClick={() => modalOpen('edit_selected_title')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Author">
                    <Button
                      textAlign="left"
                      icon="pen"
                      width="auto"
                      content={selectedbook.author}
                      onClick={() => modalOpen('edit_selected_author')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Select Categories">
                    <Box>
                      <Dropdown
                        width="190px"
                        options={book_categories.map((c) => c.description)}
                        onSelected={(val) =>
                          act('toggle_binder_category', {
                            category_id: categoryMap[val],
                          })
                        }
                      />
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item label="Summary">
                    <Button
                      icon="pen"
                      width="auto"
                      content="Edit Summary"
                      onClick={() => modalOpen('edit_selected_summary')}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item>{selectedbook.summary}</LabeledList.Item>
                </LabeledList>
                <br />
                {book_categories
                  .filter((category) => selectedbook.categories.includes(category.category_id))
                  .map((book_categories) => (
                    <Button
                      key={book_categories.category_id}
                      content={book_categories.description}
                      selected
                      icon="unlink"
                      onClick={() =>
                        act('toggle_binder_category', {
                          category_id: book_categories.category_id,
                        })
                      }
                    />
                  ))}
              </Stack.Item>
            </Stack>
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
