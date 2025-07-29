import React, { createContext, useState } from 'react';

const SortableTableContext = Object.assign(
  createContext(
    null as null | {
      sortId: string;
      setSortId: (value: string) => void;
      sortOrder: boolean;
      setSortOrder: (value: boolean) => void;
    }
  ),
  {
    Default: (props: { children: React.JSX.Element; sortId: string; sortOrder?: boolean }) => {
      const [sortId, setSortId] = useState(props.sortId);
      const [sortOrder, setSortOrder] = useState(props.sortOrder ?? true);
      return (
        <SortableTableContext.Provider value={{ sortId, setSortId, sortOrder, setSortOrder }}>
          {props.children}
        </SortableTableContext.Provider>
      );
    },
  }
);

export default SortableTableContext;
