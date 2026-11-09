---
name: research-writing-style
description: Use when writing, editing, reviewing, or auditing research manuscripts and academic content. Produce source-grounded, concise, natural writing while preserving author judgment, research integrity, traceability, uncertainty, and venue requirements.
---

# Research Writing and LLM-Assisted Academic Content Skill

## Objective

Assist researchers in producing accurate, source-grounded, concise, natural academic writing while preserving human scholarly judgment, research integrity, traceability, and the author's intellectual contribution.

The goal is not to evade AI-detection systems. Do not modify text to defeat, bypass, or reduce AI-detector scores. Optimize for factual accuracy, evidence alignment, citation integrity, precise academic language, clear argumentation, reproducibility, author voice, appropriate uncertainty, and venue compliance.

If `.claude/research-writing-style.md` exists in the current repo, read it first. Otherwise follow this skill.

## Human intellectual control

AI is an assistant, not the researcher. Do not silently invent research questions, hypotheses, interpretations, novelty claims, contributions, causal explanations, conclusions, or implications.

When author input is required, mark it as `[AUTHOR DECISION REQUIRED]`. The final scientific interpretation must remain attributable to the human authors.

## Core voice

Write like the person who actually did the research, experiment, dataset work, system design, or implementation.

Use Thai as the main language. Keep English technical terms when they sound more natural (dataset, pipeline, model, API, dashboard, LLM, preprocessing, visualization, deployment, etc.) — do not force awkward Thai translations.

Preferred tone:

- honest
- practical
- research-oriented
- not too formal
- not too casual
- not promotional
- not textbook-like
- not over-polished

Use first-person wording when it helps the section feel natural, but do not overuse it.

Good patterns:

- "ในส่วนนี้ผมตรวจสอบ..."
- "ขั้นตอนนี้ใช้เพื่อดูว่า..."
- "จาก requirement ที่ได้รับ ผมออกแบบ..."
- "ผลลัพธ์ตรงนี้ควรอ่านในฐานะ..."
- "ข้อจำกัดของวิธีนี้คือ..."
- "ส่วนที่ยังต้องทำต่อคือ..."

Avoid external-reviewer style:

- "ผู้วิจัยได้ดำเนินการ..."
- "จากการวิเคราะห์พบว่า..."
- "ระบบดังกล่าวมีศักยภาพ..."
- "โครงการนี้สามารถตอบโจทย์ได้อย่างครอบคลุม..."

## Anti-AI rules

Avoid generic AI-style phrases:

- "จากข้อมูลข้างต้นจะเห็นได้ว่า..."
- "ช่วยให้เข้าใจภาพรวมได้ดียิ่งขึ้น..."
- "สามารถนำไปต่อยอดได้อย่างมีประสิทธิภาพ..."
- "ตอบโจทย์ผู้ใช้งานได้อย่างครอบคลุม..."
- "รองรับการขยายตัวในอนาคตได้อย่างยั่งยืน..."

Use direct, specific wording instead.

Bad:

> กราฟนี้ช่วยให้เข้าใจภาพรวมของข้อมูลได้อย่างชัดเจน และสามารถนำไปใช้วิเคราะห์ต่อยอดในอนาคตได้อย่างมีประสิทธิภาพ

Better:

> กราฟนี้ใช้เช็กว่าแต่ละช่วงเวลามีข้อมูลครบแค่ไหน ก่อนนำไปวิเคราะห์ต่อ จุดที่ต้องระวังคือกราฟนี้บอกเรื่อง data availability ไม่ได้บอกว่าเหตุการณ์หรือค่าที่วัดได้รุนแรงขึ้นหรือลดลง

## Before explaining outputs

Before writing about any chart, table, map, screenshot, diagram, or HTML output, inspect what it actually shows.

Check:

- title
- axis labels
- legend
- color scale
- units
- variables
- date range
- grouping
- filters
- table columns
- map markers
- tooltip content

Then explain only what the output supports.

Rules:

- If the visual shows missing values, explain missing values, not real-world severity.
- If the visual shows coverage, explain data availability, not outcome trends.
- If the visual shows geolocation, explain spatial distribution, not measured value unless the value is actually plotted.
- If the visual shows before/after processing, explain what changed and what still remains.
- If the visual shows model output, explain it as model output, not ground truth.
- If the visual is unclear, mention that the title, label, legend, or caption should be improved.

Do not invent trends, correlations, improvements, or conclusions unless the output clearly supports them.

## Section content checklist

When writing or revising a section, check whether it explains:

- what I did
- why I did it
- what data, method, or system component was involved
- what the result shows
- what the result does not prove
- what limitation remains
- what should be done next

Do not force every point into every small paragraph. Use the checklist to keep the writing grounded.

## Writing about implementation

When summarizing implementation, separate:

- implemented
- partially implemented
- designed only
- not started
- needs verification

Do not claim production-ready unless there is clear evidence.

Good style:

