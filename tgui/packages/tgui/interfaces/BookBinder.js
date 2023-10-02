import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Icon,
  LabeledList,
  Section,
} from '../components';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';
import { FlexItem } from '../components/Flex';

export const BookBinder = (props, context) => {
  const { act, data } = useBackend(context);
  const { selectedbook, book_categories } = data;

  let categoryMap = [];
  {
    book_categories.map(
      (category) => (categoryMap[category.description] = category.category_id)
    );
  }

  return (
    <Window resizable>
      <ComplexModal />
      <Window.Content scrollable className="Layout__content--flexColumn">
        <Section title="Book Binder">
          <Box fontSize="1.2rem" bold>
            <Icon
              name="search-plus"
              verticalAlign="middle"
              size={3}
              mr="1rem"
            />
            Book Binder
          </Box>
          <Flex>
            <FlexItem>
              <LabeledList>
                <LabeledList.Item label="Title">
                  <Button
                    textAlign="left"
                    icon="pen"
                    width="auto"
                    content={selectedbook.title}
                    onClick={() => modalOpen(context, 'edit_selected_title')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Author">
                  <Button
                    textAlign="left"
                    icon="pen"
                    width="auto"
                    content={selectedbook.author}
                    onClick={() => modalOpen(context, 'edit_selected_author')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Select Categories">
                  <Box mt={2}>
                    <Dropdown
                      mt={0.6}
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
              </LabeledList>
              <br />
              {book_categories
                .filter((category) =>
                  selectedbook.categories.includes(category.category_id)
                )
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
            </FlexItem>
            <FlexItem>
              <LabeledList>
                <LabeledList.Item label="Summary">
                  <Button
                    icon="pen"
                    width="auto"
                    content="Edit Summary"
                    onClick={() => modalOpen(context, 'edit_selected_summary')}
                  />
                </LabeledList.Item>
                <LabeledList.Item>{selectedbook.summary}</LabeledList.Item>
              </LabeledList>
            </FlexItem>
          </Flex>
          <br />
          <Button
            icon="print"
            width="auto"
            content="Print Book"
            onClick={() => act('print_book')}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
