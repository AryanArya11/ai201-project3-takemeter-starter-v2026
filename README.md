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
Before running the baseline, I think the general model
might outperform my fine-tuned model because my original
model classified every test post as a technical explanation.

Personally, I feel that providing the model with clear label
definitions could help it distinguish predictions and
real-world experiences more effectively.

**What the gap actually means:**
<!-- If the baseline matched your trained model, your fine-tuning added
     nothing — and that is a real finding, not a failure. Say it plainly. -->

I found it very interesting that my fine-tuned model achieved a higher overall accuracy of 43.3% compared to the baseline's 36.7%, but actually performed worse across the labels overall.

The baseline achieved a higher macro F1 score, meaning it was more effective at recognizing the different categories rather than focusing on just one. My fine-tuned model performed better on technical explanations, but failed to correctly classify any predictions or real-world experiences.

I think this demonstrates that fine-tuning doesn't necessarily guarantee better performance. In my case, the model seems to have learned to favor technical explanations, even though my dataset was relatively balanced.

Personally, I want to explore whether this behavior comes from overlapping language between my categories, the limited amount of training data, or the training settings themselves.

---

## Run Log — Before


## Run Log — Before

| Criterion | Target | Seed 42 | Seed 7 | Seed 2024 | Verdict |
|---|---|---|---|---|---|
| 1. Overall accuracy | >= 70% | 43.3% | 43.3% | 43.3% | MISSED |
| 2. Minimum F1 for every label | >= 0.60 | 0.000 | 0.000 | 0.000 | MISSED |
| 3. Maximum dataset label share | <= 60% | 42% | 42% | 42% | MET |
| 4. Human label agreement | >= 80% | 66.7% | N/A | N/A | MISSED |
| 5. High-confidence accuracy | >= 80% | 70% | 80% | 50% | MISSED |



### Performance Across Three Seeds

| Measure | Seed 42 | Seed 7 | Seed 2024 | Spread |
|---|---|---|---|---|
| Overall accuracy | 0.433 | 0.433 | 0.433 | 0.000 |
| Macro F1 | 0.202 | 0.202 | 0.202 | 0.000 |
| F1 — `technical_explanation` | 0.605 | 0.605 | 0.605 | 0.000 |
| F1 — `prediction` | 0.000 | 0.000 | 0.000 | 0.000 |
| F1 — `real_world_experience` | 0.000 | 0.000 | 0.000 | 0.000 |

**What I noticed:**

I found it very interesting that all three training runs produced
exactly the same results, even though I changed the random seed
each time.

Personally, I think this suggests that the model is consistently
struggling to distinguish between my categories rather than
simply performing poorly because of one unlucky data split.

Although the accuracy was stable at 43.3%, the model achieved
an F1 score of 0 for predictions and real-world experiences
across all three seeds. I definitely think this points toward
a more fundamental issue with how the model learned the
differences between these labels.



### Confusion Matrix

| true \ predicted | technical_explanation | prediction | real_world_experience |
|---|---|---|---|
| **technical_explanation** | 13 | 0 | 0 |
| **prediction** | 8 | 0 | 0 |
| **real_world_experience** | 9 | 0 | 0 |


**My biggest off-diagonal number, and what it means:**
<!-- Not "the model made mistakes" — WHICH boundary it didn't learn, and which
     direction. "7 real analysis posts were called hot_take and only 3 went the
     other way" is a direction, not just an error rate. -->

The biggest confusion was between real-world experiences and
technical explanations. The model incorrectly classified all
9 real-world experience posts as technical explanations,
while none of the technical explanations were classified
as real-world experiences.

I think this shows that the model learned to heavily favor
technical explanations rather than recognizing the differences
between my categories. Personally, I feel that the overlapping
technical language might be contributing to this, but I
would need to investigate my labeling consistency further
to understand why this happened.

---

## Verdicts and Diagnoses

| # | Criterion | Target | Verdict | How I decided |
|---|---|---|---|---|
| 1 | Overall accuracy | >= 70% | MISSED | All three seeds achieved 43.3% accuracy, which was below my target. |
| 2 | Minimum F1 for every label | >= 0.60 | MISSED | Both `prediction` and `real_world_experience` achieved an F1 of 0.000 across all three seeds. |
| 3 | Maximum dataset label share | <= 60% | MET | My largest category was `technical_explanation` at 84 out of 200 posts, or 42%. |
| 4 | Human label agreement | >= 80% | MISSED | I agreed with the staff on 20 out of 30 posts, giving me 66.7% agreement. |
| 5 | High-confidence accuracy | >= 80% | MISSED | The most-confident third achieved 70%, 80%, and 50% accuracy across the three seeds. Only seed 7 met my target. |

