const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "";

function safeParse(value) {
  if (!value) {
    return null;
  }

  try {
    return JSON.parse(value);
  } catch {
    return null;
  }
}

async function requestJson(path, options = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    ...options,
  });

  const text = await response.text();
  const body = text ? safeParse(text) || text : null;

  if (!response.ok) {
    const message =
      body && typeof body === "object" && body.message ? body.message : `Request failed (${response.status})`;
    throw new Error(message);
  }

  if (body && typeof body === "object" && body.success === false) {
    throw new Error(body.message || "Request failed");
  }

  return body && typeof body === "object" && "data" in body ? body.data : body;
}

export function loginRequest(email, password) {
  return requestJson("/api/v1/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });
}

export function refreshRequest(refreshToken) {
  return requestJson("/api/v1/auth/refresh", {
    method: "POST",
    body: JSON.stringify({ refreshToken }),
  });
}

export function logoutRequest(refreshToken) {
  return requestJson("/api/v1/auth/logout", {
    method: "POST",
    body: JSON.stringify({ refreshToken }),
  });
}
