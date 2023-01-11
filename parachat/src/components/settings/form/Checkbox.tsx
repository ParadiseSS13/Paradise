import PropTypes from 'prop-types';
import { useState } from 'react';
import styled, { css } from 'styled-components';

const CheckboxWrapper = styled.div`
  display: inline-block;
  width: 16px;
  height: 16px;
  border-radius: 4px;
  border: 1px solid ${props => props.theme.colors.bg[1]};
  transition-duration: 0.2s;
  vertical-align: middle;
  overflow: hidden;

  &:hover,
  &:focus {
    border-color: ${props => props.theme.accent.primary};
  }

  ${props =>
    props.checked &&
    css`
      border-color: ${props => props.theme.accent.primary};

      &::after {
        content: '✓';
        display: inline-block;
        width: 16px;
        height: 16px;
        background-color: ${props => props.theme.accent.primary};
        text-align: center;
        font-weight: bold;
      }
    `}
`;

const Checkbox = ({ checked }) => {
  const [isChecked, setIsChecked] = useState(checked);

  const handleClick = () => setIsChecked(!isChecked);

  return <CheckboxWrapper onClick={handleClick} checked={isChecked} />;
};

Checkbox.propTypes = {
  checked: PropTypes.bool,
};

export default Checkbox;
