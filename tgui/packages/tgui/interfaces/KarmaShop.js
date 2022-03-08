import { useBackend, useLocalState } from "../backend";
import { Button, Section, Box, Tabs } from "../components";
import { Window } from "../layouts";

export const KarmaShop = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    karma_balance,
    purchased_packages,
    all_packages,
  } = data;

  let unique_cats = [];

  all_packages.map(p => {
    if (!unique_cats.includes(p.cat)) {
      unique_cats.push(p.cat);
    }
  });

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', unique_cats[0]);

  return (
    <Window>
      <Window.Content>
        <Section title={"Karma Balance: " + karma_balance}>
          {
            // Dynamically make tabs
          }
          <Tabs>
            {unique_cats.map(c => (
              <Tabs.Tab
                key={c}
                selected={tabIndex === c}
                onClick={() => setTabIndex(c)}>
                {c}
              </Tabs.Tab>
            ))}
          </Tabs>
          <Box>
            {all_packages.map(p => (
              p.cat === tabIndex && (
                <Box>
                  <Button
                    content={(purchased_packages.includes(p.id) ? "[BOUGHT] " : "") + p.name + " (" + p.cost + " Karma)"}
                    onClick={() => act('makepurchase', { id: p.id })}
                    selected={purchased_packages.includes(p.id)}
                    disabled={!purchased_packages.includes(p.id) && (p.cost > karma_balance)}
                    tooltip={(!purchased_packages.includes(p.id) && (p.cost > karma_balance)) ? "Cannot afford" : null}
                  />
                </Box>
              )
            ))}
          </Box>
          <Box mt="1rem" bold>
            Please note that people who attempt to game the karma system will be banned from the system and have all their unlocks revoked.
            &quot;Gaming&quot; the system includes, but is not limited to:
            <ul>
              <li>Karma trading</li>
              <li>OOC Karma begging</li>
              <li>Code exploits</li>
            </ul>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
