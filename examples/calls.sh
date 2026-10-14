#!/bin/sh
# Calls to Passage Data's door for programs. No key. Each answer is JSON; every row carries its `cite` block.
MCP=https://passage-data.com/mcp
API=https://passage-data.com/api/v1
# Each call names this example as its program, so a run of the examples is told apart from a question.
UA="passage-data-example/1.0 (curl)"

# MCP: list the tools, then call find_limits (the server is stateless: no session needed)
curl -s -A "$UA" -X POST "$MCP" -H "content-type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
curl -s -A "$UA" -X POST "$MCP" -H "content-type: application/json" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"find_limits","arguments":{"parameter":"ammonia","place":"US-OH","medium":"surface_water"}}}'

# HTTP: the same answers over GET
curl -s -A "$UA" "$API/limits?parameter=ammonia&place=US-OH&medium=surface_water"
curl -s -A "$UA" "$API/check?parameter=copper&value=0.15&unit=mg/L&place=CA-QC&medium=water_discharge"
curl -s -A "$UA" "$API/sources?place=CA-QC"
curl -s -A "$UA" "$API/permits/PA0228061"
curl -s -A "$UA" "$API/designations?species=Myotis%20lucifugus&place=CA-ON"

# HTTP POST: a lab table (up to 200 rows) or a species list (up to 500 names) in one call
curl -s -A "$UA" -X POST "$API/check" -H "content-type: application/json"   -d '{"place":"CA-QC","medium":"water_discharge","rows":[{"parameter":"copper","value":0.15,"unit":"mg/L"},{"parameter":"zinc","value":0.4,"unit":"mg/L"}]}'
curl -s -A "$UA" -X POST "$API/designations" -H "content-type: application/json"   -d '{"place":"CA-ON","species":["Myotis lucifugus","Emydoidea blandingii"]}'
