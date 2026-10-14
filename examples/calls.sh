#!/bin/sh
# Calls to Passage Data's door for programs. No key. Each answer is JSON; every row carries its `cite` block.
MCP=https://passage-data.com/mcp
API=https://passage-data.com/api/v1

# MCP: list the tools, then call find_limits (the server is stateless: no session needed)
curl -s -X POST "$MCP" -H "content-type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
curl -s -X POST "$MCP" -H "content-type: application/json" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"find_limits","arguments":{"parameter":"ammonia","place":"US-OH","medium":"surface_water"}}}'

# HTTP: the same answers over GET
curl -s "$API/limits?parameter=ammonia&place=US-OH&medium=surface_water"
curl -s "$API/check?parameter=copper&value=0.15&unit=mg/L&place=CA-QC&medium=water_discharge"
curl -s "$API/sources?place=CA-QC"
curl -s "$API/permits/PA0228061"
curl -s "$API/designations?species=Myotis%20lucifugus&place=CA-ON"
