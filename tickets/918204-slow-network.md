# 918204 — Everything is slow today

| Field | Value |
|---|---|
| Reported by | Eliska Markova |
| Channel | Client portal (web form) |
| Priority | Normal |
| Status | Resolved |
| Time to resolve | 30 minutes |

## What the user said

> Hi, the internet is really slow today. Everything takes forever, opening
> files, the web, even my mail. Is the server down? My colleague next to me says
> it is fine for him. I restarted my laptop but it did not help. Can you check?

## What I checked, in order

1. **Scope.** One laptop or the whole office? One user. The colleague at the
   next desk, on the same switch, was fine. So the server, the uplink and the
   office network were probably not the problem.
2. **Local or remote.** Pinged the gateway: 2 ms, no loss. Pinged `1.1.1.1` by
   address: 24 ms, no loss. The Wi-Fi link and the internet path were healthy.
3. **Address versus name.** Pinged a host by name: four to five seconds before
   the first reply, sometimes a timeout. That is not bandwidth, that is name
   resolution.
4. **The DNS servers in use.** `ipconfig /all` showed `10.8.0.1` first, the VPN
   resolver, and the local resolver second. The VPN had been disconnected at
   08:10, but the adapter kept its DNS setting.
5. **The resolver itself.** `nslookup fileserver.home.arpa 10.8.0.1` timed out.
   The same query against the local resolver answered immediately.
6. **Traceroute.** `tracert` by address showed normal hops, but the reverse
   lookups for each hop hung for seconds, which made the output look like packet
   loss. It was the same DNS timeout, not the network.

## What I found

The laptop was sending every DNS query to a VPN resolver that no longer
existed, waiting for the timeout, and only then asking the local resolver. Web
pages, file shares and mail all looked slow, while anything addressed by IP was
fast. The restart did not help because the stale DNS setting survived it.

This is the classic shape: latency is fine, names are slow.

## How I fixed it

1. `ipconfig /flushdns` to drop the cached timeouts.
2. Set the adapter back to automatic DNS (DHCP), which removed the leftover
   `10.8.0.1`. Reconnecting the VPN properly does the same thing, but doing it
   by hand made the state explicit.
3. Verified in order: ping by address, ping by name, `nslookup` for an internal
   and an external name, then opened a file on the share.
4. Asked the user to open the same document and her mail, and confirmed it felt
   normal again. Closed the ticket with the cause and the two commands.

## What I would do differently next time

- Ping by address first, then by name. It separates "the link is slow" from
  "the lookup is slow" in under a minute.
- Check `ipconfig /all` after any VPN session. The client can leave DNS behind
  even when it says it is disconnected.
- Measure before and after, and put the numbers in the ticket. "2 ms to the
  gateway, 4 s to resolve a name" is a much stronger note than "it was DNS".
- Do not start with a reboot. The user had already tried it, and it could not
  have fixed a setting that persists.
