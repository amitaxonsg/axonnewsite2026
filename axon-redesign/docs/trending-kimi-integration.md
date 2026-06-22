# Trending and Kimi Integration Notes

Purpose: keep Axon positioned as a Technology & AI Advisor while using AI to summarize relevant business technology updates for owners and decision makers.

## Safe API Key Handling

- Do not place the Kimi API key in `app.js`, HTML, or any public frontend file.
- Store the key server-side as an environment variable, for example `KIMI_API_KEY`.
- Use the same server-side key for the future Contact page Axon AI Agent button through a backend endpoint such as `/api/axon-agent`.
- Browser code should call Axon's backend only. The backend calls Kimi.

## Recommended Daily Trending Flow

1. A scheduled server job fetches approved RSS/news/source links.
2. The job extracts only metadata and a short excerpt: title, URL, source, date, category and brief snippet.
3. The job sends that limited input to Kimi with an instruction to produce:
   - What Happened
   - Why It Matters
   - Who Should Care
   - tags
   - estimated reading time
4. The job writes the final approved output to `assets/data/trending.json`.
5. The static website reads `assets/data/trending.json` and renders the cards.

## Important Content Rule

Do not republish full article text. The website should show Axon's short executive summary and link to the original source.

## Suggested Source Categories

- AI and business automation
- Google Workspace updates
- Microsoft 365 updates
- cybersecurity advisories
- cloud and hosting operations
- websites, analytics and SEO
- Singapore and Asia SME technology adoption

## Contact Page AI Agent

For the contact page AI Agent button, use the same safety pattern:

- frontend button opens chat UI
- frontend sends the visitor message to Axon's backend
- backend adds Axon's approved system prompt and calls Kimi with `KIMI_API_KEY`
- backend returns only the answer text to the browser

This protects the API key and lets Axon control tone, scope and escalation rules.
