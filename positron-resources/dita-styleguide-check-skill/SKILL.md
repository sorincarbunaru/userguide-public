---
name: dita-styleguide-check
description: Check a DITA topic (or a set of topics) for style guide adherence, fix the problems found, and report the results. Use this skill when the user asks to check, review, audit, or enforce the style guide, writing rules, markup rules, or terminology in DITA documents. The skill covers titles, short descriptions, IDs, semantic markup (uicontrol, codeph), cross-reference text, index terms, sentence style, and terminology. It also runs a terminology check and the project Schematron rules (DITA/rules/rulesAdvanced.sch).
---

# DITA Style Guide Check

## Purpose

Use this skill to check DITA documents against the project style guide. The skill works in four phases:

1. **Find** the problems and report them.
2. **Fix** the problems that can be fixed safely.
3. **Report** what was changed and how.
4. **Recommend** a human review.

## Scope

- If the user names one or more files, check those files.
- If the user does not name a file, check the document in the current editor.
- If the user asks to check a map or a folder, check each referenced topic. For many topics, ask the user to confirm the scope before you change files.

## Style Guide Rules

Check each document against the rules below. Give each rule a short ID so that the report can refer to it.

| ID | Rule | How to check |
|----|------|--------------|
| SG-01 | Has a clear, task-focused title. | The `<title>` states what the topic covers or what the user can do. For task topics, start the title with a verb in gerund or imperative form (for example, "Configuring..." or "Configure..."). Flag vague titles such as "Overview", "Misc", "Notes", or "General". |
| SG-02 | Has a short description when the document type allows one. | Topics (`concept`, `task`, `reference`, `troubleshooting`, `topic`, and their specializations) need a `<shortdesc>` (or an `<abstract>` that contains a `<shortdesc>`). Keep it to one or two sentences. Do not repeat the title. |
| SG-03 | Uses descriptive and unique IDs. | The root `@id` and the `@id` values of elements describe the content (for example, `configure-proxy`, not `topic_abc123` or `section_1`). IDs must be unique in the document. Use `grep_project` to check that a topic ID is unique in the project when needed. |
| SG-04 | Uses `<uicontrol>` for user-interface labels. | Button names, menu items, field labels, tab names, and dialog box options are marked with `<uicontrol>`. Menu paths use `<menucascade>` with `<uicontrol>` children. Window and dialog box titles use `<wintitle>`. Flag labels marked with `<b>`, `<i>`, quotes, or no markup. |
| SG-05 | Uses `<codeph>` for inline code and commands. | Inline code, commands, function names, and short code snippets are in `<codeph>` (or a more specific semantic element such as `<cmdname>`, `<filepath>`, `<xmlelement>`, `<xmlatt>`, `<parmname>`, `<varname>`, `<userinput>`, `<systemoutput>`). Flag code marked with `<tt>`, `<b>`, quotes, or no markup. |
| SG-06 | Uses meaningful cross-reference text. | `<xref>` and `<link>` text describes the target. Flag text such as "click here", "here", "this topic", "this link", "more", "read more", or "see this". When an `<xref>` has no text, check that the target title gives enough context. |
| SG-07 | Includes relevant index terms in the prolog metadata, when the project requires them. | Index terms go in `<prolog>/<metadata>/<keywords>/<indexterm>`. They must not appear in the topic body (the project Schematron also reports this). Check whether other topics in the project use index terms before you add new ones. If the project uses them, add relevant terms. Reuse existing index term wording from the project when possible. |
| SG-08 | Uses short, direct sentences and active voice. | Flag sentences longer than about 25 words, passive voice (for example, "is displayed", "can be configured", "was created"), filler words ("in order to", "basically", "simply", "please note that"), metaphors, and jargon. Address the user as "you" and use the imperative mood in steps. |
| SG-09 | Does not introduce new terminology when an established project term exists. | Compare terms in the document with the terms used in the project and in the terminology check. Use `search_project_resources` or `grep_project` to find the established term. Flag synonyms that compete with an established term (for example, "pop-up" when the project uses "dialog box"). Use `get_dita_keyrefs` to find product names that must be replaced by key references. |

## Workflow

### Phase 1: Find the problems

For each document in scope:

1. Read the document with `get_document_content` (or use the inline attachment if one is provided).
2. Use `evaluate_xpath` to locate elements quickly. Useful expressions:
   - Title and short description: `/*/title`, `/*/shortdesc`, `/*/abstract/shortdesc`
   - IDs: `//@id`, and duplicate IDs: `//@id[count(//@id[. = current()]) > 1]` (or compare the values manually)
   - Weak link text: `//xref[matches(lower-case(normalize-space(.)), '^(click here|here|this topic|this link|more|read more|see this)$')]`
   - Formatting used instead of semantic markup: `//b | //i | //tt | //u`
   - Index terms outside the prolog: `//indexterm[not(ancestor::prolog)]`
   - Index terms in the prolog: `/*/prolog/metadata/keywords/indexterm`
