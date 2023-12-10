import { Section } from '../components';
import { Window } from '../layouts';
import { CrewManifest } from './common/CrewManifest';

export const GenericCrewManifest = (props, context) => {
  return (
    <Window resizable theme="nologo" width={588} height={510}>
      <Window.Content scrollable>
        <Section noTopPadding>
          <CrewManifest />
        </Section>
      </Window.Content>
    </Window>
  );
};
