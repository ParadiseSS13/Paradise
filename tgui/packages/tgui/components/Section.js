import { classes, isFalsy, pureComponentHooks } from 'common/react';
import { Box } from './Box';

export const Section = props => {
  const {
    className,
    title,
    level = 1,
    buttons,
    content,
    stretchContents,
    noTopPadding,
    children,
    ...rest
  } = props;
  const hasTitle = !isFalsy(title) || !isFalsy(buttons);
  const hasContent = !isFalsy(content) || !isFalsy(children);
  return (
    <Box
      className={classes([
        'Section',
        'Section--level--' + level,
        props.flexGrow && 'Section--flex',
        className,
      ])}
      {...rest}>
      {hasTitle && (
        <div className="Section__title">
          <span className="Section__titleText">
            {title}
          </span>
          <div className="Section__buttons">
            {buttons}
          </div>
        </div>
      )}
      {hasContent && (
        <Box className={classes([
          "Section__content",
          !!stretchContents && "Section__content--stretchContents",
          !!noTopPadding && "Section__content--noTopPadding",
        ])}>
          {content}
          {children}
        </Box>
      )}
    </Box>
  );
};

Section.defaultHooks = pureComponentHooks;
