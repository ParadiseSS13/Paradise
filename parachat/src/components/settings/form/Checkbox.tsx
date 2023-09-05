import { useState } from 'react';
import styled, { css } from 'styled-components';
import { animationDurationMs } from '~/common/animations';

interface CheckboxProps {
  checked?: boolean;
  onChange?: (checked: boolean) => void;
}

const CheckboxWrapper = styled.div<{ checked?: boolean }>`
  width: 16px;
  height: 16px;
  display: inline-block;
  border: 1px solid ${({ theme }) => theme.colors.bg[1]};
  border-radius: 4px;
  overflow: hidden;
  transition-duration: ${animationDurationMs}ms;
  vertical-align: middle;

  &:hover,
  &:focus {
    border-color: ${({ theme }) => theme.accent.primary};
  }

  ${({ checked }) =>
    checked &&
    css`
      border-color: ${({ theme }) => theme.accent.primary};
      cursor: default;

      &::after {
        width: 16px;
        height: 16px;
        background-color: ${({ theme }) => theme.accent.primary};
        content: '✓';
        display: inline-block;
        font-weight: bold;
        text-align: center;
      }
    `}
`;

const Checkbox: React.FC<CheckboxProps> = ({ checked, onChange }) => {
  const [isChecked, setIsChecked] = useState(checked);
  const handleClick = () => {
    const value = !isChecked;
    setIsChecked(value);
    if (onChange) {
      onChange(value);
    }
  };

  return <CheckboxWrapper checked={isChecked} onClick={handleClick} />;
};

export default Checkbox;
