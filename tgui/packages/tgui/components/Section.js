/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, isFalsy, pureComponentHooks } from 'common/react';
import { computeBoxClassName, computeBoxProps, Box } from './Box';

export const Section = (props) => {
  const {
    className,
    title,
    level = 1,
    buttons,
    fill,
    children,
    content,
    stretchContents,
    noTopPadding,
    showBottom = true,
    ...rest
  } = props;
  const hasTitle = !isFalsy(title) || !isFalsy(buttons);
  const hasContent = !isFalsy(content) || !isFalsy(children);
  return (
    <div
      className={classes([
        'Section',
        'Section--level--' + level,
        fill && 'Section--fill',
        props.flexGrow && 'Section--flex',
        className,
        ...computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
    >
      {hasTitle && (
        <div
          className={classes([
            'Section__title',
            showBottom && 'Section__title--showBottom',
          ])}
        >
          <span className="Section__titleText">{title}</span>
          <div className="Section__buttons">{buttons}</div>
        </div>
      )}
      {hasContent && (
        <Box
          className={classes([
            'Section__content',
            !!stretchContents && 'Section__content--stretchContents',
            !!noTopPadding && 'Section__content--noTopPadding',
          ])}
        >
          {content}
          {children}
        </Box>
      )}
    </div>
  );
};

Section.defaultHooks = pureComponentHooks;
