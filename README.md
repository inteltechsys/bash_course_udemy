# bash_course_udemy

Personal training repo for the Udemy course ["Bash Mastery: The Complete Guide to Bash Shell Scripting"](https://www.udemy.com/course/bash-mastery/), by Denis Clairbois. The repo also contains Python scripts used for general scripting practice, alongside the bash material.

## Branches

- `main` — primary branch, holding the current state of the course work.
- `tests` — training branch, used to practice Git branching and merging workflows without touching `main`.
- `sandbox` — training branch, used for free experimentation (trying out ideas, scratch work) with no risk to `main`.

## Claude Code plugin

This repo bundles a Claude Code plugin (`bash-course-plugin`) — hooks, a skill, and a review agent for bash development. Install directly from this repo:

    /plugin install bash-course-plugin --marketplace inteltechsys/bash_course_udemy

See `my-plugin/` for the plugin source and `.claude-plugin/marketplace.json` for the in-repo marketplace definition.
