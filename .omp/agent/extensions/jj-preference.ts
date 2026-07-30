import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

export default function jjPreference(pi: ExtensionAPI): void {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;

    const command = String(event.input.command ?? "");
    if (!/^git(\s|$)/.test(command)) return;

    const result = await pi.exec("jj", ["root"], { cwd: ctx.cwd });
    if (result.code !== 0) return;

    return {
      block: true,
      reason:
        "This is a jj repository. You must use jj commands instead of git.\n\n" +
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