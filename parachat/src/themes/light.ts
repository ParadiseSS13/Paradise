import { DefaultTheme } from 'styled-components';

const light: DefaultTheme = {
  background: {
    [0]: '#fafafa',
    [1]: '#f5f5f5',
    [2]: '#f0f0f0',
    [3]: '#d9d9d9',
  },
  error: '#ff4d4f',
  errorBg: '#fff1f0',
  textPrimary: 'rgba(0, 0, 0, 0.85)',
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
  .changeling,
  .coderesponses,
  .darkmblue,
  .mentorhelp,
  .revennotice,
  .revenboldnotice,
  .revenbignotice {
    color: #0958d9;
  }

  /* Light red */
  .deadsay {
    color: #ff85c0;
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
  .adminhelp,
  .alert,
  .bad,
  .biggerdanger,
  .clown,
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
  .radio,
  .admin_channel,
  .adminticket,
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

  /* Yellow */
  .adminticketalt {
    color: #fadb14;
  }

  /* Orange */
  .average {
    color: #ad4e00;
  }

  /* Light purple */
  .mentor_channel_admin,
  .sciradio {
    color: #722ed1;
  }

  /* Purple */
  .debug,
  .interface,
  .terrorspider,
  .dantalion,
  .alien,
  .sinister,
  .purple,
  .abductor,
  .cult,
  .deptradio,
  .ghostalert,
  .hierophant,
  .hierophant_warning,
  .mentor_channel,
  .mind_control,
  .revendanger,
  .revenwarning,
  .revenminor,
  .playerreply {
    color: #531dab;
  }
`,
};

export default light;
