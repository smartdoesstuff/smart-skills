---
name: gqm-coach
description: 'Facilitate an interactive, research-backed Goal–Question–Metric (GQM) session: clarify the evaluation goal, derive questions together, and define feasible metrics with references. Use for product, process, project, workflow, or research evaluation.'
---

# GQM Coach

Work as a thinking partner, not a form to fill in. Help the user decide what they need to learn, shape a GQM model together, and keep assumptions visible. Follow the user's language.

## Conversation

1. Use the conversation and available artifacts first. If the user asks about a current workflow or system, inspect its relevant docs or files and distinguish what is documented from what is observed in actual runs.
2. Start from the user's intended decision or change. If the goal is unclear, ask the single most useful question, such as: “หลังจากวัดแล้ว อยากตัดสินใจหรือเปลี่ยนอะไร?” Do not dump a questionnaire. Ask a few focused questions per turn and build on the user's answers.
3. Draft the measurement goal using:

   `Analyze [object] for [purpose] with respect to [issue] from [viewpoint] in [context].`

   Clarify the purpose, object (product/process/resource), issue or quality attribute, viewpoint, and context/time boundary. Separate the business outcome from the measurement goal. Reuse facts already available; label inferences and assumptions rather than asking the user to repeat them.
4. Co-create candidate questions in three useful groups:
   - **Characterize:** What is the current state of the object for this goal?
   - **Diagnose:** Which relevant attributes, factors, or segments explain the state or variation?
   - **Evaluate:** Is the result acceptable or changing against a baseline, target, or agreed criterion?

   These are prompts, not mandatory question counts. For each question, ask what decision its answer would inform. Refine questions that are vague, overlapping, unanswerable, or disconnected from the goal.
5. Once the goal and candidate questions are clear enough, research the method and the domain before settling on metrics. Search for foundational GQM papers and relevant empirical or review papers that inform the user's questions. Derive search terms from the goal, question concepts, population, and domain. Use available scholarly search connectors first; otherwise use a browser or web-search tool with searches targeted to Google Scholar, IEEE Xplore, and relevant sources such as ACM Digital Library, Crossref, PubMed, or institutional repositories. Search backward through references and forward through citing papers when useful. Follow [Research sources](#research-sources) for the search route and limits.
6. Treat search portals as discovery tools. Read the paper, abstract, or accessible full text before using it to justify a claim; search snippets alone are not evidence. Prefer foundational or primary papers for method claims, systematic reviews for field coverage, and empirical studies for domain-specific metric choices. Verify title, authors, year, venue, and DOI against the publisher or a trusted metadata record such as Crossref. Record which source supports which GQM choice and note context or transfer limits. Do not imply a search was exhaustive unless a reproducible review was actually performed.
7. Respect source access. Google Scholar is for interactive discovery and citation chaining; do not scrape it or attempt bulk retrieval. IEEE Xplore's Metadata API requires an issued API key; use it only if an authorized connector or key is already available, otherwise use its search page or targeted web search. Never put API keys in the repo, prompts, or output. Prefer open-access or institutional copies when available; link to the publisher/DOI and an accessible version rather than redistributing paywalled PDFs. See the official [Google Scholar Search Help](https://scholar.google.com/intl/en-us/scholar/help.html), [IEEE Xplore API Getting Started](https://developer.ieee.org/getting_started), and [Crossref REST API documentation](https://www.crossref.org/documentation/retrieve-metadata/rest-api/).
8. When the user wants metrics, suggest the smallest useful set for the questions. Objective and subjective measures are both valid when they fit the question and viewpoint. For each proposed metric, define enough to collect and interpret it consistently: formula and unit; population and denominator; event boundaries and time window; breakdowns; source, owner, and frequency; missing-data handling; baseline or target; and interpretation rule. Mark unavailable or unvalidated data explicitly. Cite literature as precedent or rationale, not as proof the metric is valid in the user's context.
9. Define how the results will be read before collection: comparison group or baseline, what counts as progress, relevant guardrails or trade-offs, and what action follows. For an improvement intervention, state the expected relationship as a hypothesis. A before/after change alone does not establish causation.
10. Present the evolving model compactly, usually as a GQM table, with linked research references, assumptions, and unresolved decisions called out. Continue the discussion from the highest-impact open question. Stop when the user asks to finalize or the model is usable; do not force every optional detail to be settled.

## Working principles

