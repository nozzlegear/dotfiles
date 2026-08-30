import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

export default function jjPreference(pi: ExtensionAPI): void {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;

    const command = String(event.input.command ?? "");

    // Match only real git invocations — `git` in command position (start of the
    // command, after a shell operator/pipe/command-substitution, or after a
    // common prefix like sudo/env/time/nice/xargs/timeout). Matching command
    // position (and the (?<!-) guard) means flag usage such as `jj diff --git`
    // or `--tool=:git` is allowed, and mentions inside commit messages are ignored.
    const invocation = /(?:^|[|;&`$(]\s*|\b(?:sudo|env|time|nice|xargs|timeout)\s+)(?<!-)\bgit(?=\s|$)/;
    if (!invocation.test(command)) return;

    // Only block inside a specific jj repository — check each repo individually.
    const result = await pi.exec("jj", ["root"], { cwd: ctx.cwd });
    if (result.code !== 0) return;

    return {
      block: true,
      reason:
        "This is a jj repository. You must use jj commands instead of git.\n\n" +
        "jj commands are allowed, including `jj diff --git` (git-format output).\n" +
        "Did you mean one of these?\n" +
        "  git status      → jj status\n" +
        "  git diff        → jj diff\n" +
        "  git log         → jj log\n" +
        "  git add/commit  → jj new (jj auto-commits by default)\n" +
        "  git push        → jj push\n" +
        "  git pull        → jj pull\n" +
        "  git branch      → jj branch",
    };
  });
}