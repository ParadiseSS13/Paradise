import { beforeEach, describe, it } from 'vitest';

import { ChannelIterator } from './ChannelIterator';

describe('ChannelIterator', () => {
  let channelIterator: ChannelIterator;

  beforeEach(() => {
    channelIterator = new ChannelIterator();
  });

  it('should cycle through channels properly', ({ expect }) => {
    expect(channelIterator.current()).toBe('Say');
    expect(channelIterator.next()).toBe('Radio');
    expect(channelIterator.next()).toBe('Whisper');
    expect(channelIterator.next()).toBe('Me');
    expect(channelIterator.next()).toBe('OOC');
    expect(channelIterator.next()).toBe('LOOC');
    expect(channelIterator.next()).toBe('Say');
  });

  it('should set a channel properly', ({ expect }) => {
    channelIterator.set('OOC');
    expect(channelIterator.current()).toBe('OOC');
  });

  it('should return true when current channel is "Say"', ({ expect }) => {
    channelIterator.set('Say');
    expect(channelIterator.isSay()).toBe(true);
  });

  it('should return false when current channel is not "Say"', ({ expect }) => {
    channelIterator.set('Radio');
    expect(channelIterator.isSay()).toBe(false);
  });

  it('should return true when current channel is visible', ({ expect }) => {
    channelIterator.set('Say');
    expect(channelIterator.isVisible()).toBe(true);
  });

  it('should return false when current channel is not visible', ({ expect }) => {
    channelIterator.set('OOC');
    expect(channelIterator.isVisible()).toBe(false);
  });

  // Stuff & Dsay channels shouldn't be leaked by miss click
  it('should not leak a message from a blacklisted channel', ({ expect }) => {
    channelIterator.set('Mentor');
    expect(channelIterator.next()).toBe('Mentor');
  });

  it('should not leak a message from a blacklisted channel', ({ expect }) => {
    channelIterator.set('Admin');
    expect(channelIterator.next()).toBe('Admin');
  });

  it('should not leak a message from a blacklisted channel', ({ expect }) => {
    channelIterator.set('Dev');
    expect(channelIterator.next()).toBe('Dev');
  });

  it('should not leak a message from a blacklisted channel', ({ expect }) => {
    channelIterator.set('Staff');
    expect(channelIterator.next()).toBe('Staff');
  });

  it('should not leak a message from a blacklisted channel', ({ expect }) => {
    channelIterator.set('Dsay');
    expect(channelIterator.next()).toBe('Dsay');
  });
});
