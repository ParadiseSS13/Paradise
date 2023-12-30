/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';

const FA_OUTLINE_REGEX = /-o$/;

export const Icon = (props) => {
  const {
    name,
    size,
    spin,
    className,
    style = {},
    rotation,
    inverse,
    ...rest
  } = props;
  if (size) {
    style['font-size'] = size * 100 + '%';
  }
  if (typeof rotation === 'number') {
    style['transform'] = `rotate(${rotation}deg)`;
  }
  const faRegular = FA_OUTLINE_REGEX.test(name);
  const faName = name.replace(FA_OUTLINE_REGEX, '');
  return (
    <Box
      as="i"
      className={classes([
        'Icon',
        className,
        faRegular ? 'far' : 'fas',
        'fa-' + faName,
        spin && 'fa-spin',
      ])}
      style={style}
      {...rest}
    />
  );
};

Icon.defaultHooks = pureComponentHooks;

export const IconStack = (props) => {
  const { className, style = {}, children, ...rest } = props;
  return (
    <Box
      as="span"
      class={classes(['IconStack', className])}
      style={style}
      {...rest}
    >
      {children}
    </Box>
  );
};

Icon.Stack = IconStack;
