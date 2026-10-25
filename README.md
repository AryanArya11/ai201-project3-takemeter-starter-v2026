# TakeMeter

> ### 👋 Start here
>
> **New to this repo? Read [RUNNING.md](RUNNING.md) first** — setup, the
> notebook, the baseline, and what to do when something breaks.
>
> Once `python test.py` passes:
>
> ```bash
> head -5 data/practice_labels.csv     # the shape your labels.csv needs
> ```
>
> Then open `takemeter.ipynb` **in this folder** — in VS Code, or with
> `jupyter notebook` if you prefer. Pick the kernel: the `.venv` inside this
> project. Run section 1, which reports the hardware you'll be training on.
> Everything else waits until you have data.
>
> Nothing to upload, nothing to connect, no accounts and no keys. The notebook
> runs on your machine and writes next to your code.
>
> **The rest of this file is your submission.** Fill it in as you go.

---

<!-- ─────────────────────────────────────────────────────────────────────────
     HOW TO USE THIS FILE

     Unit 5 asks for the first five sections. Unit 6 adds the five below them.

     Everything is pasted as TEXT. No screenshots, no images.

     ⚠️ The confusion matrix especially. The notebook prints one as a markdown
     table, ready to copy. A screenshot of a matrix earns nothing. Paste the
     table.
     ───────────────────────────────────────────────────────────────────────── -->

<!-- ═══════════════════════ UNIT 5 — THE BUILD ═══════════════════════ -->

## What This Does

TakeMeter is a text classifier that analyzes discussions from Hacker News, a community centered around technology, AI, and software engineering. I want to explore whether a fine-tuned language model can distinguish between different types of technical discussions, particularly explanations, predictions, and real-world experiences.

After exploring posts from the community, I noticed three main distinctions:

1. Some users explain technical concepts and how different systems or technologies work.
2. Others make predictions about where technology is heading or how it might impact the future.
3. Some users share their personal experiences building, testing, or working with different technologies.

Through this project, I want to see how effectively a model can recognize these differences and classify posts based on the type of technical insight being shared.

---

## Label Taxonomy

### `technical_explanation`

**Definition:** A comment that explains how or why a technology works using specific technical details, mechanisms, or supporting evidence.

**Example 1:**
> It is significantly faster than llama.cpp on some tasks like prefill (decode is memory bandwidth constrained so language hardly makes a difference).

**Example 2:**
> The hardware supports it, but then Nvidia disabled it if the driver detects cheaper cards. This bypasses the NVidia slowdown.

### `prediction`

**Definition:** A comment that makes predictions or assumptions about how technology might evolve, perform, or impact the future.

**Example 1:**
> Considering the sheer volume GitHub received lately I wouldn’t be surprised if GitLab would experience similar issues unless self hosted.

**Example 2:**
> Building a new pro-level app with its own UI paradigms and concepts is going to be the next frontier. Give it 6 to 12 months, I'd say.

### `real_world_experience`

**Definition:** A comment that shares firsthand experiences, implementation challenges, or practical lessons learned from working with technology.

**Example 1:**
> I wanted to spend the weekend by trying to create a shared endless canvas. I was sure it would be quite possible with today's best AI [...] Eventually it took me months to complete.

**Example 2:**
> I used to get the OS out of space warning a lot from macOS. I used to have a 128GB SSD, and Adobe would fill up the drive with cache in the Application Support folder frequently.

### The Hardest Boundary

**Which two labels:** `technical_explanation` and `real_world_experience`

**The decision rule I used every time:**

The hardest distinction is between technical explanations and real-world experiences, since users often explain how something works through their own experiences.

If a comment primarily focuses on explaining the underlying technical mechanism or behavior of a system, I will classify it as `technical_explanation`. However, if the comment mainly describes something the user personally built, tested, encountered, or learned through experience, I will classify it as `real_world_experience`, even if technical details are included.

For posts that contain multiple elements, I will prioritize the main purpose of the comment rather than individual keywords.

---

## The Dataset

I collected 499 public comments from Hacker News using the
Algolia API, focusing on discussions surrounding AI, software
engineering, GPUs, databases, and other technical topics.

