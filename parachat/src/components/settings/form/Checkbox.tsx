import { useState } from 'react';
import styled, { css } from 'styled-components';

interface CheckboxProps {
  checked?: boolean;
  onChange?: (checked: boolean) => void;
}

const CheckboxWrapper = styled.div<{ checked?: boolean }>`
  width: 16px;
  height: 16px;
  display: inline-block;
  border: 1px solid ${({ theme }) => theme.background[1]};
  border-radius: 4px;
  overflow: hidden;
  transition-duration: ${({ theme }) => theme.animationDurationMs}ms;
  vertical-align: middle;

  &:hover,
  &:focus {
    border-color: ${({ theme }) => theme.accent[4]};
  }

  ${({ checked }) =>
    checked &&
    css`
      border-color: ${({ theme }) => theme.accent[4]};
      cursor: default;

      &::after {
        width: 16px;
        height: 16px;
        background-color: ${({ theme }) => theme.accent[4]};
        content: '✓';
        display: inline-block;
        font-weight: bold;
        text-align: center;
      }
    `}
`;

const Checkbox = ({ checked, onChange }: CheckboxProps) => {
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
