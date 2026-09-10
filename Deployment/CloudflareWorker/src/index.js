const githubHeaders = (token) => ({
  Accept: "application/vnd.github.raw+json",
  Authorization: `Bearer ${token}`,
  "User-Agent": "Surge-Relay-Worker/2.0",
  "X-GitHub-Api-Version": "2022-11-28",
});

const encodePath = (path) => path.split("/").map(encodeURIComponent).join("/");

const decodeRequestedPath = (pathname) => {
  const rawSegments = pathname.replace(/^\/+/, "").split("/");
  const segments = rawSegments.map((segment) => decodeURIComponent(segment));
  if (segments.some((segment) =>
    !segment || segment === "." || segment === ".." ||
    segment.includes("/") || segment.includes("\\") ||
    /[\u0000-\u001f\u007f]/u.test(segment)
  )) {
    return null;
  }
  return segments.join("/");
};

export const resolveRepositoryPath = (pathname) => {
  let requestedPath;
  try {
    requestedPath = decodeRequestedPath(pathname);
  } catch {
    return null;
  }
  if (!requestedPath) return null;

  if (/^modules\/[^/]+\.sgmodule$/u.test(requestedPath)) return requestedPath;
  if (/^airports\/[^/]+\.proxies$/u.test(requestedPath)) return requestedPath;
  if (/^modules\/assets\/(?:[^/]+\/)*[^/]+\.js$/u.test(requestedPath)) return requestedPath;

  // Compatibility with URLs copied by releases before root-level resource families.
  if (/^[^/]+\.sgmodule$/u.test(requestedPath)) return `modules/${requestedPath}`;
  if (/^assets\/(?:[^/]+\/)*[^/]+\.js$/u.test(requestedPath)) return `modules/${requestedPath}`;
  return null;
};

export const contentTypeForPath = (path) => {
  if (path.endsWith(".js")) return "application/javascript; charset=utf-8";
  return "text/plain; charset=utf-8";
};

export default {
  async fetch(request, env) {
    if (request.method !== "GET" && request.method !== "HEAD") {
      return new Response("Method Not Allowed", {
        status: 405,
        headers: { Allow: "GET, HEAD" },
      });
    }

    const url = new URL(request.url);
    if (url.pathname === "/" || url.pathname === "") {
      return Response.json({ service: "Surge Relay", status: "ok" }, {
        headers: { "Cache-Control": "no-store" },
      });
    }

    const repositoryPath = resolveRepositoryPath(url.pathname);
    if (!repositoryPath) return new Response("Not Found", { status: 404 });
    if (!env.GITHUB_TOKEN || !env.GITHUB_OWNER || !env.GITHUB_REPOSITORY) {
      return new Response("Worker is not configured", { status: 503 });
    }

    const branch = encodeURIComponent(env.GITHUB_BRANCH || "main");
    const apiURL = `https://api.github.com/repos/${encodeURIComponent(env.GITHUB_OWNER)}/${encodeURIComponent(env.GITHUB_REPOSITORY)}/contents/${encodePath(repositoryPath)}?ref=${branch}`;
    const upstream = await fetch(apiURL, { headers: githubHeaders(env.GITHUB_TOKEN) });

    if (!upstream.ok) {
      return new Response(upstream.status === 404 ? "Not Found" : "GitHub upstream error", {
        status: upstream.status,
        headers: { "Cache-Control": "no-store" },
      });
    }

    const headers = new Headers(upstream.headers);
    headers.set("Access-Control-Allow-Origin", "*");
    headers.set("Cache-Control", "public, max-age=60, stale-while-revalidate=300");
    headers.set("Content-Type", contentTypeForPath(repositoryPath));
    headers.delete("Authorization");
    headers.delete("Set-Cookie");

    return new Response(request.method === "HEAD" ? null : upstream.body, {
      status: 200,
      headers,
    });
  },
};
