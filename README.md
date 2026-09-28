## About

These tools are used by Cybersecurity operations teams at the
University of Illinois to help assess security risks in code.

This resource helps comply with University of Illinois
Cybersecurity standards - including [IT-07][it07], [IT08][it08],
and [IT13][it13].

[it07]: https://go.illinois.edu/secstd-IT07
[it08]: https://go.illinois.edu/secstd-IT08
[it13]: https://go.illinois.edu/secstd-IT13

See [Cybersecurity Development on the Illinois Knowledge Base][kbsearch]
for information about our development standards.

[kbsearch]: https://answers.uillinois.edu/illinois/search.php?q=cybersecurity+developer&cat=0

## Tools

### Cybersecurity Review

- SecDev maintains an AI "skill", `/cybersecurity-review` for identifying vulnerabilities in local source code.
- We update this AI skill after OWASP updates the OWASP Top Ten, roughly every four years.
- This skill is intended to guide remediation efforts and is not a substitute for a mature Software Development Lifecycle.
  - We consider this skill suitable for exploration and education.
  - We want to help interpret and respond to these reports - they can be confusing, may contain false positives, and will raise questions.
- Campus IT Professionals can contact securitysupport@illinois.edu.

## Data Sources

For data sensitivity, see [Data Classification](https://www.cybersecurity.illinois.edu/data-classification/).

|Data Store|Data Type|Sensitivity|Notes|
|----------|---------|-----------|-----|
| Report Files | Descriptions of Code Risks Detected | Sensitive - May contain detected vulnerabilities in a live system. | Developers are encouraged to treat reports files as [TLP:Amber](https://www.cisa.gov/news-events/news/traffic-light-protocol-tlp-definitions-and-usage) |
| Your AI Agent Training | [AI Approved for Campus Use](https://genai.illinois.edu/ai-apps/) should not train on your source code. Other AI may train on files you allow it to access. | Sensitive | Non-public source code may be Sensitive, and should not be shared with un-approved AI. |


## Endpoint Connections

|Endpoint|Purpose|Stage|Access|Contact|
|--------|-------|-----|------|-------|
| Your AI Agent | Applies these patterns to your code to produce reports. | Development | Reads your code and environment | Your AI Agent Vendor |
| OWASP Web Resources | Your agent may access OWASP resources from the OWASP web site to help analyze your code. | Development | Read | https://owasp.org/projects/top-ten |


## Product Support

Only the latest version of this product is supported by Cybersecurity teams at the
University of Illinois Urbana-Champaign on a best-effort basis.

As of the last update to this README, the expected End-of-Life and
End-of-Support dates of this product are January 2029.

- OWASP updates the Top Ten every four years. Next expected is in 2029.
- Success with these tools will vary by AI tool.

