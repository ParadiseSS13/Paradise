import styled, { css } from 'styled-components';
import { animationDurationMs } from '~/common/animations';
import Checkbox from '~/components/settings/form/Checkbox';
import { useEditSettings } from '~/hooks/useEditSettings';
import Input from '../form/Input';
import Label from '../form/Label';
import { Separator } from '../form/Separator';
import { Setting } from '../form/Setting';

const GeneralSettingsWrapper = styled.div``;

const Button = styled.a<{ disabled?: boolean }>`
  padding: 8px 12px;
  border: 1px solid transparent;
  background-color: ${({ theme }) => theme.accent.primary};
  border-radius: 4px;
  cursor: pointer;
  display: inline-block;
  transition-duration: ${animationDurationMs}ms;
  user-select: none;

  &:hover {
    background-color: ${({ theme }) => theme.accent[6]};
  }

  &:active {
    background-color: ${({ theme }) => theme.accent[5]};
  }

  ${({ disabled }) =>
    disabled &&
    css`
      border: 1px solid ${({ theme }) => theme.colors.bg[3]} !important;
      background-color: ${({ theme }) => theme.colors.bg[2]} !important;
      color: ${({ theme }) => theme.colors.fg[2]} !important;
      cursor: default !important;
    `}
`;

const Hint = styled.span`
  margin-bottom: 8px;
  margin-left: 98px;
  color: ${props => props.theme.colors.fg[3]};
  display: inline-block;
`;

const GeneralSettings = () => {
  const { currentSettings, hasUnsavedSettings, write, save } =
    useEditSettings();

  return (
    <GeneralSettingsWrapper>
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
      <Hint style={{ marginBottom: 0 }}>
        After setting the font URL, configure the font name to use it
      </Hint>
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
        <Label></Label>
        <Button disabled={hasUnsavedSettings} onClick={save}>
          Save changes
        </Button>
      </Setting>
    </GeneralSettingsWrapper>
  );
};

export default GeneralSettings;