From these comments, I selected 200 examples and classified
them into three categories:

| Label | Count | Percentage |
|---|---:|---:|
| technical_explanation | 84 | 42% |
| prediction | 57 | 28.5% |
| real_world_experience | 59 | 29.5% |

I personally labeled the first 20 comments without any
assistance. For the remaining 180, I used a rule-based script
that suggested labels based on language patterns and keywords.
I reviewed each comment, correcting suggestions when needed
and skipping comments that didn't fit my categories.

I think one of the biggest challenges was how much overlap
there can be between technical explanations and real-world
experiences. A lot of users explain how something works
through their own experiences, which definitely makes
classifying them more complicated.

---


**Three hard cases**

**1.**
> **The post:**
> I'm going to predict right now, as I weep into my coffee, massive centralized AI traffic monitoring is the only way that we fix this. The attack surface is effectively infinite as you look across all of the home routers, Keurigs, iot's, and mobile devices - and security has historically ranged from reactive to uninterested by people, companies, and government.

> **Could have been:** `prediction` or `technical_explanation`

> **I chose, because:** I chose `prediction` because although the author discusses real technical concerns surrounding cybersecurity and IoT devices, the main argument focuses on what they believe will become necessary in the future. Personally, I think the technical details support their prediction rather than explain how a specific system works.

**2.**
> **The post:**
> A substantial percentage of AI criticism can boil down to some form of gatekeeping. Maybe AI can't draw a true Scotsman but many will still enjoy the result.

> **Could have been:** `prediction` or `real_world_experience`

> **I chose, because:** I initially found this difficult because the author is making a general observation about people's attitudes toward AI, rather than a clear technical prediction. I kept it as `prediction` because the author suggests that people will continue enjoying AI-generated content regardless of criticism. However, I think this is definitely a weaker fit for my taxonomy since it is mainly an opinion.

**3.**
> **The post:**
> fund OSS? very tough thing because of how software ecosystem has changed because of AI. It's said but we can't do anything but suffer since AI is causing future vulnerabilities which will cause deadlocks later.

> **Could have been:** `prediction` or `technical_explanation`

> **I chose, because:** I chose `prediction` because the author discusses how AI might affect open-source software and introduces concerns about future vulnerabilities. While the comment mentions technical issues, it doesn't really explain the underlying mechanisms. I think the main focus is predicting potential consequences rather than explaining how something works.

---

## The Training Run

**Base model:** DistilBERT (pretrained text classification model)

**Settings:**
- Epochs: 3
- Learning rate: 2e-5
- Batch size: 16
- Random seed: 42
- Maximum sequence length: 128 tokens
- Device: CPU (PyTorch 2.14.1+cpu)

**Anything I changed from the defaults, and why:**

I kept the default training hyperparameters because I wanted to
see how well the model would perform before making any adjustments.
The main change I made was updating the label configuration to
match my three categories: technical explanations, predictions,
and real-world experiences.

Personally, I think starting with the default settings gives
me a better understanding of what the model initially struggles
with before experimenting with different configurations.

**Split sizes:**
- Training: 140 posts (70%)
- Validation: 30 posts (15%)
- Testing: 30 posts (15%)

**Test set distribution:**
- `technical_explanation`: 13 posts
- `prediction`: 8 posts
- `real_world_experience`: 9 posts

**Initial Training Results:**

| Metric | Result |
|---|---:|
| Overall accuracy | 43.33% |
| Macro F1 | 0.202 |
| Technical explanation F1 | 0.605 |
| Prediction F1 | 0.000 |
| Real-world experience F1 | 0.000 |
| High-confidence accuracy | 70% |

One thing I found very interesting was that the model classified
every single test post as a technical explanation. Even though
my dataset was relatively balanced, the model still struggled
a lot with distinguishing between the three categories.

I think this is something worth investigating in the next unit,
particularly whether the issue comes from overlapping technical
language, the quality of my labels, or the model's training
configuration.

---

## How I Used AI

**Moment 1**

- **What I asked for:** I used ChatGPT to help me explore different ways to classify discussions from Hacker News. Initially, I was considering more general labels like evidence, opinion, and questions, but I wanted something more specific to technology and software engineering.

