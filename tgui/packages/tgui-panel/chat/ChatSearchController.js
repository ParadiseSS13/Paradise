import { highlightNode } from './replaceInTextNode';

export class ChatSearchController {
  constructor() {
    // Search state belongs here because this class owns message highlighting.
    this.activeSearchText = '';
    this.activeSearchPattern = null;
    this.matchedTextNodes = [];
    this.selectedMatchIndex = null;
    // The renderer replaces this reference when the user changes chat tabs.
    this.currentPageMessages = [];
    // A rebuild creates new message nodes; scan them once after it finishes.
    this.isRebuildingChat = false;
    // Only ChatSearchBar displays the status, so one callback is sufficient.
    this.onSearchStatusChanged = null;
    this.onMatchSelected = null;
  }

  get hasActiveSearch() {
    return this.activeSearchPattern !== null;
  }

  getCurrentPageSearchStatus() {
    return {
      matchCount: this.matchedTextNodes.length,
      selectedMatchIndex: this.selectedMatchIndex,
    };
  }

  setSearchStatusChangedHandler(handler) {
    this.onSearchStatusChanged = handler;
  }

  setMatchSelectedHandler(handler) {
    this.onMatchSelected = handler;
  }

  notifySearchStatusChanged() {
    this.onSearchStatusChanged?.(this.getCurrentPageSearchStatus());
  }

  clearSearchHighlights() {
    // Replace temporary search spans with their original text nodes.
    const changedParents = new Set();
    for (const matchedTextNode of this.matchedTextNodes) {
      if (!matchedTextNode.parentNode) continue;
      const parentNode = matchedTextNode.parentNode;
      parentNode.replaceChild(document.createTextNode(matchedTextNode.textContent), matchedTextNode);
      changedParents.add(parentNode);
    }
    for (const parentNode of changedParents) {
      parentNode.normalize();
    }
    this.matchedTextNodes = [];
    this.selectedMatchIndex = null;
  }

  highlightSearchInMessage(message) {
    const canHighlightMessage = message.node && message.node !== 'pruned';
    if (!this.hasActiveSearch || !canHighlightMessage) return;

    // The global RegExp stores its last position, so reset it for each message.
    this.activeSearchPattern.lastIndex = 0;
    highlightNode(message.node, this.activeSearchPattern, null, (text) => {
      const matchedTextNode = document.createElement('span');
      matchedTextNode.className = 'Chat__searchMatch';
      matchedTextNode.textContent = text;
      this.matchedTextNodes.push(matchedTextNode);
      return matchedTextNode;
    });
  }

  applySearchToMessages(visibleMessages, focusFirstMatch = false) {
    // A query change or tab change rescans every message in the current tab.
    this.clearSearchHighlights();
    if (!this.hasActiveSearch) {
      this.notifySearchStatusChanged();
      return this.getCurrentPageSearchStatus();
    }

    for (const message of visibleMessages) {
      this.highlightSearchInMessage(message);
    }

    if (this.matchedTextNodes.length > 0) {
      this.selectMatch(0, {
        notify: false,
        scrollToMatch: focusFirstMatch,
      });
    }
    this.notifySearchStatusChanged();
    return this.getCurrentPageSearchStatus();
  }

  applySearchText(searchText) {
    this.activeSearchText = searchText.trim();
    if (!this.activeSearchText) {
      this.activeSearchPattern = null;
      return this.applySearchToMessages(this.currentPageMessages);
    }

    // Escape RegExp special characters so a query such as "[test]" is searched literally,
    // rather than interpreted as a regular expression. "g" finds every match and "i" ignores case.
    const escapedSearchText = this.activeSearchText.replace(/[-/\\^$*+?.()|[\]{}]/g, '\\$&');
    this.activeSearchPattern = new RegExp(`(${escapedSearchText})`, 'gi');
    return this.applySearchToMessages(this.currentPageMessages, true);
  }

  onMessageAdded(message, visibleMessages) {
    this.currentPageMessages = visibleMessages;
    if (!this.hasActiveSearch || this.isRebuildingChat) return;

    const matchCountBefore = this.matchedTextNodes.length;
    this.highlightSearchInMessage(message);
    if (matchCountBefore === 0 && this.matchedTextNodes.length > 0) {
      this.selectMatch(0, {
        notify: false,
        scrollToMatch: false,
      });
    }
    this.notifySearchStatusChanged();
  }

  onCurrentPageChanged(visibleMessages) {
    this.currentPageMessages = visibleMessages;
    if (this.hasActiveSearch) this.applySearchToMessages(visibleMessages);
  }

  beginChatRebuild() {
    this.isRebuildingChat = true;
  }

  endChatRebuild(visibleMessages) {
    this.isRebuildingChat = false;
    this.onCurrentPageChanged(visibleMessages);
  }

  selectMatch(index, options = {}) {
    const { notify = true, scrollToMatch = true } = options;
    if (this.selectedMatchIndex !== null) {
      this.matchedTextNodes[this.selectedMatchIndex]?.classList.remove('Chat__searchMatch--active');
    }
    const selectedMatch = this.matchedTextNodes[index];
    if (selectedMatch) {
      selectedMatch.classList.add('Chat__searchMatch--active');
      if (scrollToMatch) this.onMatchSelected?.(selectedMatch);
    }
    this.selectedMatchIndex = index;
    if (notify) this.notifySearchStatusChanged();
  }

  selectNextMatch() {
    if (this.matchedTextNodes.length === 0) return this.getCurrentPageSearchStatus();
    const nextMatchIndex =
      this.selectedMatchIndex === null ? 0 : (this.selectedMatchIndex + 1) % this.matchedTextNodes.length;
    this.selectMatch(nextMatchIndex);
    return this.getCurrentPageSearchStatus();
  }

  selectPreviousMatch() {
    if (this.matchedTextNodes.length === 0) return this.getCurrentPageSearchStatus();
    const previousMatchIndex =
      this.selectedMatchIndex === null
        ? this.matchedTextNodes.length - 1
        : (this.selectedMatchIndex - 1 + this.matchedTextNodes.length) % this.matchedTextNodes.length;
    this.selectMatch(previousMatchIndex);
    return this.getCurrentPageSearchStatus();
  }

  clearSearch() {
    this.activeSearchText = '';
    this.activeSearchPattern = null;
    this.clearSearchHighlights();
    this.notifySearchStatusChanged();
  }
}

export const chatSearchController = new ChatSearchController();
