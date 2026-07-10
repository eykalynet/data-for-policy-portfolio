# Form Variable Notes

Some Google Form exports include the same question label more than once. In this survey, repeated labels usually come from branching logic: for example, a respondent may answer a school, household, or eligibility question under one branch if the previous answer was "yes" and under another branch if the previous answer was "no."

When Google Forms exports these repeated labels, later copies are given suffixes such as ` 2`, ` 3`, or ` 4`. After cleaning with `janitor::make_clean_names()`, those become suffixes such as `_2`, `_3`, or `_4`.

The scripts keep these repeated fields rather than dropping them automatically. They should be interpreted as branch-specific versions of the same underlying question, not as accidental duplicates. During analysis, the project team can decide whether to combine them into one canonical field or keep them separate for branch-level checks.