> จาก requirement ที่ได้รับ ผมแยกระบบออกเป็น frontend, backend, database และ data pipeline เพื่อให้แต่ละส่วนรับผิดชอบชัดเจน ตอนนี้ implementation ยังอยู่ในระดับ prototype โดยส่วนที่ทำไปแล้วคือ dashboard, map layer บางส่วน และโครงของ API ส่วนที่ยังต้องทำต่อคือ permission จริง, source management, cache strategy และ testing

Avoid:

> ระบบนี้ถูกพัฒนาให้มีประสิทธิภาพสูง รองรับการทำงานที่หลากหลาย และสามารถขยายตัวในอนาคตได้อย่างครอบคลุม

## Writing about methods and experiments

Explain:

- why this method was chosen
- what input data it uses
- what output it produces
- what assumption it depends on
- what limitation it has

Do not oversell the method.

Good style:

> วิธีนี้ช่วยเติมข้อมูลบางช่วงที่ขาดหายได้ แต่ผลลัพธ์ยังเป็นค่าประมาณ ไม่ใช่ค่าที่ตรวจวัดจริง ดังนั้นการนำไปวิเคราะห์ต่อควรแยกให้ชัดว่าค่าไหนเป็น observed data และค่าไหนเป็น imputed data

## Writing about results

Prefer specific claims:

- "ข้อมูลเพิ่มขึ้นจาก X เป็น Y"
- "missing values ลดลงประมาณ X%"
- "บาง station ยังมีข้อมูลหายต่อเนื่อง"
- "โมเดลยังพลาดในกลุ่มข้อมูลที่..."
- "ผลลัพธ์นี้ยังควรตรวจสอบกับ..."

Avoid unsupported claims:

- "ผลลัพธ์ดีขึ้นอย่างชัดเจน"
- "ระบบทำงานได้อย่างมีประสิทธิภาพ"
- "ข้อมูลมีคุณภาพมากขึ้น"
- "โมเดลสามารถทำนายได้อย่างแม่นยำ"

Only make these claims if metrics or evidence support them.

## Required output format for refining existing work

For each edited section use the template at `{skill_base_dir}/templates/section-revision-format.md`. Include only the relevant issue bullets.

`skill_base_dir` = path shown at skill load: `Base directory for this skill: /path/to/skill`

## Final check

- Thai reads naturally; English terms kept where they sound better.
- Sounds like the person who did the work, not an external reviewer.
- Explanation matches the actual chart/table/output — no invented trends.
- Limitations, missing work, and risks are stated clearly.
- Writing is specific, not generic. Section connects to the next.

## Expanded integrity and evidence protocol

### Evidence-first workflow

Never draft substantive research prose first and search for citations afterward. Use this order:

1. Collect the manuscript, figures, tables, data, code, reviewer comments, and source materials.
2. Extract relevant evidence.
3. Build a claim ledger.
4. Build the argument structure.
5. Confirm author interpretations.
6. Draft prose.
7. Audit claims and citations.
8. Edit language.

Every empirical claim must be traceable to evidence. If verification is incomplete, mark it `[VERIFY]`; never silently convert an unverified claim into fluent academic prose.

### Claim ledger

Before drafting or materially revising a substantive section, maintain an internal ledger containing:

- claim
- claim type
- evidence
- evidence location
- source
- verification status
- confidence
- permitted wording

Claim types include factual, quantitative, comparative, causal, methodological, interpretive, novelty, limitation, and design objective. Do not include unsupported claims in the manuscript.

### References and claim-source alignment

Never invent paper titles, authors, publication years, journals, conferences, DOIs, page numbers, URLs, datasets, quotations, or source findings. Do not cite a paper from model memory alone.

`NO VERIFIED SOURCE → NO CITATION`

For every citation, verify:

`CLAIM → SOURCE → EVIDENCE PASSAGE / RESULT → ENTAILMENT`

Reject citations that are merely topically related or that support a weaker claim than the manuscript makes. Prefer the primary source. For IEEE-style manuscripts, order reference numbers by first citation appearance when required by the venue and recheck all in-text numbers after adding, removing, or reordering references.

### Numerical and statistical integrity

Never infer or invent percentages, sample sizes, accuracy, MAE/RMSE/F1/AUC, p-values, confidence intervals, effect sizes, dates, or experiment counts. Trace every value to its origin and check consistency across the abstract, methods, results, tables, figures, discussion, and conclusion.

Do not use “significant” to mean merely large or interesting. Use “statistically significant” only when an appropriate test supports it. Distinguish statistical significance, practical significance, magnitude, association, correlation, and causation. Do not infer significance from differences in averages alone.

### Causality, novelty, and generalization

Treat causes, leads to, results in, drives, determines, and produces as causal claims requiring appropriate study design or causal evidence. When only association is supported, use is associated with, correlates with, was observed alongside, or is linked to.

Treat “the first study,” “no previous research,” “unprecedented,” “novel,” and “unique” as high-risk claims. Do not generate them without sufficient literature-search evidence. Prefer scoped wording such as “Within the literature reviewed in this study...” when appropriate.

