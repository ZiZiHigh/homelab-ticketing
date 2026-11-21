# Troubleshooting guide

For whoever takes this queue after me. This is not a textbook and it is not
complete. It is the short version I wish someone had handed me on day one: what
to ask, what to check, and what to say while you are checking it.

Everything here assumes you have the ticket open and you are writing in it as
you go. If it is not in the ticket, it did not happen.

## The first sixty seconds

Do not touch anything yet. Ask these five things and write the answers down:

1. **What exactly is not working?** One thing, in their words.
2. **What does the screen say?** Ask for a photo or a screenshot. Users
   paraphrase error messages, and the paraphrase is usually wrong.
3. **Is it only you, or is it everyone?** This one question removes half of the
   possible causes.
4. **When did it last work, and what changed since?** New laptop, new desk, new
   update, new password, back from holiday.
5. **Where are you?** Office, home, VPN, cable, Wi-Fi. The same problem has
   different causes in each place.

Then repeat the problem back in one sentence: "So the printer in office 2 does
not print for you or your colleague, since Friday, and nothing changed on your
side. Correct?" If they say yes, you have the ticket. If they correct you, you
just saved yourself an hour.

Finally, say when you will come back: "I will look at it now and message you
within 30 minutes, even if I do not have the answer yet." Then do it.

## The four questions behind every ticket

| Question | What it tells you |
|---|---|
| One user or everyone? | Account or device problem versus server, network or service |
| Did it ever work? What changed? | Most outages are a change: update, move, password, cable, config |
| Does it fail everywhere or only here? | Which layer: device, local network, VPN, service |
| What is the exact message? | The difference between "wrong password" and "expired password" |

When you are stuck, go back to these four. Not to more commands.

## When the user says "I cannot log in"

**Check, in this order:**

1. **Where** does the error appear? Windows login, webmail, the VPN client,
   the ticket portal. They are four different systems.
2. **The exact message.** "Incorrect password", "account locked", "password
   expired", "cannot contact the domain" are four different tickets.
3. **The account** in AD: locked, expired, disabled, or fine. Check the last bad
   password time and where it came from.
4. **Caps Lock, keyboard layout, and the domain.** A laptop on a Czech layout
   with an English password looks like a wrong password.
5. **At home:** the VPN has to be up before the domain controller is reachable.
   Cached credentials cover the gap until the password expires.
6. **The phone.** A mail app with the old password will lock the account again
   five minutes after you unlock it.

**Then:**

- Verify identity before any reset. Call back on the number in the directory,
  never the number in the ticket. No reset over email or chat.
- Unlock and reset together, force a change at next logon.
- Remove the old password from the phone, then add the account back.
- Have the user connect the VPN, lock and unlock, and try again.
- Confirm the login *and* the thing they actually needed (mail, the meeting
  link), not just the login screen.

**Say:** "I am going to unlock the account and give you a temporary password.
Before you try it, please remove the work account from your phone mail, because
that is what keeps locking it."

## When the user says "the printer does not print"

**Check, in this order:**

1. **Scope.** One printer or all, one user or the whole office.
2. **The panel.** Ready, paper, toner, error code. A printer with an error still
   accepts jobs and shows nothing on the PC.
3. **The queue.** Are jobs stuck in `processing`? Then they never reached the
   device.
4. **The address.** Ping the printer. If the queue points at an old DHCP
   address, everything looks broken while the printer is fine.
5. **The driver, last.** Only after the queue, the address and a test page from
   the server work.

**Then:**

- Clear the stuck jobs before you fix the port, or the queue replays old
  documents.
- Use the hostname in the queue, not the IP.
- Ask for a DHCP reservation so it does not happen again next month.
- Print a test page from the server and from the user's machine, then have the
  user print the real document.

**Say:** "The printer itself is fine, it just moved to a different address and
your queue is still sending to the old one. I will fix the queue and make sure
it keeps the same address."

## When the user says "everything is slow"

Slow is a symptom, not a cause. Split it before you believe it.

**Check, in this order:**

1. **Scope.** One user or everyone. Compare with the person at the next desk.
2. **Ping the gateway.** 1–3 ms and no loss means the local link is fine.
3. **Ping a public address by IP** (`1.1.1.1`). If that is fast, the internet
   path is fine too.
4. **Ping by name.** If names are slow while addresses are fast, it is DNS.
5. **`ipconfig /all`.** Which DNS servers are in use? A disconnected VPN often
   leaves its resolver behind, and every lookup waits for a timeout.
6. **Link speed and Wi-Fi.** `Get-NetAdapter` or the Wi-Fi panel: 100 Mb/s
   instead of 1 Gb/s, weak signal, high retries.
7. **Only then** the server: disk, CPU, backups running in working hours.

**Then:**

- Flush DNS and set the adapter back to automatic DNS if a stale VPN resolver
  is there.
- If it is the link, try another cable and another switch port before blaming
  the server.
