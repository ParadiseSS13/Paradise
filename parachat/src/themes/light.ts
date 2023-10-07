import { DefaultTheme } from 'styled-components';

const light: DefaultTheme = {
  isDark: 'default',
  background: {
    [0]: '#fafafa',
    [1]: '#f0f0f0',
    [2]: '#d9d9d9',
    [3]: '#bfbfbf',
  },
  success: '#389e0d',
  warning: '#faad14',
  warning2: '#d46b08',
  error: '#ff4d4f',
  errorBg: '#fff1f0',
  textPrimary: 'rgba(0, 0, 0, 0.85)',
  textPrimaryLight: 'rgba(0, 0, 0, 0.85)',
  textSecondary: 'rgba(0, 0, 0, 0.65)',
  textDisabled: 'rgba(0, 0, 0, 0.45)',

  cssTheme: /*css*/ `
  .motd {
    color: #374961;
  }

  .motd h1, .motd h2, .motd h3, .motd h4, .motd h5, .motd h6, .motd a {
    color: #626b3a;
  }

  /* Grey */
  .whisper {
    color: rgba(0, 0, 0, 0.75);
  }

  /* Light blue */
  .boldnotice,
  .notice,
  .info,
  .looc {
    color: #335480;
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
    color: #3647a8;
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
  .codephrases,
  .cultspeech,
  .cultitalic,
  .cultlarge,
  .narsie,
  .narsiesmall,
  .red,
  .redtext {
    color: #b32727;
  }

  /* Green */
  .good,
  .green,
  .greentext,
  .noticealien,
  .alertalien,
  .his_grace {
    color: #226622;
  }

  /* Orange */
  .average,
  .orange {
    color: #8C3E01;
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
    color: #6a4575;
  }

  /* Pink */
  .sinister,
  .dantalion {
    color: #a6507b;
  }

  /* Fauna */
  .colossus { color: #80375e; }
  .hierophant { color: #77458c; }
  .hierophant_warning { color: #77458c; }
  .resonate { color: #466965; }

  /* Deadchat */
  .deadsay { color: #854669; }
  .ghostalert { color: #5c457d; }

  /* Admin and mentor */
  .admin_channel { color: #7800ab; }
  .adminticket { color: #28571f; }
  .adminticketalt { color: #014c8a; }
  .adminhelp { color: #aa0000; }
  .mentor_channel { color: #5743d9; }
  .mentor_channel_admin { color: #7f43d9; }
  .mentorhelp { color: #005994; }
  .playerreply { color: #680094; }

  /* Radio channels */
  .radio        { color: #275906; }
  .deptradio    { color: #993399; }
  .comradio     { color: #204090; }
  .syndradio    { color: #6D3F40; }
  .dsquadradio  { color: #686868; }
  .airadio      { color: #a700b3; }
  .centradio    { color: #5C5C7C; }
  .secradio     { color: #a30000; }
  .engradio     { color: #804800; }
  .medradio     { color: #00686b; }
  .sciradio     { color: #993399; }
  .supradio     { color: #7F6539; }
  .srvradio     { color: #3e5400; }
  .proradio     { color: #bd006b; }

  /* Languages */
  .tajaran			{ color: #803B56; }
  .skrell				{ color: #00535e; }
  .gutter       { color: #536f99; }
  .solcom				{ color: #22228B; }
  .com_srus			{ color: #7c4848; }
  .soghun				{ color: #136616; }
  .changeling   { color: #800080; }
  .vox          { color: #AA00AA; }
  .diona        { color: #804000; }
  .trinary			{ color: #727272; }
  .kidan				{ color: #664205; }
  .slime				{ color: #0077AA; }
  .drask				{ color: #416178; }
  .moth				  { color: #617519; }
  .clown				{ color: #d90007; }
  .vulpkanin    { color: #94593e; }
  .abductor			{ color: #800080; }
  .mind_control { color: #A00D6F; }
`,
};

export default light;
