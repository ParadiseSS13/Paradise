class Tab {
  constructor(name='New Tab', filters) {
    this.name = name;
    this.filters = filters || {
      asay: true,
      msay: true,
      dsay: true,
      pm: true,
      logs: true,
      ooc: true,
      radios: true,
      other: true,
    };
    this.unread = 0;
  }
}

export default Tab;
