---
name: batch-converter-docs-pr
description: Create a pull request that updates the user guide documentation based on a GitHub issue from the Batch Documents Converter repository. Use this skill when the user asks to document, describe, or create a docs pull request for a Batch Converter issue (for example, "create a PR for the docs based on batch converter issue 1"). When the user refers to the "batch converter" repo or project, always use the fork sorincarbunaru/oxygen-batch-converter-addon-fork.
---

# Batch Converter Docs Pull Request

## Purpose

Use this skill to turn a GitHub issue from the Batch Documents Converter project into a documentation update and a pull request for the user guide.

## Repositories

| Role | GitHub owner/repo | GitHub URL | Local folder | Default branch |
|------|-------------------|------------|--------------|----------------|
| Source of issues ("batch converter" repo or project) | `sorincarbunaru/oxygen-batch-converter-addon-fork` | https://github.com/sorincarbunaru/oxygen-batch-converter-addon-fork | Not needed (read issues on GitHub only) | `master` |
| Documentation (userguide repo, target of the pull request) | `sorincarbunaru/userguide-public` | https://github.com/sorincarbunaru/userguide-public | `C:\Users\SorinCarbunaru\Projects\userguide-public` | `master` |

The local folder of the userguide repo is a Git clone of `https://github.com/sorincarbunaru/userguide-public.git` (remote `origin`). All topic paths in this skill are relative to this folder. For example, `DITA/topics/batch-converter-addon.dita` is `C:\Users\SorinCarbunaru\Projects\userguide-public\DITA\topics\batch-converter-addon.dita`. When you push files with `github_push_files`, use the same relative paths (with forward slashes) as the `path` values.

**Important:** When the user says "batch converter", "batch documents converter", or "the converter repo", use `sorincarbunaru/oxygen-batch-converter-addon-fork`. Do **not** use the upstream `oxygenxml/oxygen-batch-converter-addon` repository and do not search GitHub for other repositories.

## What You Need

1. **The issue number.** If the user does not give one, ask for it.
2. **The issue details.** Read the issue with `github_issue_read` (`method: get`, and `method: get_comments` for extra context) in the fork.
3. **The documentation topics to update.** Start with these topics in the local userguide folder (`C:\Users\SorinCarbunaru\Projects\userguide-public`):
   - `DITA/topics/batch-converter-addon.dita` - the main topic for the Batch Documents Converter add-on.
   - `DITA/topics/scripting_oxygen_batch_converter.dita` - the Batch Converter command-line script.
   - Use `search_project_resources` or `grep_project` to find other related topics (for example, `dita-migrating-various-formats.dita` for new conversions to DITA).
4. **Access to GitHub tools** to create a branch, push files, and create the pull request.

## Workflow

1. **Read the issue.** Find out what changed in the converter (for example, a new conversion type, a new option, or a changed behavior).
2. **Find the affected topics.** Check how the existing documentation describes the feature. Follow the same structure and wording.
3. **Update the documentation locally.** Use `edit_document` with small, targeted edits. Keep the DITA valid. Run `validate_content` and `term_check_document_content` on each changed topic, and fix the problems found. If you create a new topic, add it to `DITA/UserManual.ditamap` with `add_dita_reference_to_ditamap`.
4. **Create a branch** in `sorincarbunaru/userguide-public` (https://github.com/sorincarbunaru/userguide-public) from `master`. Use a descriptive name, such as `batch-converter-issue-<number>`.
5. **Commit and push** the changed files with `github_push_files`. Use the local file content as the file content. Write a commit message such as `Document <feature> (batch converter issue #<number>)`.
6. **Create the pull request** with `github_create_pull_request`:
   - `owner`: `sorincarbunaru`, `repo`: `userguide-public`.
   - `base`: `master`, `head`: the new branch.
   - Title: a short summary of the docs change.
   - Body: a summary of the changes, the list of changed topics, and a link to the source issue (`https://github.com/sorincarbunaru/oxygen-batch-converter-addon-fork/issues/<number>`).
7. **Report** the pull request link and the list of changed topics to the user. Recommend a human review of the changes.

Do not ask for extra confirmation before creating the branch, committing, pushing, and creating the pull request.
