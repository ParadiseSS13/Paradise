/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';
import { useState } from 'react';
import { useDispatch, useSelector } from 'tgui/backend';
import {
  Box,
  Button,
  Collapsible,
  ColorBox,
  Input,
  LabeledList,
  Section,
  Slider,
  Stack,
  Tabs,
  TextArea,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { capitalize } from 'tgui-core/string';

import { ChatPageSettings } from '../chat';
import { clearChat, rebuildChat, saveChatToDisk } from '../chat/actions';
import { THEMES } from '../themes';
import {
  addHighlightSetting,
  changeSettingsTab,
  removeHighlightSetting,
  updateHighlightSetting,
  updateSettings,
} from './actions';
import { FONTS, MAX_HIGHLIGHT_SETTINGS, SETTINGS_TABS } from './constants';
import { selectActiveTab, selectHighlightSettingById, selectHighlightSettings, selectSettings } from './selectors';
import { SettingsStatPanel } from './SettingsStatPanel';

export const SettingsPanel = (props) => {
  const activeTab = useSelector(selectActiveTab);
  const dispatch = useDispatch();
  return (
    <Stack fill>
      <Stack.Item>
        <Section fitted fill minHeight="8em">
          <Tabs vertical>
            {SETTINGS_TABS.map((tab) => (
              <Tabs.Tab
                key={tab.id}
                selected={tab.id === activeTab}
                onClick={() =>
                  dispatch(
                    changeSettingsTab({
                      tabId: tab.id,
                    })
                  )
                }
              >
                {tab.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow basis={0}>
        {activeTab === 'general' && <SettingsGeneral />}
        {activeTab === 'chatPage' && <ChatPageSettings />}
        {activeTab === 'textHighlight' && <TextHighlightSettings />}
        {activeTab === 'statPanel' && <SettingsStatPanel />}
      </Stack.Item>
    </Stack>
  );
};

export const SettingsGeneral = (props) => {
  const { theme, fontFamily, fontSize, lineHeight, chatSaving } = useSelector(selectSettings);
  const dispatch = useDispatch();
  const [freeFont, setFreeFont] = useState(false);

  const updateChatSaving = (value) => {
    const boolValue = value === true;
    dispatch(
      updateSettings({
        chatSaving: boolValue,
      })
    );
    storage.set('chat-saving-enabled', boolValue);
  };

  return (
    <Section fill>
      <Stack fill vertical>
        <LabeledList>
          <LabeledList.Item label="Theme">
            {THEMES.map((THEME) => (
              <Button
                key={THEME}
                selected={theme === THEME}
                color="transparent"
                onClick={() =>
                  dispatch(
                    updateSettings({
                      theme: THEME,
                    })
                  )
                }
              >
                {capitalize(THEME)}
              </Button>
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Font style">
            <Stack.Item>
              {!freeFont ? (
                <Collapsible
                  title={fontFamily}
                  width={'100%'}
                  buttons={
                    <Button
                      content="Custom font"
                      icon={freeFont ? 'lock-open' : 'lock'}
                      color={freeFont ? 'good' : 'bad'}
                      onClick={() => {
                        setFreeFont(!freeFont);
                      }}
                    />
                  }
                >
                  {FONTS.map((FONT) => (
                    <Button
                      key={FONT}
                      content={FONT}
                      fontFamily={FONT}
                      selected={fontFamily === FONT}
                      color="transparent"
                      onClick={() =>
                        dispatch(
                          updateSettings({
                            fontFamily: FONT,
                          })
                        )
                      }
                    />
                  ))}
                </Collapsible>
              ) : (
                <Stack>
                  <Input
                    width={'100%'}
                    value={fontFamily}
                    onChange={(value) =>
                      dispatch(
                        updateSettings({
                          fontFamily: value,
                        })
                      )
                    }
                  />
                  <Button
                    ml={0.5}
                    content="Custom font"
                    icon={freeFont ? 'lock-open' : 'lock'}
                    color={freeFont ? 'good' : 'bad'}
                    onClick={() => {
                      setFreeFont(!freeFont);
                    }}
                  />
                </Stack>
              )}
            </Stack.Item>
          </LabeledList.Item>
          <LabeledList.Item label="Font size">
            <Slider
              step={1}
              stepPixelSize={17.5}
              minValue={8}
              value={fontSize}
              maxValue={32}
              unit="px"
              format={(value) => toFixed(value)}
              onChange={(e, value) =>
                dispatch(
                  updateSettings({
                    fontSize: value,
                  })
                )
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Line height">
            <Slider
              step={0.01}
              minValue={0.8}
              value={lineHeight}
              maxValue={5}
              format={(value) => toFixed(value, 2)}
              tickWhileDragging
              onChange={(e, value) =>
                dispatch(
                  updateSettings({
                    lineHeight: value,
                  })
                )
              }
            />
          </LabeledList.Item>
        </LabeledList>
        <Stack.Divider />
        <Stack>
          <Stack.Item>
            <Button.Checkbox
              checked={chatSaving === true}
              tooltip="Enable chat persistence"
              onClick={() => updateChatSaving(!chatSaving)}
            >
              Persistent Chat
            </Button.Checkbox>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              icon="save"
              tooltip="Export current tab history into HTML file"
              onClick={() => dispatch(saveChatToDisk())}
            >
              Save chat log
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button.Confirm
              icon="trash"
              confirmContent="Are you sure?"
              tooltip="Erase current tab history"
              onClick={() => dispatch(clearChat())}
            >
              Clear chat
            </Button.Confirm>
          </Stack.Item>
        </Stack>
      </Stack>
    </Section>
  );
};

const TextHighlightSettings = (props) => {
  const highlightSettings = useSelector(selectHighlightSettings);
  const dispatch = useDispatch();
  return (
    <Section fill scrollable height="230px">
      <Section>
        <Stack vertical>
          {highlightSettings.map((id, i) => (
            <TextHighlightSetting key={i} id={id} mb={i + 1 === highlightSettings.length ? 0 : '10px'} />
          ))}
          {highlightSettings.length < MAX_HIGHLIGHT_SETTINGS && (
            <Stack.Item>
              <Button
                color="transparent"
                icon="plus"
                onClick={() => {
                  dispatch(addHighlightSetting());
                }}
              >
                Add Highlight Setting
              </Button>
            </Stack.Item>
          )}
        </Stack>
      </Section>
      <Stack.Divider />
      <Box>
        <Button icon="check" onClick={() => dispatch(rebuildChat())}>
          Apply now
        </Button>
        <Box inline fontSize="0.9em" ml={1} color="label">
          Can freeze the chat for a while.
        </Box>
      </Box>
    </Section>
  );
};

const TextHighlightSetting = (props) => {
  const { id, ...rest } = props;
  const highlightSettingById = useSelector(selectHighlightSettingById);
  const dispatch = useDispatch();
  const { highlightColor, highlightText, highlightWholeMessage, matchWord, matchCase } = highlightSettingById[id];
  return (
    <Stack.Item {...rest}>
      <Stack mb={1} color="label" align="baseline">
        <Stack.Item grow>
          <Button
            color="transparent"
            icon="times"
            onClick={() =>
              dispatch(
                removeHighlightSetting({
                  id: id,
                })
              )
            }
          >
            Delete
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            checked={highlightWholeMessage}
            tooltip="If this option is selected, the entire message will be highlighted in yellow."
            onClick={() =>
              dispatch(
                updateHighlightSetting({
                  id: id,
                  highlightWholeMessage: !highlightWholeMessage,
                })
              )
            }
          >
            Whole Message
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            checked={matchWord}
            tooltipPosition="bottom-start"
            tooltip="If this option is selected, only exact matches (no extra letters before or after) will trigger. Not compatible with punctuation. Overriden if regex is used."
            onClick={() =>
              dispatch(
                updateHighlightSetting({
                  id: id,
                  matchWord: !matchWord,
                })
              )
            }
          >
            Exact
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            tooltip="If this option is selected, the highlight will be case-sensitive."
            checked={matchCase}
            onClick={() =>
              dispatch(
                updateHighlightSetting({
                  id: id,
                  matchCase: !matchCase,
                })
              )
            }
          >
            Case
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item shrink={0}>
          <ColorBox mr={1} color={highlightColor} />
          <Input
            width="5em"
            monospace
            placeholder="#ffffff"
            value={highlightColor}
            onChange={(value) =>
              dispatch(
                updateHighlightSetting({
                  id: id,
                  highlightColor: value,
                })
              )
            }
          />
        </Stack.Item>
      </Stack>
      <TextArea
        fluid
        height="3em"
        value={highlightText}
        placeholder="Put terms to highlight here. Separate terms with commas or vertical bars, i.e. (term1 | term2) or (term1, term2). Regex syntax is /[regex]/"
        onChange={(value) =>
          dispatch(
            updateHighlightSetting({
              id: id,
              highlightText: value,
            })
          )
        }
      />
    </Stack.Item>
  );
};
