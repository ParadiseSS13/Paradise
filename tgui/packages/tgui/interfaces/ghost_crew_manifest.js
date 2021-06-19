import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Section } from '../components';
import { Window } from '../layouts';
import { CrewManifest } from "./common/CrewManifest";

export const ghost_crew_manifest = (props, context) => {
  const { act, data } = useBackend(context);
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
