import PropTypes from 'prop-types';
import { useEffect, useState } from 'react';
import styled from 'styled-components';
import { Button } from './Button';

const ButtonGroupWrapper = styled.div`
  border-radius: 4px;
  overflow: hidden;

  ${Button} {
    border-radius: 0;
    color: ${props => props.theme.colors.fg[2]};

    &:hover {
      color: ${props => props.theme.colors.fg[0]};
    }

    &:active {
      color: ${props => props.theme.colors.fg[1]};
    }

    &.selected {
      cursor: default;
      background-color: ${props => props.theme.colors.bg[2]};
      color: ${props => props.theme.colors.fg[0]};
    }
  }
`;

const ButtonGroup = ({ options, defaultValue, onOptionSelect }) => {
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

ButtonGroup.propTypes = {
  options: PropTypes.array,
  defaultValue: PropTypes.any,
  onOptionSelect: PropTypes.func,
};

export default ButtonGroup;