- **What came back:** ChatGPT helped think about characteristics for categorizing posts based on technical explanations, predictions, and real-world experiences. It also helped me think through the differences between these categories and situations where they might overlap.

- **What I changed:** I refined the label names and definitions to make them easier to understand and more relevant to what I wanted to measure. Personally, I felt these categories would be a lot more interesting to explore because they focus on how people discuss technology rather than simply whether they agree or disagree.

**Moment 2**

- **What I asked for:** I asked ChatGPT to help me automate collecting real Hacker News comments and make the labeling process more efficient, since manually collecting and organizing 200 posts would take a lot of time.

- **What came back:** ChatGPT helped me develop PowerShell scripts that collected 499 public comments using the Hacker News Algolia API. It also provided a separate script that suggested labels based on keywords and language patterns.

- **What I changed:** I reviewed the collected comments and independently labeled my first 20 examples. For the remaining posts, I used the suggested labels as a starting point, correcting classifications when necessary and skipping posts that didn't fit my categories. I ended up with 200 labeled examples.

**Pre-labelling disclosure:**

I used a rule-based PowerShell script to generate preliminary labels for 180 of my 200 examples. The script looked for specific keywords and phrases associated with each category rather than using a trained AI model.

I personally labeled the first 20 examples without assistance and reviewed the remaining 180 suggestions before including them in my dataset.

I think this approach made the process a lot more efficient while still allowing me to make the final decisions about how each comment should be classified. I definitely noticed that keyword-based suggestions weren't always accurate, especially when posts discussed technical concepts through personal experiences.

<!-- ═══════════════════════ UNIT 6 — THE TEST ═══════════════════════

     Don't fill these in during unit 5.
     ═══════════════════════════════════════════════════════════════════ -->

---

## Baseline vs. Trained

<!-- Both models on the same posts. `python baseline.py --trained results.json`
     prints this table for you. -->

| Measure | Baseline | Trained | Difference |
|---|---|---|---|
| Overall accuracy |  |  |  |
| Macro F1 |  |  |  |
| F1 — `label_one` |  |  |  |
| F1 — `label_two` |  |  |  |

**What I predicted before I looked:**
<!-- Milestone 1 asks you to write this BEFORE seeing the trained numbers. A
     prediction made afterwards isn't one. -->

**What the gap actually means:**
<!-- If the baseline matched your trained model, your fine-tuning added
     nothing — and that is a real finding, not a failure. Say it plainly. -->



---

## Run Log — Before

<!-- Five criteria across three seeds. The notebook's section 6 prints the
     spread table; the Target and Verdict columns are yours. -->

| Criterion | Target | Seed 42 | Seed 7 | Seed 2024 | Verdict |
|---|---|---|---|---|---|
| 1.  |  |  |  |  |  |
| 2.  |  |  |  |  |  |
| 3.  |  |  |  |  |  |
| 4.  |  |  |  |  |  |
| 5.  |  |  |  |  |  |

### Confusion matrix

<!-- ⚠️ TYPED AS A MARKDOWN TABLE. The notebook prints one ready to paste.
     An image of a matrix earns nothing. -->

| true \ predicted |  |  |  |
|---|---|---|---|
| **** |  |  |  |
| **** |  |  |  |
| **** |  |  |  |

**My biggest off-diagonal number, and what it means:**
<!-- Not "the model made mistakes" — WHICH boundary it didn't learn, and which
     direction. "7 real analysis posts were called hot_take and only 3 went the
     other way" is a direction, not just an error rate. -->



---

## Verdicts and Diagnoses

<!-- MET or MISSED against LAST UNIT's target. The target has to hold across
     all three seeds, not turn up sometimes. -->

| # | Criterion | Target | Verdict | How I decided |
|---|---|---|---|---|
| 1 |  |  |  |  |
| 2 |  |  |  |  |
| 3 |  |  |  |  |
| 4 |  |  |  |  |
| 5 |  |  |  |  |

**Diagnoses**

