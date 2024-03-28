//Time until ticket becomes stale if unanswered. Alerts admins.
#define TICKET_TIMEOUT (10 MINUTES)
//Time before the user is allowed to open another ticket while their existing one is open.
#define TICKET_DUPLICATE_COOLDOWN (5 MINUTES)

//Status defines
#define TICKET_OPEN       1
#define TICKET_CLOSED     2
#define TICKET_RESOLVED   3
#define TICKET_STALE      4
