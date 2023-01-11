import { useState } from 'react';
import styled from 'styled-components';
import { saveSettings } from '~/common/settings';
import { useSettingsSlice } from '~/common/store';
import { Highlight } from '~/common/types';
import { isValidColor, processHighlights } from '~/common/util';
import { MessageWrapper, addHighlight } from '~/components/messages/Message';
import { useEditSettings } from '~/hooks/useEditSettings';
import { Button } from '../form/Button';
import ButtonGroup from '../form/ButtonGroup';
import Checkbox from '../form/Checkbox';
import Input from '../form/Input';
import Label from '../form/Label';
import { Separator } from '../form/Separator';
import { Setting } from '../form/Setting';

const HighlightSettingsWrapper = styled.div`
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden;

  > div {
    flex-direction: column;
    height: '100%';
  }
`;

const HighlightAddWrapper = styled.div``;

const HighlightAddForm = styled.div`
  flex: 2;
`;

const HighlightAddPreview = styled.div`
  flex: 1;
  display: flex;
  flex-direction: column;
`;

const HighlightAddPreviewBox = styled.div`
  border-radius: 4px;
  background-color: ${props => props.theme.colors.bg[1]};
  padding-top: 8px;
  flex: 1;
  margin-bottom: 8px;
`;

const HighlightTableWrapper = styled.div`
  border: 1px solid ${props => props.theme.colors.bg[1]};
  border-radius: 4px;
  flex: 1;
  overflow: auto;
`;

const HighlightTable = styled.table`
  width: 100%;
  border-spacing: 0;

  tr:first-child {
    background-color: ${props => props.theme.colors.bg[1]};
  }

  td {
    padding: 8px 8px;
  }

  a {
    text-decoration: none;
    margin-right: 1em;
  }
`;

const HighlightTerm = styled.span`
  font-family: monospace;
`;

const ColorBox = styled.div`
  content: '';
  background: ${props => props.color};
  border: 1px solid ${props => props.theme.colors.bg[1]};
  border-radius: 4px;
  align-self: stretch;
  margin-left: 8px;
  width: 2em;
  display: inline-block;
`;

const highlightTypeMap = {
  Line: Highlight.LINE,
  Simple: Highlight.SIMPLE,
};

// eslint-disable-next-line react/prop-types
const HighlightAdd = ({ onClose, editing }) => {
  const settings = useSettingsSlice(state => state);
  const { currentSettings, unsavedSettings, write } = useEditSettings(true, {
    term: '',
    isRegex: false,
    color: '#FFFF00',
    previewText: 'Test message',
    type: Highlight.LINE,
    ...editing,
  });
  const data = { ...currentSettings, ...unsavedSettings };
  const highlightPreview = processHighlights(data.previewText, data);

  const save = () => {
    if (!data.term || !isValidColor(data.color)) {
      return;
    }
    if (editing) {
      settings.updateSettings({
        ...settings,
        highlights: [
          ...settings.highlights.map(h =>
            h !== editing
              ? h
              : {
                  term: data.term,
                  isRegex: data.isRegex,
                  color: data.color,
                  type: data.type,
                }
          ),
        ],
      });
    } else {
      settings.updateSettings({
        ...settings,
        highlights: [
          ...settings.highlights,
          {
            term: data.term,
            isRegex: data.isRegex,
            color: data.color,
            type: data.type,
          },
        ],
      });
    }
    saveSettings();
    onClose();
  };

  return (
    <>
      <HighlightAddWrapper>
        <HighlightAddForm>
          <Setting>
            <Label>Term:</Label>
            <Input
              type="text"
              style={{ fontFamily: 'monospace' }}
              onChange={e => write('term', e.target.value)}
              defaultValue={data.term}
              stretch
            />
          </Setting>
          <Setting>
            <Label>Regex:</Label>
            <Checkbox />
          </Setting>
          <Setting>
            <Label>Type:</Label>
            <ButtonGroup
              options={Object.keys(highlightTypeMap)}
              defaultValue={Object.keys(highlightTypeMap).find(
                key => highlightTypeMap[key] === data.type
              )}
              onOptionSelect={o => write('type', highlightTypeMap[o])}
            />
          </Setting>
          <Setting>
            <Label>Color:</Label>
            <Input
              type="text"
              defaultValue={data.color}
              onChange={e => write('color', e.target.value)}
            />
            <ColorBox color={data.color} />
          </Setting>
          <Setting style={{ marginBottom: 0 }}>
            <Label></Label>
            <Button
              disabled={!data.term || !isValidColor(data.color)}
              style={{ marginRight: '0.5em' }}
              small
              onClick={() => save()}
            >
              {editing ? 'Save' : 'Add'}
            </Button>
            <Button onClick={onClose} neutral small>
              Cancel
            </Button>
          </Setting>
        </HighlightAddForm>
      </HighlightAddWrapper>
      <Separator />
      <HighlightAddPreview>
        <HighlightAddPreviewBox>
          <MessageWrapper>Regular message...</MessageWrapper>
          <MessageWrapper {...addHighlight(highlightPreview.highlight)}>
            <span
              dangerouslySetInnerHTML={{
                __html: highlightPreview.text,
              }}
            />
          </MessageWrapper>
          <MessageWrapper>Regular message...</MessageWrapper>
        </HighlightAddPreviewBox>
        <Setting>
          <Label>Test:</Label>
          <Input
            type="text"
            defaultValue={data.previewText}
            onChange={e => write('previewText', e.target.value)}
            stretch
          />
        </Setting>
      </HighlightAddPreview>
    </>
  );
};

