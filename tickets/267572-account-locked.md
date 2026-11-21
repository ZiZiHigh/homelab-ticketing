# 267572 — Password expired, change page returns an error

| Field | Value |
|---|---|
| Reported by | Tomas Benes |
| Channel | Client portal (web form) |
| Priority | High |
| Status | Resolved |
| Time to resolve | 45 minutes |

## What the user said

> I cannot log in to my computer this morning. It says my password is incorrect
> but I am typing the same one as always. I tried three or four times. I am
> working from home today, so maybe that is the problem? I have a meeting at 9
> and I need my mail. Please help.

## What I checked, in order

1. **Where exactly.** Windows login, the VPN client, webmail, or the ticket
   portal? Answer: the Windows login on the work laptop, at home, before the
   VPN is connected.
2. **The exact message.** Asked for a photo of the screen. It said "The user
   name or password is incorrect", not "Your password has expired". That
   difference decided the next step.
3. **The account.** In AD: locked out, password last set 89 days ago (policy is
   90 days), last bad password this morning at 07:58.
4. **The source of the bad passwords.** The failed attempts did not come from
   the laptop. They came from the user's phone, where the mail app still had the
   old password and retried every few minutes. Every retry kept the account
   locked again.
5. **The clock.** Checked the laptop time: correct. Kerberos rejects a skew of
   more than a few minutes, but that was not the cause here.
6. **The VPN order.** The laptop needs the VPN to reach the domain controller,
   and the VPN needs the user to log in first. At home Windows used cached
   credentials, so the expired password could not be refreshed and the message
   stayed generic.

## What I found

Two problems stacked on top of each other. The password had expired, and the
phone mail client kept trying the old one, which locked the account. At home the
laptop could not talk to the domain controller before the VPN was up, so Windows
reported "incorrect password" instead of "expired".

Resetting the password alone would have failed again within minutes, because the
phone would have locked the new account too.

## How I fixed it

1. **Verified identity first.** Called the user back on the number in the
   directory, not the number written in the ticket. No password reset based on
   an email or a chat message, ever.
2. Unlocked the account and set a temporary password with a forced change at
   next logon.
3. Told the user to remove the account from the phone mail app before trying
   again, then add it back with the new password. That is what stopped the
   lockout from repeating.
4. Had the user connect the VPN, then lock and unlock the laptop so Windows
   refreshed the cached credentials.
5. Confirmed the login, the mail and the meeting link. The user changed the
   password at first logon and the ticket was closed.

## What I would do differently next time

- Ask where the error appears before checking anything. "Windows login, at
  home" already pointed at cached credentials or the account, not at the VPN.
- Ask for the exact message. "Incorrect password" and "password expired" lead
  to different checks.
- Ask about the phone early. Most lockouts I have seen came from a mail client
  with an old password.
- Write the identity check into the ticket. If someone audits the reset later,
  "verified by callback to the directory number" is the line that matters.
