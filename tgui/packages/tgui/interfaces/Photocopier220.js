import { useBackend, useLocalState } from '../backend';
import {
  Button,
  Section,
  Flex,
  Input,
  Slider,
  ProgressBar,
} from '../components';
import { Window } from '../layouts';
import { filter, sortBy } from 'common/collections';
import { FlexItem } from '../components/Flex';
import { flow } from 'common/fp';
import { createSearch } from 'common/string';

String.prototype.trimLongStr = function (length) {
  return this.length > length ? this.substring(0, length) + '...' : this;
};

const selectForms = (forms, searchText = '') => {
  const testSearch = createSearch(searchText, (form) => form.altername);
  return flow([
    filter((form) => form?.altername),
    searchText && filter(testSearch),
    sortBy((form) => form.id),
  ])(forms);
};

export const Photocopier220 = (props, context) => {
  const { act, data } = useBackend(context);

  const { copies, maxcopies } = data;

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const forms = selectForms(
    sortBy((form) => form.category)(data.forms || []),
    searchText
  );
  const categories = [];
  for (let form of forms) {
    if (!categories.includes(form.category)) {
      categories.push(form.category);
    }
  }
  const [number, setNumber] = useLocalState(context, 'number', 0);

  let category;
  if (data.category === '') {
    category = forms;
  } else {
    category = forms.filter((form) => form.category === data.category);
  }

  return (
    <Window theme={data.ui_theme}>
      <Window.Content scrollable display="flex">
        <Flex direction="row" spacing={1}>
          <Flex.Item basis="40%">
            <Section title="Статус">
              <Flex>
                <Flex.Item width="50%" mt={0.8} color="grey">
                  Заряд тонера:
                </Flex.Item>
                <Flex.Item width="50%" mt={0.5}>
                  <ProgressBar minValue={0} maxValue={30} value={data.toner} />
                </Flex.Item>
              </Flex>
              <Flex>
                <Flex.Item width="100%" mt={2}>
                  <Button
                    fluid
                    textAlign="center"
                    disabled={!data.copyitem && !data.mob}
                    icon={data.copyitem || data.mob ? 'eject' : 'times'}
                    content={
                      data.copyitem
                        ? data.copyitem
                        : data.mob
                        ? 'Жопа ' + data.mob + '!'
                        : 'Слот для документа'
                    }
                    onClick={() => act('removedocument')}
                  />
                </Flex.Item>
              </Flex>
              <Flex>
                <Flex.Item width="100%" mt="3px">
                  <Button
                    fluid
                    textAlign="center"
                    disabled={!data.folder}
                    icon={data.folder ? 'eject' : 'times'}
                    content={data.folder ? data.folder : 'Слот для папки'}
                    onClick={() => act('removefolder')}
                  />
                </Flex.Item>
              </Flex>
            </Section>
            <Section title="Управление">
              <Flex>
                <Flex.Item grow={1} width="100%">
                  <Button
                    fluid
                    textAlign="center"
                    icon="print"
                    disabled={data.toner === 0 || data.form === null}
                    content="Печать"
                    onClick={() => act('print_form')}
                  />
                </Flex.Item>
                {!!data.isAI && (
                  <Flex.Item grow={1} width="100%" ml="5px">
                    <Button
                      fluid
                      textAlign="center"
                      icon="image"
                      disabled={data.toner < 5}
                      content="Фото"
                      tooltip="Распечатать фото с Базы Данных"
                      tooltipPosition="right"
                      onClick={() => act('ai_pic')}
                    />
                  </Flex.Item>
                )}
              </Flex>
              <Flex>
                <Flex.Item grow={1} width="100%" mt="3px">
                  <Button
                    fluid
                    textAlign="center"
                    icon="copy"
                    content="Копия"
                    disabled={data.toner === 0 || (!data.copyitem && !data.mob)}
                    onClick={() => act('copy')}
                  />
                </Flex.Item>
                {!!data.isAI && (
                  <Flex.Item grow={1} width="100%" ml="5px" mt="3px">
                    <Button
                      fluid
                      textAlign="center"
                      icon="i-cursor"
                      content="Текст"
                      tooltip="Распечатать свой текст"
                      tooltipPosition="right"
                      disabled={data.toner === 0}
                      onClick={() => act('ai_text')}
                    />
                  </Flex.Item>
                )}
              </Flex>
              <Flex>
                <Flex.Item mr={4.5} mt={1.2} color="grey">
                  Количество:
                </Flex.Item>
                <Slider
                  mt={0.75}
                  animated
                  minValue={1}
                  maxValue={maxcopies}
                  value={copies}
                  stepPixelSize={10}
                  onChange={(e, value) =>
                    act('copies', {
                      new: value,
                    })
                  }
                />
              </Flex>
            </Section>
            <Flex.Item className="Layout__content--flexColumn" height="330px">
              <Section title="Бюрократия" flexGrow="1">
                <Flex>
                  <Flex.Item mr={2} mt={0.1} color="grey">
                    Форма:
                  </Flex.Item>
                  <FlexItem bold>
                    {data.form_id === '' ? 'Не выбрана' : data.form_id}
                  </FlexItem>
                </Flex>
                <Flex direction="column" mt={2.1}>
                  <Flex.Item>
                    <Button
                      mb={1}
                      mt={0.5}
                      fluid
                      icon="chevron-right"
                      content="Все формы"
                      selected={!data.category}
                      onClick={() =>
                        act('choose_category', {
                          category: null,
                        })
                      }
                    />
                  </Flex.Item>
                  {categories.map((category) => (
                    <Flex.Item key={category}>
                      <Button
                        mb={1}
                        fluid
                        key={category}
                        icon="chevron-right"
                        content={category}
                        selected={data.category === category}
                        onClick={() =>
                          act('choose_category', {
                            category: category,
                          })
                        }
                      />
                    </Flex.Item>
                  ))}
                </Flex>
              </Section>
            </Flex.Item>
          </Flex.Item>
          <Flex.Item basis="60%" className="Layout__content--flexColumn">
            <Section title={data.category || 'Все формы'} flexGrow="1">
              <Input
                fluid
                placeholder="Поиск формы"
                onInput={(e, value) => setSearchText(value)}
              />
              <Flex direction="column" mt={1.6} wrap="wrap">
                {category.map((form) => (
                  <Flex.Item key={form.path}>
                    <Button
                      mb={1}
                      fluid
                      key={form.path}
                      content={form.altername.trimLongStr(37)}
                      selected={data.form_id === form.id}
                      onClick={() =>
                        act('choose_form', {
                          path: form.path,
                          id: form.id,
                        })
                      }
                    />
                  </Flex.Item>
                ))}
              </Flex>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