### Diagnoses

**1. Overall Accuracy**

I think the biggest issue with my model was that it learned to predict
`technical_explanation` for every single test example. Even though my
dataset was relatively balanced, the model didn't learn to distinguish
between the other two categories.

All three seeds achieved the same 43.3% accuracy, which makes me feel
that the issue wasn't just one unlucky split. I think the model may
need stronger training signals to recognize the differences between
my categories.

**2. Per-Label Performance**

Personally, I found this result very interesting because
`technical_explanation` achieved an F1 of 0.605, while both
`prediction` and `real_world_experience` achieved 0.000.

The confusion matrix showed that all 8 prediction posts and all 9
real-world experience posts were classified as technical explanations.

I think the model struggled a lot with distinguishing technical
terminology from the actual purpose of a comment.

**3. Dataset Balance**

This criterion was met because my largest category represented only
42% of the dataset.

I think this is important because it shows that the model's behavior
cannot simply be explained by an extremely unbalanced dataset.
However, having a relatively balanced dataset clearly wasn't enough
to guarantee balanced predictions.

**4. Human Label Agreement**

I missed my 80% agreement target, achieving 66.7% instead.

One thing I noticed was that I classified 8 of the 10 disagreements
as reactions, while the staff classified those posts as either
analysis or hot takes.

I think I relied too heavily on whether a post sounded personal
rather than checking whether it contained evidence or made a
general claim.

Although the staff exercise used a different taxonomy from my
Hacker News dataset, it suggests that I may have applied some
of my own label boundaries inconsistently as well.


**5. Prediction Confidence**

I missed my 80% confidence accuracy target in two out of
three training runs. Seed 42 achieved 70%, seed 7 achieved
80%, and seed 2024 only achieved 50%.

Personally, I think this is interesting because overall
accuracy stayed exactly the same across all three seeds,
but the model's high-confidence predictions varied a lot.

The spread was 30 percentage points, which makes me feel
that the model's confidence isn't very reliable yet.

I think this could be related to the model consistently
favoring technical explanations without properly learning
the differences between all three categories.


---


## Agreement Report

**Agreement rate:** 20 / 30 = 66.7%

After comparing my labels with the staff's labels, I agreed on 20 out
of 30 posts. Personally, I think the biggest issue was how I
interpreted the `reaction` category. I initially classified a lot
of personal experiences as reactions, even when those experiences
included specific evidence supporting an argument.

### Disagreements

**1. Sleep and training performance (sp_002)**

> I tracked sleep against session quality for eleven weeks. Under seven hours the next day's intervals were 6-8 seconds per mile slower, every time bar one. Small sample, one runner, but it's consistent enough that I've stopped scheduling hard days after late shifts.

- **Staff said:** `analysis`
- **I said:** `reaction`
- **My call:** I think the staff's classification is more accurate because the author uses eleven weeks of observations and specific performance numbers to support their conclusion. I focused too much on the personal experience.
- **Pile:** A — I applied the rule too loosely.

**2. Club championship scoring (sp_003)**

> The club championship scoring changed in 2019 from top-6 to top-10. Since then our B team has finished above the A team twice. That's not depth improving, it's the scoring rewarding turnout.

- **Staff said:** `analysis`
- **I said:** `hot_take`
- **My call:** I agree with the staff because the author identifies a specific rule change and its consequences. The facts are being used to support the argument rather than simply expressing an opinion.
- **Pile:** A — I overlooked the supporting evidence.

**3. The hill at mile 18 (sp_004)**

> Everyone blames the hill at 18 miles. I split the field into people who ran the first half under 1:45 and over, and the slowdown after 18 was almost identical for both groups. If the hill were the problem the fast starters would fall apart harder.

- **Staff said:** `analysis`
- **I said:** `reaction`
- **My call:** I think `analysis` makes more sense because the author separates runners into two groups and uses their results to challenge an explanation. This is definitely an argument supported by evidence.
- **Pile:** A — The rule already covered this.

**4. Carbon plates and mileage (sp_005)**

> Carbon plates aren't the whole story. My times dropped 2% in the shoes and another 2% the following year in the same pair, when the only thing that changed was going from 35 to 50 miles a week.

- **Staff said:** `analysis`
- **I said:** `reaction`
- **My call:** Personally, I can see why this is difficult because the author discusses their own running experience. However, the two percentage changes are being compared to support the argument about training mileage. I think `analysis` is ultimately the stronger choice.
- **Pile:** C — Both interpretations initially seemed defensible, but the evidence favors analysis.

**5. First-time race participants (sp_006)**

> Checked the entry lists. 41% of this year's field have never run the distance before, against 26% five years ago. That's why the finish-line photos look different, not because standards dropped.

