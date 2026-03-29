import React, { createContext, useState } from 'react';

const TabsContext = Object.assign(
  createContext(
    null as null | {
      tabIndex: number;
      setTabIndex: (value: number) => void;
    }
  ),
  {
    Default: (props: { children: React.JSX.Element; tabIndex: number }) => {
      const [tabIndex, setTabIndex] = useState(props.tabIndex);
      return <TabsContext.Provider value={{ tabIndex, setTabIndex }}>{props.children}</TabsContext.Provider>;
    },
  }
);

export default TabsContext;
