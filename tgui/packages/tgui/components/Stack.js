/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { classes } from "common/react"
import {
  computeFlexClassName,
  computeFlexItemClassName,
  computeFlexItemProps,
  computeFlexProps
} from "./Flex"

export const Stack = props => {
  const { className, vertical, fill, ...rest } = props
  return (
    <div
      className={classes([
        "Stack",
        fill && "Stack--fill",
        vertical ? "Stack--vertical" : "Stack--horizontal",
        className,
        computeFlexClassName(props)
      ])}
      {...computeFlexProps({
        direction: vertical ? "column" : "row",
        ...rest
      })}
    />
  )
}

const StackItem = props => {
  const { className, innerRef, ...rest } = props
  return (
    <div
      className={classes([
        "Stack__item",
        className,
        computeFlexItemClassName(rest)
      ])}
      ref={innerRef}
      {...computeFlexItemProps(rest)}
    />
  )
}

Stack.Item = StackItem

const StackDivider = props => {
  const { className, hidden, ...rest } = props
  return (
    <div
      className={classes([
        "Stack__item",
        "Stack__divider",
        hidden && "Stack__divider--hidden",
        className,
        computeFlexItemClassName(rest)
      ])}
      {...computeFlexItemProps(rest)}
    />
  )
}

Stack.Divider = StackDivider
