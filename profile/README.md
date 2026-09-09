<h1 align="center">Altric</h1>

<p align="center">
  <strong>Post everywhere. Once.</strong><br>
  Social media scheduling built for Nigeria, priced in naira.
</p>

<p align="center">
  <a href="https://altric.co">altric.co</a>
</p>

---

Posting to five apps every morning is a job. Altric does it while you sleep.

Upload once and publish everywhere — Instagram, Facebook, and more as each is
tested — with a caption written for each platform rather than the same text
pasted five times. Built in Lagos, for creators, small businesses, and
multi-branch teams who are running the whole thing from a phone.

### What we're building with

`TypeScript` · `Next.js` · `NestJS` · `Postgres` · `Redis` · `Temporal` ·
`Prisma` · `Tailwind` · `k3s` · `Flux`

Everything runs on a k3s cluster reconciled by Flux from a GitOps repo — a push
to trunk is the deploy, and no one touches the server by hand.

### Repositories

| | |
|---|---|
| **altric** | The product. NestJS + Next.js in a pnpm monorepo. A fork of [Postiz](https://github.com/gitroomhq/postiz-app), AGPL-3.0. |
| **homepage** | altric.co — the marketing site. |
| **altric-infra** | Cluster state. Flux reconciles it onto k3s; the repo is the source of truth, not the server. |

Most are private while we get to launch.

### Where things are

- **The product** — [app.altric.co](https://app.altric.co)
- **The pitch** — [altric.co](https://altric.co)
- **Security** — found something? Report it privately through the Security tab
  of the repository it affects, never in a public issue.

<p align="center">
  <sub>Built in Lagos 🇳🇬</sub>
</p>
