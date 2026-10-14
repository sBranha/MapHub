# MapHub

Official World of Warcraft addon. Current published version: **v0.3.9**.

- Addon information and download counter: https://gearhunter.net/
- Downloadable releases: https://github.com/sBranha/MapHub/releases
- Source files: `MapHub/`
- Published ZIP: `MapHub-vX.Y.Z.zip`

## Automated publishing

This repository is wired for automated GitHub Releases using **GitHub Actions**, following the project's David-style distribution process.

When a complete new addon build is committed to `MapHub/` with an increased `## Version:` in `MapHub.toc`, the publish workflow:
1. Validates the addon directory and TOC version.
2. Builds an installable ZIP containing the correct addon folder.
3. Generates a SHA-256 checksum.
4. Publishes the release as `vX.Y.Z` on GitHub.

No GitHub Desktop and no manual release asset upload are required. The website detects published GitHub releases, records website download clicks in SQLite, and redirects the user to the GitHub-hosted ZIP. GitHub's own asset download counters are reported separately.

**Important:** A version already published cannot be republished under the same tag by the workflow. Increase the TOC version for every new release. The source repository is not the public website: do not commit website administration code, SQLite data, passwords, setup keys, or credentials.

The optional Windows Companion and in-game GearHubBridge supply update notifications and opt-in usage reporting. The addon itself works independently of them.


### WoW Retail 12.1.5 update

MapHub v0.3.9 supports interface 120105 and includes **Support & Website** in the main /maphub screen, `/mhsupport`, and the updated map filters with a Show All Locations reset. The addon remains free and doesn't make HTTP requests inside WoW.
