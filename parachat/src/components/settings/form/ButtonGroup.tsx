import { useEffect, useState } from 'react';
import styled from 'styled-components';
import { Button } from './Button';

interface ButtonGroupProps {
  options: string[];
  defaultValue: string;
  onOptionSelect: (selectedOption: string) => void;
}

const ButtonGroupWrapper = styled.div`
  border-radius: 4px;
  overflow: hidden;

  ${Button} {
    border-radius: 0;
    color: ${({ theme }) => theme.textDisabled};
    text-transform: capitalize;

    &:hover {
      color: ${({ theme }) => theme.textPrimary};
    }

    &:active {
      color: ${({ theme }) => theme.textSecondary};
    }

    &.selected {
      cursor: default;
      background-color: ${({ theme }) => theme.background[2]};
      color: ${({ theme }) => theme.primary};
    }
  }
`;

const ButtonGroup = ({
  options,
  defaultValue,
  onOptionSelect,
}: ButtonGroupProps) => {
  const [selectedOption, setSelectedOption] = useState(
    defaultValue || options[0]
  );

  useEffect(() => {
    onOptionSelect(selectedOption);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedOption]);

  return (
    <ButtonGroupWrapper>
      {options.map(o => (
        <Button
          key={o}
          className={o === selectedOption && 'selected'}
          onClick={() => {
            setSelectedOption(o);
          }}
          neutral
          small
        >
          {o}
        </Button>
      ))}
    </ButtonGroupWrapper>
  );
};

export default ButtonGroup;
