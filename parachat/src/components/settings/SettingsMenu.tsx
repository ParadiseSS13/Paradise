import { useState } from 'react';
import { Transition } from 'react-transition-group';
import styled from 'styled-components';
import { animationDurationMs, fadeIn, slideUp } from '~/common/animations';
import { SettingsTab } from '~/common/types';
import { useHeaderSlice } from '~/stores/header';
import Categories from './Categories';
import GeneralSettings from './categories/General';
import HighlightSettings from './categories/Highlight';

const Backdrop = styled.div`
  background-color: rgba(0, 0, 0, 0.7);
  box-sizing: border-box;
  position: absolute;
  z-index: 100;
  padding: 32px;
  width: 100%;
  height: 100%;
  transition-duration: ${animationDurationMs}ms;
  ${fadeIn.initial};
`;

const SettingsWrapper = styled.div`
  background-color: ${({ theme }) => theme.background[0]};
  box-shadow: 0 0 20px rgba(0, 0, 0, 0.5);
  box-sizing: border-box;
  display: block;
  height: 100%;
  padding: 20px 0;
  transition-duration: ${animationDurationMs}ms;
  ${slideUp.initial};
`;

const Content = styled.div`
  display: block;
  height: 100%;
  overflow: auto;
  padding-right: 20px;
`;

const categories = [
  { catName: 'General', catId: SettingsTab.GENERAL },
  { catName: 'Highlight', catId: SettingsTab.HIGHLIGHT },
];

const SettingsMenu = () => {
  const [selectedCategory, setSelectedCategory] = useState(SettingsTab.GENERAL);
  const showSettings = useHeaderSlice(state => state.showSettings);
  const setShowSettings = useHeaderSlice(state => state.setShowSettings);

  const onCategorySelected = catId => {
    if (catId === selectedCategory) {
      return;
    }

    setSelectedCategory(catId);
  };

  return (
    <Transition
      in={showSettings}
      timeout={animationDurationMs}
      mountOnEnter
      unmountOnExit
    >
      {state => (
        <Backdrop
          style={{ ...fadeIn[state] }}
          onClick={() => setShowSettings(false)}
        >
          <SettingsWrapper
            style={{ ...slideUp[state] }}
            onClick={e => e.stopPropagation()}
          >
            <Categories
              categories={categories}
              selectedCategory={selectedCategory}
              onCategorySelected={onCategorySelected}
            />
            <Content>
              {selectedCategory === SettingsTab.GENERAL && <GeneralSettings />}
              {selectedCategory === SettingsTab.HIGHLIGHT && (
                <HighlightSettings />
              )}
            </Content>
          </SettingsWrapper>
        </Backdrop>
      )}
    </Transition>
  );
};

export default SettingsMenu;
