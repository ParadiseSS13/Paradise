import { useBackend, useLocalState } from '../backend';
import { Button, Section, Stack, Input, Slider, ProgressBar } from '../components';
import { Window } from '../layouts';
import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { createSearch } from 'common/string';

String.prototype.trimLongStr = function (length) {
  return this.length > length ? this.substring(0, length) + '...' : this;
};

const selectForms = (forms, searchText = '') => {
  const testSearch = createSearch(searchText, (form) => form.altername);
  return flow([filter((form) => form?.altername), searchText && filter(testSearch), sortBy((form) => form.id)])(forms);
};

export const Photocopier220 = (props, context) => {
  const { act, data } = useBackend(context);

  const { copies, maxcopies } = data;

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const forms = selectForms(sortBy((form) => form.category)(data.forms || []), searchText);
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
    <Window width={550} height={575} theme={data.ui_theme}>
      <Window.Content>
        <Stack fill>
          <Stack.Item basis="40%">
            <Stack fill vertical>
              <Section title="Статус">
                <Stack>
                  <Stack.Item width="50%" mt={0.3} color="grey">
                    Заряд тонера:
                  </Stack.Item>
                  <Stack.Item width="50%">
                    <ProgressBar minValue={0} maxValue={30} value={data.toner} />
                  </Stack.Item>
                </Stack>
                <Stack mt={1}>
                  <Stack.Item width="50%" mb={0.3} color="grey">
                    Форма:
                  </Stack.Item>
                  <Stack.Item width="50%" textAlign="center" bold>
                    {data.form_id === '' ? 'Не выбрана' : data.form_id}
                  </Stack.Item>
                </Stack>
                <Stack>
                  <Stack.Item width="100%" mt={1}>
                    <Button
                      fluid
                      textAlign="center"
                      disabled={!data.copyitem && !data.mob}
                      icon={data.copyitem || data.mob ? 'eject' : 'times'}
                      content={
                        data.copyitem ? data.copyitem : data.mob ? 'Жопа ' + data.mob + '!' : 'Слот для документа'
                      }
                      onClick={() => act('removedocument')}
                    />
                  </Stack.Item>
                </Stack>
                <Stack>
                  <Stack.Item width="100%" mt="3px">
                    <Button
                      fluid
                      textAlign="center"
                      disabled={!data.folder}
                      icon={data.folder ? 'eject' : 'times'}
                      content={data.folder ? data.folder : 'Слот для папки'}
                      onClick={() => act('removefolder')}
                    />
                  </Stack.Item>
                </Stack>
              </Section>
              <Section title="Управление">
                <Stack>
                  <Stack.Item grow width="100%">
                    <Button
                      fluid
                      textAlign="center"
                      icon="print"
                      disabled={data.toner === 0 || data.form === null}
                      content="Печать"
                      onClick={() => act('print_form')}
                    />
                  </Stack.Item>
                  {!!data.isAI && (
                    <Stack.Item grow width="100%" ml="5px">
                      <Button
                        fluid
                        textAlign="center"
                        icon="image"
                        disabled={data.toner < 5}
                        content="Фото"
                        tooltip="Распечатать фото с Базы Данных"
                        onClick={() => act('ai_pic')}
                      />
                    </Stack.Item>
                  )}
                </Stack>
                <Stack>
                  <Stack.Item grow width="100%" mt="3px">
                    <Button
                      fluid
                      textAlign="center"
                      icon="copy"
                      content="Копия"
                      disabled={data.toner === 0 || (!data.copyitem && !data.mob)}
                      onClick={() => act('copy')}
                    />
                  </Stack.Item>
                  {!!data.isAI && (
                    <Stack.Item grow width="100%" ml="5px" mt="3px">
                      <Button
                        fluid
                        textAlign="center"
                        icon="i-cursor"
                        content="Текст"
                        tooltip="Распечатать свой текст"
                        disabled={data.toner === 0}
                        onClick={() => act('ai_text')}
                      />
                    </Stack.Item>
                  )}
                </Stack>
                <Stack>
                  <Stack.Item mr={1.5} mt={1.2} width="50%" color="grey">
                    Количество:
                  </Stack.Item>
                  <Slider
                    mt={0.75}
                    width="50%"
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
                </Stack>
              </Section>
              <Stack.Item grow mt={0}>
                <Section fill scrollable title="Бюрократия">
                  <Stack fill vertical>
                    <Stack.Item>
                      <Button
                        fluid
                        mb={-0.5}
                        icon="chevron-right"
                        color="transparent"
                        content="Все формы"
                        selected={!data.category}
                        onClick={() =>
                          act('choose_category', {
                            category: '',
                          })
                        }
                      />
                    </Stack.Item>
                    {categories.map((category) => (
                      <Stack.Item key={category}>
                        <Button
                          fluid
                          key={category}
                          icon="chevron-right"
                          mb={-0.5}
                          color="transparent"
                          content={category}
                          selected={data.category === category}
                          onClick={() =>
                            act('choose_category', {
                              category: category,
                            })
                          }
                        />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item basis="60%">
            <Section
              fill
              scrollable
              title={data.category || 'Все формы'}
              buttons={
                <Input mr={18.5} width="100%" placeholder="Поиск формы" onInput={(e, value) => setSearchText(value)} />
              }
            >
              {category.map((form) => (
                <Stack.Item key={form.path}>
                  <Button
                    fluid
                    mb={0.5}
                    color="transparent"
                    content={form.altername.trimLongStr(37)}
                    tooltip={form.altername}
                    selected={data.form_id === form.id}
                    onClick={() =>
                      act('choose_form', {
                        path: form.path,
                        id: form.id,
                      })
                    }
                  />
                </Stack.Item>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