// eslint-disable-next-line react/prop-types
const HighlightList = ({ onAddNewClick, onEditClick }) => {
  const settings = useSettingsSlice(state => state);
  const highlights = settings.highlights;

  const onMove = (index, up) => {
    const newIndex = index + (up ? -1 : 1);
    settings.updateSettings({
      ...settings,
      highlights: settings.highlights.map((h, i) => {
        if (i === index) {
          return highlights[newIndex];
        } else if (i === newIndex) {
          return highlights[index];
        } else {
          return h;
        }
      }),
    });
    saveSettings();
  };

  const onDelete = highlight => {
    settings.updateSettings({
      ...settings,
      highlights: settings.highlights.filter(h => h !== highlight),
    });
    saveSettings();
  };

  return (
    <>
      <HighlightTableWrapper>
        <HighlightTable>
          <tr>
            <td>Term</td>
            <td>Highlight</td>
            <td>Action</td>
          </tr>
          {highlights.map((h, i) => (
            <tr key={i}>
              <td>
                <HighlightTerm>{h.term}</HighlightTerm>
              </td>
              <td style={{ display: 'flex' }}>
                <ColorBox
                  color={h.color}
                  style={{
                    width: '1em',
                    marginLeft: '0',
                    marginRight: '0.5em',
                  }}
                />
                {h.type === Highlight.LINE ? 'Line' : 'Simple'}
              </td>
              <td>
                {i > 0 && (
                  <a href="#" onClick={() => onMove(i, true)}>
                    ▲
                  </a>
                )}
                {i < highlights.length - 1 && (
                  <a href="#" onClick={() => onMove(i, false)}>
                    ▼
                  </a>
                )}
                <a href="#" onClick={() => onEditClick(h)}>
                  Edit
                </a>
                <a href="#" onClick={() => onDelete(h)}>
                  Delete
                </a>
              </td>
            </tr>
          ))}
        </HighlightTable>
      </HighlightTableWrapper>
      <Button
        style={{ display: 'block', textAlign: 'center', marginTop: '1em' }}
        onClick={onAddNewClick}
      >
        Add New
      </Button>
    </>
  );
};

const HighlightSettings = () => {
  const [showEditor, setShowEditor] = useState(false);
  const [editing, setEditing] = useState();

  return (
    <HighlightSettingsWrapper>
      {showEditor ? (
        <HighlightAdd
          editing={editing}
          onClose={() => {
            setShowEditor(false);
            setEditing(null);
          }}
        />
      ) : (
        <HighlightList
          onAddNewClick={() => setShowEditor(true)}
          onEditClick={h => {
            setShowEditor(true);
            setEditing(h);
          }}
        />
      )}
    </HighlightSettingsWrapper>
  );
};

export default HighlightSettings;