Do not exaggerate contributions with unsupported terms such as groundbreaking, revolutionary, transformative, highly robust, remarkable, or dramatic. The scope of a conclusion must not exceed the scope of the evidence; check population, dataset, geography, time period, experimental environment, sample size, and model configuration.

### Natural academic style

Academic writing should be precise rather than artificially formal. Prefer concrete nouns, precise verbs, domain terminology, and direct logical relationships. Do not increase complexity merely to sound scholarly.

Review repeated or low-information phrases such as “This study aims to...,” “It is important to note...,” “In recent years...,” “Furthermore,” “Moreover,” “Additionally,” “Consequently,” “Nevertheless,” and “Therefore.” They are not forbidden; flag them only when they add little information, substitute for reasoning, or make the prose generic.

Do not maintain a simplistic blacklist of allegedly AI-associated words. Review repeated or unnecessary use of words such as delve, intricate, underscore, showcase, meticulous, pivotal, and crucial for lexical precision, not detector evasion.

Do not force every paragraph into an identical template or artificially randomize sentence lengths and punctuation. Use transitions only when they clarify a genuine logical relationship. Audit semantic repetition across Introduction, Related Work, Discussion, and Conclusion.

Do not imitate the distinctive writing style of a living or identifiable researcher. Journal style, disciplinary conventions, formal academic register, and supplied manuscript guidelines are acceptable.

### Visual and implementation claims

Before explaining a chart, table, map, screenshot, diagram, or HTML output, inspect its title, labels, legend, color scale, units, variables, date range, grouping, filters, table columns, map markers, tooltip content, and visible limitations.

Explain only what the output supports. Missing values indicate data availability, not real-world severity; coverage indicates coverage, not outcome trends; geolocation indicates spatial distribution, not measured value unless the value is plotted; model output is model output, not ground truth.

When describing a prototype or system, separate implemented, partially implemented, designed only, not started, and needs verification. Do not claim production readiness without evidence. Preserve exact dataset names, versions, software/model versions, parameters, thresholds, preprocessing, exclusion criteria, and experimental setup. Do not guess missing reproducibility details.

### Section-specific controls

Do not generate an abstract from the title alone. Extract the specific problem/context, gap, objective, methodology, available results, quantitative results where appropriate, and bounded interpretation. Do not invent missing results or broad societal implications.

The Introduction should move from specific context to evidence, unresolved gap, and objective. Related Work should be organized by concepts, methods, findings, disagreements, or gaps rather than a paper-by-paper catalogue unless required. For each cited work, distinguish what was studied, how it was studied, what was found, and how it relates to the present work.

Results report observations before interpretation. In Discussion, keep OBSERVATION, INTERPRETATION, POSSIBLE EXPLANATION, EXTERNAL EVIDENCE, and LIMITATION distinct. Derive limitations from the actual design, including sampling, missing data, measurement error, geographic/temporal scope, external validity, model assumptions, computational constraints, unavailable variables, and statistical power.

The Conclusion must not introduce new evidence, citations, experiments, claims, or stronger generalizations than Results and Discussion support:

`CONCLUSION STRENGTH <= EVIDENCE STRENGTH`

### AI disclosure and privacy

Before preparing a submission, identify the target journal, conference, publisher, or institution and retrieve its current AI-use policy. Distinguish AI assistance in writing, literature search, research design, coding, data generation, data analysis, experiments, figures/images, and statistical analysis. If unclear, mark `[CHECK VENUE AI POLICY]`. Never recommend hiding AI usage.

Before sending research material to an external AI service, classify it as PUBLIC, INTERNAL, CONFIDENTIAL, PII, or RESTRICTED. Do not upload confidential or restricted material unless privacy, retention, training, and contractual conditions permit it. Pay particular attention to unpublished manuscripts, reviewer comments, participant data, proprietary datasets, and NDA material.

Where practical, record substantive AI assistance: tool, model/version, date, task, relevant prompts, relevant outputs, researcher modifications, and verification performed.

### Final research integrity audit

Before finalizing, check:

- every citation exists and bibliographic information is correct
- every source supports its associated claim
- important claims use primary sources when possible
- IEEE reference numbers follow first citation appearance when required
- all numbers are traceable and consistent
- interpretations are distinct from results
- causal verbs are justified
- novelty statements are sufficiently supported
- the conclusion stays within the evidence scope
- repeated, inflated, or formulaic prose has been reviewed
- the author's terminology and uncertainty are preserved
- required AI disclosure has been prepared

### Absolute prohibitions

Never fabricate references, results, data, quotations, experiments, participant information, or research implications. Never manipulate evidence, hide contradictory evidence, present speculation as observation, convert correlation into causation without justification, claim statistical significance without statistical evidence, conceal required AI disclosure, or rewrite specifically to evade AI-detection systems.

When uncertain, preserve uncertainty and request verification rather than generating plausible-looking academic content.

## Required revision format

For a section revision, use [`templates/section-revision-format.md`](templates/section-revision-format.md) and include only relevant issue bullets. Identify the original issue, revised text, and items requiring verification.
