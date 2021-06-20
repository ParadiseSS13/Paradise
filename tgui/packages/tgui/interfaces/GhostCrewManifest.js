import { Section } from '../components';
import { Window } from '../layouts';
import { CrewManifest } from "./common/CrewManifest";

export const GhostCrewManifest = (props, context) => {
  return (
    <Window resizable theme="nologo">
      <Window.Content scrollable>
        <Section noTopPadding>
          <CrewManifest />
        </Section>
      </Window.Content>
    </Window>
  );
};
