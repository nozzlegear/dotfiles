import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

export default function containerPreference(pi: ExtensionAPI): void {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return;

    const command = String(event.input.command ?? "");

    // Match only real invocations — `podman`/`docker` in command position:
    // start of the command, after a shell operator/pipe/command-substitution,
    // or after a common prefix (`sudo`, `env`, `time`, `nice`, `xargs`,
    // `timeout`). Mentions inside commit messages or echo strings, where the
    // word is merely an argument, are ignored.
    const invocation = /(?:^|[|;&`$(]\s*|\b(?:sudo|env|time|nice|xargs|timeout)\s+)(?:podman|docker)(?=\s|$)/;
    if (!invocation.test(command)) return;

    // Apple's `container` CLI only exists on macOS, and only when it's
    // actually installed. Only then do we reject podman/docker.
    const platform = await pi.exec("uname", ["-s"], { cwd: ctx.cwd });
    if (platform.stdout.trim() !== "Darwin") return;

    const container = await pi.exec("container", ["--version"], { cwd: ctx.cwd });
    if (container.code !== 0) return;

    return {
      block: true,
      reason:
        "On macOS, use Apple's `container` CLI instead of podman/docker — the interface is identical.\n\n" +
        "  docker build  → container build\n" +
        "  docker run    → container run\n" +
        "  docker pull   → container pull\n" +
        "  docker push   → container push\n" +
        "  docker images → container images\n" +
        "  docker logs   → container logs",
    };
  });
}
