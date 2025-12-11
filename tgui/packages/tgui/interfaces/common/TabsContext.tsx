import { noop } from 'lodash';
import React, { createContext, useState } from 'react';

export interface TabsContextInterface {
  tabIndex: number;
  setTabIndex: (value: number) => void;
}

const TabsContext = Object.assign(createContext({ tabIndex: 0, setTabIndex: noop }), {
  Default: (props: { children: React.JSX.Element; tabIndex: number }) => {
    const [tabIndex, setTabIndex] = useState(props.tabIndex);
    return <TabsContext.Provider value={{ tabIndex, setTabIndex }}>{props.children}</TabsContext.Provider>;
  },
});

export default TabsContext;
