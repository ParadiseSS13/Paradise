import { useBackend, useLocalState, useSharedState } from '../backend';
import { Button, NoticeBox, LabeledList, Section, Tabs, ImageButton, Stack, Slider } from '../components';
import { Window } from '../layouts';

const GENDERS = [
  { name: 'Male', icon: 'mars' },
  { name: 'Female', icon: 'venus' },
  { name: 'Genderless', icon: 'genderless' },
];

const BLOOD_TYPES = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

export const AgentCard = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <AgentCardInfo />;
      case 1:
        return <AgentCardAppearances />;
      default:
        return <AgentCardInfo />;
    }
  };

  return (
    <Window width={405} height={505} theme="syndicate">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item textAlign="center">
            <Tabs fluid>
              <Tabs.Tab key="Card Info" icon={'table'} selected={0 === tabIndex} onClick={() => setTabIndex(0)}>
                Информация
              </Tabs.Tab>
              <Tabs.Tab key="Appearance" icon={'id-card'} selected={1 === tabIndex} onClick={() => setTabIndex(1)}>
                Внешний вид
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          {decideTab(tabIndex)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const unset = 'Пусто';
const InfoInput = ({ label, value, onCommit, onClick, onRClick, tooltip }) => (
  <LabeledList.Item label={label}>
    <Stack fill mb={-0.5}>
      <Stack.Item grow>
        <Button.Input fluid textAlign="center" content={value || unset} onCommit={onCommit} />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="file-signature"
          tooltip={tooltip}
          tooltipPosition={'bottom-end'}
          onClick={onClick}
          onContextMenu={onRClick}
        />
      </Stack.Item>
    </Stack>
  </LabeledList.Item>
);

export const AgentCardInfo = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    registered_name,
    sex,
    age,
    assignment,
    associated_account_number,
    blood_type,
    dna_hash,
    fingerprint_hash,
    photo,
    ai_tracking,
  } = data;

  const tooltipText = (
    <span>
      Автозаполнение.
      <br />
      ЛКМ - Ввести свой параметр.
      <br />
      ПКМ - Выбрать чужой параметр.
    </span>
  );

  return (
    <>
      <Stack.Item>
        <NoticeBox m={0}>Изменения информации не влияют на доступы.</NoticeBox>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Информация">
          <LabeledList>
            <InfoInput
              label="Имя"
              value={registered_name}
              tooltip={tooltipText}
              onCommit={(e, value) => act('change_name', { name: value })}
              onClick={() => act('change_name', { option: 'Primary' })}
              onRClick={(event) => {
                event.preventDefault();
                act('change_name', { option: 'Secondary' });
              }}
            />
            <LabeledList.Item label="Пол">
              <Stack fill mb={-0.5}>
                {GENDERS.map((gender) => (
                  <Stack.Item grow key={gender.name}>
                    <Button
                      fluid
                      icon={gender.icon}
                      content={gender.name}
                      selected={sex === gender.name}
                      onClick={() => act('change_sex', { sex: gender.name })}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item label="Возраст">
              <Slider
                fluid
                minValue={17}
                value={age || 0}
                maxValue={300}
                onChange={(e, value) => act('change_age', { age: value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Должность">
              <Button fluid textAlign="center" content={assignment || unset} onClick={() => act('change_occupation')} />
            </LabeledList.Item>
            <InfoInput
              label="Отпечатки"
              value={fingerprint_hash}
              tooltip="Ввести свои отпечатки."
              onCommit={(e, value) => act('change_fingerprints', { new_fingerprints: value })}
              onClick={() => act('change_fingerprints', { option: 'Primary' })}
            />
            <LabeledList.Item label="Тип крови">
              <Stack fill mb={-0.5}>
                {BLOOD_TYPES.map((type) => (
                  <Stack.Item grow key={type}>
                    <Button
                      fluid
                      content={type}
                      selected={blood_type === type}
                      onClick={() => act('change_blood_type', { new_type: type })}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </LabeledList.Item>
            <InfoInput
              label="ДНК"
              value={dna_hash}
              onCommit={(e, value) => act('change_dna_hash', { new_dna: value })}
              onClick={() => act('change_dna_hash', { option: 'Primary' })}
              tooltip="Ввести своё ДНК."
            />
            <InfoInput
              label="Аккаунт"
              value={associated_account_number || 0}
              onCommit={(e, value) => act('change_money_account', { new_account: value })}
              onClick={() => act('change_money_account', { option: 'Primary' })}
              tooltip="Ввести случайный набор цифр."
            />
            <LabeledList.Item label="Фото">
              <Button fluid textAlign="center" content={photo ? 'Update' : unset} onClick={() => act('change_photo')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Настройки карты">
          <LabeledList>
            <LabeledList.Item label="Информация">
              <Button.Confirm
                fluid
                textAlign="center"
                content="Удалить всю информацию"
                confirmContent="Вы уверены?"
                onClick={() => act('delete_info')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Доступы">
              <Button.Confirm
                fluid
                textAlign="center"
                content="Сбросить доступы"
                confirmContent="Вы уверены?"
                onClick={() => act('clear_access')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Отслеживание ИИ">
              <Button
                fluid
                textAlign="center"
                content={ai_tracking ? 'Невозможно' : 'Возможно'}
                onClick={() => act('change_ai_tracking')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </>
  );
};

export const AgentCardAppearances = (props, context) => {
  const { act, data } = useBackend(context);
  const [selectedAppearance, setSelectedAppearance] = useSharedState(context, 'selectedAppearance', 'null');
  const { appearances } = data;

  return (
    <Stack.Item grow>
      <Section fill scrollable title="Внешний вид">
        {Object.entries(appearances).map(([name, image]) => (
          <ImageButton
            m={0.5}
            vertical
            key={name}
            image={image}
            imageSize="64px"
            selected={selectedAppearance === name}
            onClick={() => {
              setSelectedAppearance(name);
              act('change_appearance', { new_appearance: name });
            }}
          />
        ))}
      </Section>
    </Stack.Item>
  );
};
