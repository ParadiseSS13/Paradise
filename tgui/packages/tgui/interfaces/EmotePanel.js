import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Button, Section, Input, Flex, Icon, Box } from '../components';

export const EmotePanel = (props, context) => {
  return (
    <Window resizable>
      <Window.Content scrollable>
        <EmotePanelContent />
      </Window.Content>
    </Window>
  );
};

export const EmotePanelContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { emotes } = data;

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const [filterVisible, toggleVisualFilter] = useLocalState(
    context,
    'filterVisible',
    ''
  );

  const [filterAudible, toggleAudibleFilter] = useLocalState(
    context,
    'filterAudible',
    ''
  );

  const [filterSound, toggleSoundFilter] = useLocalState(
    context,
    'filterSound',
    ''
  );

  const [filterHands, toggleHandsFilter] = useLocalState(
    context,
    'filterHands',
    ''
  );

  const [filterTargettable, toggleTargettableFilter] = useLocalState(
    context,
    'filterTargettable',
    ''
  );

  const [useTarget, toggleUseTarget] = useLocalState(context, 'useTarget', '');

  let searchBar = (
    <Input
      placeholder="Искать эмоцию..."
      fluid
      onInput={(e, value) => setSearchText(value)}
    />
  );

  return (
    <Section>
      <Section
        title="Фильтры"
        buttons={
          <Flex>
            <Button
              icon="eye"
              width="100%"
              height="100%"
              align="center"
              tooltip="Видимый"
              selected={filterVisible}
              onClick={() => toggleVisualFilter(!filterVisible)}
            />
            <Button
              icon="comment"
              width="100%"
              height="100%"
              align="center"
              tooltip="Слышимый"
              selected={filterAudible}
              onClick={() => toggleAudibleFilter(!filterAudible)}
            />
            <Button
              icon="volume-up"
              width="100%"
              height="100%"
              align="center"
              tooltip="Звук"
              selected={filterSound}
              onClick={() => toggleSoundFilter(!filterSound)}
            />
            <Button
              icon="hand-paper"
              width="100%"
              height="100%"
              align="center"
              tooltip="Руки"
              selected={filterHands}
              onClick={() => toggleHandsFilter(!filterHands)}
            />
            <Button
              icon="crosshairs"
              width="100%"
              height="100%"
              align="center"
              tooltip="Цель"
              selected={filterTargettable}
              onClick={() => toggleTargettableFilter(!filterTargettable)}
            />
          </Flex>
        }
      >
        {searchBar}
      </Section>
      <Section
        title={
          searchText.length > 0
            ? `Результаты поиска "${searchText}"`
            : `Все эмоции`
        }
        fill
        buttons={
          <Button
            icon="crosshairs"
            selected={useTarget}
            onClick={() => toggleUseTarget(!useTarget)}
          >
            Выбирать цель
          </Button>
        }
      >
        <Flex>
          <Flex.Item>
            {emotes
              .filter(
                (emote) =>
                  emote.key &&
                  (searchText.length > 0
                    ? emote.key
                        .toLowerCase()
                        .includes(searchText.toLowerCase()) ||
                      emote.name
                        .toLowerCase()
                        .includes(searchText.toLowerCase())
                    : true) &&
                  (filterVisible ? emote.visible : true) &&
                  (filterAudible ? emote.audible : true) &&
                  (filterSound ? emote.sound : true) &&
                  (filterHands ? emote.hands : true) &&
                  (filterTargettable ? emote.targettable : true)
              )
              .map((emote) => (
                <Button
                  key={emote.name}
                  onClick={() =>
                    act('play_emote', {
                      emote_key: emote.key,
                      useTarget: useTarget,
                    })
                  }
                >
                  {emote.visible ? <Icon name="eye" /> : ''}
                  {emote.audible ? <Icon name="comment" /> : ''}
                  {emote.sound ? <Icon name="volume-up" /> : ''}
                  {emote.hands ? <Icon name="hand-paper" /> : ''}
                  {emote.targettable ? <Icon name="crosshairs" /> : ''}
                  {emote.name.toUpperCase()}
                </Button>
              ))}
          </Flex.Item>
        </Flex>
      </Section>
    </Section>
  );
};
