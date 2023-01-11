import { css } from 'styled-components';

const dark = {
  colors: {
    bg: {
      [0]: '#141414',
      [1]: '#1f1f1f',
      [2]: '#262626',
      [3]: '#434343',
    },
    fg: {
      [0]: '#d9d9d9',
      [1]: '#bfbfbf',
      [2]: '#8c8c8c',
      [3]: '#595959',
    },
    bgError: '#2a1215',
    fgError: '#d32029',
  },
};

dark.cssTheme = css`
  /* Grey */
  .whisper {
    color: #bfbfbf;
  }

  /* Light blue */
  .notice,
  .info,
  .looc {
    color: #bae0ff;
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
    color: #4096ff;
  }

  /* Light red */
  .deadsay {
    color: #ffd6e7;
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
    color: #d32029;
  }

  /* Dark red */
  .colossus {
    color: #791a1f;
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
    color: #73d13d;
  }

  /* Dark green */
  .motd,
  .good,
  .memo {
    color: #3c8616;
  }

  /* Teal */
  .resonate {
    color: #138585;
  }

  /* Yellow */
  .adminticketalt {
    color: #d8db14;
  }

  /* Orange */
  .average {
    color: #fa8c16;
  }

  /* Light purple */
  .mentor_channel_admin,
  .sciradio {
    color: #b37feb;
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
    color: #9254de;
  }
`;

export default dark;
