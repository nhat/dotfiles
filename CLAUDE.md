# Repository closing

At the end of a task that writes to this repository, the parent must back up its committed default branch to the configured remote through `git-workflow`, using the standing push approval. This is a closing action, not shipping; it does not require `ship` or `LOCAL_READY`. Follow the existing push safeguards and report any pending backup with its reason.
