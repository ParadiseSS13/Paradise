import { Section } from 'tgui-core/components';

import { Window } from '../layouts';
import { CrewManifest } from './common/CrewManifest';

export const GenericCrewManifest = (props) => {
  return (
    <Window theme="nologo" width={588} height={510}>
      <Window.Content scrollable>
        <Section noTopPadding>
          <CrewManifest />
        </Section>
      </Window.Content>
    </Window>
  );
};
