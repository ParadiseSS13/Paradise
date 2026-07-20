import { useEffect, useState } from 'react';
import { Button, Icon, Input, Stack } from 'tgui-core/components';

import { chatSearchController } from './ChatSearchController';

type CurrentPageSearchStatus = {
  matchCount: number;
  selectedMatchIndex: number | null;
};

type Props = {
  onClose: () => void;
};

const SEARCH_DELAY_MS = 200;

export const ChatSearchBar = ({ onClose }: Props) => {
  const [searchText, setSearchText] = useState('');
  const [searchStatus, setSearchStatus] = useState<CurrentPageSearchStatus>({
    matchCount: 0,
    selectedMatchIndex: null,
  });
  const [isSearchWaiting, setIsSearchWaiting] = useState(false);

  useEffect(() => {
    if (!searchText) {
      setIsSearchWaiting(false);
      setSearchStatus(chatSearchController.applySearchText(''));
      return;
    }

    setIsSearchWaiting(true);
    const timer = window.setTimeout(() => {
      setSearchStatus(chatSearchController.applySearchText(searchText));
      setIsSearchWaiting(false);
    }, SEARCH_DELAY_MS);
    return () => {
      window.clearTimeout(timer);
    };
  }, [searchText]);

  useEffect(() => {
    const updateSearchStatus = (nextStatus: CurrentPageSearchStatus) => setSearchStatus(nextStatus);
    chatSearchController.setSearchStatusChangedHandler(updateSearchStatus);
    return () => chatSearchController.setSearchStatusChangedHandler(null);
  }, []);

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onClose();
    };
    document.addEventListener('keydown', handleKeyDown);
    return () => {
      document.removeEventListener('keydown', handleKeyDown);
      chatSearchController.clearSearch();
    };
  }, [onClose]);

  const selectNextMatch = () => setSearchStatus(chatSearchController.selectNextMatch());
  const selectPreviousMatch = () => setSearchStatus(chatSearchController.selectPreviousMatch());

  return (
    <div className="Chat__searchBar">
      <Stack align="center">
        <Stack.Item grow>
          <Input
            autoFocus
            fluid
            placeholder="Search chat..."
            value={searchText}
            onChange={(value) => setSearchText(value)}
            onKeyDown={(event) => {
              if (event.key !== 'Enter') return;
              event.preventDefault();
              if (event.shiftKey) selectPreviousMatch();
              else selectNextMatch();
              const searchInput = event.currentTarget;
              requestAnimationFrame(() => searchInput.focus());
            }}
          />
        </Stack.Item>
        <Stack.Item className="Chat__searchCount">
          {searchStatus.matchCount > 0 && searchStatus.selectedMatchIndex !== null
            ? `${searchStatus.selectedMatchIndex + 1} / ${searchStatus.matchCount}`
            : '-'}
        </Stack.Item>
        {isSearchWaiting && (
          <Stack.Item className="Chat__searchSpinner">
            <Icon name="spinner" spin />
          </Stack.Item>
        )}
        <Stack.Item>
          <Button icon="arrow-up" tooltip="Previous match" onClick={selectPreviousMatch} />
        </Stack.Item>
        <Stack.Item>
          <Button icon="arrow-down" tooltip="Next match" onClick={selectNextMatch} />
        </Stack.Item>
        <Stack.Item>
          <Button icon="times" tooltip="Close search" onClick={onClose} />
        </Stack.Item>
      </Stack>
    </div>
  );
};
