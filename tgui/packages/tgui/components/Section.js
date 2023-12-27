/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { canRender, classes } from 'common/react';
import { Component, createRef } from 'inferno';
import { addScrollableNode, removeScrollableNode } from '../events';
import { computeBoxClassName, computeBoxProps } from './Box';

export class Section extends Component {
  constructor(props) {
    super(props);
    this.ref = createRef();
    this.scrollable = this.props.scrollable;
  }

  componentDidMount() {
    if (this.scrollable) {
      addScrollableNode(this.ref.current);
    }
  }

  componentWillUnmount() {
    if (this.scrollable) {
      removeScrollableNode(this.ref.current);
    }
  }

  render() {
    const {
      className,
      title,
      level = 1,
      buttons,
      fill,
      fitted,
      scrollable,
      children,
      content,
      stretchContents,
      noTopPadding,
      showBottom = true,
      ...rest
    } = this.props;

    const hasTitle = canRender(title) || canRender(buttons);
    const hasContent = canRender(content) || canRender(children);

    return (
      <div
        ref={this.ref}
        className={classes([
          Byond.IS_LTE_IE8 && 'Section--iefix',
          'Section',
          'Section--level--' + level,
          fill && 'Section--fill',
          fitted && 'Section--fitted',
          scrollable && 'Section--scrollable',
          this.props.flexGrow && 'Section--flex',
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
        {fitted && children
          ? children
          : hasContent && (
              <div
                className={classes([
                  'Section__content',
                  !!stretchContents && 'Section__content--stretchContents',
                  !!noTopPadding && 'Section__content--noTopPadding',
                ])}
              >
                {content}
                {children}
              </div>
            )}
      </div>
    );
  }
}