- **Staff said:** `analysis`
- **I said:** `hot_take`
- **My call:** I think the staff is right that the statistics support the argument about participation changing over time. Although the explanation about finish-line photos is an inference, the author uses the percentages to justify that interpretation.
- **Pile:** C — The connection between the numbers and the conclusion still requires interpretation.

**6. Running in different temperatures (sp_007)**

> Ran the same loop in 4C and in 24C within a fortnight, same effort by heart rate. 90 seconds slower in the heat over six miles. People keep saying heat costs you 'a bit' and it's more than that.

- **Staff said:** `analysis`
- **I said:** `reaction`
- **My call:** I originally focused on the author's personal experience, but I think this is better classified as analysis. The author compares two temperatures while controlling for effort and uses the result to support their conclusion.
- **Pile:** A — I applied the reaction definition too broadly.

**7. Comparing running shoes (sp_010)**

> Three of us ran the same session on the same day, different shoes, within 10 seconds of each other over 5 miles. I'm not saying shoes do nothing, but whatever they do was smaller than the noise between three people.

- **Staff said:** `analysis`
- **I said:** `reaction`
- **My call:** I think this is one of the harder examples because it describes an experience involving only three runners. However, the comparison is still used to make a specific argument about shoe performance. I would lean toward the staff's `analysis` label.
- **Pile:** C — The personal observation and analytical conclusion overlap.

**8. Track sessions and running pace (sp_018)**

> Track sessions are wasted on anyone running slower than 8 minute miles. You'd get more out of just running more.

- **Staff said:** `hot_take`
- **I said:** `reaction`
- **My call:** I agree with the staff because the author is making a general claim about runners without providing supporting evidence. It doesn't describe something that just happened to the writer.
- **Pile:** A — I confused a strong opinion with a reaction.

**9. Enjoying long runs (sp_019)**

> Nobody actually enjoys the long run. They enjoy having done it, which is a completely different thing, and the sport would be more honest if it said so.

- **Staff said:** `hot_take`
- **I said:** `reaction`
- **My call:** I initially interpreted this as a personal reflection about running. However, the author is making a general statement about everyone, rather than describing their own immediate experience. I think `hot_take` is more accurate.
- **Pile:** A — The decision rule already explains this boundary.

**10. Injury discussion threads (sp_020)**

> Every injury thread on this forum is the same injury and the same three replies.

- **Staff said:** `hot_take`
- **I said:** `reaction`
- **My call:** I think this is somewhat ambiguous because the claim could theoretically be checked against previous discussions. However, the author doesn't actually provide examples or evidence. Since it's a general statement rather than an immediate personal response, I think `hot_take` fits better.
- **Pile:** C — The statement sounds observational, but doesn't provide checkable supporting evidence.

### What the pattern in my disagreements tells me

The biggest pattern I noticed was that I classified eight of my ten
disagreements as `reaction`, while staff classified those same posts
as either `analysis` or `hot_take`.

I think this shows that I relied too heavily on whether a comment
sounded personal or emotional rather than looking at the actual
argument being made.

Personally, I feel that my biggest improvement would be applying
the decision rules more consistently, especially the distinction
between personal experiences and arguments supported by evidence.

This also makes me question whether similar inconsistencies could
exist in my original 200 Hacker News labels, particularly between
`technical_explanation` and `real_world_experience`.

---

**What I changed:**

I increased the training epochs from 3 to 5 while keeping
the dataset, labels, learning rate, batch size, and random
seeds unchanged.

**Which diagnosis pointed at it:**

My original model classified every test example as a
technical explanation across all three seeds. I wanted
to test whether additional training would help the model
learn the differences between categories.

### Run Log — After

<!-- Add the actual results when training finishes. -->

**Did it help, and how do I know:**

The improvement is being evaluated using the same three
random seeds. I will compare the accuracy, per-label F1,
and high-confidence accuracy against the original runs.

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

My biggest issue is that TakeMeter consistently favors
technical explanations over predictions and real-world
experiences. Across my original three training runs, the
model achieved 43.3% accuracy and completely failed to
recognize two of my three categories.

I also missed my human agreement target, achieving 66.7%.
Personally, I think my labeling process could be improved
by applying the decision rules more consistently.

If I had more time, I would review the boundaries between
my categories, collect additional examples, and experiment
with different training configurations.

**The gap between what I meant my labels to capture and what the model learned:**

I wanted TakeMeter to distinguish between different types
of technical discussions, but my confusion matrix showed
that the model learned to predict technical explanations
almost exclusively. I think this demonstrates how a model
can appear consistent without actually learning the
distinctions I originally intended.

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
