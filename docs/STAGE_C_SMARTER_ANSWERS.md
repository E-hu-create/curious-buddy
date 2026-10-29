# Stage C Proposal: Smarter Answers

**Status: Option A approved and implemented (awaiting review); Option C
approved in principle for later, after the legal/privacy review and
parental consent.** Buddy still answers only from reviewed, offline
content; no AI service, backend or API key exists.

### Option A, as built

- About 70 reviewed topics (from about 25): animals, space, Earth and
  weather, the human body, science, history and clean jokes.
- Matching: plurals and possessives fold to the base word; one-letter typos
  forgiven only for long, distinctive names (`typoTolerantWords`), because
  forgiving ordinary words caused misfires ("planes" → "planets").
- Pinned answers: question words select the answer that actually answers
  ("why do cats purr" always gets the purr answer).
- Honesty: a specific question that only matches a subject gets "I'm not
  sure about that exact question yet. Here's a snake fact instead!"
  instead of a fact passed off as an answer.
- On a sample of 30 typical questions: 25 answered directly (was 10), 1
  honest "not sure" with a related fact, 4 honest "I don't know yet".
- Tested by `test/domain/conversation/curated_matching_test.dart` (a table
  of real questions and the topic each must reach, plus misfire guards).

## The problem

Today most open questions ("Why do cats purr?") get "I don't know that one
yet". Stage C aims to answer far more questions while keeping every
safety rule in [CHILD_SAFETY.md](CHILD_SAFETY.md).

## Options

| | A. Grow the curated library | B. On-device AI model | C. Cloud AI behind our own backend |
| --- | --- | --- | --- |
| How | More reviewed topics, synonyms and fuzzier matching. Still offline. | A small language model running on the phone. | Phone → **our** server → AI provider → filtered answer. |
| Answers | Hundreds of topics, always correct and reviewed. Still says "I don't know" outside them. | Open-ended but weaker; harder to keep accurate and on-topic. | Open-ended, best quality. Can be wrong. |
| Privacy | Nothing leaves the phone. | Nothing leaves the phone. | The child's question (text only) goes to our server and the provider. |
| Cost | Writing time only. | Free to run; large download. | Per-question fees, plus hosting. |
| Feasibility on the Samsung A51 | ✅ | ❌ Unrealistic: phone-sized models need roughly 1–2 GB downloads and more memory and speed than this phone has; Android's built-in on-device model is only on newer flagship phones. | ✅ Works on any phone with internet. |
| Legal weight | Low | Low | **High**: sending children's text to a third party usually needs verifiable parental consent (e.g. COPPA in the US) and a provider that permits under-18 products. |

**Recommendation:** do **A now** (safe, no new risk, and it also becomes the
fallback for C), and treat **C as a separate, opt-in feature** that ships
only after the legal/privacy review you have already agreed to. Skip B for
now.

## Proposed architecture for C (if approved)

```
Child's question (typed or spoken, checked by the child)
  │
  ▼
ChildSafetyFilter (on the phone)     ── personal info / unsafe → safe reply, never sent
  │
  ▼
CuratedResponseProvider               ── known topic → reviewed answer, never sent
  │ (only for "I don't know" AND a grown-up switched AI answers on)
  ▼
AiResponseProvider (app)  ──HTTPS──►  Curious Buddy backend  ──►  AI provider
                                       • holds the API key (never in the app)
                                       • checks the app is genuine (Play Integrity)
                                       • rate limits, size limits
                                       • input check (filter + provider moderation)
                                       • fixed child-safe instructions
                                       • output check (length, topics, links,
                                         personal info, reading level)
                                       • stores nothing; no accounts
  ◄──────────────── structured reply {text, action?, followUps}
  │
  ▼
App validates the reply again        ── bad / slow / offline → curated "I don't know"
  │
  ▼
Shown with "AI answer, it can be wrong" label, then spoken
```

### Rules the backend and app must enforce

- **Never sent:** anything the on-phone filter flags, the child's name or
  any identifier, audio, location, or earlier conversation turns beyond the
  current topic.
- **Instructions to the model:** age 8–14, short sentences that sound good
  aloud, no personal questions, honest about being a computer character, say
  "I'm not sure" rather than guess, redirect sensitive topics to a trusted
  grown-up, no links, no instructions for anything dangerous.
- **Structured output only:** the model may pick an `action` only from the
  existing `BuddyAction` list; the app rejects anything else. The model can
  never open screens, the web or device features by itself.
- **Double filtering:** output passes the backend checks *and* the app's
  `ChildSafetyFilter` before display.
- **Transparency:** AI answers are visibly labelled and can be reported by a
  grown-up (report button in the Parent Zone, no conversation stored).
- **Off by default:** a grown-up switches "AI answers" on in the Parent Zone
  after reading what is sent where. Off = today's behaviour.
- **Retention:** choose a provider plan with zero or minimal data retention
  and no training on our traffic; our backend logs counts and errors only,
  never questions.
- **Kill switch:** the backend can disable AI answers instantly; the app
  falls back to curated answers.
- **Budget guard:** hard monthly spending cap at the provider and backend.

### App-side changes (small, because of Stage A's interface)

- `AiResponseProvider implements EducationalResponseProvider`, wrapped by a
  `LayeredResponseProvider` (safety → curated → AI → fallback).
- Parent Zone: "AI answers" switch, explanation, report button.
- Answer label and a slightly longer "thinking" state (network latency).
- Tests with a fake backend for: off by default, never sending flagged
  input, malformed/unsafe replies rejected, timeouts and offline fallback.

## What I need from you before any of C is built

1. Approve **Option A** now (expand curated content and matching)?
2. Pursue **Option C** later, after the legal/privacy review?
3. If C: which AI provider, and who hosts and pays for the backend (it
   needs an account, billing and an owner responsible for it)?
4. How will verifiable parental consent be handled for C (needed before
   any child's question leaves the phone)?

This is an engineering proposal, not legal advice or a compliance claim.
