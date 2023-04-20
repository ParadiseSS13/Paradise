/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, isFalsy } from 'common/react';

export const Tooltip = props => {
  const {
    content,
    title,
    position = 'bottom',
  } = props;
  // Empirically calculated length of the string,
  // at which tooltip text starts to overflow.
  const long = typeof content === 'string' && content.length > 35;
  const hasTitle = !isFalsy(title);
  const text = hasTitle ? title + "\n \n" + content: content;

  return (
    <div
      className={classes([
        'Tooltip',
        long && 'Tooltip--long',
        position && 'Tooltip--' + position,

      ])}
      data-tooltip={text} />
  );
};
