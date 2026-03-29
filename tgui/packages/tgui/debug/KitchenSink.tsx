/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import './ThemeContext';

import { useState } from 'react';
import { Section, Stack, Tabs } from 'tgui-core/components';

import { Pane, Window } from '../layouts';
import { ThemeContext } from './ThemeContext';

const r = require.context('../stories', false, /\.stories\.js$/);

/**
 * @returns {{
 *   meta: {
 *     title: string,
 *     render: () => any,
 *   },
 * }[]}
 */
function getStories() {
  return r.keys().map((path) => r(path));
}

export function KitchenSink(props) {
  const { panel } = props;

  const [theme, setTheme] = useState('');
  const [pageIndex, setPageIndex] = useState(0);

  const stories = getStories();
  const story = stories[pageIndex];
  const Layout = panel ? Pane : Window;

  return (
    <ThemeContext.Provider value={[theme, setTheme]}>
      <Layout title="Kitchen Sink" width={600} height={500} theme={theme}>
        <Layout.Content>
          <Stack fill>
            <Stack.Item>
              <Section fill fitted>
                <Tabs vertical>
                  {stories.map((story, i) => (
                    <Tabs.Tab key={i} color="transparent" selected={i === pageIndex} onClick={() => setPageIndex(i)}>
                      {story.meta.title}
                    </Tabs.Tab>
                  ))}
                </Tabs>
              </Section>
            </Stack.Item>
            <Stack.Item grow>{story.meta.render()}</Stack.Item>
          </Stack>
        </Layout.Content>
      </Layout>
    </ThemeContext.Provider>
  );
}
