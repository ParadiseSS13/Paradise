import PropTypes from 'prop-types';
import { useState } from 'react';
import styled, { css } from 'styled-components';
import { animationDurationMs } from '~/common/animations';
import { defaultSettings, saveSettings } from '~/common/settings';
import { useHeaderSlice, useSettingsSlice } from '~/common/store';

const CategoriesWrapper = styled.div`
  display: flex;
  flex-direction: column;
  float: left;
  width: 20%;
  height: 100%;
  margin-right: 20px;
  border-right: 1px solid ${props => props.theme.colors.bg[1]};
`;

const CategoryList = styled.div`
  flex: 1;
  overflow: auto;
`;

const Category = styled.a`
  color: ${props => props.theme.colors.fg[0]};
  display: block;
  padding: 12px;
  padding-left: 32px;
  cursor: pointer;
  transition-duration: ${animationDurationMs}ms;

  &:hover {
    background-color: ${props => props.theme.colors.bg[2]};
  }

  &:active {
    background-color: ${props => props.theme.colors.bg[1]};
  }

  ${props =>
    props.selected &&
    css`
      background-color: ${props => props.theme.accent[0]} !important;
      color: ${props => props.theme.accent.primary};
      cursor: default;
    `}
`;

const ResetButton = styled(Category)`
  color: ${props => props.theme.colors.fg[3]};
  transition-duration: ${animationDurationMs}ms;

  ${props =>
    props.confirm &&
    css`
      background-color: ${props => props.theme.colors.bgError} !important;
      color: ${props => props.theme.colors.fgError};
    `}
`;

const CloseButton = styled(Category)`
  color: ${props => props.theme.colors.fg[3]};
`;

const Categories = ({ categories, selectedCategory, onCategorySelected }) => {
  const setShowSettings = useHeaderSlice(state => state.setShowSettings);
  const updateSettings = useSettingsSlice(state => state.updateSettings);
  const [reallyReset, setReallyReset] = useState(false);

  const resetSettings = () => {
    updateSettings({ ...defaultSettings });
    saveSettings();
    setShowSettings(false);
  };

  return (
    <CategoriesWrapper>
      <CategoryList>
        {categories.map(({ catName, catId }) => (
          <Category
            key={catId}
            selected={selectedCategory === catId}
            onClick={() => onCategorySelected(catId)}
          >
            {catName}
          </Category>
        ))}
      </CategoryList>
      <ResetButton
        confirm={reallyReset}
        onClick={() => (reallyReset ? resetSettings() : setReallyReset(true))}
        onMouseLeave={() => reallyReset && setReallyReset(false)}
      >
        {reallyReset ? 'Are you sure?' : 'Reset to defaults'}
      </ResetButton>
      <CloseButton onClick={() => setShowSettings(false)}>Close</CloseButton>
    </CategoriesWrapper>
  );
};

Categories.propTypes = {
  categories: PropTypes.array.isRequired,
  selectedCategory: PropTypes.number,
  onCategorySelected: PropTypes.func,
};

export default Categories;
