# Compose stack

This directory holds the osTicket and MariaDB Compose stack. The application
image is pinned by digest, not by tag. MariaDB is pinned the same way.

## Files

| File | Purpose |
|---|---|
| `docker-compose.yml` | Two services, two networks, one named database volume |
| `.env.example` | Non-secret settings, copied to `.env` |
| `.env` | Local settings, ignored by Git, mode 600 |
| `init-secrets.sh` | Creates the four local secret files once |
| `secrets/` | Local secret files, ignored by Git, mode 600 |
| `php-hardening.ini` | PHP hardening, mounted read-only |
| `php-fpm.conf` | Lower worker count, cleared environment |
| `mariadb.cnf` | Small database tuning, server charset utf8mb4 |

## First start

Run from this directory:

```sh
./init-secrets.sh
sudo -n docker compose config
sudo -n docker compose up -d
sudo -n docker compose ps
```

The login user is not in the `docker` group on this host, so the Docker
commands use `sudo -n`. If your account can use the Docker socket directly,
omit `sudo -n`.

The admin password is in `secrets/admin_password.txt`. Do not print it into
the terminal history, a ticket or the repository. The file is 20 characters
with no trailing newline. It was rotated on 2026-10-21; the old 32-character
value no longer works. Details are in
`../journal/04-login-access-denied.txt` and
`../journal/05-admin-password-rotation.txt`.

Use the agent login, not the top-right client sign-in:

    http://tickets.home.arpa/scp/login.php

The top-right "Sign In" link goes to `/login.php` and is for client portal
users. Staff credentials there return `Access denied`. That was the actual
cause of the login incident; the password rotation was not the fix. The app is
not published on a host port. The existing nginx container reaches it as
`osticket:8080` on the shared `homelab` network and publishes it at
`http://tickets.home.arpa`.

The database is only on the internal `backend` network. It has no published
port and no route to the internet.

## Stop

```sh
sudo -n docker compose down
```

This removes the containers and the backend network and keeps the named
volume. Do not add `-v` unless you intend to delete the database.

## Access

The stack is published by the existing nginx container at
`http://tickets.home.arpa`. The application itself still publishes no host
port. The main PC uses one hosts entry for this name:

    192.168.88.32  tickets.home.arpa

The router does not resolve the new name. Do not replace the main PC resolver
with only `192.168.88.32`; that would break internet and VPN DNS. The Samba A
record remains for clients that already use the DC as their resolver. See
`../README.md` for the client steps.

## Status

Started on 2026-10-21. Both services are healthy. The app is reachable from
the `homelab` network at `osticket:8080` and from the LAN at
`http://tickets.home.arpa`; the application publishes no host port. The
first start failed because osTicket rejects the username `admin`; the local
admin is `homelab-admin`. Details are in `../journal/02-compose-stack.txt`
and `../journal/03-dns-nginx.txt`.

The MariaDB server default is utf8mb4, but the osTicket installer creates the
database and tables as utf8mb3. The upstream schema was not converted.

The app logs a harmless nginx alert about its default error log on the
read-only rootfs. Access logs still go to stdout.
