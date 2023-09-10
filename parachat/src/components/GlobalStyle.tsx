import { createGlobalStyle } from 'styled-components';

const GlobalStyle = createGlobalStyle`
  body {
    color: ${({ theme }) => theme.textPrimary};
    background-color: ${({ theme }) => theme.background[0]};
    margin: 0;
    font-family: ${({ theme }) => theme.font};
    font-size: 12px;

    scrollbar-base-color: #323232;
    scrollbar-face-color: #202020;
    scrollbar-3dlight-color: #323232;
    scrollbar-highlight-color: #323232;
    scrollbar-track-color: #323232;
    scrollbar-arrow-color: #fff;
    scrollbar-shadow-color: #323232;
  }

  a {
    color: ${({ theme }) => theme.accent[6]};
  }

  .bold, .prefix, .danger, .admin, .boldannounce, .boldnotice, .ooc, .pr_announce, .name, .sinister, .adminhelp, .admin_channel, .adminticket, .adminticketalt, .alertalien, .boldwarning, .cult, .emote, .ghostalert, .hierophant, .looc, .mentor_channel, .mentor_channel_admin, .mentorhelp, .mind_control, .narsie, .revenboldnotice, .bolditalics, .playerreply {
    font-weight: bold;
  }

  .italics, .suicide, .whisper, .sinister, .abductor, .boldwarning, .cult, .cultspeech, .cultitalic, .ghostalert, .hierophant, .hierophant_warning, .his_grace, .mind_control, .revenwarning, .bolditalics {
    font-style: italic;
  }

  .center, .memo, .memoedit {
    text-align: center;
  }

  .userdanger, .specialnotice, .all_admin_ping, .cultlarge, .revenbignotice, .revendanger {
    font-weight: bold;
    font-size: 120%;
  }

  .narsie {
    font-size: 300%;
  }

  .memoedit {
    font-size: 75%;
  }

  .mind_control {
    font-size: 3;
  }

  .big, .redtext, .biggerdanger, .greentext {
    font-size: 150%;
  }

  .reallybig, .colossus {
    font-size: 175%;
  }

  .robot {
    font-family: 'PxPlus IBM MDA', monospace;
    font-size: 1.15em;
  }

  .sans {
    font-family: 'Comic Sans MS', cursive, sans-serif;
  }

  .wingdings {
    font-family: Wingdings, Webdings;
  }

  .his_grace {
    font-family: "Courier New", cursive, sans-serif;
  }

  .box {
    padding: 1em;
    background-color: ${({ theme }) => theme.background[0]};
    border-left: 4px solid ${({ theme }) => theme.accent[4]};
    border-radius: 2px;
    margin-right: 9px;
  }

  img.icon {
    width: 16px;
    height: 16px;
    vertical-align: middle;
  }
`;

export default GlobalStyle;
