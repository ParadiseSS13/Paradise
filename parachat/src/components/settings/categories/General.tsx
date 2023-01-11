import styled, { css } from 'styled-components';
import { animationDurationMs } from '~/common/animations';
import { useEditSettings } from '~/hooks/useEditSettings';
import Input from '../form/Input';
import Label from '../form/Label';
import { Separator } from '../form/Separator';
import { Setting } from '../form/Setting';

const GeneralSettingsWrapper = styled.div``;

const Button = styled.a`
  background-color: ${props => props.theme.accent.primary};
  display: inline-block;
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  user-select: none;
  transition-duration: ${animationDurationMs}ms;
  border: 1px solid transparent;

  &:hover {
    background-color: ${props => props.theme.accent[6]};
  }

  &:active {
    background-color: ${props => props.theme.accent[5]};
  }

  ${props =>
    props.disabled &&
    css`
      cursor: default !important;
      color: ${props => props.theme.colors.fg[2]} !important;
      background-color: ${props => props.theme.colors.bg[2]} !important;
      border: 1px solid ${props => props.theme.colors.bg[3]} !important;
    `}
`;

const Hint = styled.span`
  display: inline-block;
  margin-left: 98px;
  margin-bottom: 8px;
  color: ${props => props.theme.colors.fg[3]};
`;

const GeneralSettings = () => {
  const { currentSettings, unsavedSettings, write, save } = useEditSettings();

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
        <Label></Label>
        <Button
          disabled={!Object.values(unsavedSettings).filter(v => v).length}
          onClick={save}
        >
          Save changes
        </Button>
      </Setting>
    </GeneralSettingsWrapper>
  );
};

export default GeneralSettings;