3. Check each style guide rule (SG-01 to SG-09) against the content.
4. **Check terminology.** Call the `term_check_document_content` tool with the document URL. Record each reported problem, its location, and the suggested replacement. Treat these results as part of rule SG-09.
5. **Run the project Schematron rules.** Call the `validate_with_schematron` tool with:
   - `document_systemID`: the URL of the document to check.
   - `schematron_systemID`: the absolute path of `DITA/rules/rulesAdvanced.sch` in the current project root (for example, `<project root>/DITA/rules/rulesAdvanced.sch`). Build the absolute path from the project root given in the application context, because a relative path is resolved against the checked document.
   Record each reported problem with its location and severity.
6. Also run `validate_content` on the document to make sure it is valid DITA before you change it.

### Phase 2: Report the findings

Before you make changes, present a findings report to the user. Group the findings by source:

- **Style guide rules** (SG-01 to SG-09)
- **Terminology check** (`term_check_document_content`)
- **Schematron rules** (`rulesAdvanced.sch`)
- **DITA validation** (`validate_content`), if any errors exist

For each finding, give:

- The rule ID or source
- The location (element, line number, or a short quote of the text)
- A short description of the problem
- The planned fix, or "Needs human decision" if no safe fix exists

If no problems are found for a rule, say so in one line.

### Phase 3: Fix the problems

Fix the problems directly with `edit_document`. Use small, targeted replacements. Keep the original meaning of the text.

Apply these fix guidelines:

- **SG-01:** Rewrite vague titles so they state the topic purpose. Use the gerund form for task titles if other task titles in the project use it.
- **SG-02:** Add a `<shortdesc>` right after `<title>` (or `<titlealts>`). Write one or two sentences that summarize the purpose of the topic. Keep it under about 15 words where possible, because the Schematron warns about long short descriptions.
- **SG-03:** Rename generic or duplicate element IDs to descriptive ones. **Before you rename an ID**, use `grep_project` to search for references to it (in `@href`, `@conref`, `@conkeyref`, and `@keyref` values). Update all references in the same pass. Do not rename the root topic ID when other files reference it, unless you update every reference. If the update is risky, report it as "Needs human decision" instead.
- **SG-04:** Wrap UI labels in `<uicontrol>`. Convert menu paths to `<menucascade>`. Replace `<b>` or quotes around UI labels with `<uicontrol>`.
- **SG-05:** Wrap inline code and commands in `<codeph>` or a more specific semantic element. Replace `<tt>` with `<codeph>`.
- **SG-06:** Replace weak link text with text that describes the target. Read the target topic title to write accurate text, or remove the text so that the target title is used.
- **SG-07:** Move index terms from the body into `<prolog>/<metadata>/<keywords>`. Add relevant index terms only if the project uses them. Keep the element order in `<prolog>` valid.
- **SG-08:** Split long sentences. Rewrite passive sentences in active voice. Remove filler words. You can use `retrieve_ai_actions` and `invoke_ai_action` for readability or active voice improvements, but check that the result keeps the markup and meaning.
- **SG-09 and terminology problems:** Replace non-standard terms with the established project term or the replacement suggested by `term_check_document_content`. Replace hard-coded product names with key references from `get_dita_keyrefs`.
- **Schematron problems:** Fix each reported problem as described in the Schematron message (for example, set `@scope="external"` on external links, remove link text that repeats the `@href` value, merge consecutive lists, move index terms into the prolog).

Do not fix a problem when:

- The fix could change the technical meaning of the content.
- The fix needs information you do not have (for example, the correct name of a UI control).
- The fix affects many other files and the user did not ask for project-wide changes.

Mark these problems as "Needs human decision" in the final report.

After the fixes:

1. Run `validate_content` on each changed document. Fix any new validation errors and save again (up to 3 attempts).
2. Run `term_check_document_content` again and fix any new terminology problems.
3. Run `validate_with_schematron` with `rulesAdvanced.sch` again to confirm that the problems are gone.

### Phase 4: Report the fixes and recommend a human review

Present a final report with these sections:

1. **Summary** - The number of documents checked, problems found, problems fixed, and problems left open.
2. **Fixes applied** - For each fix: the rule ID or source, the location, what was wrong, and what was changed (show short before and after text when helpful).
3. **Open problems** - Problems not fixed and the reason, such as "Needs human decision" or "Missing information".
4. **Re-check results** - The results of the second run of DITA validation, the terminology check, and the Schematron validation.
5. **Human review recommendation** - Always recommend that a writer or editor review the changes. Point out the changes that most need review, such as:
   - Rewritten titles and new short descriptions
   - Renamed IDs and updated references
   - Rewritten sentences (to confirm the technical meaning did not change)
   - Terminology replacements
   - New index terms
   Suggest that the reviewer compare the changed files with the previous versions (for example, with the `compare_documents` tool or the version control history).

## Report Style

- Keep the report short and scannable. Use headings, bullet lists, or tables.
- Do not print the full document content unless the user asks for it.
- Refer to locations by element and line number when available.
