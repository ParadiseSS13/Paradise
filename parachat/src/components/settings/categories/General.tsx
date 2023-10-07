import styled from 'styled-components';
import { Button } from '~/components/settings/form/Button';
import ButtonGroup from '~/components/settings/form/ButtonGroup';
import Checkbox from '~/components/settings/form/Checkbox';
import { useEditSettings } from '~/hooks/useEditSettings';
import Input from '../form/Input';
import Label from '../form/Label';
import { Separator } from '../form/Separator';
import { Setting } from '../form/Setting';

const GeneralSettingsWrapper = styled.div``;

const Hint = styled.span`
  margin-bottom: 8px;
  margin-left: 98px;
  color: ${({ theme }) => theme.textDisabled};
  display: inline-block;
`;

const GeneralSettings = () => {
  const { currentSettings, hasUnsavedSettings, write, save } =
    useEditSettings();

  return (
    <GeneralSettingsWrapper>
      <Setting>
        <Label>Theme:</Label>
        <ButtonGroup
          options={['dark', 'light']}
          defaultValue={currentSettings.theme}
          onOptionSelect={o => write('theme', o)}
        />
      </Setting>
      <Setting>
        <Label>Font name:</Label>
        <Input
          type="text"
          defaultValue={currentSettings.font}
          onChange={e => write('font', e.target.value)}
          onKeyPress={e => e.key === 'Enter' && save()}
          stretch
        />
      </Setting>
      <Setting>
        <Label>Font URL:</Label>
        <Input
          type="text"
          defaultValue={currentSettings.fontUrl}
          onChange={e => write('fontUrl', e.target.value)}
          onKeyPress={e => e.key === 'Enter' && save()}
          stretch
        />
      </Setting>
      <Hint>After setting the font URL, configure the font name to use it</Hint>
      <Setting>
        <Label>Font scale:</Label>
        <Input
          type="text"
          defaultValue={currentSettings.fontScale}
          onChange={e => write('fontScale', parseInt(e.target.value))}
          onKeyPress={e => e.key === 'Enter' && save()}
        />
      </Setting>
      <Separator />
      <Setting>
        <Label>Line height:</Label>
        <Input
          type="text"
          defaultValue={currentSettings.lineHeight}
          onChange={e => write('lineHeight', parseFloat(e.target.value))}
          onKeyPress={e => e.key === 'Enter' && save()}
        />
      </Setting>
      <Setting>
        <Label>Condense messages:</Label>
        <Checkbox
          checked={currentSettings.condenseMessages}
          onChange={checked => write('condenseMessages', checked)}
        />
      </Setting>
      <Setting>
        <Label>Enable animations:</Label>
        <Checkbox
          checked={currentSettings.enableAnimations}
          onChange={checked => write('enableAnimations', checked)}
        />
      </Setting>
      <Setting>
        <Label></Label>
        <Button disabled={hasUnsavedSettings} onClick={save}>
          Save changes
        </Button>
      </Setting>
    </GeneralSettingsWrapper>
  );
};

export default GeneralSettings;
