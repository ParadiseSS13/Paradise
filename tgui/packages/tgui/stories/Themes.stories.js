/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { useContext } from 'react';
import { Input, LabeledList, Section } from 'tgui-core/components';

import { ThemeContext } from '../debug/ThemeContext';

export const meta = {
  title: 'Themes',
  render: () => <Story />,
};

const Story = (props) => {
  const [theme, setTheme] = useContext(ThemeContext);
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Use theme">
          <Input placeholder="theme_name" value={theme} onChange={(value) => setTheme(value)} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
