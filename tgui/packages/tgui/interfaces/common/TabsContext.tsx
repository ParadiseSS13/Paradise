import React, { createContext, useContext, useState } from 'react';

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

export const useTabs = () => {
  const context = useContext(TabsContext);
  if (!context) {
    throw new Error('useTabs must be used within a TabsProvider');
  }
  return context;
};


export default TabsContext;
