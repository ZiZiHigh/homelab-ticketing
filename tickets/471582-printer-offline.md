# 471582 — Printer in office 2 is offline

| Field | Value |
|---|---|
| Reported by | Lucie Horakova |
| Channel | Client portal (web form) |
| Priority | Normal |
| Status | Resolved |
| Time to resolve | 35 minutes |

## What the user said

> Hi, the printer in office 2 is not printing again. I sent the document three
> times and nothing came out. The display looks normal to me, it says ready. My
> colleague tried too and she has the same problem, so it is probably the
> printer and not my laptop. I need it for the meeting at 10, can you look at
> it? Thanks.

## What I checked, in order

1. **Scope.** One printer or all of them, one user or the whole office? Two
   people, one device. That already made the laptops and the user accounts
   unlikely.
2. **When it last worked.** Friday afternoon. Nothing changed on the user side
   over the weekend.
3. **The device itself.** Panel said `Ready`, no error, but the network light
   was off. The panel showed `192.168.88.61`.
4. **Reachability.** Pinged `192.168.88.61` from my machine: no reply. Pinged
   the printer by the name in my notes: no reply either. The first ping was
   lost because the device was asleep; the second and third also failed.
5. **The queue.** Four jobs from two users, all stuck in `processing`. Nothing
   had reached the device.
6. **The address.** Checked the DHCP leases: the printer had `192.168.88.61`,
   but the print queue on the server still sent jobs to `192.168.88.54`, the
   address it had before the weekend.
7. **The driver, last.** The queue used a generic PCL driver that had worked
   for months. No reason to touch it, and changing it would have hidden the
   real cause.

## What I found

The printer was healthy. It had received a new address from DHCP after the
weekend, and the queue was configured with the old address. Jobs went to an
address where nothing was listening, stayed in the queue, and the users saw
"printing" forever. From their side that looks exactly like a broken printer.

The first ping also failed because the printer was in sleep mode and took a few
seconds to wake up. One lost ping is not proof of anything.

## How I fixed it

1. Cleared the four stuck jobs, so the queue would not replay old documents
   once it worked again.
2. Changed the queue to use the printer hostname instead of a raw address, then
   pointed it at the current address.
3. Asked the network owner for a DHCP reservation for the printer, so it keeps
   one address. That is the actual fix; the rest is cleanup.
4. Printed a test page from the print server, then from the user's laptop.
5. Asked the user to print the meeting document and confirmed it came out, then
   closed the ticket with a note about the reservation.

## What I would do differently next time

- Ask "does it affect everyone or only you" before anything else. It took two
  minutes and removed half of the possible causes.
- Check the queue and the address before the driver. The driver is the usual
  suspect and rarely the cause.
- Use hostnames for printers, not addresses. A lease that expires quietly
  breaks every queue configured by IP.
- Write the printer model, queue name and address into the ticket. The next
  person should not have to rediscover them.
