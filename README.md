# repman-paynl - PHP Repository Manager (a repman fork with small changes)

We had some problems with file permissions after the docker build and tweaked some things and finally got it working with no error messages.
So I made this repman fork with our changes. It's a bit of a mess (to many commits) because there are many small changes, but in the end we got it working. I hope this will help others to get it working.

### Some of the problems were:
- The logs could not be saved.
- crontab commands were running as root. Where in 2 cases this was the cause and/or causing the a problem. 
- When downloading the packages they were given the file permissions of 'root' so deleting via the web interface was not possible.

Maybe I forgot to mention one that was/is also a problem but the above were the most important.

### We used, installing on a (new) local server, the following commands:
```bash
git clone https://github.com/repman-io/repman.git
cd repman
composer install --ignore-platform-reqs
apt-get install php8.1-xm php8.1-xml
composer install --ignore-platform-reqs
docker-compose up
```

### NOTE
Before a 'docker-compose up' do a chown on 2 directories.
```bash
chown 82:82 ./public ./var
```
This is user 'www-data' on the containers and the UID was diferrent.

### crontab changes
In the end we are using 'yacron' to work through the crontab issues.

------------------------------
[![Minimum PHP Version](https://img.shields.io/badge/php-%3E%3D%207.4-8892BF.svg)](https://php.net/)
[![Uptime Robot ratio (24h)](https://badgen.net/uptime-robot/day/m784813562-93c7dab381e24ccdb679c5d2)](https://stats.uptimerobot.com/QAMQli6XQM)
[![buddy pipeline](https://app.buddy.works/repman/repman/pipelines/pipeline/244546/badge.svg?token=dbd28b3ece0d16aba095b8a33d0893d15f0403fbcc285a2a1a175cc77f7c94a8 "buddy pipeline")](https://app.buddy.works/repman/repman/pipelines/pipeline/244546)
[![codecov](https://codecov.io/gh/repman-io/repman/branch/master/graph/badge.svg)](https://codecov.io/gh/repman-io/repman)
[![Hits-of-Code](https://hitsofcode.com/github/repman-io/repman)](https://hitsofcode.com/view/github/repman-io/repman)
[![Maintainability](https://api.codeclimate.com/v1/badges/23a93132c8273cabf9eb/maintainability)](https://codeclimate.com/github/repman-io/repman/maintainability)
[![Docker Pulls](https://img.shields.io/docker/pulls/buddy/repman)](https://hub.docker.com/r/buddy/repman)
![License](https://img.shields.io/github/license/repman-io/repman)

**Repman** is a PHP repository manager. Main features:

- free and open source
- works as a proxy for **packagist.org** (speeds up your local builds)
- hosts your private packages
- allows to create individual access tokens
- supports private package import from **GitHub**, **GitLab** and **Bitbucket** with one click
- REST API
- security scanner (with e-mail reports)

Documentation: [https://repman.io/docs/](https://repman.io/docs/)

## Requirements

- PHP >= 7.4
- PostgreSQL 11
- `var` dir must be writeable
- any web server

## Installation

### Docker

[https://repman.io/docs/standalone/#docker-installation](https://repman.io/docs/standalone/#docker-installation)

### Ansible

[https://repman.io/docs/standalone/#ansible-playbooks-installation](https://repman.io/docs/standalone/#ansible-playbooks-installation)

### Manual

```bash
git clone git@github.com:repman-io/repman.git
cd repman
composer install
```

Setup database:
```
bin/console doctrine:migrations:migrate #for postgres
bin/console doctrine:schema:create #for sqlite init as migrations are only postgres-compatible
bin/console messenger:setup-transports
```

## Configuration

### Mailer

To configure mailer transport, enter connection details in the `MAILER_DSN` environment variable

```
MAILER_DSN=smtp://user:pass@smtp.example.com
```
Read more: [transport setup](https://symfony.com/doc/current/mailer.html#transport-setup)

In addition, setup also `MAILER_SENDER` environment variable
```
MAILER_SENDER=mail_from@example.com
```

## Workers

To process messages asynchronously you must run worker:

```bash
bin/console messenger:consume async
```

Read more: [deploying to production](https://symfony.com/doc/current/messenger.html#deploying-to-production)

## Usage

Navigate your browser to instance address, you will see home page with usage instructions.

## Local proxy

On dev env you may want to enable proxy to allow to create subdomains and tests composer organizations:

```bash
composer proxy-setup
```

This will create `repman.wip` domain. Then you can add other domains with:

```bash
symfony proxy:domain:attach your-organization.repman
```

### CLI commands

- `bin/console repman:metadata:clear-cache` - clear packages metadata cache (json files)
- `bin/console repman:create:admin <email> [<password>]` - create a new user with admin privileges
- `bin/console repman:create:user <email> [<password>]` - create a new (normal) user
- `bin/console repman:proxy:sync-releases` - sync proxy releases with packagist.org
- `bin/console repman:security:scan-all` - scan all synchronized packages
- `bin/console repman:security:update-db` - update security advisories database, scan all packages if updated
- `bin/console repman:package:synchronize <packageId>` - synchronize given package
- `bin/console repman:package:clear-old-dists` - clear old private dev distributions files

## API Integration

Callbacks:

- `/auth/{provider}/check`
- `/register/{provider}/check`
- `/user/token/{provider}/check`

### GitHub

Scopes:

- registration: `user:email`
- repositories: `read:org`, `repo`

### GitLab

Scopes:

- registration: `read_user`
- repositories: `api`

### Bitbucket

Scopes:

- registration: `email`
- repositories: `repository`, `webhook`

## Self-hosted GitLab

To integrate with self-hosted GitLab, enter the instance url in the `APP_GITLAB_API_URL` environment variable
```
APP_GITLAB_API_URL='https://gitlab.organization.lan'
```

## Docker

- Override with `docker-compose.override.yml` if needed.
- Set your domain (`APP_HOST`) in `.env.docker`.

If you wish to use your own certificate put key and certificate in:

- `docker/nginx/ssl/private/server.key`
- `docker/nginx/ssl/certs/server.crt`

Otherwise self-sign certificate will be generated.

To start all containers run:

```bash
docker-compose up
```

## Support

In case of any problems, you can use:

 - Our documentation: [repman.io/docs](https://repman.io/docs/) - it is also open sourced [github.com/repman-io/repman-docs-pages](https://github.com/repman-io/repman-docs-pages)
 - GitHub issue list: [github.com/repman-io/repman/issues](https://github.com/repman-io/repman/issues) - feel free to create a new issue there
 - E-mail: contact [at] repman.io

## License

The Repman project is licensed under the terms of the [MIT](LICENSE).

However, Repman includes several third-party Open-Source libraries, which are licensed under their own respective Open-Source licenses.

#### Libraries or projects directly included in Repman

 - Tabler:  [MIT](https://github.com/tabler/tabler/blob/master/LICENSE)
 - Feather: [MIT](https://github.com/feathericons/feather/blob/master/LICENSE)
 - Lucide: License: [ISC](https://github.com/lucide-icons/lucide/blob/master/LICENSE)
 - Postmark Transactional Email Templates: [MIT](https://github.com/wildbit/postmark-templates/blob/master/LICENSE)
 - Libraries dynamically referenced via Composer: run `composer license` to get the latest licensing info about all dependencies.

---

made with ❤️ by [Buddy](https://buddy.works)
