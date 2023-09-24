import { DefaultTheme } from 'styled-components';

const dark: DefaultTheme = {
  isDark: 'dark',
  background: {
    [0]: '#141414',
    [1]: '#1f1f1f',
    [2]: '#262626',
    [3]: '#434343',
  },
  success: '#3c8618',
  warning: '#aa9514',
  warning2: '#aa6215',
  error: '#a61d24',
  errorBg: '#2a1215',
  textPrimary: 'rgba(255, 255, 255, 0.85)',
  textPrimaryLight: 'rgba(255, 255, 255, 0.85)',
  textSecondary: 'rgba(255, 255, 255, 0.65)',
  textDisabled: 'rgba(255, 255, 255, 0.45)',

  cssTheme: /*css*/ `
  .motd {
    color: #b6ddfa;
  }

  .motd h1, .motd h2, .motd h3, .motd h4, .motd h5, .motd h6, .motd a {
    color: #b0b876;
  }

  /* Grey */
  .whisper {
    color: rgba(255, 255, 255, 0.75);
  }

  /* Light blue */
  .boldnotice,
  .notice,
  .info,
  .looc {
    color: #6699cc;
  }

  /* Blue */
  .boldnotice,
  .specialnotice,
  .pmsend,
  .all_admin_ping,
  .bluetext,
  .coderesponses,
  .darkmblue,
  .revennotice,
  .revenboldnotice,
  .revenbignotice,
  .admin {
    color: #6685f5;
  }

  /* Red */
  .boldwarning,
  .warning,
  .biggerdanger,
  .danger,
  .userdanger,
  .pr_announce,
  .boldannounce,
  .moderate,
  .disarm,
  .suicide,
  .rose,
  .cultspeech,
  .cultitalic,
  .cultlarge,
  .narsie,
  .narsiesmall,
  .red,
  .redtext {
    color: #ff5d52;
  }

  /* Green */
  .good,
  .green,
  .greentext,
  .noticealien,
  .alertalien,
  .his_grace {
    color: #54b34d;
  }

  /* Orange */
  .average,
  .orange {
    color: #d97818;
  }

  /* Purple */
  .debug,
  .interface,
  .purple,
  .alien,
  .terrorspider,
  .cult,
  .revenminor,
  .revenwarning,
  .revendanger {
    color: #b886c2;
  }

  /* Pink */
  .sinister,
  .dantalion {
    color: #cc6c99;
  }

  /* Fauna */
  .colossus { color: #e69591; }
  .hierophant { color: #eda3ff; }
  .hierophant_warning { color: #eda3ff; }
  .resonate { color: #8bb5ad; }

  /* Deadchat */
  .deadsay { color: #f8a8cc; }
  .ghostalert { color: #cda8f0; }

  /* Admin and mentor */
  .admin_channel { color: #00d68b; }
  .adminticket { color: #81c967; }
  .adminticketalt { color: #d9cc6f; }
  .adminhelp { color: #f89f9a; }
  .mentor_channel { color: #c0adff; }
  .mentor_channel_admin { color: #d6adff; }
  .mentorhelp { color: #a8c1f8; }
  .playerreply { color: #e298ed; }

  /* Radio channels */
  .radio        { color: #40c957; }
  .deptradio    { color: #ffa3f3; }
  .comradio     { color: #b7adff; }
  .syndradio    { color: #d9aba7; }
  .dsquadradio  { color: #ccb6c9; }
  .airadio      { color: #ffbfe9; }
  .centradio    { color: #91c1cc; }
  .secradio     { color: #ff917a; }
  .engradio     { color: #ffe49c; }
  .medradio     { color: #69dbca; }
  .sciradio     { color: #e0a3ff; }
  .supradio     { color: #deb76a; }
  .srvradio     { color: #eaf777; }
  .proradio     { color: #eb96c0; }

  /* Languages */
  .tajaran			{ color: #e6aab9; }
  .skrell				{ color: #a3fff4; }
  .gutter       { color: #97c1e6; }
  .solcom				{ color: #bdc6ff; }
  .com_srus			{ color: #f2a49b; }
  .soghun				{ color: #abbfa8; }
  .changeling   { color: #26cdeb; }
  .vox          { color: #e693da; }
  .diona        { color: #d9ac68; }
  .trinary			{ color: #b3b3b3; }
  .kidan				{ color: #edaf79; }
  .slime				{ color: #64bbd1; }
  .drask				{ color: #a3d4eb; }
  .moth				  { color: #bec28f; }
  .clown				{ color: #ff887a; }
  .vulpkanin    { color: #e0b999; }
  .abductor			{ color: #ffa3f3; }
  .mind_control { color: #d498b8; }
`,
};

export default dark;
