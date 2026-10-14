# Passage Data — cited environmental limits (MCP server)

A remote MCP server and HTTP API for **numeric environmental limits read from the regulations themselves**: effluent
and discharge limits, surface-water and groundwater quality criteria, drinking-water standards, soil and groundwater
screening values, ambient-air guidelines and emission limits, for the US (federal rules and the states), Canada
(federal, every province and territory), Germany, France, Italy and the EU. It also reports the status a species holds
under the species-at-risk registers it holds.

**Every row is cited**: instrument, edition, section or page, the quoted text, and the source file's URL and sha256.
When nothing is held, the answer is a coded refusal naming every instrument searched, never an empty list.

- MCP endpoint: `https://passage-data.com/mcp` (Streamable HTTP, no key)
- HTTP API: `https://passage-data.com/api/v1/` (JSON, no key; GET, and POST for a table or a list)
- Full reference for agents: [passage-data.com/llms.txt](https://passage-data.com/llms.txt) ·
  [OpenAPI 3.1](https://passage-data.com/openapi.json)
- Registry name: `io.github.kedu21-beep/passage-data`

## Connect

**Claude Code**

```bash
claude mcp add --transport http passage-data https://passage-data.com/mcp
```

**Claude (web or desktop), ChatGPT (developer mode), and other clients:** add a custom connector or remote MCP server
with the URL `https://passage-data.com/mcp`. No key or sign-in.

**Cursor** (`mcp.json`):

```json
{ "mcpServers": { "passage-data": { "url": "https://passage-data.com/mcp" } } }
```

## Tools

| Tool | What it answers |
|---|---|
| `find_limits` | Numeric limits and guidelines for one substance or measure (a name or CAS number), optionally by place (ISO 3166: `US-OH`, `CA-QC`, `DE`, `EU`), medium, statistic and kind. A place also searches the places above it. |
| `check_value` | Whether one measured value (with its unit) is over, under or within each row `find_limits` would return. Units convert exactly within a family; a row that cannot be compared says why (a hardness- or pH-dependent criterion, a narrative limit, a unit of another family). |
| `check_values` | A lab table in one call: up to 200 rows of parameter, value and unit for one place, each answered by `check_value`, with each held limit sent once and a count of the rows over. A row that cannot be read (an unknown parameter, a value below detection such as `<0.005`) gets its own coded refusal. |
| `verify_claim` | Whether a limit held says what a sentence says (an AI's answer, a report): `confirmed` with the row's `cite`, `contradicted` with the numbers held, or a refusal when nothing is held to judge it by. |
| `list_sources` | Every instrument held for a place: title, issuer, edition, what it governs, rows read, source URL and sha256. |
| `get_permit` | One US NPDES discharge permit from EPA's national file: limits by outfall, renewal due date, the last 12 months' values over a limit. |
| `find_designations` | The status a species holds under each register held: US ESA, SARA and COSEWIC, provincial and territorial acts, IUCN Red List, CITES, CMS, EU Habitats and Birds Directives, UK schedules. Each cited to the line the register prints. |
| `screen_species` | A species list in one call: up to 500 names for one place or everywhere, each answered by `find_designations`, with each register sent once and the registers that are silent on a name. |
| `map_to_darwin_core` | The Darwin Core term each column of a species occurrence or checklist file maps to, the rule that decided it, and the GBIF-required terms no column carries. |
| `search` | Free-text search over everything held (a substance and a place, a species, an instrument's title, an NPDES permit number), returning ids for `fetch`. |
| `fetch` | One document `search` returned, as text: every cited row for a parameter in a place, what each register says about a species, or what is held for a place. |

All tools are read-only and idempotent.

## Example

```bash
curl -s -X POST https://passage-data.com/mcp \
  -H "content-type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"find_limits","arguments":{"parameter":"ammonia","place":"US-OH","medium":"surface_water"}}}'
```

or over plain HTTP:

```bash
curl -s "https://passage-data.com/api/v1/limits?parameter=ammonia&place=US-OH&medium=surface_water"
```

A lab table or a species list goes in one POST:

```bash
curl -s -X POST https://passage-data.com/api/v1/check -H "content-type: application/json"   -d '{"place":"CA-QC","medium":"water_discharge","rows":[{"parameter":"copper","value":0.15,"unit":"mg/L"},{"parameter":"zinc","value":0.4,"unit":"mg/L"}]}'
curl -s -X POST https://passage-data.com/api/v1/designations -H "content-type: application/json"   -d '{"place":"CA-ON","species":["Myotis lucifugus","Emydoidea blandingii"]}'
```

Each row carries `value`, `unit`, `statistic`, `direction`, `kind`, `medium`, `place`, `conditions` as printed, and a
`cite` block (`instrument`, `title`, `issuer`, `edition`, `section`, `page`, `quote`, `source_url`, `source_sha256`).
More in [`examples/`](examples/).

## What is held

The live counts are on the service card: [passage-data.com/api/v1/](https://passage-data.com/api/v1/) (`held`).
On 2026-10-14 the card said 247 instruments, 98,587 rows, 5,910 parameters and 74 places, plus 34 species registers
holding 213,742 entries.

## Terms

- The data is read from public law and public agency files. **Check the cited source before relying on a value.** A
  refusal is a statement about our sources, not about the law of a place or the protection of a species.
- Free while in preview. Calls are rate-limited (30 requests per 10 seconds per caller; a blocked call gets HTTP 429
  with `Retry-After`).
- We keep what is asked (tool, place, parameter or species name, outcome), the name and version the calling program
  gives, the network it calls from (operator and country, as Cloudflare reports them) and how many distinct callers a
  day; never an IP address, an account or a person.

This repository holds the server's listing and examples. The server itself is hosted at passage-data.com; its code is
not public.
