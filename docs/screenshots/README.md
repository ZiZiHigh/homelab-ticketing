# Screenshots

Taken from the running stack on 2026-11-12, agent view, 1920x1080. Nothing is
mocked up: these are the real pages served by the container through nginx.

The ticket data is synthetic. The user names, addresses, subjects and messages
were created for this repository so the queue is not empty. No real employee
data, no password, no session token and no secret is visible in any image.

| File | What it shows |
|---|---|
| `osTicketDashboard.png` | Ticket activity for the last month, and the department statistics with opened, overdue, closed and response time |
| `osTicketTickets.png` | The open queue: eight tickets with priority, source and assignment |
| `osTicketUsers.png` | User directory with the guest accounts that the public ticket form created |

What the screenshots back up:

- the agent panel answers on `http://tickets.home.arpa` through the existing
  nginx container, not on a host port of the application;
- a ticket submitted through the public form reaches the same queue an agent
  works in, and the help topic decides the priority (access issues are high);
- the dashboard reads from the MariaDB instance, so the two containers really
  are connected, not just started.

Not visible here: e-mail, LDAP and the cron worker. None of them are part of
this deployment yet.
