# claude-spend

See where your Claude Code and Cowork tokens go. One command, zero setup.

## Problem

I've been using Claude Code every day for 3 months. I hit the usage limit almost daily, but had zero visibility into which prompts were eating my tokens. So I built claude-spend. One command, zero setup.

## How does it look

<img width="1910" height="966" alt="Screenshot 2026-02-18 092727" src="https://github.com/user-attachments/assets/11cc7149-d4dd-4e44-a3a0-0b48e935b7bc" />

<img width="1906" height="966" alt="Screenshot 2026-02-18 093529" src="https://github.com/user-attachments/assets/537c3611-5794-41d2-864e-e368e6949812" />

<img width="1908" height="969" alt="Screenshot 2026-02-18 093647" src="https://github.com/user-attachments/assets/aaaa8ce5-2025-407d-8596-ea1965748691" />

<img width="1908" height="969" alt="Screenshot 2026-02-18 093647" src="https://github.com/user-attachments/assets/a9fde5e2-6e52-4bae-9b96-03655109aef6" />

## Quick Start

```bash
npx claude-spend
```

That's it. Opens a dashboard in your browser at `http://127.0.0.1:3456`.

### Running from source

```bash
git clone https://github.com/kosovans/claude-spend.git
cd claude-spend
npm install
npm start
```

## What it shows

- **Token usage** per conversation, per day, and per model
- **Estimated API cost** — what your usage would cost at Anthropic's published per-token rates (your actual subscription cost may differ)
- **Tool breakdown** — which tools (Read, Edit, Bash, etc.) burn the most tokens
- **Most expensive prompts** — ranked by token cost with per-prompt cost estimates
- **Cache hit rate** — how much you're saving from prompt caching
- **Insights** — patterns like cost spikes mid-conversation, cache savings, and usage trends

## Data Sources

claude-spend automatically finds session data from multiple sources:

| Source | Location | Detected automatically |
|--------|----------|----------------------|
| Claude Code | `~/.claude/projects/` | Yes |
| Cowork (macOS) | `~/Library/Application Support/Claude/…` and `~/Library/Group Containers/…` | Yes |
| Cowork (synced) | `./cowork-data/projects/` next to the project | Yes |
| Custom path | Any directory with a `projects/` subfolder | Via `CLAUDE_SPEND_DATA` env var |

Sessions are deduplicated by ID, so overlapping sources won't double-count.

### Syncing Cowork data

Cowork sessions live inside sandboxed VMs that reset between sessions. To include historical Cowork data in the dashboard, sync the JSONL files to a persistent location using the included script:

```bash
# On macOS — copies Cowork session data into ./cowork-data/
./sync-cowork-macos.sh
```

You can run this manually, or set up a crontab to run it hourly:

```bash
crontab -e
# Add this line (adjust the path to where you cloned the repo):
0 7-23 * * * /path/to/claude-spend/sync-cowork-macos.sh
```

## Options

```
claude-spend --port 8080   # custom port (default: 3456)
claude-spend --no-open     # don't auto-open browser
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `CLAUDE_SPEND_DATA` | Colon-separated list of extra directories to scan (each should contain a `projects/` subfolder) |

## Privacy & Security

- All data stays local. The dashboard binds to `127.0.0.1` only — not accessible from the network.
- No analytics, no tracking, no data sent anywhere.
- Session files are read from your local `~/.claude/` directory (and Cowork containers if present).
- The `cowork-data/` directory is gitignored by default to prevent accidentally committing conversation logs.

## License

MIT
