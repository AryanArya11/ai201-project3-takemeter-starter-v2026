# Acceptance criteria — TakeMeter

Five criteria that say what "working" means for this classifier, written in
unit 5 **before** anything was trained.

**All five are yours this time.** None are given. You've had two projects of
practice.

An acceptance criterion names a number. *"The model is accurate"* is an
opinion. *"Every label has an F1 of at least 0.60 on the held-out set"* is a
criterion.

Under each, write a sentence or two on **why that number**. A reason that says
something about your data or your taxonomy earns credit — *"I picked 0.60 F1
for `reaction` because it's my smallest label and I only have about 50
examples of it"*. A reason that could be attached to any project does not.

> Missing your own targets next unit costs you nothing. Setting a target so
> easy you can't miss it does.

---

## Pick numbers you can defend

Not numbers that sound impressive. Three labels means a coin-flip guesser gets
about 33%, so a target of 0.40 is barely a target. Your number should sit
somewhere you'd honestly call useful.

**Cover at least three of these five areas.** They're here as prompts, not as a
form to fill in — a criterion that fits none of them is fine if it names a
number.

| Area | A question it could answer |
|---|---|
| Overall accuracy | How often does it need to be right to be worth using? |
| Per-label performance | Is one label allowed to be much worse than the others? |
| Balance | How lopsided can your label counts get before it's a problem? |
| Consistency | If someone else labelled the same posts, how often should you agree? |
| Confidence | Should a confident prediction be right more often than an unsure one? |

Two things worth knowing before you pick numbers, because both will affect
whether you hit them:

- **Your smallest label will have the jumpiest score.** If a label has 50
  examples, about 8 land in the test split. An F1 computed on 8 examples moves
  a lot between seeds. A target for that label should be looser than one for
  your biggest label, and saying so is a good reason.
- **Unit 6 tests across three seeds, and the target has to hold across all
  three.** A target of 0.65 against results of 0.71, 0.62, 0.68 is a **miss**.
  Pick with that in mind — it is stricter than it first sounds.

---

# Acceptance Criteria — TakeMeter

These five criteria define what I personally consider a successful
classifier before training the model. I want to understand how well
TakeMeter can distinguish between technical explanations, predictions,
and real-world experiences, especially since I feel there can be a
lot of overlap between these categories.

## 1. Overall Accuracy

**Target:** The model must achieve at least 70% accuracy on the
held-out test set.

**Why this target:**

I think 70% is a reasonable target because we are working with three
different labels, and I want the model to perform significantly better
than random guessing. Personally, I feel that correctly classifying
at least 7 out of 10 posts would be a good indication that the model
is actually learning the differences between these discussions.

---

## 2. Per-Label Performance

**Target:** Every label must achieve an F1 score of at least 0.60
on the held-out test set.

**Why this target:**

I don't want the model to perform very well on one category while
struggling a lot with the others. I think an F1 score of 0.60 for
every label is a fair starting point, especially because technical
explanations and real-world experiences can be very similar. I
definitely want the model to recognize all three categories
consistently rather than favoring just one.

---

## 3. Dataset Balance

**Target:** No single label should represent more than 60% of
the 200 labeled examples.

**Why this target:**

I think having a balanced dataset is very important because I
don't want the model to simply learn to predict whichever label
appears most frequently. Personally, I feel that keeping each
category below 60% gives the model a better opportunity to learn
from different types of discussions without becoming overly
dependent on one category.

---

## 4. Human Label Agreement

**Target:** My labels must agree with an independent human
annotator on at least 80% of the same posts.

**Why this target:**

I think this is one of the more important criteria because even
if the model performs well, the labels themselves need to make
sense to other people. Since some technical discussions can fit
multiple categories, I don't expect perfect agreement. However,
I feel that 80% agreement would demonstrate that my definitions
and decision rules are clear enough for someone else to apply
them consistently.

---

## 5. Prediction Confidence

**Target:** The model must achieve at least 80% accuracy on
the one-third of held-out predictions with the highest
confidence scores.

**Why this target:**

Personally, I think it's important that the model's confidence
actually reflects how reliable its predictions are. If the
model is very confident about a classification, I would expect
it to be correct most of the time. I chose 80% because I feel
that confidence should mean something beyond just producing
a prediction, especially if this classifier were eventually
used on a much larger collection of posts.

---

<!-- ─────────────────────────────────────────────────────────────────────────
     UNIT 6 — read this before you change anything above.

     If a criterion turns out to be BROKEN rather than merely unmet, you can
     revise it, and that earns credit. But never delete or edit the original
     line. Add the revision underneath, like this:

         ## 2. Every label performs acceptably

         The model performs well on all labels.

         **Why this target:** ...

         > **Revised in unit 6:** Every label has an F1 of at least 0.60 on
         > the held-out set.
         >
         > **Why revised:** "performs well" gave me nothing to check. I
         > couldn't produce a verdict from it at all.

     That's a revision because the criterion couldn't be MEASURED.

     Lowering a target because you missed it is not a revision, and it costs
     you the point:

         ✗ "Overall accuracy of at least 0.65" → "at least 0.55", because
            0.65 turned out to be optimistic for 200 examples.

     A number you missed stays where it is, gets diagnosed, and gets a fix
     attempted. That's where the points are.
     ───────────────────────────────────────────────────────────────────────── -->
