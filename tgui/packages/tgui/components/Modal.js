/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';
import { Dimmer } from './Dimmer';

export const Modal = (props) => {
  const { className, children, onEnter, ...rest } = props;
  let handleKeyDown;
  if (onEnter) {
    handleKeyDown = (e) => {
      if (e.keyCode === 13) {
        onEnter(e);
      }
    };
  }
  return (
    <Dimmer onKeyDown={handleKeyDown}>
      <div className={classes(['Modal', className, computeBoxClassName(rest)])} {...computeBoxProps(rest)}>
        {children}
      </div>
    </Dimmer>
  );
};
