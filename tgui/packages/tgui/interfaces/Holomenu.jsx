import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Holomenu = (props) => {
  const { data } = useBackend();
  const { menu_text } = data;

  return (
    <Window width={400} height={450} title="Holomenu">
      <Window.Content>
        <div dangerouslySetInnerHTML={{ __html: menu_text }} />
      </Window.Content>
    </Window>
  );
};
