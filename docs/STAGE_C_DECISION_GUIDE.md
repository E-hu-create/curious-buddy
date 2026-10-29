# Stage C, Option C: Decision Guide

**Purpose:** help you make the decisions that must come *before* any cloud
AI answers are built. Nothing here is implemented, and no account, key or
backend exists. This is an engineering guide, **not legal advice**.

Architecture recap (from [STAGE_C_SMARTER_ANSWERS.md](STAGE_C_SMARTER_ANSWERS.md)):
safety filter and curated answers on the phone first; only "I don't know"
questions, and only when a grown-up has switched AI answers on, go to **our
backend**, which holds the key, checks the request, calls the AI provider,
checks the reply and stores nothing.

---

## Decision 1: AI provider and model

What matters for Curious Buddy: short answers (1–3 sentences), fast replies
(a child is waiting), strong safety behaviour, clear data-retention terms,
**explicit permission to serve under-18 users**, and predictable cost.

### If you choose Anthropic (Claude)

Current models and list prices (Claude API, per million tokens; table dated
6 Oct 2026, **check current prices before deciding**):

| Model | Input | Output | Fit for Buddy |
| --- | --- | --- | --- |
| Claude Haiku 5.5 (`claude-haiku-5-5`) | $0.10 | $0.50 | Fastest and cheapest; well suited to short answers. Start here and test quality. |
| Claude Sonnet 5.5 (`claude-sonnet-5-5`) | $2.00 | $10.00 | Stronger judgement on tricky or ambiguous questions; ~20× Haiku's cost. |
| Claude Opus 5.5 (`claude-opus-5-5`) | $4.00 | $20.00 | Anthropic's default, most capable Opus; likely more than Buddy needs. |

Facts relevant to a children's product:

- **Refusals:** safety classifiers can decline a request (`stop_reason:
  "refusal"`). The backend must handle this and fall back to a curated reply.
- **Data retention:** Anthropic offers zero-data-retention (ZDR)
  arrangements for eligible organisations, and some top-tier models are
  *not* available under ZDR. **Verify** ZDR eligibility and terms for the
  model you pick with Anthropic before launch.
- **Where it runs:** requests can be pinned to a region (`inference_geo`),
  and Claude is also offered through Amazon Bedrock, Google Cloud Vertex AI
  and Microsoft Foundry, each with its own data terms and pricing.
- **Products for minors:** **verify** Anthropic's current Usage Policy and
  commercial terms on products used by people under 18 (what is allowed,
  and what extra safeguards are required). Do not proceed until this is
  confirmed in writing for an 8–14 audience.
- **Cost controls:** prompt caching makes the fixed instructions cheaper to
  resend; set a hard spending limit on the account.

### Other providers

Other major providers (e.g. OpenAI, Google) have comparable small, fast
models. Compare them on the same checklist: under-18 policy, retention and
training terms, region, refusal behaviour and price. I can only state
Anthropic's details reliably here; check others against their current
documentation.

### Rough cost per question (Anthropic list prices above)

Assume ~800 input tokens (instructions + question) and ~120 output tokens
(a short answer), before caching discounts:

| Model | Per question | Per 10,000 questions |
| --- | --- | --- |
| Haiku 5.5 | about $0.00014 | about $1.40 |
| Sonnet 5.5 | about $0.0028 | about $28 |
| Opus 5.5 | about $0.0056 | about $56 |

Only questions the curated library can't answer, from families who opted
in, reach the AI, so real volume is a fraction of all questions. Hosting
the backend is usually a few dollars a month at small scale. **These are
estimates; measure with a test before committing.**

**Recommendation:** start evaluation with **Claude Haiku 5.5**, compare a
sample against Sonnet 5.5 on accuracy and safety, and choose the cheapest
one that passes.

---

## Decision 2: who hosts, owns and pays for the backend

Someone must own the provider account and backend, pay the bills, rotate
keys, watch for abuse and respond to incidents.

| Option | Pros | Cons |
| --- | --- | --- |
| Serverless function (Cloudflare Workers, Google Cloud Run / Firebase Functions, AWS Lambda) | Cheap at low volume, little to maintain, scales automatically | Need to set up attestation, rate limits and spending alerts yourself |
| Claude through your cloud (Bedrock / Vertex AI / Foundry) | Keys handled by cloud IAM; one bill; regional controls | More cloud setup; per-platform terms differ |
| Small always-on server | Full control | More maintenance and security work |

Non-negotiables regardless of choice: API key only on the server; Play
Integrity check that requests come from the real app; per-device rate
limits without storing identities; size limits; no logging of questions or
answers (counts and errors only); a kill switch; a monthly budget cap.

**Recommendation:** a serverless function in one region, owned by the same
legal entity that publishes the app.

---

## Decision 3: parental consent

Sending a child's question to a third party is collecting a child's
personal information in many legal regimes, even without a name.

- **US (COPPA):** applies to children under 13. Requires **verifiable
  parental consent** before collection, e.g. a signed consent form, a
  payment-card check, an ID check, a video call, or knowledge-based
  questions. Your 8–14 audience straddles this line.
- **UK / EU:** UK Age Appropriate Design Code and GDPR (digital-consent age
  13–16 depending on country) require high-privacy defaults, a data
  protection impact assessment and parental consent below the threshold.
- **App stores:** Google Play's Families policy and Apple's Kids category add
  their own rules about third-party services and data.

Practical shape in the app: AI answers **off by default**; a grown-up enables
them in the Parent Zone after reading what is sent where; consent is
recorded in a way that does not identify the child; easy to switch off.
The exact consent method must come from your legal review.

**Recommendation:** have the privacy/legal review choose the consent
method *first*; it determines what the Parent Zone must build.

---

## What I need from you

1. **Provider:** evaluate Anthropic (Haiku 5.5 first), another provider, or
   compare several?
2. **Owner and hosting:** who owns the account and backend, and which
   hosting option?
3. **Consent and review:** who will run the privacy/legal review, and when?

Until 2 and 3 are decided, the safest next engineering step is still Option
A (more curated topics) or Phase 3 (saved settings).
