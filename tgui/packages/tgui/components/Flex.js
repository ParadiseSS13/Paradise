/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { Box, unit } from './Box';

export const computeFlexProps = (props) => {
  const {
    className,
    direction,
    wrap,
    align,
    alignContent,
    justify,
    inline,
    spacing = 0,
    spacingPrecise = 0,
    ...rest
  } = props;
  return {
    className: classes([
      'Flex',
      Byond.IS_LTE_IE10 &&
        (direction === 'column' ? 'Flex--iefix--column' : 'Flex--iefix'),
      inline && 'Flex--inline',
      spacing > 0 && 'Flex--spacing--' + spacing,
      spacingPrecise > 0 && 'Flex--spacingPrecise--' + spacingPrecise,
      className,
    ]),
    style: {
      ...rest.style,
      'flex-direction': direction,
      'flex-wrap': wrap,
      'align-items': align,
      'align-content': alignContent,
      'justify-content': justify,
    },
    ...rest,
  };
};

export const Flex = (props) => <Box {...computeFlexProps(props)} />;

Flex.defaultHooks = pureComponentHooks;

export const computeFlexItemProps = (props) => {
  const {
    className,
    grow,
    order,
    shrink,
    // IE11: Always set basis to specified width, which fixes certain
    // bugs when rendering tables inside the flex.
    basis = props.width,
    align,
    ...rest
  } = props;
  return {
    className: classes([
      'Flex__item',
      Byond.IS_LTE_IE10 && 'Flex__item--iefix',
      className,
    ]),
    style: {
      ...rest.style,
      'flex-grow': grow,
      'flex-shrink': shrink,
      'flex-basis': unit(basis),
      'order': order,
      'align-self': align,
    },
    ...rest,
  };
};

export const FlexItem = (props) => <Box {...computeFlexItemProps(props)} />;

FlexItem.defaultHooks = pureComponentHooks;

Flex.Item = FlexItem;
