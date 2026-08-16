const STORAGE_KEYS = {
  accessToken: "futurePrime.accessToken",
  refreshToken: "futurePrime.refreshToken",
  user: "futurePrime.user",
};

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

export function loadSession() {
  if (typeof window === "undefined") {
    return null;
  }

  const user = safeParse(window.localStorage.getItem(STORAGE_KEYS.user));
  const accessToken = window.localStorage.getItem(STORAGE_KEYS.accessToken);
  const refreshToken = window.localStorage.getItem(STORAGE_KEYS.refreshToken);

  if (!accessToken || !refreshToken || !user) {
    return null;
  }

  return { accessToken, refreshToken, user };
}

export function saveSession(session) {
  window.localStorage.setItem(STORAGE_KEYS.accessToken, session.accessToken || "");
  window.localStorage.setItem(STORAGE_KEYS.refreshToken, session.refreshToken || "");
  window.localStorage.setItem(STORAGE_KEYS.user, JSON.stringify(session.user || null));
}

export function clearSession() {
  Object.values(STORAGE_KEYS).forEach((key) => window.localStorage.removeItem(key));
}
