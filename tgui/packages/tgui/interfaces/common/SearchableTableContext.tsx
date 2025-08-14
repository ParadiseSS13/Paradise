import React, { createContext, useState } from 'react';

const SearchableTableContext = Object.assign(
  createContext(
    null as null | {
      searchText: string;
      setSearchText: (value: string) => void;
    }
  ),
  {
    Default: (props: { children: React.JSX.Element }) => {
      const [searchText, setSearchText] = useState('');
      return (
        <SearchableTableContext.Provider value={{ searchText, setSearchText }}>
          {props.children}
        </SearchableTableContext.Provider>
      );
    },
  }
);

export default SearchableTableContext;
