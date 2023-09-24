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
  textPrimaryLight: 'rgba(255, 255, 255, 0.85)',
  textSecondary: 'rgba(0, 0, 0, 0.65)',
  textDisabled: 'rgba(0, 0, 0, 0.45)',

  cssTheme: /*css*/ `
  /* Grey */
  .whisper {
    color: #8c8c8c;
  }

  /* Light blue */
  .notice,
  .info,
  .looc {
    color: #69b1ff;
  }

  /* Blue */
  .admin,
  .boldannounce,
  .boldnotice,
  .specialnotice,
  .pmsend,
  .all_admin_ping,
  .bluetext,
  .coderesponses,
  .darkmblue,
  .revennotice,
  .revenboldnotice,
  .revenbignotice {
    color: #0958d9;
  }

  /* Red */
  .warning,
  .danger,
  .userdanger,
  .moderate,
  .suicide,
  .rose,
  .pr_announce,
  .red,
  .redtext,
  .alert,
  .bad,
  .biggerdanger,
  .codephrases,
  .cultspeech,
  .cultitalic,
  .cultlarge,
  .disarm,
  .moderate,
  .narsie {
    color: #ff4d4f;
  }

  /* Dark red */
  .colossus {
    color: #cf1322;
  }

  /* Green */
  .green,
  .alertalien,
  .green,
  .greenannounce,
  .greentext,
  .his_grace,
  .noticealien {
    color: #237804;
  }

  /* Dark green */
  .motd,
  .good,
  .memo {
    color: #135200;
  }

  /* Teal */
  .resonate {
    color: #13c2c2;
  }

  /* Orange */
  .average {
    color: #ad4e00;
  }

  /* Purple */
  .debug,
  .interface,
  .terrorspider,
  .dantalion,
  .alien,
  .sinister,
  .purple,
  .cult,
  .ghostalert,
  .hierophant,
  .hierophant_warning,
  .mind_control,
  .revendanger,
  .revenwarning,
  .revenminor,
  .playerreply {
    color: #531dab;
  }

  /* Admin and mentor */
  .admin_channel        { color: #9a04d1; }
  .adminticket          { color: #3e7336; }
  .adminticketalt       { color: #014c8a; }
  .adminhelp            { color: #950505; }
  .mentor_channel       { color: #6a52dd; }
  .mentor_channel_admin { color: #8f53dd; }
  .mentorhelp           { color: #056aa4; }

  /* Radio channels */
  .deadsay      { color: #9276b3; }
  .radio        { color: #086323; }
  .deptradio    { color: #49124d; }
  .comradio     { color: #2e35b3; }
  .syndradio    { color: #421c1f; }
  .dsquadradio  { color: #4b3b4d; }
  .airadio      { color: #b3309b; }
  .centradio    { color: #0c3e59; }
  .secradio     { color: #91141d; }
  .engradio     { color: #b36705; }
  .medradio     { color: #006769; }
  .sciradio     { color: #7b50ad; }
  .supradio     { color: #6b451e; }
  .srvradio     { color: #6f8532; }
  .proradio     { color: #6b2356; }

  /* Languages */
  .tajaran			{ color: #59253b; }
  .skrell				{ color: #00a2ab; }
  .solcom				{ color: #6763d4; }
  .com_srus			{ color: #572e2f; }
  .soghun				{ color: #136616; }
  .changeling   { color: #0090b8; }
  .vox          { color: #800085; }
  .diona        { color: #592a00; }
  .trinary			{ color: #4d4d4d; }
  .kidan				{ color: #a13600; }
  .slime				{ color: #005885; }
  .drask				{ color: #7eacc4; }
  .moth				  { color: #617519; }
  .clown				{ color: #d90007; }
  .vulpkanin    { color: #94593e; }
  .abductor			{ color: #560059; }
  .mind_control { color: #7a0457; }
`,
};

export default light;