- Measure again after the fix and put both numbers in the ticket.

**Say:** "Your connection is fine, but every name lookup is waiting on a DNS
server that is no longer there. That is why pages and files feel slow while
everything else looks normal."

## When the user says "I cannot open the shared folder"

**Check:**

1. Can they log in at all? A locked account cannot map a drive.
2. Ping the file server by name, then by IP. Name fails, IP works: DNS.
3. Is the drive mapped, or did it disappear after a restart? `net use`.
4. Share permission versus NTFS permission. The stricter one wins.
5. Did the user change teams or get a new laptop? Group membership.
6. Time skew. Kerberos does not tolerate a clock that is minutes off.

**Then:** re-map with the hostname, check group membership, and test with a
second account before you touch permissions.

## When the user says "my email does not work"

**Check:** webmail or the mail client? Can they send, receive, or both? Is the
mailbox full? Is the password current, and is the phone locking the account?
Is it one user or the whole domain?

**Then:** test webmail first. If webmail works, the problem is the client
profile or the password stored in it, not the mail server.

## When the user says "the VPN keeps dropping"

**Check:** home internet stable without the VPN? Wired or Wi-Fi? Does it drop
on a timer (idle timeout, DHCP lease) or under load? Same client version as the
others? Does the log show a reconnect reason?

**Then:** test from a phone hotspot to separate the home line from the VPN.
Collect the client log before reinstalling anything.

## When the user says "the website is down"

**Check:** one site or all sites? Does it fail by name and by IP? Is it only
inside the LAN? Is the certificate warning the actual problem? Check the
service and the proxy logs, not the user's browser first.

## Commands, Windows and Linux side by side

| Task | Windows | Linux |
|---|---|---|
| Addresses | `ipconfig /all` | `ip a`, `ip r` |
| Flush DNS | `ipconfig /flushdns` | `resolvectl flush-caches` |
| Name lookup | `nslookup name`, `Resolve-DnsName` | `dig name`, `getent hosts name` |
| Reachability | `ping -t host` | `ping host` |
| Path | `tracert host` | `traceroute host` |
| Listening ports | `netstat -ano`, `Get-NetTCPConnection` | `ss -tulpn` |
| Mapped drives | `net use` | `mount`, `findmnt` |
| Account | `Get-ADUser -Identity name -Properties LockedOut` | `passwd -S name`, `chage -l name` |
| Service | `Get-Service name` | `systemctl status name` |
| Logs | Event Viewer | `journalctl -u name -n 50` |
| Group policy | `gpupdate /force`, `gpresult /r` | not applicable |

## Reading the evidence

- **Ping by IP works, by name does not:** DNS. Stop looking at the cable.
- **Ping fails everywhere, even the gateway:** local link, Wi-Fi, adapter, or
  the device is asleep.
- **Traceroute stops at hop 2:** the local network or the provider, not the
  website.
- **Traceroute shows long reverse lookups:** that is DNS again, not packet loss.
- **Everything is slow only for one user:** their device, their DNS, their
  Wi-Fi. Compare with a colleague before touching the server.
- **It worked yesterday:** find the change. There is almost always one.

## When to escalate

Escalate when you are missing rights, missing knowledge, the outage affects
more people than you can handle, or the user is angry and you are not calming
it down. That is not failure, it is the process.

Include in the escalation:

- the ticket number and one-sentence summary;
- what the user sees, with the exact message;
- what you checked and what the result was;
- what you already tried and what changed;
- what you think it is, and what you need from the other team.

## Writing the note

Every ticket gets the same five lines. The next person should be able to pick it
up without calling you.

```text
Symptom:   what the user reported, in one sentence
Checked:   the commands and what they returned
Cause:     what was actually wrong
Fix:       what I changed, and how to undo it
Verified:  what I tested with the user, and when
```

If you changed a config, write the old value too. "Changed DNS to automatic
(DHCP)" is not enough if nobody knows what it was before.

## Handover rules

- A closed ticket must be readable by someone who was not there.
- Never leave a ticket assigned to yourself if you are off for more than a day.
- If you promise a callback, put the time in the ticket.
- If you are unsure, say so in the ticket. A wrong guess written down is easier
  to correct than a wrong guess in your head.
- Do not close a ticket until the user confirms the thing works. "Should work
  now" is not confirmation.

## Things that will get you in trouble

- Asking for a password, or accepting one the user offers. You never need it.
- Resetting a password without verifying who you are talking to.
- Remoting into a machine without telling the user, or while they are working
  on something.
- Deleting logs, mail or files "to clean up" before anyone looked at them.
- Blaming the user in the ticket, even when it was the user.
- Promising a fix time you cannot keep. Promise a callback instead.

## One last thing

The user does not care how much you know. They care that someone answered, that
the answer was in plain language, and that it happened when you said it would.
That is most of the job. The rest is practice.