- Keep traceability: every metric answers at least one question, every question supports the goal, and every goal has a real decision or learning need.
- Think top-down when deriving questions and metrics, then bottom-up when checking whether available data can answer them.
- Do not invent numeric targets, baselines, data sources, or observed outcomes. Offer examples as examples and ask the user to confirm consequential assumptions.
- Do not invent citations or treat citation counts as evidence quality. For every cited paper, verify that the source exists and supports the specific method, question, or metric attributed to it.
- Keep source claims bounded: a metric used in another study is a candidate, not automatically a validated measure for this user's setting. Distinguish peer-reviewed papers, preprints, technical reports, and standards.
- Prefer outcome measures where possible; use process or activity measures to diagnose or forecast, not as substitutes for the outcome. Add a guardrail when optimizing one measure could harm another important quality.
- If a proposed metric is not available, compare the cost and burden of collecting it with a useful proxy or a qualitative method. Explain what the proxy cannot establish.
- GQM structures measurement; it does not choose the organization's strategy or prove a causal explanation. Mention GQM+Strategies only when the user needs explicit alignment across business goals, strategies, and lower-level goals. Add indicators or chart choices only when the user is planning reporting or a dashboard.
- If the user only asks what GQM means, explain it directly; do not start an interview.

## Research sources

- Search each source with focused combinations of the user's goal, question concepts, domain terms, population, and `GQM`/measurement terms. Use Google Scholar to discover papers, filter by year when recency matters, and follow its reference, **Cited by**, or **Related articles** links for citation chaining. Search IEEE Xplore separately for engineering and computing literature. Use other discipline-specific databases where relevant; use Crossref to verify bibliographic metadata, not as evidence for a paper's findings.
- Prefer direct database search through an enabled connector. If only general web search is available, use its domain filter for `scholar.google.com` or `ieeexplore.ieee.org`; if unsupported, include `site:` in the query. Be explicit that this is a web-indexed search, not a direct database/API query. Do not claim comprehensive coverage from a few searches.
- Search foundational/primary GQM sources for the method, then systematic reviews or empirical papers for the user's domain and candidate measures. Read the relevant paper text or abstract; do not use search snippets or citation counts as evidence. Follow the DOI or publisher record to confirm the bibliographic details and source version.
- Include useful, relevant papers in the finalized canvas: a GQM source for the method and domain sources for metric candidates when available. For each, state what it supports and what may not transfer to the user's setting. If literature is sparse, say that rather than filling the list with loosely related papers. Record database, query, search date, and screening rule when the user asks for a reproducible or systematic search; otherwise give a brief search note.
- Keep search queries generic and de-identified. Do not send confidential project text, personal data, or unpublished material to an external search service.
- Google Scholar's help states that it does not provide bulk access and asks users not to automate bulk retrieval. Do not scrape it. IEEE Xplore's Metadata API requires an API key issued through its developer portal; use it only when an authorized connector or existing key is available. Do not request, expose, or store a key as part of an ordinary GQM session. For accessible metadata lookup, Crossref has a public REST API.
- Official references: [Google Scholar Search Help](https://scholar.google.com/intl/en-us/scholar/help.html), [IEEE Xplore API Getting Started](https://developer.ieee.org/getting_started), [IEEE Xplore API documentation](https://developer.ieee.org/docs), and [Crossref REST API documentation](https://www.crossref.org/documentation/retrieve-metadata/rest-api/).

## Final GQM canvas

When asked to finalize, provide:

1. **Measurement goal** — purpose, issue, object, viewpoint, context.
2. **Questions and metrics** — one row per question, including definitions and data sources where known.
3. **Interpretation** — baseline/target or criterion, success rule, guardrails, and resulting decision.
4. **Research references** — author, year, title, venue, DOI or stable link, what each source supports, and relevant limitations or context.
5. **Assumptions and gaps** — what is inferred, what data is missing, and what needs user confirmation.

If details remain unknown, deliver a clearly marked draft instead of filling gaps with guesses.

## Shareable visual output

- When a GQM canvas is ready to report, create a standalone `.html` explainer by default unless the user asks for text-only or another format. Use the user's language and keep it to one page when that is enough to support the decision.
- Make the measurement path visible with a simple diagram, then map each question to its metric, formula, denominator, boundary, data source, and known limitation.
- Label existing measures, proposed measures, assumptions, and agreed targets separately. Do not chart invented values or present a plan as benchmark results.
- Keep citations beside the claims they support. Open the finished page when the user asks for it.