<!-- For each miss: the cause, and how you know. The four common causes are:
     too few examples for a label, a boundary you applied inconsistently, a
     genuinely hard label pair, and a task the model can't reach from this
     much data.

     ⚠️ Use your agreement report as evidence. It is the only instrument you
     have that can tell a LABELLING problem from a MODEL problem, and this
     section is graded on whether you used it that way. -->



---

## Agreement Report

<!-- Your rate against the staff set, and every disagreement adjudicated.

     Remember you labelled these 30 under the STAFF taxonomy in
     data/staff_taxonomy.md, not your own — so every argument below is made
     from those definitions and those decision rules. -->

**Agreement rate:** ___ / 30 = ___%

<!-- Nobody grades this number. A 60% who argues every disagreement from the
     stated rules beats a 95% who wrote "staff was right" nine times. Several
     of the 30 were chosen because they're genuinely ambiguous — you should be
     winning some of these. -->

**Disagreements**

<!-- Three lines each: the post, both labels, and who you think is right and
     why — grounded in the staff definitions you were both applying.

     Then sort each into one of three piles:
       (a) the rule covered it and I applied it loosely → a consistency problem
       (b) the rule genuinely doesn't say               → a gap in the definitions
       (c) the rule is ambiguous here and my reading is defensible → argue it.
           This is a legitimate win.

     Pile (a) is the one that matters most for your diagnosis: if you applied a
     written rule two different ways on 30 posts, that is direct evidence about
     what you did across your own 200. -->

**1.**
> *The post:*
>
> *Staff said / I said:*
>
> *My call, and why:*
>
> *Which pile:*

**2.**
> *The post:*
>
> *Staff said / I said:*
>
> *My call, and why:*
>
> *Which pile:*

**What the pattern in my disagreements tells me:**



---

## The Improvement

**What I changed:**

**Which diagnosis pointed at it:**

### Run Log — After

| Criterion | Target | Seed 42 | Seed 7 | Seed 2024 | Verdict |
|---|---|---|---|---|---|
| 1.  |  |  |  |  |  |
| 2.  |  |  |  |  |  |
| 3.  |  |  |  |  |  |
| 4.  |  |  |  |  |  |
| 5.  |  |  |  |  |  |

**Did it help, and how do I know:**

<!-- If it didn't, say so. Relabelling that didn't help is a genuinely
     interesting result and earns full credit. -->



---

## What's Still Broken

<!-- For each criterion still missed: what you'd do, and why you stopped. -->



**The gap between what I meant my labels to capture and what the model
learned:**
<!-- Two sentences. Your confusion matrix is the evidence. -->



<!-- ═════════════════════════════════════════════════════════════════════

     SUBMISSION CHECKLIST — unit 5

       [ ] criteria.md has five numbered criteria, each naming a NUMBER
       [ ] Each has a reason underneath tied to your data or taxonomy
       [ ] labels.csv: at least 150 rows, text/label/note, ONE file not split
       [ ] No label above 70%
       [ ] All five unit 5 sections have real content
       [ ] Label Taxonomy includes the decision rule for your hardest boundary
       [ ] The Dataset includes three hard cases
       [ ] results.json and test_split.csv committed (the notebook does this)
       [ ] At least four new commits
       [ ] Repository URL submitted — WRITE IT DOWN

     SUBMISSION CHECKLIST — unit 6

       [ ] Baseline vs. Trained table, with your prediction written beforehand
       [ ] Run Log — Before, five criteria across three seeds
       [ ] Confusion matrix TYPED AS A MARKDOWN TABLE
       [ ] A verdict on every criterion
       [ ] A diagnosis for every miss, using the agreement report as evidence
       [ ] Agreement Report with every disagreement adjudicated
       [ ] One improvement, with Run Log — After
       [ ] What's Still Broken
       [ ] results_three_seeds_before.json, results_three_seeds_after.json,
           baseline_results.json and
           agreement_results.json committed
       [ ] At least four new commits
       [ ] The SAME repository URL as last unit

     Do not delete and recreate this repository.
     ═════════════════════════════════════════════════════════════════════ -->

---

📖 **How to run this project: [RUNNING.md](RUNNING.md)**
